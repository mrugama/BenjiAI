import MLXLMCommon
import MLX
import SwiftUI
import ToolSpecsManager

public protocol ClipperLLM
where Self: Sendable, Self: Identifiable {
    var id: String { get }
    var name: String { get }
    var description: String { get }
}

public protocol ClipperAssistant
where Self: Sendable, Self: Observable {
    typealias CAModel = ModelContainer
    
    var modelInfo: (model: String, weights: String, numParams: String) { get }
    var output: String { get }
    var stat: String { get }
    var llms: [any ClipperLLM] { get }
    var llm: String? { get }
    var loadedLLM: CAModel? { get }
    var running: Bool { get }
    var isLoading: Bool { get }
    var loadingProgress: (model: String, progress: Double) { get }
    var generationTask: Task<Void, Error>? { get }
    var toolSpecManager: ToolSpecManager { get }
    
    func load() async
    
    func generate(prompt: String)
    
    func selectedModel(_ id: String)
}

public protocol DeviceStat
where Self: Sendable, Self: Observable {
    typealias ClipperGPU = GPU
    //@MainActor
    var gpuUsage: GPU.Snapshot { get }
}

// MARK: - Environment

public extension EnvironmentValues {
    var clipperAssistant: ClipperAssistant {
        get {
            self[ClipperAssistantEnvironmentKey.self]
        } set {
            self[ClipperAssistantEnvironmentKey.self] = newValue
        }
    }
    
    var deviceStat: DeviceStat {
        get {
            self[DeviceStatEnvironmentKey.self]
        } set {
            self[DeviceStatEnvironmentKey.self] = newValue
        }
    }
}
