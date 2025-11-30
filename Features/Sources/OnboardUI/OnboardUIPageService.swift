import SwiftUI
import SharedUIKit

/// A service that provides the onboarding view for first-time users.
///
/// The onboarding view introduces new users to the application, providing
/// guidance on how to use the Clipper assistant and its features.
@MainActor
public struct OnboardUIPageService {
    /// Returns the onboarding view with the specified page state binding.
    ///
    /// The onboarding view presents an introduction to the application,
    /// helping users understand how to get started with the Clipper assistant.
    ///
    /// - Parameter pageState: A binding to the current page state that controls
    ///   navigation and view transitions, allowing users to proceed past the
    ///   onboarding experience.
    /// - Returns: A SwiftUI view representing the onboarding interface.
    public static func pageView(
        _ pageState: Binding<PageState>
    ) -> some View {
        OnboardUI(pageState: pageState)
    }
}
