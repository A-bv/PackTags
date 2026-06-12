import Foundation

struct TransformedProfileModel {
    let username: String?                //. Basic: username
    let isPrivateProfile: Bool?     //. Basic: is private?
    let postsCount: Int?            //. Basic: post count
    
    let totalLikes: Int?
    let totalComments: Int?
    let averageLikes: Double?
    let averageComments: Double?
    let rates: [CGFloat?]
    let postTimes: [Double?]
    let averageRate: CGFloat?
    let maxRate: CGFloat?
    let captions: [String?]
    
    init(
        username: String? = nil,
        isPrivateProfile: Bool? = nil,
        totalLikes: Int? = nil,
        totalComments: Int? = nil,
        averageLikes: Double? = nil,
        averageComments: Double? = nil,
        rates: [CGFloat?] = [nil],
        postTimes: [CDouble?] = [nil],
        averageRate: CGFloat? = nil,
        maxRate: CGFloat? = nil,
        captions: [String?] = [nil]
    ) {
        self.username = username
        self.isPrivateProfile = isPrivateProfile
        self.totalLikes = totalLikes
        self.totalComments = totalComments
        self.averageLikes = averageLikes
        self.averageComments = averageComments
        self.rates = rates
        self.postTimes = postTimes
        self.averageRate = averageRate
        self.maxRate = maxRate
        self.captions = captions
        self.postsCount = rates.count
    }
}
