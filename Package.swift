// swift-tools-version:6.0

import PackageDescription

let package = Package(
	name: "loadable-util",
  platforms: [
    .iOS(.v15),
    .macOS(.v12),
  ],
	products: [
		.library(
			name: "Loadable",
			targets: ["Loadable"]
		),
	],
	targets: [
		.target(name: "Loadable"),
		.testTarget(
			name: "LoadableTests",
			dependencies: ["Loadable"]
		),
	]
)
