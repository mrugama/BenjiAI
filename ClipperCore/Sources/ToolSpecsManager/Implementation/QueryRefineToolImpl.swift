import Foundation

// MARK: - Query Refine Tool Implementation

/// Tool that refines user search queries to get better results
/// This tool uses heuristics and patterns to improve search queries
/// before they are passed to the search tool
final class QueryRefineToolImpl: QueryRefineTool, @unchecked Sendable {
    let id: String = "queryRefine"
    let name: String = "Query Refine"
    let toolDescription: String = "AI improves user search queries to get better results"
    let category: ToolCategory = .queryRefine
    
    var specification: ToolSpecification {
        ToolSpecification(
            name: "refineSearchQuery",
            description: "Refine and improve a user's search query to get better search results. Use this before performing a search to optimize the query.",
            parameters: ToolParameters(
                properties: [
                    "originalQuery": ToolParameterProperty(
                        type: "string",
                        description: "The original search query from the user"
                    ),
                    "context": ToolParameterProperty(
                        type: "string",
                        description: "Optional context about what the user is looking for"
                    )
                ],
                required: ["originalQuery"]
            )
        )
    }
    
    func execute(parameters: [String: Any]) async throws -> ToolFunctionResult {
        guard let originalQuery = parameters["originalQuery"] as? String else {
            throw ToolError.missingParameter("originalQuery")
        }
        let context = parameters["context"] as? String
        return try await refineQuery(originalQuery: originalQuery, context: context)
    }
    
    func refineQuery(originalQuery: String, context: String?) async throws -> ToolFunctionResult {
        let refinedQuery = refineQueryInternal(original: originalQuery, context: context)
        let suggestions = generateSearchSuggestions(query: originalQuery)
        
        // Return the refined query for chaining to search
        return ToolFunctionResult(
            success: true,
            resultType: .chainedData([
                "refinedQuery": refinedQuery.query,
                "originalQuery": originalQuery,
                "improvements": refinedQuery.improvements,
                "suggestions": suggestions
            ] as [String: any Sendable]),
            shouldChain: true,
            suggestedNextTool: "searchDuckduckgo",
            metadata: [
                "originalQuery": originalQuery,
                "refinedQuery": refinedQuery.query,
                "improvements": refinedQuery.improvements,
                "suggestions": suggestions
            ]
        )
    }
    
    // MARK: - Private Helpers
    
    private struct RefinedQuery {
        let query: String
        let improvements: [String]
    }
    
    private func refineQueryInternal(original: String, context: String?) -> RefinedQuery {
        var query = original.trimmingCharacters(in: .whitespacesAndNewlines)
        var improvements: [String] = []
        
        // 1. Remove unnecessary words (stop words for search)
        let stopWords = ["please", "can you", "could you", "would you", "i want to", "i need to",
                         "help me", "tell me", "show me", "find me", "what is", "who is",
                         "where is", "how do i", "i want", "i need", "like to know"]
        
        for stopWord in stopWords {
            if query.lowercased().contains(stopWord) {
                query = query.replacingOccurrences(of: stopWord, with: "", options: .caseInsensitive)
                improvements.append("Removed conversational phrase: '\(stopWord)'")
            }
        }
        
        // 2. Clean up whitespace
        query = query.replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
        query = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 3. Remove question marks and common punctuation
        if query.hasSuffix("?") || query.hasSuffix("!") {
            query = String(query.dropLast())
            improvements.append("Removed ending punctuation")
        }
        
        // 4. Handle common question patterns
        let questionPatterns: [(pattern: String, replacement: String)] = [
            ("^what are ", ""),
            ("^what is the ", ""),
            ("^what is ", ""),
            ("^how to ", ""),
            ("^how do i ", ""),
            ("^why does ", ""),
            ("^why is ", ""),
            ("^when did ", ""),
            ("^when is ", ""),
            ("^where can i ", ""),
            ("^where is ", ""),
            ("^who is the ", ""),
            ("^who is ", ""),
            ("^can i ", ""),
            ("^should i ", "")
        ]
        
        for (pattern, replacement) in questionPatterns {
            if let range = query.range(of: pattern, options: [.regularExpression, .caseInsensitive]) {
                query = query.replacingCharacters(in: range, with: replacement)
                improvements.append("Simplified question format")
                break
            }
        }
        
        // 5. Add context-specific keywords
        if let context = context?.lowercased() {
            if context.contains("recent") || context.contains("latest") || context.contains("new") {
                if !query.lowercased().contains("2024") && !query.lowercased().contains("2025") {
                    query += " 2024"
                    improvements.append("Added year for recency")
                }
            }
            
            if context.contains("tutorial") || context.contains("learn") || context.contains("how") {
                if !query.lowercased().contains("tutorial") && !query.lowercased().contains("guide") {
                    query += " tutorial"
                    improvements.append("Added tutorial keyword")
                }
            }
            
            if context.contains("review") || context.contains("opinion") {
                if !query.lowercased().contains("review") {
                    query += " review"
                    improvements.append("Added review keyword")
                }
            }
        }
        
        // 6. Handle specific query types
        query = handleSpecificQueryTypes(query: query, improvements: &improvements)
        
        // 7. Ensure query isn't too short
        if query.split(separator: " ").count < 2 && original.split(separator: " ").count > 2 {
            // If refinement made it too short, keep original but clean
            query = original.trimmingCharacters(in: .whitespacesAndNewlines)
            improvements = ["Kept original query (too much reduction)"]
        }
        
        // Final cleanup
        query = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if improvements.isEmpty {
            improvements.append("Query was already well-formed")
        }
        
        return RefinedQuery(query: query, improvements: improvements)
    }
    
    private func handleSpecificQueryTypes(query: String, improvements: inout [String]) -> String {
        var refinedQuery = query
        let lowercased = query.lowercased()
        
        // Programming queries
        let programmingKeywords = ["code", "programming", "function", "error", "bug", "api", "library"]
        if programmingKeywords.contains(where: { lowercased.contains($0) }) {
            if !lowercased.contains("example") && !lowercased.contains("documentation") {
                refinedQuery += " example"
                improvements.append("Added 'example' for programming query")
            }
        }
        
        // Recipe queries
        if lowercased.contains("recipe") || lowercased.contains("cook") || lowercased.contains("make") {
            if lowercased.contains("make") && !lowercased.contains("recipe") {
                refinedQuery += " recipe"
                improvements.append("Added 'recipe' keyword")
            }
        }
        
        // Definition queries
        if lowercased.hasPrefix("define ") || lowercased.hasPrefix("meaning of ") {
            refinedQuery = refinedQuery.replacingOccurrences(of: "define ", with: "", options: .caseInsensitive)
            refinedQuery = refinedQuery.replacingOccurrences(of: "meaning of ", with: "", options: .caseInsensitive)
            refinedQuery += " definition"
            improvements.append("Reformatted for definition search")
        }
        
        // Comparison queries
        if lowercased.contains(" vs ") || lowercased.contains(" versus ") || lowercased.contains(" or ") {
            if !lowercased.contains("comparison") && !lowercased.contains("difference") {
                refinedQuery += " comparison"
                improvements.append("Added 'comparison' for vs query")
            }
        }
        
        return refinedQuery
    }
    
    private func generateSearchSuggestions(query: String) -> [String] {
        var suggestions: [String] = []
        let lowercased = query.lowercased()
        
        // Generate alternative queries
        suggestions.append(query + " 2024")
        suggestions.append(query + " guide")
        suggestions.append(query + " explained")
        
        // Topic-specific suggestions
        if lowercased.contains("swift") || lowercased.contains("ios") || lowercased.contains("xcode") {
            suggestions.append(query + " Apple documentation")
            suggestions.append(query + " WWDC")
        }
        
        if lowercased.contains("python") || lowercased.contains("javascript") || lowercased.contains("programming") {
            suggestions.append(query + " Stack Overflow")
            suggestions.append(query + " GitHub")
        }
        
        // Return unique suggestions
        return Array(Set(suggestions)).prefix(5).map { $0 }
    }
}

