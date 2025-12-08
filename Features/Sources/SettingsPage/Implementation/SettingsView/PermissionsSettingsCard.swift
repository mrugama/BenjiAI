import UserPreferences
import SwiftUI

// MARK: - Permissions Settings Card

struct PermissionsSettingsCard: View {
    let grantedCount: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.severanceTeal)
                        .frame(width: 44, height: 44)

                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.severanceAmber)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Permissions")
                        .font(.system(size: 14, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Color.severanceText)

                    Text("\(grantedCount) of \(PermissionType.allCases.count) granted")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(Color.severanceMuted)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.severanceMuted)
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
