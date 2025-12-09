import SwiftUI
import SwiftData
import SharedUIKit

/// A service that provides the chat interface for interacting with the AI assistant.
///
/// The chat interface serves as the main user interaction point where users can:
/// - View dynamic prompts based on their selected AI persona
/// - Compose and send messages to the AI
/// - View conversation history
/// - Manage AI settings (model, persona, tools)
@MainActor
public struct ChatUIService {
    /// Returns the chat home view with the specified page state binding.
    ///
    /// - Parameter pageState: A binding to the current page state that controls navigation.
    /// - Returns: A SwiftUI view representing the chat interface.
    public static func pageView(_ pageState: Binding<PageState>) -> some View {
        ChatHome(pageState: pageState)
    }

    /// Returns the SwiftData model container schema for chat data.
    ///
    /// Use this to configure the model container in your app.
    public static var modelSchema: [any PersistentModel.Type] {
        [Conversation.self, ChatMessage.self]
    }
}
