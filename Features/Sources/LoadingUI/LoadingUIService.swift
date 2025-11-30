import SwiftUI
import SharedUIKit

/// A service that provides the loading view for language model operations.
///
/// The loading view displays progress and status information while language models
/// are being loaded or initialized, providing visual feedback to users during
/// potentially long-running operations.
@MainActor
public struct LoadingUIService {
    /// Returns the loading view with the specified page state binding.
    ///
    /// The loading view shows progress indicators and status messages during
    /// model loading operations, allowing users to track the initialization progress.
    ///
    /// - Parameter pageState: A binding to the current page state that controls
    ///   navigation and view transitions.
    /// - Returns: A SwiftUI view representing the loading interface.
    public static func pageView(_ pageState: Binding<PageState>) -> some View {
        LLMLoadingView(pageState: pageState)
    }
}
