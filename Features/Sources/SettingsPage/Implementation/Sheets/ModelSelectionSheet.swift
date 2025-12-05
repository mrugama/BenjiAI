import SwiftUI
import ClipperCoreKit

// MARK: - Model Selection Sheet

struct ModelSelectionSheet: View {
    let clipperAssistant: ClipperAssistant
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
                            ModelSheetRow(
                                llm: llm,
                                isSelected: clipperAssistant.llm == llm.id
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
    }

    private func selectModel(_ llm: any ClipperLLM) {
        Task {
            clipperAssistant.selectedModel(llm.id)
            if await clipperAssistant.loadedLLM?.configuration.name != llm.id {
                showDownloadButton = true
            }
            dismiss()
        }
    }
}

private struct ModelSheetRow: View {
    let llm: any ClipperLLM
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? Color.severanceGreen.opacity(0.2) : Color.severanceTeal)
                        .frame(width: 44, height: 44)

                    Image(systemName: "cpu.fill")
                        .font(.system(size: 20))
                        .foregroundColor(isSelected ? .severanceGreen : .severanceMuted)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(llm.name)
                        .font(.system(size: 14, weight: .semibold, design: .monospaced))
                        .foregroundColor(.severanceText)

                    Text(llm.description)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.severanceMuted)
                        .lineLimit(2)
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
