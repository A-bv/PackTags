import UIKit

extension ThemeListViewController {
    @objc func didTapButton() {
        coordinator?.showNewThemeEditor { [weak self] in
            self?.viewModel.loadThemes()
        }
    }

    @objc func didTapSettings() {
        coordinator?.showSettings()
    }

    @objc func didTapAnalytics() {
        coordinator?.showAnalytics()
    }

    @objc func didTapSmartG() {
        coordinator?.showSmartG()
    }
}
