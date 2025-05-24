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
    @AppStorage("ClipperModel") private var savedLlmId: String = "mlx-community/Qwen2.5-1.5B-Instruct-4bit"
    
    @State private var pageState: PageState
    @State private var userPrompt: String = ""
    @State private var showMemoryUsage: Bool = false
    @State private var pulseColor: Color = .green
    @State private var animationTimer: Timer?
    
    init() {
        // Initialize pageState based on first launch status
        let isFirst = UserDefaults.standard.object(forKey: "isFirstLaunch") == nil || UserDefaults.standard.bool(forKey: "isFirstLaunch")
        _pageState = State(initialValue: isFirst ? .welcome : .main)
    }
    
    var body: some View {
        currentPageView
            .preferredColorScheme(.dark)
            .task(id: clipperAssistant.isLoading) {
                // Handle loading completion
                if !clipperAssistant.isLoading && pageState == .loading {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        pageState = .main
                    }
                }
            }
            .onAppear {
                // Load LLM if not first launch and not already loaded
                if !isFirstLaunch && clipperAssistant.loadedLLM == nil {
                    loadLLM()
                }
            }
    }
    
    @ViewBuilder
    private var currentPageView: some View {
        switch pageState {
        case .welcome:
            OnboardUIPageService.pageView($isFirstLaunch)
                .onChange(of: isFirstLaunch) { _, newValue in
                    if !newValue {
                        // Animate transition from welcome to loading
                        withAnimation(.easeInOut(duration: 0.5)) {
                            pageState = .loading
                        }
                        // Start loading LLM
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            loadLLM()
                        }
                    }
                }
        case .main:
            mainView
        case .settings:
            SettingsPageService.pageView($pageState)
        case .loading:
            ZStack {
                Color.black
                    .ignoresSafeArea(.all)
                LoadingUIService.pageView
            }
            .interactiveDismissDisabled()
        }
    }
    
    private var mainView: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .contentShape(Rectangle())
                    .onTapGesture {
                        hideKeyboard()
                    }
                VStack(alignment: .leading) {
                    modelOutputView
                    PromptUI(promptText: $userPrompt) {
                        generate()
                    }
                }
                .padding()
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        dynamicActionButton
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
                    .preferredColorScheme(.dark)
            }
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
            .toolbarBackground(Color(uiColor: .systemGray6), for: .navigationBar)
            .navigationTitle("Benji AI")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    var modelOutputView: some View {
        ScrollView(.vertical, showsIndicators: false) {
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
    
    var dynamicActionButton: some View {
        Button {
            if clipperAssistant.running {
                // Cancel the generation
                cancel()
            } else {
                // Copy the output
                Task {
                    copyToClipboard(clipperAssistant.output)
                }
            }
        } label: {
            if clipperAssistant.running {
                Label("Stop Generation", systemImage: "stop.fill")
                    .foregroundStyle(pulseColor)
            } else {
                Label("Copy Output", systemImage: "doc.on.doc.fill")
                    .foregroundStyle(.white)
            }
        }
        .disabled(clipperAssistant.running ? false : clipperAssistant.output.isEmpty)
        .labelStyle(.titleAndIcon)
        .onAppear {
            if clipperAssistant.running {
                startPulseAnimation()
            }
        }
        .onChange(of: clipperAssistant.running) { _, isRunning in
            if isRunning {
                startPulseAnimation()
            } else {
                stopPulseAnimation()
            }
        }
    }
    
    var memoryUsageButton: some View {
        Button {
            showMemoryUsage.toggle()
        } label: {
            Image(systemName: "chart.bar.xaxis.ascending.badge.clock")
                .foregroundColor(.white)
        }
        .disabled(clipperAssistant.llm == nil)
    }
    
    var settingsButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                pageState = .settings
            }
        } label: {
            Image(systemName: "gear")
                .foregroundColor(.white)
        }
    }
    
    private func startPulseAnimation() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { _ in
            Task { @MainActor in
                withAnimation(.easeInOut(duration: 0.6)) {
                    pulseColor = pulseColor == .green ? Color.green.opacity(0.4) : .green
                }
            }
        }
    }
    
    private func stopPulseAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
        Task { @MainActor in
            pulseColor = .green
        }
    }
    
    private func loadLLM() {
        clipperAssistant.selectedModel(savedLlmId)
        clipperAssistant.load()
    }
    
    private func generate() {
        guard !userPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        clipperAssistant.generate(prompt: userPrompt)
        userPrompt = ""
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

//#Preview(traits: .sizeThatFitsLayout) {
//    HomePage(isFirstLaunch: false)
//}
