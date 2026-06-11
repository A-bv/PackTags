import XCTest
import InstagramGraph
@testable import PackTags

class PackTagsTests: XCTestCase {

    func testSmartGProcessing_whenFirstMediaHasNoCaption_keepsMediaAlignment() throws {
        let sut = SmartGViewModel()
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
