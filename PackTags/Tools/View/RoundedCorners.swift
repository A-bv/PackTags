//
//  RoundedCorners.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 06.06.22.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

extension UIView {
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius))
        
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        
        layer.mask = mask
    }
}

extension UIView {
    func roundTopCorners (radius: CGFloat) {
        if #available(iOS 11.0, *) {
            layer.cornerRadius = radius
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            roundCorners([.topLeft,.topRight], radius: radius)
        }
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
