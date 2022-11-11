//
//  Alert.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 07.12.20.
//  Copyright © 2020 Alexandre Bevilacqua. All rights reserved.
//

import Foundation
import UIKit

class DarkMode: NSObject {
    class func isDarkMode () -> Bool {
        return UITraitCollection.current.userInterfaceStyle == .dark
    }
}

//MARK: - Update colors when light/dark mode
extension ThemeCell {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.contentView.backgroundColor = bkgdColor
        supportingView.addNeumorphicShadows()
    }
}

extension ThemeTableViewController {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateLogo ()
        navigationController?.navigationBar.putShadow()
    }
}

extension PackCell {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        copyButton.addNeumorphicShadows()
    }
}
