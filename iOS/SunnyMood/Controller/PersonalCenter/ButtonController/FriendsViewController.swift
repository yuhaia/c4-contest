//
//  FriendsViewController.swift
//  SunnyMood
//
//  Created by bytedance on 2020/6/19.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import UIKit
import PolioPager
import Alamofire
import SwiftyJSON

class FriendsViewController: PolioPagerViewController {

    var token: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func tabItems() -> [TabItem] {
            return [TabItem(isSearchTab: true, title: "", image: UIImage(named: "search.png")), TabItem(title: "关注"), TabItem(title: "粉丝"), TabItem(title: "用户")]
        }
        override func viewControllers() -> [UIViewController] {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let searchUserVC = storyboard.instantiateViewController(withIdentifier: "searchUserVC")
            let followedUserVC = storyboard.instantiateViewController(withIdentifier: "followedUserVC")
            let fansUserVC = storyboard.instantiateViewController(withIdentifier: "fansUserVC")
            
            let recommendUserTVC = storyboard.instantiateViewController(withIdentifier: "recommendUserVC")
            return [searchUserVC, followedUserVC, fansUserVC, recommendUserTVC]
        }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
