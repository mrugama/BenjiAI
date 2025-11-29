import SwiftUI
import OnboardUI
import HomePage
import SettingsPage
import LoadingUI
import SharedUIKit

struct CoordinatorView: View {
    @State private var pageState: PageState = .welcome
    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = true
    @Environment(\.clipperAssistant) private var clipper
    
    var body: some View {
        switch pageState {
        case .welcome:
            WelcomeView(pageState: $pageState)
        case .onboarding:
            OnboardUIPageService.pageView($pageState)
        case .home:
            HomePageService.pageView
        case .settings:
            SettingsPageService.pageView($pageState)
        case .loading:
            LoadingUIService.pageView($pageState)
        }
    }
}
