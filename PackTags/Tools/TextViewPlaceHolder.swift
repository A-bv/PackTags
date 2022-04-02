//
//  TextViewPlaceHolder.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 03.04.22.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

//TextView place holder
extension UITextView{
    func setPlaceholder() {
        let placeholderLabel = UILabel()
        placeholderLabel.text = "Paste or enter your hashtags ..."
        placeholderLabel.font = UIFont.italicSystemFont(ofSize: (self.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        placeholderLabel.tag = 222
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (self.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !self.text.isEmpty
        self.addSubview(placeholderLabel)
    }

    func checkPlaceholder() {
        let placeholderLabel = self.viewWithTag(222) as? UILabel
        placeholderLabel?.isHidden = !self.text.isEmpty
    }
    
    func hidePlaceholder() {
        let placeholderLabel = self.viewWithTag(222) as? UILabel
        placeholderLabel?.isHidden = true
    }
}
