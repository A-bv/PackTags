import UIKit

final class SettingsCell: UITableViewCell {
    static let identifier = "SettingsCell"
    
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
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
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
        iconImageView.image = nil
        label.text = nil
        iconContainer.backgroundColor = nil
    }
    
    func configure(with model: SettingsOption) {
        label.text = model.title
        iconImageView.image = model.icon
        iconContainer.backgroundColor = model.iconBackgroundColor
    }
}
