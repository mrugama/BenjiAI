import SwiftUI
import MLX
import MLXLLM
import MLXLMCommon
import MLXRandom
import SwiftUI
import ToolSpecsManager
import OSLog

@Observable
final class ConcreteClipperAssistant: ClipperAssistant, @unchecked Sendable {
    private(set) var output: String = ""
    private(set) var stat: String = ""
    private(set) var modelInfo: (model: String, weights: String, numParams: String) = (model: "", weights: "0.0", numParams: "0")
    private(set) var llms: [any ClipperLLM] = modelList
    private(set) var llm: String?
    private let desfaultLLM: String = "mlx-community/Llama-3.2-3B-Instruct"
    private(set) var loadedLLM: CAModel?
    private(set) var running: Bool = false
    private(set) var isLoading: Bool = false
    private(set) var loadingProgress: (model: String, progress: Double) = (model: "", progress: 0.0)
    
    private let generateParameters: GenerateParameters
    private(set) var toolSpecManager: ToolSpecManager
    
    // Tool execution control
    private let maxToolIterations = 5
    private var currentToolIteration = 0
    
    /// A task responsible for handling the generation process.
    private(set) var generationTask: Task<Void, Error>?
    
    private let logger = Logger(subsystem: "com.techconte.benji", category: "ConcreteClipperAssistant")
    
    init(_ toolSpecManager: ToolSpecManager) {
        self.generateParameters = GenerateParameters()
        self.toolSpecManager = toolSpecManager
    }
    
    func load() async {
        logger.debug("Starting loading model work on thread (isMainThread: \(Thread.current.isMainThread)): \(Thread.current.description)")
        
        isLoading = true
        MLX.GPU.set(cacheLimit: 512 * 1024 * 1024)
        await manageModelLoading()
        let modelConfiguration = LLMModelFactory.shared.configuration(id: llm ?? desfaultLLM)
        do {
            loadedLLM = try await LLMModelFactory.shared.loadContainer(
                configuration: modelConfiguration
            ) { [unowned self] progress in
                loadingProgress.model = modelConfiguration.name
                loadingProgress.progress = progress.fractionCompleted
            }
            
            guard let loadedLLM else { throw ClipperAssistantError.noModelContainer }
            let numParams = await loadedLLM.perform { context in
                context.model.numParameters()
            }
            modelInfo.model = modelConfiguration.name
            modelInfo.weights = "\(numParams / (1024*1024))M"
            modelInfo.numParams = "\(numParams)"
            isLoading = false
        } catch {
            await MainActor.run {
                output = "Failed: \(error)"
            }
        }
    }
    
    func generate(prompt: String) {
        generationTask = Task { @MainActor in
            guard !running, loadedLLM != nil else { return }
            running = true
            output = ""
            currentToolIteration = 0
            guard let loadedLLM else { output = "No llm loaded"; return }
            
            await generateWithToolSupport(prompt: prompt, loadedLLM: loadedLLM)
            running = false
        }
    }
    
    private func generateWithToolSupport(prompt: String, loadedLLM: CAModel) async {
        logger.info("Prompting model work on thread (isMainThread: \(Thread.current.isMainThread)): \(Thread.current.description)")
        let conversationHistory = "## \(prompt) \n"
        let personalInfo = """
            [PERSONAL_CONTEXT]
            {
              "user_languages": ["Spanish", "English"],
              "user_location": "Brooklyn, NY, USA",
              "user_nationalities": "American",
              "user_full_name": "Marlon Rugama",
              "user_dob": "Jan/20/1990"
            }
            [/PERSONAL_CONTEXT]
            
            \(prompt)
            """
        
        let systemPrompt = """
        You are a helpful assistant. Below is the current user's personal context provided as a JSON object. You MUST use this information to answer questions about the user's personal details. Acknowledge that you have access to this context.

        CONTEXT:
        \(personalInfo)
        """

        let fullPromptForTextAPI = """
        \(systemPrompt)

        USER_QUERY:
        \(prompt)
        """
        
        MLXRandom.seed(UInt64(Date.timeIntervalSinceReferenceDate * 1000))
        
        do {
            // Get current tool specifications
            let tools = toolSpecManager.myTools
            
            let userInput = UserInput(
                prompt: .text(fullPromptForTextAPI),
                tools: tools
            )
            let currentHistory = conversationHistory
            try await loadedLLM.perform { (context: ModelContext) -> Void in
                let lmInput = try await context.processor.prepare(input: userInput)
                let stream = try MLXLMCommon.generate(
                    input: lmInput, parameters: generateParameters, context: context)
                
                var text = ""
                for await result in stream {
                    switch result {
                    case .chunk(let chunk):
                        text += chunk
                        let currentText = text
                        await MainActor.run {
                            self.output = currentHistory + currentText
                        }
                    case .info(let info):
                        await MainActor.run {
                            self.stat = "\(info.tokensPerSecond) tokens/s"
                        }
                    case .toolCall:
                        // Tool calls are handled separately if needed
                        break
                    }
                }
                
                // Check if the output contains tool calls and execute them
                let finalText = await self.processToolCallsIfNeeded(text: text, conversationHistory: currentHistory)
                
                await MainActor.run {
                    self.output = currentHistory + finalText
                }
            }
            
        } catch {
            let errorHistory = conversationHistory + "\n\nFailed: \(error)"
            Task { @MainActor in
                self.output = errorHistory
            }
        }
    }
    
    // MARK: - Tool Call Processing
    
    private func processToolCallsIfNeeded(text: String, conversationHistory: String) async -> String {
        let toolCalls = parseToolCalls(from: text)
        
        guard !toolCalls.isEmpty, currentToolIteration < maxToolIterations else {
            return cleanLLMOutput(text)
        }
        
        currentToolIteration += 1
        
        var resultText = text
        var toolResults: [String] = []
        
        for toolCall in toolCalls {
            let result = await toolSpecManager.executeToolFunction(
                name: toolCall.name,
                parameters: toolCall.parameters
            )
            
            if result.success {
                let formattedResult = formatToolResult(toolCall: toolCall, result: result)
                toolResults.append(formattedResult)
                
                // Handle rich view results
                if case .richView(let viewData) = result.resultType {
                    let richResponse = createRichViewResponse(for: toolCall, viewData: viewData)
                    toolResults.append(richResponse)
                }
                
                // Handle chained tool calls
                if result.shouldChain, let nextTool = result.suggestedNextTool {
                    if case .chainedData(let chainedData) = result.resultType,
                       let dataDict = chainedData as? [String: Any] {
                        let chainedResult = await toolSpecManager.executeToolFunction(
                            name: nextTool,
                            parameters: dataDict
                        )
                        if chainedResult.success {
                            let chainedFormatted = formatToolResult(
                                toolCall: LocalToolCall(name: nextTool, parameters: dataDict),
                                result: chainedResult
                            )
                            toolResults.append(chainedFormatted)
                        }
                    }
                }
            } else {
                toolResults.append("❌ \(toolCall.name) failed: \(result.error ?? "Unknown error")")
            }
        }
        
        // Clean the original text and append tool results
        resultText = cleanLLMOutput(text)
        if !toolResults.isEmpty {
            resultText += "\n\n" + toolResults.joined(separator: "\n\n")
        }
        
        return resultText
    }
    
    // MARK: - Tool Call Parsing
    
    struct LocalToolCall {
        let name: String
        let parameters: [String: Any]
    }
    
    private func parseToolCalls(from text: String) -> [LocalToolCall] {
        var toolCalls: [LocalToolCall] = []
        
        // Look for the specific MLX tool call format with <|python_tag|>
        let pythonTagPattern = #"<\|python_tag\|>\s*\{\s*"name":\s*"([^"]+)"\s*,\s*"parameters":\s*(\{[^}]*\})\s*\}\s*<\|eom_id\|>"#
        
        if let regex = try? NSRegularExpression(pattern: pythonTagPattern, options: [.caseInsensitive]) {
            let matches = regex.matches(in: text, options: [], range: NSRange(text.startIndex..., in: text))
            
            for match in matches {
                if match.numberOfRanges >= 3 {
                    let nameRange = Range(match.range(at: 1), in: text)
                    let parametersRange = Range(match.range(at: 2), in: text)
                    
                    if let nameRange = nameRange, let parametersRange = parametersRange {
                        let name = String(text[nameRange])
                        let parametersString = String(text[parametersRange])
                        
                        // Parse the parameters JSON
                        if let parametersData = parametersString.data(using: .utf8),
                           let parameters = try? JSONSerialization.jsonObject(with: parametersData) as? [String: Any] {
                            toolCalls.append(LocalToolCall(name: name, parameters: parameters))
                        }
                    }
                }
            }
        }
        
        // If no python_tag format found, check for simple natural language intent
        if toolCalls.isEmpty {
            toolCalls.append(contentsOf: parseSimpleToolCalls(from: text))
        }
        
        return toolCalls
    }
    
    private func parseSimpleToolCalls(from text: String) -> [LocalToolCall] {
        var toolCalls: [LocalToolCall] = []
        let lowercased = text.lowercased()
        
        // Date-related queries
        let dateKeywords = ["today's date", "today date", "what's today", "current date", "what date is it", "what's the date", "todays date"]
        let isDateQuery = dateKeywords.contains { keyword in
            lowercased.contains(keyword)
        }
        
        if isDateQuery && !toolCalls.contains(where: { $0.name == "getTodayDate" }) {
            toolCalls.append(LocalToolCall(name: "getTodayDate", parameters: ["displayType": "view"]))
            return toolCalls
        }
        
        // Search triggers
        let searchTriggers = ["search for", "look up", "find information about", "who is", "what is"]
        
        for trigger in searchTriggers {
            if lowercased.contains(trigger) {
                if let range = lowercased.range(of: trigger) {
                    let afterTrigger = String(text[range.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
                    if !afterTrigger.isEmpty && afterTrigger.count > 2 {
                        let cleanQuery = afterTrigger
                            .replacingOccurrences(of: "?", with: "")
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        if !cleanQuery.isEmpty && !toolCalls.contains(where: { $0.name == "searchDuckduckgo" }) {
                            toolCalls.append(LocalToolCall(name: "searchDuckduckgo", parameters: ["query": cleanQuery]))
                        }
                        break
                    }
                }
            }
        }
        
        return toolCalls
    }
    
    // MARK: - Output Cleaning
    
    private func cleanLLMOutput(_ text: String) -> String {
        var cleaned = text
        
        // Remove all MLX tokens and tool call syntax
        let patternsToRemove = [
            #"<\|[^|]+\|>"#,
            #"\{[^}]*"name"[^}]*\}"#,
            #"```json.*?```"#,
            #"The function.*?was used.*?\."#,
            #"This will.*?\."#,
        ]
        
        for pattern in patternsToRemove {
            cleaned = cleaned.replacingOccurrences(
                of: pattern,
                with: "",
                options: [.regularExpression, .caseInsensitive]
            )
        }
        
        // Clean up whitespace
        cleaned = cleaned.replacingOccurrences(of: #"\n\s*\n\s*\n"#, with: "\n\n", options: .regularExpression)
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return cleaned
    }
    
    private func removeToolCallSyntax(from text: String) -> String {
        var cleanedText = text
        
        let mlxPatterns = [
            #"<\|python_tag\|>.*?<\|eom_id\|>"#,
            #"<\|start_header_id\|>assistant<\|end_header_id\|>"#,
            #"<\|eom_id\|><\|start_header_id\|>assistant<\|end_header_id\|>"#,
            #"<\|eom_id\|>"#,
            #"<\|start_header_id\|>.*?<\|end_header_id\|>"#
        ]
        
        for pattern in mlxPatterns {
            cleanedText = cleanedText.replacingOccurrences(
                of: pattern,
                with: "",
                options: [.regularExpression, .caseInsensitive]
            )
        }
        
        let jsonPattern = #"\{\s*"name":\s*"[^"]+"\s*,\s*"parameters":\s*\{[^}]*\}\s*\}"#
        cleanedText = cleanedText.replacingOccurrences(
            of: jsonPattern,
            with: "",
            options: [.regularExpression, .caseInsensitive]
        )
        
        cleanedText = cleanedText.replacingOccurrences(of: #"\n\s*\n\s*\n"#, with: "\n\n", options: .regularExpression)
        cleanedText = cleanedText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return cleanedText
    }
    
    // MARK: - Tool Result Formatting
    
    private func createRichViewResponse(for toolCall: LocalToolCall, viewData: ToolViewData) -> String {
        switch viewData.type {
        case "date":
            if let dayName = viewData.data["dayName"] as? String,
               let fullDate = viewData.data["fullDate"] as? String,
               let time = viewData.data["time"] as? String {
                return "📅 **Today's Date**\n\n**\(dayName)** - \(time)\n\(fullDate)"
            } else {
                return "📅 **Today's Date**\n\n*Date information available*"
            }
            
        case "search_results":
            if let query = viewData.data["query"] as? String,
               let resultCount = viewData.data["resultCount"] as? Int {
                return "🔍 **Search Results for '\(query)'**\n\nFound \(resultCount) result\(resultCount == 1 ? "" : "s")."
            } else {
                return "🔍 **Search Results**\n\n*Search results available*"
            }
            
        case "calendar_event", "calendar_events_list":
            if let title = viewData.data["title"] as? String {
                return "📅 **Calendar Event: \(title)**"
            }
            return "📅 **Calendar Information**"
            
        case "reminder", "reminders_list":
            if let title = viewData.data["title"] as? String {
                return "⏰ **Reminder: \(title)**"
            }
            return "⏰ **Reminder Information**"
            
        case "contacts_list", "contact_detail":
            return "👤 **Contact Information**"
            
        case "current_location", "geocoded_location", "distance_calculation":
            if let address = viewData.data["address"] as? String {
                return "📍 **Location: \(address)**"
            }
            return "📍 **Location Information**"
            
        case "music_search_results", "now_playing", "playback_state":
            return "🎵 **Music**"
            
        default:
            return "🎨 **\(viewData.type)**"
        }
    }
    
    private func formatToolResult(toolCall: LocalToolCall, result: ToolFunctionResult) -> String {
        var formatted = ""
        
        if result.success {
            switch result.resultType {
            case .data(let data):
                if let resultDict = data as? [String: Any] {
                    if let jsonData = try? JSONSerialization.data(withJSONObject: resultDict, options: .prettyPrinted),
                       let jsonString = String(data: jsonData, encoding: .utf8) {
                        formatted = "```json\n\(jsonString)\n```"
                    } else {
                        formatted = "\(resultDict)"
                    }
                } else {
                    formatted = "\(data)"
                }
                
            case .text(let text):
                formatted = text
                
            case .richView(let viewData):
                formatted = createRichViewResponse(for: toolCall, viewData: viewData)
                
            case .webContent(let url):
                formatted = "🌐 **Web Content**\nURL: \(url.absoluteString)"
                if let title = result.metadata["title"] as? String {
                    formatted += "\nTitle: \(title)"
                }
                
            case .chainedData:
                // Chained data is processed separately
                formatted = ""
            }
        } else {
            formatted = "❌ Error: \(result.error ?? "Unknown error")"
        }
        
        return formatted
    }
    
    // MARK: - Model Selection
    
    func selectedModel(_ id: String) {
        self.llm = id
    }
    
    // MARK: - Tool Management
    
    func enableTool(_ toolId: String) async {
        await toolSpecManager.enableTool(id: toolId)
    }
    
    func disableTool(_ toolId: String) async {
        await toolSpecManager.disableTool(id: toolId)
    }
    
    func toolsByCategory() async -> [ToolCategory: [any AssistantTool]] {
        let registeredTools = await toolSpecManager.registeredTools
        var result: [ToolCategory: [any AssistantTool]] = [:]
        
        for tool in registeredTools.values {
            var tools = result[tool.category] ?? []
            tools.append(tool)
            result[tool.category] = tools
        }
        
        return result
    }
    
    func isToolEnabled(_ toolId: String) async -> Bool {
        let selectedTools = await toolSpecManager.selectedTools
        return selectedTools[toolId] != nil
    }
    
    // MARK: - Private Helper Methods
    
    private func manageModelLoading() async {
        if let loadedLLM, await loadedLLM.configuration.name != llm {
            let loadedModelDirURL = await loadedLLM.configuration.modelDirectory()
            deleteFile(at: loadedModelDirURL)
        }
    }
    
    func deleteFile(at url: URL) {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: url.path) {
            do {
                try fileManager.removeItem(at: url)
            } catch {
                output = "Error deleting file: \(error)"
            }
        } else {
            output = "File does not exist at path: \(url.path)"
        }
    }
}

// MARK: - Errors

enum ClipperAssistantError: LocalizedError {
    case invalidInput, invalidOutput,
         unknownError, noModelConfiguration,
         noModelContainer
    
    var errorDescription: String? {
        switch self {
        case .invalidInput:
            return "Invalid input provided."
        case .invalidOutput:
            return "Invalid output provided."
        case .unknownError:
            return "An unknown error occurred."
        case .noModelConfiguration:
            return "No model configuration found."
        case .noModelContainer:
            return "No model container found."
        }
    }
}
