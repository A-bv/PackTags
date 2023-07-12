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
        static let setupTitle = "Setup".localized()
        static let editYourSetup = "Edit Your Setup".localized()
        static let troubleShootingAlertMessage = "troubleShootingAlertMessage".localized()
    }
    
    private let viewModel: FBLoginViewModel
    
    private let loginButton: FBLoginButton = {
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
            showTroubleShootingAlert()
        }
    }
}

// MARK: - UI
extension FBLoginVC: LoginButtonDelegate {
    private func setupFBLoginVC () {
        self.view.applyBlur()
        self.placeTopRightButton(arrowButton: false)
        self.placeHelpButtonForFBLoginSetup()
        
        let loginButton = loginButton
        loginButton.delegate = self
        loginButton.center = view.center
        view.addSubview(loginButton)
    }

    private func placeHelpButtonForFBLoginSetup() {
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

// MARK: - Delegates
extension FBLoginVC {
    // triggered when just after login
    func loginButton(
        _ loginButton: FBLoginButton,
        didCompleteWith result: LoginManagerLoginResult?,
        error: Error?
    ) {
        if let error {
            print("Fb login error:", error)
        }
        viewModel.savePushedFBLoginButtonOnce()
        apiCallGetIgBusinessId()
    }

    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {}
}

// MARK: - Actions
extension FBLoginVC {
    private func apiCallGetIgBusinessId() {
        let token = viewModel.getToken()
        if token.isValid {
            viewModel.apiCallGetIgBusinessId(Completion: { [weak self] isCorrectSetup in
                if isCorrectSetup {
                    self?.showSuccessfulSetupAlert()
                } else {
                    self?.showTroubleShootingAlert()
                }
            })
        } else {
            showTroubleShootingAlert()
        }
    }
    
    private func showSuccessfulSetupAlert() {
        Alerts.simpleShortAlert(
            title: Strings.connectedAlertTitle,
            message: Strings.accessAnalyticsConfirm,
            vc: self,
            okDismissVc: true)
    }
    
    private func showTroubleShootingAlert() {
        UserDefaults.standard.set(false, forKey: "isCorrectSetup")
        Alerts.simpleShortAlert(
            title: Strings.editYourSetup,
            message: Strings.troubleShootingAlertMessage,
            vc: self,
            okDismissVc: false)
    }
}
