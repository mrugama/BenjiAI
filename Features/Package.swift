// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Features",
    platforms: [.iOS(.v18), .macOS(.v14)],
    products: [
        .library(
            name: "Coordinator",
            targets: ["Coordinator"])
    ],
    dependencies: [
        .package(path: "../ClipperCore"),
        .package(url: "https://github.com/gonzalezreal/swift-markdown-ui", from: "2.0.2"),
        .package(url: "https://github.com/realm/SwiftLint", from: "0.54.0")
    ],
    targets: [
        .target(
            name: "Coordinator",
            dependencies: [
                "ChatUI",
                "SetupUI",
                "LoadingUI",
                "SettingsPage",
                "SharedUIKit",
                "PlaygroundUI",
                "UserPreferences",
            ],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")
            ]
        ),
        .target(
            name: "ChatUI",
            dependencies: [
                "SharedUIKit",
                "UserPreferences",
                .product(name: "ClipperCoreKit", package: "ClipperCore"),
                .product(name: "MarkdownUI", package: "swift-markdown-ui")
            ],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")
            ]
        ),
        .target(name: "PlaygroundUI", dependencies: ["SharedUIKit"]),
        .target(
            name: "UserPreferences",
            dependencies: [
                "SharedUIKit"
            ],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")
            ]
        ),
        .target(
            name: "SettingsPage",
            dependencies: [
                "SharedUIKit",
                "UserPreferences",
                "BGLiveActivities",
                .product(name: "ClipperCoreKit", package: "ClipperCore")
            ],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")
            ]
        ),
        .target(
            name: "SetupUI",
            dependencies: [
                "SharedUIKit",
                "UserPreferences",
                "BGLiveActivities",
                .product(name: "ClipperCoreKit", package: "ClipperCore"),
            ],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")
            ]
        ),
        .target(
            name: "LoadingUI",
            dependencies: [
                "SharedUIKit",
                "BGLiveActivities",
                .product(name: "ClipperCoreKit", package: "ClipperCore")
            ],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")
            ]
        ),
        .target(
            name: "SharedUIKit",
            dependencies: [
                .product(name: "ToolSpecsManager", package: "ClipperCore")
            ],
            resources: [
                .process("ColorSet.xcassets")
            ],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")
            ]
        ),
        .target(
            name: "BGLiveActivities",
            dependencies: [
                "SharedUIKit",
                .product(name: "ClipperCoreKit", package: "ClipperCore")
            ],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")
            ]
        ),
        .target(
            name: "ToolSpecPage",
            dependencies: [
                .product(name: "ToolSpecsManager", package: "ClipperCore"),
            ],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")
            ]
        ),
    ]
)
