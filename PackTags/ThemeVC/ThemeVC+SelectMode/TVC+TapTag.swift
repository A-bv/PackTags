//
//  ThemeVC+tagInfo.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 29.12.20.
//  Copyright © 2020 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

//MARK: - Find tapped word in textView
extension ThemeVC {
    
    func tappedTagRecognizer () {
        tap = UITapGestureRecognizer(target: self, action: #selector(tapResponse(recognizer:)))
        tap.delegate = self as? UIGestureRecognizerDelegate
        themeTextView.addGestureRecognizer(tap)
    }
    
    
    @objc private func tapResponse(recognizer: UITapGestureRecognizer) {
        let location: CGPoint = recognizer.location(in: themeTextView)
        let position: CGPoint = CGPoint(x:location.x, y:location.y)
        let tapPosition: UITextPosition? = themeTextView.closestPosition(to:position)
        
        if tapPosition != nil {
            let textRange: UITextRange? = themeTextView.tokenizer.rangeEnclosingPosition(tapPosition!, with: UITextGranularity.word, inDirection: UITextDirection(rawValue: 1))
            if textRange != nil
            {
                let tappedWord: String? = themeTextView.text(in:textRange!)
                processTappedWord(tappedWord: tappedWord)
                /*
                print("number of views after tap:",themeTextView.numberOfViewsOnTextView(superView: themeTextView))
                print("count:",viewTagCount)
                */
            }
        }
    }
    
    func processTappedWord (tappedWord: String?) {
        
        //Vibrates
        if #available(iOS 13.0, *) {
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        } else {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
        
        if tappedWord != nil {
            if selectionDict[tappedWord!] == nil { // = not selected yet
                
                viewTagCount += 1 //UIViewTag
                selectionDict[tappedWord!] = viewTagCount//tappedWord = unique key
                
                //highlight tags on textview (must have: tag > 0)
                themeTextView.select(base: tappedWord!,tag: viewTagCount, isSelected: false)
                
            } else { // = already selected
                
                themeTextView.select(base: tappedWord!,tag: selectionDict[tappedWord!]!, isSelected: true)
                selectionDict[tappedWord!] = nil
            }
        }
    }
}
