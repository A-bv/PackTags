//
//  IgApiSetupVC+UI.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 14/06/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

extension IgApiSetupVC  {
    func buildUI() {
        
        // UI1
        let l1: UILabel  = {
            let label = UILabel()
            label.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.title2)
            label.clipsToBounds = true
            label.translatesAutoresizingMaskIntoConstraints = false
            
            let attributedString = NSMutableAttributedString(string: "")
            attributedString.append(NSAttributedString(attachment: instagramIconAttachment))
            attributedString.append(NSAttributedString(string: " Account Linking"))
            
            label.attributedText = attributedString
            label.textColor = customPurple
            return label
        }()
        
        let continueBtn: UIButton  = {
            let btn = UIButton()
            btn.setTitleColor(customPurple, for: .normal)
            btn.setTitle("Continue", for: .normal)
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.addTarget(self, action: #selector(continueFunc(_:)), for: .touchUpInside)
            return btn
        }()
        
        let cstW = view.frame.width/10
        let titleTopDistance = CGFloat(40)
        
        self.view.addSubview(l1)
        self.view.addSubview(continueBtn)
        

        
        //MARK: - Title & Continue part
        
        l1.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: cstW).isActive = true
        l1.heightAnchor.constraint(equalToConstant: 44 + titleTopDistance).isActive = true
        l1.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -cstW).isActive = true
        l1.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: cstW).isActive = true
        //l1.widthAnchor.constraint(equalToConstant: 300).isActive = true
        
        continueBtn.heightAnchor.constraint(equalToConstant: 44).isActive = true
        continueBtn.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        continueBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        
        
        //MARK: - StackView part
        
        //buttons
        for i in 0...labels.count-1 {
            let btn: UIButton = {
                let button = UIButton.init()
                button.setTitleColor(.white, for: .normal)
                button.setAttributedTitle(labels[i], for: .normal)
                button.backgroundColor = UITextView.appearance().tintColor.withAlphaComponent(0.5) //.clear //bkgdColor
                button.layer.cornerRadius = 22
                //button.layer.borderWidth = 0.5
                button.layer.borderColor = UIColor.white.cgColor
                button.translatesAutoresizingMaskIntoConstraints = false
                button.addTarget(self, action: actions[i], for: .touchUpInside)
                button.heightAnchor.constraint(equalToConstant: 44).isActive = true
                button.widthAnchor.constraint(equalToConstant: 200).isActive = true
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
        stackA.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 20).isActive = true
        stackA.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        stackA.heightAnchor.constraint(equalToConstant: CGFloat(labels.count*44) + CGFloat(labels.count-1)*cstH ).isActive = true
    }
}

