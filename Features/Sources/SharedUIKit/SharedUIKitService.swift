import SwiftUI

public protocol HideKeyboard where Self: Sendable {
    @MainActor
    func callAsFunction()
}

public extension EnvironmentValues {
    var hideKeyboard: HideKeyboard {
        get {
            self[HideKeyboardEnvironmentKey.self]
        } set {
            self[HideKeyboardEnvironmentKey.self] = newValue
        }
    }
}
