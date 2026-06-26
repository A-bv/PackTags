import UIKit

final class SettingsCell: UITableViewCell, ReusableCellProtocol {
    private enum Constants {
        static let iconContainerX: CGFloat = 15
        static let iconContainerY: CGFloat = 6
        static let iconContainerCornerRadius: CGFloat = 8
        static let iconImageViewTintColor = UIColor.white
        static let iconImageViewSizeRatio: CGFloat = 1.5
        static let labelXOffset: CGFloat = 25
        static let labelWidthOffset: CGFloat = 20
        static let contentViewHeightOffset: CGFloat = 12
        static let disclosureIndicatorType: UITableViewCell.AccessoryType = .disclosureIndicator
        // Default UILabel body size; scaled for Dynamic Type, capped so it stays
        // within the fixed row height (matching PackCell / ThemeCell).
        static let labelFontSize: CGFloat = 17
        static let labelMaxFontSize: CGFloat = 24
    }
    
    private let iconContainer: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = Constants.iconContainerCornerRadius
        view.layer.masksToBounds = true
        return view
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFontMetrics(forTextStyle: .body).scaledFont(
            for: UIFont.systemFont(ofSize: Constants.labelFontSize),
            maximumPointSize: Constants.labelMaxFontSize)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "gearshape")
        imageView.tintColor = Constants.iconImageViewTintColor
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        contentView.addSubview(iconContainer)
        contentView.addSubview(iconImageView)

        contentView.clipsToBounds = true
        accessoryType = Constants.disclosureIndicatorType
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size = contentView.frame.size.height - Constants.contentViewHeightOffset
        let imageSize = size / Constants.iconImageViewSizeRatio
        let labelX = Constants.labelXOffset + size
        let labelWidth = contentView.frame.size.width - Constants.labelWidthOffset - size
        let labelHeight = contentView.frame.size.height
        
        iconContainer.frame = CGRect(
            x: Constants.iconContainerX,
            y: Constants.iconContainerY,
            width: size,
            height: size)

        iconImageView.frame = CGRect(
            x: (size - imageSize) / 2,
            y: (size - imageSize) / 2,
            width: imageSize,
            height: imageSize)

        iconImageView.center = iconContainer.center

        label.frame = CGRect(
            x: labelX,
            y: 0,
            width: labelWidth,
            height: labelHeight)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        iconContainer.backgroundColor = nil
    }

    func configure(with model: SettingsOptionModel) {
        label.text = model.title
        iconContainer.backgroundColor = model.iconBackgroundColor

        // VoiceOver: read the row as a button (it navigates), not bare static text.
        isAccessibilityElement = true
        accessibilityLabel = model.title
        accessibilityTraits = .button
    }
}
