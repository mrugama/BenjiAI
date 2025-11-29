import SwiftUI
import ToolSpecsManager

// MARK: - Tool Result View Renderer

public struct ToolResultView: View {
    let viewData: ToolViewData
    
    public init(viewData: ToolViewData) {
        self.viewData = viewData
    }
    
    public var body: some View {
        switch viewData.template {
        case "date_display":
            DateDisplayView(data: viewData.data)
        case "search_results_display":
            SearchResultsView(data: viewData.data)
        default:
            DefaultToolView(data: viewData.data, type: viewData.type)
        }
    }
}

// MARK: - Date Display View

private struct DateDisplayView: View {
    let data: [String: any Sendable]
    
    var body: some View {
        VStack(spacing: 16) {
            // Day display
            if let day = data["day"] as? Int,
               let dayName = data["dayName"] as? String {
                VStack(spacing: 4) {
                    Text("\(day)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(dayName)
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.blue.opacity(0.1))
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )
            }
            
            // Time and date info
            VStack(spacing: 8) {
                if let time = data["time"] as? String {
                    Text(time)
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                
                if let fullDate = data["fullDate"] as? String {
                    Text(fullDate)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 4)
        )
    }
}

// MARK: - Search Results View

private struct SearchResultsView: View {
    let data: [String: any Sendable]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            if let query = data["query"] as? String {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.blue)
                    Text("Search Results for: \(query)")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .padding(.bottom, 8)
            }
            
            // Results
            if let results = data["results"] as? [[String: String]] {
                LazyVStack(spacing: 12) {
                    ForEach(Array(results.enumerated()), id: \.offset) { index, result in
                        SearchResultCard(result: result, index: index + 1)
                    }
                }
            }
            
            // Result count
            if let count = data["resultCount"] as? Int {
                Text("\(count) result\(count == 1 ? "" : "s") found")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 4)
        )
    }
}

private struct SearchResultCard: View {
    let result: [String: String]
    let index: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(index)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 20, height: 20)
                    .background(Circle().fill(Color.blue))
                
                if let title = result["title"] {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                }
            }
            
            if let snippet = result["snippet"] {
                Text(snippet)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            if let urlString = result["url"],
               let url = URL(string: urlString) {
                Link(destination: url) {
                    HStack {
                        Image(systemName: "link")
                        Text(url.host ?? urlString)
                            .lineLimit(1)
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(0.05))
                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Default Tool View

private struct DefaultToolView: View {
    let data: [String: any Sendable]
    let type: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "wrench.and.screwdriver.fill")
                    .foregroundColor(.orange)
                Text("Tool Result: \(type)")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(data.keys.sorted()), id: \.self) { key in
                        HStack(alignment: .top) {
                            Text("\(key):")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                                .frame(minWidth: 80, alignment: .leading)
                            if let value = data[key] as? String {
                                Text("\(value)")
                                    .font(.caption)
                                    .foregroundColor(.primary)
                                    .textSelection(.enabled)
                            }
                            
                            Spacer()
                        }
                    }
                }
            }
            .frame(maxHeight: 200)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 4)
        )
    }
}

// MARK: - Usage Examples

#if DEBUG
struct ToolResultView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Date view example
            ToolResultView(viewData: ToolViewData(
                type: "date",
                data: [
                    "fullDate": "Monday, December 16, 2024 at 2:30 PM",
                    "time": "2:30 PM",
                    "dayName": "Monday",
                    "day": 16,
                    "month": 12,
                    "year": 2024
                ],
                template: "date_display"
            ))
            
            // Search results view example
            ToolResultView(viewData: ToolViewData(
                type: "search_results",
                data: [
                    "query": "current president United States",
                    "results": [
                        [
                            "title": "Joe Biden - President of the United States",
                            "snippet": "Joe Biden is the 46th and current president of the United States...",
                            "url": "https://en.wikipedia.org/wiki/Joe_Biden"
                        ]
                    ],
                    "resultCount": 1
                ],
                template: "search_results_display"
            ))
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif
