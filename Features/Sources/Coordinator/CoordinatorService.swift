import SwiftUI

/// A service that provides the main coordinator view responsible for managing
/// and coordinating what content is displayed on screen.
///
/// The coordinator view handles navigation and view state management,
/// determining which views should be presented based on the current application state.
public struct CoordinatorService {
    /// Returns the main coordinator view that manages screen content coordination.
    ///
    /// This view is responsible for determining what should be displayed on screen
    /// based on the current application state, handling navigation flow, and
    /// coordinating between different views and features.
    ///
    /// - Returns: A SwiftUI view that coordinates screen content display.
    @MainActor
    public static var pageView: some View {
        CoordinatorView()
    }
}
