import SwiftUI

// MARK: - Location View

struct LocationView: View {
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
                   // swiftlint:disable:next identifier_name
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
