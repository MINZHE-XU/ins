//  COMP90018 Mobile Computing Systems Programming
//  hashtagsVC.swift
//  Instragram viewer Project
//  the University Of Melbourne
//  Created by Minzhe Xu on 25/9/18.
//  Copyright © 2018 Group 18. All rights reserved.
//

import UIKit
import Parse

var hashtag = [String]()

class hashtagsVC: UICollectionViewController {
    
    // Defining UI objects
    var refresher : UIRefreshControl!
    var page : Int = 24
    
    // Arrays to hold data from the server
    var picArray = [PFFile]()
    var uuidArray = [String]()
    var filterArray = [String]()
    
    
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // able to pull down even if few post are there
        self.collectionView?.alwaysBounceVertical = true
        
        // title at the top
        self.navigationItem.title = "#" + "\(hashtag.last!.uppercased())"
        
        // new back button:
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(image: UIImage(named: "back.png"), style: .plain, target: self, action: #selector(hashtagsVC.back(_:)))
        self.navigationItem.leftBarButtonItem = backBtn
        
        // swipe to go back:
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(hashtagsVC.back(_:)))
        backSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(backSwipe)
        
        // pull to refresh page
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(hashtagsVC.refresh), for: UIControlEvents.valueChanged)
        collectionView?.addSubview(refresher)
        
        // call loading hashtags function
        loadHashtags()
    }
    
    
    // defining the back function
    @objc func back(_ sender : UIBarButtonItem) {
        
        // pushing back
        _ = self.navigationController?.popViewController(animated: true)
        
        // clean hashtag, or deduct the last guest userame from guestname = Array
        if !hashtag.isEmpty {
            hashtag.removeLast()
        }
    }
    
    
    // defining refresh function
    @objc func refresh() {
        loadHashtags()
    }

    
    // loading hashtags function
    func loadHashtags() {
                
        // STEP 1: Find posts related to hashtags
        let hashtagQuery = PFQuery(className: "hashtags")
        hashtagQuery.whereKey("hashtag", equalTo: hashtag.last!)
        hashtagQuery.findObjectsInBackground (block: { (objects, error) -> Void in
            if error == nil {
                
                // cleaning up!
                self.filterArray.removeAll(keepingCapacity: false)
                
                // store related posts in the filterArray
                for object in objects! {
                    self.filterArray.append(object.value(forKey: "to") as! String)
                }
                
                //STEP 2: Find posts that have UUID appended to the filterArray
                let query = PFQuery(className: "posts")
                query.whereKey("uuid", containedIn: self.filterArray)
                query.limit = self.page
                query.addDescendingOrder("createdAt")
                query.findObjectsInBackground(block: { (objects, error) -> Void in
                    if error == nil {
                        
                        // cleaning up!
                        self.picArray.removeAll(keepingCapacity: false)
                        self.uuidArray.removeAll(keepingCapacity: false)
                        
                        // find relating objects
                        for object in objects! {
                            self.picArray.append(object.value(forKey: "pic") as! PFFile)
                            self.uuidArray.append(object.value(forKey: "uuid") as! String)
                        }
                        
                        // reload
                        self.collectionView?.reloadData()
                        self.refresher.endRefreshing()
                        
                    } else {
                        print(error?.localizedDescription ?? String())
                    }
                })
            } else {
                print(error?.localizedDescription ?? String())
            }
        })
        
    }
    

    // scrolling down
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height / 3 {
            loadMore()
        }
    }
    
    
    // pagination
    func loadMore() {
        
        // if posts on the server are more than those shown on screen
        if page <= uuidArray.count {
            
            // increase the size of the page
            page = page + 15
            
            // STEP 1: Find posts related to hashtags
            let hashtagQuery = PFQuery(className: "hashtags")
            hashtagQuery.whereKey("hashtag", equalTo: hashtag.last!)
            hashtagQuery.findObjectsInBackground (block: { (objects, error) -> Void in
                if error == nil {
                    
                    // cleaning up!
                    self.filterArray.removeAll(keepingCapacity: false)
                    
                    // store relating posts in the filterArray
                    for object in objects! {
                        self.filterArray.append(object.value(forKey: "to") as! String)
                    }
                    
                    //STEP 2: Find posts that have UUID appended to the filterArray
                    let query = PFQuery(className: "posts")
                    query.whereKey("uuid", containedIn: self.filterArray)
                    query.limit = self.page
                    query.addDescendingOrder("createdAt")
                    query.findObjectsInBackground(block: { (objects, error) -> Void in
                        if error == nil {
                            
                            // cleaning up!
                            self.picArray.removeAll(keepingCapacity: false)
                            self.uuidArray.removeAll(keepingCapacity: false)
                            
                            // find relating objects
                            for object in objects! {
                                self.picArray.append(object.value(forKey: "pic") as! PFFile)
                                self.uuidArray.append(object.value(forKey: "uuid") as! String)
                            }
                            
                            // then reload
                            self.collectionView?.reloadData()
                            
                        } else {
                            print(error?.localizedDescription ?? String())
                        }
                    })
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
    
    
    // cell config
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // defining cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! pictureCell
        
        // get picture from the picArray
        picArray[indexPath.row].getDataInBackground { (data, error) -> Void in
            if error == nil {
                cell.picImg.image = UIImage(data: data!)
            }
        }
        
        return cell
    }

    
    // go to post
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // send post UUID to the "postuuid" variable
        postuuid.append(uuidArray[indexPath.row])
        
        // navigate to the post view controller
        let post = self.storyboard?.instantiateViewController(withIdentifier: "postVC") as! postVC
        self.navigationController?.pushViewController(post, animated: true)
    }

}
