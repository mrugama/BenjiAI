import SwiftUI

struct ClipperAssistantEnvironmentKey: EnvironmentKey {
    static let defaultValue: ClipperAssistant = ConcreteClipperAssistant()
}

struct DeviceStatEnvironmentKey: EnvironmentKey {
    static let defaultValue: DeviceStat = DeviceStatImpl()
}
