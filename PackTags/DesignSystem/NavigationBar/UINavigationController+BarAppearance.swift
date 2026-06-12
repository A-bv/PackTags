import UIKit

extension UIViewController {
    private func setNavBarAppearance(color: UIColor) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = color
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
    }
}

extension UIViewController {
    /// The app's standard navigation chrome: themed background, soft shadow,
    /// brand tint. One call per screen keeps the look consistent.
    func applyThemedNavigationBarStyle() {
        setNavBarAppearance(color: bkgdColor)
        navigationController?.navigationBar.putShadow()
        navigationController?.navigationBar.tintColor = customBarTint
    }
}
