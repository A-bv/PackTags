import Testing
import Foundation
import CoreGraphics
@testable import PackTags
import InstagramGraph

// MARK: - Fixtures

/// Builds a Graph-API-shaped profile JSON; the package models are
/// Decodable-only, so tests construct them the way production does.
private func makeProfile(
    followers: Int? = nil,
    medias: [(likes: Int, comments: Int, reach: Int, impressions: Int, engagement: Int)]? = nil
) throws -> Profile {
    var profile: [String: Any] = ["id": "1", "username": "packtags"]
    if let followers { profile["followers_count"] = followers }
    if let medias {
        profile["media"] = ["data": medias.map { media in
            [
                "like_count": media.likes,
                "comments_count": media.comments,
                "caption": "#sun",
                "insights": ["data": [
                    ["values": [["value": media.reach]]],
                    ["values": [["value": media.impressions]]],
                    ["values": [["value": media.engagement]]],
                ]],
            ]
        }]
    }
    let data = try JSONSerialization.data(withJSONObject: profile)
    return try JSONDecoder().decode(Profile.self, from: data)
}

private func makePosts(captions: [String?]) throws -> [InstagramPost] {
    let posts = captions.map { caption -> [String: Any] in
        caption.map { ["caption": $0] } ?? [:]
    }
    let data = try JSONSerialization.data(withJSONObject: posts)
    return try JSONDecoder().decode([InstagramPost].self, from: data)
}

// MARK: - ProfileDataTransformer

@Suite struct ProfileDataTransformerTests {

    @Test func transform_profileWithoutMedia_isNil() throws {
        let profile = try makeProfile()

        #expect(DataTransformer.ProfileDataTransformer.transform(response: profile) == nil)
    }

    @Test func transform_sumsAndAveragesLikesAndComments() throws {
        let profile = try makeProfile(medias: [
            (likes: 10, comments: 2, reach: 100, impressions: 200, engagement: 12),
            (likes: 20, comments: 4, reach: 300, impressions: 400, engagement: 24),
        ])

        let model = try #require(DataTransformer.ProfileDataTransformer.transform(response: profile))

        #expect(model.username == "packtags")
        #expect(model.totalLikes == 30)
        #expect(model.totalComments == 6)
        #expect(model.averageLikes == 15)
        #expect(model.averageComments == 3)
    }

    @Test func transform_rawInsights_exposesEngagementValuesUntouched() throws {
        let profile = try makeProfile(medias: [
            (likes: 1, comments: 1, reach: 100, impressions: 200, engagement: 12),
            (likes: 1, comments: 1, reach: 300, impressions: 400, engagement: 24),
        ])

        let model = try #require(DataTransformer.ProfileDataTransformer.transform(
            response: profile, mode: 0, rawInsights: true))

        #expect(model.rates == [12, 24])
        #expect(model.averageRate == 18)
        #expect(model.maxRate == 24)
    }

    @Test func transform_computedRates_arePercentagesOfFollowers() throws {
        let profile = try makeProfile(followers: 200, medias: [
            (likes: 1, comments: 1, reach: 100, impressions: 200, engagement: 10),
            (likes: 1, comments: 1, reach: 300, impressions: 400, engagement: 30),
        ])

        let model = try #require(DataTransformer.ProfileDataTransformer.transform(
            response: profile, mode: 0, rawInsights: false))

        #expect(model.rates == [5, 15]) // engagement * 100 / followers
    }

    @Test func transform_zeroDenominators_produceZeroRatesInsteadOfNaN() throws {
        let profile = try makeProfile(followers: 0, medias: [
            (likes: 1, comments: 1, reach: 0, impressions: 0, engagement: 10),
        ])

        let model = try #require(DataTransformer.ProfileDataTransformer.transform(
            response: profile, mode: 1, rawInsights: false))

        #expect(model.rates == [0])
    }

    @Test func transform_outOfRangeMode_clampsToTheLastRate() throws {
        let profile = try makeProfile(medias: [
            (likes: 1, comments: 1, reach: 100, impressions: 200, engagement: 12),
        ])

        let model = try #require(DataTransformer.ProfileDataTransformer.transform(
            response: profile, mode: 99, rawInsights: true))

        #expect(model.rates == [200]) // clamped to the impressions slot, not a crash
    }
}

// MARK: - SmartGViewModel

@MainActor
@Suite struct SmartGViewModelTests {

    @Test func processSmartGModel_extractsHashtagsPerPost() throws {
        let sut = SmartGViewModel(gateway: UnavailableConnectedInsightsGateway())
        sut.dataMedias = try makePosts(captions: ["#sea #sun day", nil, "#sea"])

        sut.processSmartGModel()

        #expect(sut.computedData.count == 3)
        #expect(sut.computedData[0].hashtags == ["#sea", "#sun"])
        #expect(sut.computedData[1].hashtags.isEmpty)
    }

    @Test func processSmartGModel_ranksTopHashtagsByFrequency() throws {
        let sut = SmartGViewModel(gateway: UnavailableConnectedInsightsGateway())
        sut.dataMedias = try makePosts(captions: ["#sea #sun", "#sea #sky", "#sea #sun"])

        sut.processSmartGModel()

        #expect(sut.topHashtags.first == "#sea")
        #expect(sut.topHashtagsCount.first == 3)
        #expect(sut.topHashtags.count == 3)
    }
}

// MARK: - FBLoginViewModel

@MainActor
@Suite struct FBLoginViewModelTests {

    private final class FakeGateway: ConnectedInsightsGatewayProtocol {
        var setupTokens: [String] = []
        var resetCount = 0

        func accessState() -> ConnectedInsightsAccessState { .needsSetup(.setupRequired) }
        func setup(facebookToken: String) async throws { setupTokens.append(facebookToken) }
        func reset() { resetCount += 1 }
        func searchHashtag(searchedHashtag: String) async throws -> [InstagramPost] { [] }
        func loadProfileForAnalytics(mediaLimit: Int?) async throws -> Profile {
            throw ConnectedInsightsError.setupRequired
        }
    }

    private final class FakeSession: FacebookSessionServicing {
        var resetCount = 0
        func currentToken() -> FBToken { FBToken() }
        func resetSession() { resetCount += 1 }
    }

    private final class FakeSettings: AppSettingsProtocol {
        var hasSeenOnboarding = false
        var tipsAlertShown = false
        var tagsPerPack = 30
        var saveAndShuffle = false
        var keepPacksOrder = false
        var openInstagramAfterCopy = false
        var instagramUsername: String?
        var pressedFBLoginButton = false
    }

    @Test func setupWithToken_withoutATokenString_failsWithoutCallingTheGateway() async {
        let gateway = FakeGateway()
        let sut = FBLoginViewModel(gateway: gateway, settings: FakeSettings(), facebookSessionService: FakeSession())

        let result: Result<Void, Error> = await withCheckedContinuation { continuation in
            sut.setupWithToken(FBToken(tokenString: nil)) { continuation.resume(returning: $0) }
        }

        guard case .failure = result else { Issue.record("Expected a failure"); return }
        #expect(gateway.setupTokens.isEmpty)
    }

    @Test func setupWithToken_passesTheTokenToTheGateway() async {
        let gateway = FakeGateway()
        let sut = FBLoginViewModel(gateway: gateway, settings: FakeSettings(), facebookSessionService: FakeSession())

        let result: Result<Void, Error> = await withCheckedContinuation { continuation in
            sut.setupWithToken(FBToken(tokenString: "token-123")) { continuation.resume(returning: $0) }
        }

        guard case .success = result else { Issue.record("Expected success"); return }
        #expect(gateway.setupTokens == ["token-123"])
    }

    @Test func resetFacebookSession_resetsSessionGatewayAndFlag() {
        let gateway = FakeGateway()
        let session = FakeSession()
        let settings = FakeSettings()
        settings.pressedFBLoginButton = true
        let sut = FBLoginViewModel(gateway: gateway, settings: settings, facebookSessionService: session)

        sut.resetFacebookSession()

        #expect(session.resetCount == 1)
        #expect(gateway.resetCount == 1)
        #expect(!settings.pressedFBLoginButton)
    }

    @Test func markLoginButtonPressed_setsTheFlag() {
        let settings = FakeSettings()
        let sut = FBLoginViewModel(gateway: FakeGateway(), settings: settings, facebookSessionService: FakeSession())

        sut.markLoginButtonPressed()

        #expect(settings.pressedFBLoginButton)
    }
}
