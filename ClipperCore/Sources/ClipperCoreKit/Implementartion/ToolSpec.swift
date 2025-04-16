import Foundation

struct ToolSpec: Sendable {    
    func callAsFunction() -> [String: any Sendable] {
        [
            "type": "function",
            "function": [
                "name": "get_current_weather",
                "description": "Get the current weather in a given location",
                "parameters": [
                    "type": "object",
                    "properties": [
                        "location": [
                            "type": "string",
                            "description": "The city and state, e.g. San Francisco, CA",
                        ] as [String: String],
                        "unit": [
                            "type": "string",
                            "enum": ["celsius", "fahrenheit"],
                        ] as [String: any Sendable],
                    ] as [String: [String: any Sendable]],
                    "required": ["location"],
                ] as [String: any Sendable],
            ] as [String: any Sendable],
        ] as [String: any Sendable]
    }
}
