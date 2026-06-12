import UIKit

/// Thumbnail edge length for theme covers; fixed per device class.
let thumbnailDim: CGFloat = UIScreen.main.bounds.width <= 320 ? 115 : 132

extension UITableViewController {

    // MARK: - Reorder

    func addLongPressToTableView() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(onLongPressGesture(sender:)))
        longPress.minimumPressDuration = 0.8
        tableView.addGestureRecognizer(longPress)
    }

    @objc private func onLongPressGesture(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            tableView.isEditing = true
            setEditing(true, animated: false)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }

    // MARK: - Cell Height

    func getThemeListViewControllerCellHeight(
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

}
