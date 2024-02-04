//
//  hashtagIdResponse.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 15.05.23.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

struct HashtagIdResponse: Codable {
    let data: [DataItem]
}

struct DataItem: Codable {
    let id: String
}
