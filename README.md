# PackTags

A hashtag notebook for Instagram creators, shipped on the App Store. Users organize hashtags into themes and packs, copy a pack in one tap, and (with a connected Instagram Business account) generate hashtag suggestions and view post analytics through the Meta Graph API.

## Tech stack

- **iOS 16+**, **UIKit + SwiftUI hybrid** — the notebook is UIKit; the connected-insights features (SmartG hashtag generation, Analytics) are SwiftUI presented via `UIHostingController`
- **Core Data** for persistence, **Swift Package Manager** for dependencies
- [`InstagramGraph`](https://github.com/A-bv/InstagramGraph) — my own SPM package wrapping the Meta Graph API: it is this app's **remote data layer**, extracted so all networking lives outside the app target
- `facebook-ios-sdk` for authentication
- **Swift Testing** for the unit suite

## Project layout

Every folder answers one question:

```
PackTags/
├─ App/               how does the app start and wire itself?
│                       AppDelegate(+Seed), SceneDelegate, AppCoordinator, AppDependencies
├─ Coordinators/      which screen comes next? — all navigation, both areas
├─ Domain/            what are the product's rules? (would survive an Android rewrite)
│                       TagPackFormatter, TagDeduplicator
├─ Data/              how is state persisted? — local half; remote half = InstagramGraph package
│                       PersistenceController, ThemeRepository, AppSettings, SettingsKey, Model/
├─ Features/          what can a user do? — a feature is a demoable end-to-end capability
│  ├─ Notebook/         the hashtag notebook (area: three screens share repo + domain)
│  │   ├─ ThemeList/  PackList/        View/ + ViewModel/
│  │   └─ ThemeEditor/                 View/ + ViewModel/ + Components/
│  ├─ ConnectedInsights/ (area: three features share the Meta connection)
│  │   ├─ Setup/  SmartG/  Analytics/  View/ + ViewModel/ + Model/
│  │   └─ Support/                     area-local deps (NetworkMonitor, AnalyticsCache…)
│  ├─ Settings/        catalog in SettingsSections, behaviors injected via SettingsActions
│  └─ Onboarding/
├─ DesignSystem/      how do things look? — app-wide primitives + Components/
└─ Shared/            what do 2+ areas actually reuse? (kept deliberately small)
```

**The component tiers** — self-contained functionality lives at the narrowest scope that fits, and is promoted only on a second consumer or genuine genericization (never speculatively):

1. `Features/<X>/Components/` — feature-local machinery
2. `DesignSystem/Components/` — app-wide generic UI
3. `Shared/` — app-wide non-visual utilities
4. SPM package — needed beyond the app (`InstagramGraph` is the one that earned it)

## Component inventory

| Component | Scope | Lives in | Does |
|---|---|---|---|
| TapTextView | ThemeEditor | `Notebook/ThemeEditor/Components/` | tap-to-multi-select hashtags with actions toolbar |
| TextRecognitionUtility | ThemeEditor | 〃 | Vision OCR — import hashtags from a photo |
| ImageTreatment | ThemeEditor | 〃 | UIImage resize / orientation for theme covers |
| TextSearchBar | app-wide | `DesignSystem/Components/TextSearch/` | drop-in UITextView search: highlight, scroll-to-match, count, edit lock (package candidate) |
| FloatingButtonFactory | app-wide | `DesignSystem/Components/` | floating gradient action button |
| Tag engine | app-wide | `Domain/` | hashtag parsing, cross-theme dedup, pack chunking |
| LoadingView, OfflineView, ActivityIndicator | app-wide | `DesignSystem/Components/` | reusable view states |
| Neumorphic styles, nav-bar/text-view helpers | app-wide | `DesignSystem/` | the app's visual language |
| AnalyticsCache | ConnectedInsights | `ConnectedInsights/Support/` | JSON cache for offline analytics |

## Architecture

```
AppDelegate / SceneDelegate          launch, FBSDK bootstrap, first-run seeding
        │
        ▼
AppCoordinator ─── builds ──▶ AppDependencies (composition root, in App/)
        │                       ├─ PersistenceController        Core Data stack
        │                       ├─ CoreDataThemeRepository      data access (protocol-backed)
        │                       ├─ UserDefaultsAppSettings      typed settings gateway
        │                       └─ ConnectedInsightsCoordinator Meta-area navigation
        ▼
ThemeCoordinator ──▶ Notebook screens │ Settings │ Onboarding      (UIKit + MVVM)
        │
        └──▶ ConnectedInsightsCoordinator ──▶ Setup │ SmartG │ Analytics   (SwiftUI)
                                                  │
                                                  └──▶ InstagramGraph package ──▶ Meta Graph API
```

**Patterns**

- **Coordinator** — view controllers never instantiate or present other screens; one folder owns all navigation.
- **MVVM** — ViewModels own the decisions and receive every dependency through init injection; view controllers render outcomes. The settings list takes it further: `SettingsSections` is a pure catalog, behaviors injected as `SettingsActions`.
- **Domain layer** — the product's core logic as pure, fully tested types with no UIKit or UserDefaults dependencies.
- **Repository** — `ThemeRepositoryProtocol` abstracts Core Data; ViewModels are tested against the real implementation on an in-memory store, coordinators against fakes.
- **Constructor DI** — `AppDependencies` is assembled once in `AppCoordinator` and threaded down explicitly. `AppSettingsProtocol` is the single typed gateway to UserDefaults; no singletons in the data path.
- **Main-actor isolation** — every ObservableObject ViewModel is `@MainActor`; groundwork for Swift 6 strict concurrency.

## Persistence design

Two separate Core Data stores, one stack implementation:

| Store | Model | Contents | Owner |
|---|---|---|---|
| PackTags | `Data/Model/PackTags.xcdatamodeld` | Themes and packs | `AppDependencies` (app lifetime) |
| SmartTags | `Data/Model/SmartTags.xcdatamodeld` | Saved generated hashtags | `ConnectedInsightsCoordinator` (lazy) |

Both are instances of `PersistenceController` (in-memory mode for tests, per-process shared model loading, logged non-fatal errors). The stores stay separate deliberately: merging models would force a store migration on every shipped device with no user-facing benefit.

## Conventions

- **Logging** — `AppLogger` exposes `os.Logger` per category (`lifecycle`, `persistence`, `login`, `insights`, `ui`). No `print()` in the app target.
- **Settings** — every UserDefaults key lives in `SettingsKey`; raw values are frozen (enforced by `SettingsKeyContractTests`) because shipped devices store data under them.
- **Naming** — types and files match; every feature is `View/` + `ViewModel/` (+ `Model/`, `Components/` as needed); extension files spell out the extended type.
- **Commit style** — title, then `Problem:` / `Fix:` / `Notes:` paragraphs. The history reads as a narrative.

## Testing

```sh
xcodebuild -project PackTags.xcodeproj -scheme PackTags \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

56 tests in 11 suites: domain rules, coordinator wiring (spy navigation), repository CRUD on an in-memory store, ViewModel decisions, the settings catalog, the SmartG caption-alignment case, and the frozen UserDefaults key contract. The `InstagramGraph` package carries its own 37-test suite, including the setup → ready regression pair.

## Known tradeoffs / roadmap

- `TextSearchBar`'s internals are scheduled to move to iOS 16's native `UIFindInteraction` with a keyboard-accessory search field; the component API stays.
- `UIImagePickerController` (photo-library mode) is deprecated in favor of `PHPickerViewController`.
- Crash reporting is not yet integrated (vendor decision pending).
- The analytics refresh throttle is set low pending a product decision.
- Swift 6 strict concurrency checking is the next modernization step.
