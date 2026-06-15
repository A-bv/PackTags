import UIKit
import SafariServices

/// Chrome for modally presented screens: a close button in the top-right
/// corner and an optional help link in the top-left. Owns its buttons and
/// their actions, so hosts add chrome with one call instead of inheriting
/// selector-based behavior from an extension.
@MainActor
final class ModalChrome {

    private enum Constants {
        static let paddingDivisor: CGFloat = 10
        static let buttonSize: CGFloat = 22
    }

    private enum Strings {
        static let setupTitle = "Setup".localized()
        static let setupHelpQuestion = "Help?".localized()
        static let close = "Close".localized()
        static let facebookSetupHelpUrl = "https://www.facebook.com/business/help/502981923235522"
    }

    private weak var host: UIViewController?

    init(host: UIViewController) {
        self.host = host
    }

    func addCloseButton(arrowStyle: Bool = false) {
        guard let host else { return }

        let button = UIButton(primaryAction: UIAction { [weak host] _ in
            host?.dismiss(animated: true)
        })
        button.tintColor = .label
        button.accessibilityLabel = Strings.close
        let imageName = arrowStyle ? "ciDown" : "close_round"
        if let image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate) {
            button.setBackgroundImage(image, for: .normal)
        }

        host.view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        let padding = host.view.frame.width / Constants.paddingDivisor
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: host.view.safeAreaLayoutGuide.topAnchor, constant: padding),
            button.trailingAnchor.constraint(equalTo: host.view.trailingAnchor, constant: -padding),
            button.heightAnchor.constraint(equalToConstant: Constants.buttonSize),
            button.widthAnchor.constraint(equalTo: button.heightAnchor),
        ])
    }

    /// The "Setup" link on the Facebook login screen.
    func addFacebookSetupHelpButton(action: @escaping () -> Void) {
        addHelpButton(title: Strings.setupTitle, action: action)
    }

    /// The "Help?" link opening Facebook's business-setup documentation.
    func addBusinessSetupHelpLink() {
        addHelpButton(title: Strings.setupHelpQuestion) { [weak self] in
            self?.openBusinessSetupHelp()
        }
    }

    private func addHelpButton(title: String, action: @escaping () -> Void) {
        guard let host else { return }

        let button = UIButton(type: .system, primaryAction: UIAction { _ in action() })
        button.setTitle(title, for: .normal)
        button.setTitleColor(.customPurple, for: .normal)

        host.view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        let padding = host.view.frame.width / Constants.paddingDivisor
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: host.view.safeAreaLayoutGuide.topAnchor, constant: padding),
            button.leadingAnchor.constraint(equalTo: host.view.leadingAnchor, constant: padding),
            button.heightAnchor.constraint(equalToConstant: Constants.buttonSize),
        ])
    }

    private func openBusinessSetupHelp() {
        guard let host, let url = URL(string: Strings.facebookSetupHelpUrl) else { return }
        let safari = SFSafariViewController(url: url)
        safari.modalPresentationStyle = .overFullScreen
        safari.modalTransitionStyle = .crossDissolve
        host.present(safari, animated: true)
    }
}
