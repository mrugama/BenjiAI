import Foundation

#if canImport(ActivityKit)
import ActivityKit

enum LLMLiveActivityControllerImpl {
    @MainActor
    static func startOrUpdate(llmName: String, progress: Double) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let clamped = progress.clampedToUnit
        let state = LLMLiveActivityAttributes.ContentState(progress: clamped, llmName: llmName)
        let content = ActivityContent(state: state, staleDate: nil)

        if let activity = Activity<LLMLiveActivityAttributes>.activities.first {
            await activity.update(content)
        } else {
            let attributes = LLMLiveActivityAttributes()
            _ = try? Activity.request(attributes: attributes, content: content, pushType: nil)
        }
    }

    @MainActor
    static func endAll() async {
        for activity in Activity<LLMLiveActivityAttributes>.activities {
            await activity.end(activity.content, dismissalPolicy: .immediate)
        }
    }
}

private extension Double {
    var clampedToUnit: Double {
        min(max(self, 0), 1)
    }
}

#else

/// Fallback stubs for platforms without ActivityKit (e.g., macOS).
enum LLMLiveActivityControllerImpl {
    @MainActor
    static func startOrUpdate(llmName: String, progress: Double) async {}

    @MainActor
    static func endAll() async {}
}

#endif
