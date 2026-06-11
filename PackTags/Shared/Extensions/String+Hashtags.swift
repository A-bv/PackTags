import Foundation

extension String {
    /// Extracts hashtags, excluding right-to-left scripts the rest of the
    /// pipeline can't reorder safely.
    func detectHashtags() -> [String] {
        guard let regex = try? NSRegularExpression(
            pattern: "((?!#\\p{Hebrew}|#\\p{Arabic})#[\\w]+)",
            options: .caseInsensitive
        ) else { return [] }

        let nsString = self as NSString
        return regex.matches(
            in: self,
            options: [],
            range: NSRange(location: 0, length: nsString.length)
        ).map {
            nsString.substring(with: $0.range)
        }
    }
}
