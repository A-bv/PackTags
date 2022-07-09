//
//  ThemeVC+Selection.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 26/01/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

//add view
extension UITextView {

    private func frameOfTextInRange(range:NSRange) -> CGRect {
        let beginning = self.beginningOfDocument
        let start = self.position(from: beginning, offset: range.location)
        let end = self.position(from: start!, offset: range.length)
        let textRange = self.textRange(from: start!, to: end!)
        let rect = self.firstRect(for: textRange!)
        return self.convert(rect, from: self)
    }
    
    func select (base:String,tag: Int, isSelected: Bool) {
        
        //text color
        var textColorAttribute = [NSAttributedString.Key : UIColor]()
        let myString = self.attributedText.mutableCopy() as! NSMutableAttributedString //
        
        //****** Selection
        let pattern = "\\#\(base)\\b" //base //"(\\#[a-zA-Z]+\\b)(?!;)"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let matches = regex.matches(in: self.text, options: [], range: NSMakeRange(0, self.text.count))
        
        

        for m in matches {
            if isSelected == false {
                textColorAttribute = [NSAttributedString.Key.foregroundColor: UIColor.white]//
            
                // *** create a frame view ***
                let range = m.range
                var frame = frameOfTextInRange(range: range)
                frame = frame.insetBy(dx: CGFloat(-1), dy: CGFloat(2)) //Changed
                frame = frame.offsetBy(dx: CGFloat(0), dy: CGFloat(0)) //changed
                let v = UIView(frame: frame)
                v.layer.cornerRadius = v.frame.height / 4 //Initial
                v.tag = tag
                self.insertSubview(v, at: 0)
                //v.backgroundColor = UIColor.systemPink
                v.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
                
            } else if isSelected == true {
                textColorAttribute = [NSAttributedString.Key.foregroundColor: .label]//
                
                // *** delete a frame view ***
                self.removeSpecificView(tag: tag)
            }
            myString.addAttributes(textColorAttribute, range: m.range)
        }
        
    self.attributedText = myString.copy() as? NSAttributedString
    }

    func numberOfViewsOnTextView(superView: UIView)-> Int{
        var count = 0
        for _ in superView.subviews{count+=1}
        return count
    }

}
    
extension UIView {
    // Remove specific tagged view
    func removeSpecificView(tag: Int) {
        subviews
            .filter({$0.tag == tag})
            .forEach({$0.removeFromSuperview()})
    }
}
