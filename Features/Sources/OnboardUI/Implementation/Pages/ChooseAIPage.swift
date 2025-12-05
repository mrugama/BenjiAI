import SwiftUI
import ClipperCoreKit

struct ChooseAIPage: View {
    @Environment(\.clipperAssistant) private var clipperAssistant
    let onboardingService: OnboardingService
    @State private var showContent = false
    @State private var selectedModelId: String?

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 12) {
                GlowingText(
                    text: "CHOOSE YOUR AI",
                    font: .system(size: 24, weight: .bold, design: .monospaced),
                    glowRadius: 6
                )

                Text("Select your preferred language model")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(.severanceMuted)
            }
            .padding(.top, 20)
            .opacity(showContent ? 1 : 0)

            // Model list
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(clipperAssistant.llms, id: \.id) { llm in
                        ModelSelectionCard(
                            llm: llm,
                            isSelected: selectedModelId == llm.id,
                            isDefault: llm.id == "mlx-community/Llama-3.2-3B-Instruct"
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedModelId = llm.id
                                onboardingService.updateSelectedModel(llm.id)
                                clipperAssistant.selectedModel(llm.id)
                            }
                        }
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                    }
                }
                .padding(.horizontal, 24)
            }

            // Info footer
            HStack(spacing: 8) {
                Image(systemName: "info.circle")
                    .foregroundColor(.severanceMuted)
                Text("Models run locally on your device")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.severanceMuted)
            }
            .opacity(showContent ? 1 : 0)
            .padding(.bottom, 20)
        }
        .onAppear {
            // Set default model if none selected
            if selectedModelId == nil {
                selectedModelId = "mlx-community/Llama-3.2-3B-Instruct"
                onboardingService.updateSelectedModel(selectedModelId)
                clipperAssistant.selectedModel(selectedModelId!)
            }

            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                showContent = true
            }
        }
    }
}

struct ModelSelectionCard: View {
    let llm: any ClipperLLM
    let isSelected: Bool
    let isDefault: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.severanceGreen.opacity(0.2) : Color.severanceTeal)
                        .frame(width: 50, height: 50)

                    Image(systemName: "cpu.fill")
                        .font(.system(size: 22))
                        .foregroundColor(isSelected ? .severanceGreen : .severanceMuted)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(llm.name)
                            .font(.system(size: 15, weight: .semibold, design: .monospaced))
                            .foregroundColor(.severanceText)

                        if isDefault {
                            Text("DEFAULT")
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                .foregroundColor(.severanceBackground)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule().fill(Color.severanceAmber)
                                )
                        }
                    }

                    Text(llm.description)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.severanceMuted)
                        .lineLimit(2)
                }

                Spacer()

                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.severanceGreen : Color.severanceBorder, lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Circle()
                            .fill(Color.severanceGreen)
                            .frame(width: 14, height: 14)
                    }
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
            .shadow(color: isSelected ? Color.severanceGreen.opacity(0.2) : .clear, radius: 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
