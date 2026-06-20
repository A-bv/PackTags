import UIKit

@MainActor
protocol CoordinatorProtocol: AnyObject {
    var navigationController: UINavigationController { get }
    func start()
}
