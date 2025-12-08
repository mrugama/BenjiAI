import ClipperCoreKit
import UserPreferences
import SharedUIKit
import SwiftUI

struct SettingsView: View {
    @Binding var pageState: PageState
    let settingsService: SettingsService

    @Environment(\.clipperAssistant) private var clipperAssistant
    @Environment(\.dismiss) private var dismiss

    @State private var showModelSheet = false
    @State private var showToolsSheet = false
    @State private var showPermissionsSheet = false
    @State private var showPersonaSheet = false
    @State private var showDownloadButton = false
    @State private var showResetAlert = false

    private var preferencesService: UserPreferencesService {
        settingsService.preferencesService
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Severance background
                Color.severanceBackground
                    .ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        // App Info Section
                        SettingsSection(title: "APP INFO") {
                            AppInfoCard()
                        }

                        // AI Model Section
                        SettingsSection(title: "AI MODEL") {
                            ModelSettingsCard(
                                clipperAssistant: clipperAssistant,
                                showDownloadButton: $showDownloadButton
                            ) {
                                showModelSheet = true
                            }
                        }

                        // Tools Section
                        SettingsSection(title: "TOOLS") {
                            ToolsSettingsCard(
                                enabledCount: preferencesService.state.enabledTools.count
                            ) {
                                showToolsSheet = true
                            }
                        }

                        // Permissions Section
                        SettingsSection(title: "PERMISSIONS") {
                            PermissionsSettingsCard(
                                grantedCount: preferencesService.state.grantedPermissions.count
                            ) {
                                showPermissionsSheet = true
                            }
                        }

                        // Live Activities Section
                        SettingsSection(title: "LIVE ACTIVITIES") {
                            LiveActivitySettingsCard {
                                await settingsService.requestLiveActivitiesAuthorization()
                            }
                        }

                        // AI Persona Section
                        SettingsSection(title: "AI PERSONA") {
                            PersonaSettingsCard(
                                selectedPersona: preferencesService.state.selectedPersona
                            ) {
                                showPersonaSheet = true
                            }
                        }

                        // Reset Section
                        SettingsSection(title: "ADVANCED") {
                            ResetSettingsCard {
                                showResetAlert = true
                            }
                        }

                        // Download button if needed
                        if showDownloadButton {
                            DownloadModelButton(
                                clipperAssistant: clipperAssistant,
                                pageState: $pageState
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("SETTINGS")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.severanceGreen)
                        .tracking(2)
                }

                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        pageState = .home
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundStyle(Color.severanceGreen)
                    }
                }
            }
            .toolbarBackground(Color.severanceBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showModelSheet) {
            ModelSelectionSheet(
                clipperAssistant: clipperAssistant,
                preferencesService: preferencesService,
                showDownloadButton: $showDownloadButton
            )
        }
        .sheet(isPresented: $showToolsSheet) {
            ToolsSelectionSheet(preferencesService: preferencesService)
        }
        .sheet(isPresented: $showPermissionsSheet) {
            PermissionsSelectionSheet(preferencesService: preferencesService)
        }
        .sheet(isPresented: $showPersonaSheet) {
            PersonaSelectionSheet(preferencesService: preferencesService)
        }
        .alert("Reset Onboarding", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                preferencesService.resetOnboarding()
                pageState = .onboarding
            }
        } message: {
            Text("This will show the onboarding flow again on next launch.")
        }
        .task {
            await checkModelStatus()
        }
    }

    private func checkModelStatus() async {
        if clipperAssistant.loadedLLM == nil {
            showDownloadButton = true
        } else if let loadedLLM = clipperAssistant.loadedLLM,
                  await loadedLLM.configuration.name != clipperAssistant.llm {
            showDownloadButton = true
        }
    }
}
