import SwiftUI
import ClipperCoreKit
import UserPreferences

// MARK: - Model Selection Sheet

struct ModelSelectionSheet: View {
    let clipperAssistant: ClipperAssistant
    let preferencesService: UserPreferencesService
    @Binding var showDownloadButton: Bool
    @Environment(\.dismiss) var dismiss

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
        Task {
            // Persist model selection
            preferencesService.updateSelectedModel(llm.id)
            clipperAssistant.selectedModel(llm.id)
            if await clipperAssistant.loadedLLM?.configuration.name != llm.id {
                showDownloadButton = true
            }
            dismiss()
        }
    }
}
