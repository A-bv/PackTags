//
//  ThemeVC+tagInfo.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 29.12.20.
//  Copyright © 2020 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

extension TapTextView {
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
                self.select(base: tappedWord!,tag: viewTagCount, isSelected: false)
                
            } else { // = already selected
                
                self.select(base: tappedWord!,tag: selectionDict[tappedWord!]!, isSelected: true)
                selectionDict[tappedWord!] = nil
            }
        }
    }
}
