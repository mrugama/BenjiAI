import SwiftUI
import SwiftData
import SharedUIKit
import ClipperCoreKit
import UserPreferences

/// The main chat home view with dynamic prompts
struct ChatHome: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.clipperAssistant) private var clipperAssistant
    @Environment(\.userPreferencesService) private var preferencesService

    @Binding var pageState: PageState

    @State private var viewModel = ChatViewModel()
    @State private var showCompose = false
    @State private var showMicUnavailable = false
    @State private var showModelSheet = false
    @State private var showPersonaSheet = false
    @State private var showToolsSheet = false
    @State private var showConversationHistory = false

    @Query(sort: \Conversation.updatedAt, order: .reverse)
    private var conversations: [Conversation]

    private var currentPersona: AIPersona {
        preferencesService?.state.selectedPersona ?? .generic
    }

    private var hasConversation: Bool {
        viewModel.currentConversation != nil && !(viewModel.currentConversation?.messages.isEmpty ?? true)
    }

    var body: some View {
        ZStack {
            Color.severanceBackground.ignoresSafeArea()
            SeveranceUI.floatingParticles().opacity(0.3)

            VStack(spacing: 0) {
                headerView
                contentView
                bottomInputArea
            }

            // Only show floating mic when no conversation (on welcome screen)
            if !hasConversation && !clipperAssistant.running {
                floatingMicButton
            }
        }
        .preferredColorScheme(.dark)
        .fullScreenCover(isPresented: $showCompose) {
            ComposeView(
                initialText: viewModel.initialPrompt,
                persona: currentPersona,
                onSend: { viewModel.sendMessage($0, persona: currentPersona) },
                onModelTap: { showModelSheet = true },
                onPersonaTap: { showPersonaSheet = true },
                onToolsTap: { showToolsSheet = true },
                onMicTap: { showMicUnavailable = true }
            )
        }
        .sheet(isPresented: $showMicUnavailable) { MicrophoneUnavailableView() }
        .sheet(isPresented: $showModelSheet) { ModelSelectionSheet() }
        .sheet(isPresented: $showPersonaSheet) { PersonaSelectionSheet() }
        .sheet(isPresented: $showToolsSheet) { ToolsSelectionSheet() }
        .sheet(isPresented: $showConversationHistory) {
            ConversationHistoryView(
                conversations: conversations,
                onSelect: {
                    viewModel.currentConversation = $0
                    showConversationHistory = false
                },
                onDelete: { viewModel.deleteConversation($0) }
            )
        }
        .onChange(of: clipperAssistant.output) { _, newValue in
            viewModel.handleStreamingOutput(newValue, isRunning: clipperAssistant.running)
        }
        .onChange(of: clipperAssistant.running) { _, isRunning in
            if !isRunning { viewModel.finalizeAssistantResponse(output: clipperAssistant.output) }
        }
        .onAppear {
            viewModel.configure(modelContext: modelContext, clipperAssistant: clipperAssistant)
            viewModel.initialPrompt = ""
        }
    }

    // MARK: - Subviews

    private var headerView: some View {
        HStack {
            Button { showConversationHistory = true } label: {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.severanceGreen)
            }

            Spacer()

            VStack(spacing: 2) {
                Text("BENJI")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color.severanceGreen)
                    .tracking(4)
                Text(currentPersona.rawValue)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(Color.severanceMuted)
            }

            Spacer()

            Button { pageState = .settings } label: {
                Image(systemName: "gear")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.severanceGreen)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    @ViewBuilder
    private var contentView: some View {
        if let conversation = viewModel.currentConversation, !conversation.messages.isEmpty {
            conversationView(conversation)
        } else if viewModel.streamingMessage != nil || clipperAssistant.running {
            streamingView
        } else {
            Spacer()
            DynamicPromptView(persona: currentPersona) { prompt in
                viewModel.initialPrompt = prompt
                showCompose = true
            }
            .id(currentPersona)
            Spacer()
        }
    }

    @ViewBuilder
    private var streamingView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                if let userMessage = viewModel.lastUserMessage {
                    MessageBubble(
                        message: userMessage,
                        isStreaming: true,
                        onCopy: {},
                        onShare: {},
                        onDelete: {}
                    )
                }

                if let streaming = viewModel.streamingMessage, !streaming.content.isEmpty {
                    MessageBubble(
                        message: streaming,
                        isStreaming: true,
                        onCopy: {},
                        onShare: {},
                        onDelete: {}
                    )
                } else if clipperAssistant.running {
                    thinkingIndicator
                }
            }
            .padding(.vertical, 16)
            .padding(.bottom, 20)
        }
    }

    @ViewBuilder
    private func conversationView(_ conversation: Conversation) -> some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 16) {
                    ForEach(conversation.sortedMessages) { message in
                        MessageBubble(
                            message: message,
                            isStreaming: false,
                            onCopy: { viewModel.copyMessage(message) },
                            onShare: { viewModel.shareMessage(message) },
                            onDelete: { viewModel.deleteMessagePair(message) }
                        )
                        .id(message.id)
                    }

                    if let streaming = viewModel.streamingMessage,
                       !streaming.content.isEmpty,
                       clipperAssistant.running {
                        MessageBubble(
                            message: streaming,
                            isStreaming: true,
                            onCopy: {},
                            onShare: {},
                            onDelete: {}
                        )
                        .id("streaming")
                    } else if clipperAssistant.running {
                        thinkingIndicator.id("thinking")
                    }
                }
                .padding(.vertical, 16)
                .padding(.bottom, 20)
            }
            .onChange(of: conversation.messages.count) { _, _ in
                scrollToBottom(proxy: proxy, conversation: conversation)
            }
            .onChange(of: viewModel.streamingMessage?.content) { _, _ in
                scrollToBottom(proxy: proxy, conversation: conversation)
            }
        }
    }

    private var thinkingIndicator: some View {
        HStack {
            ProgressView().tint(Color.severanceGreen)
            Text("Thinking...")
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(Color.severanceMuted)
        }
        .padding()
    }

    private var bottomInputArea: some View {
        VStack(spacing: 16) {
            ChatInputBar(
                placeholder: "Message \(currentPersona.rawValue)...",
                onTap: { showCompose = true },
                onSendTap: { }
            )
            QuickActionsBar(
                onModelTap: { showModelSheet = true },
                onPersonaTap: { showPersonaSheet = true },
                onToolsTap: { showToolsSheet = true }
            )
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
    }

    private var floatingMicButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                FloatingMicButton { showMicUnavailable = true }
                    .padding(.trailing, 20)
                    .padding(.bottom, 140)
            }
        }
    }

    // MARK: - Helpers

    private func scrollToBottom(proxy: ScrollViewProxy, conversation: Conversation) {
        let target: AnyHashable
        if clipperAssistant.running {
            if viewModel.streamingMessage != nil && !(viewModel.streamingMessage?.content.isEmpty ?? true) {
                target = "streaming"
            } else {
                target = "thinking"
            }
        } else if let lastMessage = conversation.sortedMessages.last {
            target = lastMessage.id
        } else {
            return
        }

        withAnimation(.easeOut(duration: 0.2)) {
            proxy.scrollTo(target, anchor: .bottom)
        }
    }
}
