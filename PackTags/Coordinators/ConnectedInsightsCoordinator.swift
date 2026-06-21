import UIKit
import SwiftUI
import InstagramGraph

@MainActor
final class ConnectedInsightsCoordinator: ConnectedInsightsProtocol {
    private let gateway: any ConnectedInsightsGatewayProtocol
    private let fbLogin: FBLoginCoordinator
    private lazy var smartTagsPersistence = PersistenceController(modelName: "SmartTags")

    init(settings: any AppSettingsProtocol) {
        let gateway = ConnectedInsightsGateway(tokenProvider: FacebookAccessTokenProvider())
        self.gateway = gateway
        self.fbLogin = FBLoginCoordinator(gateway: gateway, settings: settings)
    }

    func open(_ destination: ConnectedInsightsDestination, from presenter: UIViewController) {
        switch destination {
        case .analytics, .smartG:
            openFeature(destination, from: presenter)
        case .setup:
            fbLogin.start(from: presenter, dismissWhenAlreadyConnected: false)
        case .setupInfo:
            fbLogin.showInfo(from: presenter)
        }
    }

    /// Features gate on token validity: `.ready` shows the feature; `.needsSetup` runs
    /// the login flow (owned by `FBLoginCoordinator`), then the feature.
    private func openFeature(_ destination: ConnectedInsightsDestination, from presenter: UIViewController) {
        switch gateway.accessState() {
        case .ready:
            AppLogger.insights.info("Access ready; presenting \(String(describing: destination), privacy: .public).")
            presentFeature(destination, from: presenter)
        case .needsSetup(let error):
            AppLogger.insights.info("\(error.localizedDescription, privacy: .public) Presenting setup flow for \(String(describing: destination), privacy: .public).")
            fbLogin.start(from: presenter) { [weak self] in
                self?.presentFeature(destination, from: presenter)
            }
        }
    }

    private func presentFeature(_ destination: ConnectedInsightsDestination, from presenter: UIViewController) {
        switch destination {
        case .analytics:
            present(AnalyticsView(gateway: gateway), from: presenter)
        case .smartG:
            present(
                SmartGContainerView(gateway: gateway, context: smartTagsPersistence.viewContext),
                from: presenter)
        default:
            return
        }
    }

    private func present(_ view: some View, from presenter: UIViewController) {
        let host = UIHostingController(rootView: view)
        host.modalPresentationStyle = .overFullScreen
        host.modalTransitionStyle = .coverVertical
        presenter.present(host, animated: true)
    }
}
