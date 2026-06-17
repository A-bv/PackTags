import UIKit

final class SettingsSwitchCell: UITableViewCell, ReusableCell {
    private enum Constants {
        static let cornerRadius: CGFloat = 8
        static let containerX: CGFloat = 15
        static let containerY: CGFloat = 6
        static let iconImageViewSizeRatio: CGFloat = 1.5
        static let labelXOffset: CGFloat = 25
        static let labelWidthOffset: CGFloat = 20
        static let sizeOffset: CGFloat = 12
    }
    
    private var onToggle: ((Bool) -> Void)?

    private let iconContainer: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = Constants.cornerRadius
        view.layer.masksToBounds = true
        return view
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()
    
    private let mySwitch: UISwitch = {
        let mySwitch = UISwitch(frame: .zero)
        mySwitch.onTintColor = .systemGreen
        return mySwitch
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "gearshape")
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        contentView.addSubview(iconContainer)
        contentView.addSubview(iconImageView)
        
        contentView.clipsToBounds = true
        accessoryView = mySwitch
        mySwitch.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size = contentView.frame.size.height - Constants.sizeOffset
        let imageSize = size / Constants.iconImageViewSizeRatio
        let labelX = Constants.labelXOffset + size
        let labelWidth = contentView.frame.size.width - Constants.labelWidthOffset - size
        let labelHeight = contentView.frame.size.height

        iconContainer.frame = CGRect(
            x: Constants.containerX,
            y: Constants.containerY,
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
        mySwitch.isOn = false
        onToggle = nil
    }
    
    func configure(with model: SettingsSwitchOption) {
        label.text = model.title
        iconContainer.backgroundColor = model.iconBackgroundColor
        mySwitch.isOn = model.isOn
        onToggle = model.onToggle
    }

    @objc private func valueChanged(sender: UISwitch) {
        onToggle?(sender.isOn)
    }
}
