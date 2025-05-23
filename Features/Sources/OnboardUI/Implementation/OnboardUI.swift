import SwiftUI

struct OnboardUI: View {
    @Binding var isFirstLaunch: Bool
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 30) {
                Text("Why Benji AI?")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundStyle(Color.indigo)
                    .padding(.top)
                
                privacyView
                
                yourAIView
                
                customizeYourAIView
                
                trainYourModelView
                
                Text("On device AI, anytime, anywhere.")
                    .font(.footnote)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(Color.gray)
                
                Button {
                    withAnimation {
                        isFirstLaunch = false
                    }
                } label: {
                    Text("Get Started")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .tint(.indigo)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding([.leading, .trailing], 50)
        }
    }
    
    private var privacyView: some View {
        HStack(spacing: 18) {
            Image(systemName: "figure.child.and.lock.fill")
                .resizable()
                .frame(width: 50, height: 50)
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
                .resizable()
                .frame(width: 50, height: 50)
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
                .resizable()
                .frame(width: 50, height: 50)
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
                .resizable()
                .frame(width: 50, height: 50)
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
