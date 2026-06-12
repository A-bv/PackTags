import UIKit

extension UIView {
    func roundTopCorners (radius: CGFloat) {
        layer.cornerRadius = radius
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
}
