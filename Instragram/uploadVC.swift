//  COMP90018 Mobile Computing Systems Programming
//  uploadVC.swift
//  Instragram viewer Project
//  the University Of Melbourne
//  Created by Jiaheng Zhu on 16/10/18.
//  Copyright © 2018 Group 18. All rights reserved.
//

import UIKit
import Parse

public let ScreenWidth: CGFloat = UIScreen.main.bounds.size.width
public let ScreenHeight: CGFloat = UIScreen.main.bounds.size.height

public let IphoneX: Bool = ScreenHeight >= 812 ? true : false
public let SafeBottomHeight: CGFloat = IphoneX ? 34 : 0
public let cameraXTabHeight: CGFloat = IphoneX ? 44 : 0

func kAdjustLength(x:CGFloat) -> CGFloat {
    let adjustLength = ScreenWidth * CGFloat(x) / 1080.0
    return CGFloat(adjustLength)
}

class uploadVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DSPhotoEditorViewControllerDelegate, UIGestureRecognizerDelegate {
    
    func dsPhotoEditor(_ editor: DSPhotoEditorViewController!, finishedWith image: UIImage!) {
        self.dismiss(animated: true, completion: nil)
        
        self.picImg.image = image
        
        // enable the publish button
        publishBtn.isEnabled = true
        publishBtn.backgroundColor = UIColor(red: 52.0/255.0, green: 169.0/255.0, blue: 255.0/255.0, alpha: 1)
        
        // unhide the remove button
        removeBtn.isHidden = false
        
        // implement the second tap for image zooming
        let zoomTap = UITapGestureRecognizer(target: self, action: #selector(uploadVC.zoomImg))
        zoomTap.numberOfTapsRequired = 1
        picImg.isUserInteractionEnabled = true
        picImg.addGestureRecognizer(zoomTap)
    }
    
    func dsPhotoEditorCanceled(_ editor: DSPhotoEditorViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    

    // Defining UI objects
    @IBOutlet weak var picImg: UIImageView!
    @IBOutlet weak var titleTxt: UITextView!
    @IBOutlet weak var publishBtn: UIButton!
    @IBOutlet weak var removeBtn: UIButton!
    
    var imagePicker: UIImagePickerController!
    
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // disable publish button
        publishBtn.isEnabled = false
        publishBtn.backgroundColor = .lightGray
        
        // hiding remove button
        removeBtn.isHidden = true
        
        // standard UI content
        picImg.image = UIImage(named: "image.png")
        
        
        // hide kyeboard tapping
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(uploadVC.hideKeyboardTap))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        // select image tapping
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
    
    
    // hide the phone kyeboard function
    @objc func hideKeyboardTap() {
        self.view.endEditing(true)
    }
    
    
    // func to call pickerViewController
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
            
            let overLayImg = LineSepView(frame: CGRect(x: 0, y: 44 + SafeBottomHeight, width: ScreenWidth, height: ScreenHeight-140-44-cameraXTabHeight))
            weak var tmpSelf = self
            overLayImg.cameraClickCallback = {
                tmpSelf?.imagePicker.cameraOverlayView = nil
            }
            overLayImg.isUserInteractionEnabled = true
            self.imagePicker.cameraOverlayView = overLayImg
            
            let cameraBtn = UIView(frame: CGRect(x: ScreenWidth/2.0 - 33, y: ScreenHeight - 140 - 44 + 46 + SafeBottomHeight, width: 66, height: 66))
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
    
    // zooming in and out function
    @objc func zoomImg() {
        
        // defining the frame of zoomed image
        let zoomed = CGRect(x: 0, y: self.view.center.y - self.view.center.x - self.tabBarController!.tabBar.frame.size.height * 1.5, width: self.view.frame.size.width, height: self.view.frame.size.width)
        
        // frame of an unzoomed (small) image
        let unzoomed = CGRect(x: 15, y: 15, width: self.view.frame.size.width / 4.5, height: self.view.frame.size.width / 4.5)
        
        // if a picture is unzoomed, zoom it...
        if picImg.frame == unzoomed {
            
            // ...with animation
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                // resize image frame
                self.picImg.frame = zoomed
                
                // hide objects from background
                self.view.backgroundColor = .black
                self.titleTxt.alpha = 0
                self.publishBtn.alpha = 0
                self.removeBtn.alpha = 0
            })
            
        // otherwise, unzoom...
        } else {
            
            // ...with animation
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                // resizing image frame
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
        
        picImg.frame = CGRect(x: 120, y: 15, width: width-240, height: width-240)
        titleTxt.frame = CGRect(x: 60, y: picImg.frame.origin.y  + picImg.frame.size.height+30, width: width-120, height: 100)
        
        removeBtn.frame = CGRect(x: picImg.frame.origin.x, y: picImg.frame.origin.y + picImg.frame.size.height, width: picImg.frame.size.width, height: 20)
        
        publishBtn.frame = CGRect(x: 60, y:  titleTxt.frame.origin.y + titleTxt.frame.size.height + 30, width:width-120, height: 50)
        publishBtn.layer.cornerRadius = publishBtn.frame.size.width / 40
        
    }
    
    
    // clicking publish button
    @IBAction func publishBtn_clicked(_ sender: AnyObject) {
        
        // dissmiss the phone keyboard
        self.view.endEditing(true)
        
        // sending data to the server to "posts" class in Parse
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
        
        // send a picture to the server after converting to FILE and comprassion
        let imageData = UIImageJPEGRepresentation(picImg.image!, 0.5)
        let imageFile = PFFile(name: "post.jpg", data: imageData!)
        object["pic"] = imageFile
        
        
        // send #hashtag to the erver
        let words:[String] = titleTxt.text!.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        
        // defining the tagged word
        for var word in words {
            
            // save #hasthag in the server
            if word.hasPrefix("#") {
                
                // cutting the symbol
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
        
        
        // finally, save the information
        object.saveInBackground (block: { (success, error) -> Void in
            if error == nil {
                
                // sending the notification with name "uploaded"
                NotificationCenter.default.post(name: Notification.Name(rawValue: "uploaded"), object: nil)
                
                // switch to another ViewController at 0 index of tabbar
                self.tabBarController!.selectedIndex = 0
                
                // reset all
                self.viewDidLoad()
                self.titleTxt.text = ""
            }
        })
        
    }
    
    
    // clicking remove button
    @IBAction func removeBtn_clicked(_ sender: AnyObject) {
        self.viewDidLoad()
    }
    
}
