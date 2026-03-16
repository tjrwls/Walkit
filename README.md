# WalkIt

WalkIt is an iOS walking companion app built with SwiftUI. It combines walking records, emotion tracking, character growth, and social features into a single experience.

## Overview

- Record walking activity and view route-based history
- Track emotions before or after walking
- Grow and customize a character with animation assets
- Manage missions, goals, notifications, and my page settings
- Support third-party login and push notifications

## Tech Stack

- SwiftUI
- MVVM-style screen structure
- CocoaPods
- Swift Package Manager
- Kakao Maps SDK
- Kakao Login SDK
- Naver Login SDK
- Firebase Messaging
- Realm
- Lottie
- Kingfisher
- Alamofire

## Project Structure

```text
WalkIt 4/
├── Config/                  # Local/build configuration
├── WalkIt/                  # App source
│   ├── Model/               # Domain models
│   ├── Protocol/            # Protocol definitions
│   ├── Servicee/            # Shared services and managers
│   ├── View/                # SwiftUI screens and reusable UI
│   ├── ViewModel/           # Screen view models
│   ├── Assets.xcassets/     # Images and app assets
│   └── LottieJson/          # Lottie animation files
├── WalkItTests/             # Unit tests
├── WalkItUITests/           # UI tests
├── Podfile
└── WalkIt.xcworkspace
```

## Features

### Authentication

- Kakao login
- Naver login
- Sign up flow and onboarding screens

### Walking

- Walking screen and walking record history
- Route visualization with Kakao Maps
- Step-related data handling

### Character

- Animated character rendering with Lottie
- Dressing room and item-based customization

### User

- My page
- Goal management
- Mission management
- Notification settings

## Requirements

- Xcode 16 or later recommended
- iOS 16.0 or later recommended
- CocoaPods installed

## Getting Started

1. Clone the repository.
2. Install CocoaPods dependencies.
3. Open the workspace file in Xcode.
4. Add the required local configuration files.
5. Build and run on a simulator or physical device.

```bash
git clone <your-repo-url>
cd WalkIt
pod install
open WalkIt.xcworkspace
```

## Local Configuration

This project uses local secrets and service configuration that should not be committed.

### Required files

- `WalkIt/GoogleService-Info.plist`
- `Config/Secrets.xcconfig`

### Recommended approach

- Keep real keys out of Git
- Copy `Config/Secrets.example.xcconfig` to `Config/Secrets.xcconfig`
- Add sample placeholders or document the required keys separately
- Share actual configuration files only through a secure channel

Example:

```bash
cp Config/Secrets.example.xcconfig Config/Secrets.xcconfig
```

## Dependencies

### CocoaPods

- `KakaoMapsSDK 2.12.0`

### Swift Package Manager

- Firebase iOS SDK
- Kakao iOS SDK
- Naver Login SDK
- Realm Swift
- Lottie
- Kingfisher
- Alamofire

## Git Ignore Notes

The repository is configured to exclude:

- `Pods/`
- `xcuserdata/`
- `*.xcuserstate`
- `GoogleService-Info.plist`
- `Config/Secrets.xcconfig`
- Derived/build artifacts

If another developer clones the project, they should run:

```bash
pod install
```

## Screens

- Login / Sign Up
- Home
- Walking
- Walking Record
- Character Shop / Dressing Room
- My Page

## Roadmap

- Improve test coverage
- Add clearer environment setup for third-party services
- Add screenshots and demo GIFs

## License

No license has been specified yet.
