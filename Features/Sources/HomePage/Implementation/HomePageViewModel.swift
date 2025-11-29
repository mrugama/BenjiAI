import ClipperCoreKit
import SharedUIKit
import SwiftUI

@Observable
final class HomePageViewModel {
    var isFirstLaunch: Bool {
        get { UserDefaults.standard.bool(forKey: "isFirstLaunch") }
        set { UserDefaults.standard.set(newValue, forKey: "isFirstLaunch") }
    }
    var pageState: PageState
    
    init(pageState: PageState = .home) {
        self.pageState = pageState
    }
}
