import SwiftUI
import MLX
import MLXLLM
import MLXLMCommon
import MLXRandom
import SwiftUI

@Observable
final class ConcreteClipperAssistant: ClipperAssistant, @unchecked Sendable {
    private var lock = NSLock()
    private(set) var output: String = ""
    private(set) var stat: String = ""
    private(set) var modelInfo: (model: String, weights: String, numParams: String) = (model: "", weights: "0.0", numParams: "0")
    private(set) var llms: [any ClipperLLM] = modelList
    private(set) var llm: String?
    private let desfaultLLM: String = "mlx-community/Qwen2.5-1.5B-Instruct-4bit"
    private(set) var loadedLLM: CAModel?
    private(set) var running: Bool = false
    private(set) var isLoading: Bool = false
    private(set) var loadingProgress: (model: String, progress: Double) = (model: "", progress: 0.0)
    
    private let generateParameters: GenerateParameters
    
    /// A task responsible for handling the generation process.
    private(set) var generationTask: Task<Void, Error>?
    
    init() {
        self.generateParameters = GenerateParameters()
    }
    
    func load() {
        lock.withLock {
            generationTask = Task { @MainActor in
                UIApplication.shared.isIdleTimerDisabled = true
                defer {
                    UIApplication.shared.isIdleTimerDisabled = false
                }
                
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
                    output = "Failed: \(error)"
                }
            }
        }
    }
    
    func generate(prompt: String) {
        guard running == false else { return }
        lock.withLock {
            generationTask = Task { @MainActor in
                running = true
                output = ""
                guard let loadedLLM else { output = "No llm loaded"; return }
                let availableTools: [[String: Any]] = [
                    [
                        "type": "function",
                        "function": [
                            "name": "getTodayDate",
                            "description": "Get the current date and time",
                            "parameters": [
                                "type": "object",
                                "properties": [:],
                                "required": [],
                            ]
                        ]
                    ]
                ]
                
                let userInput = UserInput(
                    prompt: prompt,
                    tools: availableTools,
                    additionalContext: [
                        "Markdown": "true",
                        "markdownTheme": "gitHub",
                        "imageURL": "true"
                    ]
                )
                
                MLXRandom.seed(UInt64(Date.timeIntervalSinceReferenceDate * 1000))
                do {
                    try await loadedLLM.perform { (context: ModelContext) -> Void   in
                        let lmInput = try await context.processor.prepare(input: userInput)
                        let stream = try MLXLMCommon.generate(
                            input: lmInput, parameters: generateParameters, context: context)
                        output = "## \(prompt) \n"
                        
                        for await result in stream {
                            switch result {
                            case .token(let token):
                                output += context.tokenizer.decode(tokens: [token])
                            case .info(let info):
                                Task { @MainActor in
                                    self.stat = "\(info.tokensPerSecond) tokens/s"
                                }
                            }
                        }
                    }
                } catch {
                    output = "Failed: \(error)"
                }
                running = false
            }
        }
    }
    
    func selectedModel(_ id: String) {
        self.llm = id
    }
    
    // MARK: - Helpder methods
    
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
