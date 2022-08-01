//
//  HowToSetupIGVC.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 14/06/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

var instagramIconAttachment: NSTextAttachment {
    let icon = NSTextAttachment()
    icon.image = UIImage(named: "igColor")
    icon.bounds = CGRect(x: 0, y: -5, width: 30, height: 30)
    return icon
}

var facebookIconAttachment: NSTextAttachment {
    let icon = NSTextAttachment()
    icon.image = UIImage(named: "fbColor")
    icon.bounds = CGRect(x: 0, y: -5, width: 30, height: 30)
    return icon
}

class HowToSetupProIGVC: UIViewController {
    deinit {
        print("deinit HowToSetupProIGVC")
    }
    
    private enum Constants {
        static let openInstagramBtnHeight = CGFloat(44)
        static let openInstagramBtnBottomPadding = CGFloat(-50)
        static let stackViewSpacing = CGFloat(50.0)
        static let subStackViewSpacing = CGFloat(5.0)
        static let LH = CGFloat(44.0)  //label height
        static let TH = CGFloat(100.0) //Text height
        static let textViewWidth = CGFloat(300)
        static let textViewHeight = CGFloat(125)
        static let stackViewHeight = Constants.stackViewSpacing*3 + Constants.LH*2 + Constants.TH + textViewHeight
    }
    
    private enum Links {
        static let appURL = "instagram://app"
        static let webURL = "https://instagram.com"
    }
    
    private enum Strings {
        static let topLabelText = "Switch to Creator /Business:".localized()
        static let topTextViewText = "topTextViewText".localized()
        static let bottomTextViewText = "bottomTextViewText".localized()
        static let bottomLabelText = "🔗    If your page is not linked:".localized()
        static let buttonTitle = "Open Instagram".localized()
    }
    
    var l0: UILabel {
        let l = UILabel(frame:CGRect.zero)
        l.backgroundColor = bkgdColor
        l.font = UIFont.preferredFont(forTextStyle: .headline)
        l.translatesAutoresizingMaskIntoConstraints = false // Enable autolayout
        l.heightAnchor.constraint(
            equalToConstant: Constants.LH).isActive = true
        l.widthAnchor.constraint(
            equalToConstant: Constants.textViewWidth).isActive = true
        return l
    }
    
    var t0: UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.backgroundColor = bkgdColor
        textView.textAlignment = .left
        textView.tintColor = .black
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.translatesAutoresizingMaskIntoConstraints = false // Enable autolayout
        textView.widthAnchor.constraint(
            equalToConstant: Constants.textViewWidth).isActive = true
        return textView
    }
    
    var stack: UIStackView {
        let subStack = UIStackView()
        subStack.axis = NSLayoutConstraint.Axis.vertical
        return subStack
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.placeTopRightButton(arrowButton: false)
        self.view.backgroundColor = bkgdColor
        self.placeHelpButton (isHelpSetupIgPro: false)
        
        setupCustomStackHTSProIG ()
        setupProfileButton ()
    }
    
    @objc func goProfile (_ sender: Any) {
        self.openAppURL(
            appURL: Links.appURL,
            webURL: Links.webURL,
            completion: {_ in})
    }
}


extension HowToSetupProIGVC {
    func setupProfileButton () {
        let openInstagramBtn: UIButton = {
            let btn = UIButton()
            btn.setTitleColor(customPurple, for: .normal)
            btn.setTitle(Strings.buttonTitle, for: .normal)
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.addTarget(
                self,
                action: #selector(goProfile(_:)),
                for: .touchUpInside)
            return btn
        }()
        
        self.view.addSubview(openInstagramBtn)
        openInstagramBtn.heightAnchor.constraint(
            equalToConstant: Constants.openInstagramBtnHeight).isActive = true
        openInstagramBtn.centerXAnchor.constraint(
            equalTo: self.view.centerXAnchor).isActive = true
        openInstagramBtn.bottomAnchor.constraint(
            equalTo: view.bottomAnchor,
            constant: Constants.openInstagramBtnBottomPadding).isActive = true
    }
    
    func setupCustomStackHTSProIG () {
        let topLabel = l0
        let bottomLabel = l0
        let topTextView = t0
        let bottomTextView = t0
        
        topTextView.heightAnchor.constraint(
            equalToConstant: Constants.textViewHeight).isActive = true
        bottomTextView.heightAnchor.constraint(
            equalToConstant: Constants.TH).isActive = true
        
        //General StackView
        let stackHTS = stack
        stackHTS.distribution = .equalSpacing
        stackHTS.alignment = .center
        stackHTS.spacing = Constants.stackViewSpacing
        
        //Sub stackView 1
        let subStack1 = stack
        subStack1.addArrangedSubview(topLabel)
        subStack1.addArrangedSubview(topTextView)
        subStack1.spacing = Constants.subStackViewSpacing
        
        //Sub StackView 2
        let subStack2 = stack
        subStack2.addArrangedSubview(bottomLabel)
        subStack2.addArrangedSubview(bottomTextView)
        subStack2.spacing = Constants.subStackViewSpacing
       
        stackHTS.addArrangedSubview(subStack1)
        stackHTS.addArrangedSubview(subStack2)
        self.view.addSubview(stackHTS)
        
        stackHTS.translatesAutoresizingMaskIntoConstraints  = false
        stackHTS.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        stackHTS.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        //stackHTS.heightAnchor.constraint(
        //    equalToConstant: CGFloat(Constants.stackViewHeight)).isActive = true
        
        
        // Fill text
        let attributedString = NSMutableAttributedString(string: "")
        attributedString.append(NSAttributedString(attachment: instagramIconAttachment))
        attributedString.append(NSAttributedString(string: "  " + Strings.topLabelText))
        topLabel.attributedText = attributedString
        
        topTextView.text = Strings.topTextViewText
        bottomTextView.text = Strings.bottomTextViewText
        bottomLabel.text = Strings.bottomLabelText
    }
}
