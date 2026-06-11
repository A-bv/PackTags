import Foundation
import os

enum AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "PackTags"

    static let lifecycle = Logger(subsystem: subsystem, category: "lifecycle")
    static let persistence = Logger(subsystem: subsystem, category: "persistence")
    static let login = Logger(subsystem: subsystem, category: "login")
    static let insights = Logger(subsystem: subsystem, category: "insights")
}
