import ClipperCoreKit
import MarkdownUI
import SwiftUI

#if canImport(UIKit)
import UIKit

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}
#endif

struct HomePage: View {
    @Environment(\.deviceStat) private var deviceStat
    @Environment(\.clipperAssistant) private var clipperAssistant
    
    @State private var userPrompt: String = ""
    @State private var formattedOutput: LocalizedStringKey = ""
    
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
                        memoryUsageLabel
                    }
                    ToolbarItem(placement: .primaryAction) {
                        copyOutputButton
                    }
                }
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
        .help(clipperAssistant.llm == nil ? "Please select a LLM model first." : "")
    }
    
    var memoryUsageLabel: some View {
        Label(
            "Memory Usage: \(deviceStat.gpuUsage.activeMemory.formatted(.byteCount(style: .memory)))",
            systemImage: "info.circle.fill"
        )
        .labelStyle(.titleAndIcon)
        .padding(.horizontal)
        .help(
            Text(
                """
                Active Memory: \(deviceStat.gpuUsage.activeMemory.formatted(.byteCount(style: .memory)))/\(DeviceStat.ClipperGPU.memoryLimit.formatted(.byteCount(style: .memory)))
                Cache Memory: \(deviceStat.gpuUsage.cacheMemory.formatted(.byteCount(style: .memory)))/\(DeviceStat.ClipperGPU.cacheLimit.formatted(.byteCount(style: .memory)))
                Peak Memory: \(deviceStat.gpuUsage.peakMemory.formatted(.byteCount(style: .memory)))
                """
            )
        )
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
