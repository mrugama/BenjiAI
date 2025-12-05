import SwiftUI

// MARK: - Search Results View

struct SearchResultsView: View {
    let data: [String: any Sendable]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
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

            if let results = data["results"] as? [[String: String]] {
                LazyVStack(spacing: 12) {
                    ForEach(Array(results.enumerated()), id: \.offset) { index, result in
                        SearchResultCard(result: result, index: index + 1)
                    }
                }
            }

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
