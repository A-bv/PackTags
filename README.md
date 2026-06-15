# PackTags

**A hashtag notebook for Instagram creators — shipped on the App Store.**

Organize hashtags into themes and packs, copy a pack in one tap, and — with a connected Instagram Business account — generate hashtag suggestions and read post analytics straight from the Meta Graph API.

[App Store](https://apps.apple.com/app/id1579377025) · iOS 17+ · v1.1.6

## What it does

- **Notebook** — group hashtags into themed packs; one tap copies a pack and optionally jumps to Instagram.
- **Smart cleanup** — automatic de-duplication across themes, invalid-tag stripping, and chunking into packs of your chosen size.
- **SmartG** — ranked hashtag suggestions mined from live Instagram posts for any search term.
- **Analytics** — per-post engagement, reach and views from the Meta Graph API, with value/rate toggles.
- **OCR import** — lift hashtags out of a screenshot with the Vision framework.

## Tech stack

- **iOS 17+**, **Swift** with `SWIFT_STRICT_CONCURRENCY = complete`
- **UIKit + SwiftUI hybrid** — UIKit notebook, SwiftUI insights bridged through `UIHostingController`
- **Core Data** persistence · **Swift Package Manager** · **Swift Testing**

## Architecture

A layered, testable design with one responsibility per layer:

```
SceneDelegate → AppCoordinator → AppDependencies (composition root)
                      │
         ┌────────────┴───────────────┐
   ThemeCoordinator          ConnectedInsightsCoordinator
   (UIKit notebook)          (SwiftUI insights)
         │                            │
   ViewModels ──▶ Domain ──▶ Repository ──▶ Core Data
                                       remote ──▶ InstagramGraph ──▶ Meta Graph API
```

- **Coordinator** — view controllers never present each other; all navigation lives in one place.
- **MVVM** — view models own the decisions and receive every dependency through `init`; views render outcomes. The settings screen goes further: a pure `SettingsSections` catalog with behaviors injected as `SettingsActions`.
- **Domain layer** — product rules (hashtag parsing, cross-theme dedup, pack chunking) as pure types with no UIKit or UserDefaults — they would survive an Android rewrite.
- **Repository** — `ThemeRepositoryProtocol` hides Core Data behind a protocol.
- **Constructor DI** — `AppDependencies` is assembled once and threaded down explicitly; a typed `AppSettings` wraps UserDefaults. Collaborators are injected, not reached for globally.
- **Hybrid bridge** — the SwiftUI insights area is presented from the UIKit flow via `UIHostingController`.

## Modern iOS practices

Built to current Apple guidance rather than legacy patterns:

| Area | What it uses |
|---|---|
| State | **`@Observable` + `@State`** view models — the iOS 17 model, no `ObservableObject` / `@Published` |
| Concurrency | `async`/`await`, `@MainActor`-isolated view models, views driven from `.task`, strict-concurrency build |
| Search | system **`UIFindInteraction`** find panel — no hand-rolled search bar |
| Photos | **`PHPickerViewController`** — out-of-process, no photo-library permission prompt |
| Vision | **`VNRecognizeTextRequest`** OCR for hashtag import |
| Networking | **`NWPathMonitor`** offline detection |
| Parsing | **Swift Regex** for hashtag extraction |
| Caching | **`OSAllocatedUnfairLock`** guarding the shared Core Data model cache |
| Logging | **`os.Logger`** categories — no `print()` |
| Reviews | **StoreKit `AppStore.requestReview`** behind a launch/version policy |

## Project layout

```
PackTags/
├─ App/            launch, composition root, coordinators bootstrap
├─ Coordinators/   all navigation (both UIKit and SwiftUI areas)
├─ Domain/         pure product rules (parsing, dedup, chunking)
├─ Data/           Core Data stack, repository, typed AppSettings
├─ Features/       Notebook · ConnectedInsights · Settings · Onboarding
├─ DesignSystem/   neumorphic styling, shared UI components
└─ Shared/         app-wide utilities (logger, alerts, links)
```

Self-contained pieces live at the narrowest scope that fits and are promoted only on a second consumer or genuine genericization — three reusable units (`InstagramGraph`, `TapTagKit`, `TableViewControllerCoverKit`) earned their own SPM packages.

## Dependencies

| Package | Role |
|---|---|
| [InstagramGraph](https://github.com/A-bv/InstagramGraph) | my own SPM package — the app's **remote data layer** wrapping the Meta Graph API |
| [TapTagKit](https://github.com/A-bv/TapTagKit) | my own SPM package — tap-to-multi-select hashtags in any `UITextView` |
| [TableViewControllerCoverKit](https://github.com/A-bv/TableViewControllerCoverKit) | my own SPM package — a table list over a stretchy cover image |
| [facebook-ios-sdk](https://github.com/facebook/facebook-ios-sdk) | Meta authentication |

Networking was deliberately extracted into `InstagramGraph` so every Meta API call lives — and is versioned — outside the app target.

## Getting started

Requirements: a recent Xcode (iOS 17 SDK or newer).

```sh
git clone https://github.com/A-bv/PackTags.git
cd PackTags
open PackTags.xcodeproj   # Xcode resolves the Swift packages on open
```

Pick the **PackTags** scheme and any iOS 17+ simulator, then Run (⌘R). The notebook works fully offline; **SmartG** and **Analytics** need a Facebook login linked to an Instagram Business/Creator account.

## Roadmap

- Swift 6 language mode (strict concurrency is already `complete`)
- Crash-reporting integration (vendor TBD)
