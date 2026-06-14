import UIKit
import SafariServices

class SettingsVC: UIViewController {
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
    
    var onOpenQuantityPicker: (() -> Void)?
    var onReplayOnboarding: (() -> Void)?
    let connectedInsights: any ConnectedInsightsCoordinating
    let appSettings: any AppSettingsProtocol

    init(connectedInsights: any ConnectedInsightsCoordinating, appSettings: any AppSettingsProtocol) {
        self.connectedInsights = connectedInsights
        self.appSettings = appSettings
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var models = [SettingsSection]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.putShadow(false)
        
        configure()
        
        title = Strings.settingsTitle
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
    }
    
    
    func configure() {
        tableView.backgroundColor = bkgdColor

        models = SettingsSections.make(actions: SettingsActions(
            editInstagramUsername: { [weak self] in self?.setInstaUserAlert() },
            openFacebookSetup: { [weak self] in
                guard let self else { return }
                connectedInsights.open(.setup, from: self)
            },
            showQuantityPicker: { [weak self] in self?.onOpenQuantityPicker?() },
            replayOnboarding: { [weak self] in self?.onReplayOnboarding?() },
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
        ), settings: appSettings)
    }

    private func showPage(vc: UIViewController) {
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true)
    }
}
