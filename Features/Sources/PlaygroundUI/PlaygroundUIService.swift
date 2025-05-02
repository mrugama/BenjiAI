import SwiftUI

@MainActor
public struct PlaygroundUIService: Sendable {
    public static var pageView: some View {
        PlaygroundUI()
    }
}
