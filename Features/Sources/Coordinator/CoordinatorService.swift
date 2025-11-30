import SwiftUI

public struct CoordinatorService {
    @MainActor
    public static var pageView: some View {
        CoordinatorView()
    }
}
