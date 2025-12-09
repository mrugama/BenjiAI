import SwiftUI

public extension Color {
    // MARK: - Core palette
    static let americanSilver = Color(hex: "#D1D1D1")
    static let antiqueWhite = Color(hex: "#F8EDD9")
    static let brightSnow = Color(hex: "#FFFFFF")
    static let cosmicLatte = Color(hex: "#FFFBEB")
    static let darkPastelRed = Color(hex: "#CC4B24")
    static let emeraldedGreen = Color(hex: "#317039")
    static let gunmetal = Color(hex: "#243837")
    static let inchworm = Color(hex: "#B1FA63")
    static let maximumYellow = Color(hex: "#F1BE49")
    static let orange = Color(hex: "#FE7733")
    static let paleViolet = Color(hex: "#B2A1FF")
    static let papayaWhip = Color(hex: "#FFF1D4")

    // MARK: - Severance palette
    /// Colors inspired by the Severance TV show aesthetic
    static let severanceBackground = Color(hex: "#0A0E12")
    /// Terminal green glow - brighter for visibility
    static let severanceGreen = Color(hex: "#4AFF9F")
    /// Soft cyan accent - brighter
    static let severanceCyan = Color(hex: "#6EE7D8")
    /// Muted teal for user messages - lighter for contrast
    static let severanceTeal = Color(hex: "#1F4A4A")
    /// Amber warning/highlight
    static let severanceAmber = Color(hex: "#FFD54F")
    /// Primary text - pure white for maximum readability
    static let severanceText = Color(hex: "#FFFFFF")
    /// Secondary text - lighter gray for better visibility
    static let severanceMuted = Color(hex: "#B8C0CC")
    /// Card background - more contrast from background
    static let severanceCard = Color(hex: "#1A2128")
    /// Border/divider color - more visible
    static let severanceBorder = Color(hex: "#3D4752")
    /// Error/destructive red
    static let severanceRed = Color(hex: "#FF7070")
    /// Soft background for AI messages - distinct from user
    static let severanceAIBubble = Color(hex: "#141A20")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        // swiftlint:disable:next identifier_name
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct AppThemeImpl: AppTheme {
    let background: Color
    let foreground: Color
    let textPrimary: Color
    let textSecondary: Color
    let accent: Color
    let error: Color
    let success: Color
    let fill: Color
    let iconTint: Color
    let shadow: Color

    static var current: AppThemeImpl {
        let isDark = UITraitCollection.current.userInterfaceStyle == .dark

        return isDark ? dark : light
    }

    static let light = AppThemeImpl(
        background: .cosmicLatte,
        foreground: .gunmetal,
        textPrimary: .gunmetal,
        textSecondary: .americanSilver,
        accent: .orange,
        error: .darkPastelRed,
        success: .emeraldedGreen,
        fill: .papayaWhip,
        iconTint: .orange,
        shadow: .americanSilver.opacity(0.3)
    )

    static let dark = AppThemeImpl(
        background: .gunmetal,
        foreground: .brightSnow,
        textPrimary: .brightSnow,
        textSecondary: .americanSilver,
        accent: .maximumYellow,
        error: .darkPastelRed,
        success: .inchworm,
        fill: .antiqueWhite.opacity(0.1),
        iconTint: .maximumYellow,
        shadow: .black.opacity(0.6)
    )
}

public protocol AppTheme
where Self: Sendable {
    var background: Color { get }
    var foreground: Color { get }
    var textPrimary: Color { get }
    var textSecondary: Color { get }
    var accent: Color { get }
    var error: Color { get }
    var success: Color { get }
    var fill: Color { get }
    var iconTint: Color { get }
    var shadow: Color { get }
}

struct AppThemeKey: EnvironmentKey {
    static let defaultValue: AppTheme = AppThemeImpl.current
}

public extension EnvironmentValues {
    var appTheme: AppTheme {
        get {
            self[AppThemeKey.self]
        } set {
            self[AppThemeKey.self] = newValue
        }
    }
}
