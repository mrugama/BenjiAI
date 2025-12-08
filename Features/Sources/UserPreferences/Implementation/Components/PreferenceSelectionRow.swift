import SwiftUI
import SharedUIKit

// MARK: - Preference Selection Row

/// A reusable selection row for single-choice preferences (e.g., persona, model)
public struct PreferenceSelectionRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let isSelected: Bool
    let iconShape: IconShape
    let onSelect: () -> Void

    public enum IconShape {
        case rounded
        case circle
    }

    public init(
        icon: String,
        title: String,
        subtitle: String,
        isSelected: Bool,
        iconShape: IconShape = .rounded,
        onSelect: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.isSelected = isSelected
        self.iconShape = iconShape
        self.onSelect = onSelect
    }

    public var body: some View {
        Button {
            onSelect()
        } label: {
            HStack(spacing: 16) {
                // Icon
                iconView

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Color.severanceText)

                    Text(subtitle)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(Color.severanceMuted)
                        .lineLimit(2)
                }

                Spacer()

                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.severanceGreen)
                }
            }
            .padding(16)
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
        }
        .buttonStyle(PlainButtonStyle())
    }

    @ViewBuilder
    private var iconView: some View {
        ZStack {
            switch iconShape {
            case .rounded:
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.severanceGreen.opacity(0.2) : Color.severanceTeal)
                    .frame(width: 44, height: 44)
            case .circle:
                Circle()
                    .fill(isSelected ? Color.severanceGreen.opacity(0.2) : Color.severanceTeal)
                    .frame(width: 44, height: 44)
            }

            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(isSelected ? Color.severanceGreen : Color.severanceMuted)
        }
    }
}

// MARK: - Persona Row Extension

public extension PreferenceSelectionRow {
    /// Creates a selection row for an AI persona
    init(persona: AIPersona, isSelected: Bool, onSelect: @escaping () -> Void) {
        self.init(
            icon: persona.icon,
            title: persona.rawValue,
            subtitle: persona.subtitle,
            isSelected: isSelected,
            iconShape: .circle,
            onSelect: onSelect
        )
    }
}
