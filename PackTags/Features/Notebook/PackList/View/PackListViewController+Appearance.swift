import UIKit

// Fade Navigation Bar
extension PackListViewController {
    //Scroll operations
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        updateAlphaForNavBarOpacity(offset: offset)
        setNavBarOpacityAndColors()
        uiiv.bounceImage(offset: offset, constant: cR)
    }
}
    
// Navigation Bar Color and opacity variations
extension PackListViewController {
    private func setNavBarOpacityAndColors() {
        self.setNavBarTransparent(alpha: alpha)
    }
    
    private func updateAlphaForNavBarOpacity(offset: CGFloat) {
        let pos = currentNavBarHeight + 2 * statusBarHeight
        let denominator: CGFloat = 50 // Offset threshold
        let value = (offset + pos) / denominator
        alpha = min(1, value)
    }
}

// Status Bar color
extension PackListViewController {
    override var preferredStatusBarStyle : UIStatusBarStyle {
        if resetStatusBarColor {
            return .default
        } else {
            return  alpha < 0 ? .lightContent : .default
        }
    }
}

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
    
    private func updateTableViewBackgroundImage() {
        guard let imageData = viewModel.theme.image, let image = UIImage(data: imageData) else { return }
        // Themes saved before covers were resized at save time can carry
        // multi-megapixel originals; render at display size so scrolling
        // never pushes a huge bitmap around.
        let displaySize = CGSize(
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.bounds.height / 2 + cR)
        uiiv = UIImageView(image: image.resized(to: displaySize))
    }
}

extension PackListViewController {
    func TVinset () {
        let demiS = UIScreen.main.bounds.height/2
        let navheight = 96.0 // TODO: Get max height constant
        let insetPadding = 20.0
        
        let topInset = demiS - (navheight + statusBarHeight)
        let topInset2 = (demiS - navheight) + cR + insetPadding

        tableView.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: topInset2, left: 0, bottom: 0, right: 0)
    }
}
