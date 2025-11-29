import MLXLMCommon
import SwiftUI

// MARK: - Tool Function Results

public enum ToolResultType: Sendable {
    case data(any Sendable)           // Raw data response
    case text(String)                 // Formatted text response
    case richView(ToolViewData)      // Rich view data for SwiftUI
    case webContent(URL)             // Web content to display
    case chainedData(any Sendable)   // Data for next tool in chain
}

public struct ToolViewData: Sendable {
    public let type: String           // "date", "search_results", "web_content", etc.
    public let data: [String: any Sendable]
    public let template: String       // Template identifier for view rendering
    
    public init(type: String, data: [String: any Sendable], template: String) {
        self.type = type
        self.data = data
        self.template = template
    }
}

public struct ToolFunctionResult: Sendable {
    public let success: Bool
    public let resultType: ToolResultType
    public let error: String?
    public let shouldChain: Bool      // Indicates if this should trigger another tool call
    public let suggestedNextTool: String? // Suggested next tool to call
    public let metadata: [String: any Sendable] // Additional metadata
    
    public init(
        success: Bool, 
        resultType: ToolResultType, 
        error: String? = nil,
        shouldChain: Bool = false,
        suggestedNextTool: String? = nil,
        metadata: [String: any Sendable] = [:]
    ) {
        self.success = success
        self.resultType = resultType
        self.error = error
        self.shouldChain = shouldChain
        self.suggestedNextTool = suggestedNextTool
        self.metadata = metadata
    }
    
    // Convenience initializers for backward compatibility
    public init(success: Bool, result: any Sendable, error: String? = nil) {
        self.init(
            success: success,
            resultType: .data(result),
            error: error
        )
    }
}

public enum ToolSpecValue: Sendable {
    case string(String)
    case number(Double)
    case bool(Bool)
    case object([String: ToolSpecValue])
    case array([ToolSpecValue])
    case null
}

public protocol ToolSpecManager
where Self: Sendable {
    var availableTools: [String: [String: ToolSpecValue]] { get }
    var myTools: [[String: Any]] { get }
    
    func addTool(_ toolName: String) async
    func removeTool(_ toolName: String) async
    
    func prettyPrint(_ value: Any) -> String
    func prettyPrint(_ value: Any, indentLevel: Int) -> String
    
    func executeToolFunction(name: String, parameters: [String: Any]) async -> ToolFunctionResult
}

public struct ToolSpecManagerService: Sendable {
    public static func provideService() -> ToolSpecManager {
        ToolSpecManagerImpl()
    }
}
