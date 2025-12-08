import SwiftUI
import UIKit
import BGLiveActivities
import SharedUIKit

struct LiveActivityPermissionPage: View {
    @State private var status: LiveActivityPermissionStatus = .disabled
    @State private var isRequesting = false

    var body: some View {
        VStack(spacing: 24) {
            SeveranceUI.glowingText(
                "LIVE ACTIVITIES",
                font: .system(size: 24, weight: .bold, design: .monospaced),
                glowRadius: 6
            )

            Text("Allow Live Activities to show AI download progress on your Lock Screen.")
                .font(.system(size: 14, design: .monospaced))
                .foregroundStyle(Color.severanceMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)

            statusBadge

            SeveranceUI.button(
                title: buttonTitle,
                isPrimary: true,
                isEnabled: !isRequesting
            ) {
                Task {
                    await requestPermission()
                }
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 24)
        .onAppear {
            Task {
                await loadStatus()
            }
        }
    }

    private var buttonTitle: String {
        switch status {
        case .authorized:
            return "ENABLED"
        case .denied:
            return "OPEN SETTINGS"
        case .disabled:
            return "ENABLE LIVE ACTIVITIES"
        }
    }

    @ViewBuilder
    private var statusBadge: some View {
        switch status {
        case .authorized:
            label(text: "Live Activities enabled", color: .severanceGreen, systemImage: "checkmark.circle.fill")
        case .denied:
            label(
                text: "Live Activities disabled in Settings",
                color: .severanceAmber,
                systemImage: "exclamationmark.triangle.fill")
        case .disabled:
            label(
                text: "Live Activities not yet enabled",
                color: .severanceMuted,
                systemImage: "clock.badge.questionmark")
        }
    }

    private func label(text: String, color: Color, systemImage: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage)
                .foregroundStyle(color)
            Text(text)
                .font(.system(size: 13, design: .monospaced))
                .foregroundStyle(color)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.severanceCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.severanceBorder, lineWidth: 1)
                )
        )
    }

    private func loadStatus() async {
        status = await BGLiveActivities.currentPermissionStatus()
    }

    private func requestPermission() async {
        isRequesting = true
        defer { isRequesting = false }
        let result = await BGLiveActivities.requestPermission()
        if result == .denied, let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            await MainActor.run {
                UIApplication.shared.open(settingsURL)
            }
        }
        await loadStatus()
    }
}

#Preview {
    LiveActivityPermissionPage()
        .preferredColorScheme(.dark)
        .background(Color.severanceBackground)
}
