import ClipperCoreKit
import MarkdownUI
import SharedUIKit
import SwiftUI
import SettingsPage

struct HomePage: View {
    @Environment(\.deviceStat) private var deviceStat
    @Environment(\.clipperAssistant) private var clipper
    @Environment(\.hideKeyboard) private var hideKeyboard

    @Binding var pageState: PageState
    @State private var viewModel: HomePageViewModel = .init()
    @State private var userPrompt: String = ""
    @State private var showMemoryUsage: Bool = false
    
    var body: some View {
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
                    AnswerUI(response: clipper.output)
                }
                .onChange(of: clipper.output) { _, _ in
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
            if clipper.running {
                // Cancel the generation
                cancel()
            } else {
                // Copy the output
                Task {
                    copyToClipboard(clipper.output)
                }
            }
        } label: {
            if clipper.running {
                Label("Stop Generation", systemImage: "stop.fill")
            } else {
                Label("Copy Output", systemImage: "doc.on.doc.fill")
            }
        }
        .disabled(clipper.running ? false : clipper.output.isEmpty)
        .labelStyle(.titleAndIcon)
    }
    
    var memoryUsageButton: some View {
        Button {
            showMemoryUsage.toggle()
        } label: {
            Image(systemName: "chart.bar.xaxis.ascending.badge.clock")
                .foregroundColor(.white)
        }
        .disabled(clipper.llm == nil)
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
    
    private func generate() {
        guard !userPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        clipper.generate(prompt: userPrompt)
        userPrompt = ""
    }
    
    private func cancel() {
        clipper.generationTask?.cancel()
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
