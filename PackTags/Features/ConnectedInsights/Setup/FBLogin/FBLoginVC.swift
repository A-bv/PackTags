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
    
    init(
        viewModel: FBLoginViewModel,
        settings: any ConnectedInsightsSettingsProtocol = UserDefaultsConnectedInsightsSettings()
    ) {
        self.viewModel = viewModel
        self.settings = settings
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    convenience init(settings: any ConnectedInsightsSettingsProtocol) {
        self.init(
            viewModel: FBLoginViewModel(settings: settings),
            settings: settings)
    }
    
    private enum Strings {
        static let connectedAlertTitle = "Connected!".localized()
        static let accessAnalyticsConfirm = "You can now access analytics and generate hashtags.".localized()
        static let editYourSetup = "Edit Your Setup".localized()
        static let troubleShootingAlertMessage = "troubleShootingAlertMessage".localized()
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
    private var settings: any ConnectedInsightsSettingsProtocol
    
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
        if !settings.setupInfoShown {
            showSetupScreen()
        }
    }
    
    private func showWrongSetupAlertIfNeeded() {
        if !settings.isCorrectSetup,
           settings.pressedFacebookLoginButton
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
        self.placeHelpButtonForFBLoginSetup(
            target: self,
            action: #selector(showInfoSetupScreenFromHelpButton(_:)))
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
        settings.isCorrectSetup = false
        Alerts.simpleShortAlert(
            title: Strings.editYourSetup,
            message: Strings.troubleShootingAlertMessage,
            presentingViewController: self,
            shouldDissmissPresentingVCWhenConfirmed: false)
    }
    
    private func showSetupScreen() {
        let controller = InfoSetupIGCreatorVC(settings: settings)
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        self.present(controller, animated: true, completion: nil)
    }

    @objc private func showInfoSetupScreenFromHelpButton(_ sender: Any) {
        showSetupScreen()
    }
}
