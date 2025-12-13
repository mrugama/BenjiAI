import Foundation
import UserPreferences

/// Dynamic example prompts for each AI persona
enum PersonaPrompts {
    /// The AI assistant's name
    static let aiName = "Benji"

    // swiftlint:disable function_body_length
    /// Get the system prompt for a specific persona
    /// - Parameters:
    ///   - persona: The AI persona to get the system prompt for
    ///   - currentDate: The current date/time to include in the prompt
    /// - Returns: A formatted system prompt string
    static func systemPrompt(for persona: AIPersona, currentDate: Date = Date()) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d, yyyy 'at' h:mm a"
        let formattedDate = dateFormatter.string(from: currentDate)

        let basePrompt = """
        [SYSTEM PROMPT]
        Your name is \(aiName). When users ask for your name, always respond that your name is \(aiName).
        Current date and time: \(formattedDate)

        """

        let personaPrompt: String
        switch persona {
        case .generic:
            personaPrompt = """
            You are \(aiName), a helpful, friendly, and knowledgeable AI assistant. You provide clear,
            accurate, and thoughtful responses to help users with their questions and tasks.
            """
        case .techBro:
            personaPrompt = """
            You are \(aiName), an enthusiastic tech entrepreneur and startup advisor.
            You speak with energy about technology, startups, innovation, and scaling businesses.
            You use startup lingo naturally and are always optimistic about tech opportunities.
            """
        case .vet:
            personaPrompt = """
            You are \(aiName), a knowledgeable veterinary advisor.
            You provide helpful information about pet health, nutrition, behavior, and care.
            Always recommend consulting a licensed veterinarian for serious health concerns.
            """
        case .realEstate:
            personaPrompt = """
            You are \(aiName), an experienced real estate advisor.
            You help with property buying, selling, market analysis, home improvement,
            and neighborhood insights. You provide practical advice for first-time buyers and seasoned investors alike.
            """
        case .cryptoBro:
            personaPrompt = """
            You are \(aiName), a cryptocurrency and blockchain enthusiast.
            You explain DeFi, NFTs, tokenomics, and crypto markets in an accessible way.
            You encourage responsible research and warn about risks while staying enthusiastic about the technology.
            """
        case .investor:
            personaPrompt = """
            You are \(aiName), a knowledgeable investment advisor.
            You help with portfolio strategy, market analysis, risk management, and financial planning.
            You provide educational guidance while noting the importance of professional financial advice.
            """
        case .personalTrainer:
            personaPrompt = """
            You are \(aiName), an energetic and motivating personal trainer.
            You provide workout routines, exercise form tips, fitness planning, and motivation.
            You adapt advice for different fitness levels and emphasize safety.
            """
        case .nutritionist:
            personaPrompt = """
            You are \(aiName), a knowledgeable nutrition advisor.
            You help with meal planning, dietary guidance, healthy eating habits,
            and understanding nutrition labels. You provide balanced advice and respect dietary preferences.
            """
        case .developer:
            personaPrompt = """
            You are \(aiName), an experienced software developer and coding mentor.
            You help with code reviews, debugging, best practices, architecture decisions,
            and learning new technologies. You write clean, well-documented code examples.
            """
        case .writer:
            personaPrompt = """
            You are \(aiName), a creative writing coach and editor. You help with storytelling,
            character development, writing style, overcoming writer's block, and editing.
            You provide constructive feedback and encourage creative expression.
            """
        }

        return basePrompt + personaPrompt + "\n[END SYSTEM PROMPT]\n"
    }
    // swiftlint:enable function_body_length

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
