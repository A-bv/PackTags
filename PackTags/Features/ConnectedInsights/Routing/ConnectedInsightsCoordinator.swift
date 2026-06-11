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
            print("[ConnectedInsights][Coordinator] Access ready; presenting \(destination).")
            presentFeature(destination, from: presenter)
        case .needsSetup(let error):
            print("[ConnectedInsights][Coordinator] \(error.localizedDescription) Presenting setup flow for \(destination).")
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
            vc = loginVC
        case .setupInfo:
            vc = InfoSetupIGCreatorVC()
        default:
            return
        }
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .coverVertical
        presenter.present(vc, animated: true)
    }
}
