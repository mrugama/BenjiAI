import SwiftUI
import SharedUIKit

/// A standalone welcome screen for the Benji iOS app.
///
/// This view is designed to be presented while the app is loading necessary
/// resources. It features a simple, minimalistic design with a subtle
/// pulsating animation on the logo.
struct WelcomeView: View {

    @Binding var pageState: PageState
    // State to control the scaling animation of the logo
    @State private var isPulsing: Bool = false
    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = true

    // Constants for design elements
    private let koalaGrey = Color(red: 0.65, green: 0.67, blue: 0.70) // Soft grey for the Koala
    private let paleBackground = Color(red: 0.95, green: 0.96, blue: 0.96) // Near-white background color

    var body: some View {
        ZStack {
            // 1. App-wide background color
            paleBackground
                .edgesIgnoringSafeArea(.all)

            VStack {
                // MARK: - Logo/Icon Area

                // This ZStack simulates the light circle background from the generated image.
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 180, height: 180)
                        .shadow(color: koalaGrey.opacity(0.15), radius: 20, x: 0, y: 10)

                    // IMPORTANT: Replace this placeholder with your Koala image asset
                    // It should be named "KoalaIcon" in your Asset Catalog.
                    // If you don't have the asset yet, you can use a placeholder:
                    Image(systemName: "heart.fill") // Placeholder: Use a placeholder system image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundStyle(koalaGrey)
                        .scaleEffect(isPulsing ? 1.05 : 1.0) // Apply the pulsing scale effect
                        .animation(
                            Animation.easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: true),
                            value: isPulsing
                        )
                }

                // MARK: - App Title

                Text("Benji")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(koalaGrey.opacity(0.85))
                    .padding(.top, 30)
                    .scaleEffect(isPulsing ? 1.0 : 0.95)
                    .animation(.spring().speed(0.5), value: isPulsing)

                // MARK: - Tagline

                Text("Your Companion")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(koalaGrey.opacity(0.6))
            }
        }
        // When the view appears, start the animation
        .onAppear {
            isPulsing = true
        }
        // Defines how this view should transition when it is added or removed from the screen
        .transition(.opacity)
        .task {
            if isFirstLaunch && pageState == .welcome {
                pageState = .onboarding
            } else {
                pageState = .loading
            }
        }
    }
}

#Preview {
    WelcomeView(pageState: .constant(.welcome))
}
