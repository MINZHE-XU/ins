//  COMP90018 Mobile Computing Systems Programming
//  newsVC.swift
//  Instragram viewer Project
//  the University Of Melbourne
//  Created by Jiaheng Zhu on 18/10/18.
//  Copyright © 2018 Group 18. All rights reserved.
//

import UIKit
import Parse

class newsVC: UITableViewController {
    
    // Defining arrays to hold data from server
    var usernameArray = [String]()
    var avaArray = [PFFile]()
    var typeArray = [String]()
    var dateArray = [Date?]()
    var uuidArray = [String]()
    var ownerArray = [String]()
    var towardUserArray = [String]()
    
    
    // defualt func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // dynamic tableView height - dynamic cell
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        
        // Setting the title on top
        self.navigationItem.title = "NOTIFICATIONS"
        
        // requesting notifications:
        let query = PFQuery(className: "news")
        query.whereKey("to", equalTo: PFUser.current()!.username!)
        query.limit = 30
        query.findObjectsInBackground (block: { (objects, error) -> Void in
            if error == nil {
                
                // cleaning up!
                self.usernameArray.removeAll(keepingCapacity: false)
                self.avaArray.removeAll(keepingCapacity: false)
                self.typeArray.removeAll(keepingCapacity: false)
                self.dateArray.removeAll(keepingCapacity: false)
                self.uuidArray.removeAll(keepingCapacity: false)
                self.ownerArray.removeAll(keepingCapacity: false)
                self.towardUserArray.removeAll(keepingCapacity: false)
                
                
                // find relating objects
                for object in objects! {
                    self.usernameArray.append(object.object(forKey: "by") as! String)
                    self.avaArray.append(object.object(forKey: "ava") as! PFFile)
                    self.typeArray.append(object.object(forKey: "type") as! String)
                    self.dateArray.append(object.createdAt)
                    self.uuidArray.append(object.object(forKey: "uuid") as! String)
                    self.ownerArray.append(object.object(forKey: "owner") as! String)
                    self.towardUserArray.append(object.object(forKey: "to") as! String)
                    
                    // saving notifications as checked
                    object["checked"] = "yes"
                    //object.saveInBackground()
                    
                }

            }
        })
        
                //query.whereKey("to", notEqualTo: PFUser.current()!.username!)
      
        
        let root = PFUser.current()!.username!
        let followQuery = PFQuery(className: "follow")
        followQuery.whereKey("follower", equalTo: root)
        //usersQuery.limit = 20
        followQuery.findObjectsInBackground (block: { (objects, error) -> Void in
            if error == nil {

                var newsQueryList = [PFQuery]()
                
                if objects?.count==0{
                    let elementQuery = PFQuery(className:"news")
                    newsQueryList.append(elementQuery)
                }else{
                    for object in objects! {
                        let elementQuery = PFQuery(className:"news")
                        elementQuery.whereKey("by", equalTo: object.value(forKey: "following") as! String )
                        newsQueryList.append(elementQuery)
                    }
                }
                let listQuery = PFQuery.orQuery(withSubqueries: newsQueryList)
                
                //get sub followers:
                listQuery.findObjectsInBackground (block: { (objects2, error2) -> Void in
                    // find relating objects
                    for object2 in objects2! {
                        self.usernameArray.append(object2.object(forKey: "by") as! String)
                        self.avaArray.append(object2.object(forKey: "ava") as! PFFile)
                        self.typeArray.append(object2.object(forKey: "type") as! String)
                        self.dateArray.append(object2.createdAt)
                        self.uuidArray.append(object2.object(forKey: "uuid") as! String)
                        self.ownerArray.append(object2.object(forKey: "owner") as! String)
                        self.towardUserArray.append(object2.object(forKey: "to") as! String)
                    }
                    
                    // reload tableView to show received data
                    self.tableView.reloadData()
                })
            } else {print(error!.localizedDescription)}
        })
    }

    
    // cell numb
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernameArray.count
    }
    
    
    // cell config
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // declaring cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! newsCell

        // connect cell objects with received data from server
        cell.usernameBtn.setTitle(usernameArray[indexPath.row], for: UIControlState())
        cell.toUserBtn.setTitle(towardUserArray[indexPath.row], for: UIControlState())
        
        avaArray[indexPath.row].getDataInBackground { (data, error) -> Void in
            if error == nil {
                cell.avaImg.image = UIImage(data: data!)
            } else {
                print(error!.localizedDescription)
            }
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
        
        // defining info text
        if typeArray[indexPath.row] == "mention" {
            cell.infoLbl.text = "has mentioned you."
        }

        if typeArray[indexPath.row] == "follow" {
            cell.infoLbl.text = "now following you."
        }
        if typeArray[indexPath.row] == "comment" {
            cell.infoLbl.text = "has commented your post."
        }
        if typeArray[indexPath.row] == "like" {
            cell.infoLbl.text = "likes your post."
        }
        
        
        // assign index of the button
        cell.usernameBtn.layer.setValue(indexPath, forKey: "index")

        return cell
    }

    
    // click the username button
    @IBAction func usernameBtn_click(_ sender: AnyObject) {
        
        // call index of button
        let i = sender.layer.value(forKey: "index") as! IndexPath
        
        // call cell to call further cell data
        let cell = tableView.cellForRow(at: i) as! newsCell
        
        // if user tapped on itself, go home; else go to guest page
        if cell.usernameBtn.titleLabel?.text == PFUser.current()?.username {
            let home = self.storyboard?.instantiateViewController(withIdentifier: "homeVC") as! homeVC
            self.navigationController?.pushViewController(home, animated: true)
        } else {
            guestname.append(cell.usernameBtn.titleLabel!.text!)
            let guest = self.storyboard?.instantiateViewController(withIdentifier: "guestVC") as! guestVC
            self.navigationController?.pushViewController(guest, animated: true)
        }
    }
    
    
    // click cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // call cell for calling cell data
        let cell = tableView.cellForRow(at: indexPath) as! newsCell
        
        
        // going to @mentioned comments
        if cell.infoLbl.text == "has mentioned you." {
            
            // send relating data to gloval variables
            commentuuid.append(uuidArray[indexPath.row])
            commentowner.append(ownerArray[indexPath.row])
            
            // go to comments
            let comment = self.storyboard?.instantiateViewController(withIdentifier: "commentVC") as! commentVC
            self.navigationController?.pushViewController(comment, animated: true)
        }
        
        
        // go to own comments
        if cell.infoLbl.text == "has commented your post." {
            
            // send related data to gloval variable
            commentuuid.append(uuidArray[indexPath.row])
            commentowner.append(ownerArray[indexPath.row])
            
            // go to comments
            let comment = self.storyboard?.instantiateViewController(withIdentifier: "commentVC") as! commentVC
            self.navigationController?.pushViewController(comment, animated: true)
        }
        
        
        // going to user who followed the current user
        if cell.infoLbl.text == "now following you." {
            
            // take theguestname
            guestname.append(cell.usernameBtn.titleLabel!.text!)
            
            // go to guest
            let guest = self.storyboard?.instantiateViewController(withIdentifier: "guestVC") as! guestVC
            self.navigationController?.pushViewController(guest, animated: true)
        }
        
        
        // going to post liked
        if cell.infoLbl.text == "likes your post." {
            
            // take post UUID
            postuuid.append(uuidArray[indexPath.row])
            
            // go to post
            let post = self.storyboard?.instantiateViewController(withIdentifier: "postVC") as! postVC
            self.navigationController?.pushViewController(post, animated: true)
        }
        
    }

}
