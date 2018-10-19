//
//  uploadVC.swift
//  Instragram
//
//  Created by 许敏哲 on 17/9/18.
//  Copyright © 2018 许敏哲. All rights reserved.
//

import UIKit
import Parse

public let ScreenWidth: CGFloat = UIScreen.main.bounds.size.width
public let ScreenHeight: CGFloat = UIScreen.main.bounds.size.height

func kAdjustLength(x:CGFloat) -> CGFloat {
    let adjustLength = ScreenWidth * CGFloat(x) / 1080.0
    return CGFloat(adjustLength)
}

class uploadVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DSPhotoEditorViewControllerDelegate, UIGestureRecognizerDelegate {
    
    func dsPhotoEditor(_ editor: DSPhotoEditorViewController!, finishedWith image: UIImage!) {
        self.dismiss(animated: true, completion: nil)
        
        self.picImg.image = image
        
        // enable publish btn
        publishBtn.isEnabled = true
        publishBtn.backgroundColor = UIColor(red: 52.0/255.0, green: 169.0/255.0, blue: 255.0/255.0, alpha: 1)
        
        // unhide remove button
        removeBtn.isHidden = false
        
        // implement second tap for zooming image
        let zoomTap = UITapGestureRecognizer(target: self, action: #selector(uploadVC.zoomImg))
        zoomTap.numberOfTapsRequired = 1
        picImg.isUserInteractionEnabled = true
        picImg.addGestureRecognizer(zoomTap)
    }
    
    func dsPhotoEditorCanceled(_ editor: DSPhotoEditorViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    

    // UI objects
    @IBOutlet weak var picImg: UIImageView!
    @IBOutlet weak var titleTxt: UITextView!
    @IBOutlet weak var publishBtn: UIButton!
    @IBOutlet weak var removeBtn: UIButton!
    
    var imagePicker: UIImagePickerController!
    
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // disable publish btn
        publishBtn.isEnabled = false
        publishBtn.backgroundColor = .lightGray
        
        // hide remove button
        removeBtn.isHidden = true
        
        // standart UI containt
        picImg.image = UIImage(named: "pbg.jpg")
        
        // hide kyeboard tap
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(uploadVC.hideKeyboardTap))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        // select image tap
        let picTap = UITapGestureRecognizer(target: self, action: #selector(uploadVC.selectImg))
        picTap.numberOfTapsRequired = 1
        picImg.isUserInteractionEnabled = true
        picImg.addGestureRecognizer(picTap)
    }
    
    
    // preload func
    override func viewWillAppear(_ animated: Bool) {
        // call alignment function
        alignment()
    }
    
    
    // hide kyeboard function
    @objc func hideKeyboardTap() {
        self.view.endEditing(true)
    }
    
    
    // func to cal pickerViewController
    @objc func selectImg() {
        let actionSheet = UIAlertController(title: "Choose photo from", message: "", preferredStyle: .actionSheet)
        let libraryAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            self.imagePicker = UIImagePickerController()
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.allowsEditing = false
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.imagePicker = UIImagePickerController()
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .camera
            self.imagePicker.allowsEditing = false
            
            let overLayImg = LineSepView(frame: CGRect(x: 0, y: kAdjustLength(x: 115), width: ScreenWidth, height: ScreenHeight-kAdjustLength(x: 480)))
            weak var tmpSelf = self
            overLayImg.cameraClickCallback = {
                tmpSelf?.imagePicker.cameraOverlayView = nil
            }
            overLayImg.isUserInteractionEnabled = true
            self.imagePicker.cameraOverlayView = overLayImg
            
            let cameraBtn = UIView(frame: CGRect(x: kAdjustLength(x: 450), y: kAdjustLength(x: 1540), width: kAdjustLength(x: 180), height: kAdjustLength(x: 180)))
            cameraBtn.tag = 100
            cameraBtn.backgroundColor = UIColor.clear
            overLayImg.addSubview(cameraBtn)
            
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        actionSheet.addAction(libraryAction)
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        if self.imagePicker.sourceType == .camera {
            self.imagePicker.cameraOverlayView = nil
        }
        self.dismiss(animated: true, completion: nil)
        
        let dsPhotoEditorViewController = DSPhotoEditorViewController(image: image!, apiKey: "e8ed493750788d1b46c34d05a50ee6089f39229a", toolsToHide: nil)
        dsPhotoEditorViewController!.delegate = self
        self.present(dsPhotoEditorViewController!, animated: true, completion: nil)
    }
    
    // zooming in / out function
    @objc func zoomImg() {
        
        // define frame of zoomed image
        let zoomed = CGRect(x: 0, y: self.view.center.y - self.view.center.x - self.tabBarController!.tabBar.frame.size.height * 1.5, width: self.view.frame.size.width, height: self.view.frame.size.width)
        
        // frame of unzoomed (small) image
        let unzoomed = CGRect(x: 15, y: 15, width: self.view.frame.size.width / 4.5, height: self.view.frame.size.width / 4.5)
        
        // if picture is unzoomed, zoom it
        if picImg.frame == unzoomed {
            
            // with animation
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                // resize image frame
                self.picImg.frame = zoomed
                
                // hide objects from background
                self.view.backgroundColor = .black
                self.titleTxt.alpha = 0
                self.publishBtn.alpha = 0
                self.removeBtn.alpha = 0
            })
            
        // to unzoom
        } else {
            
            // with animation
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                // resize image frame
                self.picImg.frame = unzoomed
                
                // unhide objects from background
                self.view.backgroundColor = .white
                self.titleTxt.alpha = 1
                self.publishBtn.alpha = 1
                self.removeBtn.alpha = 1
            })
        }
        
    }
    
    
    // alignment
    func alignment() {
        
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        
        picImg.frame = CGRect(x: 15, y: 15, width: width / 4.5, height: width / 4.5)
        titleTxt.frame = CGRect(x: picImg.frame.size.width + 25, y: picImg.frame.origin.y, width: width / 1.488, height: picImg.frame.size.height)
        publishBtn.frame = CGRect(x: 0, y: height / 1.09, width: width, height: width / 8)
        removeBtn.frame = CGRect(x: picImg.frame.origin.x, y: picImg.frame.origin.y + picImg.frame.size.height, width: picImg.frame.size.width, height: 20)
    }
    
    
    // clicked publish button
    @IBAction func publishBtn_clicked(_ sender: AnyObject) {
        
        // dissmiss keyboard
        self.view.endEditing(true)
        
        // send data to server to "posts" class in Parse
        let object = PFObject(className: "posts")
        object["username"] = PFUser.current()!.username
        object["ava"] = PFUser.current()!.value(forKey: "ava") as! PFFile
        
        let uuid = UUID().uuidString
        object["uuid"] = "\(PFUser.current()!.username!) \(uuid)"
        
        if titleTxt.text.isEmpty {
            object["title"] = ""
        } else {
            object["title"] = titleTxt.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
        
        // send pic to server after converting to FILE and comprassion
        let imageData = UIImageJPEGRepresentation(picImg.image!, 0.5)
        let imageFile = PFFile(name: "post.jpg", data: imageData!)
        object["pic"] = imageFile
        
        
        // send #hashtag to server
        let words:[String] = titleTxt.text!.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        
        // define taged word
        for var word in words {
            
            // save #hasthag in server
            if word.hasPrefix("#") {
                
                // cut symbold
                word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                word = word.trimmingCharacters(in: CharacterSet.symbols)
                
                let hashtagObj = PFObject(className: "hashtags")
                hashtagObj["to"] = "\(PFUser.current()!.username!) \(uuid)"
                hashtagObj["by"] = PFUser.current()?.username
                hashtagObj["hashtag"] = word.lowercased()
                hashtagObj["comment"] = titleTxt.text
                hashtagObj.saveInBackground(block: { (success, error) -> Void in
                    if success {
                        print("hashtag \(word) is created")
                    } else {
                        print(error!.localizedDescription)
                    }
                })
            }
        }
        
        
        // finally save information
        object.saveInBackground (block: { (success, error) -> Void in
            if error == nil {
                
                // send notification wiht name "uploaded"
                NotificationCenter.default.post(name: Notification.Name(rawValue: "uploaded"), object: nil)
                
                // switch to another ViewController at 0 index of tabbar
                self.tabBarController!.selectedIndex = 0
                
                // reset everything
                self.viewDidLoad()
                self.titleTxt.text = ""
            }
        })
        
    }
    
    
    // clicked remove button
    @IBAction func removeBtn_clicked(_ sender: AnyObject) {
        self.viewDidLoad()
    }
    
}
