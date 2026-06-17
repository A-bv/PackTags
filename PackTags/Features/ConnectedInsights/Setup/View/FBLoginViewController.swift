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
        static let ok = "Ok"
    }

    var onSetupComplete: (() -> Void)?
    var onShowSetupInfo: (() -> Void)?

    private let viewModel: FBLoginViewModel
    private var hasValidatedOnAppear = false
    private var isValidating = false

    private let loginButton: FBLoginButton = {
        let button = FBLoginButton()
        // Business permissions require a classic AccessToken; Limited Login only yields
        // an OIDC AuthenticationToken the Instagram Graph calls can't use.
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
        loginButton.permissions = viewModel.loginPermissions
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handleAppear()
    }

    private func handleAppear() {
        switch viewModel.onAppear() {
        case .showSetupInfo:
            onShowSetupInfo?()
        case .validateExistingSession:
            guard !hasValidatedOnAppear else { return }
            hasValidatedOnAppear = true
            runValidation(markLoginAttempt: false)
        case .idle:
            break
        }
    }

    private func runValidation(markLoginAttempt: Bool) {
        guard !isValidating else { return }
        isValidating = true
        setValidationInProgress(true)
        Task {
            let result = await viewModel.validateSetup(markLoginAttempt: markLoginAttempt)
            isValidating = false
            setValidationInProgress(false)
            handle(result)
        }
    }

    private func handle(_ result: FBLoginViewModel.SetupResult) {
        switch result {
        case .connected:
            presentConnectedAlert()
        case .sessionExpired:
            // The view model already cleared the stale session; the plain message tells
            // the user to log in again, and the login button is ready.
            presentSetupHelpAlert(detail: nil)
        case .failed(let message):
            presentSetupHelpAlert(detail: message)
        }
    }
}

// MARK: - UI
extension FBLoginViewController {
    private func setupUI() {
        view.applyBlur()
        chrome.addCloseButton()
        chrome.addFacebookSetupHelpButton { [weak self] in
            self?.onShowSetupInfo?()
        }
        placeLoginButton()
        placeResetLoginButton()
        placeSetupSpinner()
    }

    private func placeLoginButton() {
        loginButton.delegate = self
        loginButton.center = view.center
        view.addSubview(loginButton)
    }

    private func placeResetLoginButton() {
        resetLoginButton.addTarget(self, action: #selector(didTapResetLoginButton), for: .touchUpInside)
        resetLoginButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(resetLoginButton)
        NSLayoutConstraint.activate([
            resetLoginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resetLoginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
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
}

// MARK: - LoginButtonDelegate
extension FBLoginViewController: @preconcurrency LoginButtonDelegate {
    func loginButton(
        _ loginButton: FBLoginButton,
        didCompleteWith result: LoginManagerLoginResult?,
        error: Error?
    ) {
        if let error {
            presentSetupHelpAlert(detail: "Facebook Login failed: \(error.localizedDescription)")
            return
        }
        guard result?.isCancelled != true else { return }
        runValidation(markLoginAttempt: true)
    }

    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {}
}

// MARK: - Alerts & actions
extension FBLoginViewController {
    private func presentConnectedAlert() {
        let ok = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.dismiss(animated: true) { self?.onSetupComplete?() }
        }
        Alerts.show(
            from: self,
            title: Strings.connectedAlertTitle,
            message: Strings.accessAnalyticsConfirm,
            actions: [ok])
    }

    private func presentSetupHelpAlert(detail: String?) {
        let message = [Strings.troubleShootingAlertMessage, detail]
            .compactMap { $0 }
            .joined(separator: "\n\n")
        Alerts.show(
            from: self,
            title: Strings.editYourSetup,
            message: message,
            actions: [UIAlertAction(title: Strings.ok, style: .cancel)])
    }

    @objc private func didTapResetLoginButton() {
        let cancel = UIAlertAction(title: Strings.cancel, style: .cancel)
        let reset = UIAlertAction(title: Strings.reset, style: .destructive) { [weak self] _ in
            self?.viewModel.resetFacebookSession()
            self?.hasValidatedOnAppear = false
        }
        Alerts.show(
            from: self,
            title: Strings.resetLoginTitle,
            message: Strings.resetLoginMessage,
            actions: [cancel, reset])
    }
}
