import Foundation

// MARK: - AI Personas

/// Available AI persona configurations
public enum AIPersona: String, CaseIterable, Identifiable, Sendable, Codable {
    case generic = "Generic Assistant"
    case techBro = "Tech Bro"
    case vet = "Veterinarian"
    case realEstate = "Real Estate Agent"
    case cryptoBro = "Crypto Enthusiast"
    case investor = "Investment Advisor"
    case personalTrainer = "Personal Trainer"
    case nutritionist = "Nutritionist"
    case developer = "Software Developer"
    case writer = "Creative Writer"

    public var id: String { rawValue }

    public var icon: String {
        switch self {
        case .generic: return "sparkles"
        case .techBro: return "laptopcomputer"
        case .vet: return "pawprint.fill"
        case .realEstate: return "house.fill"
        case .cryptoBro: return "bitcoinsign.circle.fill"
        case .investor: return "chart.line.uptrend.xyaxis"
        case .personalTrainer: return "figure.run"
        case .nutritionist: return "leaf.fill"
        case .developer: return "chevron.left.forwardslash.chevron.right"
        case .writer: return "pencil.line"
        }
    }

    public var subtitle: String {
        switch self {
        case .generic: return "Balanced, helpful responses"
        case .techBro: return "Startup vibes, move fast"
        case .vet: return "Pet health guidance"
        case .realEstate: return "Property insights"
        case .cryptoBro: return "WAGMI energy"
        case .investor: return "Financial perspectives"
        case .personalTrainer: return "Fitness motivation"
        case .nutritionist: return "Dietary guidance"
        case .developer: return "Code-focused help"
        case .writer: return "Creative assistance"
        }
    }

    // swiftlint:disable line_length
    public var systemPrompt: String {
        switch self {
        case .generic:
            return "You are a helpful, balanced AI assistant."
        case .techBro:
            return "You're a tech-savvy assistant with startup energy. Use tech jargon naturally, be enthusiastic about innovation."
        case .vet:
            return "You're a veterinary-focused assistant. Provide pet health guidance while recommending professional vet visits."
        case .realEstate:
            return "You're a real estate-savvy assistant. Help with property insights and market trends."
        case .cryptoBro:
            return "You're a crypto-enthusiast assistant. Discuss blockchain with enthusiasm while noting volatility. Not financial advice."
        case .investor:
            return "You're an investment-focused assistant. Provide financial perspectives. This is not financial advice."
        case .personalTrainer:
            return "You're a fitness-focused assistant. Motivate and provide workout guidance. Consult doctors before new programs."
        case .nutritionist:
            return "You're a nutrition-focused assistant. Provide dietary guidance. This isn't medical advice."
        case .developer:
            return "You're a developer-focused assistant. Provide technical, code-centric responses with best practices."
        case .writer:
            return "You're a creative writing assistant. Help with storytelling, prose, and creative expression."
        }
    }

    public var disclaimerText: String {
        switch self {
        case .vet:
            return """
            This AI provides general pet care guidance only.
            For medical emergencies or health concerns, always consult a licensed veterinarian.
            """
        case .realEstate:
            return """
            This AI provides general real estate information only.
            For transactions and legal matters, consult a licensed real estate professional.
            """
        case .cryptoBro, .investor:
            return """
            This AI does not provide financial advice.
            All investment discussions are educational.
            Consult a licensed financial advisor before making investment decisions.
            """
        case .personalTrainer:
            return """
            This AI provides general fitness guidance.
            Consult a healthcare provider before starting any exercise program.
            """
        case .nutritionist:
            return """
            This AI provides general dietary information only.
            For medical conditions or specific dietary needs, consult a registered dietitian or healthcare provider.
            """
        default:
            return "This AI provides general assistance only. Always seek professional advice for specific concerns."
        }
    }
    // swiftlint:enable line_length
}
