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

#Preview(traits: .sizeThatFitsLayout) {
    PlaygroundUI(userPrompt:
        """
        What time is it?
        """)
}
