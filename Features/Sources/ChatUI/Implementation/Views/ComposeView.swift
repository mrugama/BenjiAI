import SwiftUI
import SharedUIKit
import UserPreferences

/// Full-screen compose view for entering prompts (like Google Translate)
struct ComposeView: View {
    @Environment(\.dismiss) private var dismiss

    let initialText: String
    let persona: AIPersona
    let onSend: (String) -> Void
    let onModelTap: () -> Void
    let onPersonaTap: () -> Void
    let onToolsTap: () -> Void
    let onMicTap: () -> Void

    @State private var text: String = ""
    @FocusState private var isFocused: Bool

    private var hasText: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack {
            // Background
            Color.severanceBackground
                .ignoresSafeArea()
                .onTapGesture {
                    isFocused = false
                }

            VStack(spacing: 0) {
                // Header
                headerView

                // Main text editor
                textEditorView

                Spacer()

                // Footer with actions
                footerView
            }

            // Floating action button - switches between mic and send
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    floatingActionButton
                        .padding(.trailing, 20)
                        .padding(.bottom, 100)
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            text = initialText
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isFocused = true
            }
        }
    }

    // MARK: - Subviews

    private var headerView: some View {
        HStack {
            // Close button
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color.severanceMuted)
                    .padding(12)
                    .background(
                        Circle()
                            .fill(Color.severanceCard)
                    )
            }

            Spacer()

            // Persona indicator
            HStack(spacing: 8) {
                Image(systemName: persona.icon)
                    .font(.system(size: 14))
                Text(persona.rawValue)
                    .font(.system(size: 12, design: .monospaced))
            }
            .foregroundStyle(Color.severanceGreen)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.severanceCard)
                    .overlay(
                        Capsule()
                            .stroke(Color.severanceGreen.opacity(0.3), lineWidth: 1)
                    )
            )

            Spacer()

            // Spacer to balance the close button (removed send button from header)
            Color.clear
                .frame(width: 42, height: 42)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    private var textEditorView: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Placeholder or text
            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text("Enter your message...")
                        .font(.system(size: 18, design: .monospaced))
                        .foregroundStyle(Color.severanceMuted.opacity(0.5))
                        .padding(.top, 8)
                        .padding(.leading, 4)
                }

                TextEditor(text: $text)
                    .font(.system(size: 18, design: .monospaced))
                    .foregroundStyle(Color.severanceText)
                    .scrollContentBackground(.hidden)
                    .focused($isFocused)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            // Character count
            HStack {
                Spacer()
                Text("\(text.count) characters")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(Color.severanceMuted.opacity(0.5))
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
        .frame(maxHeight: .infinity)
    }

    private var footerView: some View {
        VStack(spacing: 16) {
            // Divider
            Rectangle()
                .fill(Color.severanceBorder)
                .frame(height: 1)

            // Quick actions
            HStack(spacing: 12) {
                QuickActionChip(icon: "cpu", title: "Model", action: onModelTap)
                QuickActionChip(icon: "sparkles", title: "Persona", action: onPersonaTap)
                QuickActionChip(icon: "wrench.and.screwdriver", title: "Tools", action: onToolsTap)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
    }

    private var floatingActionButton: some View {
        Button {
            if hasText {
                onSend(text)
                dismiss()
            } else {
                onMicTap()
            }
        } label: {
            ZStack {
                Circle()
                    .fill(hasText ? Color.severanceGreen : Color.severanceCard)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Circle()
                            .stroke(
                                hasText ? Color.severanceGreen : Color.severanceBorder,
                                lineWidth: 2
                            )
                    )
                    .shadow(
                        color: hasText ? Color.severanceGreen.opacity(0.4) : Color.clear,
                        radius: 8
                    )

                Image(systemName: hasText ? "arrow.up" : "mic.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(hasText ? Color.severanceBackground : Color.severanceMuted)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: hasText)
    }
}
