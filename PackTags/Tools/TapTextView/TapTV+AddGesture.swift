//
//  ssss.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 02.04.22.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

extension TapTextView {
    func addTappedTagRecognizer () {
        tap = UITapGestureRecognizer(target: self,
                                     action: #selector(tapResponse(recognizer:)))
        tap.delegate = self as? UIGestureRecognizerDelegate
        addGestureRecognizer(tap)
    }
    
    @objc private func tapResponse(recognizer: UITapGestureRecognizer) {
        let location: CGPoint = recognizer.location(in: self)
        let position: CGPoint = CGPoint(x:location.x,
                                        y: location.y)
        
        let tapPosition: UITextPosition? = closestPosition(to:position)
        
        if tapPosition != nil {
            let textRange: UITextRange? = tokenizer.rangeEnclosingPosition(tapPosition!,
                                                                           with: UITextGranularity.word,
                                                                           inDirection: UITextDirection(rawValue: 1))
            if textRange != nil
            {
                let tappedWord: String? = self.text(in:textRange!)
                processTappedWord(tappedWord: tappedWord)
                /*
                print("number of views after tap:", self.numberOfViewsOnTextView(superView: self))
                print("count:",viewTagCount)
                */
            }
        }
    }
}
