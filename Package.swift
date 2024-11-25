// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "StoryboardHelper",
  platforms: [
    .iOS(.v13),
  ],
  products: [
    .library(
      name: "StoryboardHelper",
      targets: ["StoryboardHelper"]),
  ],
  targets: [
    .target(
      name: "StoryboardHelper"),
    .testTarget(
      name: "StoryboardHelperTests",
      dependencies: ["StoryboardHelper"]
    ),
  ]
)
