import Foundation

struct ConnectedInsightsSession {
    let facebookToken: String
    let instagramBusinessAccountId: String
}

enum ConnectedInsightsError: LocalizedError {
    case setupRequired
    case missingFacebookToken
    case missingInstagramBusinessAccountId
    case dataProviderUnavailable

    var errorDescription: String? {
        switch self {
        case .setupRequired:
            return "Connected Insights setup is required."
        case .missingFacebookToken:
            return "Facebook token is missing."
        case .missingInstagramBusinessAccountId:
            return "Instagram business account id is missing."
        case .dataProviderUnavailable:
            return "Connected Insights data provider is unavailable."
        }
    }
}

enum ConnectedInsightsAccessState {
    case ready(ConnectedInsightsSession)
    case needsSetup(ConnectedInsightsError)
}

protocol SmartGDataProviding {
    func searchHashtag(
        searchedHashtag: String,
        completion: @escaping (Result<[DataMedia], Error>) -> Void
    )
}

protocol AnalyticsDataProviding {
    func loadProfileForAnalytics(completion: @escaping (Result<Profile, Error>) -> Void)
}

protocol ConnectedInsightsGatewayProtocol {
    var smartGDataProvider: any SmartGDataProviding { get }
    var analyticsDataProvider: any AnalyticsDataProviding { get }

    func accessState() -> ConnectedInsightsAccessState
}

final class ConnectedInsightsGateway: ConnectedInsightsGatewayProtocol {
    private let settings: any ConnectedInsightsSettingsProtocol
    let smartGDataProvider: any SmartGDataProviding
    let analyticsDataProvider: any AnalyticsDataProviding

    convenience init(
        settings: any ConnectedInsightsSettingsProtocol = UserDefaultsConnectedInsightsSettings(),
        configuration: ConnectedInsightsConfiguration = .production
    ) {
        let credentialsProvider = SettingsInstagramGraphCredentialsProvider(settings: settings)
        let endpointBuilder = InstagramGraphEndpointBuilder(apiGraphVersion: configuration.graphAPIVersion)
        let client = InstagramGraphClient(apiGraphVersion: configuration.graphAPIVersion)
        self.init(
            settings: settings,
            smartGDataProvider: SmartGHashtagRepository(
                credentialsProvider: credentialsProvider,
                endpointBuilder: endpointBuilder,
                client: client
            ),
            analyticsDataProvider: AnalyticsProfileRepository(
                credentialsProvider: credentialsProvider,
                endpointBuilder: endpointBuilder,
                client: client
            )
        )
    }

    init(
        settings: any ConnectedInsightsSettingsProtocol,
        smartGDataProvider: any SmartGDataProviding,
        analyticsDataProvider: any AnalyticsDataProviding
    ) {
        self.settings = settings
        self.smartGDataProvider = smartGDataProvider
        self.analyticsDataProvider = analyticsDataProvider
    }

    func accessState() -> ConnectedInsightsAccessState {
        guard settings.isCorrectSetup else {
            return .needsSetup(.setupRequired)
        }

        guard let facebookToken = settings.facebookToken, !facebookToken.isEmpty else {
            return .needsSetup(.missingFacebookToken)
        }

        guard let instagramBusinessAccountId = settings.instagramBusinessAccountId,
              !instagramBusinessAccountId.isEmpty
        else {
            return .needsSetup(.missingInstagramBusinessAccountId)
        }

        return .ready(ConnectedInsightsSession(
            facebookToken: facebookToken,
            instagramBusinessAccountId: instagramBusinessAccountId
        ))
    }
}

struct UnavailableSmartGDataProvider: SmartGDataProviding {
    func searchHashtag(
        searchedHashtag: String,
        completion: @escaping (Result<[DataMedia], Error>) -> Void
    ) {
        completion(.failure(ConnectedInsightsError.dataProviderUnavailable))
    }
}

struct UnavailableAnalyticsDataProvider: AnalyticsDataProviding {
    func loadProfileForAnalytics(completion: @escaping (Result<Profile, Error>) -> Void) {
        completion(.failure(ConnectedInsightsError.dataProviderUnavailable))
    }
}
