import Foundation
import SwiftData

/// A conversation containing multiple messages
@Model
public final class Conversation {
    /// Unique identifier
    public var id: UUID

    /// Title of the conversation (generated from first message or AI)
    public var title: String

    /// When the conversation was created
    public var createdAt: Date

    /// When the conversation was last updated
    public var updatedAt: Date

    /// The AI persona used for this conversation
    public var personaRawValue: String

    /// All messages in this conversation
    @Relationship(deleteRule: .cascade, inverse: \ChatMessage.conversation)
    public var messages: [ChatMessage]

    /// Whether the conversation has been saved by the user
    public var isSaved: Bool

    public init(
        id: UUID = UUID(),
        title: String = "New Conversation",
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        persona: String = "Generic Assistant",
        messages: [ChatMessage] = [],
        isSaved: Bool = false
    ) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.personaRawValue = persona
        self.messages = messages
        self.isSaved = isSaved
    }

    /// Get messages sorted by timestamp
    public var sortedMessages: [ChatMessage] {
        messages.sorted { $0.timestamp < $1.timestamp }
    }

    /// Get the last message
    public var lastMessage: ChatMessage? {
        sortedMessages.last
    }

    /// Get preview text for the conversation
    public var previewText: String {
        if let firstUserMessage = messages.first(where: { $0.role == .user }) {
            let text = firstUserMessage.content
            return text.count > 50 ? String(text.prefix(50)) + "..." : text
        }
        return "No messages"
    }
}
