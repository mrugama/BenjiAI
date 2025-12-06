import SwiftUI

// MARK: - Music View

struct MusicView: View {
    let data: [String: any Sendable]
    let type: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "music.note")
                    .foregroundStyle(.pink)
                Text(type == "music_search_results" ? "Music Search" : "Now Playing")
                    .font(.headline)
                    .fontWeight(.semibold)
            }

            if type == "music_search_results" {
                if let results = data["results"] as? [[String: any Sendable]] {
                    ForEach(results.indices, id: \.self) { index in
                        MusicResultCard(result: results[index])
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
                        .foregroundStyle(.secondary)
                }
                if let state = data["state"] as? String {
                    HStack {
                        Image(systemName: state == "playing" ? "play.fill" : "pause.fill")
                        Text(state.capitalized)
                    }
                    .font(.caption)
                    .foregroundStyle(.pink)
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
                .foregroundStyle(.pink)
            VStack(alignment: .leading, spacing: 2) {
                Text(result["title"] as? String ?? result["name"] as? String ?? "Unknown")
                    .font(.subheadline)
                    .fontWeight(.medium)
                if let artist = result["artist"] as? String {
                    Text(artist)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            if let duration = result["duration"] as? String {
                Text(duration)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(8)
        .background(Color.pink.opacity(0.1))
        .clipShape(.rect(cornerRadius: 8))
    }
}
