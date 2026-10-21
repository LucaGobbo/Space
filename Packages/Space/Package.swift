// swift-tools-version: 6.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Space",
    defaultLocalization: "en",
    platforms: [.iOS(.v26), .macOS(.v26)],
    products: [
        .library(
            name: "Space",
            targets: ["Space"]
        ),
        .library(
            name: "SpaceUI",
            targets: ["SpaceUI"]
        ),
        .library(
            name: "SpaceCore",
            targets: ["SpaceCore"]
        ),
        .library(
            name: "SpacePaging",
            targets: ["SpacePaging"]
        ),
        .library(
            name: "SpaceAPI",
            targets: ["SpaceAPI"]
        ),
        .library(
            name: "SpaceDomain",
            targets: ["SpaceDomain"]
        ),
        .library(
            name: "SpaceData",
            targets: ["SpaceData"]
        ),
        .library(
            name: "LaunchesOverviewFeature",
            targets: ["LaunchesOverviewFeature"]
        ),
        .library(
            name: "RocketsOverviewFeature",
            targets: ["RocketsOverviewFeature"]
        ),
        .library(
            name: "LaunchDetailFeature",
            targets: ["LaunchDetailFeature"]
        ),
        .library(
            name: "RocketDetailFeature",
            targets: ["RocketDetailFeature"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.19.6")
    ],
    targets: [
        .target(
            name: "SpaceUI",
            dependencies: ["SpaceDomain"],
            resources: [.process("Localizable.xcstrings")],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
                .defaultIsolation(MainActor.self),
            ],
        ),
        .target(
            name: "SpaceCore",
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency")
            ],
        ),
        .target(
            name: "SpacePaging",
            dependencies: ["SpaceCore"],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
                .defaultIsolation(MainActor.self),
            ],
        ),
        .target(
            name: "LaunchesOverviewFeature",
            dependencies: ["SpaceDomain", "SpacePaging", "SpaceUI"],
            resources: [.process("Localizable.xcstrings")],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
                .defaultIsolation(MainActor.self),
            ],
        ),
        .target(
            name: "RocketsOverviewFeature",
            dependencies: ["SpaceDomain", "SpacePaging", "SpaceUI"],
            resources: [.process("Localizable.xcstrings")],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
                .defaultIsolation(MainActor.self),
            ],
        ),
        .target(
            name: "LaunchDetailFeature",
            dependencies: ["SpaceDomain", "SpaceUI"],
            resources: [.process("Localizable.xcstrings")],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
                .defaultIsolation(MainActor.self),
            ],
        ),
        .target(
            name: "RocketDetailFeature",
            dependencies: ["SpaceCore", "SpaceDomain", "SpaceUI"],
            resources: [.process("Localizable.xcstrings")],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
                .defaultIsolation(MainActor.self),
            ],
        ),
        .target(
            name: "SpaceAPI",
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency")
            ],
        ),
        .target(
            name: "SpaceDomain",
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency")
            ],
        ),
        .target(
            name: "SpaceData",
            dependencies: ["SpaceAPI", "SpaceDomain"],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency")
            ],
        ),
        .target(
            name: "Space",
            dependencies: [
                "LaunchesOverviewFeature", "RocketsOverviewFeature",
                "LaunchDetailFeature", "RocketDetailFeature",
                "SpaceDomain", "SpaceData",
            ],
            resources: [.process("Localizable.xcstrings")],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency")
            ],
        ),
        .testTarget(
            name: "SpaceUITests",
            dependencies: [
                "SpaceUI", "SpaceDomain",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency")
            ],
        ),
        .testTarget(
            name: "SpacePagingTests",
            dependencies: ["SpacePaging"],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency")
            ],
        ),
        .testTarget(
            name: "LaunchesOverviewFeatureTests",
            dependencies: ["LaunchesOverviewFeature", "SpaceDomain"],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency")
            ],
        ),
        .testTarget(
            name: "RocketsOverviewFeatureTests",
            dependencies: ["RocketsOverviewFeature", "SpaceDomain"],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency")
            ],
        ),
        .testTarget(
            name: "SpaceDataTests",
            dependencies: ["SpaceData", "SpaceAPI", "SpaceDomain"],
            resources: [.copy("Fixtures")],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency")
            ],
        ),
    ]
)
