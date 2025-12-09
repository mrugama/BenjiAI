import ChatUI
import LoadingUI
import SetupUI
import SettingsPage
import SharedUIKit
import SwiftUI
import SwiftData
import UserPreferences

struct CoordinatorView: View {
    @State private var pageState: PageState = .welcome
    @State private var preferencesService: UserPreferencesService = UserPreferencesServiceImpl()

    var body: some View {
        Group {
            switch pageState {
            case .welcome:
                WelcomeView(pageState: $pageState)
            case .onboarding:
                SetupUIService.pageView($pageState, preferencesService: preferencesService)
            case .home:
                ChatUIService.pageView($pageState)
                    .environment(\.userPreferencesService, preferencesService)
            case .settings:
                SettingsPageService.pageView(
                    $pageState,
                    settingsService: SettingsServiceImpl(preferencesService: preferencesService)
                )
            case .loading:
                LoadingUIService.pageView($pageState)
            }
        }
        .modelContainer(for: ChatUIService.modelSchema)
    }
}
