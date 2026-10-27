// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AbrovaAuthExample",
    platforms: [.iOS(.v16), .macOS(.v13)],
    dependencies: [
        .package(name: "AbrovaAuth", path: "../"),
    ],
    targets: [
        .executableTarget(
            name: "AbrovaAuthExample",
            dependencies: [
                .product(name: "AbrovaAuth", package: "AbrovaAuth"),
            ],
            path: "AbrovaAuthExample",
            exclude: ["Info.plist"]
        ),
    ]
)
