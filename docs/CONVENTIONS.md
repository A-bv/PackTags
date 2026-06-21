# PackTags — Architecture & Conventions

A reusable checklist of the rules this codebase follows. Written to be portable to
the next app, not just a description of this one.

---

## 1. Architecture: MVVM-C

Five roles, each with one job:

| Layer | Responsibility | Knows about |
|---|---|---|
| **Coordinator** | Navigation & flow. Builds screens and wires them together. | View models, view controllers, dependencies |
| **View** (`ViewController` / cells / SwiftUI views) | Render state, forward user input. No business logic. | Its view model |
| **ViewModel** | State + intents + presentation logic. | Domain & Data (via protocols) |
| **Domain** | Pure business rules. No UIKit, no persistence. | Nothing app-specific |
| **Data** | Persistence (Core Data, UserDefaults), repositories. | Domain models |

Rule of thumb: if you feel friction putting code somewhere, that's an architecture
signal — move it to the right layer, don't patch around it.

---

## 2. Dependency Injection

- **Constructor injection only.** No singletons reached for inside types, no service
  locators. Dependencies arrive through `init`.
- **Composition root** is the `AppCoordinator`, assembled in `SceneDelegate`. Shared
  dependencies live in `AppDependencies` and are passed down.
- **Inject into view models and coordinators**, not into views. A view gets its view
  model already built.
- **Depend on protocols at boundaries** (data, settings, gateways) so the app is
  framework-agnostic and unit-testable with fakes.

---

## 3. Protocols (blueprints)

A protocol names a **contract**; the implementation is a separate concrete type that
can be anything fulfilling it (a repository, a service, a coordinator, a test mock).

- **Name the blueprint `…Protocol`** — e.g. `ThemeRepositoryProtocol`,
  `AppSettingsProtocol`, `ConnectedInsightsProtocol`, `FacebookSessionServiceProtocol`,
  `ReviewPromptStoreProtocol`.
- **Exception:** `Coordinator` keeps its idiomatic pattern name (no suffix).
- **Name the implementation for *how* it works** — backing tech where there is one
  (`CoreDataThemeRepository`, `UserDefaultsAppSettings`), otherwise the concrete role
  (`ConnectedInsightsCoordinator`, `FacebookSessionService`).

> We considered the Apple-guideline style (`-ing`/`-able`, no suffix) and `Store`-style
> suffixes, but landed on `…Protocol` for unambiguous, consistent readability.

---

## 4. Naming

| Thing | Convention | Example |
|---|---|---|
| View controller | full **`…ViewController`** (never `…VC`) | `ThemeListViewController` |
| View model | `…ViewModel` | `SettingsViewModel` |
| Coordinator | `…Coordinator` | `ThemeCoordinator` |
| Repository | `…Repository` (impl `CoreData…`) | `ThemeRepository` |
| Settings store | protocol `AppSettingsProtocol`, impl `UserDefaultsAppSettings`, referenced as `appSettings` | |
| Coordinator seam | a struct of injected closures, `…Navigation` | `SettingsNavigation` |

> **Two closure seams, two names.** A coordinator seam (`…Navigation`) carries the
> flow intents the coordinator fulfils (`SettingsNavigation`, `ThemeListNavigation`).
> A data-driven screen additionally has an `…Actions` seam — the behaviours wired into
> each catalog row, consumed by the catalog builder (`SettingsActions` →
> `SettingsSections`). `Navigation` leaves the screen; `Actions` is what a row does.

### Pickers — the screen-vs-helper rule
- **Our own picker screen** (custom UI, presented by the coordinator) →
  `…PickerViewController`, with a view model, in its own screen folder.
- **A helper that drives a *system* picker** (e.g. wraps `PHPickerViewController`) →
  a helper with a role suffix (`…Service`), **not** named `…Picker` (it isn't a picker
  UI). The `ViewController` suffix is what tells the two apart.

---

## 5. View Models

- **UIKit view models** are plain classes. They expose state + intents and talk *up* to
  the coordinator through **injected closures** (no delegate-to-coordinator references).
- **SwiftUI view models** use `@Observable` + `@MainActor`.
- Logic lives in the view model; the view controller only does view setup + binding.
- The view controller holds its view model **`private`** — built by the coordinator and
  injected through `init`. Don't widen it to `internal` for tests; exercise the view
  model standalone instead (see §6).

---

## 6. Coordinators

- Own navigation. `start()` plus private `show…` / `present…` methods.
- The view model exposes navigation **intents**; the coordinator fulfills them.
- **Test through seams, never by reaching into a view controller's view model.** Because
  view models are `private` (§5), each layer is verified at its own boundary:
  - **Navigation** — expose `make…Navigation()` returning the closure seam; a test
    invokes a callback and asserts what the coordinator pushes/presents.
  - **View-model logic** (which theme an index picks, which callback an intent fires,
    which event a row emits) — tested standalone with a recording **spy** navigation.
  - **Construction** (did the coordinator build the screen with the right input?) —
    inject a screen **factory** the test can mock, or assert the built screen's *public*
    surface (e.g. its `title`).

---

## 7. Who presents alerts

- The **view** presents control-driven alerts/sheets (the user tapped something).
- The **coordinator** presents flow alerts (e.g. first-run tips).
- No dedicated "alert coordinator" — that's over-engineering until alert/error handling
  is genuinely cross-cutting.

---

## 8. Folder structure

```
App/            Composition root: AppDelegate, SceneDelegate, AppCoordinator, AppDependencies
Coordinators/   Coordinators + the Coordinator protocol
Data/           Persistence (Core Data, UserDefaults), repositories, settings, CD models
Domain/         Pure business rules (no UIKit)
DesignSystem/   App-wide UI: Views (reusable views), Components (non-view helpers,
                e.g. factories), colors, navigation bar, neumorphic, view extensions
Shared/         Non-UI utilities reused across features (alerts, logger, links, review)
Features/<Name>/
    <Name>Navigation.swift     coordinator seam (closures the coordinator injects)
    View/                      the screen + every view it owns (controllers, cells, subviews)
    ViewModel/                 view models + presentation models + catalogs
    Model/                     feature models
    Services/                  feature-local non-UI helpers (recognition, pickers, session)
    Components/                feature-local helpers that are NOT a model, view, VM, or service
    <SubScreen>/View|ViewModel sub-screens get their own View/ViewModel folders
```

A coordinator-presented screen is a **screen** (its own folder, e.g. `QuantityPicker/View/`).
`Components/` **never holds views** — it is the bucket for feature-scoped things that are not a
model, view, view model, or service and can't move to `Shared/` (they're scoped to one feature).
Views, including a screen's reusable subviews, live under `View/`.

---

## 9. Style

- **Member ordering:** properties on top, functions below (`init` counts as a function).
- **Prefer system APIs** over custom reimplementations (e.g. `UIFindInteraction` over a
  hand-rolled search bar).
- Commit messages: plain, accurate, descriptive of the *why*. No cryptic subjects.
