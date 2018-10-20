//  COMP90018 Mobile Computing Systems Programming
//  newsCell.swift
//  Instragram viewer Project
//  the University Of Melbourne
//  Created by Jiaheng Zhu on 19/10/18.
//  Copyright © 2018 Group 18. All rights reserved.
//

import UIKit

class newsCell: UITableViewCell {

    // Defining UI objects
    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var usernameBtn: UIButton!
    @IBOutlet weak var infoLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var toUserBtn: UIButton!
    @IBOutlet weak var infoLbl2: UILabel!
    
    // default func
    override func awakeFromNib() {
        super.awakeFromNib()

        // a list of constraints
        avaImg.translatesAutoresizingMaskIntoConstraints = false
        usernameBtn.translatesAutoresizingMaskIntoConstraints = false
        infoLbl.translatesAutoresizingMaskIntoConstraints = false
        infoLbl2.translatesAutoresizingMaskIntoConstraints = false
        dateLbl.translatesAutoresizingMaskIntoConstraints = false
        toUserBtn.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-10-[ava(30)]-10-[username]-7-[info]-7-[toUserBtn]-7-[info2]-7-[date]",
            options: [], metrics: nil, views: ["ava":avaImg, "toUserBtn":toUserBtn,"username":usernameBtn, "info":infoLbl, "info2":infoLbl2,"date":dateLbl]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-10-[ava(30)]-10-|",
            options: [], metrics: nil, views: ["ava":avaImg]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-10-[toUserBtn(30)]",
            options: [], metrics: nil, views: ["toUserBtn":toUserBtn]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-10-[username(30)]",
            options: [], metrics: nil, views: ["username":usernameBtn]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-10-[info2(30)]",
            options: [], metrics: nil, views: ["info2":infoLbl]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-10-[info(30)]",
            options: [], metrics: nil, views: ["info":infoLbl2]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-10-[date(30)]",
            options: [], metrics: nil, views: ["date":dateLbl]))
        
        // round ava
        avaImg.layer.cornerRadius = avaImg.frame.size.width / 2
        avaImg.clipsToBounds = true
    }

}
