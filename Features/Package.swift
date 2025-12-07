// swift-tools-version: 6.0

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
                "HomePage",
                "OnboardUI",
                "LoadingUI",
                "SettingsPage",
                "SharedUIKit",
                "PlaygroundUI",
            ],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")
            ]
        )
        ,
        .target(
            name: "HomePage",
            dependencies: [
                "SharedUIKit",
                "ToolSpecPage",
                "SettingsPage",
                .product(name: "ClipperCoreKit", package: "ClipperCore"),
                .product(name: "MarkdownUI", package: "swift-markdown-ui")
            ],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")
            ]
        ),
        .target(name: "PlaygroundUI", dependencies: ["SharedUIKit"]),
        .target(
            name: "SettingsPage",
            dependencies: [
                "SharedUIKit",
                "OnboardUI",
                .product(name: "ClipperCoreKit", package: "ClipperCore")
            ],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")
            ]
        ),
        .target(
            name: "OnboardUI",
            dependencies: [
                "SharedUIKit",
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
