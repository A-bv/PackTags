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
            Alerts.setupTroubleShootingAlert(arr: [], presenterVc: self)
        }
    }
    
    func isFbTokenValid () -> Bool {
        guard let token = AccessToken.current, !token.isExpired else {return false}
        UserDefaults.standard.set( token.tokenString, forKey: "fbToken")
        return true
    }
    
    func shouldShowFBLogin () -> Bool {
        let b: Bool? = UserDefaults.standard.bool(forKey: "isCorrectSetup")
        
        let vc = FBLoginVC()
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .coverVertical
        
        if b == nil || b == false {
            self.present(vc, animated: true, completion: nil)
            return true
        } else {
            if !isFbTokenValid() {
                self.present(vc, animated: true, completion: nil)
                return true
            } else {
                return false
            }
        }
    }
}



