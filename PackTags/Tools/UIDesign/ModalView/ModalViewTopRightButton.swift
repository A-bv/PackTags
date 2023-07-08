//
//  ModalUI.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 09/06/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

extension UIViewController {
    private enum Constants {
        static let distance10 = CGFloat(10)
        static let buttonSize = CGFloat(22)
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

    @objc func dissmissPicker(sender: UIButton) {
        let vc = String(describing: type(of: self))
        //->SetupCheck: Dismiss all views over root view for ApiSetupVC
        if vc == "ApiSetupVC" {
            self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
