import SwiftUI
import SharedUIKit
import UserPreferences

// MARK: - Re-export UserPreferences types for backward compatibility

/// Type alias for backward compatibility - use UserPreferencesState directly
public typealias OnboardingState = UserPreferencesState

/// Type alias for backward compatibility - use UserPreferencesService directly
public typealias OnboardingService = UserPreferencesService

/// Type alias for backward compatibility - use UserPreferencesServiceImpl directly
public typealias OnboardingServiceImpl = UserPreferencesServiceImpl

// MARK: - Environment Key (backward compatibility)

private struct OnboardingServiceKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: UserPreferencesService? = nil
}

public extension EnvironmentValues {
    var onboardingService: UserPreferencesService? {
        get { self[OnboardingServiceKey.self] }
        set { self[OnboardingServiceKey.self] = newValue }
    }
}

// MARK: - Page Service

/// A service that provides the onboarding view for users.
@MainActor
public struct OnboardingUIService {
    /// Returns the onboarding view with the specified page state binding.
    public static func pageView(
        _ pageState: Binding<PageState>,
        onboardingService: UserPreferencesService
    ) -> some View {
        OnboardingUI(pageState: pageState, onboardingService: onboardingService)
    }
}
