import SwiftUI
import SharedUIKit
import UserPreferences

// MARK: - Page Service

/// A service that provides the setup flow view for first-time app configuration.
@MainActor
public struct SetupUIService {
    /// Returns the setup flow view with the specified page state binding.
    public static func pageView(
        _ pageState: Binding<PageState>,
        preferencesService: UserPreferencesService
    ) -> some View {
        SetupFlow(pageState: pageState, preferencesService: preferencesService)
    }
}
