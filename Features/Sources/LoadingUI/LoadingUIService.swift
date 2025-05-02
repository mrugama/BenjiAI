import SwiftUI

@MainActor
public struct LoadingUIService: Sendable {
    public static var pageView: some View {
        LLMLoadingView()
    }
}
