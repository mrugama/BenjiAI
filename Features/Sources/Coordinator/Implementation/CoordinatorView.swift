import HomePage
import LoadingUI
import SetupUI
import SettingsPage
import SharedUIKit
import SwiftUI
import UserPreferences

struct CoordinatorView: View {
    @State private var pageState: PageState = .welcome
    @State private var preferencesService: UserPreferencesService = UserPreferencesServiceImpl()

    var body: some View {
        switch pageState {
        case .welcome:
            WelcomeView(pageState: $pageState)
        case .onboarding:
            SetupUIService.pageView($pageState, preferencesService: preferencesService)
        case .home:
            HomePageService.pageView($pageState)
        case .settings:
            SettingsPageService.pageView(
                $pageState,
                settingsService: SettingsServiceImpl(preferencesService: preferencesService)
            )
        case .loading:
            LoadingUIService.pageView($pageState)
        }
    }
}
