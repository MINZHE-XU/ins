//
//  popVC.swift
//  Instragram
//
//  Created by Misun's Macbook Air on 2018/10/20.
//  Copyright © 2018年 Akhmed Idigov. All rights reserved.
//

import UIKit

class popVC: UIViewController {
    
    var pparent: UITableViewController?
    
//    var theImagePassed = UIImage()

  
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var whiteView: UIView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet var displayImage: UIImageView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //set backgroun color
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        whiteView.center = self.view.center
    }
    func back(){
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
        self.pparent?.tableView.isScrollEnabled = true
    }
    
    @IBAction func saveBtn_clicked(_ sender: UIButton) {
        let image = displayImage.image
        UIImageWriteToSavedPhotosAlbum(image!, self, #selector(self.saveImage(_:didFinishSavingWithError:contextInfo:)), nil)
        self.back()
    }
    @IBAction func cancelBtn_clicked(_ sender: UIButton) {
        self.back()
    }
    
    @objc func saveImage(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        
        let ac = UIAlertController(title: "Saved!", message:nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        self.parent?.present(ac, animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
