import SwiftUI
import SharedUIKit

struct PlaygroundUI: View {
    var userPrompt: String?

    var body: some View {
        GeometryReader { _ in
            VStack(spacing: 0) {
                userPromptView
                ScrollView(.vertical) {
                    CalendarClockView()
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity
                        )
                }
            }
            .background(Color.antiqueWhite)
        }
    }

    private var userPromptView: some View {
        UserPromptView(userPrompt: userPrompt)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    PlaygroundUI(userPrompt:
        """
        What time is it?
        """)
}

// MARK: - Extracted Views

private struct UserPromptView: View {
    let userPrompt: String?

    var body: some View {
        VStack(alignment: .leading) {
            if let userPrompt {
                Label(userPrompt, systemImage: "person.wave.2")
            } else {
                Text("")
            }
        }
        .padding()
        .foregroundStyle(Color.gunmetal)
    }
}
