// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "lightroom-template-helper",
    platforms: [.macOS(.v12)],
    products: [
        .executable(name: "lightroom-template-helper", targets: ["MainApp"])
    ],
    targets: [
        .executableTarget(
            name: "MainApp",
            path: "Sources/MainApp"
        )
    ]
)
