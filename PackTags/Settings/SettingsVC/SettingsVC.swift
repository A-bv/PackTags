//
//  SettingsVC.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 17/03/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//
import UIKit
import SafariServices

struct Section {
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

class SettingsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    deinit {
        print("deinit")
    }
    
    private enum Strings {
        static let settingsTitle = "Settings"
        static let settingsSectionTitleAccount = "Account"
        static let settingsTitleInstagram = "Instagram"
        static let settingsTitleFacebookLogin = "Facebook Login"
        static let settingsSectionTitleHashtags = "Hastags"
        static let settingsTitleQuantityPerPack = "Quantity Per Pack"
        static let settingsTitleSaveAndShuffle = "Save & Shuffle"
        static let settingsTitleKeepPackOrder = "Keep Packs Order"
        static let settingsSectionTitleHelp = "Help"
        static let settingsTitleOnBoard = "On Board"
        static let settingsTitleTricksAndTips = "Tricks & Tips"
        static let settingsTitleInstaSetup = "Instagram Setup"
        static let settingsSectionTitleAboutUs = "About us"
        static let settingsSectionTitleOurInstagram = "Our Instagram"
        static let settingsTitleShare = "Share"
        static let settingsTitleRateAndReview = "Rate & Review"
        static let settingsTitleContactUs = "Contact Us"
        static let settingsSectionTitleLegal = "Legal"
        static let settingsTitlePrivacy = "Privacy"
        static let settingsTitleTermsAndConditions = "Terms & Conditions"
        static let settingsTitleDisclaimer = "Disclaimer"
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
        table.register(SettingsCell.self,
                       forCellReuseIdentifier: SettingsCell.identifier)
        table.register(SettingsCell2.self,
                       forCellReuseIdentifier: SettingsCell2.identifier)
        return table
    }()
    
    var models = [Section]()
    
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
            Section(
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
                            let vwc = FBLoginVC()
                            self?.showPage(vc: vwc)
                        })]))
        
        models.append(
            Section(
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
            Section(
                title: Strings.settingsSectionTitleHelp,
                options: [
                    .staticCell(
                        model: SettingsOption(
                            title: Strings.settingsTitleOnBoard,
                            icon: icon,
                            iconBackgroundColor: .systemTeal
                        ) {[weak self] in
                            UserDefaults.standard.setValue(false, forKey: "isNewUser")
                            self?.showOnboardingScreen()
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
                            let vc = IgApiSetupVC()
                            self?.showPage(vc: vc)
                        })]))
        
        models.append(
            Section(
                title: Strings.settingsSectionTitleAboutUs,
                options: [
                    .staticCell(
                        model: SettingsOption(
                            title: Strings.settingsSectionTitleOurInstagram,
                            icon: icon,
                            iconBackgroundColor: .systemPink
                        ) { [weak self] in
                            self?.openAppURL(
                                appURL: Links.settingsInstagramAppUrl,
                                webURL: Links.settingsInstagramWebUrl,
                                completion: {_ in})
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
            Section(
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

extension SettingsVC {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = models[section]
        return section.title
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models[section].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.section].options[indexPath.row]
        switch model.self{//mod
        case .staticCell(let model):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SettingsCell.identifier,
                for: indexPath
            ) as? SettingsCell else {
                return UITableViewCell()
            }
            cell.configure(with: model)
            cell.backgroundColor = UIColor.systemBackground
            return cell
            
            //mod --
        case .switchCell(let model):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SettingsCell2.identifier,
                for: indexPath
            ) as? SettingsCell2 else {
                return UITableViewCell()
            }
            cell.name = model.title
            cell.configure(with: model)
            
            cell.backgroundColor = UIColor.systemBackground
            
            return cell
            // --
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let type = models[indexPath.section].options[indexPath.row]
        //mod --
        switch type.self{
        case .staticCell(let model):
            model.handler()
        case .switchCell(let model):
            model.handler()
        }
        //--
    }
}
