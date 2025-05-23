import SwiftUI
import SharedUIKit

@MainActor
public struct SettingsPageService: Sendable {
    public static func pageView(
        _ pageState: Binding<PageState>
    ) -> some View {
        SettingsPage(pageState: pageState)
    }
}
