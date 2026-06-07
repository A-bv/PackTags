import UIKit

enum ConnectedInsightsDestination {
    case analytics
    case smartG
    case setup
    case setupInfo
}

protocol ConnectedInsightsCoordinating: AnyObject {
    func open(_ destination: ConnectedInsightsDestination, from presenter: UIViewController)
}
