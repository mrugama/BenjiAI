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

// MARK: - Previews

#Preview(traits: .sizeThatFitsLayout) {
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
}
