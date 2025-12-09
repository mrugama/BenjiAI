import SwiftUI
import SharedUIKit
import UserPreferences

/// Animated dynamic prompts that cycle through examples
struct DynamicPromptView: View {
    let persona: AIPersona
    let onPromptTap: (String) -> Void

    @State private var currentPromptIndex = 0
    @State private var opacity: Double = 1.0
    @State private var prompts: [String] = []

    private let timer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 24) {
            // Greeting
            Text(PersonaPrompts.greeting(for: persona))
                .font(.system(size: 28, weight: .light, design: .monospaced))
                .foregroundStyle(Color.severanceText)
                .multilineTextAlignment(.center)

            // Dynamic prompt suggestion
            if !prompts.isEmpty {
                Button {
                    onPromptTap(prompts[currentPromptIndex])
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.severanceGreen)

                        Text(prompts[currentPromptIndex])
                            .font(.system(size: 15, design: .monospaced))
                            .foregroundStyle(Color.severanceText)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.severanceCard)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.severanceBorder, lineWidth: 1)
                            )
                    )
                }
                .opacity(opacity)
            }

            // Hint text
            Text("Tap to try this prompt")
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(Color.severanceMuted)
        }
        .onAppear {
            loadPrompts()
        }
        .onChange(of: persona) { _, _ in
            loadPrompts()
        }
        .onReceive(timer) { _ in
            cyclePrompt()
        }
    }

    private func loadPrompts() {
        currentPromptIndex = 0
        prompts = PersonaPrompts.prompts(for: persona).shuffled()
        opacity = 1.0
    }

    private func cyclePrompt() {
        guard !prompts.isEmpty else { return }

        withAnimation(.easeOut(duration: 0.3)) {
            opacity = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            currentPromptIndex = (currentPromptIndex + 1) % max(prompts.count, 1)

            withAnimation(.easeIn(duration: 0.3)) {
                opacity = 1
            }
        }
    }
}
