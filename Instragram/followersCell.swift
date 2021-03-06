//  COMP90018 Mobile Computing Systems Programming
//  followersCell.swift
//  Instragram viewer Project
//  the University Of Melbourne
//  Created by Jiaheng Zhu on 3/10/18.
//  Copyright © 2018 Group 18. All rights reserved.

import UIKit
import Parse


class followersCell: UITableViewCell {

    // Defining UI objects
    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var followCountLbl: UILabel!
    
    // default func
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // alignment
        let width = UIScreen.main.bounds.width
        
        avaImg.frame = CGRect(x: 10, y: 10, width: width / 5.3, height: width / 5.3)
        usernameLbl.frame = CGRect(x: avaImg.frame.size.width + 20, y: 28, width: width / 3.2, height: 30)
        followCountLbl.frame = CGRect(x: avaImg.frame.size.width + 20, y: 48, width: width / 2.0, height: 30)
        followBtn.frame = CGRect(x: width - width / 3.5 - 10, y: 30, width: width / 3.5, height: 30)
        followBtn.layer.cornerRadius = followBtn.frame.size.width / 20
        
        // round ava
        avaImg.layer.cornerRadius = avaImg.frame.size.width / 2
        avaImg.clipsToBounds = true
    }
    
    
    // clicked to follow or unfollow
    @IBAction func followBtn_click(_ sender: AnyObject) {
        
        let title = followBtn.title(for: UIControlState())
        
        // 1. to follow
        if title == "FOLLOW" {
            let object = PFObject(className: "follow")
            object["follower"] = PFUser.current()?.username
            object["following"] = usernameLbl.text
            object.saveInBackground(block: { (success, error) -> Void in
                if success {
                    self.followBtn.setTitle("FOLLOWING", for: UIControlState())
                    self.followBtn.backgroundColor = UIColor.init(red: 0.00, green: 0.62, blue: 0.85, alpha: 1.0)
                }
            })
            
        // 2. to unfollow
        } else {
            let query = PFQuery(className: "follow")
            query.whereKey("follower", equalTo: PFUser.current()!.username!)
            query.whereKey("following", equalTo: usernameLbl.text!)
            query.findObjectsInBackground(block: { (objects, error) -> Void in
                if error == nil {
                    
                    for object in objects! {
                        object.deleteInBackground(block: { (success, error) -> Void in
                            if success {
                                self.followBtn.setTitle("FOLLOW", for: UIControlState())
                                self.followBtn.backgroundColor = .lightGray
                            }
                        })
                    }
                    
                } 
            })
            
        }
        
    }
    
    

}
