import SwiftUI
import SharedUIKit
import ClipperCoreKit

struct LLMLoadingView: View {
    @Binding var pageState: PageState
    @Environment(\.clipperAssistant) private var clipper
    @AppStorage("BenjiLLM") private var savedLlmId: String = "mlx-community/Qwen2.5-1.5B-Instruct-4bit"

    var body: some View {
        ZStack {
            MetalBackgroundView()
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                if let selectedLLM = clipper.llms.filter({ $0.id == clipper.llm}).first {
                    Text(selectedLLM.name)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(radius: 10)
                } else {
                    Text("Benji AI")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(radius: 10)
                }

                VStack(spacing: 12) {
                    ProgressView(value: clipper.loadingProgress.progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .white))
                        .scaleEffect(x: 1.2, y: 2, anchor: .center)
                        .padding(.horizontal, 40)

                    Text("\(Int(clipper.loadingProgress.progress * 100))%")
                        .font(.system(.title2, design: .monospaced))
                        .foregroundStyle(.white)
                }

                Spacer()

                Text(clipper.llm?.description ?? "Loading LLM...")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.8))
                    .padding()
            }
            .padding()
        }
        .ignoresSafeArea(.all)
        .interactiveDismissDisabled()
        .task {
                clipper.selectedModel(savedLlmId)
                await clipper.load()
                pageState = .home
        }
    }
}
