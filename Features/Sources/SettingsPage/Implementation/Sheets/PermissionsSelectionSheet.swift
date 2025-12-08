import SwiftUI
import UserPreferences

// MARK: - Permissions Selection Sheet

struct PermissionsSelectionSheet: View {
    let preferencesService: UserPreferencesService
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
                        WarningBanner.permissionsInfo

                        ForEach(PermissionType.allCases) { permission in
                            PreferenceToggleRow(
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
            grantedPermissions = preferencesService.state.grantedPermissions
        }
    }

    private func togglePermission(_ permission: PermissionType) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if grantedPermissions.contains(permission) {
                grantedPermissions.remove(permission)
            } else {
                grantedPermissions.insert(permission)
            }
            preferencesService.togglePermission(permission)
        }
    }
}
