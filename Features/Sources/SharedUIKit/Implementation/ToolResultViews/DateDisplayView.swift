import SwiftUI

// MARK: - Date Display View

struct DateDisplayView: View {
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
