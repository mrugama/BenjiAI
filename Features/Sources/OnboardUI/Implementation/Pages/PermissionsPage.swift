import SwiftUI
import SharedUIKit
import UserPreferences

struct PermissionsPage: View {
    let onboardingService: UserPreferencesService
    @State private var showContent = false
    @State private var grantedPermissions: Set<PermissionType> = []

    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 12) {
                SeveranceUI.glowingText(
                    "TRAIN ON YOUR TERMS",
                    font: .system(size: 22, weight: .bold, design: .monospaced),
                    glowRadius: 6
                )

                Text("Grant access to enhance your AI experience")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundStyle(Color.severanceMuted)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 20)
            .opacity(showContent ? 1 : 0)

            // Permission notice
            WarningBanner.permissionsNotice
                .padding(.horizontal, 24)
                .opacity(showContent ? 1 : 0)

            // Permissions list
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(PermissionType.allCases) { permission in
                        PreferenceToggleRow(
                            permission: permission,
                            isGranted: grantedPermissions.contains(permission)
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                togglePermission(permission)
                            }
                        }
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 15)
                    }
                }
                .padding(.horizontal, 24)
            }

            // Summary
            VStack(spacing: 8) {
                let total = PermissionType.allCases.count
                Text("\(grantedPermissions.count) of \(total) permissions granted")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(Color.severanceMuted)

                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.severanceBorder)
                            .frame(height: 4)

                        let progress = CGFloat(grantedPermissions.count) / CGFloat(total)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.severanceGreen)
                            .frame(width: geometry.size.width * progress, height: 4)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: grantedPermissions.count)
                    }
                }
                .frame(height: 4)
                .padding(.horizontal, 24)
            }
            .opacity(showContent ? 1 : 0)
            .padding(.bottom, 20)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                showContent = true
            }
        }
    }

    private func togglePermission(_ permission: PermissionType) {
        if grantedPermissions.contains(permission) {
            grantedPermissions.remove(permission)
        } else {
            grantedPermissions.insert(permission)
        }
        onboardingService.togglePermission(permission)
    }
}
