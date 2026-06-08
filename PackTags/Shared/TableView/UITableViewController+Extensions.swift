import UIKit

public var thumbnailDim = CGFloat(140.00)

extension UITableViewController {

    // MARK: - Reorder

    func addLongPressToTableView() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(onLongPressGesture(sender:)))
        longPress.minimumPressDuration = 0.8
        tableView.addGestureRecognizer(longPress)
    }

    @objc func onLongPressGesture(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            tableView.isEditing = true
            setEditing(true, animated: false)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }

    // MARK: - Cell Height

    func getThemeTableViewControllerCellHeight(
        navigationBarHeight: CGFloat,
        paddingBottom: CGFloat
    ) -> CGFloat {
        let screenHeight = view.frame.height
        let cellMinimumHeight: CGFloat = 164
        var cellHeight = (screenHeight - paddingBottom - navigationBarHeight) / 4
        if cellHeight <= cellMinimumHeight {
            cellHeight = (screenHeight - navigationBarHeight) / 3
        }
        return cellHeight
    }

    // MARK: - Thumbnail Dimensions

    func setThemeTableViewControllerThumbnailsDimension() {
        let iPhoneSEWidth: CGFloat = 320
        thumbnailDim = UIScreen.main.bounds.width <= iPhoneSEWidth ? 115 : 132
    }
}
