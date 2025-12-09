import SwiftUI
import SharedUIKit
import ClipperCoreKit
import UserPreferences

// MARK: - Model Selection Sheet

struct ModelSelectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.clipperAssistant) private var clipperAssistant
    @Environment(\.userPreferencesService) private var preferencesService

    var body: some View {
        NavigationStack {
            ZStack {
                Color.severanceBackground
                    .ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(clipperAssistant.llms, id: \.id) { llm in
                            PreferenceSelectionRow(
                                icon: "cpu.fill",
                                title: llm.name,
                                subtitle: llm.description,
                                isSelected: clipperAssistant.llm == llm.id,
                                iconShape: .rounded
                            ) {
                                selectModel(llm)
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
                    Text("SELECT MODEL")
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
    }

    private func selectModel(_ llm: any ClipperLLM) {
        preferencesService?.updateSelectedModel(llm.id)
        clipperAssistant.selectedModel(llm.id)
        dismiss()
    }
}

// MARK: - Persona Selection Sheet

struct PersonaSelectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.clipperAssistant) private var clipperAssistant
    @Environment(\.userPreferencesService) private var preferencesService

    @State private var selectedPersona: AIPersona = .generic

    var body: some View {
        NavigationStack {
            ZStack {
                Color.severanceBackground
                    .ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 12) {
                        // Warning banner
                        WarningBanner.personaDisclaimer

                        ForEach(AIPersona.allCases) { persona in
                            PreferenceSelectionRow(
                                persona: persona,
                                isSelected: selectedPersona == persona
                            ) {
                                selectPersona(persona)
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
                    Text("AI PERSONA")
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
            selectedPersona = preferencesService?.state.selectedPersona ?? .generic
        }
    }

    private func selectPersona(_ persona: AIPersona) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedPersona = persona
            preferencesService?.selectPersona(persona)
            clipperAssistant.setSystemPrompt(persona.systemPrompt)
        }
    }
}

// MARK: - Tools Selection Sheet

struct ToolsSelectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.clipperAssistant) private var clipperAssistant
    @Environment(\.userPreferencesService) private var preferencesService

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
            enabledTools = preferencesService?.state.enabledTools ?? []
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
            preferencesService?.toggleTool(toolId)
        }
    }
}
