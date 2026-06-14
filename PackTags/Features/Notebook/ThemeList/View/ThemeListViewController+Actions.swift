import UIKit

extension ThemeListViewController {
    @objc func didTapButton() {
        actions.createTheme()
    }

    @objc func didTapSettings() {
        actions.openSettings()
    }

    @objc func didTapAnalytics() {
        actions.openAnalytics()
    }

    @objc func didTapSmartG() {
        actions.openSmartG()
    }
}
