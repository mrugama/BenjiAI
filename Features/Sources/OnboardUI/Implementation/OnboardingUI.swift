import SwiftUI
import SharedUIKit
import ClipperCoreKit

struct OnboardingUI: View {
    @Binding var pageState: PageState
    let onboardingService: OnboardingService

    @State private var currentPage = 0
    @State private var showBackground = false
    @AppStorage("BenjiLLM") private var savedLlmId: String = "mlx-community/Qwen2.5-1.5B-Instruct-4bit"
    @Environment(\.clipperAssistant) private var clipperAssistant

    private let totalPages = 5

    var body: some View {
        ZStack {
            // Severance-style background
            Color.severanceBackground
                .ignoresSafeArea()

            // Floating particles
            FloatingParticles()
                .opacity(showBackground ? 0.6 : 0)

            // CRT scanline overlay
            CRTScanlineOverlay()
                .opacity(0.3)

            VStack(spacing: 0) {
                // Top bar with logo
                TopBar()
                    .opacity(showBackground ? 1 : 0)

                // Page content
                TabView(selection: $currentPage) {
                    PrivacyPage()
                        .tag(0)

                    ChooseAIPage(onboardingService: onboardingService)
                        .tag(1)

                    ToolsPage(onboardingService: onboardingService)
                        .tag(2)

                    PermissionsPage(onboardingService: onboardingService)
                        .tag(3)

                    AIExpertPage(onboardingService: onboardingService)
                        .tag(4)
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

        // Set the selected model if one was chosen and persist to AppStorage
        if let selectedModelId = onboardingService.state.selectedModelId {
            savedLlmId = selectedModelId
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
                    .foregroundColor(.severanceGreen)
                    .tracking(4)
            }

            Spacer()

            // Version badge
            Text("v1.0")
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.severanceMuted)
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
            SeveranceProgressIndicator(currentPage: currentPage, totalPages: totalPages)

            // Navigation buttons
            HStack(spacing: 16) {
                // Back button
                if currentPage > 0 {
                    SeveranceButton(title: "BACK", isPrimary: false) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            currentPage -= 1
                        }
                    }
                }

                // Next/Complete button
                SeveranceButton(
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
                Button(action: onComplete) {
                    Text("Skip setup")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.severanceMuted)
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
        onboardingService: OnboardingServiceImpl()
    )
}
