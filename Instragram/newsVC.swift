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
    
    // arrays to hold data from server
    var usernameArray = [String]()
    var avaArray = [PFFile]()
    var typeArray = [String]()
    var dateArray = [Date?]()
    var uuidArray = [String]()
    var ownerArray = [String]()
    var towardArray = [String]()
    
    
    // defualt func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // dynamic tableView height - dynamic cell
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        
        // title at the top
        self.navigationItem.title = "NOTIFICATIONS"
        
        // request notifications
        let query = PFQuery(className: "news")
        query.whereKey("to", equalTo: PFUser.current()!.username!)
        query.whereKey("checked", notEqualTo: "yes")
        query.limit = 30
        query.findObjectsInBackground (block: { (objects, error) -> Void in
            if error == nil {
                
                // clean up
                self.usernameArray.removeAll(keepingCapacity: false)
                self.avaArray.removeAll(keepingCapacity: false)
                self.typeArray.removeAll(keepingCapacity: false)
                self.dateArray.removeAll(keepingCapacity: false)
                self.uuidArray.removeAll(keepingCapacity: false)
                self.ownerArray.removeAll(keepingCapacity: false)
                self.towardArray.removeAll(keepingCapacity: false)
                
                
                // found related objects
                for object in objects! {
                    self.usernameArray.append(object.object(forKey: "by") as! String)
                    self.avaArray.append(object.object(forKey: "ava") as! PFFile)
                    self.typeArray.append(object.object(forKey: "type") as! String)
                    self.dateArray.append(object.createdAt)
                    self.uuidArray.append(object.object(forKey: "uuid") as! String)
                    self.ownerArray.append(object.object(forKey: "owner") as! String)
                    self.towardArray.append(object.object(forKey: "to") as! String)
                    
                    // save notifications as checked
                    object["checked"] = "yes"
                    object.saveInBackground()
                }
                
            }
        })
        
        
        let root = PFUser.current()!.username!
        let followQuery = PFQuery(className: "follow")
        followQuery.whereKey("follower", equalTo: root)
        
        //usersQuery.limit = 20
        followQuery.findObjectsInBackground (block: { (objects, error) -> Void in
            if error == nil {
                // clean up
                self.usernameArray.removeAll(keepingCapacity: false)
                self.avaArray.removeAll(keepingCapacity: false)

                var newsQueryList = [PFQuery]()

                if (objects?.count != 0){
                    for object in objects! {
                        let elementQuery = PFQuery(className:"news")
                        elementQuery.whereKey("by", equalTo: object.value(forKey: "following") as! String )
                        elementQuery.whereKey("to", notEqualTo: PFUser.current()!.username!)
                        newsQueryList.append(elementQuery)
                    }
                    let listQuery = PFQuery.orQuery(withSubqueries: newsQueryList)
                    //get sub followers
                    listQuery.findObjectsInBackground (block: { (objects2, error2) -> Void in
                        if error2 == nil {
                            
                            // found related objects
                            for object2 in objects2! {
                                self.usernameArray.append(object2.object(forKey: "by") as! String)
                                self.avaArray.append(object2.object(forKey: "ava") as! PFFile)
                                self.typeArray.append(object2.object(forKey: "type") as! String)
                                self.dateArray.append(object2.createdAt)
                                self.uuidArray.append(object2.object(forKey: "uuid") as! String)
                                self.ownerArray.append(object2.object(forKey: "owner") as! String)
                                self.towardArray.append(object2.object(forKey: "to") as! String)
                            }
                            // reload tableView to show received data
                            self.tableView.reloadData()
                        }
                    })
                }else{
                    self.tableView.reloadData()
                }

                
            } else {print(error!.localizedDescription)}
        })
    }

    
    // cell numb
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernameArray.count
    }
    
    
    // cell config
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // declare cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! newsCell

        // connect cell objects with received data from server
        cell.usernameBtn.setTitle(usernameArray[indexPath.row], for: UIControlState())
        cell.toUserBtn.setTitle(towardArray[indexPath.row], for: UIControlState())
        avaArray[indexPath.row].getDataInBackground { (data, error) -> Void in
            if error == nil {
                cell.avaImg.image = UIImage(data: data!)
            } else {
                print(error!.localizedDescription)
            }
        }
        
        // calculate post date
        let from = dateArray[indexPath.row]
        let now = Date()
        let components : NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfMonth]
        let difference = (Calendar.current as NSCalendar).components(components, from: from!, to: now, options: [])
        
        // logic what to show: seconds, minuts, hours, days or weeks
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
        
        var isYou=(towardArray[indexPath.row]==PFUser.current()!.username!)
        var callName = towardArray[indexPath.row]
        if isYou {
            callName = "you"
        }
        // define info text
        if typeArray[indexPath.row] == "mention" {
            cell.infoLbl.text = "has mentioned " + callName + "."
        }
        if typeArray[indexPath.row] == "comment" {
            if isYou{
                cell.infoLbl.text = "has commented your post."
            }else{
                cell.infoLbl.text = "has commented "+callName+"'s post."
            }
        }
        if typeArray[indexPath.row] == "follow" {
            cell.infoLbl.text = "now following "+callName+"."
        }
        if typeArray[indexPath.row] == "like" {
            
            if isYou {
                cell.infoLbl.text = "likes your post."
            }else{
                cell.infoLbl.text = "likes "+callName+"'s post."
            }
        }
        
        
        // asign index of button
        cell.usernameBtn.layer.setValue(indexPath, forKey: "index")

        return cell
    }

    
    // clicked username button
    @IBAction func usernameBtn_click(_ sender: AnyObject) {
        
        // call index of button
        let i = sender.layer.value(forKey: "index") as! IndexPath

        
        // call cell to call further cell data
        let cell = tableView.cellForRow(at: i) as! newsCell
        
        // if user tapped on himself go home, else go guest
        if cell.usernameBtn.titleLabel?.text == PFUser.current()?.username {
            let home = self.storyboard?.instantiateViewController(withIdentifier: "homeVC") as! homeVC
            self.navigationController?.pushViewController(home, animated: true)
        } else {
            guestname.append(cell.usernameBtn.titleLabel!.text!)
            let guest = self.storyboard?.instantiateViewController(withIdentifier: "guestVC") as! guestVC
            self.navigationController?.pushViewController(guest, animated: true)
        }
    }
    
    //click toUserBtn
    
    @IBAction func toUserBtn_clicked(_ sender: AnyObject) {
        // call index of button
        let i = sender.layer.value(forKey: "index") as! IndexPath

        // call cell to call further cell data
        let cell = tableView.cellForRow(at: i) as! newsCell
        
        // if user tapped on himself go home, else go guest
        if cell.toUserBtn.titleLabel?.text == PFUser.current()?.username {
            let home = self.storyboard?.instantiateViewController(withIdentifier: "homeVC") as! homeVC
            self.navigationController?.pushViewController(home, animated: true)
        } else {
            guestname.append(cell.toUserBtn.titleLabel!.text!)
            let guest = self.storyboard?.instantiateViewController(withIdentifier: "guestVC") as! guestVC
            self.navigationController?.pushViewController(guest, animated: true)
        }
    }
    
    
    
    // clicked cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // call cell for calling cell data
        let cell = tableView.cellForRow(at: indexPath) as! newsCell
        
        
        // going to @menionted comments
        if cell.infoLbl.text == "has mentioned you." {
            
            // send related data to gloval variable
            commentuuid.append(uuidArray[indexPath.row])
            commentowner.append(ownerArray[indexPath.row])
            
            // go comments
            let comment = self.storyboard?.instantiateViewController(withIdentifier: "commentVC") as! commentVC
            self.navigationController?.pushViewController(comment, animated: true)
        }
        
        
        // going to own comments
        if cell.infoLbl.text == "has commented your post." {
            
            // send related data to gloval variable
            commentuuid.append(uuidArray[indexPath.row])
            commentowner.append(ownerArray[indexPath.row])
            
            // go comments
            let comment = self.storyboard?.instantiateViewController(withIdentifier: "commentVC") as! commentVC
            self.navigationController?.pushViewController(comment, animated: true)
        }
        
        
        // going to user followed current user
        if cell.infoLbl.text == "now following you." {
            
            // take guestname
            guestname.append(cell.usernameBtn.titleLabel!.text!)
            
            // go guest
            let guest = self.storyboard?.instantiateViewController(withIdentifier: "guestVC") as! guestVC
            self.navigationController?.pushViewController(guest, animated: true)
        }
        
        
        // going to liked post
        if cell.infoLbl.text == "likes your post." {
            
            // take post uuid
            postuuid.append(uuidArray[indexPath.row])
            
            // go post
            let post = self.storyboard?.instantiateViewController(withIdentifier: "postVC") as! postVC
            self.navigationController?.pushViewController(post, animated: true)
        }
        
    }

}
