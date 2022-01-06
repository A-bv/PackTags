//
//  ThemeVC+slideUpMenu.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 22/01/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

//MARK: - MENU FOR IOS < 14
extension ThemeVC{
    
    func initMenu () {
        tableViewMenu1.isScrollEnabled = true
        tableViewMenu1.delegate = self
        tableViewMenu1.dataSource = self
        tableViewMenu1.register(CustomTableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    func showMenu() {
        
        let window = UIApplication.shared.keyWindow
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        transparentView.frame = self.view.frame
        window?.addSubview(transparentView)
        
        let screenSize = UIScreen.main.bounds.size
        tableViewMenu1.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: menu1Height)
        window?.addSubview(tableViewMenu1)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onClickTransparentView))
        transparentView.addGestureRecognizer(tapGesture)
        
        transparentView.alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0.5
            self.tableViewMenu1.frame = CGRect(x: 0, y: screenSize.height - self.menu1Height, width: screenSize.width, height: self.menu1Height)
        }, completion: nil)
        
    }
    
    @objc private func onClickTransparentView() {
        let screenSize = UIScreen.main.bounds.size

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0
            self.tableViewMenu1.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: self.menu1Height)
        }, completion: nil)
    }
    
}

extension ThemeVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buttonLabelArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? CustomTableViewCell else {fatalError("Unable to deque cell")}
        cell.lbl.text = buttonLabelArray[indexPath.row]
        cell.settingImage.image = UIImage(named: buttonIconsArray[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)
        perform(#selector(onClickTransparentView))
        perform(buttonSelectorArray[indexPath.row], with: nil)
    }
}










