@MainActor
protocol AppTrackingAuthorizerProtocol {
    var isAuthorized: Bool { get }
    func requestIfNeeded() async -> Bool
    func promptOrOpenSettings() async
}
