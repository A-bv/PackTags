import UIKit
import NeumorphicUIKit

final class ThemeCell: UITableViewCell, ReusableCellProtocol {
    private enum Constants {
        /// Thumbnail edge length for theme covers; fixed per device class.
        @MainActor static let thumbnailDim: CGFloat = UIScreen.main.bounds.width <= 320 ? 115 : 132
        static let padding5 = CGFloat(5)
        static let supportingViewShadowRadius = CGFloat(5)
        static let themeImageViewCornerRadius = CGFloat(10)
        static let supportingViewCornerRadius = CGFloat(15)
        static let nameLabelFontSize = CGFloat(19)
        @MainActor static let thumbnailDimReducedBy10 = thumbnailDim - CGFloat(10)
        static let padding20 = CGFloat(20)
        static let themeImageViewLeadingPadding = CGFloat(30)
        static let containerViewHeight = CGFloat(40)
    }

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()

    let themeImageView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        img.translatesAutoresizingMaskIntoConstraints = false
        img.layer.cornerRadius = Constants.themeImageViewCornerRadius
        img.clipsToBounds = true
        return img
    }()

    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFontMetrics(forTextStyle: .headline).scaledFont(
            for: UIFont.boldSystemFont(ofSize: Constants.nameLabelFontSize),
            maximumPointSize: 28)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let supportingView: UIView = {
        let view = UIView()
        view.frame = CGRect(
            x: 0,
            y: 0,
            width: Constants.thumbnailDim,
            height: Constants.thumbnailDim)
        view.neumorphism(
            cornerRadius: Constants.supportingViewCornerRadius,
            shadowRadius: Constants.supportingViewShadowRadius)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }


    private func setupUI() {
        self.contentView.backgroundColor = .colorBkgd

        // The row is one VoiceOver element labelled with the theme name (set per-row);
        // the cover image is decorative and shouldn't be focused on its own.
        isAccessibilityElement = true
        accessibilityTraits = .button
        themeImageView.isAccessibilityElement = false

        containerView.addSubview(nameLabel)
        self.contentView.addSubview(containerView)
        self.contentView.addSubview(supportingView)
        self.contentView.addSubview(themeImageView)

        // ---------- themeImageView ----------

        themeImageView.centerYAnchor.constraint(equalTo:self.contentView.centerYAnchor).isActive = true
        themeImageView.leadingAnchor.constraint(
            equalTo: self.contentView.leadingAnchor,
            constant: Constants.themeImageViewLeadingPadding
        ).isActive = true
        themeImageView.widthAnchor.constraint(
            equalToConstant: Constants.thumbnailDimReducedBy10
        ).isActive = true
        themeImageView.heightAnchor.constraint(
            equalToConstant: Constants.thumbnailDimReducedBy10
        ).isActive = true

        // ---------- supporting View ----------

        supportingView.leadingAnchor.constraint(
            equalTo:themeImageView.leadingAnchor,
            constant: -Constants.padding5
        ).isActive = true
        supportingView.topAnchor.constraint(
            equalTo:themeImageView.topAnchor,
            constant: -Constants.padding5
        ).isActive = true

        // ---------- containerView ----------

        containerView.centerYAnchor.constraint(equalTo:self.contentView.centerYAnchor).isActive = true
        containerView.heightAnchor.constraint(
            equalToConstant: Constants.containerViewHeight
        ).isActive = true
        containerView.leadingAnchor.constraint(
            equalTo: self.themeImageView.trailingAnchor,
            constant: Constants.padding20
        ).isActive = true
        containerView.trailingAnchor.constraint(
            equalTo:self.contentView.trailingAnchor,
            constant: -Constants.padding20
        ).isActive = true

        // ---------- nameLabel ----------

        nameLabel.topAnchor.constraint(equalTo:self.containerView.topAnchor).isActive = true
        //
        if UIDevice.current.userInterfaceIdiom == .pad {
            nameLabel.centerXAnchor.constraint(equalTo:self.centerXAnchor).isActive = true
        } else {
            nameLabel.centerXAnchor.constraint(equalTo:self.containerView.centerXAnchor).isActive = true
        }
    }
}
