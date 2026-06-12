import XCTest
import Testing
import InstagramGraph
@testable import PackTags

class PackTagsTests: XCTestCase {

    @MainActor
    func testSmartGProcessing_whenFirstMediaHasNoCaption_keepsMediaAlignment() throws {
        let sut = SmartGViewModel(gateway: UnavailableConnectedInsightsGateway())
        let mediaResponse = """
        {
          "data": [
            {
              "id": "1",
              "media_type": "IMAGE",
              "media_url": "https://example.com/one.jpg",
              "comments_count": 1,
              "like_count": 2
            },
            {
              "id": "2",
              "caption": "#cars #auto",
              "media_type": "IMAGE",
              "media_url": "https://example.com/two.jpg",
              "comments_count": 3,
              "like_count": 4
            }
          ]
        }
        """.data(using: .utf8)!
        let media = try JSONDecoder().decode(Media.self, from: mediaResponse)
        sut.dataMedias = media.data.compactMap { $0 }

        sut.processSmartGModel()

        XCTAssertEqual(sut.computedData.count, 2)
        XCTAssertEqual(sut.computedData[0].hashtags, [])
        XCTAssertEqual(sut.computedData[1].hashtags, ["#cars", "#auto"])
        XCTAssertEqual(Set(sut.topHashtags), Set(["#cars", "#auto"]))
    }

}

@Suite struct ReviewPromptPolicyTests {

    /// A fresh, uniquely named suite per test — the suite runs in parallel.
    private func makeDefaults() -> UserDefaults {
        let name = "ReviewPromptPolicyTests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        return defaults
    }

    @Test func shouldPrompt_requiresEnoughLaunches() {
        let policy = ReviewPromptPolicy(defaults: makeDefaults())

        for _ in 1...7 { policy.registerLaunch() }
        #expect(!policy.shouldPrompt(version: "1.0", build: "1"))

        policy.registerLaunch()
        #expect(policy.shouldPrompt(version: "1.0", build: "1"))
    }

    @Test func shouldPrompt_atMostOncePerVersion() {
        let policy = ReviewPromptPolicy(defaults: makeDefaults())
        for _ in 1...8 { policy.registerLaunch() }

        policy.markPrompted(version: "1.0", build: "1")

        #expect(!policy.shouldPrompt(version: "1.0", build: "1"))
        #expect(policy.shouldPrompt(version: "1.1", build: "2"))
    }
}
