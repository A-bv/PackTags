//
//  TTVC+NavigationLogic.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 16.07.23.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

extension ThemeTableViewController {
    func handleSelectedThemeData(sender: Any?, destination: UIViewController) {
        guard let selectedThemeCell = sender as? ThemeCell else {
            fatalError("Unexpected sender: \(String(describing: sender))")
        }
        guard let themeDetailViewController = destination as? PackTableVC else {
            fatalError("Unexpected destination: \(destination)")
        }
        guard let indexPath = tableView.indexPath(for: selectedThemeCell) else {
            fatalError("The selected cell is not being displayed by the table")
        }
        let selectedTheme = themes[indexPath.row]
        themeDetailViewController.theme = selectedTheme
    }

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
