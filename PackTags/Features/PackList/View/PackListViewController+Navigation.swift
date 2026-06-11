import UIKit

// MARK: - Navigation
extension PackListViewController {
    @objc func didTapCompose() {
        presentThemeVC(fromSwipe: false)
    }

    func presentThemeVC(fromSwipe: Bool) {
        resetStatusBarColor = true
        coordinator?.showThemeEditor(
            for: viewModel.theme,
            fromSwipe: fromSwipe,
            chosenPack: fromSwipe ? chosenPack : "",
            onSave: { [weak self] in
                self?.updatePackListViewController()
                self?.resetStatusBarColor = false
            },
            onCancel: { [weak self] in
                self?.resetStatusBarColor = false
            }
        )
    }
}
