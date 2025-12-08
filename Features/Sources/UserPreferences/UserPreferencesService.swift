import SwiftUI
import EventKit
import Contacts
import CoreLocation
import MediaPlayer
import Photos
import AVFoundation

// MARK: - User Preferences State

/// Represents the user's preferences - persisted via UserDefaults
@MainActor
@Observable
public final class UserPreferencesState {
    /// Selected AI model ID
    public var selectedModelId: String? {
        didSet { persistModelId() }
    }

    /// Selected tool IDs that the user wants to enable
    public var enabledTools: Set<String> {
        didSet { persistEnabledTools() }
    }

    /// Granted permissions
    public var grantedPermissions: Set<PermissionType> {
        didSet { persistGrantedPermissions() }
    }

    /// Selected AI persona/expert type
    public var selectedPersona: AIPersona {
        didSet { persistSelectedPersona() }
    }

    /// Whether the user has completed onboarding
    public var hasCompletedOnboarding: Bool {
        didSet { persistHasCompletedOnboarding() }
    }

    // MARK: - Storage Keys
    private enum StorageKeys {
        static let modelId = "BenjiLLM"
        static let enabledTools = "BenjiEnabledTools"
        static let grantedPermissions = "BenjiGrantedPermissions"
        static let selectedPersona = "BenjiSelectedPersona"
        static let hasCompletedOnboarding = "BenjiHasCompletedOnboarding"
        static let isFirstLaunch = "isFirstLaunch"
    }

    // MARK: - Default Values
    public static let defaultModelId = "mlx-community/Qwen2.5-1.5B-Instruct-4bit"

    public init() {
        // Load persisted values from UserDefaults
        let defaults = UserDefaults.standard

        self.selectedModelId = defaults.string(forKey: StorageKeys.modelId) ?? Self.defaultModelId
        self.enabledTools = Self.loadSet(forKey: StorageKeys.enabledTools) ?? ToolSelectionInfo.defaultEnabledToolIds
        self.grantedPermissions = Self.loadPermissions(forKey: StorageKeys.grantedPermissions)
        self.selectedPersona = Self.loadPersona(forKey: StorageKeys.selectedPersona)
        self.hasCompletedOnboarding = defaults.bool(forKey: StorageKeys.hasCompletedOnboarding)
    }

    // MARK: - Persistence Helpers

    private func persistModelId() {
        UserDefaults.standard.set(selectedModelId, forKey: StorageKeys.modelId)
    }

    private func persistEnabledTools() {
        Self.saveSet(enabledTools, forKey: StorageKeys.enabledTools)
    }

    private func persistGrantedPermissions() {
        let rawValues = grantedPermissions.map { $0.rawValue }
        Self.saveSet(Set(rawValues), forKey: StorageKeys.grantedPermissions)
    }

    private func persistSelectedPersona() {
        UserDefaults.standard.set(selectedPersona.rawValue, forKey: StorageKeys.selectedPersona)
    }

    private func persistHasCompletedOnboarding() {
        UserDefaults.standard.set(hasCompletedOnboarding, forKey: StorageKeys.hasCompletedOnboarding)
        // Also update isFirstLaunch for backward compatibility
        UserDefaults.standard.set(!hasCompletedOnboarding, forKey: StorageKeys.isFirstLaunch)
    }

    private static func saveSet(_ set: Set<String>, forKey key: String) {
        if let data = try? JSONEncoder().encode(Array(set)) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private static func loadSet(forKey key: String) -> Set<String>? {
        guard let data = UserDefaults.standard.data(forKey: key),
              let array = try? JSONDecoder().decode([String].self, from: data) else {
            return nil
        }
        return Set(array)
    }

    private static func loadPermissions(forKey key: String) -> Set<PermissionType> {
        guard let stringSet = loadSet(forKey: key) else { return [] }
        return Set(stringSet.compactMap { PermissionType(rawValue: $0) })
    }

    private static func loadPersona(forKey key: String) -> AIPersona {
        guard let rawValue = UserDefaults.standard.string(forKey: key),
              let persona = AIPersona(rawValue: rawValue) else {
            return .generic
        }
        return persona
    }
}

// MARK: - User Preferences Service Protocol

/// Protocol for user preferences service - MainActor isolated for UI state management
@MainActor
public protocol UserPreferencesService: AnyObject {
    var state: UserPreferencesState { get }
    func updateSelectedModel(_ modelId: String?)
    func toggleTool(_ toolId: String)
    func enableTool(_ toolId: String)
    func disableTool(_ toolId: String)
    func togglePermission(_ permission: PermissionType)
    func selectPersona(_ persona: AIPersona)
    func completeOnboarding()
    func resetOnboarding()
}

// MARK: - User Preferences Service Implementation

@MainActor
@Observable
public final class UserPreferencesServiceImpl: NSObject, UserPreferencesService, CLLocationManagerDelegate {
    public private(set) var state: UserPreferencesState
    private var locationManager: CLLocationManager?

    public override init() {
        self.state = UserPreferencesState()
        super.init()
    }

    public func updateSelectedModel(_ modelId: String?) {
        state.selectedModelId = modelId
    }

    public func toggleTool(_ toolId: String) {
        if state.enabledTools.contains(toolId) {
            state.enabledTools.remove(toolId)
        } else {
            state.enabledTools.insert(toolId)
        }
    }

    public func enableTool(_ toolId: String) {
        state.enabledTools.insert(toolId)
    }

    public func disableTool(_ toolId: String) {
        state.enabledTools.remove(toolId)
    }

    public func togglePermission(_ permission: PermissionType) {
        if state.grantedPermissions.contains(permission) {
            state.grantedPermissions.remove(permission)
        } else {
            state.grantedPermissions.insert(permission)
            requestSystemPermission(for: permission)
        }
    }

    public func selectPersona(_ persona: AIPersona) {
        state.selectedPersona = persona
    }

    public func completeOnboarding() {
        state.hasCompletedOnboarding = true
    }

    public func resetOnboarding() {
        state.hasCompletedOnboarding = false
    }

    private func requestSystemPermission(for permission: PermissionType) {
        Task {
            switch permission {
            case .calendar:
                let eventStore = EKEventStore()
                if #available(iOS 17.0, macOS 14.0, *) {
                    _ = try? await eventStore.requestFullAccessToEvents()
                } else {
                    _ = try? await eventStore.requestAccess(to: .event)
                }

            case .reminders:
                let eventStore = EKEventStore()
                if #available(iOS 17.0, macOS 14.0, *) {
                    _ = try? await eventStore.requestFullAccessToReminders()
                } else {
                    _ = try? await eventStore.requestAccess(to: .reminder)
                }

            case .contacts:
                let store = CNContactStore()
                _ = try? await store.requestAccess(for: .contacts)

            case .location:
                self.locationManager = CLLocationManager()
                self.locationManager?.delegate = self
                self.locationManager?.requestWhenInUseAuthorization()

            case .music:
                _ = await MPMediaLibrary.requestAuthorization()

            case .photos:
                _ = await PHPhotoLibrary.requestAuthorization(for: .readWrite)

            case .microphone:
                if #available(iOS 17.0, macOS 14.0, *) {
                    AVAudioApplication.requestRecordPermission { _ in }
                } else {
                    AVAudioSession.sharedInstance().requestRecordPermission { _ in }
                }
            }
        }
    }
}

// MARK: - Environment Key

private struct UserPreferencesServiceKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: UserPreferencesService? = nil
}

public extension EnvironmentValues {
    var userPreferencesService: UserPreferencesService? {
        get { self[UserPreferencesServiceKey.self] }
        set { self[UserPreferencesServiceKey.self] = newValue }
    }
}
