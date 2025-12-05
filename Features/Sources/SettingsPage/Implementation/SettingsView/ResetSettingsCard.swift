import SwiftUI

// MARK: - Reset Settings Card

struct ResetSettingsCard: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.severanceRed.opacity(0.1))
                        .frame(width: 44, height: 44)

                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 20))
                        .foregroundColor(.severanceRed)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Reset Onboarding")
                        .font(.system(size: 14, weight: .semibold, design: .monospaced))
                        .foregroundColor(.severanceText)

                    Text("Show setup wizard again")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.severanceMuted)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.severanceMuted)
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
        .buttonStyle(PlainButtonStyle())
    }
}
