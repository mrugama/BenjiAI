import SwiftUI

// MARK: - Calendar View

struct CalendarView: View {
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
