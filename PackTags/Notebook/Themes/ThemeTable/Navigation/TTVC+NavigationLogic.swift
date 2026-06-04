//
//  TTVC+NavigationLogic.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 16.07.23.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

extension ThemeTableViewController {
    private func showFBLoginScreenFromThemeTVC() {
        let viewModel = FBLoginViewModel()
        let viewController = FBLoginVC(viewModel: viewModel)
        viewController.modalPresentationStyle = .overFullScreen
        viewController.modalTransitionStyle = .coverVertical
        self.present(viewController, animated: true, completion: nil)
    }
}

extension ThemeTableViewController {
    @objc func didTapButton() {
        let themeVC = ThemeVC()
        themeVC.onSave = { [weak self] _ in
            self?.themes = CoreDataHelper.retrieveThemes()
        }
        let navigationController = UINavigationController(rootViewController: themeVC)
        navigationController.modalPresentationStyle = .overFullScreen
        navigationController.modalTransitionStyle = .coverVertical
        present(navigationController, animated: true)
    }

    @objc func didTapSettings() {
        let settingsVC = SettingsVC()
        navigationController?.pushViewController(settingsVC, animated: true)
    }

    @objc func didTapAnalytics() {
        let analyticsVC = AnalyticsHostingViewController()
        analyticsVC.modalPresentationStyle = .overFullScreen
        analyticsVC.modalTransitionStyle = .coverVertical
        present(analyticsVC, animated: true)
    }

    @objc func didTapSmartG() {
        let isCorrectSetup = UserDefaults.standard.bool(forKey: "isCorrectSetup")
        guard isCorrectSetup else {
            showFBLoginScreenFromThemeTVC()
            return
        }
        let smartGVC = SmartGHostingViewController()
        smartGVC.modalPresentationStyle = .overFullScreen
        smartGVC.modalTransitionStyle = .coverVertical
        present(smartGVC, animated: true)
    }
}
