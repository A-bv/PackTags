//
//  ApiService+Discovery.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 15.05.23.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

// Discovery
extension ApiService {
    static func business_discovery_url (account:String) -> String? {
        let limit = 12
        let url = "https://graph.facebook.com/\(apiGraphVersion)/\(igBId)?fields=business_discovery.username(\(account)){biography,name,followers_count,follows_count,id,ig_id,media_count,profile_picture_url,username,website,media.limit(\(limit){media_type,caption,timestamp,media_url,comments_count,username,like_count,media_product_type}}&access_token=\(fbToken)"
        return url.encodeUrl()
    }
}
