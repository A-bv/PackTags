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
import InstagramGraph

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

    convenience init(gateway: any ConnectedInsightsGatewayProtocol) {
        self.init(viewModel: FBLoginViewModel(gateway: gateway))
    }

    private enum Strings {
        static let connectedAlertTitle = "Connected!".localized()
        static let accessAnalyticsConfirm = "You can now access analytics and generate hashtags.".localized()
        static let editYourSetup = "Edit Your Setup".localized()
        static let troubleShootingAlertMessage = "troubleShootingAlertMessage".localized()
        static let setupValidationFailed = "Facebook setup validation failed.".localized()
        static let resetLogin = "Reset Facebook Login".localized()
        static let resetLoginTitle = "Reset Facebook Login?".localized()
        static let resetLoginMessage = "This will clear the current Facebook session and Instagram setup for this app.".localized()
        static let reset = "Reset".localized()
        static let cancel = "Cancel".localized()
    }

    private enum Permissions {
        static let list = [
            "instagram_basic",
            "pages_show_list",
            "instagram_manage_insights",
            "business_management"
        ]
    }

    var onSetupComplete: (() -> Void)?
    var onShowSetupInfo: (() -> Void)?

    private let viewModel: FBLoginViewModel
    private var hasStartedSetupValidation = false

    private let loginButton: FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = Permissions.list
        return button
    }()

    private let resetLoginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.resetLogin, for: .normal)
        button.setTitleColor(customPurple, for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        logLogin("FBLoginVC viewDidLoad.")
        setupFBLoginVC()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        logLogin("FBLoginVC viewDidAppear.")
        if showApiGraphSetupVCIfNeeded() {
            return
        }
        if validateExistingFacebookSessionIfNeeded() {
            return
        }
    }
}

extension FBLoginVC {
    private func showApiGraphSetupVCIfNeeded() -> Bool {
        if !UserDefaults.standard.bool(forKey: "setupInfoShown") {
            logLogin("Showing setup info before login.")
            showSetupScreen()
            return true
        }
        return false
    }

    private func validateExistingFacebookSessionIfNeeded() -> Bool {
        guard !hasStartedSetupValidation else {
            return true
        }

        let token = viewModel.getToken()
        logLogin(token.diagnostic)
        guard token.isValid else {
            logLogin("No valid existing Facebook access token.")
            return false
        }

        logLogin("Valid existing Facebook access token found; validating setup.")
        hasStartedSetupValidation = true
        performConnectedInsightsSetup(source: "existing session")
        return true
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
        self.placeResetLoginButton()
    }

    private func placeFBLogingButton() {
        let loginButton = loginButton
        loginButton.delegate = self
        loginButton.center = view.center
        view.addSubview(loginButton)
    }

    private func placeResetLoginButton() {
        resetLoginButton.addTarget(
            self,
            action: #selector(didTapResetLoginButton(_:)),
            for: .touchUpInside)
        resetLoginButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(resetLoginButton)

        NSLayoutConstraint.activate([
            resetLoginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resetLoginButton.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 40)
        ])
    }

}

// MARK: - Delegates
extension FBLoginVC {
    func loginButton(
        _ loginButton: FBLoginButton,
        didCompleteWith result: LoginManagerLoginResult?,
        error: Error?
    ) {
        if let error {
            logLogin("Facebook Login failed: \(error.localizedDescription)")
            showTroubleshootingAlert(detail: "Facebook Login failed: \(error.localizedDescription)")
            return
        }

        if result?.isCancelled == true {
            logLogin("Facebook Login was cancelled.")
            return
        }

        if let result {
            logLogin("Granted permissions: \(Array(result.grantedPermissions).sorted())")
            logLogin("Declined permissions: \(Array(result.declinedPermissions).sorted())")
            logLogin("Login result token diagnostic: \(FBToken().diagnostic)")
        } else {
            logLogin("Facebook Login completed without a result object.")
        }

        performConnectedInsightsSetup(source: "Facebook Login callback", markLoginAttempt: true)
    }

    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {}
}

// MARK: - Actions
extension FBLoginVC {
    private func performConnectedInsightsSetup(
        source: String,
        markLoginAttempt: Bool = false
    ) {
        hasStartedSetupValidation = true
        let token = viewModel.getToken()
        logLogin("Token check from \(source): \(token.diagnostic), isValid=\(token.isValid)")
        guard token.isValid else {
            showTroubleshootingAlert(detail: "No valid Facebook access token from \(source). \(token.diagnostic)")
            return
        }

        if markLoginAttempt {
            viewModel.savePushedFBLoginButtonOnce()
        }

        logLogin("Valid Facebook access token from \(source); starting Graph setup validation.")
        viewModel.setupWithToken(token) { [weak self] result in
            switch result {
            case .success:
                self?.showSuccessfulSetupAlert()
            case .failure(let error):
                self?.showTroubleshootingAlert(detail: error.localizedDescription)
            }
        }
    }

    private func showSuccessfulSetupAlert() {
        let alert = UIAlertController(
            title: Strings.connectedAlertTitle,
            message: Strings.accessAnalyticsConfirm,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.dismiss(animated: true) {
                self?.onSetupComplete?()
            }
        })
        present(alert, animated: true)
    }

    private func showTroubleshootingAlert(detail: String? = nil) {
        if let detail {
            logLogin("Showing troubleshooting alert. Detail: \(detail)")
        } else {
            logLogin("Showing troubleshooting alert.")
        }

        let message = [
            Strings.troubleShootingAlertMessage,
            detail
        ]
            .compactMap { $0 }
            .joined(separator: "\n\n")

        let alert = UIAlertController(
            title: Strings.editYourSetup,
            message: message,
            preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Ok", style: .cancel))

        present(alert, animated: true)
    }

    private func showSetupScreen() {
        onShowSetupInfo?()
    }

    @objc private func showInfoSetupScreenFromHelpButton(_ sender: Any) {
        showSetupScreen()
    }

    @objc private func didTapResetLoginButton(_ sender: Any) {
        let alert = UIAlertController(
            title: Strings.resetLoginTitle,
            message: Strings.resetLoginMessage,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Strings.cancel, style: .cancel))
        alert.addAction(UIAlertAction(title: Strings.reset, style: .destructive) { [weak self] _ in
            self?.resetFacebookLogin()
        })
        present(alert, animated: true)
    }

    private func resetFacebookLogin() {
        hasStartedSetupValidation = false
        viewModel.resetFacebookSession()
        logLogin("AccessToken after reset: \(FBToken().diagnostic)")
    }

    private func logLogin(_ message: String) {
        AppLogger.login.info("\(message, privacy: .public)")
    }
}
