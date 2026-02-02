// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Intermission",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "Intermission",
            targets: ["Intermission"]
        )
    ],
    targets: [
        .target(
            name: "WebRTCVAD",
            path: "WebRTCVAD",
            publicHeadersPath: ".",
            cSettings: [
                .headerSearchPath(".")
            ]
        ),
        .executableTarget(
            name: "Intermission",
            dependencies: ["WebRTCVAD"],
            path: "Sources"
        )
    ]
)
