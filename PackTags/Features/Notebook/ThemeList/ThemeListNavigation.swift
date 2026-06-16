import Foundation

struct ThemeListNavigation {
    let selectTheme: (ThemeCD) -> Void
    let createTheme: (_ onCreated: @escaping () -> Void) -> Void
    let openSettings: () -> Void
    let openAnalytics: () -> Void
    let openSmartG: () -> Void
}
