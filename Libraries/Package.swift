// swift-tools-version: 6.2
import PackageDescription

let defaultSwiftSettings: [SwiftSetting] = [
    .swiftLanguageMode(.v6),
    .unsafeFlags(["-default-isolation", "MainActor"]),
    .enableUpcomingFeature("InferIsolatedConformances"),
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
]

let package = Package(
    name: "Libraries",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v26),
        .macOS(.v26),
    ],
    products: [
        .library(name: "Models", targets: ["Models"]),
        .library(name: "Services", targets: ["Services"]),
        .library(name: "SharedUI", targets: ["SharedUI"]),
        .library(name: "AIMentor", targets: ["AIMentor"]),
        .library(name: "AppFeature", targets: ["AppFeature"]),
    ],
    dependencies: [
        .package(url: "https://github.com/nathant99/forgekit.git", from: "0.99.0"),
    ],
    targets: [
        .target(
            name: "Models",
            dependencies: [
                .product(name: "ForgeModels", package: "forgekit"),
            ],
            swiftSettings: defaultSwiftSettings
        ),
        .target(
            name: "Services",
            dependencies: [
                "Models",
                .product(name: "ForgePersistence", package: "forgekit"),
                .product(name: "ForgeAI", package: "forgekit"),
                .product(name: "ForgeAnalytics", package: "forgekit"),
                .product(name: "ForgeGamification", package: "forgekit"),
            ],
            swiftSettings: defaultSwiftSettings
        ),
        .target(
            name: "SharedUI",
            dependencies: [
                "Models",
                .product(name: "ForgeUI", package: "forgekit"),
                .product(name: "ForgeAccessibility", package: "forgekit"),
            ],
            swiftSettings: defaultSwiftSettings
        ),
        .target(
            name: "AIMentor",
            dependencies: [
                "Models",
                .product(name: "ForgeAI", package: "forgekit"),
            ],
            swiftSettings: defaultSwiftSettings
        ),
        .target(
            name: "AppFeature",
            dependencies: [
                "Models",
                "Services",
                "SharedUI",
                "AIMentor",
                .product(name: "ForgeNavigation", package: "forgekit"),
                .product(name: "ForgeAdventure", package: "forgekit"),
                .product(name: "ForgeAvatar", package: "forgekit"),
                .product(name: "ForgeCelebration", package: "forgekit"),
                .product(name: "ForgeGamification", package: "forgekit"),
                .product(name: "ForgePedagogy", package: "forgekit"),
                .product(name: "ForgeStateMachine", package: "forgekit"),
            ],
            swiftSettings: defaultSwiftSettings
        ),
        .testTarget(
            name: "ForgeKitIntegrationTests",
            dependencies: [
                "Models",
                .product(name: "ForgeModels", package: "forgekit"),
                .product(name: "ForgeGamification", package: "forgekit"),
            ],
            swiftSettings: defaultSwiftSettings
        ),
        .testTarget(
            name: "ModelsTests",
            dependencies: [
                "Models",
            ],
            swiftSettings: defaultSwiftSettings
        ),
        .testTarget(
            name: "ServicesTests",
            dependencies: [
                "Models",
                "Services",
            ],
            swiftSettings: defaultSwiftSettings
        ),
    ]
)
