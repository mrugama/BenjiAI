import SwiftUI

// MARK: - Query Refine View

struct QueryRefineView: View {
    let data: [String: any Sendable]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.purple)
                Text("Query Refined")
                    .font(.headline)
                    .fontWeight(.semibold)
            }

            if let original = data["originalQuery"] as? String {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Original:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(original)
                        .font(.subheadline)
                        .strikethrough()
                        .foregroundColor(.secondary)
                }
            }

            if let refined = data["refinedQuery"] as? String {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Refined:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(refined)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.purple)
                }
            }

            if let improvements = data["improvements"] as? [String] {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Improvements:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    ForEach(improvements, id: \.self) { improvement in
                        Label(improvement, systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
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
