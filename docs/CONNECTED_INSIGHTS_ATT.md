# Connected Insights: Facebook Login vs. Instagram Login

**Status:** Accepted (2026-06-18) — keep Facebook Login + the Instagram Graph API, gated behind App Tracking Transparency (phase 1). Migrating to Instagram Login is deferred to phase 2.

---

## Context

Connected Insights shows a user the analytics of **their own** Instagram Business/Creator account (engagement, reach, impressions, engagement rate). It is built on **classic Facebook Login** (`loginTracking = .enabled`) + the **Instagram Graph API** (`graph.facebook.com`), via a Facebook Page linked to the Instagram account. Meta approved the required permissions in 2021: `instagram_basic`, `instagram_manage_insights`, `pages_show_list`, `business_management`.

In 2024 Meta shipped breaking changes to the iOS Login SDK. After updating, the analytics feature stopped working for some users. This document records the investigation and the decision.

## The core finding (empirically verified)

Since **FBSDK 17.0.0** (Feb 2024), the validity of the classic Graph access token is coupled to **App Tracking Transparency**. Verified on-device with instrumentation across multiple passes:

| | ATT **allowed** | ATT **denied** |
|---|---|---|
| `AccessToken.current` | present | present |
| advertiser tracking flag | `true` | `false` |
| token shape | `EAA…`, ~331 chars (valid Graph token) | non-`EAA`, ~255 chars (limited token), OIDC `AuthenticationToken` also present, `openid` scope |
| `GET graph.facebook.com/me` | ✅ 200 | ❌ 400 `Invalid OAuth access token - Cannot parse access token` (code 190) |
| Analytics | ✅ load | ❌ fail |

The only variable that flips the outcome is the user's ATT answer. Forcing `Settings.shared.isAdvertiserTrackingEnabled = true` does **not** help: the SDK re-derives the flag from the OS ATT status and overrides the manual value. Downgrading below SDK 17 is not an option — Apple has required a Privacy Manifest since May 1, 2024, and Meta only shipped it from 17.0.0.

**Conclusion:** on Facebook Login, ATT consent is mandatory and immovable for Graph/insights access. This is a Meta-imposed coupling, not a bug in our code. It is poorly documented (Meta's own SDK repo acknowledges "inconsistent documentation"), which is why it was proven empirically.

## Constraints of the Graph API path

**ATT wall**
- ATT consent is mandatory; denial yields a token the Graph rejects.
- The ATT prompt appears only once — recovery requires iOS Settings.
- No code circumvention (the tracking flag is OS-ATT-driven).
- Cannot downgrade the SDK (Privacy Manifest requirement forces ≥17).

**Onboarding prerequisites**
- A Facebook account.
- A Facebook Page linked to the Instagram account.
- The Instagram account must be Business/Creator (personal accounts have no insights).
- The user must hold task permissions on that Page.

**Meta App Review**
- Advanced Access for the scopes requires App Review (passed in 2021).
- Hashtag Search / Business Discovery additionally require the "Instagram Public Content Access" review and are capped at 30 hashtags / 7 days.

**Ongoing maintenance & fragility**
- Token lifecycle (long-lived tokens ~60 days; refresh / re-login handling).
- Graph API version deprecation treadmill (currently v23.0).
- Inconsistent official documentation.
- Exposure to Meta's unilateral platform changes (which triggered this work).

## Options considered

### A. Keep Facebook Login + gate on ATT (chosen, phase 1)
Detect ATT conformity at the feature entry; if not authorized, explain it is a Meta-imposed limitation and offer a shortcut to Settings, instead of a cryptic Graph failure. The rest of the app works without tracking.

- **Pros:** no new infrastructure; reuses the 2021 App Review and the extracted `InstagramGraph` package; ships immediately; preserves Hashtag Search.
- **Cons:** users who deny ATT cannot use the analytics feature (Meta's constraint, surfaced gracefully); the FB-Page onboarding remains a barrier.

### B. Migrate to Instagram Login (deferred, phase 2)
Replace Facebook Login with "Instagram API with Instagram Login" (Business Login for Instagram): direct Instagram OAuth, no Facebook account, no Facebook Page, no Facebook SDK, **no ATT dependency**.

- **Pros:** removes the ATT wall and the entire Facebook onboarding; a recruiter can test it with any Instagram Creator account in seconds.
- **Cons (the real cost):**
  - Requires a small **backend** (one stateless endpoint) — the token exchange needs the `client_secret`, which must not ship in the app.
  - **Drops Hashtag Search and Business Discovery** — both are Facebook-Login-only.
  - Requires a **new App Review** for the renamed scopes (`instagram_business_basic`, `instagram_business_manage_insights`); the 2021 approval does not carry over.
  - **Obsoletes the extracted `InstagramGraph` Swift package**, which is built around Facebook Login + `graph.facebook.com` + Page resolution. Its data models and transforms are salvageable, but the package as an artifact is lost.

## Decision

Ship **Option A** now. The app is a clean showcase that must be installable and usable by anyone, but the ATT constraint is Meta-imposed and unavoidable on Facebook Login, so the right move is to surface it clearly rather than fight it. Option A also preserves three existing assets — the passed App Review, the extracted `InstagramGraph` package, and Hashtag Search — that Option B would discard.

Option B remains the long-term escape from the ATT wall and the better onboarding story, deferred to phase 2 if/when the app evolves and the backend + re-review + feature-drop are justified.

## Consequences

- `AppTrackingAuthorizer` detects ATT conformity; `ConnectedInsightsCoordinator` gates the feature on it and presents a "Meta limitation" alert with an Open Settings shortcut on every blocked attempt. `Info.plist` declares `NSUserTrackingUsageDescription`.
- Reusable analytics code (models, `ProfileDataTransformer`, charts, MVVM-C structure) is path-agnostic and would survive a future migration; only the auth/networking plumbing is Facebook-specific.
