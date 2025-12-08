import SwiftUI
import SharedUIKit
import UserPreferences

struct AIExpertPage: View {
    let preferencesService: UserPreferencesService
    @State private var showContent = false
    @State private var selectedPersona: AIPersona = .generic
    @State private var showDisclaimer = false

    var body: some View {
        VStack(spacing: 16) {
            // Header
            VStack(spacing: 12) {
                SeveranceUI.glowingText(
                    "AI EXPERT",
                    font: .system(size: 24, weight: .bold, design: .monospaced),
                    glowRadius: 6
                )

                Text("Define your AI's personality")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundStyle(Color.severanceMuted)
            }
            .padding(.top, 16)
            .opacity(showContent ? 1 : 0)

            // Experimental warning
            WarningBanner.experimentalFeature
                .padding(.horizontal, 24)
                .opacity(showContent ? 1 : 0)

            // Persona grid
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10)
                ], spacing: 10) {
                    ForEach(AIPersona.allCases) { persona in
                        PreferenceGridCard(persona: persona, isSelected: selectedPersona == persona) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedPersona = persona
                                preferencesService.selectPersona(persona)
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
                        .foregroundStyle(Color.severanceCyan)

                    Button {
                        showDisclaimer = true
                    } label: {
                        Text("View disclaimer for \(selectedPersona.rawValue)")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundStyle(Color.severanceCyan)
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
            Text(selectedPersona.disclaimerText)
        }
    }
}
