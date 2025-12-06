import SwiftUI
import ClipperCoreKit

struct ChooseAIPage: View {
    @Environment(\.clipperAssistant) private var clipperAssistant
    let onboardingService: OnboardingService
    @State private var showContent = false
    @State private var selectedModelId: String?
    @State private var showMoreModels = false

    private let defaultModelId = "mlx-community/Qwen2.5-1.5B-Instruct-4bit"

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
                    .foregroundStyle(Color.severanceMuted)
            }
            .padding(.top, 20)
            .opacity(showContent ? 1 : 0)

            // Model list
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 12) {
                    // Selected Model Section
                    if let selectedId = selectedModelId,
                       let selectedLLM = clipperAssistant.llms.first(where: { $0.id == selectedId }) {
                        Text("SELECTED MODEL")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color.severanceGreen)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 8)

                        ModelSelectionCard(
                            llm: selectedLLM,
                            isSelected: true,
                            isDefault: selectedLLM.id == defaultModelId
                        ) {
                            // No action needed if already selected
                        }
                        .transition(.scale.combined(with: .opacity))
                    }

                    // More Models Section
                    VStack(spacing: 12) {
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                showMoreModels.toggle()
                            }
                        } label: {
                            HStack {
                                Text("MORE MODELS")
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    .foregroundStyle(Color.severanceMuted)

                                Spacer()

                                Image(systemName: "chevron.down")
                                    .foregroundStyle(Color.severanceMuted)
                                    .rotationEffect(.degrees(showMoreModels ? 180 : 0))
                            }
                            .padding(.vertical, 8)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        if showMoreModels {
                            ForEach(sortedAvailableModels, id: \.id) { llm in
                                ModelSelectionCard(
                                    llm: llm,
                                    isSelected: false,
                                    isDefault: llm.id == defaultModelId
                                ) {
                                    selectModel(llm)
                                }
                                .transition(.move(edge: .top).combined(with: .opacity))
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
            .opacity(showContent ? 1 : 0)

            // Info footer
            HStack(spacing: 8) {
                Image(systemName: "info.circle")
                    .foregroundStyle(Color.severanceMuted)
                Text("Models run locally on your device")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(Color.severanceMuted)
            }
            .opacity(showContent ? 1 : 0)
            .padding(.bottom, 20)
        }
        .onAppear {
            // Set default model if none selected
            if selectedModelId == nil {
                selectModelById(defaultModelId)
            } else if !clipperAssistant.llms.contains(where: { $0.id == selectedModelId }) {
                 // Fallback if saved ID is invalid
                 selectModelById(defaultModelId)
            }

            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                showContent = true
            }
        }
    }

    // Helper to get sorted models excluding selected
    private var sortedAvailableModels: [any ClipperLLM] {
        clipperAssistant.llms
            .filter { $0.id != selectedModelId }
            .sorted { (lm1, lm2) -> Bool in
                // Priority to default model
                if lm1.id == defaultModelId { return true }
                if lm2.id == defaultModelId { return false }
                return lm1.name < lm2.name
            }
    }

    private func selectModel(_ llm: any ClipperLLM) {
        selectModelById(llm.id)
        // Animate closing the list separately to avoid nested conflicting animations
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            showMoreModels = false
        }
    }

    private func selectModelById(_ id: String) {
        // Single source of truth for selection animation
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedModelId = id
            onboardingService.updateSelectedModel(id)
            clipperAssistant.selectedModel(id)
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
                        .foregroundStyle(isSelected ? Color.severanceGreen : Color.severanceMuted)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(llm.name)
                            .font(.system(size: 15, weight: .semibold, design: .monospaced))
                            .foregroundStyle(Color.severanceText)
                            .multilineTextAlignment(.leading)

                        if isDefault {
                            Text("DEFAULT")
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                .foregroundStyle(Color.severanceBackground)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule().fill(Color.severanceAmber)
                                )
                        }
                    }

                    Text(llm.description)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(Color.severanceMuted)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
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
