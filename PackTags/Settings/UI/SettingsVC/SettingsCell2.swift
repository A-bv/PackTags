//
//  SettingsCell1.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 24/03/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//

import UIKit

//Cells with a switch
class SettingsCell2: UITableViewCell {

    static let identifier = "SettingsCell2"
    
    var name: String?
    
    private let iconContainer: UIView = {
        let view = UIView()
        view .clipsToBounds = true
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()
    
    //--
    private let mySwitch: UISwitch = {
        let mySwitch = UISwitch(frame: .zero) as UISwitch
        mySwitch.onTintColor = .systemGreen
        return mySwitch
    }() //--
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
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
        accessoryView = mySwitch    //--
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size: CGFloat = contentView.frame.size.height - 12
        iconContainer.frame = CGRect(x: 15, y: 6, width: size, height: size)
        
        let imageSize: CGFloat = size/1.5
        iconImageView.frame = CGRect(x: (size-imageSize)/2, y: (size-imageSize)/2, width: imageSize, height: imageSize)
        iconImageView.center = iconContainer.center
     
        label.frame = CGRect(
            x: 25 + iconContainer.frame.size.width,
            y: 0,
            width: contentView.frame.size.width - 20 - iconContainer.frame.size.width,
            height: contentView.frame.size.height
        )
    }
    
    //called when TV trying to reuse its cell
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        label.text = nil
        iconContainer.backgroundColor = nil
        mySwitch.isOn = false 
    }
    
    public func configure(with model: SettingsSwitchOption){//mod
        label.text = model.title
        iconImageView.image = model.icon
        iconContainer.backgroundColor = model.iconBackgroundColor
        
        mySwitch.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        
        if name != nil {
            mySwitch.isOn = UserDefaults.standard.bool(forKey: name!)
        }
    }

    //SwitchButton function
    @objc private func valueChanged(sender: UISwitch) {
        if name != nil {
            UserDefaults.standard.set(sender.isOn, forKey: name!)
        }
    }
}
