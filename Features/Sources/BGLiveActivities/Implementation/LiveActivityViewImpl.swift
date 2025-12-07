import SwiftUI
import SharedUIKit

/// Internal Severance-themed Live Activity view showing model download progress.
struct LiveActivityViewImpl: View {
    let llmName: String
    let progress: Double

    var body: some View {
        HStack(spacing: 12) {
            // Percentage on the left
            VStack(alignment: .leading, spacing: 6) {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color.severanceGreen)

                ProgressView(value: progress)
                    .progressViewStyle(.linear)
                    .tint(Color.severanceGreen)
                    .scaleEffect(x: 1, y: 1.2, anchor: .center)
            }

            Spacer()

            // LLM name on the right
            VStack(alignment: .trailing, spacing: 4) {
                Text("Downloading")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(Color.severanceMuted)
                Text(llmName)
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color.severanceText)
                    .lineLimit(2)
                    .multilineTextAlignment(.trailing)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.severanceCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.severanceBorder, lineWidth: 1)
                )
        )
    }
}

#Preview("Live Activity") {
    LiveActivityViewImpl(llmName: "mlx-community/Qwen2.5-1.5B-Instruct-4bit", progress: 0.42)
        .padding()
        .background(Color.severanceBackground)
}
