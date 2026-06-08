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

protocol HashtagSearchProviding {
    func searchHashtag(
        searchedHashtag: String,
        completion: @escaping (Result<[DataMedia], Error>) -> Void
    )
}

protocol ProfileDataProviding {
    func loadProfileForAnalytics(completion: @escaping (Result<Profile, Error>) -> Void)
}

protocol ConnectedInsightsGatewayProtocol {
    var hashtagProvider: any HashtagSearchProviding { get }
    var profileProvider: any ProfileDataProviding { get }

    func accessState() -> ConnectedInsightsAccessState
}

final class ConnectedInsightsGateway: ConnectedInsightsGatewayProtocol {
    private let settings: any ConnectedInsightsSettingsProtocol
    let hashtagProvider: any HashtagSearchProviding
    let profileProvider: any ProfileDataProviding

    convenience init(
        settings: any ConnectedInsightsSettingsProtocol = UserDefaultsConnectedInsightsSettings(),
        configuration: ConnectedInsightsConfiguration = .production
    ) {
        let credentialsProvider = SettingsInstagramGraphCredentialsProvider(settings: settings)
        let endpointBuilder = InstagramGraphEndpointBuilder(apiGraphVersion: configuration.graphAPIVersion)
        let client = InstagramGraphClient(apiGraphVersion: configuration.graphAPIVersion)
        self.init(
            settings: settings,
            hashtagProvider: InstagramHashtagRepository(
                credentialsProvider: credentialsProvider,
                endpointBuilder: endpointBuilder,
                client: client
            ),
            profileProvider: InstagramProfileRepository(
                credentialsProvider: credentialsProvider,
                endpointBuilder: endpointBuilder,
                client: client
            )
        )
    }

    init(
        settings: any ConnectedInsightsSettingsProtocol,
        hashtagProvider: any HashtagSearchProviding,
        profileProvider: any ProfileDataProviding
    ) {
        self.settings = settings
        self.hashtagProvider = hashtagProvider
        self.profileProvider = profileProvider
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

struct UnavailableHashtagProvider: HashtagSearchProviding {
    func searchHashtag(
        searchedHashtag: String,
        completion: @escaping (Result<[DataMedia], Error>) -> Void
    ) {
        completion(.failure(ConnectedInsightsError.dataProviderUnavailable))
    }
}

struct UnavailableProfileProvider: ProfileDataProviding {
    func loadProfileForAnalytics(completion: @escaping (Result<Profile, Error>) -> Void) {
        completion(.failure(ConnectedInsightsError.dataProviderUnavailable))
    }
}
