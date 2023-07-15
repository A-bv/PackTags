//
//  TVC+Navigation.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 28.05.22.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

extension ThemeVC {
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         super.prepare(for: segue, sender: sender)

         guard let segueIdentifier = segue.identifier else {
             return
         }
         
         if let origin = ThemeVCSegueOrigin(rawValue: segueIdentifier) {
             switch origin {
             case .cancel:
                 return
             case .save:
                 handleSelectedThemeData(for: segue, sender: sender)
             }
         }
     }
     
     @IBAction func cancel(_ sender: UIBarButtonItem) {
          let isPresentingInAddThemeMode = presentingViewController is UINavigationController
          if isPresentingInAddThemeMode {
              dismiss(animated: true, completion: nil)
             performSegue(withIdentifier: "cancel", sender: self)
          } else if let owningNavigationController = navigationController {
              owningNavigationController.popViewController(animated: false)
          } else {
              fatalError("func cancel")
          }
     }
}
