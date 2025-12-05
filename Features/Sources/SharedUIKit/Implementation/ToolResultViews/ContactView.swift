import SwiftUI

// MARK: - Contact View

struct ContactView: View {
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
