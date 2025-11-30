import SwiftUI
import SharedUIKit

@MainActor
public struct LoadingUIService {
    public static func pageView(_ pageState: Binding<PageState>) -> some View {
        LLMLoadingView(pageState: pageState)
    }
}
