import UIKit
import SwiftUI

final class ConnectedInsightsCoordinator: ConnectedInsightsCoordinating {
    private let settings: any ConnectedInsightsSettingsProtocol
    private let instagramGraphService: any InstagramGraphServicing

    init(
        settings: any ConnectedInsightsSettingsProtocol = UserDefaultsConnectedInsightsSettings(),
        configuration: ConnectedInsightsConfiguration = .production,
        instagramGraphService: (any InstagramGraphServicing)? = nil
    ) {
        self.settings = settings
        self.instagramGraphService = instagramGraphService ?? InstagramGraphService(
            settings: settings,
            apiGraphVersion: configuration.graphAPIVersion
        )
    }

    func open(_ destination: ConnectedInsightsDestination, from presenter: UIViewController) {
        switch destination {
        case .analytics, .smartG:
            openFeature(destination, from: presenter)
        case .setup, .setupInfo:
            presentSetupScreen(destination, from: presenter, onComplete: nil)
        }
    }

    private var isSessionReady: Bool {
        settings.isCorrectSetup &&
        settings.facebookToken != nil &&
        settings.instagramBusinessAccountId != nil
    }

    private func openFeature(_ destination: ConnectedInsightsDestination, from presenter: UIViewController) {
        if isSessionReady {
            print("[ConnectedInsights][Coordinator] Session ready; presenting \(destination).")
            presentFeature(destination, from: presenter)
        } else {
            print("[ConnectedInsights][Coordinator] Setup required for \(destination); presenting setup flow.")
            presentSetupScreen(.setup, from: presenter) { [weak self] in
                self?.presentFeature(destination, from: presenter)
            }
        }
    }

    private func presentFeature(_ destination: ConnectedInsightsDestination, from presenter: UIViewController) {
        let vc: UIViewController
        switch destination {
        case .analytics:
            vc = UIHostingController(rootView: AnalyticsNew(instagramGraphService: instagramGraphService))
        case .smartG:
            vc = UIHostingController(rootView: SmartGViewContainer(instagramGraphService: instagramGraphService))
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
