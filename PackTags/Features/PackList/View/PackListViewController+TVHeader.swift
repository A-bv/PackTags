import UIKit

extension PackListViewController {
    func setupTableViewBackgroundImage() {
        updateTableViewBackgroundImage()
        uiiv.contentMode = .scaleAspectFill
        uiiv.clipsToBounds = true
        uiiv.layer.frame = CGRect(
            x: 0,
            y: 0,
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.bounds.height / 2 + cR)
        
            let tableViewBackgroundView = UIView()
            tableViewBackgroundView.addSubview(self.uiiv)
            tableView.backgroundView = tableViewBackgroundView
            uiiv.putFilter()
    }
    
    func updateTableViewBackgroundImage() {
        if let imageData = viewModel.theme.image, let image = UIImage(data: imageData) {
            uiiv = UIImageView(image: image)
        }
    }
}

extension PackListViewController {
    func TVinset () {
        let demiS = UIScreen.main.bounds.height/2
        let navheight = 96.0 // TODO: Get max height constant
        let insetPadding = 20.0
        
        let topInset = demiS - (navheight + statusBarHeight)
        let topInset2 = (demiS - navheight) + cR + insetPadding
        
        tableView.applyTableViewTopInset(tableViewTopInset: topInset, scrollIndicatorsTopInset: topInset2)
    }
}

extension UITableView {
    func applyTableViewTopInset(
        tableViewTopInset: CGFloat,
        scrollIndicatorsTopInset: CGFloat
    ) {
        self.contentInset = UIEdgeInsets(
            top: CGFloat(tableViewTopInset), left: 0, bottom: 0, right: 0)
        
        self.scrollIndicatorInsets = UIEdgeInsets(
            top: scrollIndicatorsTopInset, left: 0, bottom: 0, right: 0)
    }
}
