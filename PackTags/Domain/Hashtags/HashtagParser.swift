enum HashtagParser {
    static func parse(_ text: String) -> [String] {
        text.matches(of: /(?!#\p{Hebrew}|#\p{Arabic})#\w+/).map { String($0.output) }
    }
}
