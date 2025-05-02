import SwiftUI
import HomePage

@main
struct ClipperApp: App {
    var body: some Scene {
        WindowGroup {
            HomePageService.pageView
        }
    }
}
