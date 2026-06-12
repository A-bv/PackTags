import UIKit

@MainActor
final class ExternalLinkOpener {
    static func openAppURL(appURL: String, webURL: String) {
        let application = UIApplication.shared
        
        if let appURL = URL(string: appURL),
           application.canOpenURL(appURL) {
            application.open(appURL)
        } else if let webURLToOpenWithSafari = URL(string: webURL) {
            application.open(webURLToOpenWithSafari)
        }
    }
}
