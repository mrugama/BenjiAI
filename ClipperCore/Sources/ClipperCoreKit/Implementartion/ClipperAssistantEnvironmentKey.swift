import SwiftUI
import ToolSpecsManager

struct ClipperAssistantEnvironmentKey: EnvironmentKey {
    static let defaultValue: ClipperAssistant = ConcreteClipperAssistant(
        ToolSpecManagerService.provideService()
    )
}

struct DeviceStatEnvironmentKey: EnvironmentKey {
    static let defaultValue: DeviceStat = DeviceStatImpl()
}
