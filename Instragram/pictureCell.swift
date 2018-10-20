//  COMP90018 Mobile Computing Systems Programming
//  pictureCell.swift
//  Instragram viewer Project
//  the University Of Melbourne
//  Created by Wanyun Sun on 13/10/18.
//  Copyright © 2018 Group 18. All rights reserved.
//

import UIKit

class pictureCell: UICollectionViewCell {
    
    // holds post picture
    @IBOutlet weak var picImg: UIImageView!
    
    
    // default func
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // alignment
        let width = UIScreen.main.bounds.width
        picImg.frame = CGRect(x: 0, y: 0, width: width / 3, height: width / 3)
    }
    
}
