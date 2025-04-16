import SwiftUI
import ClipperCoreKit

struct SettingsPage: View {
    @State private var showMenu: Bool = false
    @Environment(\.clipperAssistant) private var clipperAssistant
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section("Model") {
                        HStack(spacing: 12) {
                            Image(systemName: "apple.intelligence")
                                .font(.title)
                            VStack(alignment: .leading) {
                                Text(clipperAssistant.llm != nil ? clipperAssistant.llm!.name : "Pick your LLM")
                                    .font(.headline)
                                Text(clipperAssistant.llm != nil ? clipperAssistant.llm!.name : "No model")
                                    .font(.subheadline)
                            }
                            Spacer()
                            Image(systemName: "hand.tap")
                        }
                        .frame(maxWidth: .infinity)
                        .onTapGesture {
                            showMenu = true
                        }
                    }
                    
                    Section("Description") {
                        Text(clipperAssistant.llm != nil ? clipperAssistant.llm!.description : "No description")
                    }
                    
                    if clipperAssistant.loadedLLM != nil {
                        Section("Loaded model") {
                            VStack(alignment: .leading) {
                                Text(clipperAssistant.modelInfo.model)
                                Text("name")
                                    .font(.footnote)
                            }
                            VStack(alignment: .leading) {
                                Text(clipperAssistant.modelInfo.weights)
                                Text("Weights")
                                    .font(.footnote)
                            }
                            VStack(alignment: .leading) {
                                Text(clipperAssistant.modelInfo.numParams)
                                Text("Params")
                                    .font(.footnote)
                            }
                            VStack(alignment: .leading) {
                                Text(clipperAssistant.stat)
                                Text("Tokens per seconds")
                                    .font(.footnote)
                            }
                        }
                    }
                }
                .navigationTitle("Settings")
                .sheet(isPresented: $showMenu) {
                    SettingsSheet()
                        .presentationCornerRadius(32)
                        .presentationDetents([.medium])
                        .presentationBackground(.thinMaterial)
                }
                
                Button("Download LLM") {
                    Task {
                        try await clipperAssistant.load()
                    }
                }
                .buttonStyle(GrowingButton())
                .padding(16)
                .disabled(clipperAssistant.llm == nil)
            }
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    SettingsPage()
}
