import SwiftUI
import OnboardUI

// MARK: - Permissions Selection Sheet

struct PermissionsSelectionSheet: View {
    let onboardingService: OnboardingService
    @Environment(\.dismiss) var dismiss
    @State private var grantedPermissions: Set<PermissionType> = []

    var body: some View {
        NavigationStack {
            ZStack {
                Color.severanceBackground
                    .ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 12) {
                        // Warning
                        HStack(spacing: 12) {
                            Image(systemName: "info.circle.fill")
                                .foregroundStyle(Color.severanceAmber)
                            Text("Permissions are requested when you use related features")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundStyle(Color.severanceMuted)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.severanceAmber.opacity(0.1))
                        )

                        ForEach(PermissionType.allCases) { permission in
                            PermissionSheetRow(
                                permission: permission,
                                isGranted: grantedPermissions.contains(permission)
                            ) {
                                togglePermission(permission)
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("PERMISSIONS")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.severanceGreen)
                        .tracking(2)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundStyle(Color.severanceGreen)
                }
            }
            .toolbarBackground(Color.severanceBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .presentationDetents([.large])
        .presentationBackground(Color.severanceBackground)
        .onAppear {
            grantedPermissions = onboardingService.state.grantedPermissions
        }
    }

    private func togglePermission(_ permission: PermissionType) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if grantedPermissions.contains(permission) {
                grantedPermissions.remove(permission)
            } else {
                grantedPermissions.insert(permission)
            }
            onboardingService.togglePermission(permission)
        }
    }
}

private struct PermissionSheetRow: View {
    let permission: PermissionType
    let isGranted: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 16) {
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
                        .font(.system(size: 14, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Color.severanceText)

                    Text(permission.description)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(Color.severanceMuted)
                }

                Spacer()

                // Toggle
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
