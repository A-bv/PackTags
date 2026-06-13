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

    private func makeDefaults() -> UserDefaults {
        let name = "ReviewPromptPolicyTests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        return defaults
    }

    @Test func registerLaunch_incrementsCount() {
        let defaults = makeDefaults()
        let policy = ReviewPromptPolicy(defaults: defaults)
        policy.registerLaunch()
        policy.registerLaunch()
        #expect(defaults.integer(forKey: SettingsKey.timesLaunched) == 2)
    }
}
