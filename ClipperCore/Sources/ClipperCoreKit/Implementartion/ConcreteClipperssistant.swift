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
        // Let the LLM handle all tool calls intelligently (MLX-Outil style)
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
            let userInput = UserInput(
                prompt: .text(fullPromptForTextAPI),
                tools: toolSpecManager.myTools
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
                        let currentText = text // Capture current value to avoid data race
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
                
                // No tool calls - set final clean output
                let finalText = text // Capture final value to avoid data race
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
    

    

    
    // Clean LLM output of all technical artifacts
    private func cleanLLMOutput(_ text: String) -> String {
        var cleaned = text
        
        // Remove all MLX tokens and tool call syntax
        let patternsToRemove = [
            #"<\|[^|]+\|>"#,                    // All MLX tokens
            #"\{[^}]*"name"[^}]*\}"#,           // JSON tool calls
            #"```json.*?```"#,                 // JSON code blocks
            #"The function.*?was used.*?\."#,   // Function explanations
            #"This will.*?\."#,                // Generic explanations
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
    
    func selectedModel(_ id: String) {
        self.llm = id
    }
    
    // MARK: - Helper methods
    
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
                        
                        // Only parse if it's one of our valid tools
                        let validTools = ["getTodayDate", "searchDuckduckgo", "processSearchResults"]
                        guard validTools.contains(name) else { continue }
                        
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
        
        // Only trigger getTodayDate for very specific date-related queries
        let dateKeywords = ["today's date", "today date", "what's today", "current date", "what date is it", "what's the date", "todays date"]
        let isDateQuery = dateKeywords.contains { keyword in
            lowercased.contains(keyword)
        }
        
        if isDateQuery && !toolCalls.contains(where: { $0.name == "getTodayDate" }) {
            toolCalls.append(LocalToolCall(name: "getTodayDate", parameters: ["displayType": "view"]))
            return toolCalls // Return immediately to prevent other tool calls
        }
        
        // Be more restrictive about search - only trigger on explicit search requests
        let searchTriggers = ["search for", "look up", "find information about", "who is", "what is"]
        
        for trigger in searchTriggers {
            if lowercased.contains(trigger) {
                // Extract the query after the trigger
                if let range = lowercased.range(of: trigger) {
                    let afterTrigger = String(text[range.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
                    if !afterTrigger.isEmpty && afterTrigger.count > 2 {
                        // Clean the query - remove common question words
                        let cleanQuery = afterTrigger
                            .replacingOccurrences(of: "?", with: "")
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        if !cleanQuery.isEmpty && !toolCalls.contains(where: { $0.name == "searchDuckduckgo" }) {
                            toolCalls.append(LocalToolCall(name: "searchDuckduckgo", parameters: ["query": cleanQuery]))
                        }
                        break // Only add one search call
                    }
                }
            }
        }
        
        return toolCalls
    }
    
    private func removeToolCallSyntax(from text: String) -> String {
        var cleanedText = text
        
        // Remove the python_tag tool call patterns and MLX tokens
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
        
        // Remove any remaining tool call JSON patterns
        let jsonPattern = #"\{\s*"name":\s*"[^"]+"\s*,\s*"parameters":\s*\{[^}]*\}\s*\}"#
        cleanedText = cleanedText.replacingOccurrences(
            of: jsonPattern,
            with: "",
            options: [.regularExpression, .caseInsensitive]
        )
        
        // Remove common tool call explanations
        let explanationPatterns = [
            "The code above will.*?\\.",
            "This function call will.*?\\.",
            "This will.*?\\.",
            "The.*?function.*?will.*?\\.",
            "This JSON.*?will.*?\\.",
            "The function \".*?\" was used.*?\\.",
            "The \".*?\" function.*?\\.",
            "Function \".*?\" was called.*?\\.",
            "Using the \".*?\" function.*?\\.",
            "The.*?function returns.*?\\.",
            "This function.*?\\.",
            ".*?was used to.*?\\."
        ]
        
        for pattern in explanationPatterns {
            cleanedText = cleanedText.replacingOccurrences(
                of: pattern,
                with: "",
                options: [.regularExpression, .caseInsensitive]
            )
        }
        
        // Remove any lines that are purely explanatory about tools
        let lines = cleanedText.components(separatedBy: .newlines)
        let filteredLines = lines.filter { line in
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            
            // Skip empty lines or lines that explain tool usage
            if trimmedLine.isEmpty { return false }
            if trimmedLine.contains("function") && (trimmedLine.contains("was used") || trimmedLine.contains("returns") || trimmedLine.contains("will")) { return false }
            if trimmedLine.contains("tool") && (trimmedLine.contains("called") || trimmedLine.contains("executed")) { return false }
            if trimmedLine.starts(with: "the ") && trimmedLine.contains("function") { return false }
            if trimmedLine.starts(with: "using ") && trimmedLine.contains("function") { return false }
            
            return true
        }
        
        cleanedText = filteredLines.joined(separator: "\n")
        
        // Clean up extra whitespace and newlines
        cleanedText = cleanedText.replacingOccurrences(of: #"\n\s*\n\s*\n"#, with: "\n\n", options: .regularExpression)
        cleanedText = cleanedText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return cleanedText
    }
    
    private func createRichViewResponse(for toolCall: LocalToolCall, viewData: ToolViewData) -> String {
        switch viewData.type {
        case "date":
            if let dayName = viewData.data["dayName"] as? String,
               let fullDate = viewData.data["fullDate"] as? String,
               let time = viewData.data["time"] as? String {
                return "📅 **Today's Date**\n\n**\(dayName)** - \(time)\n\(fullDate)\n\n*Rich date view available in UI*"
            } else {
                return "📅 **Today's Date**\n\n*Date information available in rich view format*"
            }
            
        case "search_results":
            if let query = viewData.data["query"] as? String,
               let resultCount = viewData.data["resultCount"] as? Int {
                return "🔍 **Search Results for '\(query)'**\n\nFound \(resultCount) result\(resultCount == 1 ? "" : "s").\n\n*Rich search results view available in UI*"
            } else {
                return "🔍 **Search Results**\n\n*Search results available in rich view format*"
            }
            
        default:
            return "🎨 **Rich Content Available**\n\nType: \(viewData.type)\nTemplate: \(viewData.template)\n\n*Rich view available in UI*"
        }
    }
    
    private func decidePresentationType(for toolName: String, result: ToolFunctionResult) -> String {
        // AI logic to decide the best presentation method
        switch toolName {
        case "searchDuckduckgo":
            // For search results, check the query type and content
            if let query = result.metadata["originalQuery"] as? String {
                if query.lowercased().contains("president") || query.lowercased().contains("current") {
                    return "summary" // For factual queries, provide a summary
                } else if query.lowercased().contains("how to") || query.lowercased().contains("tutorial") {
                    return "webview" // For tutorials, show the actual webpage
                } else {
                    return "formatted" // For general queries, show formatted results
                }
            }
            return "summary"
        default:
            return "summary"
        }
    }
    
    private func formatToolResult(toolCall: LocalToolCall, result: ToolFunctionResult) -> String {
        var formatted = "**\(toolCall.name)**"
        
        if result.success {
            switch result.resultType {
            case .data(let data):
                if let resultDict = data as? [String: Any] {
                    formatted += "\n```json\n"
                    if let jsonData = try? JSONSerialization.data(withJSONObject: resultDict, options: .prettyPrinted),
                       let jsonString = String(data: jsonData, encoding: .utf8) {
                        formatted += jsonString
                    } else {
                        formatted += "\(resultDict)"
                    }
                    formatted += "\n```"
                } else {
                    formatted += "\n\(data)"
                }
                
            case .text(let text):
                formatted += "\n\(text)"
                
            case .richView(let viewData):
                formatted += "\n🎨 **Rich View: \(viewData.type)**\n"
                formatted += "Template: \(viewData.template)\n"
                
                // Format the view data for display
                if let jsonData = try? JSONSerialization.data(withJSONObject: viewData.data, options: .prettyPrinted),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    formatted += "```json\n\(jsonString)\n```"
                }
                
            case .webContent(let url):
                formatted += "\n🌐 **Web Content**\n"
                formatted += "URL: \(url.absoluteString)\n"
                if let title = result.metadata["title"] as? String {
                    formatted += "Title: \(title)\n"
                }
                if let snippet = result.metadata["snippet"] as? String {
                    formatted += "Preview: \(snippet)\n"
                }
                
            case .chainedData(let data):
                formatted += "\n🔗 **Chained Data** (processed by next tool)\n"
                if let dataDict = data as? [String: Any],
                   let jsonData = try? JSONSerialization.data(withJSONObject: dataDict, options: .prettyPrinted),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    formatted += "```json\n\(jsonString)\n```"
                }
            }
            
            // Add metadata if present
            if !result.metadata.isEmpty {
                formatted += "\n\n*Metadata:*\n"
                for (key, value) in result.metadata {
                    formatted += "- \(key): \(value)\n"
                }
            }
            
        } else {
            formatted += "\n❌ Error: \(result.error ?? "Unknown error")"
        }
        
        return formatted
    }
}

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
