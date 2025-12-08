import SwiftUI
import ClipperCoreKit
import UserPreferences

// MARK: - Persona Selection Sheet

struct PersonaSelectionSheet: View {
    let preferencesService: UserPreferencesService
    @Environment(\.dismiss) var dismiss
    @Environment(\.clipperAssistant) private var clipperAssistant
    @State private var selectedPersona: AIPersona = .generic

    var body: some View {
        NavigationStack {
            ZStack {
                Color.severanceBackground
                    .ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 12) {
                        // Warning
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
            selectedPersona = preferencesService.state.selectedPersona
        }
    }

    private func selectPersona(_ persona: AIPersona) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedPersona = persona
            preferencesService.selectPersona(persona)
            // Update the system prompt on the clipper assistant
            clipperAssistant.setSystemPrompt(persona.systemPrompt)
        }
    }
}
