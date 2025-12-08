import Foundation

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

    /// Default enabled tools for new users
    public static let defaultEnabledToolIds: Set<String> = ["search", "getTodayDate", "queryRefine"]
}
