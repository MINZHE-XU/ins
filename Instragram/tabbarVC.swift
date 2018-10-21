//  COMP90018 Mobile Computing Systems Programming
//  tabbarVC.swift
//  Instragram viewer Project
//  the University Of Melbourne
//  Created by Liangmu Zhu on 14/10/18.
//  Copyright © 2018 Group 18. All rights reserved.
//

import UIKit
import Parse


// defining global variables of icons
var icons = UIScrollView()
var corner = UIImageView()
var dot = UIView()

// customize tab bar buttons
let tabBarPostButton = UIButton()

class tabbarVC: UITabBarController {
    
    
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // color of the item
        self.tabBar.tintColor = .white
        
        // color of the background
        self.tabBar.barTintColor = UIColor(red: 37.0 / 255.0, green: 39.0 / 255.0, blue: 42.0 / 255.0, alpha: 1)
        
        // translucent disabled
        self.tabBar.isTranslucent = false
        
        // customize the button
        
        let itemHeight = self.tabBar.frame.size.height
        let itemWidth = self.view.frame.size.width / 5
        tabBarPostButton.frame = CGRect(x: ( self.view.frame.size.width - itemHeight)/2, y: self.view.frame.size.height - itemHeight, width: itemHeight, height: itemHeight)
        tabBarPostButton.setBackgroundImage(UIImage(named: "upload.png"), for: UIControlState())
        tabBarPostButton.adjustsImageWhenHighlighted = false
        tabBarPostButton.addTarget(self, action: #selector(tabbarVC.upload(_:)), for: UIControlEvents.touchUpInside)
        self.view.addSubview(tabBarPostButton)
        
        
        // creation of total icons
        icons.frame = CGRect(x: self.view.frame.size.width / 5 * 3 + 10, y: self.view.frame.size.height - self.tabBar.frame.size.height * 2 - 3, width: 50, height: 35)
        self.view.addSubview(icons)
        
        // creating corner
        corner.frame = CGRect(x: icons.frame.origin.x, y: icons.frame.origin.y + icons.frame.size.height, width: 20, height: 14)
        corner.center.x = icons.center.x
        corner.image = UIImage(named: "corner.png")
        corner.isHidden = true
        self.view.addSubview(corner)
        
        // creating dot
        dot.frame = CGRect(x: self.view.frame.size.width / 5 * 3, y: self.view.frame.size.height - 5, width: 7, height: 7)
        dot.center.x = self.view.frame.size.width / 5 * 3 + (self.view.frame.size.width / 5) / 2
        dot.backgroundColor = UIColor(red: 251/255, green: 103/255, blue: 29/255, alpha: 1)
        dot.layer.cornerRadius = dot.frame.size.width / 2
        dot.isHidden = true
        self.view.addSubview(dot)
        
        
        // call the function of all type of notifications
        query(["like"], image: UIImage(named: "likeIcon.png")!)
        query(["follow"], image: UIImage(named: "followIcon.png")!)
        query(["mention", "comment"], image: UIImage(named: "commentIcon.png")!)
        
        
        // hiding icon objects
        UIView.animate(withDuration: 1, delay: 8, options: [], animations: { () -> Void in
            icons.alpha = 0
            corner.alpha = 0
            dot.alpha = 0
        }, completion: nil)
        
    }
    
    
    // multiple queries
    func query (_ type:[String], image:UIImage) {
        
        let query = PFQuery(className: "news")
        query.whereKey("to", equalTo: PFUser.current()!.username!)
        //query.whereKey("checked", equalTo: "no")
        query.whereKey("type", containedIn: type)
        query.countObjectsInBackground (block: { (count, error) -> Void in
            if error == nil {
                if count > 0 {
                    self.placeIcon(image, text: "\(count)")
                }
            } else {
                print(error!.localizedDescription)
            }
        })
    }
    
    
    // multiple icons
    func placeIcon (_ image:UIImage, text:String) {
        
        // create a separate icon
        let view = UIImageView(frame: CGRect(x: icons.contentSize.width, y: 0, width: 50, height: 35))
        view.image = image
        icons.addSubview(view)
        
        // create UI label
        let label = UILabel(frame: CGRect(x: view.frame.size.width / 2, y: 0, width: view.frame.size.width / 2, height: view.frame.size.height))
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 18)
        label.text = text
        label.textAlignment = .center
        label.textColor = .white
        view.addSubview(label)
        
        // updating icons view frame
        icons.frame.size.width = icons.frame.size.width + view.frame.size.width - 4
        icons.contentSize.width = icons.contentSize.width + view.frame.size.width - 4
        icons.center.x = self.view.frame.size.width / 5 * 4 - (self.view.frame.size.width / 5) / 4
        
        // unhide elements
        corner.isHidden = false
        dot.isHidden = false
    }
    
    
    // clicked upload button (and go to upload)
    @objc func upload(_ sender : UIButton) {
        self.selectedIndex = 2
    }
    
}
