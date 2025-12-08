import SwiftUI
import SharedUIKit
import ClipperCoreKit
import UserPreferences

struct OnboardingUI: View {
    @Binding var pageState: PageState
    let onboardingService: UserPreferencesService

    @State private var currentPage = 0
    @State private var showBackground = false
    @Environment(\.clipperAssistant) private var clipperAssistant

    private let totalPages = 6

    var body: some View {
        ZStack {
            // Severance-style background
            Color.severanceBackground
                .ignoresSafeArea()

            // Floating particles
            SeveranceUI.floatingParticles()
                .opacity(showBackground ? 0.6 : 0)

            // CRT scanline overlay
            SeveranceUI.crtScanlineOverlay()
                .opacity(0.3)

            VStack(spacing: 0) {
                // Top bar with logo
                TopBar()
                    .opacity(showBackground ? 1 : 0)

                // Page content
                TabView(selection: $currentPage) {
                    PrivacyPage()
                        .tag(0)

                    LiveActivityPermissionPage()
                        .tag(1)

                    ChooseAIPage(onboardingService: onboardingService)
                        .tag(2)

                    ToolsPage(onboardingService: onboardingService)
                        .tag(3)

                    PermissionsPage(onboardingService: onboardingService)
                        .tag(4)

                    AIExpertPage(onboardingService: onboardingService)
                        .tag(5)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentPage)

                // Bottom navigation
                BottomNavigation(
                    currentPage: $currentPage,
                    totalPages: totalPages,
                    onComplete: completeOnboarding
                )
                .opacity(showBackground ? 1 : 0)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                showBackground = true
            }
        }
    }

    private func completeOnboarding() {
        onboardingService.completeOnboarding()

        // Set the system prompt based on selected persona
        clipperAssistant.setSystemPrompt(onboardingService.state.selectedPersona.systemPrompt)

        // Set the selected model if one was chosen
        if let selectedModelId = onboardingService.state.selectedModelId {
            clipperAssistant.selectedModel(selectedModelId)
        }

        // Enable/disable tools based on user selection
        Task {
            for toolId in onboardingService.state.enabledTools {
                await clipperAssistant.enableTool(toolId)
            }
        }

        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            pageState = .loading
        }
    }
}

// MARK: - Top Bar

private struct TopBar: View {
    var body: some View {
        HStack {
            // Logo
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .stroke(Color.severanceGreen.opacity(0.5), lineWidth: 1)
                        .frame(width: 32, height: 32)

                    Circle()
                        .fill(Color.severanceGreen)
                        .frame(width: 8, height: 8)
                        .shadow(color: .severanceGreen.opacity(0.8), radius: 4)
                }

                Text("BENJI")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color.severanceGreen)
                    .tracking(4)
            }

            Spacer()

            // Version badge
            Text("v1.0")
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(Color.severanceMuted)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .stroke(Color.severanceBorder, lineWidth: 1)
                )
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }
}

// MARK: - Bottom Navigation

private struct BottomNavigation: View {
    @Binding var currentPage: Int
    let totalPages: Int
    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            // Progress indicator
            SeveranceUI.progressIndicator(currentPage: currentPage, totalPages: totalPages)

            // Navigation buttons
            HStack(spacing: 16) {
                // Back button
                if currentPage > 0 {
                    SeveranceUI.button(title: "BACK", isPrimary: false) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            currentPage -= 1
                        }
                    }
                }

                // Next/Complete button
                SeveranceUI.button(
                    title: currentPage == totalPages - 1 ? "GET STARTED" : "NEXT"
                ) {
                    if currentPage == totalPages - 1 {
                        onComplete()
                    } else {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            currentPage += 1
                        }
                    }
                }
            }
            .padding(.horizontal, 24)

            // Skip option (except on last page)
            if currentPage < totalPages - 1 {
                Button {
                    onComplete()
                } label: {
                    Text("Skip setup")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(Color.severanceMuted)
                }
            }
        }
        .padding(.bottom, 32)
    }
}

// MARK: - Preview

#Preview {
    OnboardingUI(
        pageState: .constant(.onboarding),
        onboardingService: UserPreferencesServiceImpl()
    )
}
