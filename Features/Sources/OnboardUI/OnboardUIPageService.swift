import SwiftUI
import SharedUIKit

@MainActor
public struct OnboardUIPageService {
    public static func pageView(
        _ pageState: Binding<PageState>
    ) -> some View {
        OnboardUI(pageState: pageState)
    }
}
