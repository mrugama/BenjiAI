import SwiftUI
import ClipperCoreKit
import SharedUIKit

struct SettingsPage: View {
    @State private var showMenu: Bool = false
    @Environment(\.clipperAssistant) private var clipperAssistant
    @Environment(\.dismiss) private var dismiss
    @AppStorage("ClipperModel") private var savedLlmId: String?
    @State private var showDowndloadButton: Bool = false
    @Binding var pageState: PageState
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    AppVersionViewRow()
                    Section("Model") {
                        modelSelectionView
                    }
                    
                    Section("Description") {
                        modelDescriptionView
                    }
                    
                    if clipperAssistant.loadedLLM != nil {
                        Section("Loaded model") {
                            loadedModelInfoView
                        }
                    }
                }
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Back") {
                            pageState = .home
                        }
                    }
                }
                .sheet(isPresented: $showMenu) {
                    SettingsSheet(showDownloadButton: $showDowndloadButton)
                        .presentationCornerRadius(32)
                        .presentationDetents([.medium])
                        .presentationBackground(.thinMaterial)
                }
                
                if showDowndloadButton {
                    downloadButton
                }
            }
        }
        .preferredColorScheme(.dark)
        .task {
            await checkModelStatus()
        }
    }
    
    private var modelSelectionView: some View {
        HStack(spacing: 12) {
            Image(systemName: "apple.intelligence")
                .font(.title)
            VStack(alignment: .leading) {
                if let selectedLLM = selectedModel {
                    Text(selectedLLM.name)
                        .font(.headline)
                    Text(selectedLLM.id)
                        .font(.subheadline)
                } else {
                    Text("Pick your LLM")
                        .font(.headline)
                    Text("No model")
                        .font(.subheadline)
                }
            }
            Spacer()
            Image(systemName: "hand.tap")
        }
        .frame(maxWidth: .infinity)
        .onTapGesture {
            showMenu = true
        }
    }
    
    private var modelDescriptionView: some View {
        Group {
            if let selectedLLM = selectedModel {
                Text(selectedLLM.description)
            } else {
                Text("No description")
            }
        }
    }
    
    private var loadedModelInfoView: some View {
        Group {
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
    
    private var downloadButton: some View {
        Button("Download LLM") {
            Task { @MainActor in
                withAnimation(.easeInOut(duration: 0.3)) {
                    pageState = .loading
                }
                await clipperAssistant.load()
                savedLlmId = clipperAssistant.llm
                // The HomePage will handle transitioning back to .main when loading completes
            }
        }
        .buttonStyle(GrowingButton())
        .padding(16)
        .disabled(clipperAssistant.llm == nil)
    }
    
    private var selectedModel: (any ClipperLLM)? {
        clipperAssistant.llms.filter({ $0.id == clipperAssistant.llm}).first
    }
    
    private func checkModelStatus() async {
        if clipperAssistant.loadedLLM == nil {
            showDowndloadButton = true
        } else if let loadedLLM = clipperAssistant.loadedLLM, 
                  await loadedLLM.configuration.name != clipperAssistant.llm {
            showDowndloadButton = true
        }
    }
}
