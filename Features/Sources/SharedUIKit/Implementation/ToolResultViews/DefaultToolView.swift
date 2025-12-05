import SwiftUI

// MARK: - Default Tool View

struct DefaultToolView: View {
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
