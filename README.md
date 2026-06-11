# PackTags

A hashtag notebook for Instagram creators, shipped on the App Store. Users organize hashtags into themes and packs, copy a pack in one tap, and (with a connected Instagram Business account) generate hashtag suggestions and view post analytics through the Meta Graph API.

## Tech stack

- **UIKit + SwiftUI hybrid** — the notebook (themes, packs, editor, settings) is UIKit; the connected-insights features (SmartG hashtag generation, Analytics) are SwiftUI presented via `UIHostingController`
- **Core Data** for persistence, **Swift Package Manager** for dependencies
- [`InstagramGraph`](https://github.com/A-bv/InstagramGraph) — my own SPM package wrapping the Meta Graph API, keeping all networking out of the app target
- `facebook-ios-sdk` for authentication
- **Swift Testing** for the unit suite

## Architecture

```
AppDelegate / SceneDelegate          launch, FBSDK bootstrap, first-run seeding
        │
        ▼
AppCoordinator ─── builds ──▶ AppDependencies (DI container)
        │                       ├─ PersistenceController        Core Data stack
        │                       ├─ CoreDataThemeRepository      data access (protocol-backed)
        │                       ├─ UserDefaultsAppSettings      typed settings
        │                       └─ ConnectedInsightsCoordinator Meta-API feature routing
        ▼
ThemeCoordinator ──▶ ThemeList │ PackList │ ThemeEditor │ Settings   (UIKit + MVVM)
        │
        └──▶ ConnectedInsightsCoordinator ──▶ FB Login │ SmartG │ Analytics   (SwiftUI)
                                                  │
                                                  └──▶ InstagramGraph package ──▶ Meta Graph API
```

**Patterns**

- **Coordinator** — view controllers never instantiate or present other screens; all navigation flows through coordinators, which makes every screen independently constructible and testable.
- **MVVM** — view controllers delegate logic to ViewModels that receive their dependencies through init injection.
- **Repository** — `ThemeRepositoryProtocol` abstracts Core Data behind a protocol; ViewModels are tested against the real implementation on an in-memory store, and coordinators against fakes.
- **Constructor DI** — `AppDependencies` is assembled once in `AppCoordinator` and threaded down explicitly. No singletons in the data path.

## Persistence design

Two separate Core Data stores, one stack implementation:

| Store | Model | Contents | Owner |
|---|---|---|---|
| PackTags | `PackTags.xcdatamodeld` | Themes and packs (the notebook) | `AppDependencies` (app lifetime) |
| SmartTags | `SmartTags.xcdatamodeld` | Saved generated hashtags | `ConnectedInsightsCoordinator` (lazy — loads on first SmartG use) |

Both are instances of `PersistenceController`, which supports an in-memory mode for tests, loads each managed object model exactly once per process (a second load of the same model registers duplicate `NSEntityDescription`s and breaks entity resolution), and treats store-load/save failures as logged, recoverable errors rather than crashes.

The stores are kept separate deliberately: merging the models would force a store migration on every shipped device with no user-facing benefit.

## Conventions

- **Logging** — `AppLogger` exposes `os.Logger` instances per category (`lifecycle`, `persistence`, `login`, `insights`, `ui`). No `print()` in the app target.
- **Settings** — every UserDefaults key lives in `SettingsKey`; raw values are frozen because shipped devices already store data under them. Display strings and storage keys are never conflated (toggles once stored under their *localized* titles — a bug fixed in `caf6d76`).
- **Commit style** — title, then `Problem:` / `Fix:` / `Notes:` paragraphs. The history is intended to be readable as a narrative.

## Testing

```sh
xcodebuild -project PackTags.xcodeproj -scheme PackTags \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

30 tests in 4 suites:

- **Coordinator tests** — navigation wiring against spy navigation controllers and fake dependencies
- **Repository tests** — `CoreDataThemeRepository` end-to-end on an in-memory store: CRUD, ordering, and the tag-matching predicate
- **ViewModel tests** — `ThemeListViewModel` load/reorder/delete against the real repository
- **SmartG tests** — hashtag extraction alignment when posts lack captions

## Known tradeoffs / roadmap

- `AsyncImageForSui/` predates native SwiftUI `AsyncImage`; replacing it requires raising the deployment target from iOS 14 to 15.
- `UIImagePickerController` (photo-library mode) is deprecated in favor of `PHPickerViewController`.
- Crash reporting is not yet integrated (vendor decision pending).
- The analytics refresh throttle (`minimumSecondsBetweenRefreshes`) is set low pending a product decision.
