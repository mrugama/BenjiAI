import SwiftUI
import HomePage
import SettingsPage
import ClipperCoreKit
import SharedUIKit

struct MainTabPage: View {
    @Environment(\.clipperAssistant) private var clipperAssistant
    @Environment(\.deviceStat) private var deviceStat
    @Environment(\.hideKeyboard) private var hideKeyboard
    
    var body: some View {
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
        .overlay {
            if clipperAssistant.isLoading {
                ProgressView(value: clipperAssistant.loadingProgress.progress) {
                    VStack {
                        Text(clipperAssistant.loadingProgress.model)
                            .font(.caption)
                        Text(clipperAssistant.loadingProgress.progress, format: .percent)
                    }
                }
                .padding()
            }
        }
    }
}

#Preview {
    MainTabPage()
}
