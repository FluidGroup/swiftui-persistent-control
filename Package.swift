// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "swiftui-persistent-control",
  platforms: [.iOS(.v18)],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "SwiftUIPersistentControl",
      targets: ["SwiftUIPersistentControl"])
  ],
  dependencies: [
    .package(url: "https://github.com/FluidGroup/swiftui-scrollview-interoperable-drag-gesture", from: "0.2.1")
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "SwiftUIPersistentControl",
      dependencies: [
        .product(name: "SwiftUIScrollViewInteroperableDragGesture", package: "swiftui-scrollview-interoperable-drag-gesture")
      ]
    ),
    .testTarget(
      name: "SwiftUIPersistentControlTests",
      dependencies: ["SwiftUIPersistentControl"]
    ),
  ]
)
