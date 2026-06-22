import UIKit
import SwiftUI
import FBSDKCoreKit
import NeumorphicUIKit
import NeumorphicSwiftUI

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if !UserDefaultsAppSettings().hasSeenOnboarding { seedData() }

        configureNeumorphicTheme()
        setupAppearance()

        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)

        ReviewPromptPolicy().registerLaunch()

        return true
    }
    
    // MARK: - Fb login
    func application( _ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:] ) -> Bool {
        ApplicationDelegate.shared.application(app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])}

    // MARK: - Style
    private func setupAppearance() {
        let color = UIColor.customPurple
        UITextView.appearance().tintColor = color
        UITextField.appearance().tintColor = color
        UISearchBar.appearance().tintColor = color
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = color
        UITableView.appearance().tintColor = color //Cell buttons
    }

    // MARK: - Theme
    /// Injects the app's palette into the neumorphic packages. Runs before any styled view appears.
    private func configureNeumorphicTheme() {
        Neumorphism.configure(NeumorphicColors(
            surface: .colorBkgd,
            darkShadow: .shadowColor,
            lightShadow: .lightShadowColor,
            bottom: .bottomColor))
        NeumorphicTheme.configure(NeumorphicPalette(
            gradientStart: .mphStart,
            gradientEnd: .mphEnd,
            lowerShadow: .lowerShadow,
            upperShadow: .upperShadow,
            highlightStroke: Color("Color4"),
            baseStroke: Color("Color1"),
            background: Color("Color-Bkgd")))
    }
    
    // MARK: - UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role)
    }

}
