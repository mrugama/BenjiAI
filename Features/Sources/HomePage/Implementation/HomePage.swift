import ClipperCoreKit
import MarkdownUI
import SharedUIKit
import SwiftUI

struct HomePage: View {
    @Environment(\.deviceStat) private var deviceStat
    @Environment(\.clipperAssistant) private var clipperAssistant
    @Environment(\.hideKeyboard) private var hideKeyboard
    
    @State private var userPrompt: String = ""
    @State private var showMemoryUsage: Bool = false
    
    var body: some View {
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
                    submitButton
                }
                .padding()
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        memoryUsageButton
                    }
                    ToolbarItem(placement: .primaryAction) {
                        copyOutputButton
                    }
                }
            }
            .sheet(isPresented: $showMemoryUsage) {
                MemoryUsageView()
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
                
                EmptyView()
                    .frame(width: 1, height: 1)
                    .id("bottom")
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    var submitButton: some View {
        HStack(spacing: 10) {
            PromptUI(promptText: $userPrompt) {
                generate()
            }
            
            Button {
                if clipperAssistant.llm == nil {
                    return
                }
                if clipperAssistant.running {
                    cancel()
                } else {
                    generate()
                }
            } label: {
                Image(systemName: clipperAssistant.running ? "brain" : "arrow.up.square.fill")
                    .font(.largeTitle)
            }
        }
        .padding()
    }
    
    var memoryUsageButton: some View {
        Button {
            showMemoryUsage.toggle()
        } label: {
            Image(systemName: "chart.bar.xaxis.ascending.badge.clock")
        }
        .disabled(clipperAssistant.llm == nil)
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
