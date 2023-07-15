//
//  ViewController.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 10.07.22.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

class ThemeNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Status bar color in navigation controller
    // Set in infoPlist: "UIViewControllerBasedStatusBarAppearance" to YES
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        if let topVC = viewControllers.last {
            return topVC.preferredStatusBarStyle
        }
        return .default
    }
}
