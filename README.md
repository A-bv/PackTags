# PackTags

**The notebook for Instagram hashtags. [Shipped on the App Store](https://apps.apple.com/app/id1579377025).**

[![CI](https://github.com/A-bv/PackTags/actions/workflows/ci.yml/badge.svg)](https://github.com/A-bv/PackTags/actions/workflows/ci.yml)
![Swift 6](https://img.shields.io/badge/Swift-6-F05138?logo=swift&logoColor=white)
![iOS 17+](https://img.shields.io/badge/iOS-17%2B-007AFF?logo=apple&logoColor=white)
![UIKit + SwiftUI](https://img.shields.io/badge/UI-UIKit%20%2B%20SwiftUI-8E44AD)
![App Store](https://img.shields.io/badge/App%20Store-shipped-2ECC71)

Save hashtags as reusable themed packs, copy a pack in one tap, and lift tags straight out of a screenshot. Connect an Instagram Business account through the official Meta Graph API and PackTags also finds live hashtags for any topic and reports how your recent posts performed.

<p align="center">
  <img src="docs/screenshots/overview.png" width="185" alt="Post analytics, the hashtag editor, a themed pack, and the theme list">
  <img src="docs/screenshots/dark-mode.png" width="185" alt="A themed pack in dark mode">
  <img src="docs/screenshots/editor.png" width="185" alt="The tap-to-select hashtag editor over a themed pack">
  <img src="docs/screenshots/smart-hashtags.png" width="185" alt="Smart Hashtags: discover tags for any topic, ranked by frequency in recent posts">
</p>

## Engineering

A production iOS app built to a senior bar. Every technique below is verifiable in the source.

**Modern Swift & concurrency**
- **Swift 6 language mode** with `SWIFT_STRICT_CONCURRENCY = complete`. The whole target compiles under full data-race checking, not the opt-in minimal mode.
- **Observation, not Combine.** View models are `@Observable`; there is no `ObservableObject`, `@Published`, or `@StateObject` anywhere in the codebase.
- **Structured concurrency with real cancellation:** a custom `withThrowingTimeout` that races the work against `Task.sleep` in a task group and cancels the loser; generation-token guards that discard superseded searches; cooperative `Task.checkCancellation()` on in-flight requests.
- **`@MainActor` isolation throughout**, with documented `@unchecked Sendable` and region-isolation handling where the strict-concurrency checker needs it.

**Architecture & testability**
- **MVVM-C.** Coordinators own every navigation decision; views never present each other. ([conventions](docs/CONVENTIONS.md))
- **Protocol-driven DI from a single composition root.** No app singletons; every dependency arrives through `init`, so every unit test runs against fakes.
- **Pure domain layer.** Hashtag parsing and pack-chunking are value types with no UIKit and no persistence import.
- **Repository pattern over Core Data**, behind protocols, on in-memory stores in tests.
- **Modular by extraction.** Networking, tag editing, and the reusable UI live in five first-party Swift packages (`InstagramGraph`, `TapTagKit`, and three more) maintained separately from the app.

**Production quality**
- **Observability:** `os.Logger` categories (no `print`), `OSSignposter` intervals on hot paths for Instruments, and **MetricKit** capture of crashes, hangs, and launch time.
- **Accessibility as a CI gate:** automated `performAccessibilityAudit()` UI tests, pervasive Dynamic Type via `UIFontMetrics`, and deliberate VoiceOver labels and traits.
- **Performance baseline:** a cold-launch `XCTApplicationLaunchMetric` test that gates regressions.
- **Fully localized** in English and French, with a privacy manifest (`PrivacyInfo.xcprivacy`).

**Tests & tooling**
- **Swift Testing** (`@Test` / `#expect`) for units, **snapshot tests** for the design system, and **XCUITest** for the accessibility and launch metrics above.
- **SwiftLint enforced in CI.** The pipeline lints, then builds and tests on every PR, auto-discovering a simulator rather than hardcoding one.

**Platform APIs used deliberately:** `UIFindInteraction` (system find panel), `PHPickerViewController` (out-of-process photo access), Vision `VNRecognizeTextRequest` (OCR import), `NWPathMonitor` (connectivity), Swift Regex (parsing), StoreKit `AppStore.requestReview` (behind a launch/version policy).

## Architecture

MVVM-C (Model, View, ViewModel, Coordinator) over a Domain / Repository core, wired by one composition root. Two data sources share one shape: local data flows through repositories over Core Data; remote data is decoded into value models by the `InstagramGraph` package behind an `async` gateway, so the app target contains no networking code of its own.

<p align="center">
  <img src="docs/architecture.svg" alt="MVVM-C architecture: a coordinator creates a View and ViewModel; the ViewModel uses the Domain layer and persists through a Repository (Core Data) or the InstagramGraph gateway (Meta Graph API); AppDependencies injects everything." width="800">
</p>

<p align="center">
  <img src="docs/coordinators.svg" alt="Coordinator tree: AppCoordinator starts NotebookCoordinator (ThemeList, PackList, ThemeEditor; children SettingsCoordinator with Settings and QuantityPicker, and OnboardingCoordinator with Onboarding) and ConnectedInsightsCoordinator (SmartG, Analytics; child FacebookLoginCoordinator with FacebookLoginView and SetupInfoView)." width="800">
</p>

The conventions the codebase holds to (layering, DI, naming, who presents what) are documented in **[docs/CONVENTIONS.md](docs/CONVENTIONS.md)**.

> **Worked example.** Diagnosing why analytics silently broke after a Facebook SDK upgrade (the classic Graph token's validity became coupled to App Tracking Transparency) is written up as an ADR, with the on-device test matrix and the alternatives weighed: **[docs/CONNECTED_INSIGHTS_ATT.md](docs/CONNECTED_INSIGHTS_ATT.md)**.

## Build & run

Requires Xcode with the iOS 17 SDK.

```sh
git clone https://github.com/A-bv/PackTags.git
cd PackTags
cp Secrets.xcconfig.template Secrets.xcconfig   # placeholder is enough to build
open PackTags.xcodeproj                          # SPM resolves packages on open
```

Run the **PackTags** scheme on any iOS 17+ simulator. The notebook works offline out of the box; the connected features additionally need real Facebook credentials in `Secrets.xcconfig` and an Instagram Business account, which the app walks you through linking.

```sh
# tests
xcodebuild test -scheme PackTags \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

## Author

Built and maintained by [A-bv](https://github.com/A-bv).
