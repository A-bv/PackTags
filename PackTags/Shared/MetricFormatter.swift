import Foundation

/// Formats analytics metrics into compact display strings (e.g. `1.2K`, `3.4 %`),
/// honouring the user's locale for the decimal separator so French reads `3,4 %`.
enum MetricFormatter {
    /// A compact, human-readable number: `12`, `1.2K`, `3.4M`.
    static func compact(_ value: Double, noDecimal: Bool = false) -> String {
        switch value {
        case ..<0.01:
            return number(value, fractionDigits: 0)
        case 0.01..<100:
            return number(value, fractionDigits: noDecimal ? 0 : 1)
        case 100..<1_000:
            return number(value, fractionDigits: 0)
        case 1_000..<999_999:
            return number(value / 1_000, fractionDigits: 1) + "K"
        default:
            return number(value / 1_000_000, fractionDigits: 1) + "M"
        }
    }

    /// A metric as display text: a percentage when `isRate`, otherwise a compact value
    /// with the decimals dropped at or below 100.
    static func text(for value: Double, isRate: Bool) -> String {
        if isRate { return compact(value) + " %" }
        return value <= 100 ? compact(value, noDecimal: true) : compact(value)
    }

    /// Locale-aware number string with up to `fractionDigits` decimals and no trailing
    /// zeros — so `2.0` renders as `2`, matching the compact style.
    private static func number(_ value: Double, fractionDigits: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = fractionDigits
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "%.\(fractionDigits)f", value)
    }
}
