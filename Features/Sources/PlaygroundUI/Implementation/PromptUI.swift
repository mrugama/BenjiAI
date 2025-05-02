import SwiftUI

struct PromptUI: View {
    @Binding var promptText: String
    var onSubmit: () -> Void = { }

    @State private var isEditing = false
    @Namespace private var animation

    var body: some View {
        HStack {
            Image(systemName: "apple.intelligence")
                .foregroundStyle(.primary)

            TextField(
                "How can I help you?",
                text: $promptText,
                onEditingChanged: { editing in
                withAnimation(.easeInOut(duration: 0.3)) {
                    isEditing = editing
                }
            })
            .onSubmit(onSubmit)
        }
        .padding()
        .background(
            Capsule()
                .fill(
                    isEditing
                    ? AnyShapeStyle(LinearGradient(
                        colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                      ))
                    : AnyShapeStyle(Color.gray.opacity(0.2))
                )
                .matchedGeometryEffect(id: "background", in: animation)
                .animation(.easeInOut(duration: 0.4), value: isEditing)
        )
        .overlay(
            Capsule()
                .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
        )
    }
}

#Preview {
    PromptUI(
        promptText: .constant("")
    )
}
