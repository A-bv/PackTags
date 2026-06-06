//
//  RoundedCorners.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 06.06.22.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

extension UIView {
    func roundTopCorners (radius: CGFloat) {
        layer.cornerRadius = radius
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
}

/*
extension UIView{
    func blurImage()
    {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds

        self.addSubview(blurEffectView)
    }
}
*/
