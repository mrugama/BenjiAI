import SwiftUI
import SharedUIKit

/// View for browsing conversation history
struct ConversationHistoryView: View {
    @Environment(\.dismiss) private var dismiss

    let conversations: [Conversation]
    let onSelect: (Conversation) -> Void
    let onDelete: (Conversation) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Color.severanceBackground
                    .ignoresSafeArea()

                if conversations.isEmpty {
                    emptyStateView
                } else {
                    conversationListView
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("HISTORY")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.severanceGreen)
                        .tracking(2)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundStyle(Color.severanceGreen)
                }
            }
            .toolbarBackground(Color.severanceBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .presentationDetents([.large])
        .presentationBackground(Color.severanceBackground)
    }

    // MARK: - Subviews

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 48))
                .foregroundStyle(Color.severanceMuted)

            Text("No conversations yet")
                .font(.system(size: 16, design: .monospaced))
                .foregroundStyle(Color.severanceMuted)

            Text("Start chatting to see your history here")
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(Color.severanceMuted.opacity(0.6))
        }
    }

    private var conversationListView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 12) {
                ForEach(groupedConversations.keys.sorted().reversed(), id: \.self) { date in
                    Section {
                        ForEach(groupedConversations[date] ?? []) { conversation in
                            ConversationRow(
                                conversation: conversation,
                                onTap: { onSelect(conversation) },
                                onDelete: { onDelete(conversation) }
                            )
                        }
                    } header: {
                        Text(dateHeader(for: date))
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color.severanceMuted)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 16)
                    }
                }
            }
            .padding(20)
        }
    }

    // MARK: - Helpers

    private var groupedConversations: [Date: [Conversation]] {
        Dictionary(grouping: conversations) { conversation in
            Calendar.current.startOfDay(for: conversation.updatedAt)
        }
    }

    private func dateHeader(for date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return "TODAY"
        } else if Calendar.current.isDateInYesterday(date) {
            return "YESTERDAY"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM d, yyyy"
            return formatter.string(from: date).uppercased()
        }
    }
}

/// A row displaying a conversation in the history
struct ConversationRow: View {
    let conversation: Conversation
    let onTap: () -> Void
    let onDelete: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 14) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.severanceTeal)
                        .frame(width: 44, height: 44)

                    Image(systemName: "bubble.left.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.severanceMuted)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(conversation.title)
                        .font(.system(size: 14, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Color.severanceText)
                        .lineLimit(1)

                    Text(conversation.previewText)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(Color.severanceMuted)
                        .lineLimit(2)
                }

                Spacer()

                // Time
                Text(conversation.updatedAt.formatted(date: .omitted, time: .shortened))
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(Color.severanceMuted.opacity(0.6))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.severanceCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.severanceBorder, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
