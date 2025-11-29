import Foundation

final class ToolSpecManagerImpl: ToolSpecManager, @unchecked Sendable {
    
    private var tools: [[String: ToolSpecValue]] = [
        [
            "type": .string("function"),
            "function": .object([
                "name": .string("getTodayDate"),
                "description": .string("Get the current date and time with a beautiful display"),
                "parameters": .object([
                    "type": .string("object"),
                    "properties": .object([
                        "displayType": .object([
                            "type": .string("string"),
                            "enum": .array([.string("view"), .string("text")]),
                            "description": .string("How to display the date - as a view or text")
                        ])
                    ]),
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
        ],
        [
            "type": .string("function"),
            "function": .object([
                "name": .string("processSearchResults"),
                "description": .string("Process and format search results for better presentation"),
                "parameters": .object([
                    "type": .string("object"),
                    "properties": .object([
                        "searchData": .object([
                            "type": .string("object"),
                            "description": .string("The search results data to process")
                        ]),
                        "presentationType": .object([
                            "type": .string("string"),
                            "enum": .array([.string("summary"), .string("webview"), .string("formatted")]),
                            "description": .string("How to present the processed results")
                        ])
                    ]),
                    "required": .array([.string("searchData")])
                ])
            ])
        ]
    ]
    var selectedTools: [[String: ToolSpecValue]] = [
        [
            "type": .string("function"),
            "function": .object([
                "name": .string("getTodayDate"),
                "description": .string("Get the current date and time with a beautiful display"),
                "parameters": .object([
                    "type": .string("object"),
                    "properties": .object([
                        "displayType": .object([
                            "type": .string("string"),
                            "enum": .array([.string("view"), .string("text")]),
                            "description": .string("How to display the date - as a view or text")
                        ])
                    ]),
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
        ],
        [
            "type": .string("function"),
            "function": .object([
                "name": .string("processSearchResults"),
                "description": .string("Process and format search results for better presentation"),
                "parameters": .object([
                    "type": .string("object"),
                    "properties": .object([
                        "searchData": .object([
                            "type": .string("object"),
                            "description": .string("The search results data to process")
                        ]),
                        "presentationType": .object([
                            "type": .string("string"),
                            "enum": .array([.string("summary"), .string("webview"), .string("formatted")]),
                            "description": .string("How to present the processed results")
                        ])
                    ]),
                    "required": .array([.string("searchData")])
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
    
    // MARK: - Tool Functions
    
    func getTodayDate(displayType: String = "view") async -> ToolFunctionResult {
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .medium
        let dateString = formatter.string(from: now)
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        let timeString = timeFormatter.string(from: now)
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEEE"
        let dayName = dayFormatter.string(from: now)
        
        if displayType == "view" {
            let viewData = ToolViewData(
                type: "date",
                data: [
                    "fullDate": dateString,
                    "time": timeString,
                    "dayName": dayName,
                    "timestamp": now.timeIntervalSince1970,
                    "day": Calendar.current.component(.day, from: now),
                    "month": Calendar.current.component(.month, from: now),
                    "year": Calendar.current.component(.year, from: now)
                ] as [String: any Sendable],
                template: "date_display"
            )
            
            return ToolFunctionResult(
                success: true,
                resultType: .richView(viewData)
            )
        } else {
            return ToolFunctionResult(
                success: true,
                resultType: .text("Today is \(dateString)")
            )
        }
    }
    
    func searchDuckduckgo(query: String) async -> ToolFunctionResult {
        // For now, this is a mock implementation
        // In a real implementation, you would make an HTTP request to DuckDuckGo's API
        
        // Simulate different types of search results based on query
        let mockResults: [String: any Sendable]
        
        if query.lowercased().contains("president") {
            mockResults = [
                "query": query,
                "results": [
                    [
                        "title": "Joe Biden - President of the United States",
                        "snippet": "Joe Biden is the 46th and current president of the United States. A member of the Democratic Party, he previously served as the 47th vice president from 2009 to 2017...",
                        "url": "https://en.wikipedia.org/wiki/Joe_Biden"
                    ] as [String: String],
                    [
                        "title": "White House Official Website",
                        "snippet": "The official website of the President of the United States. Learn about the current administration and government policies...",
                        "url": "https://www.whitehouse.gov"
                    ] as [String: String]
                ] as [[String: String]],
                "resultCount": 2,
                "searchType": "general"
            ]
        } else {
            mockResults = [
                "query": query,
                "results": [
                    [
                        "title": "Search result for \(query)",
                        "snippet": "This is a mock search result for your query: \(query). Here's some relevant information about the topic.",
                        "url": "https://example.com/search/\(query.replacingOccurrences(of: " ", with: "-"))"
                    ] as [String: String]
                ] as [[String: String]],
                "resultCount": 1,
                "searchType": "general"
            ]
        }
        
        return ToolFunctionResult(
            success: true,
            resultType: .chainedData(mockResults),
            shouldChain: true,
            suggestedNextTool: "processSearchResults",
            metadata: [
                "originalQuery": query,
                "searchEngine": "DuckDuckGo"
            ]
        )
    }
    
    func processSearchResults(searchData: [String: Any], presentationType: String = "summary") async -> ToolFunctionResult {
        guard let results = searchData["results"] as? [[String: String]],
              let query = searchData["query"] as? String else {
            return ToolFunctionResult(
                success: false,
                resultType: .text("Invalid search data format"),
                error: "Could not parse search results"
            )
        }
        
        switch presentationType {
        case "summary":
            // Create an AI-processed summary
            let summaryText = createSummary(from: results, query: query)
            return ToolFunctionResult(
                success: true,
                resultType: .text(summaryText)
            )
            
        case "webview":
            // Return the first URL for web viewing
            if let firstResult = results.first,
               let urlString = firstResult["url"],
               let url = URL(string: urlString) {
                return ToolFunctionResult(
                    success: true,
                    resultType: .webContent(url),
                    metadata: [
                        "title": firstResult["title"] ?? "Web Content",
                        "snippet": firstResult["snippet"] ?? ""
                    ]
                )
            } else {
                return ToolFunctionResult(
                    success: false,
                    resultType: .text("No valid URL found in search results"),
                    error: "Invalid URL"
                )
            }
            
        case "formatted":
            // Create a rich formatted view
            let viewData = ToolViewData(
                type: "search_results",
                data: [
                    "query": query,
                    "results": results,
                    "resultCount": results.count,
                    "formattedResults": formatSearchResults(results)
                ] as [String: any Sendable],
                template: "search_results_display"
            )
            
            return ToolFunctionResult(
                success: true,
                resultType: .richView(viewData)
            )
            
        default:
            return ToolFunctionResult(
                success: false,
                resultType: .text("Unknown presentation type: \(presentationType)"),
                error: "Invalid presentation type"
            )
        }
    }
    
    // MARK: - Helper Functions
    
    private func createSummary(from results: [[String: String]], query: String) -> String {
        var summary = "## Search Results for '\(query)'\n\n"
        
        for (index, result) in results.enumerated() {
            let title = result["title"] ?? "Unknown Title"
            let snippet = result["snippet"] ?? "No description available"
            
            summary += "**\(index + 1). \(title)**\n"
            summary += "\(snippet)\n\n"
        }
        
        if results.count > 1 {
            summary += "\n*Based on \(results.count) search results*"
        }
        
        return summary
    }
    
    private func formatSearchResults(_ results: [[String: String]]) -> [[String: String]] {
        return results.map { result in
            var formatted = result
            // Add any formatting or processing here
            formatted["formattedSnippet"] = result["snippet"]?.prefix(150).appending("...") ?? ""
            return formatted
        }
    }
    
    // MARK: - Tool Execution
    
    func executeToolFunction(name: String, parameters: [String: Any]) async -> ToolFunctionResult {
        switch name {
        case "getTodayDate":
            let displayType = parameters["displayType"] as? String ?? "view"
            return await getTodayDate(displayType: displayType)
            
        case "searchDuckduckgo":
            guard let query = parameters["query"] as? String else {
                return ToolFunctionResult(
                    success: false,
                    resultType: .text("Missing required parameter 'query' for searchDuckduckgo"),
                    error: "Missing required parameter 'query'"
                )
            }
            return await searchDuckduckgo(query: query)
            
        case "processSearchResults":
            guard let searchData = parameters["searchData"] as? [String: Any] else {
                return ToolFunctionResult(
                    success: false,
                    resultType: .text("Missing required parameter 'searchData' for processSearchResults"),
                    error: "Missing required parameter 'searchData'"
                )
            }
            let presentationType = parameters["presentationType"] as? String ?? "summary"
            return await processSearchResults(searchData: searchData, presentationType: presentationType)
            
        default:
            return ToolFunctionResult(
                success: false,
                resultType: .text("Unknown tool function: \(name)"),
                error: "Unknown tool function: \(name)"
            )
        }
    }
}
