//
//  Import+TestCase.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 25.06.23.
//  Copyright © 2023 Alexandre Bevilacqua. All rights reserved.
//

import SwiftUI

#if DEBUG

// Preview Testing cases purposes QQQ:
// ***
extension AnalyticsViewModel {
    func fakeProcessedJson0 () -> TransformedProfileModel {
        TransformedProfileModel(
            usr: "packtags.app",
            isPv: false,
            sum0: Optional(225),
            sum1: Optional(26),
            avg0: Optional(18.8),
            avg1: Optional(2.2),
            rates: [],
            pTimes: [],
            avg2: 23.0,
            maxR: 40.0,
            captions: [])
    }
    
    func fakeProcessedJson3 () -> TransformedProfileModel {
        TransformedProfileModel(
            usr: "packtags.app",
            isPv: false,
            sum0: Optional(225),
            sum1: Optional(26),
            avg0: Optional(18.8),
            avg1: Optional(2.2),
            rates: [Optional(12.0), Optional(23.0), Optional(16.0)],
            pTimes: [Optional(1639268616.0), Optional(1637529580.0), Optional(1636327207.0)],
            avg2: 23.0,
            maxR: 40.0,
            captions: ["A", "B", "C"])
    }

    func fakeProcessedJson1 () -> TransformedProfileModel {
        TransformedProfileModel(
            usr: "packtags.app",
            isPv: false,
            sum0: Optional(225),
            sum1: Optional(26),
            avg0: Optional(18.8),
            avg1: Optional(2.2),
            rates: [Optional(12.0)],
            pTimes: [Optional(1639268616.0)],
            avg2: 23.0,
            maxR: 40.0,
            captions: ["A"])
    }
}
// ***
#endif
