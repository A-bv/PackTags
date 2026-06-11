import Foundation

struct SmartGModel: Hashable, Decodable {
    let hashtags: [String]
    
    init(hashtags: [String] = []) {
        self.hashtags = hashtags
    }
}
