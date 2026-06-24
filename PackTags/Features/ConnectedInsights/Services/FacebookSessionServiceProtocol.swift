protocol FacebookSessionServiceProtocol {
    func currentToken() -> FacebookToken
    func resetSession()
}
