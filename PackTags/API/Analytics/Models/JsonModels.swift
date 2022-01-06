//
//  JsonModelOfficial.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 30/05/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit


struct Profile: Hashable, Decodable {
    let biography: String?
    let name: String?
    let followers_count: Int?
    let follows_count: Int?
    let id: String?
    //let ig_id: Int?
    let media_count: Int?
    let profile_picture_url: String?
    let username: String?
    let insights: InsightsIG?
    let media: Media?
}

//
struct InsightsIG: Hashable, Decodable {
    let data: [DataIG?]
}
//
struct DataIG: Hashable, Decodable {
    let name: String?
    let period: String?
    let values: [Values?]
}
//
struct Values: Hashable, Decodable {
    let value: Int?
    let end_time: String?
}


struct Media: Hashable, Decodable {
    let data: [DataMedia?]
}

struct DataMedia: Hashable, Decodable {
    let media_type: String?
    let caption: String?
    let timestamp: String?
    let media_url: String?
    let comments_count: Int?
    let is_comment_enabled: Bool?
    let username: String?
    let like_count: Int?
    let insights: InsightsMedia?
}

struct InsightsMedia: Hashable, Decodable {
    let data: [DataIG?]
}

//Json model for SmartG
struct Discovery: Hashable, Decodable {
    let business_discovery: Profile?
}
