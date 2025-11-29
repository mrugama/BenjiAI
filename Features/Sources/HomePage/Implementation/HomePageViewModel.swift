import ClipperCoreKit
import SwiftUI

@Observable
final class HomePageViewModel {
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
    var pageState: PageState = .main
}
