import SwiftUI

/// Public factories for Severance-styled UI elements.
public enum SeveranceUI {
    /// Creates glowing text with the Severance aesthetic.
    public static func glowingText(
        _ text: String,
        font: Font = .system(size: 32, weight: .bold, design: .monospaced),
        color: Color = .severanceGreen,
        glowRadius: CGFloat = 10
    ) -> some View {
        GlowingText(
            text: text,
            font: font,
            color: color,
            glowRadius: glowRadius
        )
    }

    /// Floating particles background.
    public static func floatingParticles() -> some View {
        FloatingParticles()
    }

    /// CRT scanline overlay.
    public static func crtScanlineOverlay() -> some View {
        CRTScanlineOverlay()
    }

    /// Severance-styled progress indicator.
    public static func progressIndicator(currentPage: Int, totalPages: Int) -> some View {
        SeveranceProgressIndicator(currentPage: currentPage, totalPages: totalPages)
    }

    /// Severance-styled button.
    public static func button(
        title: String,
        isPrimary: Bool = true,
        isEnabled: Bool = true,
        action: @escaping @MainActor () -> Void
    ) -> some View {
        SeveranceButton(
            title: title,
            isPrimary: isPrimary,
            isEnabled: isEnabled,
            action: action
        )
    }
}
