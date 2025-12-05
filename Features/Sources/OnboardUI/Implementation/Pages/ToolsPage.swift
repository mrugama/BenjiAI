import SwiftUI

struct ToolsPage: View {
    let onboardingService: OnboardingService
    @State private var showContent = false
    @State private var enabledTools: Set<String> = []

    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 12) {
                GlowingText(
                    text: "MAKE IT YOURS",
                    font: .system(size: 24, weight: .bold, design: .monospaced),
                    glowRadius: 6
                )

                Text("Choose which tools your AI can use")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(.severanceMuted)
            }
            .padding(.top, 20)
            .opacity(showContent ? 1 : 0)

            // Tools grid
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 12) {
                    ForEach(ToolSelectionInfo.allTools) { tool in
                        ToolSelectionCard(
                            tool: tool,
                            isEnabled: enabledTools.contains(tool.id)
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                toggleTool(tool.id)
                            }
                        }
                        .opacity(showContent ? 1 : 0)
                        .scaleEffect(showContent ? 1 : 0.9)
                    }
                }
                .padding(.horizontal, 24)
            }

            // Quick actions
            HStack(spacing: 16) {
                QuickActionButton(title: "Select All", icon: "checkmark.circle.fill") {
                    withAnimation {
                        enabledTools = Set(ToolSelectionInfo.allTools.map { $0.id })
                        syncWithService()
                    }
                }

                QuickActionButton(title: "Clear All", icon: "xmark.circle.fill") {
                    withAnimation {
                        enabledTools.removeAll()
                        syncWithService()
                    }
                }
            }
            .padding(.horizontal, 24)
            .opacity(showContent ? 1 : 0)

            // Counter
            Text("\(enabledTools.count) tools enabled")
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.severanceMuted)
                .padding(.bottom, 20)
                .opacity(showContent ? 1 : 0)
        }
        .onAppear {
            // Default enabled tools
            enabledTools = ["search", "getTodayDate", "queryRefine"]
            syncWithService()

            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                showContent = true
            }
        }
    }

    private func toggleTool(_ toolId: String) {
        if enabledTools.contains(toolId) {
            enabledTools.remove(toolId)
        } else {
            enabledTools.insert(toolId)
        }
        onboardingService.toggleTool(toolId)
    }

    private func syncWithService() {
        for toolId in enabledTools where !onboardingService.state.enabledTools.contains(toolId) {
            onboardingService.toggleTool(toolId)
        }
    }
}

struct ToolSelectionCard: View {
    let tool: ToolSelectionInfo
    let isEnabled: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            VStack(spacing: 12) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isEnabled ? Color.severanceGreen.opacity(0.15) : Color.severanceTeal)
                        .frame(width: 50, height: 50)

                    Image(systemName: tool.icon)
                        .font(.system(size: 22))
                        .foregroundColor(isEnabled ? .severanceGreen : .severanceMuted)
                }

                VStack(spacing: 4) {
                    Text(tool.name)
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        .foregroundColor(.severanceText)

                    Text(tool.description)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.severanceMuted)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }

                // Status indicator
                Image(systemName: isEnabled ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18))
                    .foregroundColor(isEnabled ? .severanceGreen : .severanceBorder)
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.severanceCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isEnabled ? Color.severanceGreen : Color.severanceBorder,
                                lineWidth: isEnabled ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
            }
            .foregroundColor(.severanceGreen)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .stroke(Color.severanceGreen.opacity(0.5), lineWidth: 1)
            )
        }
    }
}
