//  COMP90018 Mobile Computing Systems Programming
//  homeVC.swift
//  Instragram viewer Project
//  the University Of Melbourne
//  Created by Minzhe Xu on 20/9/18.
//  Copyright © 2018 Group 18. All rights reserved.
//

import UIKit
import Parse


class homeVC: UICollectionViewController {

    // Declaring the refresher variable
    var refresher : UIRefreshControl!
    
    // Defining size of pages
    var page : Int = 12
    
    // Defining arrays to hold server information
    var uuidArray = [String]()
    var picArray = [PFFile]()
    
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // always scroll vertically
        self.collectionView?.alwaysBounceVertical = true
        
        // set background color
        collectionView?.backgroundColor = .white

        // title at the top of page
        self.navigationItem.title = PFUser.current()?.username?.uppercased()
        
        // pull to refresh
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(homeVC.refresh), for: UIControlEvents.valueChanged)
        collectionView?.addSubview(refresher)
        
        // receiving notifications from editVC
        NotificationCenter.default.addObserver(self, selector: #selector(homeVC.reload(_:)), name: NSNotification.Name(rawValue: "reload"), object: nil)
        
        
        // loadposts function
        loadPosts()
    }
    
    @objc func refresh() {
        
        // reload posts
        loadPosts()
        
        // stop refresher animation
        refresher.endRefreshing()
    }
    
    
    // reloading func after having received notification
    @objc func reload(_ notification:Notification) {
        collectionView?.reloadData()
    }
    
        
    // load posts func
    func loadPosts() {
        
        // request infomration from the server
        let query = PFQuery(className: "posts")
        query.whereKey("username", equalTo: PFUser.current()!.username!)
        query.limit = page
        query.findObjectsInBackground (block: { (objects, error) -> Void in
            if error == nil {
                
                // cleaning up!
                self.uuidArray.removeAll(keepingCapacity: false)
                self.picArray.removeAll(keepingCapacity: false)
                
                // find objects relating to our request
                for object in objects! {
                    
                    // add found data to arrays (holders)
                    self.uuidArray.append(object.value(forKey: "uuid") as! String)
                    self.picArray.append(object.value(forKey: "pic") as! PFFile)
                }
                
                self.collectionView?.reloadData()

            } else {
                print(error!.localizedDescription)
            }
        })
        
    }
    
    // load more contents while scrolling down
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height {
            loadMore()
        }
    }
    
    // paging
    func loadMore() {
        
        // if there is more objects
        if page <= picArray.count {
            
            // increase the size of pages
            page = page + 12
            
            // loading more posts:
            let query = PFQuery(className: "posts")
            query.whereKey("username", equalTo: PFUser.current()!.username!)
            query.limit = page
            query.findObjectsInBackground(block: { (objects, error) -> Void in
                if error == nil {
                    
                    // cleaning up!
                    self.uuidArray.removeAll(keepingCapacity: false)
                    self.picArray.removeAll(keepingCapacity: false)
                    
                    // find relating objects
                    for object in objects! {
                        self.uuidArray.append(object.value(forKey: "uuid") as! String)
                        self.picArray.append(object.value(forKey: "pic") as! PFFile)
                    }
                    
                    self.collectionView?.reloadData()
                    
                } else {
                    print(error?.localizedDescription ?? String())
                }
            })

        }
        
    }
    
    // cell numb
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picArray.count
    }
    
    
    // cell size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: self.view.frame.size.width / 3, height: self.view.frame.size.width / 3)
        return size
    }
    
    
    // cell configuration
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // defining cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! pictureCell
        
        // get pictures from the picArray
        picArray[indexPath.row].getDataInBackground { (data, error) -> Void in
            if error == nil {
                cell.picImg.image = UIImage(data: data!)
            }
        }
        
        return cell
    }

    
    // header configuration
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        // defining the header
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! headerView
        
        
        // STEP 1: Get user data
        // get users' data with connections to columns of PFuser class
        header.fullnameLbl.text = (PFUser.current()?.object(forKey: "fullname") as? String)?.uppercased()
        header.bioLbl.text = PFUser.current()?.object(forKey: "bio") as? String
        header.bioLbl.sizeToFit()
        let avaQuery = PFUser.current()?.object(forKey: "ava") as! PFFile
        avaQuery.getDataInBackground { (data, error) -> Void in
            header.avaImg.image = UIImage(data: data!)
        }
        header.button.setTitle("edit profile", for: UIControlState())
        
        
        // STEP 2: Count statistics
        // count the number of total posts
        let posts = PFQuery(className: "posts")
        posts.whereKey("username", equalTo: PFUser.current()!.username!)
        posts.countObjectsInBackground (block: { (count, error) -> Void in
            if error == nil {
                header.posts.text = "\(count)"
            }
        })
        
        // counting total followers
        let followers = PFQuery(className: "follow")
        followers.whereKey("following", equalTo: PFUser.current()!.username!)
        followers.countObjectsInBackground (block: { (count, error) -> Void in
            if error == nil {
                header.followers.text = "\(count)"
            }
        })
        
        // and counting total followings
        let followings = PFQuery(className: "follow")
        followings.whereKey("follower", equalTo: PFUser.current()!.username!)
        followings.countObjectsInBackground (block: { (count, error) -> Void in
            if error == nil {
                header.followings.text = "\(count)"
            }
        })
        
        // STEP 3: Implementation of tap gestures
        // tap posts
        let postsTap = UITapGestureRecognizer(target: self, action: #selector(homeVC.postsTap))
        postsTap.numberOfTapsRequired = 1
        header.posts.isUserInteractionEnabled = true
        header.posts.addGestureRecognizer(postsTap)
        
        // tap followers
        let followersTap = UITapGestureRecognizer(target: self, action: #selector(homeVC.followersTap))
        followersTap.numberOfTapsRequired = 1
        header.followers.isUserInteractionEnabled = true
        header.followers.addGestureRecognizer(followersTap)
        
        // tap followings
        let followingsTap = UITapGestureRecognizer(target: self, action: #selector(homeVC.followingsTap))
        followingsTap.numberOfTapsRequired = 1
        header.followings.isUserInteractionEnabled = true
        header.followings.addGestureRecognizer(followingsTap)
        
        return header
    }
    
    
    // tap posts label:
    @objc func postsTap() {
        if !picArray.isEmpty {
            let index = IndexPath(item: 0, section: 0)
            self.collectionView?.scrollToItem(at: index, at: UICollectionViewScrollPosition.top, animated: true)
        }
    }
    
    // tap followers label:
    @objc func followersTap() {
        
        user = PFUser.current()!.username!
        category = "followers"
        
        // make references to followersVC
        let followers = self.storyboard?.instantiateViewController(withIdentifier: "followersVC") as! followersVC
        
        // present
        self.navigationController?.pushViewController(followers, animated: true)
    }
    
    // tap followings label
    @objc func followingsTap() {
        
        user = PFUser.current()!.username!
        category = "followings"
        
        // make reference to followersVC
        let followings = self.storyboard?.instantiateViewController(withIdentifier: "followersVC") as! followersVC

        // present
        self.navigationController?.pushViewController(followings, animated: true)
    }
    
    
    // click log out
    @IBAction func logout(_ sender: AnyObject) {
    
        // implementing log out
        PFUser.logOutInBackground { (error) -> Void in
            if error == nil {
                
                // remove logged user from App memory
                UserDefaults.standard.removeObject(forKey: "username")
                UserDefaults.standard.synchronize()
                
                let signin = self.storyboard?.instantiateViewController(withIdentifier: "signInVC") as! signInVC
                let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = signin
                
            }
        }
        
    }
    
    
    // go to posts
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // send post UUID to "postuuid" variable
        postuuid.append(uuidArray[indexPath.row])
        
        // navigation to the post view controller
        let post = self.storyboard?.instantiateViewController(withIdentifier: "postVC") as! postVC
        self.navigationController?.pushViewController(post, animated: true)
    }
    
}
