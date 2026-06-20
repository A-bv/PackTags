import UIKit

/// Chrome for a modally presented screen: a close button in the top-right corner.
/// Owns its button and action, so a host adds chrome with one call instead of
/// inheriting selector-based behavior from an extension.
@MainActor
final class ModalChrome {

    private enum Constants {
        static let paddingDivisor: CGFloat = 10
        static let buttonSize: CGFloat = 22
    }

    private enum Strings {
        static let close = "Close".localized()
    }

    private weak var host: UIViewController?

    init(host: UIViewController) {
        self.host = host
    }

    func addCloseButton() {
        guard let host else { return }

        let button = UIButton(primaryAction: UIAction { [weak host] _ in
            host?.dismiss(animated: true)
        })
        button.tintColor = .label
        button.accessibilityLabel = Strings.close
        if let image = UIImage(named: "close_round")?.withRenderingMode(.alwaysTemplate) {
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
}
