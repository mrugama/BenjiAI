import Foundation
import SwiftData

/// Represents the role of a message sender
public enum MessageRole: String, Codable, Sendable {
    case user
    case assistant
}

/// A single message in a conversation
@Model
public final class ChatMessage {
    /// Unique identifier
    public var id: UUID

    /// The role (user or assistant)
    public var roleRawValue: String

    /// The message content
    public var content: String

    /// When the message was created
    public var timestamp: Date

    /// Parent conversation
    public var conversation: Conversation?

    public var role: MessageRole {
        get { MessageRole(rawValue: roleRawValue) ?? .user }
        set { roleRawValue = newValue.rawValue }
    }

    public init(
        id: UUID = UUID(),
        role: MessageRole,
        content: String,
        timestamp: Date = Date(),
        conversation: Conversation? = nil
    ) {
        self.id = id
        self.roleRawValue = role.rawValue
        self.content = content
        self.timestamp = timestamp
        self.conversation = conversation
    }
}
