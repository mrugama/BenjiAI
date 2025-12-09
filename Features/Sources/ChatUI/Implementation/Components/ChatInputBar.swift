import SwiftUI
import SharedUIKit

/// The input bar at the bottom of the chat home
struct ChatInputBar: View {
    let placeholder: String
    let onTap: () -> Void
    let onSendTap: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Text field button (tappable, navigates to compose)
            Button {
                onTap()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "text.cursor")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.severanceMuted)

                    Text(placeholder)
                        .font(.system(size: 15, design: .monospaced))
                        .foregroundStyle(Color.severanceMuted)

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.severanceCard)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.severanceBorder, lineWidth: 1)
                        )
                )
            }

            // Send button (disabled)
            Button {
                onSendTap()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(Color.severanceBorder)
            }
            .disabled(true)
        }
    }
}

/// Quick action buttons below the input bar
struct QuickActionsBar: View {
    let onModelTap: () -> Void
    let onPersonaTap: () -> Void
    let onToolsTap: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            QuickActionChip(icon: "cpu", title: "Model", action: onModelTap)
            QuickActionChip(icon: "sparkles", title: "Persona", action: onPersonaTap)
            QuickActionChip(icon: "wrench.and.screwdriver", title: "Tools", action: onToolsTap)
        }
    }
}

/// Individual quick action chip
struct QuickActionChip: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(title)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
            }
            .foregroundStyle(Color.severanceGreen)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .stroke(Color.severanceGreen.opacity(0.4), lineWidth: 1)
            )
        }
    }
}

/// Floating microphone button
struct FloatingMicButton: View {
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                Circle()
                    .fill(Color.severanceGreen)
                    .frame(width: 56, height: 56)
                    .shadow(color: Color.severanceGreen.opacity(0.4), radius: 8, y: 4)

                Image(systemName: "mic.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(Color.severanceBackground)
            }
        }
    }
}
