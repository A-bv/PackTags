import Foundation

protocol InstagramGraphServicing: SmartGDataProviding, AnalyticsDataProviding {
    func searchHashtag(
        searchedHashtag: String,
        completion: @escaping (Result<[DataMedia], Error>) -> Void
    )

    func loadProfileForAnalytics(completion: @escaping (Result<Profile, Error>) -> Void)
}

final class InstagramGraphService: InstagramGraphServicing {
    private let smartGRepository: any SmartGHashtagRepositoryProtocol
    private let analyticsRepository: any AnalyticsProfileRepositoryProtocol
    private let credentialsProvider: any InstagramGraphCredentialsProviding
    private let endpointBuilder: InstagramGraphEndpointBuilder

    convenience init(
        settings: any ConnectedInsightsSettingsProtocol = UserDefaultsConnectedInsightsSettings(),
        apiGraphVersion: String = ConnectedInsightsConfiguration.production.graphAPIVersion
    ) {
        let credentialsProvider = SettingsInstagramGraphCredentialsProvider(settings: settings)
        let endpointBuilder = InstagramGraphEndpointBuilder(apiGraphVersion: apiGraphVersion)
        let client = InstagramGraphClient(apiGraphVersion: apiGraphVersion)
        self.init(
            credentialsProvider: credentialsProvider,
            endpointBuilder: endpointBuilder,
            smartGRepository: SmartGHashtagRepository(
                credentialsProvider: credentialsProvider,
                endpointBuilder: endpointBuilder,
                client: client
            ),
            analyticsRepository: AnalyticsProfileRepository(
                credentialsProvider: credentialsProvider,
                endpointBuilder: endpointBuilder,
                client: client
            )
        )
    }

    init(
        credentialsProvider: any InstagramGraphCredentialsProviding,
        endpointBuilder: InstagramGraphEndpointBuilder,
        smartGRepository: any SmartGHashtagRepositoryProtocol,
        analyticsRepository: any AnalyticsProfileRepositoryProtocol
    ) {
        self.credentialsProvider = credentialsProvider
        self.endpointBuilder = endpointBuilder
        self.smartGRepository = smartGRepository
        self.analyticsRepository = analyticsRepository
    }

    func searchHashtag(
        searchedHashtag: String,
        completion: @escaping (Result<[DataMedia], Error>) -> Void
    ) {
        smartGRepository.searchHashtag(searchedHashtag: searchedHashtag, completion: completion)
    }

    func loadProfileForAnalytics(completion: @escaping (Result<Profile, Error>) -> Void) {
        analyticsRepository.loadProfileForAnalytics(completion: completion)
    }

    func business_discovery_url(account: String) -> String? {
        guard case let .success(credentials) = credentialsProvider.validCredentials() else {
            return nil
        }
        return endpointBuilder.businessDiscoveryURL(account: account, credentials: credentials)
    }
}
