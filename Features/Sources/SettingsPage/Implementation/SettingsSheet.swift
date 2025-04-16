import SwiftUI
import ClipperCoreKit

struct SettingsSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.clipperAssistant) private var clipperAssistant
    
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
        clipperAssistant.selectedModel(llm)
        dismiss()
    }
}

