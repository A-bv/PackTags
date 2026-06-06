//
//  FloatingButtonFactory.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 25.02.2024.
//  Copyright © 2024 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

class FloatingButtonFactory {
    static func createFloatingButton(onView view: UIView) -> UIButton {
        // Create the button
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        
        // Create and configure the gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = button.bounds
        gradientLayer.colors = [UIColor.customPurple.withAlphaComponent(0.5).cgColor, UIColor.systemBlue.withAlphaComponent(0.7).cgColor]
        gradientLayer.cornerRadius = 15
        gradientLayer.masksToBounds = true
        button.layer.addSublayer(gradientLayer)
        
        // Create and configure the blurred background view
        let blur = UIVisualEffectView(
            effect: UIBlurEffect(style: DarkMode.isDarkMode() ? .systemMaterialLight : .regular))
        blur.frame = button.bounds
        blur.isUserInteractionEnabled = false
        //button.addSubview(blur)
        
        // Configure the button appearance
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        
        // Add the plus icon
        let image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .medium))
        let imageView = UIImageView(image: image)
        imageView.tintColor = UIColor.colorBkgd
        imageView.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(imageView)
        
        // Center the plus icon in the button
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
        
        // Add the button to the view and configure constraints
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -15),
            button.heightAnchor.constraint(equalToConstant: 30),
            button.widthAnchor.constraint(equalToConstant: 30)
        ])
        
        return button
    }
}
