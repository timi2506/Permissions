# Permissions

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Ftimi2506%2FPermissions%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/timi2506/Permissions)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Ftimi2506%2FPermissions%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/timi2506/Permissions)

A Simple Permission Manager - built with SwiftUI in Mind

## Documentation

The Documentation is hosted on SwiftPackageIndex at https://swiftpackageindex.com/timi2506/Permissions/documentation

## Features

- Request and check authorization for the following permissions:
  - Camera
  - Microphone
  - Location (When In Use or Always)
  - Notifications (alert, sound, badge)
  - Photo Library (read/write)
  - Contacts
  - Bluetooth (currently unavailable, working on a Fix)
  
- Async/await API with `PermissionsManager` and `PermissionType` (Example: `await PermissionsManager.shared.requestPermissions(for: [.camera, .microphone])` and `await type.isAuthorized()`)
- SwiftUI integration: `.permissionsSheet(isPresented:skipGranted:permissions:)` modifier presents a sheet that shows details about each Permission and a Grant/Granted button with a completion screen
- Built-in, customizable localization via `PermissionsLocalizationProvider` (override titles, descriptions, and button labels)
- Info.plist safety checks for missing required usage descriptions
- 0 External Dependencies

## Showcase
You can see a showcase of this Package in its Example App "PermissionsExample"

TestFlight: https://testflight.apple.com/join/9d24muZE

GitHub Source Code: https://github.com/timi2506/PermissionsExample


## Requirements

- Swift 5.5 or later
- iOS 15+, iPadOS 15+

## Installation

### Swift Package Manager (SPM)

You can add this package to your project using Xcode:

1. In Xcode, go to File > Add Package Dependencies…
2. Enter the repository URL:
`https://github.com/timi2506/Permissions`
