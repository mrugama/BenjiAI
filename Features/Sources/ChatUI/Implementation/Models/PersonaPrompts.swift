import Foundation
import UserPreferences

/// Dynamic example prompts for each AI persona
enum PersonaPrompts {
    // swiftlint:disable function_body_length
    /// Get example prompts for a specific persona
    static func prompts(for persona: AIPersona) -> [String] {
        switch persona {
        case .generic:
            return [
                "What's the best way to stay organized?",
                "Explain quantum computing simply",
                "Help me write a thank you note",
                "What are some healthy breakfast ideas?",
                "How do I start learning a new skill?"
            ]
        case .techBro:
            return [
                "What's the next big thing in AI?",
                "How do I scale my startup?",
                "Explain Web3 to me like I'm five",
                "Best productivity hacks for founders",
                "How to pitch to VCs effectively?"
            ]
        case .vet:
            return [
                "My dog is scratching a lot, why?",
                "Best diet for a senior cat?",
                "How often should I walk my puppy?",
                "Signs my pet needs a vet visit",
                "Safe human foods for dogs?"
            ]
        case .realEstate:
            return [
                "Is now a good time to buy?",
                "How to increase home value?",
                "What to look for in a neighborhood?",
                "First-time buyer tips",
                "Renting vs buying pros and cons?"
            ]
        case .cryptoBro:
            return [
                "What's happening in crypto today?",
                "Explain DeFi to me",
                "Best way to DYOR on a token?",
                "What are NFTs actually good for?",
                "How does staking work?"
            ]
        case .investor:
            return [
                "How to build a diversified portfolio?",
                "Index funds vs individual stocks?",
                "What's dollar-cost averaging?",
                "How to evaluate a company?",
                "Risk management strategies?"
            ]
        case .personalTrainer:
            return [
                "Best exercises for beginners?",
                "How to build muscle at home?",
                "Pre-workout nutrition tips",
                "How often should I rest?",
                "Stretching routine for flexibility?"
            ]
        case .nutritionist:
            return [
                "How to eat more protein?",
                "Best foods for energy?",
                "Meal prep ideas for busy people",
                "How to read nutrition labels?",
                "Healthy snack alternatives?"
            ]
        case .developer:
            return [
                "Best practices for clean code?",
                "How to debug efficiently?",
                "Explain async/await in Swift",
                "When to use which design pattern?",
                "Tips for code reviews?"
            ]
        case .writer:
            return [
                "Help me overcome writer's block",
                "How to create compelling characters?",
                "Tips for writing dialogue",
                "How to structure a story?",
                "Finding your writing voice?"
            ]
        }
        // swiftlint:enable function_body_length
    }

    /// Get a random prompt for a persona
    static func randomPrompt(for persona: AIPersona) -> String {
        prompts(for: persona).randomElement() ?? "Ask me anything"
    }

    /// Get greeting text for a persona
    static func greeting(for persona: AIPersona) -> String {
        switch persona {
        case .generic:
            return "How can I help you today?"
        case .techBro:
            return "Let's ship something awesome! 🚀"
        case .vet:
            return "How can I help with your furry friend?"
        case .realEstate:
            return "Ready to talk property?"
        case .cryptoBro:
            return "GM! What's on your mind? 💎"
        case .investor:
            return "Let's discuss your financial goals"
        case .personalTrainer:
            return "Ready to crush your fitness goals?"
        case .nutritionist:
            return "Let's fuel your body right!"
        case .developer:
            return "What are we building today?"
        case .writer:
            return "Ready to create something beautiful?"
        }
    }
}
