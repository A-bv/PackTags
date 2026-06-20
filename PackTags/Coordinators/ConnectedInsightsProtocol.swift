import UIKit

@MainActor
protocol ConnectedInsightsProtocol: AnyObject {
    func open(_ destination: ConnectedInsightsDestination, from presenter: UIViewController)
}
