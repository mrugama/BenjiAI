import SwiftUI
import SharedUIKit

@MainActor
public struct LoadingUIService: Sendable {
    public static func pageView(_ pageState: Binding<PageState>) -> some View {
        LLMLoadingView(pageState: pageState)
    }
}
