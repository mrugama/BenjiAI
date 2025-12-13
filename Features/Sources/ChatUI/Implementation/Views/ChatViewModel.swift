import SwiftUI
import SwiftData
import ClipperCoreKit
import UserPreferences
import UIKit

/// ViewModel for managing chat state and actions
@MainActor
@Observable
final class ChatViewModel {
    var currentConversation: (any Conversation)?
    var streamingMessage: (any ChatMessage)?
    var lastUserMessage: (any ChatMessage)?
    var initialPrompt: String = ""
    var isWaitingForResponse = false

    private var modelContext: ModelContext?
    private var clipperAssistant: ClipperAssistant?
    private var lastProcessedOutput: String = ""

    func configure(modelContext: ModelContext, clipperAssistant: ClipperAssistant) {
        self.modelContext = modelContext
        self.clipperAssistant = clipperAssistant
    }

    // MARK: - Message Actions

    func sendMessage(_ prompt: String, persona: AIPersona) {
        guard let modelContext,
              let clipperAssistant,
              !prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        // Get or create conversation (concrete type for SwiftData)
        let conversationImpl: ConversationImpl
        if let existing = currentConversation as? ConversationImpl {
            conversationImpl = existing
        } else {
            conversationImpl = ConversationImpl(persona: persona.rawValue)
            modelContext.insert(conversationImpl)
            currentConversation = conversationImpl
        }

        // Build conversation history from existing messages (before adding the new one)
        let conversationHistory = buildConversationHistory(from: conversationImpl)

        // Add user message with concrete relationship
        let userMessage = ChatMessageImpl(role: .user, content: prompt, conversation: conversationImpl)
        modelContext.insert(userMessage)
        conversationImpl.messagesImpl.append(userMessage)
        conversationImpl.updatedAt = Date()
        lastUserMessage = userMessage

        // Reset streaming state
        streamingMessage = ChatMessageImpl(role: .assistant, content: "")
        lastProcessedOutput = ""
        isWaitingForResponse = true

        // Set the system prompt with current date/time
        let systemPrompt = PersonaPrompts.systemPrompt(for: persona, currentDate: Date())
        clipperAssistant.setSystemPrompt(systemPrompt)

        // Trigger AI response with conversation history
        clipperAssistant.generate(prompt: prompt, conversationHistory: conversationHistory)

        // Clear initial prompt
        initialPrompt = ""

        try? modelContext.save()
    }

    /// Builds the conversation history array from an existing conversation
    private func buildConversationHistory(from conversation: ConversationImpl) -> [(role: String, content: String)] {
        let sortedMessages = conversation.sortedMessages
        return sortedMessages.map { message in
            (role: message.role == .user ? "user" : "assistant", content: message.content)
        }
    }

    func handleStreamingOutput(_ output: String, isRunning: Bool) {
        // Only process if we're waiting for a response
        guard isWaitingForResponse else { return }

        let cleanedOutput = cleanOutput(output)

        // Skip if empty (waiting for content)
        guard !cleanedOutput.isEmpty else { return }

        // Only update if content has changed
        guard cleanedOutput != lastProcessedOutput else { return }
        lastProcessedOutput = cleanedOutput

        // Update or create streaming message
        if streamingMessage == nil {
            streamingMessage = ChatMessageImpl(role: .assistant, content: cleanedOutput)
        } else {
            streamingMessage?.content = cleanedOutput
        }
    }

    func forceRefreshConversation() {
        // Force SwiftData to refresh the conversation
        if let conversation = currentConversation {
            currentConversation = conversation
        }
    }

    func finalizeAssistantResponse(output: String) {
        guard let modelContext,
              isWaitingForResponse,
              let conversationImpl = currentConversation as? ConversationImpl else {
            resetStreamingState()
            return
        }

        let cleanContent = cleanOutput(output)

        // Skip if empty
        guard !cleanContent.isEmpty else {
            resetStreamingState()
            return
        }

        // Check for duplicates - compare with last assistant message only
        let existingAssistantMessages = conversationImpl.messagesImpl.filter { $0.role == .assistant }
        if let lastAssistant = existingAssistantMessages.last,
           lastAssistant.content == cleanContent {
            resetStreamingState()
            return
        }

        // Save the final message with concrete relationship
        let assistantMessage = ChatMessageImpl(role: .assistant, content: cleanContent, conversation: conversationImpl)
        modelContext.insert(assistantMessage)
        conversationImpl.messagesImpl.append(assistantMessage)
        conversationImpl.updatedAt = Date()

        try? modelContext.save()

        resetStreamingState()
    }

    private func resetStreamingState() {
        streamingMessage = nil
        lastUserMessage = nil
        isWaitingForResponse = false
        lastProcessedOutput = ""
    }

    func copyMessage(_ message: any ChatMessage) {
        UIPasteboard.general.string = message.content

        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    func shareMessage(_ message: any ChatMessage) {
        let activityVC = UIActivityViewController(
            activityItems: [message.content],
            applicationActivities: nil
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            var topController = rootViewController
            while let presented = topController.presentedViewController {
                topController = presented
            }
            topController.present(activityVC, animated: true)
        }
    }

    func deleteMessagePair(_ message: any ChatMessage) {
        guard let modelContext,
              let conversationImpl = currentConversation as? ConversationImpl,
              let messageImpl = message as? ChatMessageImpl else { return }

        if message.role == .assistant {
            let sortedMessages = conversationImpl.sortedMessages

            if let index = sortedMessages.firstIndex(where: { $0.id == message.id }),
               index > 0 {
                let previousMessage = sortedMessages[index - 1]
                if previousMessage.role == .user,
                   let prevImpl = previousMessage as? ChatMessageImpl {
                    modelContext.delete(prevImpl)
                }
            }
            modelContext.delete(messageImpl)
        } else {
            let sortedMessages = conversationImpl.sortedMessages

            if let index = sortedMessages.firstIndex(where: { $0.id == message.id }),
               index < sortedMessages.count - 1 {
                let nextMessage = sortedMessages[index + 1]
                if nextMessage.role == .assistant,
                   let nextImpl = nextMessage as? ChatMessageImpl {
                    modelContext.delete(nextImpl)
                }
            }
            modelContext.delete(messageImpl)
        }

        if conversationImpl.messagesImpl.count <= 2 {
            currentConversation = nil
        }

        try? modelContext.save()
    }

    func deleteConversation(_ conversation: any Conversation) {
        guard let modelContext,
              let conversationImpl = conversation as? ConversationImpl else { return }

        if currentConversation?.id == conversation.id {
            currentConversation = nil
        }
        modelContext.delete(conversationImpl)
        try? modelContext.save()
    }

    // MARK: - Helpers

    private func cleanOutput(_ output: String) -> String {
        var cleaned = output

        // Remove ONLY the first "## prompt \n" header that ClipperAssistant adds
        // This pattern is: "## <prompt text> \n" at the beginning
        if cleaned.hasPrefix("## ") {
            if let newlineIndex = cleaned.firstIndex(of: "\n") {
                cleaned = String(cleaned[cleaned.index(after: newlineIndex)...])
            }
        }

        // Clean up excessive whitespace at the start
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)

        // Remove duplicate content (when LLM repeats itself)
        cleaned = removeDuplicateContent(cleaned)

        return cleaned
    }

    private func removeDuplicateContent(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return trimmed }

        // Only check for longer texts (minimum 50 chars to have meaningful duplicates)
        let halfLength = trimmed.count / 2
        guard halfLength > 50 else { return trimmed }

        // Check if content is roughly duplicated by comparing halves
        let firstHalf = String(trimmed.prefix(halfLength)).trimmingCharacters(in: .whitespacesAndNewlines)
        let secondHalf = String(trimmed.suffix(halfLength)).trimmingCharacters(in: .whitespacesAndNewlines)

        // Use a similarity check rather than exact match
        if firstHalf == secondHalf {
            return firstHalf
        }

        // Check for exact duplicate blocks separated by newlines
        let lines = trimmed.components(separatedBy: "\n\n")
        if lines.count >= 2 {
            let uniqueLines = removeDuplicateBlocks(lines)
            if uniqueLines.count < lines.count {
                return uniqueLines.joined(separator: "\n\n")
            }
        }

        return trimmed
    }

    private func removeDuplicateBlocks(_ blocks: [String]) -> [String] {
        var seen = Set<String>()
        var result: [String] = []

        for block in blocks {
            let normalized = block.trimmingCharacters(in: .whitespacesAndNewlines)
            if !normalized.isEmpty && !seen.contains(normalized) {
                seen.insert(normalized)
                result.append(block)
            }
        }

        return result
    }
}
