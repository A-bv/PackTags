# PackTags — Engineering

The full set of techniques behind the app, grouped by concern. The README carries the
highlights; this is the complete breakdown.

## Modern Swift & concurrency
- Swift 6 language mode with `SWIFT_STRICT_CONCURRENCY = complete`. The whole target compiles under full data-race checking, not the opt-in minimal mode.
- Observation, not Combine. View models are `@Observable`; there is no `ObservableObject`, `@Published`, or `@StateObject` anywhere in the codebase.
- Structured concurrency with real cancellation: a custom `withThrowingTimeout` that races the work against `Task.sleep` in a task group and cancels the loser; generation-token guards that discard superseded searches; cooperative `Task.checkCancellation()` on in-flight requests.
- `@MainActor` isolation throughout, with documented `@unchecked Sendable` and region-isolation handling where the strict-concurrency checker needs it.

## Architecture & testability
- MVVM-C. Coordinators own every navigation decision; views never present each other. ([conventions](CONVENTIONS.md))
- Protocol-driven DI from a single composition root. No app singletons; every dependency arrives through `init`, so every unit test runs against fakes.
- Pure domain layer. Hashtag parsing and pack-chunking are value types with no UIKit and no persistence import.
- Repository pattern over Core Data, behind protocols, on in-memory stores in tests.
- Modular by extraction. Networking, tag editing, and the reusable UI live in five first-party Swift packages ([`InstagramGraph`](https://github.com/A-bv/InstagramGraph), [`TapTagKit`](https://github.com/A-bv/TapTagKit), [`TableViewControllerCoverKit`](https://github.com/A-bv/TableViewControllerCoverKit), [`NeumorphicUIKit`](https://github.com/A-bv/NeumorphicUIKit), [`NeumorphicSwiftUI`](https://github.com/A-bv/NeumorphicSwiftUI)) maintained separately from the app.

## Production quality
- Observability: `os.Logger` categories (no `print`), `OSSignposter` intervals on hot paths for Instruments, and MetricKit capture of crashes, hangs, and launch time.
- Accessibility as a CI gate: automated `performAccessibilityAudit()` UI tests, pervasive Dynamic Type via `UIFontMetrics`, and deliberate VoiceOver labels and traits.
- Performance baseline: a cold-launch `XCTApplicationLaunchMetric` test that gates regressions.
- Fully localized in English and French, with a privacy manifest (`PrivacyInfo.xcprivacy`).

## Tests & tooling
- Swift Testing (`@Test` / `#expect`) for units, snapshot tests for the design system, and XCUITest for the accessibility and launch metrics above.
- SwiftLint enforced in CI. The pipeline lints, then builds and tests on every PR, auto-discovering a simulator rather than hardcoding one.

## Platform APIs used deliberately
`UIFindInteraction` (system find panel), `PHPickerViewController` (out-of-process photo access), Vision `VNRecognizeTextRequest` (OCR import), `NWPathMonitor` (connectivity), Swift Regex (parsing), StoreKit `AppStore.requestReview` (behind a launch/version policy).
