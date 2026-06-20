import Foundation

/// Behaviors the settings list can trigger. The view controller supplies the
/// implementations; the catalog stays free of view and navigation code.
struct SettingsActions {
    let editInstagramUsername: () -> Void
    let openFacebookSetup: () -> Void
    let showQuantityPicker: () -> Void
    let replayOnboarding: () -> Void
    let openSetupInfo: () -> Void
    let openWebPage: (String) -> Void
    let openOurInstagram: () -> Void
    let shareApp: () -> Void
    let rateApp: () -> Void
    let contactSupport: () -> Void
}
