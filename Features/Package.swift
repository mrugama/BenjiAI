// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Features",
    platforms: [.iOS(.v18), .macOS(.v14)],
    products: [
        .library(
            name: "MainTabPage",
            targets: ["MainTabPage"])
    ],
    dependencies: [
        .package(path: "../ClipperCore"),
        .package(url: "https://github.com/gonzalezreal/swift-markdown-ui", from: "2.0.2")
    ],
    targets: [
        .target(
            name: "MainTabPage",
            dependencies: [
                "HomePage",
                "SettingsPage",
                "OnboardUI",
                "SharedUIKit",
                .product(name: "ClipperCoreKit", package: "ClipperCore")
            ]
        ),
        .target(
            name: "HomePage",
            dependencies: [
                "SharedUIKit",
                .product(name: "ClipperCoreKit", package: "ClipperCore"),
                .product(name: "MarkdownUI", package: "swift-markdown-ui")
            ]
        ),
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
        .target(name: "SharedUIKit"),
    ]
)
