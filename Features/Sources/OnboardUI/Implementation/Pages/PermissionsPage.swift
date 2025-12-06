import SwiftUI

struct PermissionsPage: View {
    let onboardingService: OnboardingService
    @State private var showContent = false
    @State private var grantedPermissions: Set<PermissionType> = []

    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 12) {
                GlowingText(
                    text: "TRAIN ON YOUR TERMS",
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
            HStack(spacing: 12) {
                Image(systemName: "shield.checkered")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.severanceAmber)

                Text("All permissions are optional and can be changed in Settings")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(Color.severanceMuted)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.severanceAmber.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.severanceAmber.opacity(0.3), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 24)
            .opacity(showContent ? 1 : 0)

            // Permissions list
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(PermissionType.allCases) { permission in
                        PermissionRow(
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

struct PermissionRow: View {
    let permission: PermissionType
    let isGranted: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isGranted ? Color.severanceGreen.opacity(0.15) : Color.severanceTeal)
                        .frame(width: 44, height: 44)

                    Image(systemName: permission.icon)
                        .font(.system(size: 20))
                        .foregroundStyle(isGranted ? Color.severanceGreen : Color.severanceMuted)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(permission.rawValue)
                        .font(.system(size: 15, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Color.severanceText)

                    Text(permission.description)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(Color.severanceMuted)
                }

                Spacer()

                // Toggle indicator
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(isGranted ? Color.severanceGreen : Color.severanceBorder)
                        .frame(width: 50, height: 28)

                    Circle()
                        .fill(Color.severanceText)
                        .frame(width: 22, height: 22)
                        .offset(x: isGranted ? 10 : -10)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.severanceCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isGranted ? Color.severanceGreen.opacity(0.5) : Color.severanceBorder,
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
