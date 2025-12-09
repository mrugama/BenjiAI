import Foundation
import SwiftData

/// A single message in a conversation
@Model
final class ChatMessageImpl: ChatMessage {
    /// Unique identifier
    var id: UUID

    /// The role (user or assistant)
    var roleRawValue: String

    /// The message content
    var content: String

    /// When the message was created
    var timestamp: Date

    /// Parent conversation (concrete type for SwiftData)
    var conversationImpl: ConversationImpl?

    /// Protocol-conforming accessor
    var conversation: (any Conversation)? {
        get { conversationImpl }
        set { conversationImpl = newValue as? ConversationImpl }
    }

    var role: MessageRole {
        get { MessageRole(rawValue: roleRawValue) ?? .user }
        set { roleRawValue = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        role: MessageRole,
        content: String,
        timestamp: Date = Date(),
        conversation: ConversationImpl? = nil
    ) {
        self.id = id
        self.roleRawValue = role.rawValue
        self.content = content
        self.timestamp = timestamp
        self.conversationImpl = conversation
    }
}
