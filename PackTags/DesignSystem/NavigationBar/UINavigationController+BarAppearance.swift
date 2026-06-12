import UIKit

extension UIViewController {
    func setNavBarTransparent(alpha: CGFloat) {
        
        let textColor: UIColor = alpha >= 0 ? .label.withAlphaComponent(alpha) : .white
        let backgroundColor: UIColor = alpha >= 0 ? bkgdColor.withAlphaComponent(alpha) : .clear
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = backgroundColor
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: textColor]
        appearance.largeTitleTextAttributes = getClearNavigationBarAttributes()
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = textColor
    }
    
    private func getClearNavigationBarAttributes() -> [NSAttributedString.Key : Any] {
        let font = UIFont.systemFont(
            ofSize: 31,
            weight: UIFont.Weight.bold)
        
        return [ .foregroundColor: UIColor.white, .font: font ]
    }
}

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
