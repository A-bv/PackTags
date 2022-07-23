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
    private enum Strings {
        static let textViewPlaceHolder = "Paste or enter your hashtags ..."
    }
    
    private enum Constants {
        static let placeHolderLabelTag = 222
    }
    
    func setPlaceholder() {
        let placeholderLabel = UILabel()
        placeholderLabel.text = Strings.textViewPlaceHolder
        placeholderLabel.font = UIFont.italicSystemFont(ofSize: (self.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        placeholderLabel.tag = Constants.placeHolderLabelTag
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (self.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !self.text.isEmpty
        self.addSubview(placeholderLabel)
    }

    func checkPlaceholder() {
        let placeholderLabel = self.viewWithTag(Constants.placeHolderLabelTag) as? UILabel
        placeholderLabel?.isHidden = !self.text.isEmpty
    }
    
    func hidePlaceholder() {
        let placeholderLabel = self.viewWithTag(Constants.placeHolderLabelTag) as? UILabel
        placeholderLabel?.isHidden = true
    }
}
