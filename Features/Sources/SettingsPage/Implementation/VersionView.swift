import SwiftUI

struct VersionView: View {
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }

    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }

    var body: some View {
        VStack(spacing: 4) {
            Text("App Version: \(appVersion)")
            Text("Build Number: \(buildNumber)")
        }
        .font(.footnote)
        .foregroundColor(.secondary)
    }
}
