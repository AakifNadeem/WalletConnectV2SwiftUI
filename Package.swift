// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WalletConnectV2SwiftUI",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "WalletConnectV2SwiftUI",
            targets: ["WalletConnectV2SwiftUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/WalletConnect/Web3.swift", exact: "1.0.2"),
        .package(url: "https://github.com/daltoniam/Starscream", exact: "3.1.2"),
        .package(url: "https://github.com/WalletConnect/WalletConnectSwiftV2.git", branch: "develop"),
        .package(url: "https://github.com/flypaper0/solana-swift", branch: "feature/available-13"),
        .package(url: "https://github.com/WalletConnect/HDWallet", branch: "develop"),
    ],
    targets: [
        .target(
            name: "WalletConnectV2SwiftUI",
            dependencies: [
                .product(name: "HDWalletKit", package: "HDWallet"),
                .product(name: "SolanaSwift", package: "solana-swift"),
                .product(name: "Web3", package: "Web3.swift"),
                .product(name: "Web3PromiseKit", package: "Web3.swift"),
                .product(name: "Web3ContractABI", package: "Web3.swift"),
                .product(name: "Starscream", package: "Starscream"),
                .product(name: "WalletConnect", package: "WalletConnectSwiftV2"),
                .product(name: "WalletConnectAuth", package: "WalletConnectSwiftV2"),
                .product(name: "WalletConnectModal", package: "WalletConnectSwiftV2")
                
            ],
            path: "Sources"
        )
    ]
)
