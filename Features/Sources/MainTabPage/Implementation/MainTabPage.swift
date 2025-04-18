import SwiftUI
import HomePage
import SettingsPage
import ClipperCoreKit
import SharedUIKit
import OnboardUI
import LoadingUI

struct MainTabPage: View {
    @Environment(\.clipperAssistant) private var clipperAssistant
    @Environment(\.deviceStat) private var deviceStat
    @Environment(\.hideKeyboard) private var hideKeyboard
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
    @AppStorage("ClipperModel") private var llm: String?
    
    var body: some View {
        if isFirstLaunch {
            OnboardUIPageService.pageView($isFirstLaunch)
        } else if let _ = clipperAssistant.loadedLLM {
            TabView {
                Tab("Home", systemImage: "lasso.badge.sparkles") {
                    HomePageService.pageView
                        .environment(\.clipperAssistant, clipperAssistant)
                        .environment(\.deviceStat, deviceStat)
                        .environment(\.hideKeyboard, hideKeyboard)
                }
                Tab("Sentting", systemImage: "apple.intelligence") {
                    SettingsPageService.pageView
                        .environment(\.clipperAssistant, clipperAssistant)
                }
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
}
