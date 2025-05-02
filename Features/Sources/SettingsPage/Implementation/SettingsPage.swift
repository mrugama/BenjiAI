import SwiftUI
import ClipperCoreKit

struct SettingsPage: View {
    @State private var showMenu: Bool = false
    @Environment(\.clipperAssistant) private var clipperAssistant
    @AppStorage("ClipperModel") private var llm: String?
    @State private var showDowndloadButton: Bool = false
    
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
                                    .foregroundStyle(.secondary)
                            }
                            VStack(alignment: .leading) {
                                Text(clipperAssistant.modelInfo.weights)
                                Text("Weights")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                            VStack(alignment: .leading) {
                                Text(clipperAssistant.modelInfo.numParams)
                                Text("Params")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                            if !clipperAssistant.stat.isEmpty {
                                VStack(alignment: .leading) {
                                    Text(clipperAssistant.stat)
                                    Text("Tokens per seconds")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Settings")
                .sheet(isPresented: $showMenu) {
                    SettingsSheet(showDownloadButton: $showDowndloadButton)
                        .presentationCornerRadius(32)
                        .presentationDetents([.medium])
                        .presentationBackground(.thinMaterial)
                }
                
                if showDowndloadButton {
                    Button("Download LLM") {
                        Task {
                            llm = clipperAssistant.llm?.id
                            try await clipperAssistant.load()
                        }
                    }
                    .buttonStyle(GrowingButton())
                    .padding(16)
                    .disabled(clipperAssistant.llm == nil)
                }
            }
        }
        .task {
            if clipperAssistant.loadedLLM == nil  {
                showDowndloadButton = true
            } else if let loadedLLM = clipperAssistant.loadedLLM, let selectedLLM = clipperAssistant.llm, await loadedLLM.configuration.name != selectedLLM.id {
                showDowndloadButton = true
            }
        }
    }
}
