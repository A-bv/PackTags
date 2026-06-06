import Foundation

protocol ThemeCoordinatorProtocol: AnyObject {
    func showPackList(for theme: ThemeCD)
    func showNewThemeEditor(onSave: @escaping () -> Void)
    func showOnboarding(completion: (() -> Void)?)
    func showSettings()
    func showAnalytics()
    func showSmartG()
    func showThemeEditor(for theme: ThemeCD, fromSwipe: Bool, chosenPack: String, onSave: @escaping () -> Void, onCancel: @escaping () -> Void)
}
