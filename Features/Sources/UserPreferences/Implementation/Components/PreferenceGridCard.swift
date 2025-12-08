import SwiftUI
import SharedUIKit

// MARK: - Preference Grid Card

/// A compact card for grid layouts (tools, personas in grid mode)
public struct PreferenceGridCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let isSelected: Bool
    let showCheckmark: Bool
    let onSelect: () -> Void

    public init(
        icon: String,
        title: String,
        subtitle: String,
        isSelected: Bool,
        showCheckmark: Bool = true,
        onSelect: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.isSelected = isSelected
        self.showCheckmark = showCheckmark
        self.onSelect = onSelect
    }

    public var body: some View {
        Button {
            onSelect()
        } label: {
            VStack(spacing: 10) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.severanceGreen.opacity(0.2) : Color.severanceTeal)
                        .frame(width: 50, height: 50)

                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundStyle(isSelected ? Color.severanceGreen : Color.severanceMuted)
                }

                VStack(spacing: 3) {
                    Text(title)
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Color.severanceText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Text(subtitle)
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundStyle(Color.severanceMuted)
                        .lineLimit(1)
                }

                if showCheckmark {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 18))
                        .foregroundStyle(isSelected ? Color.severanceGreen : Color.severanceBorder)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.severanceCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? Color.severanceGreen : Color.severanceBorder,
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .shadow(color: isSelected ? Color.severanceGreen.opacity(0.2) : .clear, radius: 6)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Persona Card Extension

public extension PreferenceGridCard {
    /// Creates a grid card for an AI persona
    init(persona: AIPersona, isSelected: Bool, onSelect: @escaping () -> Void) {
        self.init(
            icon: persona.icon,
            title: persona.rawValue,
            subtitle: persona.subtitle,
            isSelected: isSelected,
            showCheckmark: false,
            onSelect: onSelect
        )
    }

    /// Creates a grid card for a tool
    init(tool: ToolSelectionInfo, isEnabled: Bool, onToggle: @escaping () -> Void) {
        self.init(
            icon: tool.icon,
            title: tool.name,
            subtitle: tool.description,
            isSelected: isEnabled,
            showCheckmark: true,
            onSelect: onToggle
        )
    }
}
