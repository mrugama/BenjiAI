import SwiftUI

struct OnboardUI: View {
    @Binding var isFirstLaunch: Bool
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("Why Benji?")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundStyle(Color.indigo)
                
                privacyView
                
                yourAIView
                
                customizeYourAIView
                
                trainYourModelView
                
                Text("On device AI, anytime, anywhere.")
                    .font(.footnote)
                    .foregroundStyle(Color.gray)
                
                Button {
                    isFirstLaunch = false
                } label: {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.indigo)
                }

            }
            .padding()
            .padding([.leading, .trailing], 50)
        }
    }
    
    private var privacyView: some View {
        HStack(spacing: 18) {
            Image(systemName: "figure.child.and.lock.fill")
                .font(.largeTitle)
                .foregroundStyle(Color.indigo)
            VStack(alignment: .leading) {
                Text("Privacy First")
                    .font(.headline)
                Text("Everything you do stays on your device. Your searches, questions, and activity are yours alone.")
                    .font(.subheadline)
            }
        }
    }
    
    private var yourAIView: some View {
        HStack(spacing: 18) {
            Image(systemName: "apple.intelligence")
                .font(.largeTitle)
                .foregroundStyle(Color.indigo)
            VStack(alignment: .leading) {
                Text("Choose Your AI")
                    .font(.headline)
                Text("Pick the AI model that works best for you — and switch it up anytime you like.")
                    .font(.subheadline)
            }
        }
    }
    
    private var customizeYourAIView: some View {
        HStack(spacing: 18) {
            Image(systemName: "pencil.and.scribble")
                .font(.largeTitle)
                .foregroundStyle(Color.indigo)
            VStack(alignment: .leading) {
                Text("Make It Yours")
                    .font(.headline)
                Text("Advanced settings let you fine-tune and customize how your AI works.")
                    .font(.subheadline)
            }
        }
    }
    
    private var trainYourModelView: some View {
        HStack(spacing: 18) {
            Image(systemName: "figure.strengthtraining.traditional.circle")
                .font(.largeTitle)
                .foregroundStyle(Color.indigo)
            VStack(alignment: .leading) {
                Text("Train on Your Terms")
                    .font(.headline)
                Text("Want smarter results? Allow your model to learn from your behavior — or wipe its memory whenever you want.")
                    .font(.subheadline)
            }
        }
    }
}

#Preview {
    OnboardUI(isFirstLaunch: .constant(false))
}
