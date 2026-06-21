import Foundation

struct SmartGModel: Hashable {
    let hashtags: [String]
    
    init(hashtags: [String] = []) {
        self.hashtags = hashtags
    }
}
