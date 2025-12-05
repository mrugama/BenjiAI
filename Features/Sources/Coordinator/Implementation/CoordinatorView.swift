import HomePage
import LoadingUI
import OnboardUI
import SettingsPage
import SharedUIKit
import SwiftUI

struct CoordinatorView: View {
    @State private var pageState: PageState = .welcome
    @State private var onboardingService: OnboardingService = OnboardingServiceImpl()

    var body: some View {
        switch pageState {
        case .welcome:
            WelcomeView(pageState: $pageState)
        case .onboarding:
            OnboardingUIService.pageView($pageState, onboardingService: onboardingService)
        case .home:
            HomePageService.pageView($pageState)
        case .settings:
            SettingsPageService.pageView(
                $pageState,
                settingsService: SettingsServiceImpl(onboardingService: onboardingService),
                onboardingService: onboardingService
            )
        case .loading:
            LoadingUIService.pageView($pageState)
        }
    }
}
