//
//  PackController.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 26.10.20.
//  Copyright © 2020 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

class PackListViewController: UITableViewController {

    weak var coordinator: (any ThemeCoordinatorProtocol)?
    let viewModel: PackListViewModel

    init(style: UITableView.Style, viewModel: PackListViewModel) {
        self.viewModel = viewModel
        super.init(style: style)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let composeButton = UIBarButtonItem()
    let instaButton = UIBarButtonItem()

    var packs: [String] { viewModel.packs }
    
    let pasteboard = UIPasteboard.general
    var chosenPack = String()
    
    //Image header
    var uiiv = UIImageView()
    
    //Corner radius table view
    let cR = CGFloat(22)
    
    // Status Bar color && Navigation Bar
    var alpha = CGFloat(0) {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    var resetStatusBarColor = false {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    // MARK: - Interface
    override func viewDidLoad(){
        super.viewDidLoad()
        self.title = viewModel.theme.name

        composeButton.image = UIImage(named: "EditPic")
        composeButton.target = self
        composeButton.action = #selector(didTapCompose)

        instaButton.image = UIImage(named: "insta2")
        instaButton.target = self
        instaButton.action = #selector(didTapInstagram)

        navigationItem.rightBarButtonItems = [composeButton, instaButton]

        tableView.register(PackCell.self, forCellReuseIdentifier: "PackCell")
        tableView.rowHeight = 81

        loadPacks() //load
        TVinset()
        setupTableViewBackgroundImage()
        tableView.backgroundColor = bkgdColor

        self.setNavBarTransparent(alpha: alpha)
    }

    @objc func didTapInstagram() {
        statusAutoDirectToInstagram()
    }
}
