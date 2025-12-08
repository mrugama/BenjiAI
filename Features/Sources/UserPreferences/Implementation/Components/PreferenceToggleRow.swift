import SwiftUI
import SharedUIKit

// MARK: - Preference Toggle Row

/// A reusable toggle row for permission and tool selections
public struct PreferenceToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let isEnabled: Bool
    let iconShape: IconShape
    let onToggle: () -> Void

    public enum IconShape {
        case rounded
        case circle
    }

    public init(
        icon: String,
        title: String,
        subtitle: String,
        isEnabled: Bool,
        iconShape: IconShape = .rounded,
        onToggle: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.isEnabled = isEnabled
        self.iconShape = iconShape
        self.onToggle = onToggle
    }

    public var body: some View {
        Button {
            onToggle()
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
                }

                Spacer()

                // Toggle indicator
                toggleView
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.severanceCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isEnabled ? Color.severanceGreen.opacity(0.5) : Color.severanceBorder,
                                lineWidth: 1
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
                    .fill(isEnabled ? Color.severanceGreen.opacity(0.15) : Color.severanceTeal)
                    .frame(width: 44, height: 44)
            case .circle:
                Circle()
                    .fill(isEnabled ? Color.severanceGreen.opacity(0.2) : Color.severanceTeal)
                    .frame(width: 44, height: 44)
            }

            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(isEnabled ? Color.severanceGreen : Color.severanceMuted)
        }
    }

    private var toggleView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(isEnabled ? Color.severanceGreen : Color.severanceBorder)
                .frame(width: 50, height: 28)

            Circle()
                .fill(Color.severanceText)
                .frame(width: 22, height: 22)
                .offset(x: isEnabled ? 10 : -10)
        }
    }
}

// MARK: - Permission Row Extension

public extension PreferenceToggleRow {
    /// Creates a toggle row for a permission type
    init(permission: PermissionType, isGranted: Bool, onToggle: @escaping () -> Void) {
        self.init(
            icon: permission.icon,
            title: permission.rawValue,
            subtitle: permission.description,
            isEnabled: isGranted,
            iconShape: .rounded,
            onToggle: onToggle
        )
    }

    /// Creates a toggle row for a tool selection
    init(tool: ToolSelectionInfo, isEnabled: Bool, onToggle: @escaping () -> Void) {
        self.init(
            icon: tool.icon,
            title: tool.name,
            subtitle: tool.description,
            isEnabled: isEnabled,
            iconShape: .rounded,
            onToggle: onToggle
        )
    }
}
