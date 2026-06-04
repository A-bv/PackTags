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
        let themeVC = ThemeVC()
        configure(themeVC, fromSwipe: fromSwipe)

        let navigationController = UINavigationController(rootViewController: themeVC)
        navigationController.modalPresentationStyle = .overFullScreen
        navigationController.modalTransitionStyle = .crossDissolve

        resetStatusBarColor = true
        present(navigationController, animated: true)
    }

    private func configure(_ themeVC: ThemeVC, fromSwipe: Bool) {
        themeVC.theme = theme
        themeVC.isNotNewTheme = true

        if fromSwipe {
            themeVC.isFromShow = true
            themeVC.packFromShow = chosenPack
        }

        themeVC.onSave = { [weak self] _ in
            self?.updatePackTableVC()
            self?.resetStatusBarColor = false
        }

        themeVC.onCancel = { [weak self] in
            self?.resetStatusBarColor = false
        }
    }
}
