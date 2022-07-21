//
//  SlideUpMenuViewController.swift
//  SlideUpAnimation
//
//  Created by Alexandre Bevilacqua on 28.05.22.
//  Copyright © 2022 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

class SlideUpMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private enum Strings {
        static let themeMenuEditName = "Edit name"
        static let themeMenuEditPicture = "Edit name"
        static let themeMenuSearchHashtags = "Search hashtags"
        static let themeMenuShuffleHashtags = "Shuffle hashtags"
    }
    
    var buttonLabelArray = [
        Strings.themeMenuEditName,
        Strings.themeMenuEditName,
        Strings.themeMenuSearchHashtags,
        Strings.themeMenuShuffleHashtags]
    
    var buttonIconsArray = [
        "titleTag",
        "imageLib",
        "mglassIcon",
        "shuffle"]
    
    var tableView: UITableView {
        let tableView = UITableView()
        tableView.isScrollEnabled = false
        tableView.register(SlideUpMenuTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }
    
    var delegate: SlideUpMenuDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
 
        let pad = SlideUpMenuConstants.tablePadding
        
        let tableView = tableView
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: pad).isActive = true
        tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -pad).isActive = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buttonLabelArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? SlideUpMenuTableViewCell else {fatalError("Unable to deque cell")}
        cell.lbl.text = buttonLabelArray[indexPath.row]
        cell.settingImage.image = UIImage(named: buttonIconsArray[indexPath.row])!
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SlideUpMenuConstants.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.tableRowDidSelect(indexPath)
    }
}
