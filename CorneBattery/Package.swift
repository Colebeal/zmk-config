// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CorneBattery",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "CorneBattery",
            path: "CorneBattery",
            exclude: ["Info.plist", "CorneBattery.entitlements"]
        )
    ]
)
