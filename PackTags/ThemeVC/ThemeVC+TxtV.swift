//
//  ViewController.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 02.09.20.
//  Copyright © 2020 Alexandre Bevilacqua. All rights reserved.
//

import Foundation
import UIKit

//Avoid Keyboard hiding textview
extension ThemeVC {
    func setupKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func adjustForKeyboard(notification: Notification)
    {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        else {return}
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        if notification.name == UIResponder.keyboardWillHideNotification {
            themeTextView.contentInset = .zero
        } else {
            themeTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        //scrollBar size
        themeTextView.scrollIndicatorInsets = themeTextView.contentInset
    }
}
