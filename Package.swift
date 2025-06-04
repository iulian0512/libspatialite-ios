// swift-tools-version:5.9
import PackageDescription

let package = Package(
  name: "libspatialite",
  platforms: [.iOS(.v17)],
  products: [
    .library(name: "SpatialiteObjC", type: .dynamic, targets: ["SpatialiteObjC"]),
    .library(name: "libspatialite", targets: ["libspatialite"]),
  ],
  targets: [
    .binaryTarget(
      name: "libspatialite",
      url: "https://github.com/mozi-app/libspatialite-ios/releases/download/v5.1.0/libspatialite.xcframework.zip",
      checksum: "f152b53c5c042544ec1d97eb50be1f8d129c6d2b33a2b627322930997ffe24ba"
    ),
    .target(
      name: "SpatialiteObjC",
      dependencies: [
        "libspatialite"
      ],
      path: "Sources/SpatialiteObjC",
      exclude: [],
      sources: ["LibSpatialite.m"],
      linkerSettings: [
        .linkedLibrary("z"),
        .linkedLibrary("iconv"),
        .linkedLibrary("c++"),
      ]
    ),
  ]
)
