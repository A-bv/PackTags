import UIKit

/// A table list presented over a cover image: the image sits behind the
/// content with a vignette and a stretch-on-overscroll bounce, and the
/// navigation bar fades in as the list scrolls up over it.
///
/// Subclasses call `setCoverImage(_:)`; insets, bar fade, and status-bar
/// style are owned here.
class CoverImageTableViewController: UITableViewController {

    private enum Constants {
        static let fadeDistance: CGFloat = 50
        static let estimatedExpandedBarHeight: CGFloat = 96
        static let scrollIndicatorPadding: CGFloat = 20
    }

    /// Corner radius where the list content meets the image.
    let coverCornerRadius: CGFloat = 22

    private var coverImageView = UIImageView()

    /// Negative while the bar floats over the image (light status bar),
    /// 0...1 while fading in over the content.
    private(set) var barAlpha: CGFloat = 0 {
        didSet { setNeedsStatusBarAppearanceUpdate() }
    }

    /// Set while a modal covers this screen so the status bar reads normally.
    var overridesStatusBarToDefault = false {
        didSet { setNeedsStatusBarAppearanceUpdate() }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if overridesStatusBarToDefault { return .default }
        return barAlpha < 0 ? .lightContent : .default
    }

    // MARK: - Cover image

    /// Installs `image` behind the list — rendered at display size with the
    /// vignette applied once — and pushes the content below the image's
    /// visible half.
    func setCoverImage(_ image: UIImage?) {
        tableView.backgroundColor = bkgdColor

        if let image {
            coverImageView = UIImageView(image: image.resized(to: coverDisplaySize))
        }
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        coverImageView.layer.frame = CGRect(origin: .zero, size: coverDisplaySize)

        let backgroundView = UIView()
        backgroundView.addSubview(coverImageView)
        tableView.backgroundView = backgroundView

        applyVignette()
        configureContentInsets()
    }

    private var coverDisplaySize: CGSize {
        CGSize(
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.bounds.height / 2 + coverCornerRadius)
    }

    private func configureContentInsets() {
        let halfScreen = UIScreen.main.bounds.height / 2
        let topInset = halfScreen - (Constants.estimatedExpandedBarHeight + statusBarHeight)
        let indicatorInset = (halfScreen - Constants.estimatedExpandedBarHeight)
            + coverCornerRadius + Constants.scrollIndicatorPadding

        tableView.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: indicatorInset, left: 0, bottom: 0, right: 0)
    }

    // MARK: - Scroll-driven bar fade

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        let fadeStart = currentNavBarHeight + 2 * statusBarHeight
        barAlpha = min(1, (offset + fadeStart) / Constants.fadeDistance)
        setNavBarTransparent(alpha: barAlpha)
        bounceCover(offset: offset)
    }

    private func bounceCover(offset: CGFloat) {
        let bounceThreshold = -UIScreen.main.bounds.height / 2
        if offset < bounceThreshold {
            coverImageView.frame.size.height = -offset + coverCornerRadius
        }
    }

    // MARK: - Vignette

    private static let vignetteContext = CIContext()

    /// Rendered once into a bitmap; a CIImage-backed image would re-run the
    /// filter on every draw while the bounce resizes the view per frame.
    private func applyVignette() {
        guard
            let img = coverImageView.image,
            let beginImage = CIImage(image: img),
            let filter = CIFilter(name: "CIVignetteEffect")
        else { return }

        filter.setValue(beginImage, forKey: kCIInputImageKey)
        filter.setValue(0.12, forKey: "inputIntensity")
        filter.setValue(0.2, forKey: "inputRadius")

        guard
            let output = filter.outputImage,
            let rendered = Self.vignetteContext.createCGImage(output, from: beginImage.extent)
        else { return }

        coverImageView.image = UIImage(cgImage: rendered, scale: img.scale, orientation: img.imageOrientation)
    }
}
