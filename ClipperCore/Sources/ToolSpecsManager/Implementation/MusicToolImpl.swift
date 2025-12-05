import Foundation
import MusicKit

// MARK: - Music Tool Implementation

final class MusicToolImpl: MusicTool, @unchecked Sendable {
    let id: String = "music"
    let name: String = "Music"
    let toolDescription: String = "Search and play music, manage playback"
    let category: ToolCategory = .music
    
    var specification: ToolSpecification {
        ToolSpecification(
            name: "music",
            description: "Access Apple Music - search and play music, manage playback",
            parameters: ToolParameters(
                properties: [
                    "action": ToolParameterProperty(
                        type: "string",
                        description: "The action to perform",
                        enumValues: ["search", "play", "pause", "resume", "skip", "previous"]
                    ),
                    "query": ToolParameterProperty(
                        type: "string",
                        description: "Search query for finding music"
                    ),
                    "type": ToolParameterProperty(
                        type: "string",
                        description: "Type of content to search",
                        enumValues: ["song", "album", "artist", "playlist"]
                    ),
                    "trackId": ToolParameterProperty(
                        type: "string",
                        description: "Track/song ID to play"
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
        case "search":
            guard let query = parameters["query"] as? String else {
                throw ToolError.missingParameter("query")
            }
            let type = parameters["type"] as? String
            return try await searchMusic(query: query, type: type)
            
        case "play":
            guard let trackId = parameters["trackId"] as? String else {
                throw ToolError.missingParameter("trackId")
            }
            return try await playMusic(trackId: trackId)
            
        case "pause":
            return try await pauseMusic()
            
        case "resume":
            return try await resumeMusic()
            
        case "skip":
            return try await skipTrack()
            
        case "previous":
            return try await previousTrack()
            
        default:
            throw ToolError.invalidParameter("action", reason: "Unknown action: \(action)")
        }
    }
    
    func searchMusic(query: String, type: String?) async throws -> ToolFunctionResult {
        let authorized = await requestMusicAccess()
        guard authorized else {
            return .failure(error: "Apple Music access denied")
        }
        
        do {
            var results: [[String: any Sendable]] = []
            
            // Search based on type
            switch type?.lowercased() {
            case "song", nil:
                let request = MusicCatalogSearchRequest(term: query, types: [Song.self])
                let response = try await request.response()
                results = response.songs.prefix(10).map { song in
                    [
                        "id": song.id.rawValue,
                        "title": song.title,
                        "artist": song.artistName,
                        "album": song.albumTitle ?? "",
                        "duration": formatDuration(song.duration ?? 0),
                        "type": "song"
                    ]
                }
                
            case "album":
                let request = MusicCatalogSearchRequest(term: query, types: [Album.self])
                let response = try await request.response()
                results = response.albums.prefix(10).map { album in
                    [
                        "id": album.id.rawValue,
                        "title": album.title,
                        "artist": album.artistName,
                        "trackCount": album.trackCount,
                        "type": "album"
                    ]
                }
                
            case "artist":
                let request = MusicCatalogSearchRequest(term: query, types: [Artist.self])
                let response = try await request.response()
                results = response.artists.prefix(10).map { artist in
                    [
                        "id": artist.id.rawValue,
                        "name": artist.name,
                        "type": "artist"
                    ]
                }
                
            case "playlist":
                let request = MusicCatalogSearchRequest(term: query, types: [Playlist.self])
                let response = try await request.response()
                results = response.playlists.prefix(10).map { playlist in
                    [
                        "id": playlist.id.rawValue,
                        "name": playlist.name,
                        "curatorName": playlist.curatorName ?? "",
                        "type": "playlist"
                    ]
                }
                
            default:
                let request = MusicCatalogSearchRequest(term: query, types: [Song.self])
                let response = try await request.response()
                results = response.songs.prefix(10).map { song in
                    [
                        "id": song.id.rawValue,
                        "title": song.title,
                        "artist": song.artistName,
                        "album": song.albumTitle ?? "",
                        "type": "song"
                    ]
                }
            }
            
            let viewData = ToolViewData(
                type: "music_search_results",
                data: [
                    "query": query,
                    "searchType": type ?? "song",
                    "results": results,
                    "count": results.count
                ],
                template: "music_search_display"
            )
            
            return .success(viewData: viewData, metadata: ["resultCount": results.count])
        } catch {
            return .failure(error: "Music search failed: \(error.localizedDescription)")
        }
    }
    
    func playMusic(trackId: String) async throws -> ToolFunctionResult {
        let authorized = await requestMusicAccess()
        guard authorized else {
            return .failure(error: "Apple Music access denied")
        }
        
        do {
            // Fetch the song by ID
            let request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: MusicItemID(trackId))
            let response = try await request.response()
            
            guard let song = response.items.first else {
                return .failure(error: "Song not found with ID: \(trackId)")
            }
            
            // Play the song using MusicKit's ApplicationMusicPlayer
            let player = ApplicationMusicPlayer.shared
            player.queue = [song]
            try await player.play()
            
            let viewData = ToolViewData(
                type: "now_playing",
                data: [
                    "id": trackId,
                    "title": song.title,
                    "artist": song.artistName,
                    "album": song.albumTitle ?? "",
                    "duration": formatDuration(song.duration ?? 0),
                    "isPlaying": true,
                    "action": "playing"
                ],
                template: "now_playing_display"
            )
            
            return .success(viewData: viewData)
        } catch {
            return .failure(error: "Failed to play music: \(error.localizedDescription)")
        }
    }
    
    func pauseMusic() async throws -> ToolFunctionResult {
        let player = ApplicationMusicPlayer.shared
        player.pause()
        
        let currentEntry = player.queue.currentEntry
        
        let viewData = ToolViewData(
            type: "playback_state",
            data: [
                "state": "paused",
                "currentTrack": currentEntry?.title ?? "Unknown",
                "action": "paused"
            ],
            template: "playback_state_display"
        )
        
        return .success(viewData: viewData)
    }
    
    func resumeMusic() async throws -> ToolFunctionResult {
        let player = ApplicationMusicPlayer.shared
        
        do {
            try await player.play()
            
            let currentEntry = player.queue.currentEntry
            
            let viewData = ToolViewData(
                type: "playback_state",
                data: [
                    "state": "playing",
                    "currentTrack": currentEntry?.title ?? "Unknown",
                    "action": "resumed"
                ],
                template: "playback_state_display"
            )
            
            return .success(viewData: viewData)
        } catch {
            return .failure(error: "Failed to resume playback: \(error.localizedDescription)")
        }
    }
    
    func skipTrack() async throws -> ToolFunctionResult {
        let player = ApplicationMusicPlayer.shared
        
        do {
            try await player.skipToNextEntry()
            
            let currentEntry = player.queue.currentEntry
            
            let viewData = ToolViewData(
                type: "playback_state",
                data: [
                    "state": "playing",
                    "currentTrack": currentEntry?.title ?? "Unknown",
                    "action": "skipped"
                ],
                template: "playback_state_display"
            )
            
            return .success(viewData: viewData)
        } catch {
            return .failure(error: "Failed to skip track: \(error.localizedDescription)")
        }
    }
    
    func previousTrack() async throws -> ToolFunctionResult {
        let player = ApplicationMusicPlayer.shared
        
        do {
            try await player.skipToPreviousEntry()
            
            let currentEntry = player.queue.currentEntry
            
            let viewData = ToolViewData(
                type: "playback_state",
                data: [
                    "state": "playing",
                    "currentTrack": currentEntry?.title ?? "Unknown",
                    "action": "previous"
                ],
                template: "playback_state_display"
            )
            
            return .success(viewData: viewData)
        } catch {
            return .failure(error: "Failed to go to previous track: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private Helpers
    
    private func requestMusicAccess() async -> Bool {
        let status = await MusicAuthorization.request()
        return status == .authorized
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
