//  COMP90018 Mobile Computing Systems Programming
//  signInVC.swift
//  Instragram viewer Project
//  the University Of Melbourne
//  Created by Minzhe Xu on 19/9/18.
//  Copyright © 2018 Group 18. All rights reserved.
//

import UIKit
import Parse


class signInVC: UIViewController {
    
    // text fields
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    
    // buttons
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var forgotBtn: UIButton!
    
    
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        // alignment
        label.frame = CGRect(x: 30, y: 80, width: self.view.frame.size.width - 60, height: 50)
        usernameTxt.frame = CGRect(x: 30, y: label.frame.origin.y + 70, width: self.view.frame.size.width - 60, height: 30)
        passwordTxt.frame = CGRect(x: 30, y: usernameTxt.frame.origin.y + 40, width: self.view.frame.size.width - 60, height: 30)

        
        forgotBtn.frame = CGRect(x: 30, y: passwordTxt.frame.origin.y + 40, width: self.view.frame.size.width - 60, height: 30)
        
        
        signInBtn.frame = CGRect(x: 30, y: forgotBtn.frame.origin.y + 100, width: self.view.frame.size.width - 60, height: 30)
        signInBtn.layer.cornerRadius = signInBtn.frame.size.width / 40
        
        signUpBtn.frame = CGRect(x: 30, y: signInBtn.frame.origin.y + 40, width: self.view.frame.size.width - 60, height: 30)
        signUpBtn.layer.cornerRadius = signUpBtn.frame.size.width / 40

        
        // tap to hide phone keyboard
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(signInVC.hideKeyboard(_:)))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        // background
        let bg = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        bg.image = UIImage(named: "background.jpg")
        bg.layer.zPosition = -1
        self.view.addSubview(bg)
    }
    
    
    // hide keyboard func
    func hideKeyboard(_ recognizer : UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    
    // clicking sign in button...
    @IBAction func signInBtn_click(_ sender: AnyObject) {
        print("sign in pressed")
        
        // hide phone keyboard
        self.view.endEditing(true)
        
        // if textfields are empty...
        if usernameTxt.text!.isEmpty || passwordTxt.text!.isEmpty {
            
            // then show the alert message
            let alert = UIAlertController(title: "Please", message: "fill in fields", preferredStyle: UIAlertControllerStyle.alert)
            let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
        
        // login functions
        PFUser.logInWithUsername(inBackground: usernameTxt.text!, password: passwordTxt.text!) { (user, error) -> Void in
            if error == nil {
                
                // remember user or save in App Memeory whether the user logged in or not
                UserDefaults.standard.set(user!.username, forKey: "username")
                UserDefaults.standard.synchronize()
                
                // call login function from AppDelegate.swift class
                let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.login()
            
            } else {
                
                // show alert message:
                let alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
}
