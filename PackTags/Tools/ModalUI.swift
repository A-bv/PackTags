//
//  ModalUI.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 09/06/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit
import SafariServices

// Close modal view button
extension UIViewController {
    
    func modalUI (arrowButton: Bool) {
        
        let btn: UIButton = {
            let btn = UIButton()
            btn.tintColor = UIColor.label
            
            //btn.backgroundColor = UITextView.appearance().tintColor
            let image = arrowButton == true ? UIImage(named: "ciDown") : UIImage(named: "close_round")
            let tintedImage = image?.withRenderingMode(.alwaysTemplate)
            btn.setBackgroundImage(tintedImage ,for: .normal)
            btn.addTarget(self, action: #selector(dissmissPicker(sender:)), for: .touchUpInside)
            
            
            return btn
        } ()
        
        self.view.addSubview(btn)
        
        // -- constraints --
        let cstW = view.frame.width/10
        let btnSize = CGFloat(22)
        
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        btn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: cstW).isActive = true
        
        // -- button --
        btn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -cstW).isActive = true
        btn.heightAnchor.constraint(equalToConstant: btnSize).isActive = true
        btn.widthAnchor.constraint(equalToConstant: btnSize).isActive = true
    }
    
    @objc func dissmissPicker(sender: UIButton) {
        
        let vc = String(describing: type(of: self))
        
        //->SetupCheck: Dismiss all views over root view for IgApiSetupVC
        if vc == "IgApiSetupVC" {
            self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func dissmissAllUntilRootVC(sender: UIButton) {
        self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
    }
}


// Add a help button
extension UIViewController {
    func placeHelpButton (isHelpSetupIgPro: Bool) {
        
        let helpBtn: UIButton = {
            let btn = UIButton()
            btn.setTitle("Help?", for: .normal)
            btn.setTitleColor(customPurple, for: .normal)
            btn.addTarget(self, action: #selector(showWebSetBusinessIG(_:)), for: .touchUpInside)
            return btn
        } ()
        
        let setupBtn: UIButton = {
            let btn = UIButton()
            btn.setTitle("Setup", for: .normal)
            btn.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title3)
            btn.setTitleColor(customPurple, for: .normal)
            btn.addTarget(self, action: #selector(showHowToSetupProIGVC(_:)), for: .touchUpInside)
            return btn
        } ()
        
        var btn = UIButton()
        if isHelpSetupIgPro == true {
            btn = setupBtn
        } else {
            btn = helpBtn
        }
        
        self.view.addSubview(btn)
        
        // -- constraints --
        let cstW = view.frame.width/10
        let btnSize = CGFloat(22)
        
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        btn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: cstW).isActive = true
        
        // -- button --
        btn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: cstW).isActive = true
        btn.heightAnchor.constraint(equalToConstant: btnSize).isActive = true
        
    }
    
    @objc func showWebSetBusinessIG (_ sender: Any) {
        if let url = URL(string: "https://www.facebook.com/business/help/502981923235522") {
            let vc = SFSafariViewController(url: url)
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true)
        }
    }
    
    @objc func showHowToSetupProIGVC (_ sender: Any) {
        let vwc = IgApiSetupVC()
        vwc.modalPresentationStyle = .overFullScreen
        vwc.modalTransitionStyle = .crossDissolve
        self.present(vwc, animated: true, completion: nil)
    }
}


// Add a textview
extension UIViewController {
    func placeTextView (textView: UITextView) {
        // Def TextView
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.adjustsFontForContentSizeCategory = true
        textView.autocorrectionType = UITextAutocorrectionType.no
        textView.keyboardType = UIKeyboardType.default
        textView.returnKeyType = UIReturnKeyType.done
        textView.isEditable = false
        textView.textAlignment = .center
        self.view.addSubview(textView)
        
        let cstW = view.frame.width/10
        let btnSize = CGFloat(22)
        
        textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: cstW + btnSize + 16).isActive = true
        textView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        textView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        textView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -34).isActive = true
    }
}
