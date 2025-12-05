import SwiftUI
import ClipperCoreKit

// MARK: - Persona Selection Sheet

struct PersonaSelectionSheet: View {
    let onboardingService: OnboardingService
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
                        HStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.severanceAmber)
                            Text("Personas are experimental. Always consult professionals for specialized advice.")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.severanceMuted)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.severanceAmber.opacity(0.1))
                        )

                        ForEach(AIPersona.allCases) { persona in
                            PersonaSheetRow(
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
                        .foregroundColor(.severanceGreen)
                        .tracking(2)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(.severanceGreen)
                }
            }
            .toolbarBackground(Color.severanceBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .presentationDetents([.large])
        .presentationBackground(Color.severanceBackground)
        .onAppear {
            selectedPersona = onboardingService.state.selectedPersona
        }
    }

    private func selectPersona(_ persona: AIPersona) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedPersona = persona
            onboardingService.selectPersona(persona)
            // Update the system prompt on the clipper assistant
            clipperAssistant.setSystemPrompt(persona.systemPrompt)
        }
    }
}

private struct PersonaSheetRow: View {
    let persona: AIPersona
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.severanceGreen.opacity(0.2) : Color.severanceTeal)
                        .frame(width: 44, height: 44)

                    Image(systemName: persona.icon)
                        .font(.system(size: 20))
                        .foregroundColor(isSelected ? .severanceGreen : .severanceMuted)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(persona.rawValue)
                        .font(.system(size: 14, weight: .semibold, design: .monospaced))
                        .foregroundColor(.severanceText)

                    Text(persona.subtitle)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.severanceMuted)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.severanceGreen)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.severanceCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? Color.severanceGreen : Color.severanceBorder,
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
