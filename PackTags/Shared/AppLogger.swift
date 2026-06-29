import Foundation
import os

enum AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "PackTags"

    static let lifecycle = Logger(subsystem: subsystem, category: "lifecycle")
    static let persistence = Logger(subsystem: subsystem, category: "persistence")
    static let login = Logger(subsystem: subsystem, category: "login")
    static let insights = Logger(subsystem: subsystem, category: "insights")
    static let ui = Logger(subsystem: subsystem, category: "ui")
    static let metrics = Logger(subsystem: subsystem, category: "metrics")

    /// Signpost intervals for hot paths (OCR, hashtag search, analytics load) so they show
    /// up as measurable regions in Instruments' os_signpost track.
    static let signposter = OSSignposter(subsystem: subsystem, category: .pointsOfInterest)
}
