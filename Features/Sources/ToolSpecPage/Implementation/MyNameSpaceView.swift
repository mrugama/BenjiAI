import SwiftUI

struct MyNameSpaceView: View {
    @Namespace private var namespace
    var body: some View {
        NavigationStack {
            NavigationLink {
                Image(systemName: "globe")
                    .resizable()
                    .scaledToFit()
                    .navigationTransition(.zoom(sourceID: "world", in: namespace))
            } label: {
                Image(systemName: "globe")
                    .matchedTransitionSource(id: "world", in: namespace)
            }
        }
    }
}

#Preview {
    MyNameSpaceView()
}

