import SwiftUI

struct SearchResultCard: View {
    let result: [String: String]
    let index: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(index)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(width: 20, height: 20)
                    .background(Circle().fill(Color.blue))

                if let title = result["title"] {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                }
            }

            if let snippet = result["snippet"] {
                Text(snippet)
                    .font(.body)
                    .foregroundStyle(.secondary)
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
                    .foregroundStyle(.blue)
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
