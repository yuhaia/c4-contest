//
//  ResourceViewController.swift
//  SunnyMood
//
//  Created by bytedance on 2020/5/12.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import UIKit
import PolioPager
import Alamofire
import SwiftyJSON

class ResourceViewController: PolioPagerViewController {
    
    var userModel: UserModel?
    var config = Configuration()
    var resources = [ResourceModel]()
    
    override func tabItems() -> [TabItem] {
        return [TabItem(isSearchTab: true, title: "", image: UIImage(named: "search.png")), TabItem(title: "书籍"), TabItem(title: "电影"), TabItem(title: "课程"), TabItem(title: "正念"), TabItem(title: "我喜欢的")]
    }
    
    override func viewControllers() -> [UIViewController] {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let searchViewController = storyboard.instantiateViewController(withIdentifier: "searchResourceView")
        let bookViewController = storyboard.instantiateViewController(withIdentifier: "bookCollectionView")
        let movieViewController = storyboard.instantiateViewController(withIdentifier: "movieCollectionView")
        let courseViewController = storyboard.instantiateViewController(withIdentifier: "courseCollectionView")
        let exerciseViewController = storyboard.instantiateViewController(withIdentifier: "exerciseCollectionView")
        let myLikesViewController = storyboard.instantiateViewController(withIdentifier: "MyLikesResourceCVC")
        return [searchViewController, bookViewController, movieViewController, courseViewController, exerciseViewController, myLikesViewController]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.takeOutUser()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func takeOutUser() {
        let def = UserDefaults.standard
        if let _id = def.object(forKey: "_id") as? String {
            let name = def.object(forKey: "name") as! String
            let bio = def.object(forKey: "bio") as! String
            let gender = def.object(forKey: "gender") as! String
            let professor = def.object(forKey: "professor") as! String
            let avatar = def.object(forKey: "avatar") as! String
            let fans_number = def.object(forKey: "fans_number") as! String
            let follow_number = def.object(forKey: "follow_number") as! String
            let coins = def.object(forKey: "coins") as! Int

            self.userModel = UserModel(_id: _id, name: name, bio: bio, avatar: avatar, gender: gender, professor: professor, fans_number: fans_number, follow_number: follow_number, coins: coins)
        }
    }
}
