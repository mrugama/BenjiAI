import Foundation
import EventKit

// MARK: - Calendar Tool Implementation

final class CalendarToolImpl: CalendarTool, @unchecked Sendable {
    let id: String = "calendar"
    let name: String = "Calendar"
    let toolDescription: String = "Create, read, update, and query calendar events"
    let category: ToolCategory = .calendar
    
    private let eventStore = EKEventStore()
    
    var specification: ToolSpecification {
        ToolSpecification(
            name: "calendar",
            description: "Manage calendar events - create, read, update, and query events",
            parameters: ToolParameters(
                properties: [
                    "action": ToolParameterProperty(
                        type: "string",
                        description: "The action to perform",
                        enumValues: ["create", "read", "update", "query"]
                    ),
                    "title": ToolParameterProperty(
                        type: "string",
                        description: "Event title"
                    ),
                    "startDate": ToolParameterProperty(
                        type: "string",
                        description: "Start date in ISO 8601 format"
                    ),
                    "endDate": ToolParameterProperty(
                        type: "string",
                        description: "End date in ISO 8601 format"
                    ),
                    "eventId": ToolParameterProperty(
                        type: "string",
                        description: "Event identifier for updates"
                    ),
                    "notes": ToolParameterProperty(
                        type: "string",
                        description: "Event notes/description"
                    ),
                    "query": ToolParameterProperty(
                        type: "string",
                        description: "Search query for finding events"
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
            let startDate = parseDate(parameters["startDate"]) ?? Date()
            let endDate = parseDate(parameters["endDate"]) ?? startDate.addingTimeInterval(3600)
            let notes = parameters["notes"] as? String
            return try await createEvent(title: title, startDate: startDate, endDate: endDate, notes: notes)
            
        case "read":
            let startDate = parseDate(parameters["startDate"]) ?? Date()
            let endDate = parseDate(parameters["endDate"]) ?? startDate.addingTimeInterval(86400 * 7)
            return try await readEvents(startDate: startDate, endDate: endDate)
            
        case "update":
            guard let eventId = parameters["eventId"] as? String else {
                throw ToolError.missingParameter("eventId")
            }
            let title = parameters["title"] as? String
            let startDate = parseDate(parameters["startDate"])
            let endDate = parseDate(parameters["endDate"])
            let notes = parameters["notes"] as? String
            return try await updateEvent(eventId: eventId, title: title, startDate: startDate, endDate: endDate, notes: notes)
            
        case "query":
            guard let query = parameters["query"] as? String else {
                throw ToolError.missingParameter("query")
            }
            return try await queryEvents(query: query)
            
        default:
            throw ToolError.invalidParameter("action", reason: "Unknown action: \(action)")
        }
    }
    
    func createEvent(title: String, startDate: Date, endDate: Date, notes: String?) async throws -> ToolFunctionResult {
        let authorized = try await requestCalendarAccess()
        guard authorized else {
            return .failure(error: "Calendar access denied")
        }
        
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.notes = notes
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        do {
            try eventStore.save(event, span: .thisEvent)
            
            let viewData = ToolViewData(
                type: "calendar_event",
                data: [
                    "eventId": event.eventIdentifier ?? "",
                    "title": title,
                    "startDate": formatDate(startDate),
                    "endDate": formatDate(endDate),
                    "notes": notes ?? "",
                    "action": "created"
                ],
                template: "calendar_event_display"
            )
            
            return .success(viewData: viewData, metadata: ["eventId": event.eventIdentifier ?? ""])
        } catch {
            return .failure(error: "Failed to create event: \(error.localizedDescription)")
        }
    }
    
    func readEvents(startDate: Date, endDate: Date) async throws -> ToolFunctionResult {
        let authorized = try await requestCalendarAccess()
        guard authorized else {
            return .failure(error: "Calendar access denied")
        }
        
        let calendars = eventStore.calendars(for: .event)
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
        let events = eventStore.events(matching: predicate)
        
        let eventData: [[String: any Sendable]] = events.map { event in
            [
                "eventId": event.eventIdentifier ?? "",
                "title": event.title ?? "",
                "startDate": formatDate(event.startDate),
                "endDate": formatDate(event.endDate),
                "notes": event.notes ?? "",
                "location": event.location ?? "",
                "isAllDay": event.isAllDay
            ]
        }
        
        let viewData = ToolViewData(
            type: "calendar_events_list",
            data: [
                "events": eventData,
                "startDate": formatDate(startDate),
                "endDate": formatDate(endDate),
                "count": events.count
            ],
            template: "calendar_events_list_display"
        )
        
        return .success(viewData: viewData, metadata: ["eventCount": events.count])
    }
    
    func updateEvent(eventId: String, title: String?, startDate: Date?, endDate: Date?, notes: String?) async throws -> ToolFunctionResult {
        let authorized = try await requestCalendarAccess()
        guard authorized else {
            return .failure(error: "Calendar access denied")
        }
        
        guard let event = eventStore.event(withIdentifier: eventId) else {
            return .failure(error: "Event not found with ID: \(eventId)")
        }
        
        if let title = title { event.title = title }
        if let startDate = startDate { event.startDate = startDate }
        if let endDate = endDate { event.endDate = endDate }
        if let notes = notes { event.notes = notes }
        
        do {
            try eventStore.save(event, span: .thisEvent)
            
            return .success(text: "Event '\(event.title ?? "")' updated successfully", metadata: ["eventId": eventId])
        } catch {
            return .failure(error: "Failed to update event: \(error.localizedDescription)")
        }
    }
    
    func queryEvents(query: String) async throws -> ToolFunctionResult {
        let authorized = try await requestCalendarAccess()
        guard authorized else {
            return .failure(error: "Calendar access denied")
        }
        
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(86400 * 365) // Search next year
        let calendars = eventStore.calendars(for: .event)
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
        let allEvents = eventStore.events(matching: predicate)
        
        let matchingEvents = allEvents.filter { event in
            let titleMatch = event.title?.localizedCaseInsensitiveContains(query) ?? false
            let notesMatch = event.notes?.localizedCaseInsensitiveContains(query) ?? false
            let locationMatch = event.location?.localizedCaseInsensitiveContains(query) ?? false
            return titleMatch || notesMatch || locationMatch
        }
        
        let eventData: [[String: any Sendable]] = matchingEvents.prefix(10).map { event in
            [
                "eventId": event.eventIdentifier ?? "",
                "title": event.title ?? "",
                "startDate": formatDate(event.startDate),
                "endDate": formatDate(event.endDate),
                "notes": event.notes ?? ""
            ]
        }
        
        let viewData = ToolViewData(
            type: "calendar_search_results",
            data: [
                "query": query,
                "events": eventData,
                "count": matchingEvents.count
            ],
            template: "calendar_search_display"
        )
        
        return .success(viewData: viewData)
    }
    
    // MARK: - Private Helpers
    
    private func requestCalendarAccess() async throws -> Bool {
        if #available(iOS 17.0, macOS 14.0, *) {
            return try await eventStore.requestFullAccessToEvents()
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                eventStore.requestAccess(to: .event) { granted, error in
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
}

