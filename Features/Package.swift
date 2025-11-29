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
        .package(url: "https://github.com/gonzalezreal/swift-markdown-ui", from: "2.0.2")
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
                .product(name: "ClipperCoreKit", package: "ClipperCore"),
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
            ]
        ),
        .target(name: "PlaygroundUI", dependencies: ["SharedUIKit"]),
        .target(
            name: "SettingsPage",
            dependencies: [
                "SharedUIKit",
                .product(name: "ClipperCoreKit", package: "ClipperCore")
            ]
        ),
        .target(
            name: "OnboardUI",
            dependencies: [
                "SharedUIKit",
                .product(name: "ClipperCoreKit", package: "ClipperCore"),
            ]
        ),
        .target(
            name: "LoadingUI",
            dependencies: [
                "SharedUIKit",
                .product(name: "ClipperCoreKit", package: "ClipperCore")
            ]
        ),
        .target(
            name: "SharedUIKit",
            dependencies: [
                .product(name: "ToolSpecsManager", package: "ClipperCore")
            ]
        ),
        .target(
            name: "ToolSpecPage",
            dependencies: [
                .product(name: "ToolSpecsManager", package: "ClipperCore"),
            ]
        ),
    ]
)
