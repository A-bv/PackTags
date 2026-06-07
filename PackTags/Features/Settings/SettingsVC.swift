//
//  SettingsVC.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 17/03/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//
import UIKit
import SafariServices

struct SettingsSection {
    let title: String
    let options: [SettingsOptionType] //mod
}

//mod --
enum SettingsOptionType {
    case staticCell(model: SettingsOption)
    case switchCell(model: SettingsSwitchOption)
    
}

struct SettingsSwitchOption {
    let title: String
    //let id: String
    let icon: UIImage?
    let iconBackgroundColor: UIColor
    let handler: (() -> Void)
    var isOn: Bool
}
// --

struct SettingsOption {
    let title: String
    let icon: UIImage?
    let iconBackgroundColor: UIColor
    let handler: (() -> Void)
}

class SettingsVC: UIViewController {
    private enum Strings {
        static let settingsTitle = "Settings".localized()
        static let settingsSectionTitleAccount = "Account".localized()
        static let settingsTitleInstagram = "Instagram".localized()
        static let settingsTitleFacebookLogin = "Facebook Login".localized()
        static let settingsSectionTitleHashtags = "Hastags".localized()
        static let settingsTitleQuantityPerPack = "Quantity Per Pack".localized()
        static let settingsTitleSaveAndShuffle = "Save & Shuffle".localized()
        static let settingsTitleKeepPackOrder = "Keep Packs Order".localized()
        static let settingsSectionTitleHelp = "Help".localized()
        static let settingsTitleOnBoard = "On Board".localized()
        static let settingsTitleTricksAndTips = "Tricks & Tips".localized()
        static let settingsTitleInstaSetup = "Instagram Setup".localized()
        static let settingsSectionTitleAboutUs = "About us".localized()
        static let settingsSectionTitleOurInstagram = "Our Instagram".localized()
        static let settingsTitleShare = "Share".localized()
        static let settingsTitleRateAndReview = "Rate & Review".localized()
        static let settingsTitleContactUs = "Contact Us".localized()
        static let settingsSectionTitleLegal = "Legal".localized()
        static let settingsTitlePrivacy = "Privacy".localized()
        static let settingsTitleTermsAndConditions = "Terms & Conditions".localized()
        static let settingsTitleDisclaimer = "Disclaimer".localized()
    }
    
    private enum Links {
        static let settingsInstagramAppUrl = "instagram://user?username=packtags.app"
        static let settingsInstagramWebUrl = "https://instagram.com/packtags.app"
        static let settingsPrivacyPolicyUrl = "https://sites.google.com/view/packtags-privacy-policy/accueil"
        static let settingsTermsAndConditionsUrl = "https://sites.google.com/view/packtagstc/accueil"
        static let settingsDisclaimerUrl = "https://sites.google.com/view/packtagsdisclaimer/accueil"
        static let settingsTricksAndTipsUrl = "https://sites.google.com/view/packtags-tricks-tips/accueil"
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
    
    weak var coordinator: (any ThemeCoordinatorProtocol)?
    var connectedInsights: any ConnectedInsightsRouting = ConnectedInsightsModule()

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
    
    
    func configure () {
        let icon = UIImage(systemName: "gearshape")!
        self.tableView.backgroundColor = bkgdColor
        
        models.append(
            SettingsSection(
                title: Strings.settingsSectionTitleAccount,
                options: [
                    .staticCell(
                        model:
                            SettingsOption(
                                title: Strings.settingsTitleInstagram,
                                icon: icon,
                                iconBackgroundColor: .systemRed
                            ) { [weak self] in
                                self?.setInstaUserAlert ()
                            }),
                    
                    .staticCell(
                        model: SettingsOption(
                            title: Strings.settingsTitleFacebookLogin,
                            icon: icon,
                            iconBackgroundColor: .systemOrange
                        ) { [weak self] in
                            guard let self else { return }
                            let viewController = connectedInsights.makeViewController(for: .setup)
                            showPage(vc: viewController)
                        })]))
        
        models.append(
            SettingsSection(
                title: Strings.settingsSectionTitleHashtags,
                options: [
                    .staticCell(
                        model: SettingsOption(
                            title: Strings.settingsTitleQuantityPerPack,
                            icon: icon,
                            iconBackgroundColor: .systemPink
                        ) { [weak self] in
                            let vwc = QuantityPickerVC()
                            self?.showPage(vc: vwc)
                        }),
                    .switchCell(
                        model: SettingsSwitchOption(
                            title: Strings.settingsTitleSaveAndShuffle,
                            icon: icon,
                            iconBackgroundColor: .systemYellow,
                            handler: {}, isOn: false)),
                    .switchCell(
                        model: SettingsSwitchOption(
                            title: Strings.settingsTitleKeepPackOrder,
                            icon: icon,
                            iconBackgroundColor: .systemRed,
                            handler: {}, isOn: false))]))
        
        models.append(
            SettingsSection(
                title: Strings.settingsSectionTitleHelp,
                options: [
                    .staticCell(
                        model: SettingsOption(
                            title: Strings.settingsTitleOnBoard,
                            icon: icon,
                            iconBackgroundColor: .systemTeal
                        ) {[weak self] in
                            UserDefaults.standard.setValue(false, forKey: "isNewUser")
                            self?.coordinator?.showOnboarding(completion: nil)
                        }),
                    .staticCell(
                        model: SettingsOption(
                            title: Strings.settingsTitleTricksAndTips,
                            icon: icon,
                            iconBackgroundColor: .systemBlue
                        ) { [weak self] in
                            guard let url = URL(string: Links.settingsTricksAndTipsUrl) else { return }
                            let vc = SFSafariViewController(url: url)
                            self?.showPage(vc: vc)
                        }),
                    .staticCell(
                        model: SettingsOption(
                            title: Strings.settingsTitleInstaSetup,
                            icon: icon,
                            iconBackgroundColor: .systemPurple
                        ) {[weak self] in
                            guard let self else { return }
                            let viewController = connectedInsights.makeViewController(for: .setupInfo)
                            showPage(vc: viewController)
                        })]))

        models.append(
            SettingsSection(
                title: Strings.settingsSectionTitleAboutUs,
                options: [
                    .staticCell(
                        model: SettingsOption(
                            title: Strings.settingsSectionTitleOurInstagram,
                            icon: icon,
                            iconBackgroundColor: .systemPink
                        ) {
                            AppURLHandler.openAppURL(
                                appURL: Links.settingsInstagramAppUrl,
                                webURL: Links.settingsInstagramWebUrl)
                        }),
                    
                    .staticCell(
                        model: SettingsOption(
                            title: Strings.settingsTitleShare,
                            icon: icon,
                            iconBackgroundColor: .systemGreen
                        ) { [weak self] in
                            self?.shareApp()
                        }),
                    
                    .staticCell(
                        model: SettingsOption(
                            title: Strings.settingsTitleRateAndReview,
                            icon: icon,
                            iconBackgroundColor: .systemYellow
                        ) { [weak self] in
                            self?.showReviewPopUp ()
                            //self?.writeReview()
                        }),
                    .staticCell(
                        model: SettingsOption(
                            title: Strings.settingsTitleContactUs,
                            icon: icon,
                            iconBackgroundColor: .systemOrange
                        ) {[weak self] in
                            self?.sendEmail()
                        })]))
        
        models.append(
            SettingsSection(
                title: Strings.settingsSectionTitleLegal,
                options: [
                    .staticCell(
                        model: SettingsOption(
                            title: Strings.settingsTitlePrivacy,
                            icon: icon,
                            iconBackgroundColor: .systemPurple
                        ) { [weak self] in
                            guard let url = URL(string: Links.settingsPrivacyPolicyUrl) else { return }
                            let vc = SFSafariViewController(url: url)
                            self?.showPage(vc: vc)
                        }),
                    
                    .staticCell(
                        model: SettingsOption(
                            title: Strings.settingsTitleTermsAndConditions,
                            icon: icon,
                            iconBackgroundColor: .systemYellow
                        ) { [weak self] in
                            guard let url = URL(string: Links.settingsTermsAndConditionsUrl) else { return }
                            let vc = SFSafariViewController(url: url)
                            self?.showPage(vc: vc)
                        }),
                    
                    .staticCell(
                        model: SettingsOption(
                            title: Strings.settingsTitleDisclaimer,
                            icon: icon,
                            iconBackgroundColor: .systemRed
                        ) { [weak self] in
                            guard let url = URL(string: Links.settingsDisclaimerUrl) else { return }
                            let vc = SFSafariViewController(url: url)
                            self?.showPage(vc: vc)
                        })
                ]))
        
    }
}

extension UIViewController {
    func showPage (vc: UIViewController) {
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true)
    }
}
