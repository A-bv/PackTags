//
//  Pack.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 26.10.20.
//  Copyright © 2020 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

class PackCell: UITableViewCell {
    
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
        img.layer.cornerRadius = 35
        img.clipsToBounds = true
        return img
    }()
    
    let nameLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 19)
        //label.font = UIFont(name: "PingFangTC-Semibold", size:19)
        label.textColor = labelColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var subButtonTapCallback: () -> ()  = { }
    
    let subButton :UIButton = {
        let btn = UIButton()
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        btn.layer.cornerRadius = 5
        btn.clipsToBounds = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.showsTouchWhenHighlighted = true
        return btn
    }()
    
    var buttonTapCallback: () -> ()  = { }
        
    let copyButton: UIButton = {
        let cornerRadius: CGFloat = 22
        let shadowRadius: CGFloat = 7
        
        let btn = UIButton(frame:CGRect(x: 0, y: 0, width: 80, height: 44))
        btn.setTitleColor(customTextColor, for: .normal)
        btn.setTitle("Copy", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.titleLabel?.font = UIFont(name: "PingFangTC-Semibold", size:17)
        btn.titleLabel?.adjustsFontForContentSizeCategory = true
        
        btn.neumorphism(cornerRadius: cornerRadius, shadowRadius: shadowRadius)
        
        return btn
    }()
    
    @objc func startTap(sender: UIButton) {
        sender.updateNeumorphicButton(hold: true, delay:true)
    }
    
    @objc func didTapButton(sender: UIButton) {
        sender.updateNeumorphicButton(hold: false, delay:true)
        buttonTapCallback()
    }
    
    @objc func dragOutButton(sender: UIButton) {
        sender.updateNeumorphicButton(hold: false, delay:false)
        buttonTapCallback()
    }
    
    @objc func showMore(sender: UIButton) {
        if #available(iOS 13.0, *) {
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        } else {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
        subButtonTapCallback()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = bkgdColor
        
        containerView.addSubview(nameLabel)
        containerView.addSubview(subButton)
        self.contentView.addSubview(containerView)
        self.contentView.addSubview(copyButton)
        
        copyButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        copyButton.addTarget(self, action: #selector(startTap), for: .touchDown)
        copyButton.addTarget(self, action: #selector(dragOutButton(sender:)), for: .touchDragExit)
        
        subButton.addTarget(self, action: #selector(showMore), for: .touchUpInside)
        
        // ---------- containerView ----------
        
        containerView.centerYAnchor.constraint(equalTo:self.contentView.centerYAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo:self.contentView.leadingAnchor, constant:30).isActive = true
        
        containerView.trailingAnchor.constraint(equalTo:self.copyButton.leadingAnchor, constant:-10).isActive = true
        containerView.heightAnchor.constraint(equalToConstant:55).isActive = true
        
        // ---------- nameLabel ----------
        
        nameLabel.topAnchor.constraint(equalTo:self.containerView.topAnchor).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo:self.containerView.leadingAnchor).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo:self.containerView.trailingAnchor).isActive = true
        
        // ---------- subLabel ----------
        
        subButton.topAnchor.constraint(equalTo:self.nameLabel.bottomAnchor, constant: 5).isActive = true
        subButton.leadingAnchor.constraint(equalTo:self.containerView.leadingAnchor).isActive = true
        subButton.bottomAnchor.constraint(equalTo:self.containerView.bottomAnchor).isActive = true
        
        // ---------- copyButton ----------
        
        copyButton.widthAnchor.constraint(equalToConstant:80).isActive = true
        copyButton.heightAnchor.constraint(equalToConstant:44).isActive = true
        copyButton.trailingAnchor.constraint(equalTo:self.contentView.trailingAnchor, constant:-30).isActive = true
        copyButton.centerYAnchor.constraint(equalTo:self.contentView.centerYAnchor).isActive = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.roundTopCorners(radius: 0)
        self.copyButton.updateNeumorphicButton(hold: false, delay:false)
    }
}
