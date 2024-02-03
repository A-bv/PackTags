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
class FBLoginVC: UIViewController {
    
    deinit {
        print("deinit FBLoginVC")
    }
    
    init(viewModel: FBLoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private enum Strings {
        static let connectedAlertTitle = "Connected!".localized()
        static let accessAnalyticsConfirm = "You can now access analytics and generate hashtags.".localized()
        static let editYourSetup = "Edit Your Setup".localized()
        static let troubleShootingAlertMessage = "troubleShootingAlertMessage".localized()
    }
    
    private enum UserDefaultsKeys {
        static let setupInfoShown = UserDefaults.standard.object(forKey: "setupInfoShownOnce")
        static let triedASetup = UserDefaults.standard.object(forKey: "pressedFBLoginButton")
        static let isCorrectSetup = UserDefaults.standard.bool(forKey: "isCorrectSetup")
    }

    private enum Permissions {
        static let list = [
            "instagram_basic",
            "pages_show_list",
            "instagram_manage_insights",
            "business_management"
        ]
    }
    
    private let viewModel: FBLoginViewModel
    
    private let loginButton: FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = Permissions.list
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFBLoginVC()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        showApiGraphSetupVCIfNeeded()
        showWrongSetupAlertIfNeeded()
    }
}
    
extension FBLoginVC {
    private func showApiGraphSetupVCIfNeeded() {
        if UserDefaultsKeys.setupInfoShown == nil {
            showSetupScreen()
        }
    }
    
    private func showWrongSetupAlertIfNeeded() {
        if UserDefaultsKeys.isCorrectSetup == false,
           UserDefaultsKeys.triedASetup != nil
        {
            showTroubleshootingAlert()
        }
    }
}

// MARK: - UI
extension FBLoginVC: LoginButtonDelegate {
    private func setupFBLoginVC () {
        self.view.applyBlur()
        self.placeTopRightButton(arrowButton: false)
        self.placeHelpButtonForFBLoginSetup()
        self.placeFBLogingButton()
    }
    
    private func placeFBLogingButton() {
        let loginButton = loginButton
        loginButton.delegate = self
        loginButton.center = view.center
        view.addSubview(loginButton)
    }

}

// MARK: - Delegates
extension FBLoginVC {
    // When login is pressed
    func loginButton(
        _ loginButton: FBLoginButton,
        didCompleteWith result: LoginManagerLoginResult?,
        error: Error?
    ) {
        if let error {
            print("Fb login error:", error)
        }
        viewModel.savePushedFBLoginButtonOnce()
        performIgBusinessIdAPICall()
    }

    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {}
}

// MARK: - Actions
extension FBLoginVC {
    private func performIgBusinessIdAPICall() {
        let token = viewModel.getToken()
        guard token.isValid else {
            showTroubleshootingAlert()
            return
        }

        viewModel.apiCallGetIgBusinessId { [weak self] isCorrectSetup in
            if isCorrectSetup {
                self?.showSuccessfulSetupAlert()
            } else {
                self?.showTroubleshootingAlert()
            }
        }
    }
    
    private func showSuccessfulSetupAlert() {
        Alerts.simpleShortAlert(
            title: Strings.connectedAlertTitle,
            message: Strings.accessAnalyticsConfirm,
            presentingViewController: self,
            shouldDissmissPresentingVCWhenConfirmed: true)
    }
    
    private func showTroubleshootingAlert() {
        UserDefaults.standard.set(false, forKey: "isCorrectSetup")
        Alerts.simpleShortAlert(
            title: Strings.editYourSetup,
            message: Strings.troubleShootingAlertMessage,
            presentingViewController: self,
            shouldDissmissPresentingVCWhenConfirmed: false)
    }
    
    private func showSetupScreen() {
        let controller = ProIGSetupVC()
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        self.present(controller, animated: true, completion: nil)
    }
}
