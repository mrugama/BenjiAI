import SwiftUI
import SharedUIKit

// MARK: - Warning Banner

/// A reusable warning/info banner for preference sections
public struct WarningBanner: View {
    let icon: String
    let title: String?
    let message: String
    let color: Color

    public init(
        icon: String = "info.circle.fill",
        title: String? = nil,
        message: String,
        color: Color = .severanceAmber
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.color = color
    }

    public var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(color)

            VStack(alignment: .leading, spacing: 2) {
                if let title {
                    Text(title)
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(color)
                }

                Text(message)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(Color.severanceMuted)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Preset Warning Banners

public extension WarningBanner {
    /// Warning banner for permissions
    static var permissionsNotice: WarningBanner {
        WarningBanner(
            icon: "shield.checkered",
            message: "All permissions are optional and can be changed in Settings"
        )
    }

    /// Warning banner for experimental features
    static var experimentalFeature: WarningBanner {
        WarningBanner(
            icon: "exclamationmark.triangle.fill",
            title: "EXPERIMENTAL FEATURE",
            message: "AI responses are for guidance only. Always consult professionals."
        )
    }

    /// Info banner for persona selection in settings
    static var personaDisclaimer: WarningBanner {
        WarningBanner(
            icon: "exclamationmark.triangle.fill",
            message: "Personas are experimental. Always consult professionals for specialized advice."
        )
    }

    /// Info banner for permissions in settings
    static var permissionsInfo: WarningBanner {
        WarningBanner(
            icon: "info.circle.fill",
            message: "Permissions are requested when you use related features"
        )
    }
}
