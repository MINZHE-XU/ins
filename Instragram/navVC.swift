//  COMP90018 Mobile Computing Systems Programming
//  navVC.swift
//  Instragram viewer Project
//  the University Of Melbourne
//  Created by Minzhe Xu on 10/10/18.
//  Copyright © 2018 Group 18. All rights reserved.

import UIKit

class navVC: UINavigationController {
    
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // color of title at the top in nav controller
        self.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        
        // color of buttons in nav controller
        self.navigationBar.tintColor = .white
        
        // color of background of nav controller
        self.navigationBar.barTintColor = UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 77.0 / 255.0, alpha: 1)
        
        // disable translucent
        self.navigationBar.isTranslucent = false
    }
    
    
    // white status bar function
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
}
