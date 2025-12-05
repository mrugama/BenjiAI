import SwiftUI
import ToolSpecsManager

// MARK: - Tool Result View Renderer

public struct ToolResultView: View {
    let viewData: ToolViewData

    public init(viewData: ToolViewData) {
        self.viewData = viewData
    }

    public var body: some View {
        switch viewData.template {
        case "date_display":
            DateDisplayView(data: viewData.data)
        case "search_results_display":
            SearchResultsView(data: viewData.data)
        case "calendar_event_display", "calendar_events_list_display", "calendar_search_display":
            CalendarView(data: viewData.data, type: viewData.type)
        case "reminder_display", "reminders_list_display", "reminder_completed_display", "reminder_search_display":
            ReminderView(data: viewData.data, type: viewData.type)
        case "contacts_list_display", "contact_detail_display", "contact_created_display":
            ContactView(data: viewData.data, type: viewData.type)
        case "location_display", "geocode_result_display", "distance_result_display":
            LocationView(data: viewData.data, type: viewData.type)
        case "music_search_display", "now_playing_display", "playback_state_display":
            MusicView(data: viewData.data, type: viewData.type)
        case "query_refine_display":
            QueryRefineView(data: viewData.data)
        default:
            DefaultToolView(data: viewData.data, type: viewData.type)
        }
    }
}

// MARK: - Date Display View

private struct DateDisplayView: View {
    let data: [String: any Sendable]

    var body: some View {
        VStack(spacing: 16) {
            if let day = data["day"] as? Int,
               let dayName = data["dayName"] as? String {
                VStack(spacing: 4) {
                    Text("\(day)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)

                    Text(dayName)
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.blue.opacity(0.1))
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )
            }

            VStack(spacing: 8) {
                if let time = data["time"] as? String {
                    Text(time)
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }

                if let fullDate = data["fullDate"] as? String {
                    Text(fullDate)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 4)
        )
    }
}

// MARK: - Search Results View

private struct SearchResultsView: View {
    let data: [String: any Sendable]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let query = data["query"] as? String {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.blue)
                    Text("Search Results for: \(query)")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .padding(.bottom, 8)
            }

            if let results = data["results"] as? [[String: String]] {
                LazyVStack(spacing: 12) {
                    ForEach(Array(results.enumerated()), id: \.offset) { index, result in
                        SearchResultCard(result: result, index: index + 1)
                    }
                }
            }

            if let count = data["resultCount"] as? Int {
                Text("\(count) result\(count == 1 ? "" : "s") found")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 4)
        )
    }
}

private struct SearchResultCard: View {
    let result: [String: String]
    let index: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(index)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 20, height: 20)
                    .background(Circle().fill(Color.blue))

                if let title = result["title"] {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                }
            }

            if let snippet = result["snippet"] {
                Text(snippet)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }

            if let urlString = result["url"],
               let url = URL(string: urlString) {
                Link(destination: url) {
                    HStack {
                        Image(systemName: "link")
                        Text(url.host ?? urlString)
                            .lineLimit(1)
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(0.05))
                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Calendar View

private struct CalendarView: View {
    let data: [String: any Sendable]
    let type: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.red)
                Text(type == "calendar_events_list" ? "Calendar Events" : "Calendar Event")
                    .font(.headline)
                    .fontWeight(.semibold)
            }

            if type == "calendar_events_list" || type == "calendar_search_results" {
                if let events = data["events"] as? [[String: any Sendable]] {
                    ForEach(Array(events.enumerated()), id: \.offset) { _, event in
                        CalendarEventCard(event: event)
                    }
                }
                if let count = data["count"] as? Int {
                    Text("\(count) event\(count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                if let title = data["title"] as? String {
                    Text(title)
                        .font(.title3)
                        .fontWeight(.medium)
                }
                if let startDate = data["startDate"] as? String {
                    Label(startDate, systemImage: "clock")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                if let notes = data["notes"] as? String, !notes.isEmpty {
                    Text(notes)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 4)
        )
    }
}

private struct CalendarEventCard: View {
    let event: [String: any Sendable]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(event["title"] as? String ?? "Untitled Event")
                .font(.subheadline)
                .fontWeight(.medium)
            if let startDate = event["startDate"] as? String {
                Text(startDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Reminder View

private struct ReminderView: View {
    let data: [String: any Sendable]
    let type: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "checklist")
                    .foregroundColor(.orange)
                Text(type.contains("list") ? "Reminders" : "Reminder")
                    .font(.headline)
                    .fontWeight(.semibold)
            }

            if type.contains("list") || type.contains("search") {
                if let reminders = data["reminders"] as? [[String: any Sendable]] {
                    ForEach(Array(reminders.enumerated()), id: \.offset) { _, reminder in
                        ReminderCard(reminder: reminder)
                    }
                }
                if let count = data["count"] as? Int {
                    Text("\(count) reminder\(count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                if let title = data["title"] as? String {
                    HStack {
                        Image(systemName: (data["isCompleted"] as? Bool == true) ? "checkmark.circle.fill" : "circle")
                            .foregroundColor((data["isCompleted"] as? Bool == true) ? .green : .orange)
                        Text(title)
                            .font(.title3)
                            .fontWeight(.medium)
                    }
                }
                if let dueDate = data["dueDate"] as? String {
                    Label(dueDate, systemImage: "clock")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 4)
        )
    }
}

private struct ReminderCard: View {
    let reminder: [String: any Sendable]

    var body: some View {
        HStack {
            Image(systemName: (reminder["isCompleted"] as? Bool == true) ? "checkmark.circle.fill" : "circle")
                .foregroundColor((reminder["isCompleted"] as? Bool == true) ? .green : .orange)
            VStack(alignment: .leading, spacing: 2) {
                Text(reminder["title"] as? String ?? "Untitled")
                    .font(.subheadline)
                    .fontWeight(.medium)
                if let dueDate = reminder["dueDate"] as? String {
                    Text(dueDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
        }
        .padding(8)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Contact View

private struct ContactView: View {
    let data: [String: any Sendable]
    let type: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person.crop.circle")
                    .foregroundColor(.green)
                Text(type.contains("list") ? "Contacts" : "Contact")
                    .font(.headline)
                    .fontWeight(.semibold)
            }

            if type.contains("list") {
                if let contacts = data["contacts"] as? [[String: any Sendable]] {
                    ForEach(Array(contacts.enumerated()), id: \.offset) { _, contact in
                        ContactCard(contact: contact)
                    }
                }
            } else {
                if let fullName = data["fullName"] as? String {
                    Text(fullName)
                        .font(.title3)
                        .fontWeight(.medium)
                }
                if let phoneNumbers = data["phoneNumbers"] as? [String], let first = phoneNumbers.first {
                    Label(first, systemImage: "phone")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                if let emails = data["emails"] as? [String], let first = emails.first {
                    Label(first, systemImage: "envelope")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 4)
        )
    }
}

private struct ContactCard: View {
    let contact: [String: any Sendable]

    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .foregroundColor(.green)
                .font(.title2)
            VStack(alignment: .leading, spacing: 2) {
                Text(contact["fullName"] as? String ?? "Unknown")
                    .font(.subheadline)
                    .fontWeight(.medium)
                if let phones = contact["phoneNumbers"] as? [String], let first = phones.first {
                    Text(first)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
        }
        .padding(8)
        .background(Color.green.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Location View

private struct LocationView: View {
    let data: [String: any Sendable]
    let type: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(.blue)
                Text(type == "distance_calculation" ? "Distance" : "Location")
                    .font(.headline)
                    .fontWeight(.semibold)
            }

            if type == "distance_calculation" {
                if let from = data["fromAddress"] as? String,
                   let to = data["toAddress"] as? String {
                    VStack(alignment: .leading, spacing: 8) {
                        Label(from, systemImage: "mappin.circle")
                            .font(.subheadline)
                        Label(to, systemImage: "mappin.circle.fill")
                            .font(.subheadline)
                    }
                }
                if let distance = data["distanceFormatted"] as? String {
                    Text(distance)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
            } else {
                if let address = data["address"] as? String {
                    Text(address)
                        .font(.body)
                }
                if let lat = data["latitude"] as? Double,
                   let lon = data["longitude"] as? Double {
                    Text("Coordinates: \(String(format: "%.4f", lat)), \(String(format: "%.4f", lon))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 4)
        )
    }
}

// MARK: - Music View

private struct MusicView: View {
    let data: [String: any Sendable]
    let type: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "music.note")
                    .foregroundColor(.pink)
                Text(type == "music_search_results" ? "Music Search" : "Now Playing")
                    .font(.headline)
                    .fontWeight(.semibold)
            }

            if type == "music_search_results" {
                if let results = data["results"] as? [[String: any Sendable]] {
                    ForEach(Array(results.enumerated()), id: \.offset) { _, result in
                        MusicResultCard(result: result)
                    }
                }
            } else {
                if let title = data["title"] as? String {
                    Text(title)
                        .font(.title3)
                        .fontWeight(.medium)
                }
                if let artist = data["artist"] as? String {
                    Text(artist)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                if let state = data["state"] as? String {
                    HStack {
                        Image(systemName: state == "playing" ? "play.fill" : "pause.fill")
                        Text(state.capitalized)
                    }
                    .font(.caption)
                    .foregroundColor(.pink)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 4)
        )
    }
}

private struct MusicResultCard: View {
    let result: [String: any Sendable]

    var body: some View {
        HStack {
            Image(systemName: "music.note")
                .foregroundColor(.pink)
            VStack(alignment: .leading, spacing: 2) {
                Text(result["title"] as? String ?? result["name"] as? String ?? "Unknown")
                    .font(.subheadline)
                    .fontWeight(.medium)
                if let artist = result["artist"] as? String {
                    Text(artist)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            if let duration = result["duration"] as? String {
                Text(duration)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(8)
        .background(Color.pink.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Query Refine View

private struct QueryRefineView: View {
    let data: [String: any Sendable]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.purple)
                Text("Query Refined")
                    .font(.headline)
                    .fontWeight(.semibold)
            }

            if let original = data["originalQuery"] as? String {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Original:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(original)
                        .font(.subheadline)
                        .strikethrough()
                        .foregroundColor(.secondary)
                }
            }

            if let refined = data["refinedQuery"] as? String {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Refined:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(refined)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.purple)
                }
            }

            if let improvements = data["improvements"] as? [String] {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Improvements:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    ForEach(improvements, id: \.self) { improvement in
                        Label(improvement, systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 4)
        )
    }
}

// MARK: - Default Tool View

private struct DefaultToolView: View {
    let data: [String: any Sendable]
    let type: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "wrench.and.screwdriver.fill")
                    .foregroundColor(.orange)
                Text("Tool Result: \(type)")
                    .font(.headline)
                    .fontWeight(.semibold)
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(data.keys.sorted()), id: \.self) { key in
                        HStack(alignment: .top) {
                            Text("\(key):")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                                .frame(minWidth: 80, alignment: .leading)
                            if let value = data[key] as? String {
                                Text("\(value)")
                                    .font(.caption)
                                    .foregroundColor(.primary)
                                    .textSelection(.enabled)
                            }

                            Spacer()
                        }
                    }
                }
            }
            .frame(maxHeight: 200)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 4)
        )
    }
}

// MARK: - Previews

#if DEBUG
struct ToolResultView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Date view example
                ToolResultView(viewData: ToolViewData(
                    type: "date",
                    data: [
                        "fullDate": "Monday, December 16, 2024 at 2:30 PM",
                        "time": "2:30 PM",
                        "dayName": "Monday",
                        "day": 16,
                        "month": 12,
                        "year": 2024
                    ],
                    template: "date_display"
                ))

                // Search results example
                ToolResultView(viewData: ToolViewData(
                    type: "search_results",
                    data: [
                        "query": "Swift programming",
                        "results": [
                            [
                                "title": "Swift Programming Language",
                                "snippet": "Swift is a powerful programming language...",
                                "url": "https://swift.org"
                            ]
                        ],
                        "resultCount": 1
                    ],
                    template: "search_results_display"
                ))

                // Location example
                ToolResultView(viewData: ToolViewData(
                    type: "current_location",
                    data: [
                        "address": "Brooklyn, NY, USA",
                        "latitude": 40.6782,
                        "longitude": -73.9442
                    ],
                    template: "location_display"
                ))
            }
            .padding()
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
