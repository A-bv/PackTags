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
    
    func shouldNavigateToShowAnalytics(segueIdentifier: String) -> Bool {
        if ThemeTableViewControllerSegueOrigin(rawValue: segueIdentifier) == .showAnalytics {
            let isCorrectSetup = UserDefaults.standard.bool(forKey: "isCorrectSetup")
            if !isCorrectSetup { showFBLoginScreenFromThemeTVC() }
            return isCorrectSetup
        } else {
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
