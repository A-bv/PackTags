import Foundation

struct ThemeListNavigation {
    let selectTheme: (Theme) -> Void
    let createTheme: (_ onCreated: @escaping () -> Void) -> Void
    let openSettings: () -> Void
    let openAnalytics: () -> Void
    let openSmartG: () -> Void
}
