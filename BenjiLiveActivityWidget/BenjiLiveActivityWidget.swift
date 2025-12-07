import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Live Activity Attributes

struct LLMLiveActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var progress: Double
        var llmName: String
    }
}

// MARK: - Severance Colors

private extension Color {
    static let severanceBackground = Color(red: 10/255, green: 14/255, blue: 20/255)
    static let severanceGreen = Color(red: 0, green: 1, blue: 156/255)
    static let severanceCard = Color(red: 17/255, green: 24/255, blue: 32/255)
    static let severanceBorder = Color(red: 31/255, green: 41/255, blue: 55/255)
    static let severanceText = Color(red: 232/255, green: 232/255, blue: 232/255)
    static let severanceMuted = Color(red: 107/255, green: 114/255, blue: 128/255)
    static let severanceTeal = Color(red: 26/255, green: 58/255, blue: 58/255)
}

// MARK: - Live Activity Widget

struct BenjiLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LLMLiveActivityAttributes.self) { context in
            SurrealLockScreenView(
                llmName: context.state.llmName,
                progress: context.state.progress
            )
            .activityBackgroundTint(.clear)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(Int(context.state.progress * 100))%")
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color.severanceGreen)
                            .shadow(color: .severanceGreen.opacity(0.8), radius: 4)
                        
                        Text("Syncing")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(Color.severanceMuted)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(context.state.llmName.components(separatedBy: "/").last ?? context.state.llmName)
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .foregroundStyle(Color.severanceText)
                            .lineLimit(1)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    SurrealProgressBar(progress: context.state.progress)
                        .frame(height: 24)
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

// MARK: - Surreal Lock Screen View

struct SurrealLockScreenView: View {
    let llmName: String
    let progress: Double

    var body: some View {
        ZStack {
            // Animated gradient background
            SurrealBackground()
            
            // Matrix-style number overlay
            Canvas { context, size in
                let numberCount = 12
                for i in 0..<numberCount {
                    let xPos = CGFloat(i) * (size.width / CGFloat(numberCount))
                    let randomNumber = String(Int.random(in: 0...9))
                    let opacity = Double.random(in: 0.1...0.3)
                    
                    context.opacity = opacity
                    context.draw(
                        Text(randomNumber)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(Color.severanceGreen),
                        at: CGPoint(x: xPos, y: 8)
                    )
                }
            }
            .frame(height: 20)
            
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    // Glitched percentage
                    HStack(spacing: 2) {
                        Text("\(Int(progress * 100))")
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color.severanceGreen)
                            .shadow(color: .severanceGreen.opacity(0.8), radius: 4)
                        
                        Text("%")
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color.severanceGreen.opacity(0.7))
                            .offset(y: 2)
                    }
                    
                    Spacer()
                    
                    Text(llmName.components(separatedBy: "/").last ?? llmName)
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Color.severanceText)
                        .lineLimit(1)
                }
                
                // Surreal progress bar
                SurrealProgressBar(progress: progress)
                    .frame(height: 20)
            }
            .padding(16)
        }
    }
}

// MARK: - Surreal Progress Bar

struct SurrealProgressBar: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track with gradient
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.severanceTeal.opacity(0.3),
                                Color.severanceBorder.opacity(0.5)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                // Filled progress with animated gradient
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.severanceGreen,
                                Color.severanceGreen.opacity(0.7),
                                Color(red: 0, green: 0.9, blue: 0.8)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progress)
                    .shadow(color: .severanceGreen.opacity(0.6), radius: 4)
                
                // Random number overlay on progress bar
                Canvas { context, size in
                    let barWidth = size.width * progress
                    let numberCount = max(1, Int(barWidth / 15))
                    
                    for i in 0..<numberCount {
                        let xPos = CGFloat(i) * (barWidth / CGFloat(numberCount)) + 4
                        let randomNumber = String(Int.random(in: 0...1))
                        
                        context.opacity = 0.4
                        context.draw(
                            Text(randomNumber)
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundStyle(Color.severanceBackground),
                            at: CGPoint(x: xPos, y: size.height / 2)
                        )
                    }
                }
                .frame(width: geometry.size.width * progress)
            }
        }
    }
}

// MARK: - Surreal Background

struct SurrealBackground: View {
    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    Color.severanceBackground,
                    Color.severanceTeal.opacity(0.2),
                    Color.severanceBackground
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Scan line effect
            Canvas { context, size in
                for yPos in stride(from: 0, to: size.height, by: 4) {
                    let rect = CGRect(x: 0, y: yPos, width: size.width, height: 1)
                    context.opacity = 0.1
                    context.fill(Path(rect), with: .color(.black))
                }
            }
            
            // Glowing edge
            LinearGradient(
                colors: [
                    Color.severanceGreen.opacity(0.05),
                    Color.clear
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 40)
            .frame(maxHeight: .infinity, alignment: .top)
        }
    }
}

// MARK: - Preview

#Preview("Lock Screen", as: .content, using: LLMLiveActivityAttributes()) {
    BenjiLiveActivityWidget()
} contentStates: {
    LLMLiveActivityAttributes.ContentState(progress: 0.42, llmName: "Qwen2.5-1.5B")
    LLMLiveActivityAttributes.ContentState(progress: 0.75, llmName: "Llama-3.2-1B")
}
