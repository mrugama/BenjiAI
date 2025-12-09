import SwiftUI
import SharedUIKit

/// Placeholder view for unavailable microphone feature
struct MicrophoneUnavailableView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.severanceBackground
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // Icon
                ZStack {
                    Circle()
                        .fill(Color.severanceCard)
                        .frame(width: 120, height: 120)

                    Circle()
                        .stroke(Color.severanceAmber.opacity(0.3), lineWidth: 2)
                        .frame(width: 120, height: 120)

                    Image(systemName: "mic.slash.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(Color.severanceAmber)
                }

                // Text
                VStack(spacing: 12) {
                    Text("VOICE INPUT")
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.severanceText)
                        .tracking(2)

                    Text("Coming Soon")
                        .font(.system(size: 28, weight: .light, design: .monospaced))
                        .foregroundStyle(Color.severanceAmber)

                    Text("Voice input is not available yet.\nWe're working on bringing this feature to you.")
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundStyle(Color.severanceMuted)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }

                Spacer()

                // Dismiss button
                SeveranceUI.button(title: "GOT IT") {
                    dismiss()
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
        .presentationDetents([.medium])
        .presentationBackground(Color.severanceBackground)
    }
}

#Preview {
    MicrophoneUnavailableView()
}
