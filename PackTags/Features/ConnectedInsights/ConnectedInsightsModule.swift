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
    private let appSettings: any AppSettingsProtocol

    init(appSettings: any AppSettingsProtocol) {
        self.appSettings = appSettings
    }

    func makeViewController(for destination: ConnectedInsightsDestination) -> UIViewController {
        guard appSettings.isCorrectSetup else {
            return FBLoginVC(viewModel: FBLoginViewModel())
        }

        switch destination {
        case .analytics:
            return UIHostingController(rootView: AnalyticsNew())
        case .smartG:
            return UIHostingController(rootView: SmartGViewContainer())
        }
    }
}
