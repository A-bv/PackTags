import SwiftUI

#if DEBUG

// Preview Testing cases purposes QQQ:
// ***
extension AnalyticsViewModel {
    func fakeProcessedJson0 () -> TransformedProfileModel {
        TransformedProfileModel(
            username: "packtags.app",
            isPrivateProfile: false,
            totalLikes: Optional(225),
            totalComments: Optional(26),
            averageLikes: Optional(18.8),
            averageComments: Optional(2.2),
            rates: [],
            postTimes: [],
            averageRate: 23.0,
            maxRate: 40.0,
            captions: [])
    }
    
    func fakeProcessedJson3 () -> TransformedProfileModel {
        TransformedProfileModel(
            username: "packtags.app",
            isPrivateProfile: false,
            totalLikes: Optional(225),
            totalComments: Optional(26),
            averageLikes: Optional(18.8),
            averageComments: Optional(2.2),
            rates: [Optional(12.0), Optional(23.0), Optional(16.0)],
            postTimes: [Optional(1639268616.0), Optional(1637529580.0), Optional(1636327207.0)],
            averageRate: 23.0,
            maxRate: 40.0,
            captions: ["A", "B", "C"])
    }

    func fakeProcessedJson1 () -> TransformedProfileModel {
        TransformedProfileModel(
            username: "packtags.app",
            isPrivateProfile: false,
            totalLikes: Optional(225),
            totalComments: Optional(26),
            averageLikes: Optional(18.8),
            averageComments: Optional(2.2),
            rates: [Optional(12.0)],
            postTimes: [Optional(1639268616.0)],
            averageRate: 23.0,
            maxRate: 40.0,
            captions: ["A"])
    }
}
// ***
#endif
