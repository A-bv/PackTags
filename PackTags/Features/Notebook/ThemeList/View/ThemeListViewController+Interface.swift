import UIKit
import SwiftUI

extension ThemeListViewController {
    enum Constants {
        static let tableViewBottomPadding = CGFloat(14)
    }

    func updateLogo() {
        navigationItem.titleView = DarkMode.isDarkMode() ?
        UIImageView(image: UIImage(named: "logoBlack")) :
        UIImageView(image: UIImage(named: "logoWhite"))
    }
    
    func configureNavBar () {
        settingsButton.image = UIImage(systemName: "gearshape.2.fill")
        settingsButton.target = self
        settingsButton.action = #selector(didTapSettings)
        analyticsButton.image = UIImage(systemName: "chart.line.uptrend.xyaxis.circle.fill")
        analyticsButton.target = self
        analyticsButton.action = #selector(didTapAnalytics)
        smartGButton.image = UIImage(systemName: "number.circle.fill")
        smartGButton.target = self
        smartGButton.action = #selector(didTapSmartG)

        navigationController?.navigationBar.putShadow()
        navigationItem.leftBarButtonItem = settingsButton
        navigationItem.rightBarButtonItems = [analyticsButton, smartGButton]
        updateLogo()
    }
    
    func configureTableView () {
        self.tableView.backgroundColor = bkgdColor
        self.tableView.register(ThemeCell.self, forCellReuseIdentifier: "ThemeCell")
        self.setThemeListViewControllerThumbnailsDimension()
        self.addLongPressToTableView() // reorder cells
    }

    func updateRowHeightIfNeeded() {
        let navigationBarHeight = currentNavBarHeight + statusBarHeight
        let newHeight = getThemeListViewControllerCellHeight(
            navigationBarHeight: navigationBarHeight,
            paddingBottom: Constants.tableViewBottomPadding)
        if newHeight > 0, tableView.rowHeight != newHeight {
            tableView.rowHeight = newHeight
            tableView.reloadData()
        }
    }
    
    func addFloatingButton() {
        let button = FloatingButtonFactory.createFloatingButton(onView: self.view)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
}
