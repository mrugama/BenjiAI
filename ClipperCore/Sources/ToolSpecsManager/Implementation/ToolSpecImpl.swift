import Foundation

final class ToolSpecManagerImpl: ToolSpecManager, @unchecked Sendable {
    
    private var tools: [[String: ToolSpecValue]] = [
        [
            "type": .string("function"),
            "function": .object([
                "name": .string("getTodayDate"),
                "description": .string("Get the current date and time"),
                "parameters": .object([
                    "type": .string("object"),
                    "properties": .object([:]),
                    "required": .array([]),
                ])
            ])
        ],
        [
            "type": .string("function"),
            "function": .object([
                "name": .string("searchDuckduckgo"),
                "description": .string("Search DuckDuckGo for information on a topic"),
                "parameters": .object([
                    "type": .string("object"),
                    "properties": .object([
                        "query": .object([
                            "type": .string("string"),
                            "description": .string("The search query to look up")
                        ])
                    ]),
                    "required": .array([.string("query")])
                ])
            ])
        ]
    ]
    var selectedTools: [[String: ToolSpecValue]] = [
        [
            "type": .string("function"),
            "function": .object([
                "name": .string("getTodayDate"),
                "description": .string("Get the current date and time"),
                "parameters": .object([
                    "type": .string("object"),
                    "properties": .object([:]),
                    "required": .array([]),
                ])
            ])
        ],
        [
            "type": .string("function"),
            "function": .object([
                "name": .string("searchDuckduckgo"),
                "description": .string("Search DuckDuckGo for information on a topic"),
                "parameters": .object([
                    "type": .string("object"),
                    "properties": .object([
                        "query": .object([
                            "type": .string("string"),
                            "description": .string("The search query to look up")
                        ])
                    ]),
                    "required": .array([.string("query")])
                ])
            ])
        ]
    ]
    
    private func toolSpecValueToAny(_ value: ToolSpecValue) -> Any {
        switch value {
        case .string(let str):
            return str
        case .object(let dict):
            return dict.mapValues { toolSpecValueToAny($0) }
        case .array(let arr):
            return arr.map { toolSpecValueToAny($0) }
        default:
            return "null"
        }
    }
    
    var availableTools: [String: [String: ToolSpecValue]] {
        Dictionary(uniqueKeysWithValues: tools.compactMap { tool in
            guard case let .object(function)? = tool["function"],
                  case let .string(name)? = function["name"] else {
                return nil
            }
            return (name, tool)
        })
    }
    
    var myTools: [[String: Any]] {
        return selectedTools.map { tool in
            return tool.mapValues { toolSpecValueToAny($0) }
        }
    }
    
    func addTool(_ toolName: String) async {
        guard let tool = availableTools[toolName] else { return }
        selectedTools.append(tool)
    }
    
    func removeTool(_ toolName: String) async {
        selectedTools.removeAll { tool in
            guard case let .object(function)? = tool["function"],
                  case let .string(name)? = function["name"] else {
                return false
            }
            return name == toolName
        }
    }
    
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
}
