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
        navigationToThemeDetails(segue: segue, sender: sender)
    }
    
    //MARK: - Unwind
    @IBAction func unwindToThemeList(sender: UIStoryboardSegue) {
        setPackTableVC()
    }
    
    @IBAction func unwindFromCancel(segue: UIStoryboardSegue) {}
    
    override func canPerformUnwindSegueAction(_ action: Selector,
        from fromViewController: UIViewController,
        withSender sender: Any) -> Bool
    {
        return true //true = unwind segue stops here
    }
}
