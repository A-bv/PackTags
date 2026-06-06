//
//  BlurView.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 06.06.22.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

extension UIView {
    func applyBlur() {
        if !UIAccessibility.isReduceTransparencyEnabled {
            self.backgroundColor = .clear

            let  blurEffect = UIBlurEffect(style: .regular)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = self.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            self.addSubview(blurEffectView)
        } else {
            self.backgroundColor = .systemBackground
        }
    }
}
