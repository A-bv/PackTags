import UIKit
import InstagramGraph

enum ConnectedInsightsDestination {
    case analytics
    case smartG
    case setup
    case setupInfo
}

@MainActor
protocol ConnectedInsightsCoordinating: AnyObject {
    func open(_ destination: ConnectedInsightsDestination, from presenter: UIViewController)
}

struct UnavailableConnectedInsightsGateway: ConnectedInsightsGatewayProtocol {
    nonisolated init() {}
    func accessState() -> ConnectedInsightsAccessState { .needsSetup(.setupRequired) }
    func setup(facebookToken: String) async throws { throw ConnectedInsightsError.setupRequired }
    func reset() {}
    func searchHashtag(searchedHashtag: String) async throws -> [InstagramPost] { throw ConnectedInsightsError.setupRequired }
    func loadProfileForAnalytics(mediaLimit: Int?) async throws -> Profile { throw ConnectedInsightsError.setupRequired }
}
