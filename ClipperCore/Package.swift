// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ClipperCore",
    platforms: [.iOS(.v17), .macOS(.v14), .visionOS(.v1)],
    products: [
        .library(
            name: "ClipperCoreKit",
            targets: ["ClipperCoreKit"]
        ),
        .library(name: "ToolSpecsManager", targets: ["ToolSpecsManager"])
    ],
    dependencies: [
        .package(url: "https://github.com/ml-explore/mlx-swift-examples",
                 branch: "main")
    ],
    targets: [
        .target(
            name: "ClipperCoreKit",
            dependencies: [
                "ToolSpecsManager",
                .product(name: "MLXLMCommon", package: "mlx-swift-examples"),
            ]
        ),
        .target(
            name: "ToolSpecsManager",
            dependencies: [
                .product(name: "MLXLMCommon", package: "mlx-swift-examples"),
            ]
        ),
        .target(
            name: "DynamicContent",
            dependencies: [
                "ToolSpecsManager",
            ]
        ),
    ]
)
