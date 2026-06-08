import Foundation
import InstagramGraph

struct FacebookSetupValidationResult {
    let isCorrectSetup: Bool
    let instagramBusinessAccountId: String?
}

protocol FacebookSetupServicing {
    func validateSetup(
        facebookToken: String,
        completion: @escaping (FacebookSetupValidationResult) -> Void
    )
}

final class FacebookSetupService: FacebookSetupServicing {
    private let accountResolver: InstagramGraphAccountResolver

    init(accountResolver: InstagramGraphAccountResolver = InstagramGraphAccountResolver()) {
        self.accountResolver = accountResolver
    }

    func validateSetup(
        facebookToken: String,
        completion: @escaping (FacebookSetupValidationResult) -> Void
    ) {
        logSetup("Resolve Instagram business account from Facebook token")
        accountResolver.resolveAccount(facebookToken: facebookToken) { result in
            switch result {
            case .success(let account):
                self.logSetup("Resolved Instagram account id=\(account.instagramBusinessAccountId) username=\(account.instagramUsername ?? "<none>")")
                completion(FacebookSetupValidationResult(
                    isCorrectSetup: true,
                    instagramBusinessAccountId: account.instagramBusinessAccountId
                ))
            case .failure(let error):
                self.logSetup("Instagram account resolution failed: \(error.localizedDescription)")
                completion(FacebookSetupValidationResult(
                    isCorrectSetup: false,
                    instagramBusinessAccountId: nil
                ))
            }
        }
    }

    private func logSetup(_ message: String) {
        print("[ConnectedInsights][Setup] \(message)")
    }
}
