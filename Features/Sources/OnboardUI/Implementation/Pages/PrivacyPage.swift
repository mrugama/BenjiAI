import SwiftUI

struct PrivacyPage: View {
    @State private var showContent = false

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 32) {
                    Spacer(minLength: 20) // Flexible spacer with minimum height

                    // Icon
                    ZStack {
                        Circle()
                            .fill(Color.severanceGreen.opacity(0.1))
                            .frame(width: 140, height: 140)

                        Circle()
                            .stroke(Color.severanceGreen.opacity(0.3), lineWidth: 2)
                            .frame(width: 140, height: 140)

                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(Color.severanceGreen)
                            .shadow(color: .severanceGreen.opacity(0.5), radius: 20)
                    }
                    .opacity(showContent ? 1 : 0)
                    .scaleEffect(showContent ? 1 : 0.5)

                    VStack(spacing: 16) {
                        GlowingText(
                            text: "PRIVACY FIRST",
                            font: .system(size: 28, weight: .bold, design: .monospaced),
                            glowRadius: 8
                        )

                        Text("Your data never leaves your device")
                            .font(.system(size: 16, design: .monospaced))
                            .foregroundStyle(Color.severanceMuted)
                            .opacity(showContent ? 1 : 0)
                            .multilineTextAlignment(.center)
                    }

                    // Privacy features
                    VStack(spacing: 16) {
                        PrivacyFeatureRow(
                            icon: "network.slash",
                            title: "No Cloud Processing",
                            description: "AI runs entirely on your device"
                        )
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)

                        PrivacyFeatureRow(
                            icon: "eye.slash.fill",
                            title: "No Tracking",
                            description: "Zero analytics or behavior tracking"
                        )
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)

                        PrivacyFeatureRow(
                            icon: "xmark.shield.fill",
                            title: "No Cookies",
                            description: "Completely anonymous usage"
                        )
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)

                        PrivacyFeatureRow(
                            icon: "hand.raised.fill",
                            title: "No Data Collection",
                            description: "Your conversations stay private"
                        )
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                    }
                    .padding(.horizontal, 24)

                    Spacer(minLength: 20) // Flexible spacer

                    // Anonymous badge
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(Color.severanceGreen)
                        Text("100% ANONYMOUS")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color.severanceGreen)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .stroke(Color.severanceGreen.opacity(0.5), lineWidth: 1)
                    )
                    .opacity(showContent ? 1 : 0)

                    // Spacer for bottom padding to avoid cut-off
                    Color.clear.frame(height: 40)
                }
                .frame(minHeight: geometry.size.height) // Ensure full height
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                showContent = true
            }
        }
    }
}

struct PrivacyFeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(Color.severanceGreen)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color.severanceText)

                Text(description)
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundStyle(Color.severanceMuted)
                    .fixedSize(horizontal: false, vertical: true) // Allow text to wrap
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.severanceCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.severanceBorder, lineWidth: 1)
                )
        )
    }
}
