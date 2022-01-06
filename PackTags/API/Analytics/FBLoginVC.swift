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
    
    let loginButton: FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["instagram_basic","pages_show_list","instagram_manage_insights"]
        return button
    }()
    
    
    // Delegates
    // triggered when just after login
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
        if ((error) != nil){}
        
        //Detects first time login
        UserDefaults.standard.set(true, forKey: "pressedFBLoginButton")
        
        //Checks Setup
        if AccessToken.current != nil {
            GetJson.apiGraphIgBHub(of: Profile.self, token: result?.token?.tokenString, smartGString: nil, Completion: {
                _ in
                    Foundation.UserDefaults.standard.set(true, forKey: "isCorrectSetup")
            })
            
        }
        
        
        if AccessToken.current != nil {
            Utility.simpleShortAlert(title: "Connected!", message: "You can now access analytics and generate hashtags.", vc: self, okDismissVc: true)
            
        } else {
            print("cancelled")
        }
        
    }
    
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {}

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.applyBlur()
        self.modalUI(arrowButton: false)
        self.placeHelpButton (isHelpSetupIgPro: true)
        
        let loginButton = loginButton
        loginButton.delegate = self
        loginButton.center = view.center
        view.addSubview(loginButton)
        
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        shouldShowIgApiSetupVC ()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
    }
}


























 













