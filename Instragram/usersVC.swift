//  COMP90018 Mobile Computing Systems Programming
//  usersVC.swift
//  Instragram viewer Project
//  the University Of Melbourne
//  Created by Minzhe Xu on 26/9/18.
//  Copyright © 2018 Group 18. All rights reserved.
//

import UIKit
import Parse


class usersVC: UITableViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // declaring the search bar
    var searchBar = UISearchBar()
    
    // defining tableView arrays to hold information from server
    var usernameArray = [String]()
    var avaArray = [PFFile]()
    var countArray = [Int]()
    
    // declaring the collectionView UI
    var collectionView : UICollectionView!
    
    // collectionView arrays to hold server information
    var picArray = [PFFile]()
    var uuidArray = [String]()
    var page : Int = 15
    var isNoFolloing=true

    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // implement a search bar
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.tintColor = UIColor.groupTableViewBackground
        searchBar.frame.size.width = self.view.frame.size.width - 34
        let searchItem = UIBarButtonItem(customView: searchBar)
        self.navigationItem.leftBarButtonItem = searchItem
        
        // call functions
        loadUsers()
        
        //call collectionView
        //collectionViewLaunch()
        //collectionView.isHidden = true
    }
    
    
    
    // SEARCHING part
    // loadusers function
    func loadUsers() {
        
        
        let root = PFUser.current()!.username!
        let followQuery = PFQuery(className: "follow")
        followQuery.whereKey("follower", equalTo: root)
        
        //usersQuery.limit = 20
        followQuery.findObjectsInBackground (block: { (objects, error) -> Void in
            if error == nil {
                
                // cleaning up
                self.usernameArray.removeAll(keepingCapacity: false)
                self.avaArray.removeAll(keepingCapacity: false)
                self.countArray.removeAll(keepingCapacity: false)
                var subFollowingList=[String]()
                var followingQueryList = [PFQuery]()
                
                if objects?.count==0{
                    let elementQuery = PFQuery(className:"follow")
                    followingQueryList.append(elementQuery)
                    self.isNoFolloing=true
                }else{
                    for object in objects! {
                        let elementQuery = PFQuery(className:"follow")
                        elementQuery.whereKey("follower", equalTo: object.value(forKey: "following") as! String )
                        followingQueryList.append(elementQuery)
                    }
                    self.isNoFolloing=false
                }
                let listQuery = PFQuery.orQuery(withSubqueries: followingQueryList)
                
                //get sub followers:
                listQuery.findObjectsInBackground (block: { (objects2, error2) -> Void in
                    if error2 == nil {
                        var userQueryList = [PFQuery]()
                        
                        for object2 in objects2! {
                            subFollowingList.append(object2.value(forKey: "following") as! String)
                            let elementQuery2 = PFQuery(className:"_User")
                            elementQuery2.whereKey("username", equalTo: object2.value(forKey: "following") as! String )
                            userQueryList.append(elementQuery2)
                        }
                        //print(subFollowingList)
                        let subFollowingUser = self.order(strList:subFollowingList ,ruleOut:root).sorted { $0.1 > $1.1 }
                        //print(subFollowingUser)
                        
                        let listUserQuery = PFQuery.orQuery(withSubqueries: userQueryList)
                        
                        // get sub follower information
                        listUserQuery.findObjectsInBackground (block: { (objects3, error3) -> Void in
                            if error3 == nil {
                            
                                for u in subFollowingUser {
                                    for object3 in objects3! {
                                        let obUserName = object3.value(forKey: "username") as! String
                                        if obUserName == u.key {
                                            self.usernameArray.append(obUserName)
                                            self.avaArray.append(object3.object(forKey: "ava") as! PFFile)
                                            self.countArray.append(u.value)
                                        }
                                        
                                    }
                                }
                                self.tableView.reloadData()
                            } else {print(error3!.localizedDescription)}
                        })
           
                    } else {print(error2!.localizedDescription)}
                })
                
            } else {print(error!.localizedDescription)}
        })
    }
    

    
    // updated search
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // find by username
        let usernameQuery = PFQuery(className: "_User")
        usernameQuery.whereKey("username", matchesRegex: "(?i)" + searchBar.text!)
        usernameQuery.findObjectsInBackground (block: { (objects, error) -> Void in
            if error == nil {
                
                // if no objects are found according to entered text in username colomn,
                // find them by fullname
                if objects!.isEmpty {

                    let fullnameQuery = PFUser.query()
                    fullnameQuery?.whereKey("fullname", matchesRegex: "(?i)" + self.searchBar.text!)
                    fullnameQuery?.findObjectsInBackground(block: { (objects, error) -> Void in
                        if error == nil {
                            
                            // cleaning up!
                            self.usernameArray.removeAll(keepingCapacity: false)
                            self.avaArray.removeAll(keepingCapacity: false)
                            self.countArray.removeAll(keepingCapacity: false)
                            
                            // find relating objects
                            for object in objects! {
                                self.usernameArray.append(object.object(forKey: "username") as! String)
                                self.avaArray.append(object.object(forKey: "ava") as! PFFile)
                                self.countArray.append(0)
                                
                            }
                            
                            // reload:
                            self.tableView.reloadData()
                            
                        }
                    })
                }
                
                // cleaning up!
                self.usernameArray.removeAll(keepingCapacity: false)
                self.avaArray.removeAll(keepingCapacity: false)
                self.countArray.removeAll(keepingCapacity: false)
                
                // find relating objects
                for object in objects! {
                    self.usernameArray.append(object.object(forKey: "username") as! String)
                    self.avaArray.append(object.object(forKey: "ava") as! PFFile)
                    self.countArray.append(0)
                }
                
                // reload:
                self.tableView.reloadData()
                
            }
        })
        
        return true
    }
    
    // tap on the searchBar
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        // hide collectionView when starting search
        //collectionView.isHidden = true
        
        // show the cancel button
        searchBar.showsCancelButton = true
    }
    
    
    // clicked the cancel button
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        //unhide collectionView when tapped cancel button
        //collectionView.isHidden = false
        
        // dismiss phone keyboard
        searchBar.resignFirstResponder()
        
        // hide the cancel button
        searchBar.showsCancelButton = false
        
        // text reset
        searchBar.text = ""
        
        // reset users shown
        loadUsers()
    }
    
    
    
    // TABLEVIEW part
    
    // cell numb
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernameArray.count
    }
    
    // cell height
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.size.width / 4
    }

    // cell config
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // defining cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! followersCell

        // hide follow button
        cell.followBtn.isHidden = true
        
        // connect the cell's objects with received infromation from the server
        cell.usernameLbl.text = usernameArray[indexPath.row]
        var userTail = ""
        if self.isNoFolloing{
            userTail = "user"
        }else{
            userTail = "follower"
        }
        if countArray[indexPath.row]==0 {
             cell.followCountLbl.text = ""
        }else if countArray[indexPath.row]==1{
            cell.followCountLbl.text = "followed by " + "\(countArray[indexPath.row])" + " "+userTail
        }else {
            cell.followCountLbl.text = "followed by " + "\(countArray[indexPath.row])"  + " "+userTail + "s"
        }

        
        avaArray[indexPath.row].getDataInBackground { (data, error) -> Void in
            if error == nil {
                cell.avaImg.image = UIImage(data: data!)
            }
        }
        
        
        return cell
    }

    
    // select tableView cell - then select user
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // calling the cell again for cell data
        let cell = tableView.cellForRow(at: indexPath) as! followersCell
        
        // if a user taps on its name, go home; else go to guest
        if cell.usernameLbl.text! == PFUser.current()?.username {
            let home = self.storyboard?.instantiateViewController(withIdentifier: "homeVC") as! homeVC
            self.navigationController?.pushViewController(home, animated: true)
        } else {
            guestname.append(cell.usernameLbl.text!)
            let guest = self.storyboard?.instantiateViewController(withIdentifier: "guestVC") as! guestVC
            self.navigationController?.pushViewController(guest, animated: true)
        }
    }
    
    /**
    
    // COLLECTION VIEW part
    func collectionViewLaunch() {
     
        // the layout of collectionView
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        // item size
        layout.itemSize = CGSize(width: self.view.frame.size.width / 3, height: self.view.frame.size.width / 3)
        
        // scrolling direction
        layout.scrollDirection = UICollectionViewScrollDirection.vertical
        
        // defining a frame of collectionView
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height - self.tabBarController!.tabBar.frame.size.height - self.navigationController!.navigationBar.frame.size.height - 20)
        
        // declaring collectionView
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .white
        self.view.addSubview(collectionView)
        
        // defining a cell for collectionView
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        // call functions to load posts
        loadPosts()
    }
    */
    
    // cell line spasing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    // cell inter spasing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    // cell numb
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picArray.count
    }
    
    // cell config
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // defining a cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        // creating picture imageView in cell to show loaded pictures
        let picImg = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.frame.size.width, height: cell.frame.size.height))
        cell.addSubview(picImg)
        
        // get loaded images from array
        picArray[indexPath.row].getDataInBackground { (data, error) -> Void in
            if error == nil {
                picImg.image = UIImage(data: data!)
            } else {
                print(error!.localizedDescription)
            }
        }
        
        return cell
    }
    
    // when a cell is selected
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // take relevant unique id of post to load post in postVC
        postuuid.append(uuidArray[indexPath.row])
        
        // present postVC programmaticaly
        let post = self.storyboard?.instantiateViewController(withIdentifier: "postVC") as! postVC
        self.navigationController?.pushViewController(post, animated: true)
    }
    
    // loading posts
    func loadPosts() {
        let query = PFQuery(className: "posts")
        query.limit = page
        query.findObjectsInBackground { (objects, error) -> Void in
            if error == nil {
                
                // cleaning up!
                self.picArray.removeAll(keepingCapacity: false)
                self.uuidArray.removeAll(keepingCapacity: false)
                
                // find relating objects
                for object in objects! {
                    self.picArray.append(object.object(forKey: "pic") as! PFFile)
                    self.uuidArray.append(object.object(forKey: "uuid") as! String)
                }
                
                // reload collectionView to present images
                self.collectionView.reloadData()
                
            } else {
                print(error!.localizedDescription)
            }
        }
    }
    
    // scrolling down
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // scroll down for paging
        if scrollView.contentOffset.y >= scrollView.contentSize.height / 6 {
            self.loadMore()
        }
    }
    
    // pagination
    func loadMore() {
        
        // if more posts are unloaded, we wanna load them
        if page <= picArray.count {
            
            // increase page size
            page = page + 15
            
            // load additional posts
            let query = PFQuery(className: "posts")
            query.limit = page
            query.findObjectsInBackground(block: { (objects, error) -> Void in
                if error == nil {
                    
                    // clean up
                    self.picArray.removeAll(keepingCapacity: false)
                    self.uuidArray.removeAll(keepingCapacity: false)
                    
                    // find related objects
                    for object in objects! {
                        self.picArray.append(object.object(forKey: "pic") as! PFFile)
                        self.uuidArray.append(object.object(forKey: "uuid") as! String)
                    }
                    
                    // reload collectionView to present loaded images
                    self.collectionView.reloadData()
                    
                } else {
                    print(error!.localizedDescription)
                }
            })
            
        }
        
    }
    
    func order(strList:[String],ruleOut:String )-> [String: Int]{
        var followDict = [String: Int]()
        for s in strList {
            if !(s==ruleOut) {
                followDict.updateValue((followDict[s] ?? 0)+1, forKey: s)
            }
        }
        return followDict
    }
    
}
