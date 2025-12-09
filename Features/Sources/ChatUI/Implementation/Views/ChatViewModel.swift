import SwiftUI
import SwiftData
import ClipperCoreKit
import UserPreferences
import UIKit

/// ViewModel for managing chat state and actions
@MainActor
@Observable
final class ChatViewModel {
    var currentConversation: Conversation?
    var streamingMessage: ChatMessage?
    var lastUserMessage: ChatMessage?
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

        // Create or get current conversation
        if currentConversation == nil {
            let conversation = Conversation(persona: persona.rawValue)
            modelContext.insert(conversation)
            currentConversation = conversation
        }

        // Add user message
        let userMessage = ChatMessage(role: .user, content: prompt)
        userMessage.conversation = currentConversation
        modelContext.insert(userMessage)
        currentConversation?.messages.append(userMessage)
        currentConversation?.updatedAt = Date()
        lastUserMessage = userMessage

        // Reset streaming state
        streamingMessage = ChatMessage(role: .assistant, content: "")
        lastProcessedOutput = ""
        isWaitingForResponse = true

        // Trigger AI response
        clipperAssistant.generate(prompt: prompt)

        // Clear initial prompt
        initialPrompt = ""

        try? modelContext.save()
    }

    func handleStreamingOutput(_ output: String, isRunning: Bool) {
        guard isRunning, isWaitingForResponse else { return }

        let cleanedOutput = cleanOutput(output)

        // Only update if content has changed
        guard cleanedOutput != lastProcessedOutput else { return }
        lastProcessedOutput = cleanedOutput

        if streamingMessage == nil {
            streamingMessage = ChatMessage(role: .assistant, content: cleanedOutput)
        } else {
            streamingMessage?.content = cleanedOutput
        }
    }

    func finalizeAssistantResponse(output: String) {
        guard let modelContext,
              isWaitingForResponse,
              let conversation = currentConversation else {
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
        let existingAssistantMessages = conversation.messages.filter { $0.role == .assistant }
        if let lastAssistant = existingAssistantMessages.last,
           lastAssistant.content == cleanContent {
            resetStreamingState()
            return
        }

        // Save the final message
        let assistantMessage = ChatMessage(role: .assistant, content: cleanContent)
        assistantMessage.conversation = conversation
        modelContext.insert(assistantMessage)
        conversation.messages.append(assistantMessage)
        conversation.updatedAt = Date()

        try? modelContext.save()

        resetStreamingState()
    }

    private func resetStreamingState() {
        streamingMessage = nil
        lastUserMessage = nil
        isWaitingForResponse = false
        lastProcessedOutput = ""
    }

    func copyMessage(_ message: ChatMessage) {
        UIPasteboard.general.string = message.content

        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    func shareMessage(_ message: ChatMessage) {
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

    func deleteMessagePair(_ message: ChatMessage) {
        guard let modelContext,
              let conversation = currentConversation else { return }

        if message.role == .assistant {
            let sortedMessages = conversation.sortedMessages

            if let index = sortedMessages.firstIndex(where: { $0.id == message.id }),
               index > 0 {
                let previousMessage = sortedMessages[index - 1]
                if previousMessage.role == .user {
                    modelContext.delete(previousMessage)
                }
            }
            modelContext.delete(message)
        } else {
            let sortedMessages = conversation.sortedMessages

            if let index = sortedMessages.firstIndex(where: { $0.id == message.id }),
               index < sortedMessages.count - 1 {
                let nextMessage = sortedMessages[index + 1]
                if nextMessage.role == .assistant {
                    modelContext.delete(nextMessage)
                }
            }
            modelContext.delete(message)
        }

        if conversation.messages.count <= 2 {
            currentConversation = nil
        }

        try? modelContext.save()
    }

    func deleteConversation(_ conversation: Conversation) {
        guard let modelContext else { return }

        if currentConversation?.id == conversation.id {
            currentConversation = nil
        }
        modelContext.delete(conversation)
        try? modelContext.save()
    }

    // MARK: - Helpers

    private func cleanOutput(_ output: String) -> String {
        var cleaned = output

        // Remove the "## prompt \n" header pattern that ClipperAssistant adds
        // Pattern: starts with "## " followed by any text until newline
        while let range = cleaned.range(of: "## ") {
            if let newlineRange = cleaned.range(of: "\n", range: range.upperBound..<cleaned.endIndex) {
                cleaned = String(cleaned[newlineRange.upperBound...])
            } else {
                // No newline found, remove from ## to end
                cleaned = String(cleaned[..<range.lowerBound])
                break
            }
        }

        // Remove any duplicate content (sometimes LLM outputs duplicates)
        cleaned = removeDuplicateContent(cleaned)

        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func removeDuplicateContent(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return trimmed }

        // Check if the content is exactly duplicated
        let halfLength = trimmed.count / 2
        guard halfLength > 20 else { return trimmed } // Only check for longer texts

        let firstHalf = String(trimmed.prefix(halfLength))
        let secondHalf = String(trimmed.suffix(halfLength))

        // If first and second half are very similar, return just the first half
        if firstHalf.trimmingCharacters(in: .whitespacesAndNewlines) ==
            secondHalf.trimmingCharacters(in: .whitespacesAndNewlines) {
            return firstHalf
        }

        return trimmed
    }
}
