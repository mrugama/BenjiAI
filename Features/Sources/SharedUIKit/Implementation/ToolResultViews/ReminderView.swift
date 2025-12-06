import SwiftUI

// MARK: - Reminder View

struct ReminderView: View {
    let data: [String: any Sendable]
    let type: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "checklist")
                    .foregroundStyle(.orange)
                Text(type.contains("list") ? "Reminders" : "Reminder")
                    .font(.headline)
                    .fontWeight(.semibold)
            }

            if type.contains("list") || type.contains("search") {
                if let reminders = data["reminders"] as? [[String: any Sendable]] {
                    ForEach(reminders.indices, id: \.self) { index in
                        ReminderCard(reminder: reminders[index])
                    }
                }
                if let count = data["count"] as? Int {
                    Text("\(count) reminder\(count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                if let title = data["title"] as? String {
                    HStack {
                        Image(systemName: (data["isCompleted"] as? Bool == true) ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle((data["isCompleted"] as? Bool == true) ? .green : .orange)
                        Text(title)
                            .font(.title3)
                            .fontWeight(.medium)
                    }
                }
                if let dueDate = data["dueDate"] as? String {
                    Label(dueDate, systemImage: "clock")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
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
                .foregroundStyle((reminder["isCompleted"] as? Bool == true) ? .green : .orange)
            VStack(alignment: .leading, spacing: 2) {
                Text(reminder["title"] as? String ?? "Untitled")
                    .font(.subheadline)
                    .fontWeight(.medium)
                if let dueDate = reminder["dueDate"] as? String {
                    Text(dueDate)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
        .padding(8)
        .background(Color.orange.opacity(0.1))
        .clipShape(.rect(cornerRadius: 8))
    }
}
