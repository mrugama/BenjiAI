import ClipperCoreKit
import SwiftUI

// MARK: - Model Settings Card

struct ModelSettingsCard: View {
    let clipperAssistant: ClipperAssistant
    @Binding var showDownloadButton: Bool
    let onTap: () -> Void

    private var selectedModel: (any ClipperLLM)? {
        clipperAssistant.llms.first { $0.id == clipperAssistant.llm }
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.severanceTeal)
                        .frame(width: 44, height: 44)

                    Image(systemName: "cpu.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.severanceGreen)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedModel?.name ?? "No model selected")
                        .font(.system(size: 14, weight: .semibold, design: .monospaced))
                        .foregroundColor(.severanceText)

                    if let model = selectedModel {
                        Text(model.id)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.severanceMuted)
                            .lineLimit(1)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.severanceMuted)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.severanceCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.severanceBorder, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
