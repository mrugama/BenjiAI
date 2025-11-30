import SwiftUI
import ClipperCoreKit

struct SettingsSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.clipperAssistant) private var clipperAssistant
    @Binding var showDownloadButton: Bool

    var body: some View {
        List {
            Section {
                ForEach(clipperAssistant.llms, id: \.id) { llm in
                    Button(llm.name) {
                        llmSelected(llm)
                    }
                    .listRowSeparator(.hidden)
                }
            } header: {
                Text("LLMs for Clipper Assist")
                    .font(.title.bold())
                    .padding()
                    .foregroundStyle(Color.accentColor)
            }
        }
        .listStyle(.plain)
    }

    func llmSelected(_ llm: any ClipperLLM) {
        Task {
            clipperAssistant.selectedModel(llm.id)
            if await clipperAssistant.loadedLLM?.configuration.name != llm.id {
                showDownloadButton = true
            }
            dismiss()
        }
    }
}
