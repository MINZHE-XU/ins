//  COMP90018 Mobile Computing Systems Programming
//  postVC.swift
//  Instragram viewer Project
//  the University Of Melbourne
//  Created by Wanyun Sun on 8/10/18.
//  Copyright © 2018 Group 18. All rights reserved.
//

import UIKit
import Parse

var postuuid = [String]()

class postVC: UITableViewController {

    // arrays to hold information from the server
    var avaArray = [PFFile]()
    var usernameArray = [String]()
    var dateArray = [Date?]()
    var picArray = [PFFile]()
    var uuidArray = [String]()
    var titleArray = [String]()
    
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // title on top
        self.navigationItem.title = "PHOTO"
        
        // new back button
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(image: UIImage(named: "back.png"), style: .plain, target: self, action: #selector(postVC.back(_:)))
        self.navigationItem.leftBarButtonItem = backBtn
        
        // swipe to return
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(postVC.back(_:)))
        backSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(backSwipe)
        
        NotificationCenter.default.addObserver(self, selector: #selector(postVC.refresh), name: NSNotification.Name(rawValue: "liked"), object: nil)
                
        // dynamic cell height
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 450
        
        // finding posts
        let postQuery = PFQuery(className: "posts")
        postQuery.whereKey("uuid", equalTo: postuuid.last!)
        postQuery.findObjectsInBackground (block: { (objects, error) -> Void in
            if error == nil {
                
                // cleaning up!
                self.avaArray.removeAll(keepingCapacity: false)
                self.usernameArray.removeAll(keepingCapacity: false)
                self.dateArray.removeAll(keepingCapacity: false)
                self.picArray.removeAll(keepingCapacity: false)
                self.uuidArray.removeAll(keepingCapacity: false)
                self.titleArray.removeAll(keepingCapacity: false)
                
                // find relating objects
                for object in objects! {
                    self.avaArray.append(object.value(forKey: "ava") as! PFFile)
                    self.usernameArray.append(object.value(forKey: "username") as! String)
                    self.dateArray.append(object.createdAt)
                    self.picArray.append(object.value(forKey: "pic") as! PFFile)
                    self.uuidArray.append(object.value(forKey: "uuid") as! String)
                    self.titleArray.append(object.value(forKey: "title") as! String)
                }
                
                self.tableView.reloadData()
            }
        })
        
    }
    
    func refresh() {
        self.tableView.reloadData()
    }

    
    // cell numb
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernameArray.count
    }
    
    
    // cell config
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // defining cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! postCell
        
        // connect objects with our information from arrays
        cell.usernameBtn.setTitle(usernameArray[indexPath.row], for: UIControlState())
        cell.usernameBtn.sizeToFit()
        cell.uuidLbl.text = uuidArray[indexPath.row]
        cell.titleLbl.text = titleArray[indexPath.row]
        cell.titleLbl.sizeToFit()
        
        // place the profile picture
        avaArray[indexPath.row].getDataInBackground { (data, error) -> Void in
            cell.avaImg.image = UIImage(data: data!)
        }
        
        // place the post picture
        picArray[indexPath.row].getDataInBackground { (data, error) -> Void in
            cell.picImg.image = UIImage(data: data!)
        }
        
        // calculating post date
        let from = dateArray[indexPath.row]
        let now = Date()
        let components : NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfMonth]
        let difference = (Calendar.current as NSCalendar).components(components, from: from!, to: now, options: [])

        // time to show: seconds, minutes, hours, days or weeks
        if difference.second! <= 0 {
            cell.dateLbl.text = "now"
        }
        if difference.second! > 0 && difference.minute! == 0 {
            cell.dateLbl.text = "\(String(describing: difference.second!))s."
        }
        if difference.minute! > 0 && difference.hour! == 0 {
            cell.dateLbl.text = "\(String(describing: difference.minute!))m."
        }
        if difference.hour! > 0 && difference.day! == 0 {
            cell.dateLbl.text = "\(String(describing: difference.hour!))h."
        }
        if difference.day! > 0 && difference.weekOfMonth! == 0 {
            cell.dateLbl.text = "\(String(describing: difference.day!))d."
        }
        if difference.weekOfMonth! > 0 {
            cell.dateLbl.text = "\(String(describing: difference.weekOfMonth!))w."
        }
        
        // control like button depending on if user like it or not
        let didLike = PFQuery(className: "likes")
        didLike.whereKey("by", equalTo: PFUser.current()!.username!)
        didLike.whereKey("to", equalTo: cell.uuidLbl.text!)
        didLike.countObjectsInBackground { (count, error) -> Void in
            // if no any likes are found, else found likes
            if count == 0 {
                cell.likeBtn.setTitle("unlike", for: UIControlState())
                cell.likeBtn.setBackgroundImage(UIImage(named: "unlike.png"), for: UIControlState())
            } else {
                cell.likeBtn.setTitle("like", for: UIControlState())
                cell.likeBtn.setBackgroundImage(UIImage(named: "like.png"), for: UIControlState())
            }
        }
        
        
        // counting total number of likes of a shown post
        let countLikes = PFQuery(className: "likes")
        countLikes.whereKey("to", equalTo: cell.uuidLbl.text!)
        countLikes.findObjectsInBackground (block: { (objects, error) -> Void in
            if error == nil {
                let likeCount="\(objects?.count ?? 0)"
                cell.likeLbl.text = likeCount
                var str = "Liked by:" + " "
                for object in objects! {
                    let user = object.object(forKey: "by") as! String
                    str = str + user + " "
                }
                if likeCount=="0" {
                    cell.likepeopleLbl.text = ""
                }else{
                    cell.likepeopleLbl.text = str
                }
            } else { print(error!.localizedDescription)}
        })
        
        // assigning index
        cell.usernameBtn.layer.setValue(indexPath, forKey: "index")
        cell.commentBtn.layer.setValue(indexPath, forKey: "index")

        // @mention is tapped
        cell.titleLbl.userHandleLinkTapHandler = { label, handle, rang in
            var mention = handle
            mention = String(mention.dropFirst())
            
            // if taps on @currentUser, go home; else go to the guest page
            if mention.lowercased() == PFUser.current()?.username {
                let home = self.storyboard?.instantiateViewController(withIdentifier: "homeVC") as! homeVC
                self.navigationController?.pushViewController(home, animated: true)
            } else {
                guestname.append(mention.lowercased())
                let guest = self.storyboard?.instantiateViewController(withIdentifier: "guestVC") as! guestVC
                self.navigationController?.pushViewController(guest, animated: true)
            }
        }
        
        // when #hashtag is tapped
        cell.titleLbl.hashtagLinkTapHandler = { label, handle, range in
            var mention = handle
            mention = String(mention.dropFirst())
            hashtag.append(mention.lowercased())
            let hashvc = self.storyboard?.instantiateViewController(withIdentifier: "hashtagsVC") as! hashtagsVC
            self.navigationController?.pushViewController(hashvc, animated: true)
        }
        
        return cell
    }
    
    // click username button
    @IBAction func usernameBtn_click(_ sender: AnyObject) {
        
        // call index of button
        let i = sender.layer.value(forKey: "index") as! IndexPath
        
        // call cell to call further cell data
        let cell = tableView.cellForRow(at: i) as! postCell
        
        // if user taps on itself, go home; else go to the guest
        if cell.usernameBtn.titleLabel?.text == PFUser.current()?.username {
            let home = self.storyboard?.instantiateViewController(withIdentifier: "homeVC") as! homeVC
            self.navigationController?.pushViewController(home, animated: true)
        } else {
            guestname.append(cell.usernameBtn.titleLabel!.text!)
            let guest = self.storyboard?.instantiateViewController(withIdentifier: "guestVC") as! guestVC
            self.navigationController?.pushViewController(guest, animated: true)
        }
        
    }
    
    // click comment button
    @IBAction func commentBtn_click(_ sender: AnyObject) {
        
        // call index of button
        let i = sender.layer.value(forKey: "index") as! IndexPath
        
        // call cell to call further cell data
        let cell = tableView.cellForRow(at: i) as! postCell
        
        // send relating data to global variables
        commentuuid.append(cell.uuidLbl.text!)
        commentowner.append(cell.usernameBtn.titleLabel!.text!)
        
        // go to comments. present vc
        let comment = self.storyboard?.instantiateViewController(withIdentifier: "commentVC") as! commentVC
        self.navigationController?.pushViewController(comment, animated: true)
    }
    
    
    // alert action
    func alert (_ title: String, message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    
    // go back function
    func back(_ sender: UIBarButtonItem) {
        
        // push back
        _ = self.navigationController?.popViewController(animated: true)
        
        // clean post UUID from last hold
        if !postuuid.isEmpty {
           postuuid.removeLast()
        }
        
    }

}
