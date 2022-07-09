//
//  NavigationBarAppearance.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 09.07.22.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

extension UIViewController {
    func applyNavBarAppearance(color: UIColor, textColor: UIColor = .label) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = color
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: textColor]
        appearance.largeTitleTextAttributes = [.foregroundColor: textColor]
        navigationController?.navigationBar.overrideUserInterfaceStyle = .dark
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
    }
}
