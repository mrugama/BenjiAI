import SwiftUI
#if canImport(UIKit)
import UIKit

struct HideKeyboardImpl: HideKeyboard {
    @MainActor
    func callAsFunction() {
        UIApplication
            .shared
            .sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

struct HideKeyboardEnvironmentKey: EnvironmentKey {
    static let defaultValue: HideKeyboard = HideKeyboardImpl()
}
#endif
