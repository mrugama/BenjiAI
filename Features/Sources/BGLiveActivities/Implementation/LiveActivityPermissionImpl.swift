import Foundation
import UserNotifications

#if canImport(ActivityKit)
import ActivityKit
#endif

enum LiveActivityPermissionImpl {
    static func currentStatus() async -> LiveActivityPermissionStatus {
        #if canImport(ActivityKit)
        let info = ActivityAuthorizationInfo()
        if info.areActivitiesEnabled {
            return .authorized
        }
        // Fall back to notification authorization as proxy for denial
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        return settings.authorizationStatus == .denied ? .denied : .disabled
        #else
        return .disabled
        #endif
    }

    @MainActor
    static func request() async -> LiveActivityPermissionStatus {
        let center = UNUserNotificationCenter.current()
        _ = try? await center.requestAuthorization(options: [.alert, .sound, .badge, .provisional])
        return await currentStatus()
    }
}
