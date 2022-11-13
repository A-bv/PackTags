//
//  FBLoginVc.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 25/05/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//
//User needs to have a Facebook User account that can perform Tasks on the Page connected to the targeted Instagram Business or Creator Account

import UIKit
import FBSDKLoginKit

class FBLoginVC: UIViewController, LoginButtonDelegate {
    
    deinit {
        print("deinit FBLoginVC")
    }
    
    private enum Strings {
        static let connectedAlertTitle = "Connected!".localized()
        static let accessAnalyticsConfirm = "You can now access analytics and generate hashtags.".localized()
    }
    
    let loginButton: FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = [
            "instagram_basic",
            "pages_show_list",
            "instagram_manage_insights"]
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFBLoginVC()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        shouldShowIgApiSetupVC ()
    }
    
    private func setupFBLoginVC () {
        self.view.applyBlur()
        self.placeTopRightButton(arrowButton: false)
        self.placeHelpButton (isHelpSetupIgPro: true)
        
        let loginButton = loginButton
        loginButton.delegate = self
        loginButton.center = view.center
        view.addSubview(loginButton)
    }
}

// Delegates
extension FBLoginVC {
    // triggered when just after login
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
        if ((error) != nil){ }
        checkSetup()
    }
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {}
}

// Checks
extension FBLoginVC {
    private func checkSetup() {
        //Checks Setup and save Instagram Business Account ID
        let uD = UserDefaults.standard
        //Detects first time login
        uD.set(true, forKey: "pressedFBLoginButton")
        if isFbTokenValid() {
            verifySetupFbPages(Completion: {[weak self] _ in
                self?.verifySetupIgBAndGetIgBId(Completion: {(IgBId) in
                    uD.set(true, forKey: "isCorrectSetup")
                    uD.set(IgBId, forKey: "IgBId")
                    Alerts.simpleShortAlert(
                        title: Strings.connectedAlertTitle,
                        message: Strings.accessAnalyticsConfirm,
                        vc: self,
                        okDismissVc: true)
                })
            })
        } else {
            uD.set(false, forKey: "isCorrectSetup")
            Alerts.setupTroubleShootingAlert(presenterVc: self)
        }
    }

    private func shouldShowIgApiSetupVC () {
        let isCorrectSetup = UserDefaults.standard.bool(forKey: "isCorrectSetup")
        let isBtnPressedFbLogin =
            UserDefaults.standard.object(forKey: "pressedFBLoginButton")
        let isBtnPressedOnIgApiSetupVC =
            UserDefaults.standard.object(forKey: "continued_IgApiSetupVC")
            
        //Only show if never pressed continue on IgApiSetupVC()
        if isBtnPressedOnIgApiSetupVC == nil {
            let controller = IgApiSetupVC()
            controller.modalPresentationStyle = .overFullScreen
            controller.modalTransitionStyle = .coverVertical
            self.present(controller, animated: true, completion: nil)
        }
        
        //Alert if already pressed fb login button and if wrong setup
        if isCorrectSetup == false && isBtnPressedFbLogin != nil {
            Alerts.setupTroubleShootingAlert(presenterVc: self)
        }
    }
}

// Calls
extension FBLoginVC {
    private func verifySetupFbPages (Completion block: @escaping (([String]) -> ())) {
        // 0. Fb acc gives a token
        // Request 1. Get facebook business page of the facebook account
        let fbPageRequest = GraphRequest(graphPath: "/me/accounts", httpMethod: .get)
    
        fbPageRequest.start(completionHandler: {connection,result,error in
            
            if let error = error {
                print("fbPageRequest error :", error)
                return
            }

            guard let response1 = result as? NSDictionary else { return } //
            //id page fb packtags.app 107298991584829
            // ----- CAUTION ----- only works with one associated page (takes the first in array)
            guard let pages = (response1.value(forKeyPath: "data.name") as? [String]) else { return }
            
            if pages == [] {
                // Exit if no IGPro or wrong linked FB page(s)
                print("No page")
                Alerts.setupTroubleShootingAlert(presenterVc: self)
                return
            }
            // ----- CAUTION -----
            
            block(pages)
        })
    }

    private func verifySetupIgBAndGetIgBId (Completion block: @escaping ((String) -> ())){
        
        // Required: Fb acc + Fb business page + IG Business or creator
           let igBRequest = GraphRequest(graphPath: "/me/accounts", parameters: ["fields":"instagram_business_account"], httpMethod: .get)
            
           igBRequest.start(completionHandler: {connection,result,error in
          
               if let error = error {
                   print("igBRequest error :", error)
                   return
               }
               
               guard let response2 = result as? NSDictionary else { return } //
               guard let igBIds = (response2.value(forKeyPath: "data.instagram_business_account.id") as? [String])
               else {
                   print("No business account linked or wrong pages selected")
                   Alerts.setupTroubleShootingAlert(presenterVc: self)
                   return
               }
               if igBIds.count >= 1 {
                   block(igBIds[0])
               } else {
                   return
               }
           })
    }
}

extension UIViewController {
    func isFbTokenValid () -> Bool {
        guard let token = AccessToken.current, !token.isExpired else { return false }
        UserDefaults.standard.set( token.tokenString, forKey: "fbToken")
        return true
    }
    
    func shouldShowFBLogin () -> Bool {
        let isCorrectSetup = UserDefaults.standard.bool(forKey: "isCorrectSetup")
        return (!isCorrectSetup || !isFbTokenValid())
    }
    
    func showFBLoginScreen () {
        let vc = FBLoginVC()
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .coverVertical
        self.present(vc, animated: true, completion: nil)
    }
}
