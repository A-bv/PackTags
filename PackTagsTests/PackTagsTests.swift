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

@MainActor
@Suite struct ReviewPromptPolicyTests {

    private final class FakeReviewPromptStore: ReviewPromptStoreProtocol {
        var launchCount = 0
        func incrementLaunchCount() { launchCount += 1 }
        var lastPromptedVersion: String?
        var lastPromptedBuild: String?
    }

    @Test func registerLaunch_incrementsCount() {
        let store = FakeReviewPromptStore()
        let policy = ReviewPromptPolicy(store: store)
        policy.registerLaunch()
        policy.registerLaunch()
        #expect(store.launchCount == 2)
    }

    @Test func promptIfEarned_presentsOnlyAfterEnoughLaunches() {
        let store = FakeReviewPromptStore()
        var presentCount = 0
        let policy = ReviewPromptPolicy(store: store, presentReview: { presentCount += 1; return true })

        store.launchCount = 7
        policy.promptIfEarned()
        #expect(presentCount == 0)

        store.launchCount = 8
        policy.promptIfEarned()
        #expect(presentCount == 1)
    }

    @Test func promptIfEarned_presentsAtMostOncePerVersion() {
        let store = FakeReviewPromptStore()
        store.launchCount = 8
        var presentCount = 0
        let policy = ReviewPromptPolicy(store: store, presentReview: { presentCount += 1; return true })

        policy.promptIfEarned()
        policy.promptIfEarned()
        #expect(presentCount == 1)
    }

    @Test func promptIfEarned_doesNotRecordWhenTheSheetIsNotShown() {
        let store = FakeReviewPromptStore()
        store.launchCount = 8

        let notShown = ReviewPromptPolicy(store: store, presentReview: { false })
        notShown.promptIfEarned()
        #expect(store.lastPromptedVersion == nil)

        var shown = false
        let shownPolicy = ReviewPromptPolicy(store: store, presentReview: { shown = true; return true })
        shownPolicy.promptIfEarned()
        #expect(shown)
    }
}
