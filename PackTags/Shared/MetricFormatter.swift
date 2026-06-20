import Foundation

/// Formats analytics metrics into compact display strings (e.g. `1.2K`, `3.4 %`).
enum MetricFormatter {
    /// A compact, human-readable number: `12`, `1.2K`, `3.4M`.
    static func compact(_ value: Double, noDecimal: Bool = false) -> String {
        switch value {
        case ..<0.01:
            return String(format: "%.0f", value)
        case 0.01..<100:
            return String(format: noDecimal ? "%.0f" : "%.1f", value)
        case 100..<1_000:
            return String(format: "%.0f", value)
        case 1_000..<999_999:
            return String(format: "%.1fK", value / 1_000).replacingOccurrences(of: ".0", with: "")
        default:
            return String(format: "%.1fM", value / 1_000_000).replacingOccurrences(of: ".0", with: "")
        }
    }

    /// A metric as display text: a percentage when `isRate`, otherwise a compact value
    /// with the decimals dropped at or below 100.
    static func text(for value: Double, isRate: Bool) -> String {
        let number = compact(value)
        if isRate { return number + " %" }
        return value <= 100 ? number.components(separatedBy: ".")[0] : number
    }
}
