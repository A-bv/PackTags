import UIKit

extension CALayer {
    func shadowPerformanceBoost() {
        self.shouldRasterize = true
        self.rasterizationScale = UIScreen.main.scale
    }
}
