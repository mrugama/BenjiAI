import Foundation

// MARK: - Permission Types

/// Types of permissions the app can request
public enum PermissionType: String, CaseIterable, Identifiable, Sendable, Codable {
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
