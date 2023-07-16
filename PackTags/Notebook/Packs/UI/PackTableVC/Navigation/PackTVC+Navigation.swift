//
//  PackTVC+Navigation.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 14/03/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

// MARK: - Navigation
extension PackTableVC {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let segueIdentifier = segue.identifier else {
            return
        }
        
        if let origin = PackTableVCSegueOrigin(rawValue: segueIdentifier) {
            if origin == .showDetail {
                handleSelectedThemeData(for: segue, sender: sender)
                resetStatusBarColor = true
            }
        }
    }
}

//MARK: - Unwind
extension PackTableVC {
    @IBAction func unwindToThemeList(sender: UIStoryboardSegue) {
        updatePackTableVC()
        resetStatusBarColor = false
    }
    
    @IBAction func unwindFromCancel(segue: UIStoryboardSegue) {
        resetStatusBarColor = false
    }
    
    override func canPerformUnwindSegueAction(_ action: Selector,
        from fromViewController: UIViewController,
        withSender sender: Any) -> Bool
    {
        return true
        //if true -> unwind segue will execute first unwindToThemeList it encounters in hierarchy (PackTableVC's one)
        //if false -> it will ignore and continue to the second it encounters in hierarchy (TTVC's one)
    }
}
