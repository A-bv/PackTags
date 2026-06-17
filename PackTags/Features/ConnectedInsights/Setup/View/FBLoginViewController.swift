//User needs to have a Facebook User account that can perform Tasks on the Page connected to the targeted Instagram Business or Creator Account

import UIKit
import FBSDKLoginKit
import InstagramGraph

// MARK: - Class
final class FBLoginViewController: UIViewController {

    private enum Strings {
        static let connectedAlertTitle = "Connected!".localized()
        static let accessAnalyticsConfirm = "You can now access analytics and generate hashtags.".localized()
        static let editYourSetup = "Edit Your Setup".localized()
        static let troubleShootingAlertMessage = "troubleShootingAlertMessage".localized()
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
        // Business permissions (instagram_manage_insights, business_management)
        // require a classic AccessToken; Limited Login only yields an OIDC
        // AuthenticationToken, which the Instagram Graph calls can't use.
        button.loginTracking = .enabled
        return button
    }()

    private let resetLoginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.resetLogin, for: .normal)
        button.setTitleColor(.secondaryLabel, for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .footnote)
        return button
    }()

    private let setupSpinner = UIActivityIndicatorView(style: .large)

    private lazy var chrome = ModalChrome(host: self)

    init(viewModel: FBLoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    convenience init(gateway: any ConnectedInsightsGatewayProtocol, settings: any AppSettingsProtocol) {
        self.init(viewModel: FBLoginViewModel(gateway: gateway, settings: settings))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        logLogin("FBLoginViewController viewDidLoad.")
        setupFBLoginViewController()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        logLogin("FBLoginViewController viewDidAppear.")
        if showApiGraphSetupVCIfNeeded() {
            return
        }
        if validateExistingFacebookSessionIfNeeded() {
            return
        }
    }
}

extension FBLoginViewController {
    private func showApiGraphSetupVCIfNeeded() -> Bool {
        if !viewModel.hasSeenSetupInfo {
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
extension FBLoginViewController: @preconcurrency LoginButtonDelegate {
    private func setupFBLoginViewController () {
        self.view.applyBlur()
        chrome.addCloseButton()
        chrome.addFacebookSetupHelpButton { [weak self] in
            self?.showSetupScreen()
        }
        self.placeFBLogingButton()
        self.placeResetLoginButton()
        self.placeSetupSpinner()
    }

    private func placeSetupSpinner() {
        setupSpinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(setupSpinner)
        NSLayoutConstraint.activate([
            setupSpinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            setupSpinner.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80),
        ])
    }

    private func setValidationInProgress(_ inProgress: Bool) {
        inProgress ? setupSpinner.startAnimating() : setupSpinner.stopAnimating()
        loginButton.isEnabled = !inProgress
        resetLoginButton.isEnabled = !inProgress
    }

    private func placeFBLogingButton() {
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
            resetLoginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

}

// MARK: - Delegates
extension FBLoginViewController {
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
extension FBLoginViewController {
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
            viewModel.markLoginButtonPressed()
        }

        logLogin("Valid Facebook access token from \(source); starting Graph setup validation.")
        setValidationInProgress(true)
        Task {
            do {
                try await viewModel.setup(with: token)
                setValidationInProgress(false)
                showSuccessfulSetupAlert()
            } catch {
                setValidationInProgress(false)
                showTroubleshootingAlert(detail: error.localizedDescription)
            }
        }
    }

    private func showSuccessfulSetupAlert() {
        let ok = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.dismiss(animated: true) {
                self?.onSetupComplete?()
            }
        }
        Alerts.show(
            from: self,
            title: Strings.connectedAlertTitle,
            message: Strings.accessAnalyticsConfirm,
            actions: [ok])
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

        Alerts.show(
            from: self,
            title: Strings.editYourSetup,
            message: message,
            actions: [UIAlertAction(title: "Ok", style: .cancel)])
    }

    private func showSetupScreen() {
        onShowSetupInfo?()
    }

    @objc private func didTapResetLoginButton(_ sender: Any) {
        let cancel = UIAlertAction(title: Strings.cancel, style: .cancel)
        let reset = UIAlertAction(title: Strings.reset, style: .destructive) { [weak self] _ in
            self?.resetFacebookLogin()
        }
        Alerts.show(
            from: self,
            title: Strings.resetLoginTitle,
            message: Strings.resetLoginMessage,
            actions: [cancel, reset])
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
