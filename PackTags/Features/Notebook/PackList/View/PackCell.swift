import UIKit
import NeumorphicUIKit

final class PackCell: UITableViewCell, ReusableCellProtocol {
    private enum Strings {
        static let copyLabel = "Copy".localized()
    }
    
    private enum Constants {
        static let subButtonCornerRadius = CGFloat(5)
        static let subButtonFontSize = CGFloat(12)
        
        static let copyButtonShadowRadius = CGFloat(7)
        static let copyButtonFontSize = CGFloat(17)
        static let copyButtonRightPadding = CGFloat(30)
        static let copyButtonHeight = CGFloat(44)
        static let copyButtonWidth = CGFloat(80)
        static let copyButtonCornerRadius = copyButtonHeight/2
        
        static let value10 = CGFloat(10)
        
        static let value55 = CGFloat(55)
        
        static let cellLabelFontSize = CGFloat(19)
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()
    
    let cellLabel: UILabel = {
        let label = UILabel()
        label.font = UIFontMetrics(forTextStyle: .headline).scaledFont(
            for: UIFont.boldSystemFont(ofSize: Constants.cellLabelFontSize),
            maximumPointSize: 28)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var subButtonTapCallback: () -> Void = { }
    
    let subButton: UIButton = {
        let btn = UIButton()
        btn.titleLabel?.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(
            for: UIFont.boldSystemFont(ofSize: Constants.subButtonFontSize),
            maximumPointSize: 18)
        btn.titleLabel?.adjustsFontForContentSizeCategory = true
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.backgroundColor = UIColor.tagBadgeBlue
        btn.layer.cornerRadius = Constants.subButtonCornerRadius
        btn.clipsToBounds = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    var buttonTapCallback: () -> Void = { }
        
    private let copyButton: UIButton = {
        let fontSize = Constants.copyButtonFontSize
        let btn = UIButton(
            frame: CGRect(
                x: 0,
                y: 0,
                width: Constants.copyButtonWidth,
                height: Constants.copyButtonHeight))
        btn.setTitleColor(.customTextColor, for: .normal)
        btn.setTitle(Strings.copyLabel, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.titleLabel?.font = UIFont(name: "PingFangTC-Semibold", size: fontSize)
        btn.titleLabel?.adjustsFontForContentSizeCategory = true
        
        btn.neumorphism(
            cornerRadius: Constants.copyButtonCornerRadius,
            shadowRadius: Constants.copyButtonShadowRadius)
        
        return btn
    }()
    
    @objc private func startTap(sender: UIButton) {
        sender.addNeumorphicShadows(isButtonViewHeld: true, updateAfterShortDelay:true)
    }
    
    @objc private func didTapButton(sender: UIButton) {
        sender.addNeumorphicShadows(updateAfterShortDelay:true)
        buttonTapCallback()
    }
    
    @objc private func dragOutButton(sender: UIButton) {
        sender.addNeumorphicShadows()
    }
    
    @objc private func showMore(sender: UIButton) {
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        subButtonTapCallback()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (cell: PackCell, _) in
            cell.copyButton.addNeumorphicShadows()
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupUI() {
        self.contentView.backgroundColor = .colorBkgd

        containerView.addSubview(cellLabel)
        containerView.addSubview(subButton)
        self.contentView.addSubview(containerView)
        self.contentView.addSubview(copyButton)

        copyButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        copyButton.addTarget(self, action: #selector(startTap), for: .touchDown)
        copyButton.addTarget(self, action: #selector(dragOutButton(sender:)), for: .touchDragExit)

        subButton.addTarget(self, action: #selector(showMore), for: .touchUpInside)
        
        // ---------- containerView ----------
        
        containerView.centerYAnchor.constraint(equalTo:self.contentView.centerYAnchor).isActive = true
        containerView.leadingAnchor.constraint(
            equalTo:self.contentView.leadingAnchor,
            constant: Constants.copyButtonRightPadding).isActive = true
        
        containerView.trailingAnchor.constraint(
            equalTo:self.copyButton.leadingAnchor,
            constant: -Constants.value10).isActive = true
        containerView.heightAnchor.constraint(
            equalToConstant: Constants.value55).isActive = true
        
        // ---------- cellLabel ----------
        
        cellLabel.topAnchor.constraint(equalTo:self.containerView.topAnchor).isActive = true
        cellLabel.leadingAnchor.constraint(equalTo:self.containerView.leadingAnchor).isActive = true
        cellLabel.trailingAnchor.constraint(equalTo:self.containerView.trailingAnchor).isActive = true
        
        // ---------- subLabel ----------
        
        subButton.topAnchor.constraint(
            equalTo: self.cellLabel.bottomAnchor,
            constant: Constants.subButtonCornerRadius).isActive = true
        subButton.leadingAnchor.constraint(
            equalTo: self.containerView.leadingAnchor).isActive = true
        subButton.bottomAnchor.constraint(
            equalTo: self.containerView.bottomAnchor).isActive = true
        
        // ---------- copyButton ----------
        
        copyButton.widthAnchor.constraint(
            equalToConstant: Constants.copyButtonWidth).isActive = true
        copyButton.heightAnchor.constraint(
            equalToConstant: Constants.copyButtonHeight).isActive = true
        copyButton.trailingAnchor.constraint(
            equalTo:self.contentView.trailingAnchor,
            constant: -Constants.copyButtonRightPadding).isActive = true
        copyButton.centerYAnchor.constraint(
            equalTo:self.contentView.centerYAnchor).isActive = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.roundTopCorners(radius: 0)
        self.copyButton.addNeumorphicShadows()
    }
}
