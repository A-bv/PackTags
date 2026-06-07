//
//  File.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 22.02.23.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

import UIKit
import SafariServices

extension UIViewController {
    private enum Constants {
        static let distance10 = CGFloat(10)
        static let buttonSize = CGFloat(22)
    }
    
    private enum Strings {
        static let setupTitle = "Setup".localized()
        static let setupHelpQuestion = "Help?".localized()
        static let facebookSetupHelpUrl = "https://www.facebook.com/business/help/502981923235522"
    }
    
    func placeHelpButtonForFBLoginSetup(
        target: Any? = nil,
        action: Selector? = nil
    ) {
        placeHelpButton(
            title: Strings.setupTitle,
            target: target ?? self,
            action: action ?? #selector(showInfoSetupIGCreatorVC(_:))
        )
    }
    
    func placeHelpButtonForSetupIGProWeb() {
        placeHelpButton(
            title: Strings.setupHelpQuestion,
            target: self,
            action: #selector(showWebSetBusinessIG(_:))
        )
    }
    
    func placeTopRightButton(arrowButton: Bool) {
        let btn = UIButton()
        btn.tintColor = UIColor.label
        
        let imageName = arrowButton ? "ciDown" : "close_round"
        if let image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate) {
            btn.setBackgroundImage(image, for: .normal)
        }
        
        btn.addTarget(self, action: #selector(dissmissPicker(sender:)), for: .touchUpInside)
        
        self.view.addSubview(btn)
        rightButtonSetupConstraints(btn: btn)
    }
    
    private func placeHelpButton(title: String, target: Any, action: Selector) {
        let helpBtn = createHelpButton(title: title, target: target, action: action)
        view.addSubview(helpBtn)
        setupHelpButtonConstraints(helpBtn)
    }
    
    private func createHelpButton(title: String, target: Any, action: Selector) -> UIButton {
        let btn = UIButton()
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(customPurple, for: .normal)
        btn.addTarget(target, action: action, for: .touchUpInside)
        return btn
    }
    
    private func presentViewController(_ viewController: UIViewController) {
        viewController.modalPresentationStyle = .overFullScreen
        viewController.modalTransitionStyle = .crossDissolve
        self.present(viewController, animated: true)
    }

    @objc func showInfoSetupIGCreatorVC(_ sender: Any) {
        let viewController = ConnectedInsightsModule().makeViewController(for: .setupInfo)
        presentViewController(viewController)
    }

    @objc func showWebSetBusinessIG(_ sender: Any) {
        guard let url = URL(string: Strings.facebookSetupHelpUrl) else { return }
        let vc = SFSafariViewController(url: url)
        presentViewController(vc)
    }
    
    @objc func dissmissPicker(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func rightButtonSetupConstraints(btn: UIButton) {
        let padding = view.frame.width / Constants.distance10
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            btn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: padding),
            btn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            btn.heightAnchor.constraint(equalToConstant: Constants.buttonSize),
            btn.widthAnchor.constraint(equalToConstant: Constants.buttonSize)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupHelpButtonConstraints(_ btn: UIButton) {
        let padding = view.frame.width / Constants.distance10
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            btn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: padding),
            btn.leadingAnchor.constraint( equalTo: view.leadingAnchor, constant: padding),
            btn.heightAnchor.constraint(equalToConstant: Constants.buttonSize)
        ]

        NSLayoutConstraint.activate(constraints)
    }
}
