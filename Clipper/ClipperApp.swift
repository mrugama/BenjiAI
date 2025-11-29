import SwiftUI
import Coordinator

@main
struct ClipperApp: App {
    var body: some Scene {
        WindowGroup {
            CoordinatorService.pageView
        }
    }
}
