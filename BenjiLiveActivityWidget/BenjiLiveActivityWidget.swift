import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Live Activity Attributes (must match BGLiveActivities module)

struct LLMLiveActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var progress: Double
        var llmName: String
    }
}

// MARK: - Severance Colors for Widget

private extension Color {
    static let severanceBackground = Color(red: 10/255, green: 14/255, blue: 20/255)
    static let severanceGreen = Color(red: 0, green: 1, blue: 156/255)
    static let severanceCard = Color(red: 17/255, green: 24/255, blue: 32/255)
    static let severanceBorder = Color(red: 31/255, green: 41/255, blue: 55/255)
    static let severanceText = Color(red: 232/255, green: 232/255, blue: 232/255)
    static let severanceMuted = Color(red: 107/255, green: 114/255, blue: 128/255)
}

// MARK: - Live Activity Widget

struct BenjiLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LLMLiveActivityAttributes.self) { context in
            // Lock Screen / Banner UI
            LockScreenLiveActivityView(
                llmName: context.state.llmName,
                progress: context.state.progress
            )
            .activityBackgroundTint(Color.severanceCard)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text("\(Int(context.state.progress * 100))%")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.severanceGreen)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Downloading")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(Color.severanceMuted)
                        Text(context.state.llmName.components(separatedBy: "/").last ?? context.state.llmName)
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .foregroundStyle(Color.severanceText)
                            .lineLimit(1)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ProgressView(value: context.state.progress)
                        .progressViewStyle(.linear)
                        .tint(Color.severanceGreen)
                        .padding(.horizontal, 8)
                }
            } compactLeading: {
                Text("\(Int(context.state.progress * 100))%")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color.severanceGreen)
            } compactTrailing: {
                Image(systemName: "arrow.down.circle.fill")
                    .foregroundStyle(Color.severanceGreen)
            } minimal: {
                Image(systemName: "arrow.down.circle.fill")
                    .foregroundStyle(Color.severanceGreen)
            }
        }
    }
}

// MARK: - Lock Screen View

struct LockScreenLiveActivityView: View {
    let llmName: String
    let progress: Double

    var body: some View {
        HStack(spacing: 12) {
            // Percentage on the left
            VStack(alignment: .leading, spacing: 6) {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color.severanceGreen)

                ProgressView(value: progress)
                    .progressViewStyle(.linear)
                    .tint(Color.severanceGreen)
            }

            Spacer()

            // LLM name on the right
            VStack(alignment: .trailing, spacing: 4) {
                Text("Downloading")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(Color.severanceMuted)
                Text(llmName.components(separatedBy: "/").last ?? llmName)
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color.severanceText)
                    .lineLimit(2)
                    .multilineTextAlignment(.trailing)
            }
        }
        .padding(16)
    }
}

// MARK: - Preview

#Preview("Lock Screen", as: .content, using: LLMLiveActivityAttributes()) {
    BenjiLiveActivityWidget()
} contentStates: {
    LLMLiveActivityAttributes.ContentState(progress: 0.42, llmName: "mlx-community/Qwen2.5-1.5B-Instruct-4bit")
    LLMLiveActivityAttributes.ContentState(progress: 0.85, llmName: "mlx-community/Llama-3.2-1B-Instruct-4bit")
}
