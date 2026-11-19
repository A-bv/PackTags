import Foundation
import InstagramGraph

/// Serves canned sample data so the Connected Insights screens (Analytics and
/// Smart Hashtags) can run without a real Instagram account. The composition
/// root selects it under the `-uitests` launch argument, for UI tests and
/// screenshots. The package models are Decodable-only, so the sample data is
/// built the way production decodes it: from Graph-API-shaped JSON.
struct DemoConnectedInsightsGateway: ConnectedInsightsGatewayProtocol {
    nonisolated init() {}

    func accessState() -> ConnectedInsightsAccessState { .ready }
    func setup(facebookToken: String) async throws {}
    func reset() {}

    func searchHashtag(searchedHashtag: String) async throws -> [InstagramPost] {
        try Self.decode([InstagramPost].self, from: Self.samplePosts)
    }

    func loadProfileForAnalytics(mediaLimit: Int?) async throws -> Profile {
        try Self.decode(Profile.self, from: Self.sampleProfile)
    }

    // MARK: - Sample data (Graph-API-shaped JSON)

    private static func decode<T: Decodable>(_ type: T.Type, from json: Any) throws -> T {
        try JSONDecoder().decode(T.self, from: JSONSerialization.data(withJSONObject: json))
    }

    private static func media(
        likes: Int, comments: Int, reach: Int, views: Int, interactions: Int, caption: String
    ) -> [String: Any] {
        [
            "like_count": likes,
            "comments_count": comments,
            "caption": caption,
            "insights": ["data": [
                ["name": "reach", "values": [["value": reach]]],
                ["name": "views", "values": [["value": views]]],
                ["name": "total_interactions", "values": [["value": interactions]]]
            ]]
        ]
    }

    private static var sampleProfile: [String: Any] {
        [
            "id": "1",
            "username": "packtags",
            "followers_count": 4200,
            "media": ["data": [
                media(likes: 420, comments: 31, reach: 5200, views: 7100, interactions: 468, caption: "#sunset"),
                media(likes: 510, comments: 44, reach: 6100, views: 8900, interactions: 572, caption: "#coffee"),
                media(likes: 380, comments: 22, reach: 4800, views: 4300, interactions: 410, caption: "#travel"),
                media(likes: 620, comments: 58, reach: 7300, views: 11200, interactions: 702, caption: "#food"),
                media(likes: 290, comments: 15, reach: 3900, views: 5100, interactions: 312, caption: "#design"),
                media(likes: 475, comments: 37, reach: 5600, views: 6800, interactions: 523, caption: "#city")
            ]]
        ]
    }

    private static var samplePosts: [Any] {
        let captions = [
            "#travel #wanderlust #explore #adventure #nature",
            "#travel #wanderlust #trip #mountains #sunset",
            "#travel #vacation #explore #beach #summer",
            "#travel #wanderlust #roadtrip #nature #views",
            "#travel #explore #city #architecture #streetphotography",
            "#travel #wanderlust #hiking #mountains #adventure",
            "#travel #vacation #island #beach #paradise",
            "#travel #explore #foodie #local #culture",
            "#travel #wanderlust #nature #landscape #sunset",
            "#travel #trip #adventure #explore #wanderlust"
        ]
        return captions.map { ["caption": $0] }
    }
}
