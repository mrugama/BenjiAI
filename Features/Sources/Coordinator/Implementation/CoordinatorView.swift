import HomePage
import LoadingUI
import OnboardUI
import SettingsPage
import SharedUIKit
import SwiftUI

struct CoordinatorView: View {
    @State private var pageState: PageState = .welcome

    var body: some View {
        switch pageState {
        case .welcome:
            WelcomeView(pageState: $pageState)
        case .onboarding:
            OnboardUIPageService.pageView($pageState)
        case .home:
            HomePageService.pageView($pageState)
        case .settings:
            SettingsPageService.pageView($pageState)
        case .loading:
            LoadingUIService.pageView($pageState)
        }
    }
}

public struct MyView: View {
    public var body: some View {
        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Hello, world!@*/Text("Hello, world!")/*@END_MENU_TOKEN@*/
    }
}
