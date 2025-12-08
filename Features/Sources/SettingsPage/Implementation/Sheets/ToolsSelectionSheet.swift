import SwiftUI
import UserPreferences

// MARK: - Tools Selection Sheet

struct ToolsSelectionSheet: View {
    let preferencesService: UserPreferencesService
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
                            PreferenceToggleRow(
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
            enabledTools = preferencesService.state.enabledTools
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
            preferencesService.toggleTool(toolId)
        }
    }
}
