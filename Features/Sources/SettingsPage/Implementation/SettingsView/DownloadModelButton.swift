import ClipperCoreKit
import OnboardUI
import SharedUIKit
import SwiftUI

// MARK: - Download Model Button

struct DownloadModelButton: View {
    let clipperAssistant: ClipperAssistant
    @Binding var pageState: PageState
    @AppStorage("BenjiLLM") private var savedLlmId: String = "mlx-community/Qwen2.5-1.5B-Instruct-4bit"

    var body: some View {
        Button {
            Task { @MainActor in
                withAnimation(.easeInOut(duration: 0.3)) {
                    pageState = .loading
                }
                await clipperAssistant.load()
                // Persist the loaded model to AppStorage
                if let loadedModelId = clipperAssistant.llm {
                    savedLlmId = loadedModelId
                }
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "arrow.down.circle.fill")
                    .font(.system(size: 20))
                Text("DOWNLOAD MODEL")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
            }
            .foregroundStyle(Color.severanceBackground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.severanceGreen)
            )
        }
        .disabled(clipperAssistant.llm == nil)
        .opacity(clipperAssistant.llm == nil ? 0.5 : 1)
        .padding(.top, 8)
    }
}
