//
//  MyViewController.swift
//  SunnyMood
//
//  Created by bytedance on 2020/5/12.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage

class MyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.person.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "personCell", for: indexPath) as! PersonCenterTableViewCell
        
        cell.frame = tableView.bounds
        cell.selectionStyle = .none
        cell.layoutIfNeeded()
        
        cell.reloadData(icon: self.icons[indexPath.row], listName: self.person[indexPath.row])
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // ["测评", "喜欢", "小组", "打卡动态", "设置", "帮助与反馈", "退出登录"]
        if (indexPath.row == 0) {
//            performSegue(withIdentifier: "toReportsListSegue", sender: self)
        } else if (indexPath.row == 1) {
            performSegue(withIdentifier: "toMyLikesResourceSegue", sender: self)
        } else if (indexPath.row == 2) {
            performSegue(withIdentifier: "toMyCommunitiesSegue", sender: self)
        } else if (indexPath.row == 3) {
            performSegue(withIdentifier: "toMomentsSegue", sender: self)
        } else if (indexPath.row == 4) {
            performSegue(withIdentifier: "toSettingSegue", sender: self)
        } else if (indexPath.row == 5) {
            performSegue(withIdentifier: "toHelpSegue", sender: self)
        } else if (indexPath.row == 6) {
            print("退出登录")
            self.logout()
        }
    }
    
    
    @IBAction func touchMessageAction(_ sender: UIButton) {
        let alertController = UIAlertController(title: "暂未开通消息机制", message: "请耐心等待下一版本", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func touchFriendsAction(_ sender: UIButton) {
        performSegue(withIdentifier: "toFriendsSegue", sender: self)
    }
    
    
    @IBAction func touchCoinsAction(_ sender: UIButton) {
        performSegue(withIdentifier: "toCoinsSegue", sender: self)
    }
    
    @IBAction func touchMedalAction(_ sender: UIButton) {
        performSegue(withIdentifier: "toMedalSegue", sender: self)
    }
    
    
    
    var user:UserModel?
    let userInfo = TakeUserInfo()
    
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    
    
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var friendsButton: UIButton!
    @IBOutlet weak var coinsButton: UIButton!
    @IBOutlet weak var medalButton: UIButton!
    
    
    @IBOutlet weak var myTableView: UITableView!
    
    var person = ["测评", "喜欢", "小组", "打卡动态", "设置", "帮助与反馈", "退出登录"]
    var icons = ["evaluation", "like", "community", "moment", "setting", "help", "exit"]
    
    var items = ["消息", "好友", "金币", "勋章"]
    var items_icon = ["message", "friends", "coins", "medal"]
    
//    @IBAction func logOutAction(_ sender: UIButton) {
//        let def = UserDefaults.standard
//        def.removeObject(forKey: "is_authenticated")
//        def.synchronize()
//
//        let sceneDelegate = self.view.window?.windowScene?.delegate as! SceneDelegate
//        sceneDelegate.switchRVC2SINV()
//    }
    
    func logout() {
        let def = UserDefaults.standard
        def.removeObject(forKey: "is_authenticated")
        def.synchronize()
        
        let sceneDelegate = self.view.window?.windowScene?.delegate as! SceneDelegate
        sceneDelegate.switchRVC2SINV()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("my view page")
        self.user = self.userInfo.user
        self.user?.printInfo()
        
        self.myTableView.delegate = self
        self.myTableView.dataSource = self
        
        self.myTableView.separatorStyle = .none
        
        self.myTableView.register(UINib(nibName: "PersonCenterTableViewCell", bundle: nil), forCellReuseIdentifier: "personCell")
        
        self.myTableView.estimatedRowHeight = 44.0
        self.myTableView.rowHeight = UITableView.automaticDimension
        
        let user = self.userInfo.user!
        self.avatarImageView.sd_setImage(with: URL(string: user.avatar), placeholderImage: UIImage(named: "pic3"), completed: nil)
        self.topImageView.sd_setImage(with: URL(string: user.avatar), placeholderImage: UIImage(named: "pic3"), completed: nil)
        self.avatarImageView.layer.cornerRadius = 5.0
        self.topImageView.layer.cornerRadius = 5.0
        self.nameLabel.text = user.name
        self.bioLabel.text = user.bio
        
        
        self.messageButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15) //文字大小
        //        self.messageButton.setTitleColor(UIColor.orangeColor(), forState: UIControlState.Normal) //文字颜色
        self.messageButton.set(image: UIImage(systemName: "message"), title: "消息", titlePosition: .bottom, additionalSpacing: 10.0, state: [.normal])
        
        self.friendsButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        self.friendsButton.set(image: UIImage(systemName: "person"), title: "好友", titlePosition: .bottom, additionalSpacing: 10.0, state: [.normal])
        
//        self.followsButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15) //文字大小
//        //        self.messageButton.setTitleColor(UIColor.orangeColor(), forState: UIControlState.Normal) //文字颜色
//        self.followsButton.set(image: UIImage(systemName: "person"), title: "关注", titlePosition: .bottom,
//                               additionalSpacing: 10.0, state: [.normal])
//
//        self.fansButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15) //文字大小
//        //        self.messageButton.setTitleColor(UIColor.orangeColor(), forState: UIControlState.Normal) //文字颜色
//        self.fansButton.set(image: UIImage(systemName: "person.crop.circle"), title: "粉丝", titlePosition: .bottom,
//                            additionalSpacing: 10.0, state: [.normal])
        
        
        self.coinsButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15) //文字大小
        //        self.messageButton.setTitleColor(UIColor.orangeColor(), forState: UIControlState.Normal) //文字颜色
        self.coinsButton.set(image: UIImage(systemName: "bitcoinsign.square"), title: "金币", titlePosition: .bottom,
                             additionalSpacing: 10.0, state: [.normal])
        self.medalButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        self.medalButton.set(image: UIImage(systemName: "flame"), title: "勋章", titlePosition: .bottom,
        additionalSpacing: 10.0, state: [.normal])
        
    }
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
        if (segue.identifier == "toMomentsSegue") {
            let destination = segue.destination as! PersonalMomentsViewController
            destination.user_id = self.user?._id
            destination.user_info = self.user
        } else if (segue.identifier == "toCoinsSegue") {
            let destination = segue.destination as! CoinsViewController
            destination.user_info = self.user
        }
     }
     
    
}

extension UIButton {
    
    @objc func set(image anImage: UIImage?, title: String,
                   titlePosition: UIView.ContentMode, additionalSpacing: CGFloat, state: UIControl.State){
        self.imageView?.contentMode = .scaleAspectFill
        self.setImage(anImage, for: state)
        
        positionLabelRespectToImage(title: title, position: titlePosition, spacing: additionalSpacing)
        
        self.titleLabel?.contentMode = .center
        self.setTitle(title, for: state)
    }
    
    private func positionLabelRespectToImage(title: String, position: UIView.ContentMode,
                                             spacing: CGFloat) {
        let imageSize = self.imageRect(forContentRect: self.frame)
        let titleFont = self.titleLabel?.font!
        let titleSize = title.size(withAttributes: [NSAttributedString.Key.font: titleFont!])
        
        var titleInsets: UIEdgeInsets
        var imageInsets: UIEdgeInsets
        
        switch (position){
        case .top:
            titleInsets = UIEdgeInsets(top: -(imageSize.height + titleSize.height + spacing),
                                       left: -(imageSize.width), bottom: 0, right: 0)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -titleSize.width)
        case .bottom:
            titleInsets = UIEdgeInsets(top: (imageSize.height + titleSize.height + spacing),
                                       left: -(imageSize.width), bottom: 0, right: 0)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -titleSize.width)
        case .left:
            titleInsets = UIEdgeInsets(top: 0, left: -(imageSize.width * 2), bottom: 0, right: 0)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0,
                                       right: -(titleSize.width * 2 + spacing))
        case .right:
            titleInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -spacing)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        default:
            titleInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        
        self.titleEdgeInsets = titleInsets
        self.imageEdgeInsets = imageInsets
    }
}

