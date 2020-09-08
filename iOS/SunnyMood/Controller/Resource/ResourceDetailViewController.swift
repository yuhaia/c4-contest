//
//  ResourceDetailViewController.swift
//  SunnyMood
//
//  Created by bytedance on 2020/5/17.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import UIKit
import SDWebImage
import Alamofire
import SwiftyJSON

protocol ValueBackDelegate {
    func valueBack(selectedIndex: Int, like: String, likes_number: String) // like = "1" means user like the resource
}

class ResourceDetailViewController: UIViewController {
    @IBOutlet weak var resourceImageView: UIImageView!
    @IBOutlet weak var resourceNameLabel: UILabel!
    @IBOutlet weak var resourceAuthorLabel: UILabel!
    @IBOutlet weak var resourceLikeIconButton: UIButton!
    @IBOutlet weak var linkButton: UIButton!
    @IBOutlet weak var resourceLabelsLabel: UILabel!
    @IBOutlet weak var resourceDesLabel: UILabel!
    @IBOutlet weak var relatedCommunitiesButton: UIButton!
    @IBOutlet weak var createCommunityButton: UIButton!
    
    var valueBackDelegate: ValueBackDelegate?
    
    var selectedIndex: Int? {
        didSet {
            print("the index you tapped is \(String(describing: selectedIndex))")
        }
    }
    var old_likes: String? // 喜欢该资源的人数
    var current_likes = 0 // 当前喜欢该资源的人数
    var old_user_like: String?
    var now_user_like: String? // 浏览该页面的用户是否喜欢 喜欢为"1" 否则为"0"
    var resource: ResourceModel?

    let config = Configuration()
    var user: UserModel?
    let userInfo = TakeUserInfo()
    
    @IBAction func UserTapLikeAction(_ sender: UIButton) {
        print("user tapped the like icon")
        if let now_user_like = self.now_user_like, now_user_like == "1" {
            self.now_user_like = "0"
            self.current_likes = self.current_likes - 1
            print("self.now_user_like: \(String(describing: self.now_user_like))")
            self.resourceLikeIconButton.setImage(UIImage(systemName: "star"), for: .normal)
            self.resourceLikeIconButton.setTitle(" " + String(self.current_likes) + "人", for: .normal)
        } else {
            self.now_user_like = "1"
            self.current_likes = self.current_likes + 1
            self.resourceLikeIconButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            self.resourceLikeIconButton.setTitle(String(self.current_likes) + "人", for: .normal)
        }
    }
    
    @IBAction func UserTapLinkAction(_ sender: UIButton) {
        if let url = URL(string: (self.resource?.link!)!) {
            UIApplication.shared.open(url)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.relatedCommunitiesButton.setImage(UIImage(systemName: "person.2"), for: .normal)
        self.relatedCommunitiesButton.setTitle(" 相关小组", for: .normal)
        self.relatedCommunitiesButton.imageEdgeInsets = UIEdgeInsets(top: 3, left: 0, bottom: 0, right: 8)

        
        self.createCommunityButton.setImage(UIImage(systemName: "person.badge.plus"), for: .normal)
        self.createCommunityButton.setTitle("   创建小组", for: .normal)
        self.createCommunityButton.imageEdgeInsets = UIEdgeInsets(top: 3, left: 0, bottom: 0, right: 8)
        
        self.old_likes = self.resource?.likes!
        self.current_likes = Int((self.resource?.likes)!) ?? 0
        
        if self.resource?.isUserLike == "1" {
            self.now_user_like = "1"
            self.resourceLikeIconButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        } else {
            self.now_user_like = "0"
            self.resourceLikeIconButton.setImage(UIImage(systemName: "star"), for: .normal)
        }
        self.resourceLikeIconButton.imageView?.contentMode = .scaleAspectFill
        self.resourceLikeIconButton.setTitle(String(self.current_likes) + "人", for: .normal)
        
        self.linkButton.imageView?.contentMode = .scaleAspectFill
        let picture_url = URL(string: (resource?.picture_url!)!)
        self.resourceImageView?.sd_setImage(with: picture_url!, completed: nil)
        self.resourceNameLabel?.text = resource?.name!
        self.resourceNameLabel?.font = UIFont.boldSystemFont(ofSize: 24.0)
        
        self.resourceAuthorLabel?.text = "作者：" + (resource?.author!)!
        self.resourceLabelsLabel?.text = "类别：" + (resource?.labels!)!
        
        self.resourceDesLabel?.layer.cornerRadius = 4
        self.resourceDesLabel?.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        self.resourceDesLabel?.lineBreakMode = .byTruncatingTail
        self.resourceDesLabel?.text = (resource?._description!)! + "\n\n\n\n"
        
        self.takeOutUser()
        print("resource:")
        resource?.printInfo()
    }
    
    func takeOutUser() {
        self.user = self.userInfo.user
    }
    
    @IBAction func toRelatedCommuAction(_ sender: UIButton) {
        if (self.resource?.communities_id?.count == 0) {
            let alertController = UIAlertController(title: "没有相关小组", message: "你可以选择创建围绕该资源的小组", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            performSegue(withIdentifier: "toRelatedCommuSegue", sender: sender)
        }
    }
    
    @IBAction func toCreateCommuAction(_ sender: UIButton) {
        let resource_name = (self.resource?.name)!
        let def = UserDefaults.standard
        def.set(resource_name, forKey: "community_resource_name")
        performSegue(withIdentifier: "toCreateCommunitySegue", sender: sender)
    }
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     
        if (segue.identifier == "toRelatedCommuSegue") {
            let destination = segue.destination as! ResourceRelatedCommunitiesCVC
            destination.resource_id = (self.resource?._id)!
        } else if (segue.identifier == "toCreateCommunitySegue") {
            let destination = segue.destination as! CreateCommunityViewController
            print("segue to CreateCommunityViewController")
            // 这样传不过去给SwiftForms
//            destination.already_has_resource = true
//            let resource_name = (self.resource?.name)!
//            destination.default_resource_name = resource_name
        }
     }
     
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        var now_likes: String?
        var like_number: Int?
        var url: String?
        let token = UserDefaults.standard.object(forKey: "token") as? String
        let headers = ["token": token!]
        let parameters = ["resource_id": (self.resource?._id)!]
        
        if self.old_user_like != self.now_user_like {
            if self.now_user_like! == "1" {
                like_number = Int(self.old_likes!)
                now_likes = String(like_number! + 1)
                url = self.config.url + "likes/likeResource"
                self.resource?.isUserLike = "1"
            } else {
                like_number = Int(self.old_likes!)
                now_likes = String(like_number! - 1)
                url = self.config.url + "likes/dislikeResource"
                self.resource?.isUserLike = "0"
            }
            
            // like or dislike resource
            Alamofire.request(url!, method: .post, parameters: parameters as Parameters, headers: headers).responseJSON {
                    response in
                    if response.result.isSuccess {
                        print("send to backend to update likes successfully")
                    } else {
                        print("update failed...")
                    }
            }
            
            let updateLikesURL = self.config.url + "resources/updateLikes"
            let likes = now_likes!
            let updateLikesParameters = ["resource_id": (self.resource?._id)!, "likes": likes]
            // updateLikes of resource
            Alamofire.request(updateLikesURL, method: .post, parameters: updateLikesParameters as Parameters).responseJSON {
                response in
                if response.result.isSuccess {
                    print("send to backend to update likes of resource successfully")
                } else {
                    print("update likes of resoruce failed...")
                }
            }
            
            self.valueBackDelegate?.valueBack(selectedIndex: selectedIndex!, like: self.now_user_like!, likes_number: now_likes!)
        }
    }
}
