import MLXLMCommon
import MLX
import SwiftUI
import ToolSpecsManager

/// A protocol representing a language model that can be used by the Clipper assistant.
///
/// Conforming types must be `Sendable` for thread-safe usage and `Identifiable`
/// for unique identification. This protocol provides basic information about
/// a language model including its identifier, display name, and description.
public protocol ClipperLLM
where Self: Sendable, Self: Identifiable {
    /// A unique identifier for the language model.
    var id: String { get }
    
    /// The display name of the language model.
    var name: String { get }
    
    /// A description of the language model's capabilities or characteristics.
    var description: String { get }
}

/// A protocol representing the main Clipper assistant that manages language models
/// and handles text generation.
///
/// Conforming types must be `Sendable` for thread-safe usage and `Observable`
/// for SwiftUI integration. This protocol provides functionality for loading models,
/// generating text, and managing available language models.
public protocol ClipperAssistant
where Self: Sendable, Self: Observable {
    /// A type alias for the model container type.
    typealias CAModel = ModelContainer
    
    /// Information about the current model including model name, weights path, and parameter count.
    /// - Returns: A tuple containing `(model: String, weights: String, numParams: String)`
    var modelInfo: (model: String, weights: String, numParams: String) { get }
    
    /// The current generated output text from the assistant.
    var output: String { get }
    
    /// Statistics information about the current generation or model state.
    var stat: String { get }
    
    /// A list of all available language models that can be used.
    var llms: [any ClipperLLM] { get }
    
    /// The identifier of the currently selected language model, if any.
    var llm: String? { get }
    
    /// The currently loaded model container, if a model has been loaded.
    var loadedLLM: CAModel? { get }
    
    /// Indicates whether a generation task is currently running.
    var running: Bool { get }
    
    /// Indicates whether a model is currently being loaded.
    var isLoading: Bool { get }
    
    /// The current loading progress for model loading operations.
    /// - Returns: A tuple containing `(model: String, progress: Double)` where progress is 0.0 to 1.0
    var loadingProgress: (model: String, progress: Double) { get }
    
    /// The current generation task, if one is active.
    var generationTask: Task<Void, Error>? { get }
    
    /// The tool specification manager for handling available tools and their specifications.
    var toolSpecManager: ToolSpecManager { get }
    
    /// Loads the selected language model asynchronously.
    ///
    /// This method should be called before generating text to ensure a model is loaded.
    /// The `isLoading` property will be updated during the loading process.
    func load() async
    
    /// Generates text based on the provided prompt.
    ///
    /// - Parameter prompt: The input text prompt to generate a response for.
    /// - Note: This method will update the `output` and `running` properties as generation progresses.
    func generate(prompt: String)
    
    /// Selects a language model by its identifier.
    ///
    /// - Parameter id: The unique identifier of the language model to select.
    /// - Note: The selected model must be loaded using `load()` before it can be used for generation.
    func selectedModel(_ id: String)
    
    /// Enable a specific tool by its identifier
    /// - Parameter toolId: The unique identifier of the tool to enable
    func enableTool(_ toolId: String) async
    
    /// Disable a specific tool by its identifier
    /// - Parameter toolId: The unique identifier of the tool to disable
    func disableTool(_ toolId: String) async
    
    /// Get all registered tools grouped by category
    func toolsByCategory() async -> [ToolCategory: [any AssistantTool]]
    
    /// Check if a tool is currently enabled
    /// - Parameter toolId: The unique identifier of the tool
    /// - Returns: True if the tool is enabled, false otherwise
    func isToolEnabled(_ toolId: String) async -> Bool
}

/// A protocol for accessing device statistics, particularly GPU usage information.
///
/// Conforming types must be `Sendable` for thread-safe usage and `Observable`
/// for SwiftUI integration. This protocol provides real-time device performance metrics.
public protocol DeviceStat
where Self: Sendable, Self: Observable {
    /// A type alias for the GPU type.
    typealias ClipperGPU = GPU
    
    /// The current GPU usage snapshot containing real-time GPU statistics.
    var gpuUsage: GPU.Snapshot { get }
}

// MARK: - Environment

/// SwiftUI environment values extension for accessing Clipper services.
public extension EnvironmentValues {
    /// Accesses the Clipper assistant from the SwiftUI environment.
    ///
    /// This property allows SwiftUI views to access the `ClipperAssistant` instance
    /// that manages language models and text generation. The assistant should be
    /// provided via the environment using `.environment(\.clipperAssistant, assistant)`.
    ///
    /// - Example:
    ///   ```swift
    ///   @Environment(\.clipperAssistant) var assistant
    ///   ```
    var clipperAssistant: ClipperAssistant {
        get {
            self[ClipperAssistantEnvironmentKey.self]
        } set {
            self[ClipperAssistantEnvironmentKey.self] = newValue
        }
    }
    
    /// Accesses the device statistics service from the SwiftUI environment.
    ///
    /// This property allows SwiftUI views to access the `DeviceStat` instance
    /// that provides GPU usage and other device performance metrics. The service
    /// should be provided via the environment using `.environment(\.deviceStat, deviceStat)`.
    ///
    /// - Example:
    ///   ```swift
    ///   @Environment(\.deviceStat) var deviceStat
    ///   ```
    var deviceStat: DeviceStat {
        get {
            self[DeviceStatEnvironmentKey.self]
        } set {
            self[DeviceStatEnvironmentKey.self] = newValue
        }
    }
}
