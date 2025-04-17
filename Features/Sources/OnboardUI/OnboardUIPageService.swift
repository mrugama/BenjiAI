import SwiftUI

@MainActor
public struct OnboardUIPageService: Sendable {
    public static func pageView(
        _ isFirstLaunch: Binding<Bool>
    ) -> some View {
        OnboardUI(isFirstLaunch: isFirstLaunch)
    }
}

