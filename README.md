# PackTags

**The notebook for Instagram hashtags, [shipped on the App Store](https://apps.apple.com/app/id1579377025).**

[![CI](https://github.com/A-bv/PackTags/actions/workflows/ci.yml/badge.svg)](https://github.com/A-bv/PackTags/actions/workflows/ci.yml)
![Swift 6](https://img.shields.io/badge/Swift-6-F05138?logo=swift&logoColor=white)
![iOS 17+](https://img.shields.io/badge/iOS-17%2B-007AFF?logo=apple&logoColor=white)
![UI](https://img.shields.io/badge/UI-UIKit%20%2B%20SwiftUI-9cf)
![App Store](https://img.shields.io/badge/App%20Store-shipped-blue)

Creators reuse the same hashtags every day, but Instagram gives them nowhere to keep or clean them. PackTags is that missing notebook: save hashtags as reusable themed packs, copy a pack in one tap, and keep every list tidy. Connect an Instagram Business account through the official Meta Graph API and PackTags also finds live hashtags for any topic and shows how your recent posts performed.

<p align="center">
  <img src="docs/screenshots/overview.png" width="185" alt="Post analytics, the hashtag editor, a themed pack, and the theme list">
  <img src="docs/screenshots/dark-mode.png" width="185" alt="A themed pack in dark mode">
  <img src="docs/screenshots/editor.png" width="185" alt="The tap-to-select hashtag editor over a themed pack">
  <img src="docs/screenshots/smart-hashtags.png" width="185" alt="Smart Hashtags: discover tags for any topic, ranked by frequency in recent posts">
</p>

## Features

- **Themed packs.** Organize hashtags by theme and copy a whole pack in one tap.
- **Import and cleanup.** Lift hashtags straight out of any screenshot; only well-formed `#tags` are kept and duplicates are dropped across themes.
- **Hashtag discovery.** Type any topic and get the top hashtags pulled live from recent Instagram posts.
- **Post analytics.** Engagement, reach, and impressions for your recent posts.
- **English and French.** Fully localized in both languages.

## Architecture

PackTags follows **MVVM-C** (Model, View, ViewModel, Coordinator) over a Domain / Repository core, wired by a single composition root.

<p align="center">
  <img src="docs/architecture.svg" alt="MVVM-C architecture: a coordinator creates a View and ViewModel; the ViewModel uses the Domain layer and persists through a Repository (Core Data) or the InstagramGraph gateway (Meta Graph API); AppDependencies injects everything." width="800">
</p>
<p align="center"><em>Figure 1: how one feature slice fits together.</em></p>

- **Coordinators own navigation.** A coordinator builds a screen's view model from the shared `AppDependencies`, injects it into the view, and performs every push and present. Views never reach for another screen.
- **View models own the logic**, with dependencies passed through `init`. SwiftUI screens use `@Observable`, `@MainActor` view models driven from `.task`; the UIKit notebook uses lightweight view models that signal changes through a closure.
- **Domain holds the product rules.** Hashtag parsing and pack-chunking are pure value types with no UIKit and no persistence; de-duplication reaches already-saved tags through a repository protocol.
- **Two data sources, one shape.** Local data flows through repositories over Core Data (`ThemeEntity`, saved hashtags); remote data is decoded into value models (`Profile`, `InstagramPost`) by the `InstagramGraph` package behind an `async` gateway. The app target contains no networking code of its own.

### Coordinator tree

`AppCoordinator` lives for the app's lifetime and starts the two areas: the UIKit notebook and the SwiftUI insights. Child coordinators own the settings, onboarding, and Facebook login flows.

<p align="center">
  <img src="docs/coordinators.svg" alt="Coordinator tree: AppCoordinator starts NotebookCoordinator (ThemeList, PackList, ThemeEditor; children SettingsCoordinator with Settings and QuantityPicker, and OnboardingCoordinator with Onboarding) and ConnectedInsightsCoordinator (SmartG, Analytics; child FacebookLoginCoordinator with FacebookLoginView and SetupInfoView)." width="800">
</p>
<p align="center"><em>Figure 2: every navigation path in the app.</em></p>

## Engineering highlights

Built on current Apple APIs rather than legacy patterns:

| Concern | API |
|---|---|
| State (SwiftUI) | `@Observable` + `@State`, no `ObservableObject` / `@Published` |
| Concurrency | `async`/`await`, `@MainActor` isolation, Swift 6 language mode with strict concurrency |
| In-text search | `UIFindInteraction` system find panel |
| Photo picking | `PHPickerViewController` (out-of-process, no permission prompt) |
| OCR | Vision `VNRecognizeTextRequest` |
| Connectivity | `NWPathMonitor` |
| Hashtag parsing | Swift Regex |
| Reviews | StoreKit `AppStore.requestReview` behind a launch/version policy |
| Logging | `os.Logger` categories, no `print()` |
| Linting | SwiftLint, enforced on every PR by CI |

## Case study: the Connected Insights / ATT regression

After upgrading the Facebook SDK (9 to 18), Instagram analytics silently stopped loading: the access token looked valid, but the Graph API rejected it with `Cannot parse access token`. Rather than guess, I instrumented the login flow and ran an on-device test matrix (allow vs. deny App Tracking Transparency, each followed by a live `/me` probe) and proved the root cause:

> **FBSDK 17+ ties the classic Graph token's validity to ATT consent.** Deny tracking and the SDK silently issues an unusable Limited Login token; forcing the in-app advertiser flag doesn't help, because the OS-level ATT status wins.

The fix ships the constraint honestly: a SwiftUI setup flow (`FacebookLoginView`) surfaces the tracking state, routes the user to the one place iOS lets them change it, and degrades gracefully. Denying tracking costs only the analytics feature, never the notebook. The full investigation and the alternatives weighed are written up as an architecture decision record: **[docs/CONNECTED_INSIGHTS_ATT.md](docs/CONNECTED_INSIGHTS_ATT.md)**.

## Layout

```text
PackTags.xcodeproj         the app project (open this)
PackTags/
  App/                     app delegate, composition root, root coordinator
  Coordinators/            navigation: one coordinator per flow
  Domain/                  product rules and repository protocols, no UIKit
  Data/                    Core Data stores, repositories, app settings
  Features/                one folder per screen: View + ViewModel
  DesignSystem/            shared colors, components, nav-bar styling
  Shared/                  logging, formatters, small helpers
  en.lproj / fr.lproj      localization tables

PackTagsTests/             unit + snapshot tests (Swift Testing)
PackTagsUITests/           accessibility audits + cold-launch baseline

docs/                      diagrams, conventions, decision records
.github/workflows/         CI: SwiftLint + build & test
Secrets.xcconfig.template  copy to Secrets.xcconfig before building
```

## Dependencies

Managed with Swift Package Manager and resolved automatically when you open the project.

| Package | Role |
|---|---|
| https://github.com/A-bv/InstagramGraph | remote data layer wrapping the Meta Graph API |
| https://github.com/A-bv/TapTagKit | tap-to-select hashtags in any `UITextView` |
| https://github.com/A-bv/TableViewControllerCoverKit | table list over a stretchy cover image |
| https://github.com/A-bv/NeumorphicUIKit | neumorphic surfaces for UIKit views |
| https://github.com/A-bv/NeumorphicSwiftUI | neumorphic button/toggle/shadow styles for SwiftUI |
| https://github.com/facebook/facebook-ios-sdk | authentication |
| https://github.com/pointfreeco/swift-snapshot-testing | snapshot tests (test target only) |

The five `A-bv` packages are first-party: extracted from PackTags and maintained separately, so the networking, tag editing, and reusable UI evolve independently of the app.

## Build and run

Requires a recent Xcode with the iOS 17 SDK.

```sh
git clone https://github.com/A-bv/PackTags.git
cd PackTags
cp Secrets.xcconfig.template Secrets.xcconfig
open PackTags.xcodeproj
```

Run the **PackTags** scheme on any iOS 17+ simulator. The notebook works out of the box with the template's placeholder values; the connected features additionally need real Facebook credentials in `Secrets.xcconfig` and an Instagram Business account, which the app walks you through linking.

## Testing

```sh
xcodebuild test -scheme PackTags \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

Unit tests use **Swift Testing** and cover the domain rules, the repositories (on in-memory Core Data stores), view-model decisions, and coordinator wiring. Snapshot tests pin the design-system components in light and dark mode. The UI test suite runs Xcode's automated accessibility audits over the primary flow plus a cold-launch performance baseline.

## Roadmap

- **Crash and error reporting**: evaluating Sentry vs. Firebase Crashlytics.
- **String Catalog migration**: move the `.strings` tables to `Localizable.xcstrings` so missing or stale translations fail at build time.

## Author

Built and maintained by [A-bv](https://github.com/A-bv).
