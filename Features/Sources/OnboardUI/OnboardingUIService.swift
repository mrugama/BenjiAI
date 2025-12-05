import SwiftUI
import SharedUIKit

// MARK: - Onboarding State Model

/// Represents the user's selections during onboarding
@MainActor
@Observable
public final class OnboardingState {
    /// Selected AI model ID
    public var selectedModelId: String?

    /// Selected tool IDs that the user wants to enable
    public var enabledTools: Set<String>

    /// Granted permissions
    public var grantedPermissions: Set<PermissionType>

    /// Selected AI persona/expert type
    public var selectedPersona: AIPersona

    /// Whether the user has completed onboarding
    public var hasCompletedOnboarding: Bool

    public init(
        selectedModelId: String? = nil,
        enabledTools: Set<String> = [],
        grantedPermissions: Set<PermissionType> = [],
        selectedPersona: AIPersona = .generic,
        hasCompletedOnboarding: Bool = false
    ) {
        self.selectedModelId = selectedModelId
        self.enabledTools = enabledTools
        self.grantedPermissions = grantedPermissions
        self.selectedPersona = selectedPersona
        self.hasCompletedOnboarding = hasCompletedOnboarding
    }
}

// MARK: - Permission Types

/// Types of permissions the app can request
public enum PermissionType: String, CaseIterable, Identifiable, Sendable {
    case calendar = "Calendar"
    case reminders = "Reminders"
    case contacts = "Contacts"
    case location = "Location"
    case music = "Music"
    case photos = "Photos"
    case microphone = "Microphone"

    public var id: String { rawValue }

    public var icon: String {
        switch self {
        case .calendar: return "calendar"
        case .reminders: return "checklist"
        case .contacts: return "person.crop.circle"
        case .location: return "location.fill"
        case .music: return "music.note"
        case .photos: return "photo.fill"
        case .microphone: return "mic.fill"
        }
    }

    public var description: String {
        switch self {
        case .calendar: return "Access your calendar events"
        case .reminders: return "Manage your reminders"
        case .contacts: return "Search and create contacts"
        case .location: return "Get location-based assistance"
        case .music: return "Control music playback"
        case .photos: return "Analyze and organize photos"
        case .microphone: return "Voice input and commands"
        }
    }
}

// MARK: - AI Personas

/// Available AI persona configurations
public enum AIPersona: String, CaseIterable, Identifiable, Sendable {
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
    // swiftlint:enable line_length
}

// MARK: - Tool Selection Info

/// Information about available tools for selection
public struct ToolSelectionInfo: Identifiable, Sendable {
    public let id: String
    public let name: String
    public let description: String
    public let icon: String
    public let category: String

    public init(id: String, name: String, description: String, icon: String, category: String) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
        self.category = category
    }

    public static let allTools: [ToolSelectionInfo] = [
        ToolSelectionInfo(
            id: "calendar", name: "Calendar",
            description: "Create and manage events", icon: "calendar", category: "Productivity"
        ),
        ToolSelectionInfo(
            id: "reminder", name: "Reminders",
            description: "Track your tasks", icon: "checklist", category: "Productivity"
        ),
        ToolSelectionInfo(
            id: "contact", name: "Contacts",
            description: "Find and create contacts", icon: "person.crop.circle", category: "Communication"
        ),
        ToolSelectionInfo(
            id: "location", name: "Location",
            description: "Get directions and places", icon: "location.fill", category: "Navigation"
        ),
        ToolSelectionInfo(
            id: "music", name: "Music",
            description: "Search and play music", icon: "music.note", category: "Entertainment"
        ),
        ToolSelectionInfo(
            id: "search", name: "Web Search",
            description: "Search the internet", icon: "magnifyingglass", category: "Information"
        ),
        ToolSelectionInfo(
            id: "queryRefine", name: "Smart Search",
            description: "AI-enhanced queries", icon: "sparkles", category: "Information"
        ),
        ToolSelectionInfo(
            id: "getTodayDate", name: "Date & Time",
            description: "Current date and time", icon: "clock.fill", category: "Utility"
        )
    ]
}

// MARK: - Onboarding Service Protocol

/// Protocol for onboarding service - MainActor isolated for UI state management
@MainActor
public protocol OnboardingService: AnyObject {
    var state: OnboardingState { get }
    func updateSelectedModel(_ modelId: String?)
    func toggleTool(_ toolId: String)
    func togglePermission(_ permission: PermissionType)
    func selectPersona(_ persona: AIPersona)
    func completeOnboarding()
    func resetOnboarding()
}

// MARK: - Onboarding Service Implementation

@MainActor
@Observable
public final class OnboardingServiceImpl: OnboardingService {
    public private(set) var state: OnboardingState

    public init() {
        self.state = OnboardingState()
    }

    public func updateSelectedModel(_ modelId: String?) {
        state.selectedModelId = modelId
    }

    public func toggleTool(_ toolId: String) {
        if state.enabledTools.contains(toolId) {
            state.enabledTools.remove(toolId)
        } else {
            state.enabledTools.insert(toolId)
        }
    }

    public func togglePermission(_ permission: PermissionType) {
        if state.grantedPermissions.contains(permission) {
            state.grantedPermissions.remove(permission)
        } else {
            state.grantedPermissions.insert(permission)
        }
    }

    public func selectPersona(_ persona: AIPersona) {
        state.selectedPersona = persona
    }

    public func completeOnboarding() {
        state.hasCompletedOnboarding = true
    }

    public func resetOnboarding() {
        state.hasCompletedOnboarding = false
    }
}

// MARK: - Environment Key
// Note: Environment keys don't use actor isolation - SwiftUI handles thread safety

private struct OnboardingServiceKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: OnboardingService? = nil
}

public extension EnvironmentValues {
    var onboardingService: OnboardingService? {
        get { self[OnboardingServiceKey.self] }
        set { self[OnboardingServiceKey.self] = newValue }
    }
}

// MARK: - Page Service

/// A service that provides the onboarding view for users.
@MainActor
public struct OnboardingUIService {
    /// Returns the onboarding view with the specified page state binding.
    public static func pageView(
        _ pageState: Binding<PageState>,
        onboardingService: OnboardingService
    ) -> some View {
        OnboardingUI(pageState: pageState, onboardingService: onboardingService)
    }
}
