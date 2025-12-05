import Foundation

// MARK: - Tool Specification Manager Implementation

/// Actor-based implementation of ToolSpecManager for thread-safe tool management
actor ToolSpecManagerActor {
    var registeredTools: [String: any AssistantTool] = [:]
    var selectedTools: [String: any AssistantTool] = [:]
    
    func register(_ tool: any AssistantTool) {
        registeredTools[tool.id] = tool
    }
    
    func select(_ tool: any AssistantTool) {
        selectedTools[tool.id] = tool
    }
    
    func unregister(id: String) {
        registeredTools.removeValue(forKey: id)
        selectedTools.removeValue(forKey: id)
    }
    
    func enable(id: String) {
        if let tool = registeredTools[id] {
            selectedTools[id] = tool
        }
    }
    
    func disable(id: String) {
        selectedTools.removeValue(forKey: id)
    }
    
    func getTool(id: String) -> (any AssistantTool)? {
        registeredTools[id]
    }
    
    func getRegisteredTools() -> [String: any AssistantTool] {
        registeredTools
    }
    
    func getSelectedTools() -> [String: any AssistantTool] {
        selectedTools
    }
    
    func toolsIn(category: ToolCategory) -> [any AssistantTool] {
        registeredTools.values.filter { $0.category == category }
    }
    
    func isEnabled(id: String) -> Bool {
        selectedTools[id] != nil
    }
    
    func enableCategory(_ category: ToolCategory) {
        for (id, tool) in registeredTools where tool.category == category {
            selectedTools[id] = tool
        }
    }
    
    func disableCategory(_ category: ToolCategory) {
        for (id, tool) in selectedTools where tool.category == category {
            selectedTools.removeValue(forKey: id)
        }
    }
    
    func toolsByCategory() -> [ToolCategory: [String]] {
        var result: [ToolCategory: [String]] = [:]
        for tool in registeredTools.values {
            var tools = result[tool.category] ?? []
            tools.append(tool.id)
            result[tool.category] = tools
        }
        return result
    }
}

/// Concrete implementation of ToolSpecManager
final class ToolSpecManagerImpl: ToolSpecManager, @unchecked Sendable {
    
    // MARK: - Singleton
    
    static let shared = ToolSpecManagerImpl()
    
    // MARK: - Private Properties
    
    private let actor = ToolSpecManagerActor()
    private var _cachedAvailableTools: [String: [String: ToolSpecValue]] = [:]
    private var _cachedMyTools: [[String: Any]] = []
    private var needsCache = true
    
    // MARK: - Initialization
    
    init() {
        Task {
            await registerDefaultTools()
        }
    }
    
    // MARK: - Default Tools Registration
    
    private func registerDefaultTools() async {
        // Utility Tools
        let dateTool = DateToolImpl()
        let processSearchTool = ProcessSearchResultsToolImpl()
        
        // Calendar Tool
        let calendarTool = CalendarToolImpl()
        
        // Reminder Tool
        let reminderTool = ReminderToolImpl()
        
        // Contact Tool
        let contactTool = ContactToolImpl()
        
        // Location Tool
        let locationTool = LocationToolImpl()
        
        // Music Tool
        let musicTool = MusicToolImpl()
        
        // Search Tool
        let searchTool = SearchToolImpl()
        
        // Query Refine Tool
        let queryRefineTool = QueryRefineToolImpl()
        
        // Register all tools
        let allTools: [any AssistantTool] = [
            dateTool,
            processSearchTool,
            calendarTool,
            reminderTool,
            contactTool,
            locationTool,
            musicTool,
            searchTool,
            queryRefineTool
        ]
        
        for tool in allTools {
            await actor.register(tool)
        }
        
        // Enable default tools (date and search)
        await actor.select(dateTool)
        await actor.select(searchTool)
        await actor.select(queryRefineTool)
        
        needsCache = true
    }
    
    // MARK: - ToolSpecManager Protocol
    
    var registeredTools: [String: any AssistantTool] {
        get async {
            await actor.getRegisteredTools()
        }
    }
    
    var selectedTools: [String: any AssistantTool] {
        get async {
            await actor.getSelectedTools()
        }
    }
    
    var toolSpecifications: [[String: Any]] {
        get async {
            let selected = await actor.getSelectedTools()
            return selected.values.map { $0.specification.toDictionary() }
        }
    }
    
    // MARK: - Backward Compatibility (Synchronous)
    
    var availableTools: [String: [String: ToolSpecValue]] {
        // Return cached value for synchronous access
        // This will be empty initially but populated after async init
        if needsCache {
            Task {
                await updateCache()
            }
        }
        return _cachedAvailableTools
    }
    
    var myTools: [[String: Any]] {
        // Return cached value for synchronous access
        if needsCache {
            Task {
                await updateCache()
            }
        }
        return _cachedMyTools
    }
    
    private func updateCache() async {
        let registered = await actor.getRegisteredTools()
        let selected = await actor.getSelectedTools()
        
        var newAvailable: [String: [String: ToolSpecValue]] = [:]
        for (id, tool) in registered {
            newAvailable[id] = specificationToToolSpecValue(tool.specification)
        }
        
        let newMyTools = selected.values.map { $0.specification.toDictionary() }
        
        _cachedAvailableTools = newAvailable
        _cachedMyTools = newMyTools
        needsCache = false
    }
    
    // MARK: - Tool Management
    
    func registerTool(_ tool: any AssistantTool) async {
        await actor.register(tool)
        needsCache = true
    }
    
    func unregisterTool(id: String) async {
        await actor.unregister(id: id)
        needsCache = true
    }
    
    func enableTool(id: String) async {
        await actor.enable(id: id)
        needsCache = true
    }
    
    func disableTool(id: String) async {
        await actor.disable(id: id)
        needsCache = true
    }
    
    func addTool(_ toolName: String) async {
        await enableTool(id: toolName)
    }
    
    func removeTool(_ toolName: String) async {
        await disableTool(id: toolName)
    }
    
    func tools(in category: ToolCategory) async -> [any AssistantTool] {
        await actor.toolsIn(category: category)
    }
    
    // MARK: - Tool Execution
    
    func executeToolFunction(name: String, parameters: [String: Any]) async -> ToolFunctionResult {
        guard let tool = await actor.getTool(id: name) else {
            return .failure(error: "Unknown tool function: \(name)")
        }
        
        do {
            return try await tool.execute(parameters: parameters)
        } catch let error as ToolError {
            return .failure(error: error.localizedDescription)
        } catch {
            return .failure(error: "Tool execution failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Pretty Print
    
    func prettyPrint(_ value: Any) -> String {
        prettyPrint(value, indentLevel: 0)
    }
    
    func prettyPrint(_ value: Any, indentLevel: Int = 0) -> String {
        let indent = String(repeating: "  ", count: indentLevel)
        var output = ""
        
        switch value {
        case let dict as [String: Any]:
            for (key, val) in dict {
                output += "\(indent)- \(key):\n"
                output += prettyPrint(val, indentLevel: indentLevel + 1)
            }
        case let array as [Any]:
            for item in array {
                output += prettyPrint(item, indentLevel: indentLevel + 1)
            }
        default:
            output += "\(indent)  \(value)\n"
        }
        
        return output
    }
    
    // MARK: - Private Helpers
    
    private func specificationToToolSpecValue(_ spec: ToolSpecification) -> [String: ToolSpecValue] {
        [
            "type": .string("function"),
            "function": .object([
                "name": .string(spec.name),
                "description": .string(spec.description),
                "parameters": parametersToToolSpecValue(spec.parameters)
            ])
        ]
    }
    
    private func parametersToToolSpecValue(_ params: ToolParameters) -> ToolSpecValue {
        var properties: [String: ToolSpecValue] = [:]
        
        for (key, prop) in params.properties {
            var propDict: [String: ToolSpecValue] = [
                "type": .string(prop.type),
                "description": .string(prop.description)
            ]
            
            if let enumValues = prop.enumValues {
                propDict["enum"] = .array(enumValues.map { .string($0) })
            }
            
            properties[key] = .object(propDict)
        }
        
        return .object([
            "type": .string(params.type),
            "properties": .object(properties),
            "required": .array(params.required.map { .string($0) })
        ])
    }
}

// MARK: - Tool Registry Extension

extension ToolSpecManagerImpl {
    /// Get all available tool IDs grouped by category
    func toolsByCategory() async -> [ToolCategory: [String]] {
        await actor.toolsByCategory()
    }
    
    /// Check if a tool is currently enabled
    func isToolEnabled(id: String) async -> Bool {
        await actor.isEnabled(id: id)
    }
    
    /// Get tool information for UI display
    func toolInfo(id: String) async -> (name: String, description: String, category: ToolCategory, isEnabled: Bool)? {
        guard let tool = await actor.getTool(id: id) else { return nil }
        let isEnabled = await actor.isEnabled(id: id)
        return (tool.name, tool.toolDescription, tool.category, isEnabled)
    }
    
    /// Enable all tools in a category
    func enableCategory(_ category: ToolCategory) async {
        await actor.enableCategory(category)
        needsCache = true
    }
    
    /// Disable all tools in a category
    func disableCategory(_ category: ToolCategory) async {
        await actor.disableCategory(category)
        needsCache = true
    }
}
