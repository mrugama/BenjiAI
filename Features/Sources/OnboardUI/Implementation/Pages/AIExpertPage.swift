import SwiftUI

struct AIExpertPage: View {
    let onboardingService: OnboardingService
    @State private var showContent = false
    @State private var selectedPersona: AIPersona = .generic
    @State private var showDisclaimer = false

    var body: some View {
        VStack(spacing: 16) {
            // Header
            VStack(spacing: 12) {
                GlowingText(
                    text: "AI EXPERT",
                    font: .system(size: 24, weight: .bold, design: .monospaced),
                    glowRadius: 6
                )

                Text("Define your AI's personality")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(.severanceMuted)
            }
            .padding(.top, 16)
            .opacity(showContent ? 1 : 0)

            // Experimental warning
            HStack(spacing: 10) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.severanceAmber)

                VStack(alignment: .leading, spacing: 2) {
                    Text("EXPERIMENTAL FEATURE")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.severanceAmber)

                    Text("AI responses are for guidance only. Always consult professionals.")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.severanceMuted)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.severanceAmber.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.severanceAmber.opacity(0.3), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 24)
            .opacity(showContent ? 1 : 0)

            // Persona grid
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10)
                ], spacing: 10) {
                    ForEach(AIPersona.allCases) { persona in
                        PersonaCard(
                            persona: persona,
                            isSelected: selectedPersona == persona
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedPersona = persona
                                onboardingService.selectPersona(persona)
                            }
                        }
                        .opacity(showContent ? 1 : 0)
                        .scaleEffect(showContent ? 1 : 0.9)
                    }
                }
                .padding(.horizontal, 24)
            }

            // Selected persona info
            if selectedPersona != .generic {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.severanceCyan)

                    Button {
                        showDisclaimer = true
                    } label: {
                        Text("View disclaimer for \(selectedPersona.rawValue)")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.severanceCyan)
                            .underline()
                    }
                }
                .padding(.bottom, 16)
                .opacity(showContent ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                showContent = true
            }
        }
        .alert("Professional Disclaimer", isPresented: $showDisclaimer) {
            Button("I Understand", role: .cancel) { }
        } message: {
            Text(getDisclaimerText(for: selectedPersona))
        }
    }

    private func getDisclaimerText(for persona: AIPersona) -> String {
        switch persona {
        case .vet:
            return """
            This AI provides general pet care guidance only.
            For medical emergencies or health concerns, always consult a licensed veterinarian.
            """
        case .realEstate:
            return """
            This AI provides general real estate information only.
            For transactions and legal matters, consult a licensed real estate professional.
            """
        case .cryptoBro, .investor:
            return """
            This AI does not provide financial advice.
            All investment discussions are educational.
            Consult a licensed financial advisor before making investment decisions.
            """
        case .personalTrainer:
            return """
            This AI provides general fitness guidance.
            Consult a healthcare provider before starting any exercise program.
            """
        case .nutritionist:
            return """
            This AI provides general dietary information only.
            For medical conditions or specific dietary needs, consult a registered dietitian or healthcare provider.
            """
        default:
            return "This AI provides general assistance only. Always seek professional advice for specific concerns."
        }
    }
}

struct PersonaCard: View {
    let persona: AIPersona
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 10) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.severanceGreen.opacity(0.2) : Color.severanceTeal)
                        .frame(width: 50, height: 50)

                    Image(systemName: persona.icon)
                        .font(.system(size: 22))
                        .foregroundColor(isSelected ? .severanceGreen : .severanceMuted)
                }

                VStack(spacing: 3) {
                    Text(persona.rawValue)
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(.severanceText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Text(persona.subtitle)
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(.severanceMuted)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, 8)
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
            .shadow(color: isSelected ? Color.severanceGreen.opacity(0.2) : .clear, radius: 6)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
