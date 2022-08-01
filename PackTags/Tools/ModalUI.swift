//
//  ModalUI.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 09/06/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit
import SafariServices

extension UIViewController {
    private enum Links {
        static let facebookSetupHelpUrl = "https://www.facebook.com/business/help/502981923235522"
    }
    
    private enum Strings {
        static let setupHelpQuestion = "Help?".localized()
        static let setupTitle = "Setup".localized()
    }
    
    private enum Constants {
        static let distance10 = CGFloat(10)
        static let buttonSize = CGFloat(22)
        static let distance16 = CGFloat(16)
        static let distance34 = CGFloat(34)
    }
    
    func placeTopRightButton (arrowButton: Bool) {
        let btn: UIButton = {
            let btn = UIButton()
            btn.tintColor = UIColor.label

            let image = arrowButton == true ? UIImage(named: "ciDown") : UIImage(named: "close_round")
            let tintedImage = image?.withRenderingMode(.alwaysTemplate)
            btn.setBackgroundImage(tintedImage ,for: .normal)
            btn.addTarget(self, action: #selector(dissmissPicker(sender:)), for: .touchUpInside)
            
            return btn
        } ()
        self.view.addSubview(btn)
        
        // -- constraints --
        let cstW = view.frame.width/Constants.distance10
        
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: cstW).isActive = true
        
        // -- button --
        btn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -cstW).isActive = true
        btn.heightAnchor.constraint(equalToConstant: Constants.buttonSize).isActive = true
        btn.widthAnchor.constraint(equalToConstant: Constants.buttonSize).isActive = true
    }
    
    func placeHelpButton (isHelpSetupIgPro: Bool) {
        let helpBtn: UIButton = {
            let btn = UIButton()
            btn.setTitle(Strings.setupHelpQuestion, for: .normal)
            btn.setTitleColor(customPurple, for: .normal)
            btn.addTarget(
                self,
                action: #selector(showWebSetBusinessIG(_:)),
                for: .touchUpInside)
            return btn
        } ()
        
        let setupBtn: UIButton = {
            let btn = UIButton()
            btn.setTitle(Strings.setupTitle, for: .normal)
            btn.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title3)
            btn.setTitleColor(customPurple, for: .normal)
            btn.addTarget(
                self,
                action: #selector(showHowToSetupProIGVC(_:)),
                for: .touchUpInside)
            return btn
        } ()
                
        let btn = isHelpSetupIgPro ? setupBtn : helpBtn
        self.view.addSubview(btn)
        
        // -- constraints --
        let cstW = view.frame.width/Constants.distance10
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.topAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.topAnchor,
            constant: cstW).isActive = true
        
        // -- button --
        btn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: cstW).isActive = true
        btn.heightAnchor.constraint(equalToConstant: Constants.buttonSize).isActive = true
    }

    func placeTextView (textView: UITextView) {
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.adjustsFontForContentSizeCategory = true
        textView.autocorrectionType = UITextAutocorrectionType.no
        textView.keyboardType = UIKeyboardType.default
        textView.returnKeyType = UIReturnKeyType.done
        textView.isEditable = false
        textView.textAlignment = .center
        self.view.addSubview(textView)
        
        let cstW = view.frame.width/Constants.distance10
        
        textView.topAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.topAnchor,
            constant: cstW + Constants.buttonSize + Constants.distance16).isActive = true
        textView.leftAnchor.constraint(
            equalTo: view.leftAnchor,
            constant: Constants.distance16).isActive = true
        textView.rightAnchor.constraint(
            equalTo: view.rightAnchor,
            constant: -Constants.distance16).isActive = true
        textView.bottomAnchor.constraint(
            equalTo: view.bottomAnchor,
            constant: -Constants.distance34).isActive = true
    }
    
    // MARK: - objc action functions
    @objc func showWebSetBusinessIG (_ sender: Any) {
        if let url = URL(string: Links.facebookSetupHelpUrl) {
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
