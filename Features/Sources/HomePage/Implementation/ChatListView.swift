import SwiftUI

struct ChatListView<Content: View>: View {
    var content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        _VariadicView.Tree(ChatLayout()) {
            content
        }
    }
}


struct ChatLayout: _VariadicView_MultiViewRoot {
    @ViewBuilder
    func body(children: _VariadicView.Children) -> some View {
        ForEach(children.reversed()) { child in
            child
        }
    }
}
