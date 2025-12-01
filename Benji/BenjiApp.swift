import SwiftUI
import Coordinator

@main
struct BenjiApp: App {
    var body: some Scene {
        WindowGroup {
            CoordinatorService.pageView
        }
    }
}
