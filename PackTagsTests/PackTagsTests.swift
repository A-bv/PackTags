//
//  PackTagsTests.swift
//  PackTagsTests
//
//  Created by Alexandre Bevilacqua on 02.09.20.
//  Copyright © 2020 Alexandre Bevilacqua. All rights reserved.
//

import XCTest
import InstagramGraph
@testable import PackTags

class PackTagsTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

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
        XCTAssertEqual(sut.topHashtags, ["#cars", "#auto"])
    }

}
