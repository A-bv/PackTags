//
//  TTVC+NavigationLogic.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 16.07.23.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

extension ThemeTableViewController {
    private enum UserDefaultsKeys {
        static let isCorrectSetup = UserDefaults.standard.bool(forKey: "isCorrectSetup")
    }
    
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
        
    func shouldNavigateToShowAnalytics(segueIdentifier: String) -> Bool {
        guard let segueOrigin = ThemeTableViewControllerSegueOrigin(rawValue: segueIdentifier) else {
            return true
        }

        switch segueOrigin {
        case .showAnalytics:
            if !UserDefaultsKeys.isCorrectSetup {
                showFBLoginScreenFromThemeTVC()
            }
            return UserDefaultsKeys.isCorrectSetup
        default:
            return true
        }
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
        self.performSegue(withIdentifier: "addItem", sender: self)
    }

    @objc func didTapSettings() {
        let settingsVC = SettingsVC()
        navigationController?.pushViewController(settingsVC, animated: true)
    }
}
