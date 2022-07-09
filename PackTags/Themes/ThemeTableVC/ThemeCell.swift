//
//  ThemeCell.swift
//  PackTags
//
//  Created by Alexandre Bevilacqua on 12/04/2021.
//  Copyright © 2021 Alexandre Bevilacqua. All rights reserved.
//


import UIKit

class ThemeCell: UITableViewCell {
        
    let containerView:UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()
    
    let themeImageView:UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        img.translatesAutoresizingMaskIntoConstraints = false
        img.layer.cornerRadius = 10
        img.clipsToBounds = true
        return img
    }()
    
    let nameLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 19)
        label.textColor = labelColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let subLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor =  .white
        label.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        label.layer.cornerRadius = 5
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let view: UIView = {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: thumbnailDim, height: thumbnailDim)
        view.neumorphism(cornerRadius: 15, shadowRadius: 5)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = bkgdColor
        
        containerView.addSubview(nameLabel)
        containerView.addSubview(subLabel)
        self.contentView.addSubview(containerView)
        
        self.contentView.addSubview(view)
        self.contentView.addSubview(themeImageView)
        
        
        // ---------- themeImageView ----------
        
        themeImageView.centerYAnchor.constraint(equalTo:self.contentView.centerYAnchor).isActive = true
        themeImageView.leadingAnchor.constraint(equalTo:self.contentView.leadingAnchor, constant:30).isActive = true
        themeImageView.widthAnchor.constraint(equalToConstant: thumbnailDim - 10).isActive = true
        themeImageView.heightAnchor.constraint(equalToConstant: thumbnailDim - 10).isActive = true
        
        //
        view.leadingAnchor.constraint(equalTo:themeImageView.leadingAnchor, constant: -5).isActive = true
        view.topAnchor.constraint(equalTo:themeImageView.topAnchor, constant: -5).isActive = true
        
        
        // ---------- containerView ----------
        
        containerView.centerYAnchor.constraint(equalTo:self.contentView.centerYAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant:40).isActive = true
        containerView.leadingAnchor.constraint(equalTo:self.themeImageView.trailingAnchor, constant:20).isActive = true
        containerView.trailingAnchor.constraint(equalTo:self.contentView.trailingAnchor, constant:-20).isActive = true
        
        // ---------- nameLabel ----------
        
        nameLabel.topAnchor.constraint(equalTo:self.containerView.topAnchor).isActive = true
        //
        if UIDevice.current.userInterfaceIdiom == .pad {
            nameLabel.centerXAnchor.constraint(equalTo:self.centerXAnchor).isActive = true
        } else {
            nameLabel.centerXAnchor.constraint(equalTo:self.containerView.centerXAnchor).isActive = true
        }
        
        
        // ---------- subLabel ----------
        
        subLabel.topAnchor.constraint(equalTo:self.nameLabel.bottomAnchor).isActive = true
        subLabel.centerXAnchor.constraint(equalTo:self.containerView.centerXAnchor).isActive = true
        subLabel.topAnchor.constraint(equalTo:self.nameLabel.bottomAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }

}















