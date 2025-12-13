// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ClipperCore",
    platforms: [.iOS(.v18), .macOS(.v14)],
    products: [
        .library(
            name: "ClipperCoreKit",
            targets: ["ClipperCoreKit"]
        ),
        .library(name: "ToolSpecsManager", targets: ["ToolSpecsManager"])
    ],
    dependencies: [
        .package(url: "https://github.com/ml-explore/mlx-swift-lm",
                 branch: "main")
    ],
    targets: [
        .target(
            name: "ClipperCoreKit",
            dependencies: [
                "ToolSpecsManager",
                .product(name: "MLXLLM", package: "mlx-swift-lm"),
                .product(name: "MLXLMCommon", package: "mlx-swift-lm"),
            ]
        ),
        .target(
            name: "ToolSpecsManager",
            dependencies: [
                .product(name: "MLXLMCommon", package: "mlx-swift-lm"),
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
