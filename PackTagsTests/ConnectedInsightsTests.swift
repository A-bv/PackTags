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
                    ["name": "reach", "values": [["value": media.reach]]],
                    ["name": "views", "values": [["value": media.impressions]]],
                    ["name": "total_interactions", "values": [["value": media.engagement]]],
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

        #expect(ProfileDataTransformer.transform(response: profile) == nil)
    }

    @Test func transform_sumsAndAveragesLikesAndComments() throws {
        let profile = try makeProfile(medias: [
            (likes: 10, comments: 2, reach: 100, impressions: 200, engagement: 12),
            (likes: 20, comments: 4, reach: 300, impressions: 400, engagement: 24),
        ])

        let model = try #require(ProfileDataTransformer.transform(response: profile))

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

        let model = try #require(ProfileDataTransformer.transform(
            response: profile, metric: .engagement, rawInsights: true))

        #expect(model.rates == [12, 24])
        #expect(model.averageRate == 18)
        #expect(model.maxRate == 24)
    }

    @Test func transform_computedRates_arePercentagesOfFollowers() throws {
        let profile = try makeProfile(followers: 200, medias: [
            (likes: 1, comments: 1, reach: 100, impressions: 200, engagement: 10),
            (likes: 1, comments: 1, reach: 300, impressions: 400, engagement: 30),
        ])

        let model = try #require(ProfileDataTransformer.transform(
            response: profile, metric: .engagement, rawInsights: false))

        #expect(model.rates == [5, 15]) // engagement * 100 / followers
    }

    @Test func transform_zeroDenominators_produceZeroRatesInsteadOfNaN() throws {
        let profile = try makeProfile(followers: 0, medias: [
            (likes: 1, comments: 1, reach: 0, impressions: 0, engagement: 10),
        ])

        let model = try #require(ProfileDataTransformer.transform(
            response: profile, metric: .reach, rawInsights: false))

        #expect(model.rates == [0])
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

    @Test func loadDefaultFeed_flagsTheErrorState_whenTheGatewayFails() async {
        let sut = SmartGViewModel(gateway: UnavailableConnectedInsightsGateway())

        await sut.loadDefaultFeed()

        #expect(sut.isErrorState)
        #expect(!sut.loading)
    }

    @Test func submitSearch_runsOncePerDistinctEntry() async {
        let sut = SmartGViewModel(gateway: UnavailableConnectedInsightsGateway())

        sut.hashtagEntry = "#sea"
        #expect(await sut.submitSearch())
        #expect(await !sut.submitSearch()) // unchanged entry

        sut.hashtagEntry = "sea" // identical once the # is stripped
        #expect(await !sut.submitSearch())
    }
}

// MARK: - FacebookLoginViewModel

@MainActor
@Suite struct FacebookLoginViewModelTests {

    private final class FakeGateway: ConnectedInsightsGatewayProtocol {
        var setupTokens: [String] = []
        var resetCount = 0
        var setupError: Error?

        func accessState() -> ConnectedInsightsAccessState { .needsSetup(.setupRequired) }
        func setup(facebookToken: String) async throws {
            setupTokens.append(facebookToken)
            if let setupError { throw setupError }
        }
        func reset() { resetCount += 1 }
        func searchHashtag(searchedHashtag: String) async throws -> [InstagramPost] { [] }
        func loadProfileForAnalytics(mediaLimit: Int?) async throws -> Profile {
            throw ConnectedInsightsError.setupRequired
        }
    }

    private final class FakeSession: FacebookSessionServiceProtocol {
        var token = FacebookToken(tokenString: nil)
        var resetCount = 0
        func currentToken() -> FacebookToken { token }
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
        var pressedFacebookLoginButton = false
        var setupInfoShown = false
    }

    @MainActor
    private final class FakeTracking: AppTrackingAuthorizerProtocol {
        var authorized: Bool
        private(set) var requestCount = 0
        private(set) var promptCount = 0
        init(authorized: Bool) { self.authorized = authorized }
        var isAuthorized: Bool { authorized }
        func requestIfNeeded() async -> Bool { requestCount += 1; return authorized }
        func promptOrOpenSettings() async { promptCount += 1 }
    }

    private func makeSUT(
        token: FacebookToken = FacebookToken(tokenString: nil),
        setupError: Error? = nil,
        setupInfoShown: Bool = true
    ) -> (sut: FacebookLoginViewModel, gateway: FakeGateway, session: FakeSession, settings: FakeSettings) {
        let gateway = FakeGateway()
        gateway.setupError = setupError
        let session = FakeSession()
        session.token = token
        let settings = FakeSettings()
        settings.setupInfoShown = setupInfoShown
        let sut = FacebookLoginViewModel(gateway: gateway, settings: settings, facebookSessionService: session)
        return (sut, gateway, session, settings)
    }

    private let oauthError = InstagramGraphServiceError.graphHTTPError(
        statusCode: 400,
        body: #"{"error":{"message":"Invalid OAuth access token","type":"OAuthException","code":190}}"#)

    // MARK: setup info

    @Test func hasSeenSetupInfo_reflectsSettings() {
        let (seen, _, _, _) = makeSUT(setupInfoShown: true)
        #expect(seen.hasSeenSetupInfo)
        let (unseen, _, _, _) = makeSUT(setupInfoShown: false)
        #expect(!unseen.hasSeenSetupInfo)
    }

    // MARK: validateSetup

    @Test func validateSetup_connects_whenGatewaySucceeds() async {
        let (sut, gateway, _, _) = makeSUT(token: FacebookToken(tokenString: "token-123"))

        await sut.validateSetup()

        #expect(sut.result == .connected)
        #expect(gateway.setupTokens == ["token-123"])
    }

    @Test func validateSetup_sessionExpired_andResets_whenNoToken() async {
        let (sut, gateway, session, _) = makeSUT(token: FacebookToken(tokenString: nil))

        await sut.validateSetup()

        #expect(sut.result == .sessionExpired)
        #expect(gateway.setupTokens.isEmpty)   // never reached the Graph
        #expect(session.resetCount == 1)       // stale session cleared
    }

    @Test func validateSetup_sessionExpired_andResets_onInvalidToken() async {
        let (sut, _, session, _) = makeSUT(token: FacebookToken(tokenString: "stale"), setupError: oauthError)

        await sut.validateSetup()

        #expect(sut.result == .sessionExpired)
        #expect(session.resetCount == 1)       // self-heals the code-190 case
    }

    @Test func validateSetup_fails_withoutResetting_onNonAuthError() async {
        let (sut, _, session, _) = makeSUT(
            token: FacebookToken(tokenString: "token-123"),
            setupError: InstagramGraphServiceError.instagramAccountNotFound)

        await sut.validateSetup()

        if case .failed = sut.result {} else { Issue.record("expected .failed, got \(String(describing: sut.result))") }
        #expect(session.resetCount == 0)       // not an auth problem — keep the session
    }

    @Test func validateSetup_marksLoginAttempt_whenRequested() async {
        let (sut, _, _, settings) = makeSUT(token: FacebookToken(tokenString: "token-123"))

        await sut.validateSetup(markLoginAttempt: true)

        #expect(settings.pressedFacebookLoginButton)
    }

    @Test func validateSetup_flagsLogin_whenConnectedViaLoginAttempt() async {
        let (sut, _, _, _) = makeSUT(token: FacebookToken(tokenString: "token-123"))

        await sut.validateSetup(markLoginAttempt: true)

        #expect(sut.result == .connected)
        #expect(sut.connectedViaLogin)   // active login → confirm with "Connected!"
    }

    @Test func validateSetup_doesNotFlagLogin_onPassiveRevalidation() async {
        let (sut, _, _, _) = makeSUT(token: FacebookToken(tokenString: "token-123"))

        await sut.validateSetup(markLoginAttempt: false)

        #expect(sut.result == .connected)
        #expect(!sut.connectedViaLogin)  // passive re-validation → no alert
    }

    @Test func didCompleteLogin_connectsAndFlagsLogin_onSuccess() async {
        let session = FakeSession()
        session.token = FacebookToken(tokenString: "token-123")
        let sut = FacebookLoginViewModel(
            gateway: FakeGateway(), settings: FakeSettings(),
            facebookSessionService: session)

        await sut.didCompleteLogin(error: nil)

        #expect(sut.result == .connected)
        #expect(sut.connectedViaLogin)
    }

    // MARK: reset

    @Test func resetFacebookSession_resetsSessionGatewayAndFlag() {
        let (sut, gateway, session, settings) = makeSUT()
        settings.pressedFacebookLoginButton = true

        sut.resetFacebookSession()

        #expect(session.resetCount == 1)
        #expect(gateway.resetCount == 1)
        #expect(!settings.pressedFacebookLoginButton)
    }

    // MARK: tracking (ATT)

    @Test func onAppear_promptsTracking_andValidatesWhenAuthorizedWithToken() async {
        let session = FakeSession()
        session.token = FacebookToken(tokenString: "token-123")
        let tracking = FakeTracking(authorized: true)
        let sut = FacebookLoginViewModel(
            gateway: FakeGateway(), settings: FakeSettings(),
            facebookSessionService: session, tracking: tracking)

        await sut.onAppear()

        #expect(tracking.requestCount == 1)
        #expect(sut.isTrackingAuthorized)
        #expect(sut.result == .connected)
    }

    @Test func handleTrackingTap_routesToTheAuthorizer() async {
        let tracking = FakeTracking(authorized: false)
        let sut = FacebookLoginViewModel(
            gateway: FakeGateway(), settings: FakeSettings(),
            facebookSessionService: FakeSession(), tracking: tracking)

        await sut.handleTrackingTap()

        #expect(tracking.promptCount == 1)
        #expect(!sut.isTrackingAuthorized)
    }

    @Test func didCompleteLogin_failsOnError() async {
        let sut = FacebookLoginViewModel(
            gateway: FakeGateway(), settings: FakeSettings(),
            facebookSessionService: FakeSession())

        await sut.didCompleteLogin(error: oauthError)

        if case .failed = sut.result {} else {
            Issue.record("expected .failed, got \(String(describing: sut.result))")
        }
    }
}

// MARK: - AnalyticsViewModel

@MainActor
@Suite struct AnalyticsViewModelTests {

    /// Returns whatever profile it's seeded with, so the VM's transform/fill pipeline
    /// can be exercised without networking.
    private final class StubGateway: ConnectedInsightsGatewayProtocol {
        let profile: Profile
        init(profile: Profile) { self.profile = profile }
        func accessState() -> ConnectedInsightsAccessState { .needsSetup(.setupRequired) }
        func setup(facebookToken: String) async throws {}
        func reset() {}
        func searchHashtag(searchedHashtag: String) async throws -> [InstagramPost] { [] }
        func loadProfileForAnalytics(mediaLimit: Int?) async throws -> Profile { profile }
    }

    private func makeSUT(profile: Profile) -> AnalyticsViewModel {
        AnalyticsViewModel(gateway: StubGateway(profile: profile))
    }

    private func twoPostProfile() throws -> Profile {
        try makeProfile(followers: 1000, medias: [
            (likes: 10, comments: 2, reach: 100, impressions: 200, engagement: 12),
            (likes: 20, comments: 4, reach: 300, impressions: 400, engagement: 24),
        ])
    }

    @Test func load_buildsOneBarPerPost() async throws {
        let sut = makeSUT(profile: try twoPostProfile())

        await sut.load()

        #expect(sut.profile != nil)
        #expect(sut.barChartData.count == 2)
        #expect(sut.barChartData.map(\.post) == ["1", "2"])
    }

    @Test func load_fillsOverviewWithFormattedAverages() async throws {
        let sut = makeSUT(profile: try twoPostProfile())

        await sut.load()

        let averageLikes = try #require(sut.transformedProfile?.averageLikes)
        let averageComments = try #require(sut.transformedProfile?.averageComments)
        #expect(sut.overviewSectionData[0].value == MetricFormatter.compact(averageLikes))
        #expect(sut.overviewSectionData[1].value == MetricFormatter.compact(averageComments))
    }

    @Test func load_withoutMedia_leavesDefaultsUntouched() async throws {
        let sut = makeSUT(profile: try makeProfile())

        await sut.load()

        #expect(sut.transformedProfile == nil)
        #expect(sut.overviewSectionData[0].value == "0")
        #expect(sut.barChartData.count == 1)   // the seeded placeholder bar
    }

    @Test func refreshFromCurrentProfile_withoutLoad_isNoOp() throws {
        let sut = makeSUT(profile: try twoPostProfile())

        sut.refreshFromCurrentProfile()

        #expect(sut.transformedProfile == nil)
        #expect(sut.barChartData.count == 1)
    }

    @Test func refreshFromCurrentProfile_afterMetricChange_recomputesFromMemory() async throws {
        let sut = makeSUT(profile: try twoPostProfile())
        await sut.load()

        sut.metric = .reach
        sut.refreshFromCurrentProfile()

        #expect(sut.metric == .reach)
        #expect(sut.barChartData.count == 2)
        #expect(sut.transformedProfile != nil)
    }
}
