import UIKit
import SwiftUI
import InstagramGraph

/// Presents the Facebook login / Instagram setup flow. A child of
/// `ConnectedInsightsCoordinator`, it shares the same gateway so a successful login
/// flips the very access state the features read. Reached from the features (on
/// needs-setup) and from Settings, both through `ConnectedInsightsProtocol`.
@MainActor
final class FacebookLoginCoordinator {
    private let gateway: any ConnectedInsightsGatewayProtocol
    private let settings: any AppSettingsProtocol

    init(gateway: any ConnectedInsightsGatewayProtocol, settings: any AppSettingsProtocol) {
        self.gateway = gateway
        self.settings = settings
    }

    /// Presents the login screen; `onConnected` fires once Graph setup succeeds.
    func start(
        from presenter: UIViewController,
        dismissWhenAlreadyConnected: Bool = true,
        onConnected: (() -> Void)? = nil
    ) {
        let viewModel = FacebookLoginViewModel(gateway: gateway, settings: settings)
        let view = FacebookLoginView(
            viewModel: viewModel,
            appSettings: settings,
            dismissWhenAlreadyConnected: dismissWhenAlreadyConnected,
            onConnected: { [weak presenter] in
                presenter?.dismiss(animated: true) { onConnected?() }
            },
            onClose: { [weak presenter] in
                presenter?.dismiss(animated: true)
            })
        present(view, from: presenter)
    }

    /// Presents the standalone Business/Creator requirements explainer.
    func showInfo(from presenter: UIViewController) {
        let view = SetupInfoView(appSettings: settings, onClose: { [weak presenter] in
            presenter?.dismiss(animated: true)
        })
        present(view, from: presenter)
    }

    private func present(_ view: some View, from presenter: UIViewController) {
        let host = UIHostingController(rootView: view)
        host.view.backgroundColor = .clear   // the SwiftUI view supplies a blur over what's behind
        host.modalPresentationStyle = .overFullScreen
        host.modalTransitionStyle = .coverVertical
        presenter.present(host, animated: true)
    }
}
