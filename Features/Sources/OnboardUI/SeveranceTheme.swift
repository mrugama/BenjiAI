import SwiftUI

// MARK: - Severance Color Palette

/// Colors inspired by the Severance TV show aesthetic
public extension Color {
    /// Deep dark blue-black background
    static let severanceBackground = Color(hex: "#0A0E14")
    /// Terminal green glow
    static let severanceGreen = Color(hex: "#00FF9C")
    /// Soft cyan accent
    static let severanceCyan = Color(hex: "#00D4AA")
    /// Muted teal
    static let severanceTeal = Color(hex: "#1A3A3A")
    /// Amber warning/highlight
    static let severanceAmber = Color(hex: "#FFB000")
    /// Soft white text
    static let severanceText = Color(hex: "#E8E8E8")
    /// Muted gray text
    static let severanceMuted = Color(hex: "#6B7280")
    /// Card background
    static let severanceCard = Color(hex: "#111820")
    /// Border/divider color
    static let severanceBorder = Color(hex: "#1F2937")
    /// Error/destructive red
    static let severanceRed = Color(hex: "#FF4444")
}

// MARK: - CRT Scanline Effect

struct CRTScanlineOverlay: View {
    @State private var offset: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Static scanlines
                Canvas { context, size in
                    for yPos in stride(from: 0, to: size.height, by: 3) {
                        let rect = CGRect(x: 0, y: yPos, width: size.width, height: 1)
                        context.fill(Path(rect), with: .color(.black.opacity(0.15)))
                    }
                }

                // Animated scan line
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                .clear,
                                Color.severanceGreen.opacity(0.03),
                                .clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 100)
                    .offset(y: offset - geometry.size.height / 2)
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                offset = UIScreen.main.bounds.height + 100
            }
        }
    }
}

// MARK: - Glowing Text Effect

struct GlowingText: View {
    let text: String
    var font: Font = .system(size: 32, weight: .bold, design: .monospaced)
    var color: Color = .severanceGreen
    var glowRadius: CGFloat = 10

    var body: some View {
        ZStack {
            // Glow layer
            Text(text)
                .font(font)
                .foregroundStyle(color)
                .blur(radius: glowRadius)

            // Main text
            Text(text)
                .font(font)
                .foregroundStyle(color)
        }
    }
}

// MARK: - Terminal Text Animation

struct TerminalText: View {
    let text: String
    var font: Font = .system(size: 16, weight: .regular, design: .monospaced)
    var color: Color = .severanceText
    var typingSpeed: Double = 0.03

    @State private var displayedText = ""
    @State private var showCursor = true

    var body: some View {
        HStack(spacing: 0) {
            Text(displayedText)
                .font(font)
                .foregroundStyle(color)

            if displayedText.count < text.count || showCursor {
                Text("█")
                    .font(font)
                    .foregroundStyle(color)
                    .opacity(showCursor ? 1 : 0)
            }
        }
        .onAppear {
            animateText()
            animateCursor()
        }
    }

    private func animateText() {
        displayedText = ""
        Task { @MainActor in
            for (index, character) in text.enumerated() {
                if index > 0 {
                    try? await Task.sleep(for: .seconds(typingSpeed))
                }
                displayedText += String(character)
            }
        }
    }

    private func animateCursor() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            Task { @MainActor in
                showCursor.toggle()
            }
        }
    }
}

// MARK: - Severance Card

struct SeveranceCard<Content: View>: View {
    let content: Content
    var isSelected: Bool = false
    var onTap: (() -> Void)?

    init(isSelected: Bool = false, onTap: (() -> Void)? = nil, @ViewBuilder content: () -> Content) {
        self.isSelected = isSelected
        self.onTap = onTap
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.severanceCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                isSelected ? Color.severanceGreen : Color.severanceBorder,
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .shadow(color: isSelected ? Color.severanceGreen.opacity(0.3) : .clear, radius: 10)
            .onTapGesture {
                onTap?()
            }
    }
}

// MARK: - Severance Button

struct SeveranceButton: View {
    let title: String
    var isPrimary: Bool = true
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                .foregroundStyle(isPrimary ? Color.severanceBackground : Color.severanceGreen)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isPrimary ? Color.severanceGreen : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.severanceGreen, lineWidth: isPrimary ? 0 : 2)
                        )
                )
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.5)
    }
}

// MARK: - Progress Indicator

struct SeveranceProgressIndicator: View {
    let currentPage: Int
    let totalPages: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? Color.severanceGreen : Color.severanceBorder)
                    .frame(width: index == currentPage ? 32 : 8, height: 4)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
            }
        }
        .padding(.vertical, 20)
    }
}

// MARK: - Floating Particles Background

struct FloatingParticles: View {
    @State private var particles: [Particle] = []

    struct Particle: Identifiable {
        let id = UUID()
        var positionX: CGFloat
        var positionY: CGFloat
        var size: CGFloat
        var opacity: Double
        var speed: Double
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(Color.severanceGreen)
                        .frame(width: particle.size, height: particle.size)
                        .position(x: particle.positionX, y: particle.positionY)
                        .opacity(particle.opacity)
                        .blur(radius: 1)
                }
            }
            .onAppear {
                createParticles(in: geometry.size)
                animateParticles(in: geometry.size)
            }
        }
        .allowsHitTesting(false)
    }

    private func createParticles(in size: CGSize) {
        particles = (0..<30).map { _ in
            Particle(
                positionX: CGFloat.random(in: 0...size.width),
                positionY: CGFloat.random(in: 0...size.height),
                size: CGFloat.random(in: 1...3),
                opacity: Double.random(in: 0.1...0.4),
                speed: Double.random(in: 0.5...2)
            )
        }
    }

    private func animateParticles(in size: CGSize) {
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            Task { @MainActor in
                for idx in particles.indices {
                    particles[idx].positionY -= CGFloat(particles[idx].speed)
                    if particles[idx].positionY < -10 {
                        particles[idx].positionY = size.height + 10
                        particles[idx].positionX = CGFloat.random(in: 0...size.width)
                    }
                }
            }
        }
    }
}

// MARK: - Lumon Logo Animation

struct LumonStyleLogo: View {
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Outer ring
            Circle()
                .stroke(Color.severanceGreen.opacity(0.3), lineWidth: 2)
                .frame(width: 120, height: 120)

            // Inner rotating elements
            ForEach(0..<4, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.severanceGreen)
                    .frame(width: 4, height: 30)
                    .offset(y: -35)
                    .rotationEffect(.degrees(Double(index) * 90 + rotation))
            }

            // Center dot
            Circle()
                .fill(Color.severanceGreen)
                .frame(width: 16, height: 16)
                .shadow(color: Color.severanceGreen.opacity(0.8), radius: 10)
                .scaleEffect(scale)
        }
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.easeInOut(duration: 2).repeatForever()) {
                scale = 1.2
            }
        }
    }
}

// MARK: - Page Transition

struct SeverancePageTransition: ViewModifier {
    let isActive: Bool

    func body(content: Content) -> some View {
        content
            .opacity(isActive ? 1 : 0)
            .offset(x: isActive ? 0 : 50)
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isActive)
    }
}

extension View {
    func severanceTransition(isActive: Bool) -> some View {
        modifier(SeverancePageTransition(isActive: isActive))
    }
}

// MARK: - Toggle Style

struct SeveranceToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            RoundedRectangle(cornerRadius: 16)
                .fill(configuration.isOn ? Color.severanceGreen : Color.severanceBorder)
                .frame(width: 50, height: 28)
                .overlay(
                    Circle()
                        .fill(Color.severanceText)
                        .frame(width: 24, height: 24)
                        .offset(x: configuration.isOn ? 10 : -10)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isOn)
                )
                .onTapGesture {
                    configuration.isOn.toggle()
                }
        }
    }
}
