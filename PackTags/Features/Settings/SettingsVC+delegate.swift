//
//  SettingsVC+delegate.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 13.11.22.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

extension SettingsVC: UITableViewDelegate, UITableViewDataSource {
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
                withIdentifier: SettingsSwitchCell.identifier,
                for: indexPath
            ) as? SettingsSwitchCell else {
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
