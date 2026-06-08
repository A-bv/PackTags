import UIKit
import SwiftUI

final class ConnectedInsightsCoordinator: ConnectedInsightsCoordinating {
    private let settings: any ConnectedInsightsSettingsProtocol
    private let gateway: any ConnectedInsightsGatewayProtocol

    init(
        settings: any ConnectedInsightsSettingsProtocol = UserDefaultsConnectedInsightsSettings(),
        configuration: ConnectedInsightsConfiguration = .production,
        gateway: (any ConnectedInsightsGatewayProtocol)? = nil
    ) {
        self.settings = settings
        if let gateway {
            self.gateway = gateway
        } else {
            let credentialsProvider = SettingsInstagramGraphCredentialsProvider(settings: settings)
            let endpointBuilder = InstagramGraphEndpointBuilder(apiGraphVersion: configuration.graphAPIVersion)
            let client = InstagramGraphClient(apiGraphVersion: configuration.graphAPIVersion)
            self.gateway = ConnectedInsightsGateway(
                settings: settings,
                hashtagProvider: InstagramHashtagRepository(
                    credentialsProvider: credentialsProvider,
                    endpointBuilder: endpointBuilder,
                    client: client
                ),
                profileProvider: InstagramProfileRepository(
                    credentialsProvider: credentialsProvider,
                    endpointBuilder: endpointBuilder,
                    client: client,
                    onDataFetched: { data in DocumentDirectory.saveJsonDataLocally(data: data) }
                )
            )
        }
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
            vc = UIHostingController(rootView: AnalyticsNew(profileProvider: gateway.profileProvider))
        case .smartG:
            vc = UIHostingController(rootView: SmartGViewContainer(hashtagProvider: gateway.hashtagProvider))
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
            let loginVC = FBLoginVC(settings: settings)
            loginVC.onSetupComplete = onComplete
            vc = loginVC
        case .setupInfo:
            vc = InfoSetupIGCreatorVC(settings: settings)
        default:
            return
        }
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .coverVertical
        presenter.present(vc, animated: true)
    }
}
