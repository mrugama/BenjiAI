import SharedUIKit
import SwiftUI

@MainActor
public struct HomePageService: Sendable {
    
    public static func pageView(_ pageState: Binding<PageState>) -> some View {
        HomePage(pageState: pageState)
    }
}
