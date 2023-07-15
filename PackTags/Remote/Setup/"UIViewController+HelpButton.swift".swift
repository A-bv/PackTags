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
    
    private func setupHelpButtonConstraints(_ btn: UIButton) {
        let distance10: CGFloat = 10
        let buttonSize: CGFloat = 22
        
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            btn.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: distance10),
            btn.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: distance10),
            btn.heightAnchor.constraint(equalToConstant: buttonSize)
        ])
    }
    
    private func placeHelpButton(title: String, target: Any, action: Selector) {
        let helpBtn = createHelpButton(title: title, target: target, action: action)
        view.addSubview(helpBtn)
        setupHelpButtonConstraints(helpBtn)
    }
    
    func placeHelpButtonForFBLoginSetup() {
        placeHelpButton(
            title: Strings.setupTitle,
            target: self,
            action: #selector(showProIGSetupVC(_:))
        )
    }
    
    func placeHelpButtonForSetupIGProWeb() {
        placeHelpButton(
            title: Strings.setupHelpQuestion,
            target: self,
            action: #selector(showWebSetBusinessIG(_:))
        )
    }
    
    private func createHelpButton(title: String, target: Any, action: Selector) -> UIButton {
        let btn = UIButton()
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(customPurple, for: .normal)
        btn.addTarget(target, action: action, for: .touchUpInside)
        return btn
    }

    @objc func showProIGSetupVC(_ sender: Any) {
        let vc = ProIGSetupVC()
        presentViewController(vc)
    }

    @objc func showWebSetBusinessIG(_ sender: Any) {
        guard let url = URL(string: Strings.facebookSetupHelpUrl) else { return }
        let vc = SFSafariViewController(url: url)
        presentViewController(vc)
    }
    
    private func presentViewController(_ viewController: UIViewController) {
        viewController.modalPresentationStyle = .overFullScreen
        viewController.modalTransitionStyle = .crossDissolve
        self.present(viewController, animated: true)
    }
}
