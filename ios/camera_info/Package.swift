// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "camera_info",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "camera-info", targets: ["camera_info"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "camera_info",
            dependencies: [.product(name: "FlutterFramework", package: "FlutterFramework")],
            resources: [.process("PrivacyInfo.xcprivacy")]
        )
    ]
)
