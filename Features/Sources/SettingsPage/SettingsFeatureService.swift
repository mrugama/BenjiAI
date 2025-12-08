import SwiftUI
import SharedUIKit
import UserPreferences
import BGLiveActivities

// MARK: - Re-export UserPreferences types for use by SettingsPage consumers
// This allows code using SettingsPage to access preference types

public typealias SettingsState = UserPreferencesState

// MARK: - Settings Service Protocol

/// Protocol defining the settings service interface - MainActor isolated for UI state management
@MainActor
public protocol SettingsService: AnyObject {
    /// Get the current preferences state
    var preferencesState: UserPreferencesState { get }

    /// Get the underlying preferences service
    var preferencesService: UserPreferencesService { get }

    /// Request Live Activities authorization
    func requestLiveActivitiesAuthorization() async -> LiveActivityPermissionStatus
}

// MARK: - Settings Service Implementation

@MainActor
@Observable
public final class SettingsServiceImpl: SettingsService {
    public var preferencesState: UserPreferencesState {
        preferencesService.state
    }

    public let preferencesService: UserPreferencesService

    public init(preferencesService: UserPreferencesService) {
        self.preferencesService = preferencesService
    }

    public func requestLiveActivitiesAuthorization() async -> LiveActivityPermissionStatus {
        await BGLiveActivities.requestPermission()
    }
}

// MARK: - Environment Key

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
        settingsService: SettingsService
    ) -> some View {
        SettingsView(
            pageState: pageState,
            settingsService: settingsService
        )
    }
}
