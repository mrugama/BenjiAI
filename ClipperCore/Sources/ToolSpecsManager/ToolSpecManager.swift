import MLXLMCommon

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
}

public struct ToolSpecManagerService: Sendable {
    public static func provideService() -> ToolSpecManager {
        ToolSpecManagerImpl()
    }
}
