//
//  ThemeListViewController.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 02.09.20.
//  Copyright © 2020 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

class ThemeListViewController: UITableViewController {

    weak var coordinator: (any ThemeCoordinatorProtocol)?
    var appSettings: any AppSettingsProtocol
    let viewModel: ThemeListViewModel

    init(style: UITableView.Style, appSettings: any AppSettingsProtocol, viewModel: ThemeListViewModel) {
        self.appSettings = appSettings
        self.viewModel = viewModel
        super.init(style: style)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let smartGButton = UIBarButtonItem()
    let settingsButton = UIBarButtonItem()
    let analyticsButton = UIBarButtonItem()

    override func viewWillAppear(_ animated: Bool) {
        setupNavigationBarAppearance()
        self.view.isUserInteractionEnabled = true //(fix p1)
        OperationQueue.main.addOperation {
            //(p1): fast clicks opens views multiple times
            self.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        configureTableView()
        viewModel.onUpdate = { [weak self] in
            OperationQueue.main.addOperation {
                self?.tableView.reloadData()
            }
        }
        viewModel.loadThemes()
        addFloatingButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handleNewUserFlow()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateRowHeightIfNeeded()
    }
}
