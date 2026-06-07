import Foundation
import FBSDKLoginKit

struct FacebookSetupValidationResult {
    let isCorrectSetup: Bool
    let instagramBusinessAccountId: String?
}

protocol FacebookSetupServicing {
    func validateSetup(completion: @escaping (FacebookSetupValidationResult) -> Void)
}

final class FacebookSetupService: FacebookSetupServicing {
    func validateSetup(completion: @escaping (FacebookSetupValidationResult) -> Void) {
        verifyCorrectFacebookPagesSetup { isCorrectSetup in
            self.verifyInstagramBusinessAccountId { instagramBusinessAccountId in
                completion(FacebookSetupValidationResult(
                    isCorrectSetup: isCorrectSetup && instagramBusinessAccountId != nil,
                    instagramBusinessAccountId: instagramBusinessAccountId
                ))
            }
        }
    }

    private func verifyCorrectFacebookPagesSetup(completion: @escaping (Bool) -> Void) {
        let request = GraphRequest(
            graphPath: "/me/accounts",
            httpMethod: .get)

        logSetup("Request /me/accounts")

        request.start { connection, result, error in
            self.handleCorrectFacebookPagesSetupResponse(
                connection,
                result,
                error,
                completion: completion)
        }
    }

    private func verifyInstagramBusinessAccountId(completion: @escaping (String?) -> Void) {
        let request = GraphRequest(
            graphPath: "/me/accounts",
            parameters: ["fields": "instagram_business_account"],
            httpMethod: .get)

        logSetup("Request /me/accounts fields=instagram_business_account")

        request.start { connection, result, error in
            self.handleInstagramBusinessAccountResponse(
                connection,
                result,
                error,
                completion: completion)
        }
    }
}

private extension FacebookSetupService {
    func handleCorrectFacebookPagesSetupResponse(
        _ connection: GraphRequestConnection?,
        _ result: Any?,
        _ error: (any Error)?,
        completion: @escaping (Bool) -> Void
    ) {
        let key = "data.name"
        if let error {
            logSetup("Facebook page request failed: \(error.localizedDescription)")
            completion(false)
            return
        }

        guard let response = result as? NSDictionary else {
            logUnexpectedResult(result, context: "Facebook page request")
            completion(false)
            return
        }

        guard let pages = response.value(forKeyPath: key) as? [String] else {
            logSetup("Facebook page request returned no page names. Response: \(responsePreview(response))")
            completion(false)
            return
        }

        logSetup("Facebook page request returned \(pages.count) page(s).")
        completion(!pages.isEmpty)
    }

    func handleInstagramBusinessAccountResponse(
        _ connection: GraphRequestConnection?,
        _ result: Any?,
        _ error: Error?,
        completion: @escaping (String?) -> Void
    ) {
        let key = "data.instagram_business_account.id"
        if let error {
            logSetup("Instagram business account request failed: \(error.localizedDescription)")
            completion(nil)
            return
        }

        guard let response = result as? NSDictionary else {
            logUnexpectedResult(result, context: "Instagram business account request")
            completion(nil)
            return
        }

        if let instagramBusinessAccountIds = response.value(forKeyPath: key) as? [String] {
            logSetup("Instagram business account request returned \(instagramBusinessAccountIds.count) id(s).")
            completion(instagramBusinessAccountIds.first)
        } else {
            logSetup("No business account linked or wrong pages selected. Response: \(responsePreview(response))")
            completion(nil)
        }
    }

    func logUnexpectedResult(_ result: Any?, context: String) {
        logSetup("\(context) returned an unexpected result: \(String(describing: result))")
    }

    func responsePreview(_ response: NSDictionary) -> String {
        if JSONSerialization.isValidJSONObject(response),
           let data = try? JSONSerialization.data(withJSONObject: response, options: [.sortedKeys]),
           let body = String(data: data, encoding: .utf8) {
            return String(body.prefix(1_500))
        }

        return String(String(describing: response).prefix(1_500))
    }

    func logSetup(_ message: String) {
        print("[ConnectedInsights][Setup] \(message)")
    }
}
