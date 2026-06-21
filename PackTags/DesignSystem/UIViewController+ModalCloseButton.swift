import UIKit

extension UIViewController {
    private enum Constants {
        static let paddingDivisor: CGFloat = 10
        static let buttonSize: CGFloat = 22
    }

    /// Adds a circular close button in the top-right corner that dismisses the screen.
    /// For modally presented screens that supply their own chrome.
    func addModalCloseButton() {
        let button = UIButton(primaryAction: UIAction { [weak self] _ in
            self?.dismiss(animated: true)
        })
        button.tintColor = .label
        button.accessibilityLabel = "Close".localized()
        if let image = UIImage(named: "close_round")?.withRenderingMode(.alwaysTemplate) {
            button.setBackgroundImage(image, for: .normal)
        }

        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        let padding = view.frame.width / Constants.paddingDivisor
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: padding),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            button.heightAnchor.constraint(equalToConstant: Constants.buttonSize),
            button.widthAnchor.constraint(equalTo: button.heightAnchor),
        ])
    }
}
