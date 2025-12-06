import SwiftUI
import OnboardUI

// MARK: - Tools Selection Sheet

struct ToolsSelectionSheet: View {
    let onboardingService: OnboardingService
    @Environment(\.dismiss) var dismiss
    @Environment(\.clipperAssistant) private var clipperAssistant
    @State private var enabledTools: Set<String> = []

    var body: some View {
        NavigationStack {
            ZStack {
                Color.severanceBackground
                    .ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(ToolSelectionInfo.allTools) { tool in
                            ToolSheetRow(
                                tool: tool,
                                isEnabled: enabledTools.contains(tool.id)
                            ) {
                                toggleTool(tool.id)
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("MANAGE TOOLS")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.severanceGreen)
                        .tracking(2)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundStyle(Color.severanceGreen)
                }
            }
            .toolbarBackground(Color.severanceBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .presentationDetents([.large])
        .presentationBackground(Color.severanceBackground)
        .onAppear {
            enabledTools = onboardingService.state.enabledTools
        }
    }

    private func toggleTool(_ toolId: String) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if enabledTools.contains(toolId) {
                enabledTools.remove(toolId)
                Task {
                    await clipperAssistant.disableTool(toolId)
                }
            } else {
                enabledTools.insert(toolId)
                Task {
                    await clipperAssistant.enableTool(toolId)
                }
            }
            onboardingService.toggleTool(toolId)
        }
    }
}

private struct ToolSheetRow: View {
    let tool: ToolSelectionInfo
    let isEnabled: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isEnabled ? Color.severanceGreen.opacity(0.15) : Color.severanceTeal)
                        .frame(width: 44, height: 44)

                    Image(systemName: tool.icon)
                        .font(.system(size: 20))
                        .foregroundStyle(isEnabled ? Color.severanceGreen : Color.severanceMuted)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(tool.name)
                        .font(.system(size: 14, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Color.severanceText)

                    Text(tool.description)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(Color.severanceMuted)
                }

                Spacer()

                // Toggle
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(isEnabled ? Color.severanceGreen : Color.severanceBorder)
                        .frame(width: 50, height: 28)

                    Circle()
                        .fill(Color.severanceText)
                        .frame(width: 22, height: 22)
                        .offset(x: isEnabled ? 10 : -10)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.severanceCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.severanceBorder, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
