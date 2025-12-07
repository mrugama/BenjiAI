import SwiftUI

#if canImport(ActivityKit)
import ActivityKit
#endif

// MARK: - Live Activity Attributes (must be public for ActivityKit)

public struct LLMLiveActivityAttributes: Sendable {
    public struct ContentState: Codable, Hashable, Sendable {
        public var progress: Double
        public var llmName: String

        public init(progress: Double, llmName: String) {
            self.progress = progress
            self.llmName = llmName
        }
    }

    public init() {}
}

#if canImport(ActivityKit)
extension LLMLiveActivityAttributes: ActivityAttributes {}
#endif

// MARK: - Permission Status

public enum LiveActivityPermissionStatus: Sendable {
    case authorized
    case denied
    case disabled
}

// MARK: - Public Factories

public enum BGLiveActivities {
    /// Starts or updates the live activity with the given progress.
    @MainActor
    public static func startOrUpdate(llmName: String, progress: Double) async {
        await LLMLiveActivityControllerImpl.startOrUpdate(llmName: llmName, progress: progress)
    }

    /// Ends all active live activities.
    @MainActor
    public static func endAll() async {
        await LLMLiveActivityControllerImpl.endAll()
    }

    /// Returns the current Live Activity permission status.
    public static func currentPermissionStatus() async -> LiveActivityPermissionStatus {
        await LiveActivityPermissionImpl.currentStatus()
    }

    /// Requests Live Activity permission and returns the resulting status.
    @MainActor
    public static func requestPermission() async -> LiveActivityPermissionStatus {
        await LiveActivityPermissionImpl.request()
    }
}
