//
//  HowToSetupIGVC.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 14/06/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

class HowToSetupProIGVC: UIViewController {
    deinit {print("deinit HowToSetupProIGVC")}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalUI(arrowButton: false)
        self.view.backgroundColor = bkgdColor
        customStackHTSProIG ()
        placeProfileButton ()
        self.placeHelpButton (isHelpSetupIgPro: false)
    }
    
    
}
    
extension HowToSetupProIGVC {
    
    //profile button
    func placeProfileButton () {
        let profileBtn: UIButton  = {
            let btn = UIButton()
            btn.setTitleColor(customPurple, for: .normal)
            btn.setTitle("Open Instagram", for: .normal)
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.addTarget(self, action: #selector(goProfile(_:)), for: .touchUpInside)
            return btn
        }()
        
        self.view.addSubview(profileBtn)
        
        profileBtn.heightAnchor.constraint(equalToConstant: 44).isActive = true
        profileBtn.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        profileBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
    }
    
    @objc func goProfile (_ sender: Any) {
        self.openAppURL(appURL: "instagram://app", webURL: "https://instagram.com", completion: {_ in})
    }
    
    //StackView
    func customStackHTSProIG () {
        
        let spacing = CGFloat(0.0)
        let LH = CGFloat(44.0)  //label height
        let TH = CGFloat(100.0) //Text height

        
        let t0: UITextView = {
            let textView = UITextView()
            textView.backgroundColor = bkgdColor
            textView.textAlignment = .left
            textView.tintColor = .black
            textView.font = UIFont.preferredFont(forTextStyle: .body)
            textView.translatesAutoresizingMaskIntoConstraints = false //enable autolayout
            textView.heightAnchor.constraint(equalToConstant: 125).isActive = true
            textView.widthAnchor.constraint(equalToConstant: 300).isActive = true
            textView.isEditable = false
            return textView
        }()
        
        let t1: UITextView = {
            let textView = UITextView()
            textView.backgroundColor = bkgdColor
            textView.textAlignment = .left
            textView.tintColor = .black
            textView.font = UIFont.preferredFont(forTextStyle: .body)
            textView.translatesAutoresizingMaskIntoConstraints = false //enable autolayout
            textView.heightAnchor.constraint(equalToConstant: TH).isActive = true
            textView.widthAnchor.constraint(equalToConstant: 300).isActive = true
            textView.isEditable = false
            return textView
        }()
            
        let l0: UILabel = {
            let l = UILabel(frame:CGRect.zero)
            l.backgroundColor = bkgdColor
            l.font = UIFont.preferredFont(forTextStyle: .headline)
            l.translatesAutoresizingMaskIntoConstraints = false //enable autolayout
            l.heightAnchor.constraint(equalToConstant: LH).isActive = true
            l.widthAnchor.constraint(equalToConstant: 300).isActive = true
            return l
        }()
        
        let l1: UILabel = {
            let l = UILabel(frame:CGRect.zero)
            l.backgroundColor = bkgdColor
            l.font = UIFont.preferredFont(forTextStyle: .headline)
            l.translatesAutoresizingMaskIntoConstraints = false //enable autolayout
            l.heightAnchor.constraint(equalToConstant: LH).isActive = true
            l.widthAnchor.constraint(equalToConstant: 300).isActive = true
            return l
        }()
        
        t0.text = """
                  • On your profile tap  ≡
                  • Tap Settings
                  • Tap Accounts
                  • Switch to Professional Account
             
            """
            
        t1.text = """
                  • On your profile tap "Edit Profile"
                  • Link your page to your account
            """
        
        l1.text = "🔗    If your page is not linked:"
        
        let attributedString = NSMutableAttributedString(string: "")
        let iconsSize = CGRect(x: 0, y: -5, width: 30, height: 30)
        
        let iconAttachment = NSTextAttachment()
        iconAttachment.image = UIImage(named: "igColor")
        iconAttachment.bounds = iconsSize
        attributedString.append(NSAttributedString(attachment: iconAttachment))
        attributedString.append(NSAttributedString(string: "  Have a Creator/Business IG:"))
        
        l0.attributedText = attributedString
        
        //StackView
        let stackHTS = UIStackView()
        stackHTS.axis = NSLayoutConstraint.Axis.vertical
        stackHTS.distribution = .equalSpacing
        stackHTS.alignment = .center
        stackHTS.spacing = spacing
       
        
        //Add StackView + elements
        stackHTS.addArrangedSubview(l0)
        stackHTS.addArrangedSubview(t0)
        stackHTS.addArrangedSubview(l1)
        stackHTS.addArrangedSubview(t1)
        
        self.view.addSubview(stackHTS)
        
        
        //Constraints StackView
        stackHTS.translatesAutoresizingMaskIntoConstraints  = false
        stackHTS.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        stackHTS.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        let stackHTSHeight = 3*spacing + LH*2 + TH + 125
        stackHTS.heightAnchor.constraint(equalToConstant: CGFloat(stackHTSHeight)).isActive = true
    }
    
    
    
    
}


