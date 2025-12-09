import SwiftUI
import SwiftData
import SharedUIKit

/// Represents the role of a message sender
public enum MessageRole: String, Codable, Sendable {
    case user
    case assistant
}

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
        [ConversationImpl.self, ChatMessageImpl.self]
    }
}

/// A single message in a conversation
public protocol ChatMessage: AnyObject, Observable, Hashable, Identifiable, SendableMetatype, PersistentModel {
    /// Unique identifier
    var id: UUID { get set }

    /// The role (user or assistant)
    var roleRawValue: String { get set }

    /// The message content
    var content: String { get set }

    /// When the message was created
    var timestamp: Date { get set }

    /// Parent conversation
    var conversation: (any Conversation)? { get set }

    var role: MessageRole { get }
}

/// A conversation containing multiple messages
public protocol Conversation: AnyObject, Observable, Hashable, Identifiable, SendableMetatype, PersistentModel {
    /// Unique identifier
    var id: UUID { get set }

    /// Title of the conversation (generated from first message or AI)
    var title: String { get set }

    /// When the conversation was created
    var createdAt: Date { get set }

    /// When the conversation was last updated
    var updatedAt: Date { get set }

    /// The AI persona used for this conversation
    var personaRawValue: String { get set }

    /// All messages in this conversation
    var messages: [any ChatMessage] { get set }

    /// Whether the conversation has been saved by the user
    var isSaved: Bool { get set }

    /// Get messages sorted by timestamp
    var sortedMessages: [any ChatMessage] { get }

    /// Get the last message
    var lastMessage: (any ChatMessage)? { get }

    /// Get preview text for the conversation
    var previewText: String { get }
}
