# PackTags

**A hashtag manager for Instagram creators — shipped on the App Store.**

![Platform](https://img.shields.io/badge/platform-iOS%2017%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5-orange)
![UI](https://img.shields.io/badge/UI-UIKit%20%2B%20SwiftUI-9cf)
![App Store](https://img.shields.io/badge/App%20Store-live-brightgreen)

## Overview

Creators reuse the same hashtags every day, but Instagram gives them nowhere to keep, clean, or reason about them. PackTags is that missing notebook: save hashtags as reusable themed packs, copy a pack in one tap, and keep every list tidy. Connect an Instagram Business account — through the **official Meta Graph API** — and it also surfaces trending hashtags and shows how your recent posts performed.

Built with UIKit + SwiftUI on an MVVM-C architecture, fully testable and on the App Store today.

## Features

- **Themed packs** — organize your hashtags and copy a whole pack in one tap.
- **Import & cleanup** — lift hashtags straight out of any screenshot, then auto-remove duplicates across themes and strip invalid tags.
- **Hashtag discovery** — find new hashtags pulled live from trending Instagram posts.
- **Post analytics** — engagement, reach and views for your recent posts.

## Screenshots

| Notebook | Discovery | Analytics |
|:---:|:---:|:---:|
| _docs/screenshots/notebook.png_ | _docs/screenshots/discovery.png_ | _docs/screenshots/analytics.png_ |

> Placeholders — drop PNGs into `docs/screenshots/` to populate.

## Architecture

PackTags follows **MVVM-C** — Model · View · ViewModel · Coordinator — over a Domain / Repository core, wired by a single composition root.

<p align="center">
  <img src="docs/architecture.svg" alt="MVVM-C architecture: a coordinator creates a View and ViewModel; the ViewModel uses the Domain layer and persists through a Repository (Core Data) or the InstagramGraph gateway (Meta Graph API); AppDependencies injects everything." width="800">
</p>
<p align="center"><em>Figure 1 — how one feature slice fits together.</em></p>

- **Coordinators own navigation.** A coordinator builds a screen's view model from the shared `AppDependencies`, injects it into the view, and performs every push/present. Views never reach for another screen.
- **View models own the logic**, with dependencies passed through `init`. SwiftUI screens use `@Observable`, `@MainActor` view models the view drives from `.task`; the UIKit notebook uses lightweight view models that signal changes through a closure.
- **Model.** `ThemeCD` (the Core Data entity) is the notebook's model; the insights features decode remote models — `Profile`, `InstagramPost` — and map them to presentation types.
- **Domain holds the product rules.** Parsing, de-duplication and pack chunking are small types, free of UIKit and reaching persistence only through the `Repository` protocol.
- **Two data sources, one shape.** Local data flows through a `Repository` over Core Data; remote data flows through the `InstagramGraph` package behind an `async` gateway. The app target contains no networking code of its own.

### Coordinator tree

`AppCoordinator` lives for the app's lifetime and starts the two area coordinators — the UIKit notebook and the SwiftUI insights — each of which presents its own screens.

<p align="center">
  <img src="docs/coordinators.svg" alt="Coordinator tree: AppCoordinator starts ThemeCoordinator (ThemeList, PackList, ThemeEditor, Settings, Onboarding, QuantityPicker) and ConnectedInsightsCoordinator (FBLogin, InfoSetup, SmartG, Analytics)." width="800">
</p>
<p align="center"><em>Figure 2 — every navigation path in the app (updated 2026-06-15).</em></p>

## Engineering highlights

Built on current Apple APIs rather than legacy patterns:

| Concern | API |
|---|---|
| State (SwiftUI) | `@Observable` + `@State` — no `ObservableObject` / `@Published` |
| Concurrency | `async`/`await`, `@MainActor` isolation; Swift 5 mode with `SWIFT_STRICT_CONCURRENCY = complete` |
| In-text search | `UIFindInteraction` system find panel |
| Photo picking | `PHPickerViewController` (out-of-process, no permission prompt) |
| OCR | Vision `VNRecognizeTextRequest` |
| Connectivity | `NWPathMonitor` |
| Hashtag parsing | Swift Regex |
| Reviews | StoreKit `AppStore.requestReview` behind a launch/version policy |
| Logging | `os.Logger` categories — no `print()` |

## Dependencies

Managed with Swift Package Manager (resolved automatically when you open the project).

| Package | Role |
|---|---|
| https://github.com/A-bv/InstagramGraph | remote data layer wrapping the Meta Graph API |
| https://github.com/A-bv/TapTagKit | tap-to-select hashtags in any `UITextView` |
| https://github.com/A-bv/TableViewControllerCoverKit | table list over a stretchy cover image |
| https://github.com/facebook/facebook-ios-sdk | authentication |

`InstagramGraph`, `TapTagKit` and `TableViewControllerCoverKit` are first-party packages — extracted from PackTags and maintained separately, so the networking and reusable UI evolve independently of the app.

## Installation

**Requirements:** a recent Xcode with the iOS 17 SDK.

```sh
git clone https://github.com/A-bv/PackTags.git
open "PackTags/PackTags.xcodeproj"   # Xcode resolves the Swift packages on open
```

Run the **PackTags** scheme on any iOS 17+ simulator (⌘R). The notebook works offline; the connected features need an Instagram Business account, which the app walks you through linking.

## Testing

```sh
xcodebuild -project PackTags.xcodeproj -scheme PackTags \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

Unit tests use **Swift Testing** and run the domain rules, the repository (on an in-memory Core Data store), view-model decisions, and coordinator wiring.

## Roadmap

- **Crash & error reporting** — evaluating Sentry vs. Firebase Crashlytics.
- **Swift 6 language mode** — strict concurrency is already `complete`.
- **CI** — build + test on every push.

## Author

Built and maintained by [A-bv](https://github.com/A-bv).
