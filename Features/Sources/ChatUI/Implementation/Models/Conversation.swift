import Foundation
import SwiftData

/// A conversation containing multiple messages
@Model
final class ConversationImpl: Conversation {
    /// Unique identifier
    var id: UUID

    /// Title of the conversation (generated from first message or AI)
    var title: String

    /// When the conversation was created
    var createdAt: Date

    /// When the conversation was last updated
    var updatedAt: Date

    /// The AI persona used for this conversation
    var personaRawValue: String

    /// All messages in this conversation (concrete type for SwiftData)
    @Relationship(deleteRule: .cascade, inverse: \ChatMessageImpl.conversationImpl)
    var messagesImpl: [ChatMessageImpl]

    /// Protocol-conforming accessor
    var messages: [any ChatMessage] {
        get { messagesImpl }
        set { messagesImpl = newValue.compactMap { $0 as? ChatMessageImpl } }
    }

    /// Whether the conversation has been saved by the user
    var isSaved: Bool

    init(
        id: UUID = UUID(),
        title: String = "New Conversation",
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        persona: String = "Generic Assistant",
        messages: [ChatMessageImpl] = [],
        isSaved: Bool = false
    ) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.personaRawValue = persona
        self.messagesImpl = messages
        self.isSaved = isSaved
    }

    /// Get messages sorted by timestamp
    var sortedMessages: [any ChatMessage] {
        messagesImpl.sorted { $0.timestamp < $1.timestamp }
    }

    /// Get the last message
    var lastMessage: (any ChatMessage)? {
        sortedMessages.last
    }

    /// Get preview text for the conversation
    var previewText: String {
        if let firstUserMessage = messagesImpl.first(where: { $0.role == .user }) {
            let text = firstUserMessage.content
            return text.count > 50 ? String(text.prefix(50)) + "..." : text
        }
        return "No messages"
    }
}
