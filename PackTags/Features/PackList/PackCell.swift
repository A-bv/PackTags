//
//  Pack.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 26.10.20.
//  Copyright © 2020 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

class PackCell: UITableViewCell {
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
        static let profileImageViewCornerRadius = CGFloat(35)
    }
    
    let containerView:UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()
    
    let profileImageView:UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill 
        img.translatesAutoresizingMaskIntoConstraints = false // enable autolayout
        img.layer.cornerRadius = Constants.profileImageViewCornerRadius
        img.clipsToBounds = true
        return img
    }()
    
    let cellLabel:UILabel = {
        let label = UILabel()
        let fontSize = Constants.cellLabelFontSize
        label.font = UIFont.boldSystemFont(ofSize: fontSize)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var subButtonTapCallback: () -> ()  = { }
    
    let subButton :UIButton = {
        let btn = UIButton()
        let fontSize = Constants.subButtonFontSize
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: fontSize)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        btn.layer.cornerRadius = Constants.subButtonCornerRadius
        btn.clipsToBounds = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    var buttonTapCallback: () -> Void = { }
        
    let copyButton: UIButton = {
        let fontSize = Constants.copyButtonFontSize
        let btn = UIButton(
            frame: CGRect(
                x: 0,
                y: 0,
                width: Constants.copyButtonWidth,
                height: Constants.copyButtonHeight))
        btn.setTitleColor(customTextColor, for: .normal)
        btn.setTitle(Strings.copyLabel, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.titleLabel?.font = UIFont(name: "PingFangTC-Semibold", size: fontSize)
        btn.titleLabel?.adjustsFontForContentSizeCategory = true
        
        btn.neumorphism(
            cornerRadius: Constants.copyButtonCornerRadius,
            shadowRadius: Constants.copyButtonShadowRadius)
        
        return btn
    }()
    
    @objc func startTap(sender: UIButton) {
        sender.addNeumorphicShadows(isButtonViewHeld: true, updateAfterShortDelay:true)
    }
    
    @objc func didTapButton(sender: UIButton) {
        sender.addNeumorphicShadows(updateAfterShortDelay:true)
        buttonTapCallback()
    }
    
    @objc func dragOutButton(sender: UIButton) {
        sender.addNeumorphicShadows()
        buttonTapCallback()
    }
    
    @objc func showMore(sender: UIButton) {
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        subButtonTapCallback()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        self.contentView.backgroundColor = bkgdColor

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
