import Foundation

struct ThemeListNavigation {
    let selectTheme: (ThemeEntity) -> Void
    let createTheme: (_ onCreated: @escaping () -> Void) -> Void
    let openSettings: () -> Void
    let openAnalytics: () -> Void
    let openSmartG: () -> Void
}
