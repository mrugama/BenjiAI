import Foundation

// MARK: - Search Tool Implementation (DuckDuckGo)

final class SearchToolImpl: SearchTool, @unchecked Sendable {
    let id: String = "search"
    let name: String = "Search"
    let toolDescription: String = "Search DuckDuckGo for information on a topic"
    let category: ToolCategory = .search
    
    private let session: URLSession
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
    }
    
    var specification: ToolSpecification {
        ToolSpecification(
            name: "searchDuckduckgo",
            description: "Search DuckDuckGo for information on a topic. Returns relevant web results.",
            parameters: ToolParameters(
                properties: [
                    "query": ToolParameterProperty(
                        type: "string",
                        description: "The search query to look up"
                    )
                ],
                required: ["query"]
            )
        )
    }
    
    func execute(parameters: [String: Any]) async throws -> ToolFunctionResult {
        guard let query = parameters["query"] as? String else {
            throw ToolError.missingParameter("query")
        }
        return try await search(query: query)
    }
    
    func search(query: String) async throws -> ToolFunctionResult {
        // Use DuckDuckGo Instant Answer API
        guard var urlComponents = URLComponents(string: "https://api.duckduckgo.com/") else {
            return .failure(error: "Invalid URL")
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "no_html", value: "1"),
            URLQueryItem(name: "skip_disambig", value: "1")
        ]
        
        guard let url = urlComponents.url else {
            return .failure(error: "Failed to construct search URL")
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                return .failure(error: "Search request failed")
            }
            
            // Parse DuckDuckGo response
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                return .failure(error: "Failed to parse search response")
            }
            
            var results: [[String: any Sendable]] = []
            
            // Abstract (main answer)
            if let abstract = json["Abstract"] as? String, !abstract.isEmpty {
                results.append([
                    "title": json["Heading"] as? String ?? "Answer",
                    "snippet": abstract,
                    "url": json["AbstractURL"] as? String ?? "",
                    "source": json["AbstractSource"] as? String ?? "DuckDuckGo"
                ])
            }
            
            // Related topics
            if let relatedTopics = json["RelatedTopics"] as? [[String: Any]] {
                for topic in relatedTopics.prefix(5) {
                    if let text = topic["Text"] as? String,
                       let firstURL = topic["FirstURL"] as? String {
                        let title = extractTitle(from: text)
                        results.append([
                            "title": title,
                            "snippet": text,
                            "url": firstURL,
                            "source": "DuckDuckGo"
                        ])
                    }
                }
            }
            
            // If no results from API, create a web search URL
            if results.isEmpty {
                let webSearchURL = "https://duckduckgo.com/?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query)"
                results.append([
                    "title": "Web Search: \(query)",
                    "snippet": "Click to search for '\(query)' on DuckDuckGo",
                    "url": webSearchURL,
                    "source": "DuckDuckGo Web Search"
                ])
            }
            
            let viewData = ToolViewData(
                type: "search_results",
                data: [
                    "query": query,
                    "results": results,
                    "resultCount": results.count,
                    "searchEngine": "DuckDuckGo"
                ],
                template: "search_results_display"
            )
            
            return ToolFunctionResult(
                success: true,
                resultType: .richView(viewData),
                shouldChain: false,
                metadata: [
                    "originalQuery": query,
                    "searchEngine": "DuckDuckGo",
                    "resultCount": results.count
                ]
            )
        } catch {
            return .failure(error: "Search failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private Helpers
    
    private func extractTitle(from text: String) -> String {
        // Extract first sentence or first 50 chars as title
        if let dotIndex = text.firstIndex(of: ".") {
            let title = String(text[..<dotIndex])
            if title.count < 100 {
                return title
            }
        }
        if text.count > 50 {
            return String(text.prefix(50)) + "..."
        }
        return text
    }
}

// MARK: - HTML Search Implementation (Fallback)

extension SearchToolImpl {
    /// Alternative search using HTML scraping (fallback if API doesn't return good results)
    func searchHTML(query: String) async throws -> ToolFunctionResult {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://html.duckduckgo.com/html/?q=\(encodedQuery)") else {
            return .failure(error: "Invalid search query")
        }
        
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36", forHTTPHeaderField: "User-Agent")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  let html = String(data: data, encoding: .utf8) else {
                return .failure(error: "Search request failed")
            }
            
            let results = parseHTMLResults(html: html)
            
            let viewData = ToolViewData(
                type: "search_results",
                data: [
                    "query": query,
                    "results": results,
                    "resultCount": results.count,
                    "searchEngine": "DuckDuckGo"
                ],
                template: "search_results_display"
            )
            
            return .success(viewData: viewData, metadata: ["originalQuery": query])
        } catch {
            return .failure(error: "Search failed: \(error.localizedDescription)")
        }
    }
    
    private func parseHTMLResults(html: String) -> [[String: any Sendable]] {
        var results: [[String: any Sendable]] = []
        
        // Simple regex-based parsing for DuckDuckGo HTML results
        let titlePattern = #"<a[^>]*class="result__a"[^>]*>([^<]+)</a>"#
        let snippetPattern = #"<a[^>]*class="result__snippet"[^>]*>([^<]+)</a>"#
        let urlPattern = #"<a[^>]*class="result__a"[^>]*href="([^"]+)"[^>]*>"#
        
        let titles = matches(for: titlePattern, in: html)
        let snippets = matches(for: snippetPattern, in: html)
        let urls = matches(for: urlPattern, in: html)
        
        for i in 0..<min(titles.count, snippets.count, urls.count, 10) {
            results.append([
                "title": cleanHTML(titles[i]),
                "snippet": cleanHTML(snippets[i]),
                "url": urls[i],
                "source": "DuckDuckGo"
            ])
        }
        
        return results
    }
    
    private func matches(for pattern: String, in text: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return []
        }
        let nsText = text as NSString
        let results = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsText.length))
        return results.compactMap { result in
            if result.numberOfRanges > 1 {
                return nsText.substring(with: result.range(at: 1))
            }
            return nil
        }
    }
    
    private func cleanHTML(_ text: String) -> String {
        var cleaned = text
        // Remove HTML tags
        cleaned = cleaned.replacingOccurrences(of: #"<[^>]+>"#, with: "", options: .regularExpression)
        // Decode HTML entities
        cleaned = cleaned.replacingOccurrences(of: "&amp;", with: "&")
        cleaned = cleaned.replacingOccurrences(of: "&lt;", with: "<")
        cleaned = cleaned.replacingOccurrences(of: "&gt;", with: ">")
        cleaned = cleaned.replacingOccurrences(of: "&quot;", with: "\"")
        cleaned = cleaned.replacingOccurrences(of: "&#39;", with: "'")
        cleaned = cleaned.replacingOccurrences(of: "&nbsp;", with: " ")
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

