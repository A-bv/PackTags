import Foundation

protocol ReviewPromptStoreProtocol: AnyObject {
    var launchCount: Int { get }
    func incrementLaunchCount()
    var lastPromptedVersion: String? { get set }
    var lastPromptedBuild: String? { get set }
}
