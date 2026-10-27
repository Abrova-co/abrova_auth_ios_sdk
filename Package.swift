// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "AbrovaAuth",
    platforms: [
        .iOS(.v13),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "AbrovaAuth",
            targets: ["AbrovaAuth"]
        ),
    ],
    targets: [
        .target(
            name: "AbrovaAuth",
            path: "Sources/AbrovaAuth"
        ),
        .testTarget(
            name: "AbrovaAuthTests",
            dependencies: ["AbrovaAuth"],
            path: "Tests/AbrovaAuthTests"
        ),
    ]
)
