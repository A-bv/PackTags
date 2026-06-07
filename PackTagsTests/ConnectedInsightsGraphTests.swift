import XCTest
@testable import PackTags

final class ConnectedInsightsGraphTests: XCTestCase {

    func testAccessState_whenSetupIsMissing_requiresSetup() {
        let sut = makeGateway(settings: FakeConnectedInsightsSettings(isCorrectSetup: false))

        assertNeedsSetup(sut.accessState(), .setupRequired)
    }

    func testAccessState_whenFacebookTokenIsMissing_requiresToken() {
        let settings = FakeConnectedInsightsSettings(
            isCorrectSetup: true,
            facebookToken: nil,
            instagramBusinessAccountId: "ig-business-id"
        )
        let sut = makeGateway(settings: settings)

        assertNeedsSetup(sut.accessState(), .missingFacebookToken)
    }

    func testAccessState_whenInstagramBusinessIdIsMissing_requiresInstagramBusinessId() {
        let settings = FakeConnectedInsightsSettings(
            isCorrectSetup: true,
            facebookToken: "facebook-token",
            instagramBusinessAccountId: nil
        )
        let sut = makeGateway(settings: settings)

        assertNeedsSetup(sut.accessState(), .missingInstagramBusinessAccountId)
    }

    func testAccessState_whenCredentialsAreComplete_isReady() {
        let settings = FakeConnectedInsightsSettings(
            isCorrectSetup: true,
            facebookToken: "facebook-token",
            instagramBusinessAccountId: "ig-business-id"
        )
        let sut = makeGateway(settings: settings)

        switch sut.accessState() {
        case .ready(let session):
            XCTAssertEqual(session.facebookToken, "facebook-token")
            XCTAssertEqual(session.instagramBusinessAccountId, "ig-business-id")
        case .needsSetup(let error):
            XCTFail("Expected ready state, got setup error: \(error)")
        }
    }

    func testCredentialsProvider_whenCredentialsExist_returnsValidCredentials() throws {
        let settings = FakeConnectedInsightsSettings(
            facebookToken: "facebook-token",
            instagramBusinessAccountId: "ig-business-id"
        )
        let sut = SettingsInstagramGraphCredentialsProvider(settings: settings)

        let credentials = try sut.validCredentials().get()

        XCTAssertEqual(credentials.facebookToken, "facebook-token")
        XCTAssertEqual(credentials.instagramBusinessAccountId, "ig-business-id")
    }

    func testCredentialsProvider_whenCredentialsAreMissing_returnsGraphCredentialError() {
        let settings = FakeConnectedInsightsSettings(
            facebookToken: nil,
            instagramBusinessAccountId: "ig-business-id"
        )
        let sut = SettingsInstagramGraphCredentialsProvider(settings: settings)

        switch sut.validCredentials() {
        case .success:
            XCTFail("Expected missing credentials failure")
        case .failure(let error):
            guard case InstagramGraphServiceError.missingCredentials(let hasToken, let hasInstagramBusinessId) = error else {
                XCTFail("Expected missingCredentials error, got \(error)")
                return
            }
            XCTAssertFalse(hasToken)
            XCTAssertTrue(hasInstagramBusinessId)
        }
    }

    func testEndpointBuilder_buildsEncodedHashtagSearchURL() throws {
        let sut = InstagramGraphEndpointBuilder(apiGraphVersion: "v99.0")
        let credentials = InstagramGraphCredentials(
            facebookToken: "token value",
            instagramBusinessAccountId: "1789"
        )

        let url = try XCTUnwrap(sut.hashtagSearchURL(
            searchedHashtag: "summer tag",
            credentials: credentials
        ))

        XCTAssertTrue(url.contains("https://graph.facebook.com/v99.0/ig_hashtag_search"))
        XCTAssertTrue(url.contains("user_id=1789"))
        XCTAssertTrue(url.contains("q=summer%20tag"))
        XCTAssertTrue(url.contains("access_token=token%20value"))
    }

    func testEndpointBuilder_buildsAnalyticsProfileURLWithRequestedMediaLimit() throws {
        let sut = InstagramGraphEndpointBuilder(apiGraphVersion: "v99.0")
        let credentials = InstagramGraphCredentials(
            facebookToken: "facebook-token",
            instagramBusinessAccountId: "1789"
        )

        let url = try XCTUnwrap(sut.analyticsProfileURL(
            mediaLimit: 7,
            credentials: credentials
        ))

        XCTAssertTrue(url.contains("https://graph.facebook.com/v99.0/1789?fields="))
        XCTAssertTrue(url.contains("media.limit(7)"))
        XCTAssertTrue(url.contains("access_token=facebook-token"))
        XCTAssertTrue(url.contains("checkType=FULL"))
    }

    func testSmartGRepository_whenCredentialsAreMissing_doesNotCallGraphClient() {
        let client = FakeInstagramGraphClient()
        let sut = SmartGHashtagRepository(
            credentialsProvider: FakeInstagramGraphCredentialsProvider(
                facebookToken: nil,
                instagramBusinessAccountId: "ig-business-id"
            ),
            endpointBuilder: InstagramGraphEndpointBuilder(apiGraphVersion: "v99.0"),
            client: client
        )
        let expectation = expectation(description: "search completes")

        sut.searchHashtag(searchedHashtag: "travel") { result in
            switch result {
            case .success:
                XCTFail("Expected missing credentials failure")
            case .failure(let error):
                guard case InstagramGraphServiceError.missingCredentials(let hasToken, let hasInstagramBusinessId) = error else {
                    XCTFail("Expected missingCredentials error, got \(error)")
                    return
                }
                XCTAssertFalse(hasToken)
                XCTAssertTrue(hasInstagramBusinessId)
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func testSmartGRepository_fetchesHashtagMediaWithGraphClient() throws {
        let client = FakeInstagramGraphClient(responses: [
            .success(#"{"data":[{"id":"17841562498105353"}]}"#.data(using: .utf8)!),
            .success(#"{"data":[{"media_type":"IMAGE","caption":"Hello","timestamp":"2026-06-07T08:00:00+0000","media_url":"https://example.com/image.jpg","comments_count":3,"like_count":9}]}"#.data(using: .utf8)!)
        ])
        let sut = SmartGHashtagRepository(
            credentialsProvider: FakeInstagramGraphCredentialsProvider(
                facebookToken: "facebook-token",
                instagramBusinessAccountId: "ig-business-id"
            ),
            endpointBuilder: InstagramGraphEndpointBuilder(apiGraphVersion: "v99.0"),
            client: client
        )
        let expectation = expectation(description: "search completes")
        var loadedMedia: [DataMedia]?

        sut.searchHashtag(searchedHashtag: "travel") { result in
            loadedMedia = try? result.get()
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)

        XCTAssertEqual(client.requestedURLs.count, 2)
        XCTAssertTrue(client.requestedURLs[0].contains("ig_hashtag_search"))
        XCTAssertTrue(client.requestedURLs[1].contains("17841562498105353/top_media"))
        let firstMedia = try XCTUnwrap(loadedMedia?.first)
        XCTAssertEqual(firstMedia.caption, "Hello")
        XCTAssertEqual(firstMedia.comments_count, 3)
        XCTAssertEqual(firstMedia.like_count, 9)
    }

    func testUnavailableProvidersReturnUnavailableError() {
        let smartGExpectation = expectation(description: "smartG unavailable completes")
        let analyticsExpectation = expectation(description: "analytics unavailable completes")

        UnavailableSmartGDataProvider().searchHashtag(searchedHashtag: "travel") { result in
            XCTAssertThrowsUnavailableError(result)
            smartGExpectation.fulfill()
        }

        UnavailableAnalyticsDataProvider().loadProfileForAnalytics { result in
            XCTAssertThrowsUnavailableError(result)
            analyticsExpectation.fulfill()
        }

        wait(for: [smartGExpectation, analyticsExpectation], timeout: 1)
    }

    private func makeGateway(
        settings: FakeConnectedInsightsSettings
    ) -> ConnectedInsightsGateway {
        ConnectedInsightsGateway(
            settings: settings,
            smartGDataProvider: FakeSmartGDataProvider(),
            analyticsDataProvider: FakeAnalyticsDataProvider()
        )
    }

    private func assertNeedsSetup(
        _ state: ConnectedInsightsAccessState,
        _ expectedError: ConnectedInsightsError,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        switch state {
        case .ready:
            XCTFail("Expected needsSetup state", file: file, line: line)
        case .needsSetup(let error):
            XCTAssertEqual(error.errorDescription, expectedError.errorDescription, file: file, line: line)
        }
    }
}

private final class FakeConnectedInsightsSettings: ConnectedInsightsSettingsProtocol {
    var isCorrectSetup: Bool
    var facebookToken: String?
    var instagramBusinessAccountId: String?
    var setupInfoShown: Bool
    var pressedFacebookLoginButton: Bool

    init(
        isCorrectSetup: Bool = false,
        facebookToken: String? = nil,
        instagramBusinessAccountId: String? = nil,
        setupInfoShown: Bool = false,
        pressedFacebookLoginButton: Bool = false
    ) {
        self.isCorrectSetup = isCorrectSetup
        self.facebookToken = facebookToken
        self.instagramBusinessAccountId = instagramBusinessAccountId
        self.setupInfoShown = setupInfoShown
        self.pressedFacebookLoginButton = pressedFacebookLoginButton
    }
}

private struct FakeInstagramGraphCredentialsProvider: InstagramGraphCredentialsProviding {
    let facebookToken: String?
    let instagramBusinessAccountId: String?
}

private final class FakeInstagramGraphClient: InstagramGraphClientProtocol {
    private var responses: [Result<Data, Error>]
    private(set) var requestedURLs: [String] = []

    init(responses: [Result<Data, Error>] = []) {
        self.responses = responses
    }

    func fetchGraphData(
        from urlString: String,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        requestedURLs.append(urlString)
        guard !responses.isEmpty else {
            completion(.failure(InstagramGraphServiceError.emptyResponse))
            return
        }
        completion(responses.removeFirst())
    }
}

private struct FakeSmartGDataProvider: SmartGDataProviding {
    func searchHashtag(
        searchedHashtag: String,
        completion: @escaping (Result<[DataMedia], Error>) -> Void
    ) {
        completion(.success([]))
    }
}

private struct FakeAnalyticsDataProvider: AnalyticsDataProviding {
    func loadProfileForAnalytics(completion: @escaping (Result<Profile, Error>) -> Void) {
        completion(.failure(ConnectedInsightsError.dataProviderUnavailable))
    }
}

private func XCTAssertThrowsUnavailableError<T>(
    _ result: Result<T, Error>,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    switch result {
    case .success:
        XCTFail("Expected unavailable provider failure", file: file, line: line)
    case .failure(let error):
        XCTAssertEqual(
            error.localizedDescription,
            ConnectedInsightsError.dataProviderUnavailable.localizedDescription,
            file: file,
            line: line
        )
    }
}
