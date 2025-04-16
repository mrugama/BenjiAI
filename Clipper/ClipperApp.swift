import SwiftUI
import MainTabPage

@main
struct ClipperApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabPageService.pageView
        }
    }
}
