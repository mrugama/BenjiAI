// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Features",
    platforms: [.iOS(.v18), .macOS(.v14)],
    products: [
        .library(
            name: "HomePage",
            targets: ["HomePage"])
    ],
    dependencies: [
        .package(path: "../ClipperCore"),
        .package(url: "https://github.com/gonzalezreal/swift-markdown-ui", from: "2.0.2")
    ],
    targets: [
        .target(
            name: "HomePage",
            dependencies: [
                "SharedUIKit",
                "ToolSpecPage",
                "SettingsPage",
                "OnboardUI",
                "LoadingUI",
                .product(name: "ClipperCoreKit", package: "ClipperCore"),
                .product(name: "MarkdownUI", package: "swift-markdown-ui")
            ]
        ),
        .target(name: "PlaygroundUI", dependencies: ["SharedUIKit"]),
        .target(
            name: "SettingsPage",
            dependencies: [
                .product(name: "ClipperCoreKit", package: "ClipperCore")
            ]
        ),
        .target(
            name: "OnboardUI",
            dependencies: [
                .product(name: "ClipperCoreKit", package: "ClipperCore")
            ]
        ),
        .target(
            name: "LoadingUI",
            dependencies: [
                "SharedUIKit",
                .product(name: "ClipperCoreKit", package: "ClipperCore")
            ]
        ),
        .target(name: "SharedUIKit"),
        .target(
            name: "ToolSpecPage",
            dependencies: [
                .product(name: "ToolSpecsManager", package: "ClipperCore"),
            ]
        ),
    ]
)
