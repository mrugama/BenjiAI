import SwiftUI
import BGLiveActivities
import SharedUIKit

struct LiveActivitySettingsCard: View {
    @State private var status: LiveActivityPermissionStatus = .disabled
    let onRequest: () async -> LiveActivityPermissionStatus

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Live Activities")
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color.severanceText)
                Spacer()
                statusLabel
            }

            Text("Show download progress on your Lock Screen.")
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(Color.severanceMuted)

            SeveranceUI.button(
                title: buttonTitle,
                isPrimary: status != .authorized
            ) {
                Task {
                    status = await onRequest()
                }
            }
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
        .task {
            await refreshStatus()
        }
    }

    private var buttonTitle: String {
        status == .authorized ? "ENABLED" : "ENABLE"
    }

    @ViewBuilder
    private var statusLabel: some View {
        switch status {
        case .authorized:
            label(text: "Enabled", color: .severanceGreen, systemImage: "checkmark.circle.fill")
        case .denied:
            label(text: "Denied", color: .severanceAmber, systemImage: "exclamationmark.triangle.fill")
        case .disabled:
            label(text: "Off", color: .severanceMuted, systemImage: "clock.badge.questionmark")
        }
    }

    private func label(text: String, color: Color, systemImage: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: systemImage)
                .font(.system(size: 12))
                .foregroundStyle(color)
            Text(text)
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(color)
        }
    }

    private func refreshStatus() async {
        status = await BGLiveActivities.currentPermissionStatus()
    }
}
