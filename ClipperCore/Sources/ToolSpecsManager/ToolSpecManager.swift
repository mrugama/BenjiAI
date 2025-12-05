import Foundation

// MARK: - Tool Result Types

/// Represents the type of result returned by a tool execution
public enum ToolResultType: Sendable {
    /// Raw data response
    case data(any Sendable)
    /// Formatted text response
    case text(String)
    /// Rich view data for SwiftUI rendering
    case richView(ToolViewData)
    /// Web content to display
    case webContent(URL)
    /// Data intended for chaining to another tool
    case chainedData(any Sendable)
}

/// Data structure for rich SwiftUI view rendering
public struct ToolViewData: Sendable {
    /// The type of view (e.g., "date", "search_results", "calendar_event")
    public let type: String
    /// The data to be rendered
    public let data: [String: any Sendable]
    /// Template identifier for view rendering
    public let template: String
    
    public init(type: String, data: [String: any Sendable], template: String) {
        self.type = type
        self.data = data
        self.template = template
    }
}

/// Result of a tool function execution
public struct ToolFunctionResult: Sendable {
    public let success: Bool
    public let resultType: ToolResultType
    public let error: String?
    /// Indicates if this result should trigger another tool call
    public let shouldChain: Bool
    /// Suggested next tool to call in a chain
    public let suggestedNextTool: String?
    /// Additional metadata about the execution
    public let metadata: [String: any Sendable]
    
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
    
    /// Convenience initializer for simple results
    public init(success: Bool, result: any Sendable, error: String? = nil) {
        self.init(
            success: success,
            resultType: .data(result),
            error: error
        )
    }
    
    /// Creates a successful text result
    public static func success(text: String, metadata: [String: any Sendable] = [:]) -> ToolFunctionResult {
        ToolFunctionResult(success: true, resultType: .text(text), metadata: metadata)
    }
    
    /// Creates a successful rich view result
    public static func success(viewData: ToolViewData, metadata: [String: any Sendable] = [:]) -> ToolFunctionResult {
        ToolFunctionResult(success: true, resultType: .richView(viewData), metadata: metadata)
    }
    
    /// Creates a failure result
    public static func failure(error: String) -> ToolFunctionResult {
        ToolFunctionResult(success: false, resultType: .text(error), error: error)
    }
}

// MARK: - Tool Specification Value

/// Represents a JSON-compatible value for tool specifications
public enum ToolSpecValue: Sendable, Equatable {
    case string(String)
    case number(Double)
    case integer(Int)
    case bool(Bool)
    case object([String: ToolSpecValue])
    case array([ToolSpecValue])
    case null
    
    /// Converts to Any type for JSON serialization
    public func toAny() -> Any {
        switch self {
        case .string(let str): return str
        case .number(let num): return num
        case .integer(let int): return int
        case .bool(let bool): return bool
        case .object(let dict): return dict.mapValues { $0.toAny() }
        case .array(let arr): return arr.map { $0.toAny() }
        case .null: return NSNull()
        }
    }
}

// MARK: - Tool Category

/// Categories of available tools
public enum ToolCategory: String, Sendable, CaseIterable {
    case calendar = "Calendar"
    case reminder = "Reminder"
    case contact = "Contact"
    case location = "Location"
    case music = "Music"
    case search = "Search"
    case queryRefine = "Query Refine"
    case utility = "Utility"
}

// MARK: - Tool Protocol

/// Base protocol for all assistant tools
public protocol AssistantTool: Sendable {
    /// Unique identifier for the tool
    var id: String { get }
    
    /// Human-readable name
    var name: String { get }
    
    /// Description of what the tool does (named toolDescription to avoid NSObject conflict)
    var toolDescription: String { get }
    
    /// Category this tool belongs to
    var category: ToolCategory { get }
    
    /// The tool specification for LLM integration
    var specification: ToolSpecification { get }
    
    /// Execute the tool with given parameters
    func execute(parameters: [String: Any]) async throws -> ToolFunctionResult
}

/// Represents the full specification of a tool for LLM integration
public struct ToolSpecification: Sendable {
    public let name: String
    public let description: String
    public let parameters: ToolParameters
    
    public init(name: String, description: String, parameters: ToolParameters) {
        self.name = name
        self.description = description
        self.parameters = parameters
    }
    
    /// Converts to dictionary format expected by LLM
    public func toDictionary() -> [String: Any] {
        [
            "type": "function",
            "function": [
                "name": name,
                "description": description,
                "parameters": parameters.toDictionary()
            ]
        ]
    }
}

/// Represents the parameters schema for a tool
public struct ToolParameters: Sendable {
    public let type: String
    public let properties: [String: ToolParameterProperty]
    public let required: [String]
    
    public init(
        type: String = "object",
        properties: [String: ToolParameterProperty],
        required: [String] = []
    ) {
        self.type = type
        self.properties = properties
        self.required = required
    }
    
    public func toDictionary() -> [String: Any] {
        [
            "type": type,
            "properties": properties.mapValues { $0.toDictionary() },
            "required": required
        ]
    }
}

/// Represents a single parameter property
public struct ToolParameterProperty: Sendable {
    public let type: String
    public let description: String
    public let enumValues: [String]?
    
    public init(
        type: String,
        description: String,
        enumValues: [String]? = nil
    ) {
        self.type = type
        self.description = description
        self.enumValues = enumValues
    }
    
    public func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "type": type,
            "description": description
        ]
        if let enumValues = enumValues {
            dict["enum"] = enumValues
        }
        return dict
    }
}

// MARK: - Tool-Specific Protocols

/// Protocol for calendar-related tools
public protocol CalendarTool: AssistantTool {
    func createEvent(title: String, startDate: Date, endDate: Date, notes: String?) async throws -> ToolFunctionResult
    func readEvents(startDate: Date, endDate: Date) async throws -> ToolFunctionResult
    func updateEvent(eventId: String, title: String?, startDate: Date?, endDate: Date?, notes: String?) async throws -> ToolFunctionResult
    func queryEvents(query: String) async throws -> ToolFunctionResult
}

/// Protocol for reminder-related tools
public protocol ReminderTool: AssistantTool {
    func createReminder(title: String, dueDate: Date?, notes: String?, priority: Int?) async throws -> ToolFunctionResult
    func readReminders(listName: String?) async throws -> ToolFunctionResult
    func updateReminder(reminderId: String, title: String?, dueDate: Date?, notes: String?, priority: Int?) async throws -> ToolFunctionResult
    func completeReminder(reminderId: String) async throws -> ToolFunctionResult
    func queryReminders(query: String) async throws -> ToolFunctionResult
}

/// Protocol for contact-related tools
public protocol ContactTool: AssistantTool {
    func searchContacts(query: String) async throws -> ToolFunctionResult
    func readContact(contactId: String) async throws -> ToolFunctionResult
    func createContact(firstName: String, lastName: String?, phoneNumber: String?, email: String?) async throws -> ToolFunctionResult
}

/// Protocol for location-related tools
public protocol LocationTool: AssistantTool {
    func getCurrentLocation() async throws -> ToolFunctionResult
    func geocodeAddress(address: String) async throws -> ToolFunctionResult
    func calculateDistance(from: String, to: String) async throws -> ToolFunctionResult
}

/// Protocol for music-related tools
public protocol MusicTool: AssistantTool {
    func searchMusic(query: String, type: String?) async throws -> ToolFunctionResult
    func playMusic(trackId: String) async throws -> ToolFunctionResult
    func pauseMusic() async throws -> ToolFunctionResult
    func resumeMusic() async throws -> ToolFunctionResult
    func skipTrack() async throws -> ToolFunctionResult
    func previousTrack() async throws -> ToolFunctionResult
}

/// Protocol for search-related tools
public protocol SearchTool: AssistantTool {
    func search(query: String) async throws -> ToolFunctionResult
}

/// Protocol for query refinement tools
public protocol QueryRefineTool: AssistantTool {
    func refineQuery(originalQuery: String, context: String?) async throws -> ToolFunctionResult
}

// MARK: - Tool Errors

/// Errors that can occur during tool execution
public enum ToolError: Error, Sendable {
    case missingParameter(String)
    case invalidParameter(String, reason: String)
    case executionFailed(String)
    case permissionDenied(String)
    case notAvailable(String)
    case networkError(String)
    case unknown(String)
    
    public var localizedDescription: String {
        switch self {
        case .missingParameter(let param):
            return "Missing required parameter: \(param)"
        case .invalidParameter(let param, let reason):
            return "Invalid parameter '\(param)': \(reason)"
        case .executionFailed(let reason):
            return "Tool execution failed: \(reason)"
        case .permissionDenied(let resource):
            return "Permission denied for: \(resource)"
        case .notAvailable(let feature):
            return "Feature not available: \(feature)"
        case .networkError(let reason):
            return "Network error: \(reason)"
        case .unknown(let message):
            return "Unknown error: \(message)"
        }
    }
}

// MARK: - Tool Manager Protocol

/// Protocol for managing tool registration, selection, and execution
public protocol ToolSpecManager: Sendable {
    /// All registered tools
    var registeredTools: [String: any AssistantTool] { get async }
    
    /// Currently selected/enabled tools
    var selectedTools: [String: any AssistantTool] { get async }
    
    /// Tool specifications formatted for LLM consumption
    var toolSpecifications: [[String: Any]] { get async }
    
    /// Available tools dictionary (for backward compatibility)
    var availableTools: [String: [String: ToolSpecValue]] { get }
    
    /// My tools array (for backward compatibility)
    var myTools: [[String: Any]] { get }
    
    /// Register a new tool
    func registerTool(_ tool: any AssistantTool) async
    
    /// Unregister a tool by ID
    func unregisterTool(id: String) async
    
    /// Enable a tool for use
    func enableTool(id: String) async
    
    /// Disable a tool
    func disableTool(id: String) async
    
    /// Add tool (backward compatibility)
    func addTool(_ toolName: String) async
    
    /// Remove tool (backward compatibility)
    func removeTool(_ toolName: String) async
    
    /// Get tools by category
    func tools(in category: ToolCategory) async -> [any AssistantTool]
    
    /// Execute a tool function by name
    func executeToolFunction(name: String, parameters: [String: Any]) async -> ToolFunctionResult
    
    /// Pretty print utility
    func prettyPrint(_ value: Any) -> String
    func prettyPrint(_ value: Any, indentLevel: Int) -> String
}

// MARK: - Service Provider

/// Service provider for ToolSpecManager
public struct ToolSpecManagerService: Sendable {
    public static func provideService() -> ToolSpecManager {
        ToolSpecManagerImpl.shared
    }
}
