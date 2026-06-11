//
//  TTVC+Navigation.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 16.07.23.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

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
