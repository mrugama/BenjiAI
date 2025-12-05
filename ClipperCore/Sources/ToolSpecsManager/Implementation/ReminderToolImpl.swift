import Foundation
import EventKit

// MARK: - Reminder Tool Implementation

final class ReminderToolImpl: ReminderTool, @unchecked Sendable {
    let id: String = "reminder"
    let name: String = "Reminder"
    let toolDescription: String = "Create, read, update, complete, and query reminders"
    let category: ToolCategory = .reminder
    
    private let eventStore = EKEventStore()
    
    var specification: ToolSpecification {
        ToolSpecification(
            name: "reminder",
            description: "Manage reminders - create, read, update, complete, and query reminders",
            parameters: ToolParameters(
                properties: [
                    "action": ToolParameterProperty(
                        type: "string",
                        description: "The action to perform",
                        enumValues: ["create", "read", "update", "complete", "query"]
                    ),
                    "title": ToolParameterProperty(
                        type: "string",
                        description: "Reminder title"
                    ),
                    "dueDate": ToolParameterProperty(
                        type: "string",
                        description: "Due date in ISO 8601 format"
                    ),
                    "reminderId": ToolParameterProperty(
                        type: "string",
                        description: "Reminder identifier for updates"
                    ),
                    "notes": ToolParameterProperty(
                        type: "string",
                        description: "Reminder notes/description"
                    ),
                    "priority": ToolParameterProperty(
                        type: "integer",
                        description: "Priority (1=high, 5=medium, 9=low)"
                    ),
                    "listName": ToolParameterProperty(
                        type: "string",
                        description: "Reminder list name"
                    ),
                    "query": ToolParameterProperty(
                        type: "string",
                        description: "Search query for finding reminders"
                    )
                ],
                required: ["action"]
            )
        )
    }
    
    func execute(parameters: [String: Any]) async throws -> ToolFunctionResult {
        guard let action = parameters["action"] as? String else {
            throw ToolError.missingParameter("action")
        }
        
        switch action {
        case "create":
            guard let title = parameters["title"] as? String else {
                throw ToolError.missingParameter("title")
            }
            let dueDate = parseDate(parameters["dueDate"])
            let notes = parameters["notes"] as? String
            let priority = parameters["priority"] as? Int
            return try await createReminder(title: title, dueDate: dueDate, notes: notes, priority: priority)
            
        case "read":
            let listName = parameters["listName"] as? String
            return try await readReminders(listName: listName)
            
        case "update":
            guard let reminderId = parameters["reminderId"] as? String else {
                throw ToolError.missingParameter("reminderId")
            }
            let title = parameters["title"] as? String
            let dueDate = parseDate(parameters["dueDate"])
            let notes = parameters["notes"] as? String
            let priority = parameters["priority"] as? Int
            return try await updateReminder(reminderId: reminderId, title: title, dueDate: dueDate, notes: notes, priority: priority)
            
        case "complete":
            guard let reminderId = parameters["reminderId"] as? String else {
                throw ToolError.missingParameter("reminderId")
            }
            return try await completeReminder(reminderId: reminderId)
            
        case "query":
            guard let query = parameters["query"] as? String else {
                throw ToolError.missingParameter("query")
            }
            return try await queryReminders(query: query)
            
        default:
            throw ToolError.invalidParameter("action", reason: "Unknown action: \(action)")
        }
    }
    
    func createReminder(title: String, dueDate: Date?, notes: String?, priority: Int?) async throws -> ToolFunctionResult {
        let authorized = try await requestReminderAccess()
        guard authorized else {
            return .failure(error: "Reminders access denied")
        }
        
        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = title
        reminder.notes = notes
        reminder.priority = priority ?? 0
        reminder.calendar = eventStore.defaultCalendarForNewReminders()
        
        if let dueDate = dueDate {
            reminder.dueDateComponents = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: dueDate
            )
        }
        
        do {
            try eventStore.save(reminder, commit: true)
            
            let viewData = ToolViewData(
                type: "reminder",
                data: [
                    "reminderId": reminder.calendarItemIdentifier,
                    "title": title,
                    "dueDate": dueDate.map { formatDate($0) } ?? "No due date",
                    "notes": notes ?? "",
                    "priority": priorityString(priority ?? 0),
                    "action": "created"
                ],
                template: "reminder_display"
            )
            
            return .success(viewData: viewData, metadata: ["reminderId": reminder.calendarItemIdentifier])
        } catch {
            return .failure(error: "Failed to create reminder: \(error.localizedDescription)")
        }
    }
    
    func readReminders(listName: String?) async throws -> ToolFunctionResult {
        let authorized = try await requestReminderAccess()
        guard authorized else {
            return .failure(error: "Reminders access denied")
        }
        
        var calendars: [EKCalendar]?
        if let listName = listName {
            calendars = eventStore.calendars(for: .reminder).filter { $0.title == listName }
        }
        
        let predicate = eventStore.predicateForReminders(in: calendars)
        
        return try await withCheckedThrowingContinuation { continuation in
            eventStore.fetchReminders(matching: predicate) { reminders in
                guard let reminders = reminders else {
                    continuation.resume(returning: .failure(error: "Failed to fetch reminders"))
                    return
                }
                
                let incompleteReminders = reminders.filter { !$0.isCompleted }
                
                let reminderData: [[String: any Sendable]] = incompleteReminders.prefix(20).map { reminder in
                    [
                        "reminderId": reminder.calendarItemIdentifier,
                        "title": reminder.title ?? "",
                        "dueDate": reminder.dueDateComponents.flatMap { Calendar.current.date(from: $0) }.map { self.formatDate($0) } ?? "No due date",
                        "notes": reminder.notes ?? "",
                        "priority": self.priorityString(reminder.priority),
                        "isCompleted": reminder.isCompleted,
                        "listName": reminder.calendar.title
                    ]
                }
                
                let viewData = ToolViewData(
                    type: "reminders_list",
                    data: [
                        "reminders": reminderData,
                        "listName": listName ?? "All Lists",
                        "count": incompleteReminders.count
                    ],
                    template: "reminders_list_display"
                )
                
                continuation.resume(returning: .success(viewData: viewData, metadata: ["reminderCount": incompleteReminders.count]))
            }
        }
    }
    
    func updateReminder(reminderId: String, title: String?, dueDate: Date?, notes: String?, priority: Int?) async throws -> ToolFunctionResult {
        let authorized = try await requestReminderAccess()
        guard authorized else {
            return .failure(error: "Reminders access denied")
        }
        
        guard let reminder = eventStore.calendarItem(withIdentifier: reminderId) as? EKReminder else {
            return .failure(error: "Reminder not found with ID: \(reminderId)")
        }
        
        if let title = title { reminder.title = title }
        if let notes = notes { reminder.notes = notes }
        if let priority = priority { reminder.priority = priority }
        if let dueDate = dueDate {
            reminder.dueDateComponents = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: dueDate
            )
        }
        
        do {
            try eventStore.save(reminder, commit: true)
            return .success(text: "Reminder '\(reminder.title ?? "")' updated successfully", metadata: ["reminderId": reminderId])
        } catch {
            return .failure(error: "Failed to update reminder: \(error.localizedDescription)")
        }
    }
    
    func completeReminder(reminderId: String) async throws -> ToolFunctionResult {
        let authorized = try await requestReminderAccess()
        guard authorized else {
            return .failure(error: "Reminders access denied")
        }
        
        guard let reminder = eventStore.calendarItem(withIdentifier: reminderId) as? EKReminder else {
            return .failure(error: "Reminder not found with ID: \(reminderId)")
        }
        
        reminder.isCompleted = true
        reminder.completionDate = Date()
        
        do {
            try eventStore.save(reminder, commit: true)
            
            let viewData = ToolViewData(
                type: "reminder",
                data: [
                    "reminderId": reminderId,
                    "title": reminder.title ?? "",
                    "isCompleted": true,
                    "completedDate": formatDate(Date()),
                    "action": "completed"
                ],
                template: "reminder_completed_display"
            )
            
            return .success(viewData: viewData, metadata: ["reminderId": reminderId])
        } catch {
            return .failure(error: "Failed to complete reminder: \(error.localizedDescription)")
        }
    }
    
    func queryReminders(query: String) async throws -> ToolFunctionResult {
        let authorized = try await requestReminderAccess()
        guard authorized else {
            return .failure(error: "Reminders access denied")
        }
        
        let predicate = eventStore.predicateForReminders(in: nil)
        
        return try await withCheckedThrowingContinuation { continuation in
            eventStore.fetchReminders(matching: predicate) { reminders in
                guard let reminders = reminders else {
                    continuation.resume(returning: .failure(error: "Failed to fetch reminders"))
                    return
                }
                
                let matchingReminders = reminders.filter { reminder in
                    let titleMatch = reminder.title?.localizedCaseInsensitiveContains(query) ?? false
                    let notesMatch = reminder.notes?.localizedCaseInsensitiveContains(query) ?? false
                    return titleMatch || notesMatch
                }
                
                let reminderData: [[String: any Sendable]] = matchingReminders.prefix(10).map { reminder in
                    [
                        "reminderId": reminder.calendarItemIdentifier,
                        "title": reminder.title ?? "",
                        "dueDate": reminder.dueDateComponents.flatMap { Calendar.current.date(from: $0) }.map { self.formatDate($0) } ?? "No due date",
                        "notes": reminder.notes ?? "",
                        "isCompleted": reminder.isCompleted
                    ]
                }
                
                let viewData = ToolViewData(
                    type: "reminder_search_results",
                    data: [
                        "query": query,
                        "reminders": reminderData,
                        "count": matchingReminders.count
                    ],
                    template: "reminder_search_display"
                )
                
                continuation.resume(returning: .success(viewData: viewData))
            }
        }
    }
    
    // MARK: - Private Helpers
    
    private func requestReminderAccess() async throws -> Bool {
        if #available(iOS 17.0, macOS 14.0, *) {
            return try await eventStore.requestFullAccessToReminders()
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                eventStore.requestAccess(to: .reminder) { granted, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: granted)
                    }
                }
            }
        }
    }
    
    private func parseDate(_ value: Any?) -> Date? {
        guard let dateString = value as? String else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: dateString) {
            return date
        }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: dateString)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func priorityString(_ priority: Int) -> String {
        switch priority {
        case 1...4: return "High"
        case 5: return "Medium"
        case 6...9: return "Low"
        default: return "None"
        }
    }
}

