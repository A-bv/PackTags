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

// MARK: - Class
class FBLoginVC: UIViewController, LoginButtonDelegate {
    
    deinit {
        print("deinit FBLoginVC")
    }
    
    private enum Strings {
        static let connectedAlertTitle = "Connected!".localized()
        static let accessAnalyticsConfirm = "You can now access analytics and generate hashtags.".localized()
        static let setupTitle = "Setup".localized()
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
        showApiGraphSetupVCIfneeded()
        showWrongSetupAlertIfNeeded()
    }
}

// Delegates
extension FBLoginVC {
    // triggered when just after login
    func loginButton(
        _ loginButton: FBLoginButton,
        didCompleteWith result: LoginManagerLoginResult?,
        error: Error?
    ) {
        if let error { print("Fb login error:", error) }
        savePushedFBLoginButtonOnce()
        apiCallGetIgBusinessId()
    }

    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {}
}

// MARK: - Logic
extension FBLoginVC {
    private func apiCallGetIgBusinessId() {
        
        let token = FBToken()
        saveCorrectStatus(token: token)
        saveFBToken(token: token)
        
        if token.isValid {
            verifySetupFbPages(Completion: {[weak self] _ in
                self?.verifySetupIgBAndGetIgBId(Completion: {(id) in
                    self?.saveInstagramBusinessAccountID(id: id)
                    self?.showSuccessfulSetupAlert()
                })
            })
        } else {
            Alerts.setupTroubleShootingAlert(presenterVc: self)
        }
    }
}

// MARK: - Logic
extension FBLoginVC {
    private func verifySetupFbPages (Completion block: @escaping (([String]) -> ())) {
        // 0. Fb acc gives a token
        // Request 1. Get facebook business page of the facebook account
        let fbPageRequest = GraphRequest(graphPath: "/me/accounts", httpMethod: .get)
        
        fbPageRequest.start(
            completionHandler: { connection, result, error in
            
            if let error = error {
                print("fbPageRequest error :", error)
                return
            }
            
            guard let response1 = result as? NSDictionary else { return } //
            //id page fb packtags.app 107298991584829
            // ----- CAUTION ----- only works with one associated page (takes the first in array)
            guard let pages = (response1.value(forKeyPath: "data.name") as? [String]) else { return }
            
            if pages.isEmpty {
                // Exit if no IGPro or wrong linked FB page(s)
                Alerts.setupTroubleShootingAlert(presenterVc: self)
                return
            }
            // ----- CAUTION -----
            
            block(pages)
        })
    }
    
    private func verifySetupIgBAndGetIgBId (Completion block: @escaping ((String) -> ())){
        
        // Required: Fb acc + Fb business page + IG Business or creator
        let igBRequest = GraphRequest(
            graphPath: "/me/accounts",
            parameters: ["fields":"instagram_business_account"],
            httpMethod: .get)
        
        igBRequest.start(
            completionHandler: { connection, result, error in
                
                if let error = error {
                    print("igBRequest error :", error)
                    return
                }
                
                guard let response2 = result as? NSDictionary else { return } //
                guard let igBIds = response2.value(forKeyPath: "data.instagram_business_account.id") as? [String]
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

// MARK: - Logic
extension FBLoginVC {
    func saveFBToken (token: FBToken) {
        let token = token.tokenString
        UserDefaults.standard.set( token, forKey: "fbToken")
    }
    
    func saveCorrectStatus (token: FBToken) {
        if token.isValid {
            UserDefaults.standard.set(true, forKey: "isCorrectSetup")
        } else {
            UserDefaults.standard.set(false, forKey: "isCorrectSetup")
        }
    }
}

// MARK: - Logic
extension FBLoginVC {
    private func showApiGraphSetupVCIfneeded() {
        if UserDefaults.standard.object(forKey: "continuedApiGraphSetupOnce") == nil {
            let controller = ApiGraphSetupTutorialVC()
            controller.modalPresentationStyle = .overFullScreen
            controller.modalTransitionStyle = .coverVertical
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    private func showWrongSetupAlertIfNeeded() {
        let triedASetup = UserDefaults.standard.object(forKey: "pressedFBLoginButton")
        let isCorrectSetup = UserDefaults.standard.bool(forKey: "isCorrectSetup")
        if isCorrectSetup == false, triedASetup != nil {
            Alerts.setupTroubleShootingAlert(presenterVc: self)
        }
    }
}

// MARK: - Logic
extension FBLoginVC {
    private func savePushedFBLoginButtonOnce() {
        if UserDefaults.standard.object(forKey: "pressedFBLoginButton") == nil {
            UserDefaults.standard.set(true, forKey: "pressedFBLoginButton")
        }
    }
    
    private func saveInstagramBusinessAccountID(id: String) {
        UserDefaults.standard.set(id, forKey: "IgBId")
    }
}

// MARK: - UI
extension FBLoginVC {
    private func setupFBLoginVC () {
        self.view.applyBlur()
        self.placeTopRightButton(arrowButton: false)
        self.placeHelpButtonForFBLoginSetup()
        
        let loginButton = loginButton
        loginButton.delegate = self
        loginButton.center = view.center
        view.addSubview(loginButton)
    }
}

// MARK: - UI
extension FBLoginVC {
    func showSuccessfulSetupAlert() {
        Alerts.simpleShortAlert(
            title: Strings.connectedAlertTitle,
            message: Strings.accessAnalyticsConfirm,
            vc: self,
            okDismissVc: true)
    }
}

// MARK: - UI
extension FBLoginVC {
    func placeHelpButtonForFBLoginSetup() {
        let setupBtn: UIButton = {
            let btn = UIButton()
            btn.setTitle(Strings.setupTitle, for: .normal)
            btn.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title3)
            btn.setTitleColor(customPurple, for: .normal)
            btn.addTarget(
                self,
                action: #selector(showProIGSetupVC(_:)),
                for: .touchUpInside)
            return btn
        } ()
        view.addSubview(setupBtn)
        setupHelpButtonConstraints(setupBtn)
    }
    
    @objc func showProIGSetupVC (_ sender: Any) {
        let vwc = ApiGraphSetupTutorialVC()
        vwc.modalPresentationStyle = .overFullScreen
        vwc.modalTransitionStyle = .crossDissolve
        self.present(vwc, animated: true, completion: nil)
    }
}
