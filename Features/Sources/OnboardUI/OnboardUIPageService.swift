import SwiftUI
import SharedUIKit

@MainActor
public struct OnboardUIPageService: Sendable {
    public static func pageView(
        _ pageState: Binding<PageState>
    ) -> some View {
        OnboardUI(pageState: pageState)
    }
}

