import OnboardUI
import SwiftUI

// MARK: - Persona Settings Card

struct PersonaSettingsCard: View {
    let selectedPersona: AIPersona
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.severanceTeal)
                        .frame(width: 44, height: 44)

                    Image(systemName: selectedPersona.icon)
                        .font(.system(size: 20))
                        .foregroundColor(.paleViolet)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("AI Persona")
                        .font(.system(size: 14, weight: .semibold, design: .monospaced))
                        .foregroundColor(.severanceText)

                    Text(selectedPersona.rawValue)
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
