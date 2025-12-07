import SwiftUI
import SharedUIKit
import OnboardUI
import BGLiveActivities

// MARK: - Settings Service Protocol

/// Protocol defining the settings service interface - MainActor isolated for UI state management
@MainActor
public protocol SettingsService: AnyObject {
    /// Get the current onboarding state
    var onboardingState: OnboardingState { get }

    /// Update the selected AI model
    func updateSelectedModel(_ modelId: String?)

    /// Toggle a tool on/off
    func toggleTool(_ toolId: String)

    /// Toggle a permission on/off
    func togglePermission(_ permission: PermissionType)

    /// Update the AI persona
    func selectPersona(_ persona: AIPersona)

    /// Request Live Activities authorization
    func requestLiveActivitiesAuthorization() async -> LiveActivityPermissionStatus

    /// Reset onboarding to show again
    func resetOnboarding()
}

// MARK: - Settings Service Implementation

@MainActor
@Observable
public final class SettingsServiceImpl: SettingsService {
    public var onboardingState: OnboardingState {
        onboardingService.state
    }
    private let onboardingService: OnboardingService

    public init(onboardingService: OnboardingService) {
        self.onboardingService = onboardingService
    }

    public func updateSelectedModel(_ modelId: String?) {
        onboardingService.updateSelectedModel(modelId)
    }

    public func toggleTool(_ toolId: String) {
        onboardingService.toggleTool(toolId)
    }

    public func togglePermission(_ permission: PermissionType) {
        onboardingService.togglePermission(permission)
    }

    public func selectPersona(_ persona: AIPersona) {
        onboardingService.selectPersona(persona)
    }

    public func requestLiveActivitiesAuthorization() async -> LiveActivityPermissionStatus {
        await BGLiveActivities.requestPermission()
    }

    public func resetOnboarding() {
        onboardingService.resetOnboarding()
    }
}

// MARK: - Environment Key
// Note: Environment keys don't use actor isolation - SwiftUI handles thread safety

private struct SettingsServiceKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: SettingsService? = nil
}

public extension EnvironmentValues {
    var settingsService: SettingsService? {
        get { self[SettingsServiceKey.self] }
        set { self[SettingsServiceKey.self] = newValue }
    }
}

// MARK: - Page Service

/// A service that provides the settings page view for application configuration.
@MainActor
public struct SettingsPageService {
    /// Returns the settings page view with the specified page state binding.
    public static func pageView(
        _ pageState: Binding<PageState>,
        settingsService: SettingsService,
        onboardingService: OnboardingService
    ) -> some View {
        SettingsView(
            pageState: pageState,
            settingsService: settingsService,
            onboardingService: onboardingService
        )
    }
}
