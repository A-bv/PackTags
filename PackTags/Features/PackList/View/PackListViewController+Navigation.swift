//
//  PackTVC+Navigation.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 14/03/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

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
