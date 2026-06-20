import UIKit

extension CALayer {
    func shadowPerformanceBoost() {
        self.shouldRasterize = true
        self.rasterizationScale = UITraitCollection.current.displayScale
    }
}
