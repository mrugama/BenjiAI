import SwiftUI
import SharedUIKit

/// A service that provides the settings page view for application configuration.
///
/// The settings page allows users to configure application preferences, manage
/// language models, and access various application settings and information.
@MainActor
public struct SettingsPageService {
    /// Returns the settings page view with the specified page state binding.
    ///
    /// The settings page provides a user interface for configuring application
    /// preferences, managing models, viewing app information, and accessing
    /// other configuration options.
    ///
    /// - Parameter pageState: A binding to the current page state that controls
    ///   navigation and view transitions.
    /// - Returns: A SwiftUI view representing the settings page interface.
    public static func pageView(
        _ pageState: Binding<PageState>
    ) -> some View {
        SettingsPage(pageState: pageState)
    }
}
