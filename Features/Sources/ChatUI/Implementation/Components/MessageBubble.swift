import SwiftUI
import SharedUIKit
import MarkdownUI
import UIKit

/// A message bubble for displaying chat messages
struct MessageBubble: View {
    let message: any ChatMessage
    let isStreaming: Bool
    let onCopy: () -> Void
    let onShare: () -> Void
    let onDelete: () -> Void

    @State private var showActions = false

    init(
        message: any ChatMessage,
        isStreaming: Bool = false,
        onCopy: @escaping () -> Void,
        onShare: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.message = message
        self.isStreaming = isStreaming
        self.onCopy = onCopy
        self.onShare = onShare
        self.onDelete = onDelete
    }

    var body: some View {
        VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 6) {
            // Message content
            HStack(alignment: .bottom, spacing: 8) {
                if message.role == .user {
                    timestampView
                    Spacer(minLength: 40)
                }

                // Message bubble
                VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 0) {
                    if message.role == .assistant {
                        Markdown(message.content)
                            .markdownTheme(.severance)
                            .textSelection(.enabled)
                    } else {
                        Text(message.content)
                            .font(.system(size: 15, design: .monospaced))
                            .foregroundStyle(Color.white)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(bubbleBackground)

                if message.role == .assistant {
                    Spacer(minLength: 40)
                    timestampView
                }
            }

            // Action buttons (only for assistant messages, hidden during streaming)
            if message.role == .assistant && !isStreaming {
                HStack(spacing: 8) {
                    MessageActionButton(icon: "doc.on.doc", action: onCopy)
                    MessageActionButton(icon: "square.and.arrow.up", action: onShare)
                    MessageActionButton(icon: "trash", action: onDelete)
                    Spacer()
                }
                .opacity(showActions ? 1 : 0)
                .animation(.easeInOut(duration: 0.3), value: showActions)
                .onAppear {
                    // Delay showing actions for smooth appearance
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        showActions = true
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private var bubbleBackground: some View {
        Group {
            if message.role == .user {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.severanceTeal)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.severanceGreen.opacity(0.5), lineWidth: 1)
                    )
            } else {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.severanceCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.severanceCyan.opacity(0.4), lineWidth: 1)
                    )
            }
        }
    }

    private var timestampView: some View {
        Text(formatTimestamp(message.timestamp))
            .font(.system(size: 9, design: .monospaced))
            .foregroundStyle(Color.severanceMuted.opacity(0.7))
    }

    private func formatTimestamp(_ date: Date) -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()

        if calendar.isDateInToday(date) {
            formatter.dateFormat = "h:mm a"
        } else if calendar.isDateInYesterday(date) {
            formatter.dateFormat = "'Yest' h:mm"
        } else {
            formatter.dateFormat = "M/d h:mm"
        }

        return formatter.string(from: date)
    }
}

/// Small action button for messages
struct MessageActionButton: View {
    let icon: String
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundStyle(Color.severanceMuted)
                .padding(8)
                .background(
                    Circle()
                        .fill(Color.severanceCard)
                        .overlay(
                            Circle()
                                .stroke(Color.severanceBorder, lineWidth: 1)
                        )
                )
        }
    }
}

// MARK: - Markdown Theme Extension

extension MarkdownUI.Theme {
    @MainActor
    static let severance = Theme()
        .text {
            FontFamily(.system(.monospaced))
            FontSize(15)
            ForegroundColor(Color.white)
        }
        .code {
            FontFamily(.system(.monospaced))
            FontSize(14)
            ForegroundColor(Color.severanceGreen)
            BackgroundColor(Color.severanceTeal.opacity(0.5))
        }
        .strong {
            FontWeight(.bold)
            ForegroundColor(Color.white)
        }
        .emphasis {
            FontStyle(.italic)
            ForegroundColor(Color.white.opacity(0.95))
        }
        .link {
            ForegroundColor(Color.severanceCyan)
        }
        .heading1 { configuration in
            configuration.label
                .markdownMargin(top: 16, bottom: 8)
                .markdownTextStyle {
                    FontSize(22)
                    FontWeight(.bold)
                    ForegroundColor(Color.severanceGreen)
                }
        }
        .heading2 { configuration in
            configuration.label
                .markdownMargin(top: 12, bottom: 6)
                .markdownTextStyle {
                    FontSize(18)
                    FontWeight(.semibold)
                    ForegroundColor(Color.severanceGreen)
                }
        }
        .heading3 { configuration in
            configuration.label
                .markdownMargin(top: 10, bottom: 4)
                .markdownTextStyle {
                    FontSize(16)
                    FontWeight(.semibold)
                    ForegroundColor(Color.severanceCyan)
                }
        }
        .listItem { configuration in
            configuration.label
                .markdownMargin(top: 4)
        }
        .codeBlock { configuration in
            ScrollView(.horizontal, showsIndicators: false) {
                configuration.label
                    .markdownTextStyle {
                        FontFamily(.system(.monospaced))
                        FontSize(13)
                        ForegroundColor(Color.severanceGreen)
                    }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.severanceBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.severanceBorder, lineWidth: 1)
                    )
            )
            .markdownMargin(top: 10, bottom: 10)
        }
        .blockquote { configuration in
            HStack(spacing: 10) {
                Rectangle()
                    .fill(Color.severanceAmber)
                    .frame(width: 3)
                configuration.label
            }
            .padding(.leading, 8)
            .markdownTextStyle {
                FontStyle(.italic)
                ForegroundColor(Color.severanceMuted)
            }
        }
}
