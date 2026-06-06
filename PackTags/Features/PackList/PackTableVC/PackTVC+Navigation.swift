//
//  PackTVC+Navigation.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 14/03/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

// MARK: - Navigation
extension PackTableVC {
    @objc func didTapCompose() {
        presentThemeVC(fromSwipe: false)
    }

    func presentThemeVC(fromSwipe: Bool) {
        guard let theme = theme else { return }
        resetStatusBarColor = true
        coordinator?.showThemeEditor(
            for: theme,
            fromSwipe: fromSwipe,
            chosenPack: fromSwipe ? chosenPack : "",
            onSave: { [weak self] in
                self?.updatePackTableVC()
                self?.resetStatusBarColor = false
            },
            onCancel: { [weak self] in
                self?.resetStatusBarColor = false
            }
        )
    }
}
