import SharedUIKit
import SwiftUI

@MainActor
public struct HomePageService {
    public static func pageView(_ pageState: Binding<PageState>) -> some View {
        HomePage(pageState: pageState)
    }
}
