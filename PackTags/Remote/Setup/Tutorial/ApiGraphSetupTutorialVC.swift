//
//  AnalyticsSetupVC.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 09/06/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit
import SafariServices

class ApiGraphSetupTutorialVC: UIViewController {
    
    deinit {
        print("deinit ApiGraphSetupTutorialVC")
    }
    
    private enum Strings {
        static let switchAccount = "Account type".localized()
        static let createAPage = "Create a page".localized()
        static let login = "Login".localized()
        static let accountLinkingTitle = "Account Linking".localized()
        static let continueString = "Continue".localized()
    }
    
    private enum Constants {
        static let value10: CGFloat = 10
        static let value20: CGFloat = 20
        static let titleTopDistance: CGFloat = 40
        static let value44: CGFloat = 44
        static let value50: CGFloat = 50
        static let value200: CGFloat = 200
    }
    
    let cstH = UIScreen.main.bounds.height >= 600.0 ? CGFloat(80.0) : CGFloat(65.0)
    
    private enum Links {
        // static let facebookLink = "https://www.facebook.com"
        static let facebookCreatePageLink = "https://www.facebook.com/pages/create"
    }
    
    let actions =  [
        // #selector(loginFunc(_:)),
        #selector(createPageFunc(_:)),
        #selector(convertIGFunc(_:))
    ]
    
    static var businessAccAttributedString: NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: "")
        attributedString.append(NSAttributedString(string: "   \(Strings.switchAccount)"))
        return attributedString
    }
    
    static var facebookPageAttributedString: NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: "")
        attributedString.append(NSAttributedString(string: "  \(Strings.createAPage)"))
        return attributedString
    }
    
    static var loginAttributedString: NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: "")
        attributedString.append(NSAttributedString(string: "  \(Strings.login)"))
        return attributedString
    }
    
    var labels = [
        // loginAttributedString,
        facebookPageAttributedString,
        businessAccAttributedString]
    
    var buttonIcons = [
        // UIImage(named: "fbColor"),
        UIImage(named: "fbColor"),
        UIImage(named: "igColor")
    ]
    
    var buttons: [UIButton] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.applyBlur()
        self.placeTopRightButton(arrowButton: false)
        self.buildUI()
    }

    func buildUI() {
        /*
        let l1: UILabel  = {
            let label = UILabel()
            label.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.title2)
            label.clipsToBounds = true
            label.translatesAutoresizingMaskIntoConstraints = false
            
            let attributedString = NSMutableAttributedString(string: "")
            attributedString.append(NSAttributedString(attachment: instagramIconAttachment))
            attributedString.append(NSAttributedString(string: " \(Strings.accountLinkingTitle)"))
            
            label.attributedText = attributedString
            label.textColor = customPurple
            return label
        }()*/
        
        let continueBtn: UIButton  = {
            let btn = UIButton()
            btn.setTitleColor(customPurple, for: .normal)
            btn.setTitle(Strings.continueString, for: .normal)
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.addTarget(
                self,
                action: #selector(continueFunc(_:)),
                for: .touchUpInside)
            return btn
        }()
        
        // let cstW = view.frame.width/Constants.value10
        
        // self.view.addSubview(l1)
        self.view.addSubview(continueBtn)
        
        
        //MARK: - Title & Continue part
        /*
        l1.topAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.topAnchor,
            constant: cstW).isActive = true
        l1.heightAnchor.constraint(
            equalToConstant: Constants.value44 + Constants.titleTopDistance).isActive = true
        l1.trailingAnchor.constraint(
            equalTo: view.trailingAnchor,
            constant: -cstW).isActive = true
        l1.leadingAnchor.constraint(
            equalTo: view.leadingAnchor,
            constant: cstW).isActive = true
         */
        
        continueBtn.heightAnchor.constraint(
            equalToConstant: Constants.value44).isActive = true
        continueBtn.centerXAnchor.constraint(
            equalTo: self.view.centerXAnchor).isActive = true
        continueBtn.bottomAnchor.constraint(
            equalTo: view.bottomAnchor,
            constant: -Constants.value50).isActive = true
        
        
        //MARK: - StackView part
        for i in 0...labels.count-1 {
            let btn: UIButton = {
                let button = UIButton.init()
                button.setTitleColor(.white, for: .normal)
                button.setAttributedTitle(labels[i], for: .normal)
                button.backgroundColor = UITextView.appearance().tintColor.withAlphaComponent(0.5)
                button.layer.cornerRadius = Constants.value44/2
                button.layer.borderColor = UIColor.white.cgColor
                button.translatesAutoresizingMaskIntoConstraints = false
                button.addTarget(self, action: actions[i], for: .touchUpInside)
                button.heightAnchor.constraint(equalToConstant: Constants.value44).isActive = true
                button.widthAnchor.constraint(equalToConstant: Constants.value200).isActive = true
                button.setImage(buttonIcons[i], for: .normal)
                return button
            }()
            
            buttons.append(btn)
        }
        
        //StackView
        let stackA = UIStackView()
        stackA.axis = NSLayoutConstraint.Axis.vertical
        stackA.distribution = .fillEqually
        stackA.alignment = .center
        stackA.spacing = cstH
        
        //Add StackView + elements
        for i in 0...labels.count-1 {
            stackA.addArrangedSubview(buttons[i])
        }
        
        self.view.addSubview(stackA)
        
        
        //Constraints StackView
        stackA.translatesAutoresizingMaskIntoConstraints  = false
        stackA.centerYAnchor.constraint(
            equalTo: self.view.centerYAnchor,
            constant: Constants.value20).isActive = true
        stackA.centerXAnchor.constraint(
            equalTo: self.view.centerXAnchor).isActive = true
        stackA.heightAnchor.constraint(
            equalToConstant: CGFloat(labels.count)*Constants.value44 + CGFloat(labels.count-1)*cstH ).isActive = true
    }
}

extension ApiGraphSetupTutorialVC {
    /*
    @objc func loginFunc (_ sender: Any) {
        if let url = URL(string: Links.facebookLink) {
            let vc = SFSafariViewController(url: url)
            present(vc, animated: true)
         }
    }*/
    
    @objc func createPageFunc (_ sender: Any) {
        if let url = URL(string: Links.facebookCreatePageLink) {
            let vc = SFSafariViewController(url: url)
            present(vc, animated: true)
         }
    }
    
    @objc func convertIGFunc (_ sender: Any) {
        let vwc = ProIGSetupVC()
        vwc.modalPresentationStyle = .overFullScreen
        vwc.modalTransitionStyle = .coverVertical
        self.present(vwc, animated: true, completion: nil)
    }
    
    @objc func continueFunc (_ sender: Any) {
        if UserDefaults.standard.object(forKey: "continuedApiGraphSetupOnce") == nil {
            UserDefaults.standard.set("true",  forKey: "continuedApiGraphSetupOnce")
        }
        self.dismiss(animated: true, completion: nil)
    }
}
