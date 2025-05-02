import ClipperCoreKit
import OnboardUI
import LoadingUI
import MarkdownUI
import SharedUIKit
import SwiftUI
import SettingsPage

struct HomePage: View {
    @Environment(\.deviceStat) private var deviceStat
    @Environment(\.clipperAssistant) private var clipperAssistant
    @Environment(\.hideKeyboard) private var hideKeyboard
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
    @AppStorage("ClipperModel") private var llm: String?
    
    @State private var userPrompt: String = ""
    @State private var showMemoryUsage: Bool = false
    @State private var showSettings: Bool = false
    
    var body: some View {
        if isFirstLaunch {
            OnboardUIPageService.pageView($isFirstLaunch)
        } else if let _ = clipperAssistant.loadedLLM {
            NavigationStack {
                ZStack {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            hideKeyboard()
                        }
                    VStack(alignment: .leading) {
                        if clipperAssistant.running {
                            ProgressView()
                                .frame(maxHeight: 20)
                            Spacer()
                        }
                        modelOutputView
                        PromptUI(promptText: $userPrompt) {
                            generate()
                        }
                    }
                    .padding()
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            copyOutputButton
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            memoryUsageButton
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            settingsButton
                        }
                    }
                }
                .sheet(isPresented: $showMemoryUsage) {
                    MemoryUsageView()
                }
                .sheet(isPresented: $showSettings) {
                    SettingsPageService.pageView
                }
                .toolbarBackgroundVisibility(.visible, for: .navigationBar)
                .toolbarBackground(Color.darkPastelRed, for: .navigationBar)
                .navigationTitle("Benji")
                .navigationBarTitleDisplayMode(.inline)
            }
        } else {
            LoadingUIService.pageView
                .task {
                    if let llmID = llm, let llm = clipperAssistant.llms.filter({$0.id == llmID}).first {
                        clipperAssistant.selectedModel(llm)
                    } else if let llm = clipperAssistant.llms.filter({ $0.id == "mlx-community/Qwen2.5-1.5B-Instruct-4bit"}).first {
                        clipperAssistant.selectedModel(llm)
                    }
                    try? await clipperAssistant.load()
                }
        }
    }
    
    var modelOutputView: some View {
        ScrollView(.vertical) {
            ScrollViewReader { sp in
                Group {
                    AnswerUI(response: clipperAssistant.output)
                }
                .onChange(of: clipperAssistant.output) { _, _ in
                    sp.scrollTo("bottom")
                }
                
                Spacer()
                    .frame(width: 1, height: 1)
                    .id("bottom")
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    var memoryUsageButton: some View {
        Button {
            showMemoryUsage.toggle()
        } label: {
            Image(systemName: "chart.bar.xaxis.ascending.badge.clock")
        }
        .disabled(clipperAssistant.llm == nil)
    }
    
    var settingsButton: some View {
        Button {
            showSettings.toggle()
        } label: {
            Image(systemName: "gear")
        }
    }

    var copyOutputButton: some View {
        Button {
            Task {
                copyToClipboard(clipperAssistant.output)
            }
        } label: {
            Label("Copy Output", systemImage: "doc.on.doc.fill")
        }
        .disabled(clipperAssistant.output == "")
        .labelStyle(.titleAndIcon)
    }
    
    private func generate() {
        Task {
            await clipperAssistant.generate(prompt: userPrompt)
            userPrompt = ""
        }
    }
    
    private func cancel() {
        clipperAssistant.generationTask?.cancel()
    }
    
    private func copyToClipboard(_ string: String) {
#if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(string, forType: .string)
#else
        UIPasteboard.general.string = string
#endif
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    HomePage()
}
