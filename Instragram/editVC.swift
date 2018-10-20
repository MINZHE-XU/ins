//  COMP90018 Mobile Computing Systems Programming
//  editVC.swift
//  Instragram viewer Project
//  the University Of Melbourne
//  Created by Jiaheng Zhu on 9/10/18.
//  Copyright © 2018 Group 18. All rights reserved.
//

import UIKit
import Parse

class editVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // Declaring UI objects
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var avaImg: UIImageView!
    
    @IBOutlet weak var fullnameTxt: UITextField!
    @IBOutlet weak var usernameTxt: UITextField!

    @IBOutlet weak var bioTxt: UITextView!
    
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var telTxt: UITextField!
    @IBOutlet weak var genderTxt: UITextField!
    // pickerView and pickerData:
        var genderPicker : UIPickerView!
        let genders = ["male","female"]
    
    // value to hold the phone keyboard frmae size
    var keyboard = CGRect()
    
    
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // creating gender picker
        genderPicker = UIPickerView()
        genderPicker.dataSource = self
        genderPicker.delegate = self
        genderPicker.backgroundColor = UIColor.groupTableViewBackground
        genderPicker.showsSelectionIndicator = true
        genderTxt.inputView = genderPicker
        
        // check notifications of phone keyboard - shown or not
        NotificationCenter.default.addObserver(self, selector: #selector(editVC.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(editVC.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // tap to hide phone keyboard
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(editVC.hideKeyboard))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        // tap to choose an image
        let avaTap = UITapGestureRecognizer(target: self, action: #selector(editVC.loadImg(_:)))
        avaTap.numberOfTapsRequired = 1
        avaImg.isUserInteractionEnabled = true
        avaImg.addGestureRecognizer(avaTap)
        
        // call the alignment function
        alignment()
        
        // call the information function
        information()
    }
    
    
    // func to hide the phone keyboard
    func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    
    // func when the phone keyboard is shown
    func keyboardWillShow(_ notification: Notification) {
    
        // defining frame size of the phone keyboard
        keyboard = ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue)!
        
        // movin' up animation
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.scrollView.contentSize.height = self.view.frame.size.height + self.keyboard.height / 2
        }) 
    }
    
    
    // func when the phone keyboard is hidden
    func keyboardWillHide(_ notification: Notification) {
        
        // movin' down animation
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.scrollView.contentSize.height = 0
        }) 
    }
    
    
    // func to call the UIImagePickerController
    func loadImg (_ recognizer : UITapGestureRecognizer) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    
    // method to finalize our actions with UIImagePickerController
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        avaImg.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    // alignment function
    func alignment() {
        
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        
        scrollView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        avaImg.frame = CGRect(x: width - 68 - 10, y: 15, width: 68, height: 68)
        avaImg.layer.cornerRadius = avaImg.frame.size.width / 2
        avaImg.clipsToBounds = true
        
        fullnameTxt.frame = CGRect(x: 10, y: avaImg.frame.origin.y, width: width - avaImg.frame.size.width - 30, height: 30)
        usernameTxt.frame = CGRect(x: 10, y: fullnameTxt.frame.origin.y + 40, width: width - avaImg.frame.size.width - 30, height: 30)

        bioTxt.frame = CGRect(x: 10, y: usernameTxt.frame.origin.y + 40, width: width - 20, height: 60)
        bioTxt.layer.borderWidth = 1
        bioTxt.layer.borderColor = UIColor(red: 230 / 255.5, green: 230 / 255.5, blue: 230 / 255.5, alpha: 1).cgColor
        bioTxt.layer.cornerRadius = bioTxt.frame.size.width / 50
        bioTxt.clipsToBounds = true
        
        emailTxt.frame = CGRect(x: 10, y: bioTxt.frame.origin.y + 100, width: width - 20, height: 30)
        telTxt.frame = CGRect(x: 10, y: emailTxt.frame.origin.y + 40, width: width - 20, height: 30)
        genderTxt.frame = CGRect(x: 10, y: telTxt.frame.origin.y + 40, width: width - 20, height: 30)
        
        titleLbl.frame = CGRect(x: 15, y: emailTxt.frame.origin.y - 30, width: width - 20, height: 30)
    }
    
    
    // user information function
    func information() {
        
        // receiving the profile picture
        let ava = PFUser.current()?.object(forKey: "ava") as! PFFile
        ava.getDataInBackground { (data, error) -> Void in
            self.avaImg.image = UIImage(data: data!)
        }
        
        // receiving text information
        usernameTxt.text = PFUser.current()?.username
        fullnameTxt.text = PFUser.current()?.object(forKey: "fullname") as? String
        bioTxt.text = PFUser.current()?.object(forKey: "bio") as? String

        emailTxt.text = PFUser.current()?.email
        telTxt.text = PFUser.current()?.object(forKey: "tel") as? String
        genderTxt.text = PFUser.current()?.object(forKey: "gender") as? String
    }
    
    
    // regex restrictions for email text field
    func validateEmail (_ email : String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]{4}+@[A-Za-z0-9.-]+\\.[A-Za-z]{2}"
        let range = email.range(of: regex, options: .regularExpression)
        let result = range != nil ? true : false
        return result
    }
    
    // regex restrictions for web text field
    func validateWeb (_ web : String) -> Bool {
        let regex = "www.+[A-Z0-9a-z._%+-]+.[A-Za-z]{2}"
        let range = web.range(of: regex, options: .regularExpression)
        let result = range != nil ? true : false
        return result
    }
    
    
    // alert message function
    func alert (_ error: String, message : String) {
        let alert = UIAlertController(title: error, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // click save button:
    @IBAction func save_clicked(_ sender: AnyObject) {
        
        // if incorrect email according to regex,
        if !validateEmail(emailTxt.text!) {
            alert("Incorrect email", message: "please provide correct email address")
            return
        }
        
  
        
        // save filled information
        let user = PFUser.current()!
        user.username = usernameTxt.text?.lowercased()
        user.email = emailTxt.text?.lowercased()
        user["fullname"] = fullnameTxt.text?.lowercased()

        user["bio"] = bioTxt.text
        
        // if "tel" is empty, send empty data, else send entered data
        if telTxt.text!.isEmpty {
            user["tel"] = ""
        } else {
            user["tel"] = telTxt.text
        }
        
        // if "gender" is empty, send empty data, else send entered data
        if genderTxt.text!.isEmpty {
            user["gender"] = ""
        } else {
            user["gender"] = genderTxt.text
        }
        
        // send the profile picture
        let avaData = UIImageJPEGRepresentation(avaImg.image!, 0.5)
        let avaFile = PFFile(name: "ava.jpg", data: avaData!)
        user["ava"] = avaFile
        
        // send filled information to the server
        user.saveInBackground (block: { (success, error) -> Void in
            if success{
                
                // hide the phone keyboard
                self.view.endEditing(true)
                
                // dismiss editVC
                self.dismiss(animated: true, completion: nil)
                
                // send notification to homeVC for reloading
                NotificationCenter.default.post(name: Notification.Name(rawValue: "reload"), object: nil)
                
                
                // update ava in posts
                let followQuery = PFQuery(className: "posts")
                followQuery.whereKey("username", equalTo: PFUser.current()!.username!)
                followQuery.findObjectsInBackground (block: { (objects, error) -> Void in
                    if error == nil {
                        for object in objects!{
                            object["ava"] = avaFile
                            object.saveInBackground()
                        }
                    } else {
                        print(error!.localizedDescription)
                    }
                })

            } else {
                print(error!.localizedDescription)
            }
        })
        
    }
    
    
    // click cancel button
    @IBAction func cancel_clicked(_ sender: AnyObject) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    // PICKER VIEW METHODS
    // picker comp numb:
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // picker text numb:
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genders.count
    }
    
    // picker text config:
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genders[row]
    }
    
    // picker selects some value from it:
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderTxt.text = genders[row]
        self.view.endEditing(true)
    }
    
    
}
