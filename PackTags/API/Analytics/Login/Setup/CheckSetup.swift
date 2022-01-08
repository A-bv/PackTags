//
//  CheckSetupApiGraph.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 17/06/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit
import Foundation
import FBSDKLoginKit

//->SetupCheck
extension UIViewController {
    func shouldShowIgApiSetupVC () {
    
        let b: Bool? = UserDefaults.standard.bool(forKey: "isCorrectSetup")
        
        //Only show if never pressed continue on IgApiSetupVC()
        if UserDefaults.standard.object(forKey: "continued_IgApiSetupVC") == nil {
             let vc1 = IgApiSetupVC()
             vc1.modalPresentationStyle = .overFullScreen
             vc1.modalTransitionStyle = .coverVertical
             self.present(vc1, animated: true, completion: nil)
        }
        
        
        //Alert if already pressed fb login button and if wrong setup
        if b == false && UserDefaults.standard.object(forKey: "pressedFBLoginButton") != nil {
            Utility.setupTroubleShootingAlert(arr: [])
        }
    }
    
    func isCorrectSetup () -> Bool {
        let b: Bool? = UserDefaults.standard.bool(forKey: "isCorrectSetup")
        
        if b == nil || b == false {
            
            let vc1 = FBLoginVC()
            vc1.modalPresentationStyle = .overFullScreen
            vc1.modalTransitionStyle = .coverVertical
                    
            self.present(vc1, animated: true, completion: nil)
        
            return false
        } else {
            
            
            if AccessToken.current == nil {
                let vc = FBLoginVC()
                vc.modalPresentationStyle = .overFullScreen
                vc.modalTransitionStyle = .coverVertical
                self.present(vc, animated: true, completion: nil)
                return false
                
            } else {
                return true
            }
        }
    }

}
