import SwiftUI
import MarkdownUI

struct AnswerUI: View {
    var response: String?

    var body: some View {
        ZStack {
            // Background glowing circle
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            .pink.opacity(0.5),
                            .purple.opacity(0.4),
                            .blue.opacity(0.3)
                        ]),
                        center: .center,
                        startRadius: 50,
                        endRadius: 200
                    )
                )
                .frame(width: 300, height: 300)
                .blur(radius: 30)

            // Foreground content
            VStack(spacing: 12) {
                if let response = response, !response.isEmpty {
                    Markdown(response)
                        .font(.title2)
                        .foregroundStyle(Color.primary)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground).opacity(0.45))
                                .blur(radius: 0.3)
                        )
                } else {
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.pink)
                            .frame(width: 150, height: 18)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.4))
                            .frame(width: 100, height: 18)
                    }
                    .padding(.top, 100)
                    .transition(.opacity)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

#Preview {
    AnswerUI(response:
        """
        ## Hey there

        Hey! How can I help you today?
        We have a lot of text to explain many ideas in the world.
        """
    )
}
