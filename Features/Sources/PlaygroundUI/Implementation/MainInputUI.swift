import SwiftUI
import SharedUIKit

struct MainInputUI: View {
    @Environment(\.appTheme) private var appTheme
    var height: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading) {
            NavigationLink {
                Text("Destination View")
            } label: {
                Text("Enter text")
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: height * 0.75,
                        alignment: .topLeading)
                    .font(.title)
                    .foregroundStyle(appTheme.textSecondary)
                    .safeAreaPadding(.all)
                    .padding(.leading, 12)
                    .background(appTheme.background.cornerRadius(15))
                    .shadow(color: appTheme.shadow, radius: 20)
            }
            Spacer()
        }
        .background(appTheme.background)
    }
}

#Preview {
    MainInputUI(height: 50)
}
