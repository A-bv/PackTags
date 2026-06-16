import UIKit
import SafariServices

final class SettingsVC: UIViewController {
    private enum Strings {
        static let settingsTitle = "Settings".localized()
    }
    
    private enum Links {
        static let settingsInstagramAppUrl = "instagram://user?username=packtags.app"
        static let settingsInstagramWebUrl = "https://instagram.com/packtags.app"
    }
    
    private let tableView: UITableView = {
        let table = UITableView (frame:  .zero, style: .grouped)
        table.register(
            SettingsCell.self,
            forCellReuseIdentifier: SettingsCell.identifier)
        table.register(
            SettingsSwitchCell.self,
            forCellReuseIdentifier: SettingsSwitchCell.identifier)
        return table
    }()
    
    let navigation: SettingsNavigation
    let connectedInsights: any ConnectedInsightsProtocol
    let appSettings: any AppSettingsProtocol
    lazy var viewModel = makeViewModel()

    init(connectedInsights: any ConnectedInsightsProtocol, appSettings: any AppSettingsProtocol, navigation: SettingsNavigation) {
        self.connectedInsights = connectedInsights
        self.appSettings = appSettings
        self.navigation = navigation
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.putShadow(false)
        tableView.backgroundColor = .colorBkgd
        title = Strings.settingsTitle
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
    }
    
    
    private func makeViewModel() -> SettingsViewModel {
        let actions = SettingsActions(
            editInstagramUsername: { [weak self] in self?.setInstaUserAlert() },
            openFacebookSetup: { [weak self] in
                guard let self else { return }
                connectedInsights.open(.setup, from: self)
            },
            showQuantityPicker: navigation.openQuantityPicker,
            replayOnboarding: navigation.replayOnboarding,
            openSetupInfo: { [weak self] in
                guard let self else { return }
                connectedInsights.open(.setupInfo, from: self)
            },
            openWebPage: { [weak self] urlString in
                guard let url = URL(string: urlString) else { return }
                self?.showPage(vc: SFSafariViewController(url: url))
            },
            openOurInstagram: {
                ExternalLinkOpener.openAppURL(
                    appURL: Links.settingsInstagramAppUrl,
                    webURL: Links.settingsInstagramWebUrl)
            },
            shareApp: { [weak self] in self?.shareApp() },
            rateApp: { [weak self] in self?.showReviewPopUp() },
            contactSupport: { [weak self] in self?.sendEmail() }
        )
        return SettingsViewModel(actions: actions, settings: appSettings)
    }

    private func showPage(vc: UIViewController) {
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true)
    }
}
