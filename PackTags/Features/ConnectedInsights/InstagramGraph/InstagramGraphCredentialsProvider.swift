import Foundation

protocol InstagramGraphCredentialsProviding {
    var facebookToken: String? { get }
    var instagramBusinessAccountId: String? { get }
}

struct InstagramGraphCredentials {
    let facebookToken: String
    let instagramBusinessAccountId: String
}

final class SettingsInstagramGraphCredentialsProvider: InstagramGraphCredentialsProviding {
    private let settings: any ConnectedInsightsSettingsProtocol

    init(settings: any ConnectedInsightsSettingsProtocol = UserDefaultsConnectedInsightsSettings()) {
        self.settings = settings
    }

    var facebookToken: String? {
        settings.facebookToken
    }

    var instagramBusinessAccountId: String? {
        settings.instagramBusinessAccountId
    }
}

extension InstagramGraphCredentialsProviding {
    func validCredentials() -> Result<InstagramGraphCredentials, Error> {
        let token = facebookToken ?? ""
        let instagramBusinessAccountId = instagramBusinessAccountId ?? ""

        guard !token.isEmpty, !instagramBusinessAccountId.isEmpty else {
            return .failure(InstagramGraphServiceError.missingCredentials(
                hasToken: !token.isEmpty,
                hasInstagramBusinessId: !instagramBusinessAccountId.isEmpty
            ))
        }

        return .success(InstagramGraphCredentials(
            facebookToken: token,
            instagramBusinessAccountId: instagramBusinessAccountId
        ))
    }
}
