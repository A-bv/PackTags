import UIKit
import SwiftUI
import InstagramGraph

@MainActor
final class ConnectedInsightsCoordinator: ConnectedInsightsCoordinating {
    private let gateway: any ConnectedInsightsGatewayProtocol

    init(gateway: (any ConnectedInsightsGatewayProtocol)? = nil) {
        self.gateway = gateway ?? ConnectedInsightsGateway()
    }

    func open(_ destination: ConnectedInsightsDestination, from presenter: UIViewController) {
        switch destination {
        case .analytics, .smartG:
            openFeature(destination, from: presenter)
        case .setup, .setupInfo:
            presentSetupScreen(destination, from: presenter, onComplete: nil)
        }
    }

    private func openFeature(_ destination: ConnectedInsightsDestination, from presenter: UIViewController) {
        switch gateway.accessState() {
        case .ready:
            AppLogger.insights.info("Access ready; presenting \(String(describing: destination), privacy: .public).")
            presentFeature(destination, from: presenter)
        case .needsSetup(let error):
            AppLogger.insights.info("\(error.localizedDescription, privacy: .public) Presenting setup flow for \(String(describing: destination), privacy: .public).")
            presentSetupScreen(.setup, from: presenter) { [weak self] in
                self?.presentFeature(destination, from: presenter)
            }
        }
    }

    private func presentFeature(_ destination: ConnectedInsightsDestination, from presenter: UIViewController) {
        let vc: UIViewController
        switch destination {
        case .analytics:
            vc = UIHostingController(rootView: AnalyticsNew(gateway: gateway))
        case .smartG:
            vc = UIHostingController(rootView: SmartGViewContainer(gateway: gateway))
        default:
            return
        }
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .coverVertical
        presenter.present(vc, animated: true)
    }

    private func presentSetupScreen(
        _ destination: ConnectedInsightsDestination,
        from presenter: UIViewController,
        onComplete: (() -> Void)?
    ) {
        let vc: UIViewController
        switch destination {
        case .setup:
            let loginVC = FBLoginVC(gateway: gateway)
            loginVC.onSetupComplete = onComplete
            loginVC.onShowSetupInfo = { [weak self, weak loginVC] in
                guard let self, let loginVC else { return }
                self.presentSetupScreen(.setupInfo, from: loginVC, onComplete: nil)
            }
            vc = loginVC
        case .setupInfo:
            let infoVC = InfoSetupIGCreatorVC()
            infoVC.modalPresentationStyle = .overFullScreen
            infoVC.modalTransitionStyle = .crossDissolve
            presenter.present(infoVC, animated: true)
            return
        default:
            return
        }
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .coverVertical
        presenter.present(vc, animated: true)
    }
}
