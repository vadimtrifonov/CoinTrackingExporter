// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CryptoSAK",
    platforms: [
        .macOS(.v10_15),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.1"),
        .package(url: "https://github.com/dehesa/CodableCSV.git", from: "0.6.5")
    ],
    targets: [
        .target(
            name: "CryptoSAK",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "CodableCSV", package: "CodableCSV"),
                "Algorand",
                "AlgorandAlgoExplorer",
                "CoinTracking",
                "Ethereum",
                "EthereumEtherscan",
                "FoundationExtensions",
                "Gate",
                "Hashgraph",
                "HashgraphDragonGlass",
                "IDEX",
                "Kusama",
                "KusamaSubscan",
                "Networking",
                "Polkadot",
                "PolkadotSubscan",
                "Tezos",
                "TezosCapital",
                "TezosTzStats"
            ]
        ),
        .target(
            name: "Algorand",
            dependencies: []
        ),
        .target(
            name: "AlgorandAlgoExplorer",
            dependencies: [
                "Algorand",
                "FoundationExtensions",
                "Networking",
            ]
        ),
        .target(
            name: "CoinTracking",
            dependencies: [
                "FoundationExtensions",
            ]
        ),
        .target(
            name: "Ethereum",
            dependencies: []
        ),
        .target(
            name: "EthereumEtherscan",
            dependencies: [
                "Ethereum",
                "FoundationExtensions",
                "Networking",
            ]
        ),
        .target(
            name: "FoundationExtensions",
            dependencies: []
        ),
        .target(
            name: "Gate",
            dependencies: [
                "FoundationExtensions"
            ]
        ),
        .target(
            name: "Hashgraph",
            dependencies: []
        ),
        .target(
            name: "HashgraphDragonGlass",
            dependencies: [
                "Hashgraph",
                "FoundationExtensions",
                "Networking",
            ]
        ),
        .target(
            name: "IDEX",
            dependencies: [
                "FoundationExtensions"
            ]
        ),
        .target(
            name: "Kusama",
            dependencies: []
        ),
        .target(
            name: "KusamaSubscan",
            dependencies: [
                "FoundationExtensions",
                "Kusama",
                "Networking",
            ]
        ),
        .target(
            name: "Networking",
            dependencies: []
        ),
        .target(
            name: "Polkadot",
            dependencies: []
        ),
        .target(
            name: "PolkadotSubscan",
            dependencies: [
                "FoundationExtensions",
                "Networking",
                "Polkadot",
            ]
        ),
        .target(
            name: "Tezos",
            dependencies: []
        ),
        .target(
            name: "TezosCapital",
            dependencies: [
                "FoundationExtensions",
                "Networking"
            ]
        ),
        .target(
            name: "TezosTzStats",
            dependencies: [
                "Tezos",
                "FoundationExtensions",
                "Networking"
            ]
        ),
    ]
)
