//
//  IgApiSetupVC+acts.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 14/06/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit
import SafariServices

extension IgApiSetupVC  {
    
    @objc func loginFunc (_ sender: Any) {
        
        if let url = URL(string: "https://www.facebook.com") {
            
            let vc = SFSafariViewController(url: url)
            present(vc, animated: true)
            
         }
        
    }
    
    @objc func createPageFunc (_ sender: Any) {
        
        if let url = URL(string: "https://www.facebook.com/pages/create") {
            
            let vc = SFSafariViewController(url: url)
            present(vc, animated: true)
            
         }
    }
    
    @objc func convertIGFunc (_ sender: Any) {
        
        let vwc = HowToSetupProIGVC()
        vwc.modalPresentationStyle = .overFullScreen
        vwc.modalTransitionStyle = .coverVertical
        self.present(vwc, animated: true, completion: nil)
    }
    
    @objc func continueFunc (_ sender: Any) {
        
        if UserDefaults.standard.object(forKey: "continued_IgApiSetupVC") == nil {
            UserDefaults.standard.set("true", forKey: "continued_IgApiSetupVC")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}

