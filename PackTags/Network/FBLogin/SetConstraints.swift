//
//  File.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 22.02.23.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

extension UIViewController {
    private enum Constants {
        static let distance10 = CGFloat(10)
        static let buttonSize = CGFloat(22)
    }
    
    func setupHelpButtonConstraints(_ btn: UIButton) {
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
}
