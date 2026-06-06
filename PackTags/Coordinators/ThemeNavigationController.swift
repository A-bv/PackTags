//
//  ViewController.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 10.07.22.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

class ThemeNavigationController: UINavigationController {
    override var childForStatusBarStyle: UIViewController? {
        return viewControllers.last
    }
}
