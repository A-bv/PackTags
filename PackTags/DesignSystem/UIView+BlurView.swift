import UIKit

extension UIView {
    func applyBlur() {
        if !UIAccessibility.isReduceTransparencyEnabled {
            self.backgroundColor = .clear

            let  blurEffect = UIBlurEffect(style: .regular)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = self.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            self.addSubview(blurEffectView)
        } else {
            self.backgroundColor = .systemBackground
        }
    }
}
