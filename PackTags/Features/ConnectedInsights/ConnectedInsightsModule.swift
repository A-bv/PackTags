import SwiftUI
import UIKit

enum ConnectedInsightsDestination {
    case analytics
    case smartG
}

protocol ConnectedInsightsRouting {
    func makeViewController(for destination: ConnectedInsightsDestination) -> UIViewController
}

final class ConnectedInsightsModule: ConnectedInsightsRouting {
    private let appSettings: any ConnectedInsightsSettingsProtocol
    private let instagramGraphService: any InstagramGraphServicing

    init(
        appSettings: any ConnectedInsightsSettingsProtocol,
        instagramGraphService: any InstagramGraphServicing
    ) {
        self.appSettings = appSettings
        self.instagramGraphService = instagramGraphService
    }

    func makeViewController(for destination: ConnectedInsightsDestination) -> UIViewController {
        guard appSettings.isCorrectSetup else {
            return FBLoginVC(settings: appSettings)
        }

        switch destination {
        case .analytics:
            return UIHostingController(
                rootView: AnalyticsNew(instagramGraphService: instagramGraphService))
        case .smartG:
            return UIHostingController(
                rootView: SmartGViewContainer(instagramGraphService: instagramGraphService))
        }
    }
}
