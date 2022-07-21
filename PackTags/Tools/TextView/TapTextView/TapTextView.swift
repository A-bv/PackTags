//
//  dss.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 02.04.22.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

@objc
protocol TapTextViewDelegate: AnyObject {
    func tapTextViewDidStartSelection(_ textView: TapTextView)
    func tapTextViewDidFinishSelection(_ textView: TapTextView)
    func tapTextViewShowInfoAlert(_ title: String, _ message: String)
}

extension UIViewController: TapTextViewDelegate {
    func tapTextViewDidStartSelection(_ textView: TapTextView) {
        navigationController?.setToolbarHidden(false,
                                               animated: false)
    }
    
    func tapTextViewDidFinishSelection(_ textView: TapTextView) {
        navigationController?.setToolbarHidden(true,
                                               animated: false)
    }
    
    func tapTextViewShowInfoAlert(_ title: String, _ message: String) {
        let action = UIAlertAction(
            title: "OK",
            style: .default)
        self.simpleAlert(
            title: title,
            message: message,
            btnAction1: action)
    }
}

@IBDesignable
class TapTextView: UITextView {
    var selectionDict = [String:Int]()
    var viewTagCount = Int()
    var tap = UIGestureRecognizer()
    var firstTimeGrouped = false
    
    var tB = UIBarButtonItem()
    
    @IBInspectable
    weak var tagDelegate: TapTextViewDelegate?
    
    func startTagSelection () {
        tap.isEnabled = true
        isEditable = false
        isSelectable = false
        addTappedTagRecognizer()
        tagDelegate?.tapTextViewDidStartSelection(self)
    }
}
