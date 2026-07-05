import InstagramGraph

/// The previews/tests fake gateway: every Connected Insights call reports "needs setup".
struct UnavailableConnectedInsightsGateway: ConnectedInsightsGatewayProtocol {
    // Written out so it can be nonisolated: the MainActor-bound gateway protocol would
    // otherwise isolate the synthesized init, blocking nonisolated preview/test creation.
    // swiftlint:disable:next unneeded_synthesized_initializer
    nonisolated init() {}
    func accessState() -> ConnectedInsightsAccessState { .needsSetup(.setupRequired) }
    func setup(facebookToken: String) async throws { throw ConnectedInsightsError.setupRequired }
    func reset() {}
    func searchHashtag(searchedHashtag: String) async throws -> [InstagramPost] { throw ConnectedInsightsError.setupRequired }
    func loadProfileForAnalytics(mediaLimit: Int?) async throws -> Profile { throw ConnectedInsightsError.setupRequired }
}
