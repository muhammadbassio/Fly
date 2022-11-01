// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "Fly",
	platforms: [
		.iOS(.v15),
		.macOS(.v11)
	],
	products: [
		.library(
			name: "Fly",
			targets: ["Fly"]),
	],
	targets: [
		.target(
			name: "Fly",
			dependencies: [])
	]
)
