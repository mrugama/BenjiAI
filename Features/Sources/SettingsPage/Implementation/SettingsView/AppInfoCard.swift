import SwiftUI

// MARK: - App Info Card

struct AppInfoCard: View {
    var body: some View {
        HStack(spacing: 16) {
            // App icon
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.severanceGreen.opacity(0.1))
                    .frame(width: 60, height: 60)

                Image(systemName: "brain.head.profile")
                    .font(.system(size: 28))
                    .foregroundColor(.severanceGreen)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Benji AI")
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(.severanceText)

                Text("Version 1.0.0")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.severanceMuted)

                Text("On-device AI Assistant")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.severanceCyan)
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.severanceCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.severanceBorder, lineWidth: 1)
                )
        )
    }
}
