import SharedUIKit
import SwiftUI

/// A service that provides the home page view for the application.
///
/// The home page serves as the main interface where users can interact with
/// the Clipper assistant, view chat history, and manage conversations.
@MainActor
public struct HomePageService {
    /// Returns the home page view with the specified page state binding.
    ///
    /// The home page view provides the primary user interface for interacting
    /// with the assistant, including chat input, message display, and conversation
    /// management features.
    ///
    /// - Parameter pageState: A binding to the current page state that controls
    ///   navigation and view transitions.
    /// - Returns: A SwiftUI view representing the home page interface.
    public static func pageView(_ pageState: Binding<PageState>) -> some View {
        HomePage(pageState: pageState)
    }
}
