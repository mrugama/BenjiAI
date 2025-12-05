import Foundation

// MARK: - Date Tool Implementation

final class DateToolImpl: AssistantTool, @unchecked Sendable {
    let id: String = "getTodayDate"
    let name: String = "Get Today's Date"
    let toolDescription: String = "Get the current date and time with a beautiful display"
    let category: ToolCategory = .utility
    
    var specification: ToolSpecification {
        ToolSpecification(
            name: "getTodayDate",
            description: "Get the current date and time with a beautiful display",
            parameters: ToolParameters(
                properties: [
                    "displayType": ToolParameterProperty(
                        type: "string",
                        description: "How to display the date - as a view or text",
                        enumValues: ["view", "text"]
                    )
                ],
                required: []
            )
        )
    }
    
    func execute(parameters: [String: Any]) async throws -> ToolFunctionResult {
        let displayType = parameters["displayType"] as? String ?? "view"
        return await getDate(displayType: displayType)
    }
    
    private func getDate(displayType: String) async -> ToolFunctionResult {
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
            
            return .success(viewData: viewData)
        } else {
            return .success(text: "Today is \(dateString)")
        }
    }
}

// MARK: - Process Search Results Tool Implementation

final class ProcessSearchResultsToolImpl: AssistantTool, @unchecked Sendable {
    let id: String = "processSearchResults"
    let name: String = "Process Search Results"
    let toolDescription: String = "Process and format search results for better presentation"
    let category: ToolCategory = .utility
    
    var specification: ToolSpecification {
        ToolSpecification(
            name: "processSearchResults",
            description: "Process and format search results for better presentation",
            parameters: ToolParameters(
                properties: [
                    "searchData": ToolParameterProperty(
                        type: "object",
                        description: "The search results data to process"
                    ),
                    "presentationType": ToolParameterProperty(
                        type: "string",
                        description: "How to present the processed results",
                        enumValues: ["summary", "webview", "formatted"]
                    )
                ],
                required: ["searchData"]
            )
        )
    }
    
    func execute(parameters: [String: Any]) async throws -> ToolFunctionResult {
        guard let searchData = parameters["searchData"] as? [String: Any] else {
            throw ToolError.missingParameter("searchData")
        }
        let presentationType = parameters["presentationType"] as? String ?? "summary"
        return await processResults(searchData: searchData, presentationType: presentationType)
    }
    
    private func processResults(searchData: [String: Any], presentationType: String) async -> ToolFunctionResult {
        guard let results = searchData["results"] as? [[String: String]],
              let query = searchData["query"] as? String else {
            return .failure(error: "Invalid search data format")
        }
        
        switch presentationType {
        case "summary":
            let summaryText = createSummary(from: results, query: query)
            return .success(text: summaryText)
            
        case "webview":
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
                return .failure(error: "No valid URL found in search results")
            }
            
        case "formatted":
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
            return .success(viewData: viewData)
            
        default:
            return .failure(error: "Unknown presentation type: \(presentationType)")
        }
    }
    
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
            formatted["formattedSnippet"] = String((result["snippet"] ?? "").prefix(150)) + "..."
            return formatted
        }
    }
}

