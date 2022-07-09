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
        self.navigationController?.navigationBar.putShadow(put: false)
       
        configure()
        
        title = "Settings"
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
    }
    
    
    func configure () {
        
        let icon = UIImage(systemName: "gearshape")!
        
        self.tableView.backgroundColor = bkgdColor
      
        
        models.append(Section(title: "Account", options: [
            
            .staticCell(model:
            SettingsOption(title: "Instagram", icon: icon, iconBackgroundColor: .systemRed) { [weak self] in
                
                self?.setInstaUser ()
                
            }),
            
            .staticCell(model:
            SettingsOption(title: "Facebook Login", icon: icon, iconBackgroundColor: .systemOrange) { [weak vc = self] in
                
                let vwc = FBLoginVC()
                vwc.modalPresentationStyle = .overFullScreen
                vwc.modalTransitionStyle = .crossDissolve
                vc?.present(vwc, animated: true, completion: nil)
                
            })
        ]))
        
        models.append(Section(title: "Hastags", options: [
            
            .staticCell(model:
            SettingsOption(title: "Quantity Per Pack", icon: icon, iconBackgroundColor: .systemPink) { [weak vc = self] in
        
                let vwc = QuantityPickerVC()
                vwc.modalPresentationStyle = .overFullScreen
                vwc.modalTransitionStyle = .crossDissolve
                vc?.present(vwc, animated: true, completion: nil)
                
                
            }),
            
            .switchCell(model:
                            SettingsSwitchOption(title: "Save & Shuffle", icon: icon, iconBackgroundColor: .systemYellow, handler: {
            
                }, isOn: false)),
            
            .switchCell(model:
                            SettingsSwitchOption(title: "Keep Packs Order", icon: icon, iconBackgroundColor: .systemRed, handler: {
            
                }, isOn: false)),
            
        ]))
        
        models.append(Section(title: "Help", options: [
            
            .staticCell(model:
            SettingsOption(title: "On Board", icon: icon, iconBackgroundColor: .systemTeal) {[weak self] in
                
                UserDefaults.standard.setValue(false, forKey: "isNewUser")
                self?.showOnboardingScreen()
            }),
            
            .staticCell(model:
            SettingsOption(title: "Tricks & Tips", icon: icon, iconBackgroundColor: .systemBlue) { [weak self] in
                self?.showTricksPage()
            }),
            
            .staticCell(model:
            SettingsOption(title: "Instagram Setup", icon: icon, iconBackgroundColor: .systemPurple) {[weak vc = self] in
                
                let vwc = IgApiSetupVC()
                vwc.modalPresentationStyle = .overFullScreen
                vwc.modalTransitionStyle = .crossDissolve
                vc?.present(vwc, animated: true, completion: nil)
                
            })
            
        ]))
        
        models.append(Section(title: "About us", options: [
            
            .staticCell(model:
            SettingsOption(title: "Our Instagram", icon: icon, iconBackgroundColor: .systemPink) {
                [weak self] in
                self?.openAppURL(appURL: "instagram://user?username=packtags.app", webURL: "https://instagram.com/packtags.app", completion: {_ in})
            }),
            
            .staticCell(model:
            SettingsOption(title: "Share", icon: icon, iconBackgroundColor: .systemGreen) { [weak self] in
                
                self?.shareApp()
                
            }),
            
            .staticCell(model:
             SettingsOption(title: "Rate & Review", icon: icon, iconBackgroundColor: .systemYellow) { [weak self] in
    
                    self?.showReviewPopUp ()
                    //self?.writeReview()
                 
            }),
            
            
            .staticCell(model:
            SettingsOption(title: "Contact Us", icon: icon, iconBackgroundColor: .systemOrange) {[weak self] in
                self?.sendEmail()
            })
        ]))
        
        models.append(Section(title: "Legal", options: [
            .staticCell(model:
                            SettingsOption(title: "Privacy", icon: icon, iconBackgroundColor: .systemPurple) { [weak self] in
                                
                if let url = URL(string: "https://sites.google.com/view/packtags-privacy-policy/accueil") {
                                    
                    let vc = SFSafariViewController(url: url)
                    vc.modalTransitionStyle = .crossDissolve
                    vc.modalPresentationStyle = .overFullScreen
                    self?.present(vc, animated: true)
                                    
                }
            }),
            
            .staticCell(model:
                            SettingsOption(title: "Terms & Conditions", icon: icon, iconBackgroundColor: .systemYellow) { [weak self] in
                                
                if let url = URL(string: "https://sites.google.com/view/packtagstc/accueil") {
                                                    
                let vc = SFSafariViewController(url: url)
                    vc.modalTransitionStyle = .crossDissolve
                    vc.modalPresentationStyle = .overFullScreen
                    self?.present(vc, animated: true)
                                                    
                }
            }),
            
            .staticCell(model:
                            SettingsOption(title: "Disclaimer", icon: icon, iconBackgroundColor: .systemRed) { [weak self] in
                                
                if let url = URL(string: "https://sites.google.com/view/packtagsdisclaimer/accueil") {
                                                                    
                    let vc = SFSafariViewController(url: url)
                    vc.modalTransitionStyle = .crossDissolve
                    vc.modalPresentationStyle = .overFullScreen
                    self?.present(vc, animated: true)
    
                }
                
            })
        ]))
        
    }
    
    //MARK: -
    
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

extension UIViewController {
    func showTricksPage () {
        if let url = URL(string: "https://sites.google.com/view/packtags-tricks-tips/accueil") {
            
            let vc = SFSafariViewController(url: url)
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true)
            
         }
    }
}
