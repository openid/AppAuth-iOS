// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

/*! @file Package.swift
   @brief AppAuth iOS SDK
   @copyright
       Copyright 2020 The AppAuth Authors. All Rights Reserved.
   @copydetails
       Licensed under the Apache License, Version 2.0 (the "License");
       you may not use this file except in compliance with the License.
       You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

       Unless required by applicable law or agreed to in writing, software
       distributed under the License is distributed on an "AS IS" BASIS,
       WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
       See the License for the specific language governing permissions and
       limitations under the License.
*/

let package = Package(
    name: "AppAuth",
    platforms: [
        .macOS(.v10_10),
        .iOS(.v9),
        .tvOS(.v9),
        .watchOS(.v2)
    ],
    products: [
        .library(
            name: "AppAuthCore",
            targets: ["AppAuthCore"]),
        .library(
            name: "AppAuth",
            targets: ["AppAuth"]),
        .library(
	        name: "AppAuthEnterpriseUserAgent",
	        targets: ["AppAuthEnterpriseUserAgent"]),
        .library(
            name: "AppAuthTV",
            targets: ["AppAuthTV"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "AppAuthCore",
            path: "Source/AppAuthCore",
            publicHeadersPath: ""
        ),
        .target(
            name: "AppAuth",
            dependencies: ["AppAuthCore"],
            path: "Source/AppAuth",
            sources: ["iOS", "macOS"],
            publicHeadersPath: "",
            cSettings: [
                .headerSearchPath("iOS"),
                .headerSearchPath("macOS"),
                .headerSearchPath("macOS/LoopbackHTTPServer"),
            ]
        ),
        .target(
            name: "AppAuthEnterpriseUserAgent",
            dependencies: ["AppAuthCore"],
            path: "Source/AppAuthEnterpriseUserAgent",
            sources: ["iOS"],
            publicHeadersPath: "",
            cSettings: [
                .headerSearchPath("iOS"),
            ]
        ),
        .target(
            name: "AppAuthTV",
            dependencies: ["AppAuthCore"],
            path: "Source/AppAuthTV",
            publicHeadersPath: ""
        ),
        .testTarget(
            name: "AppAuthCoreTests",
            dependencies: ["AppAuthCore"],
            path: "UnitTests",
            exclude: ["OIDSwiftTests.swift", "AppAuthTV"]
        ),
        .testTarget(
            name: "AppAuthCoreSwiftTests",
            dependencies: ["AppAuthCore"],
            path: "UnitTests",
            sources: ["OIDSwiftTests.swift"]
        ),
        .testTarget(
            name: "AppAuthTVTests",
            dependencies: ["AppAuthTV"],
            path: "UnitTests/AppAuthTV"
        ),
    ]
)
