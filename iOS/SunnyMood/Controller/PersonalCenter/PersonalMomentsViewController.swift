//
//  PersonalMomentsViewController.swift
//  SunnyMood
//
//  Created by bytedance on 2020/6/19.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage

class PersonalMomentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        return self.books.count
        return self.moments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "momentCell", for: indexPath) as! MomentTVC
        
        cell.frame = tableView.bounds
        cell.layoutIfNeeded()
        
        //        cell.reloadData(userName: books[indexPath.row].title, userAvatarPath: "pic1", images: books[indexPath.row].images)
        
        cell.reloadData(moment: self.moments[indexPath.row], navigationController: self.navigationController)
        return cell
    }
    
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var momentsTableView: UITableView!
    
    var user_id: String?        // user_id必须要传过来
    var user_info: UserModel?   // 如果是自己查看自己的就需要user_info 这样不用请求网络啦
    
    var config = Configuration()
    var moments = [MomentModel]()
    var followed: Int?
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.requestMomentsData()
        let local_user_id = UserDefaults.standard.object(forKey: "_id") as! String
        if (self.user_id! == local_user_id) {
            // 本人查看本人
            self.followButton.isHidden = true
            let avatar_string = self.user_info?.avatar
            self.avatarImageView.sd_setImage(with: URL(string: avatar_string!), placeholderImage: UIImage(named: "pic4"), completed: nil)
            self.nameLabel.text = self.user_info?.name
            self.bioLabel.text = self.user_info?.bio
        } else {
            self.followButton.layer.cornerRadius = 15.0
            self.followButton.clipsToBounds = true
            self.followButton.setTitleColor(#colorLiteral(red: 0.9999127984, green: 1, blue: 0.9998814464, alpha: 1), for: .normal)
//            self.followButton.setAttributedTitle(<#T##title: NSAttributedString?##NSAttributedString?#>, for: <#T##UIControl.State#>)
            // 本人查看他人，获取到用户信息后在主线程更新ui
            self.requestUserInfo()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.momentsTableView.delegate = self
        self.momentsTableView.dataSource = self
        
        self.momentsTableView.separatorStyle = .none
        
        self.momentsTableView.register(UINib(nibName: "MomentTVC", bundle: nil), forCellReuseIdentifier: "momentCell")
        
        self.momentsTableView.estimatedRowHeight = 44.0
        self.momentsTableView.rowHeight = UITableView.automaticDimension
        
        self.avatarImageView.layer.cornerRadius = 5.0
    }
    
    func requestUserInfo() {
        let url = config.url + "users/getUserByID"
        let token = UserDefaults.standard.object(forKey: "token") as! String
        let request_user_id = UserDefaults.standard.object(forKey: "_id") as? String
        let headers = ["token": token]
        let parameters = ["user_id": self.user_id!, "ios": "1", "request_user_id": request_user_id!]
        Alamofire.request(url, method: .get, parameters: parameters, headers: headers).responseJSON {
            response in
            if response.result.isSuccess {
                print("后台连接成功")
                let resultData = try? JSONSerialization.data(withJSONObject: response.result.value!, options: .prettyPrinted)
                if let resultJson = try? JSON.init(data: resultData!) {
                    if let error = resultJson["error"].string {
                        print("error: \(error)")
                    } else {
                        let user_res = resultJson["data"]
                        var user_info = UserModel()
                        user_info._id = user_res["_id"].string!
                        user_info.name = user_res["name"].string!
                        user_info.avatar = user_res["avatar"].string!
                        user_info.bio = user_res["bio"].string!
                        
                        self.user_info = user_info
                        
                        self.followed = resultJson["followed"].int!
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                            let avatar_string = self.user_info!.avatar
                            let name = self.user_info!.name
                            let bio = self.user_info!.bio
                            self.avatarImageView.sd_setImage(with: URL(string: avatar_string), completed: nil)
                            self.nameLabel.text = name
                            self.bioLabel.text = bio
                            print("获取到用户信息并更新了ui中的头像等信息")
                            
                            // 确定是否关注
                            if (self.followed == 1) {
                                self.followButton.setTitle("已关注", for: .normal)
                                
//                                self.followButton.titleLabel?.text = "已关注"
                                
                                self.followButton.backgroundColor = #colorLiteral(red: 0.8783541918, green: 0.8784807324, blue: 0.8783264756, alpha: 1)
//                                self.followButton.titleLabel?.backgroundColor
                            } else {
                                self.followButton.setTitle("关注", for: .normal)
                                
//                                self.followButton.titleLabel?.text = "关注"
                                
                                self.followButton.backgroundColor = #colorLiteral(red: 0.658742249, green: 0.7372956276, blue: 0.6783480048, alpha: 1)
//                                self.followButton.titleLabel?.backgroundColor = #colorLiteral(red: 0.658742249, green: 0.7372956276, blue: 0.6783480048, alpha: 1)
                            }
                        }
                    }
                }
            } else {
                print("error!!!")
            }
        }
    }
    
    func requestMomentsData() {
        let url = config.url + "moment/getMomentsByUserID"
        let parameters = ["user_id": self.user_id!]
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("后台连接成功")
                let resultData = try? JSONSerialization.data(withJSONObject: response.result.value!, options: .prettyPrinted)
                if let resultJson = try? JSON.init(data: resultData!) {
                    if let error = resultJson["error"].string {
                        print("error: \(error)")
                        
                        let alertController = UIAlertController(title: "暂无动态信息", message: "hhh", preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertController.addAction(defaultAction)
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        if let momentDatas = resultJson["data"].array {
                            print("请求到的moments结果的data字段：\(momentDatas)")
                            let user_info = resultJson["user_info"]
                            print("user_info:")
                            print(user_info)
                            var index = 0
                            for momentData in momentDatas {
                                index += 1
                                
                                let moment = MomentModel()
                                moment._id = momentData["_id"].string!
                                moment.user_id = momentData["user_id"].string!
                                moment.texts = momentData["texts"].string!
                                moment.time = momentData["time"].number!
                                moment.pictures_number = momentData["pictures"].count
                                moment.praises = momentData["praises"].int!
                                moment.user_info = user_info
                                
                                var pictures = [String]()
                                for pic in momentData["pictures"].array! {
                                    pictures.append(pic.string!)
                                }
                                moment.pictures = pictures
                                //                                moment.printInfo()
                                
                                self.moments.append(moment)
                            }
                            self.momentsTableView.reloadData()
                        }
                    }
                }
            } else {
                print("后台连接失败")
                let alertController = UIAlertController(title: "后台连接失败", message: "请稍后", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func followHimAction(_ sender: UIButton) {
        if let followed = self.followed {
            if followed == 0 {
                self.followButton.setTitle("已关注", for: .normal)
//                self.followButton.titleLabel?.text = "已关注"
                self.followButton.backgroundColor = #colorLiteral(red: 0.8783541918, green: 0.8784807324, blue: 0.8783264756, alpha: 1)
                let url = self.config.url + "follow/followHim"
                let token = UserDefaults.standard.object(forKey: "token") as! String
                let headers = ["token": token]
                let followed_id = self.user_id!
                let parameters = ["followed_id": followed_id]
                Alamofire.request(url, method: .post, parameters: parameters, headers: headers).responseJSON {
                    response in
                    if response.result.isSuccess {
                        print("follow him successfully")
                        self.followed = 1
                    } else {
                        print("follow him failed...")
                    }
                }
            } else {
                self.followButton.setTitle("关注", for: .normal)
                self.followButton.backgroundColor = #colorLiteral(red: 0.658742249, green: 0.7372956276, blue: 0.6783480048, alpha: 1)
                let url = self.config.url + "follow/disfollowHim"
                let token = UserDefaults.standard.object(forKey: "token") as! String
                let headers = ["token": token]
                let followed_id = self.user_id!
                let parameters = ["followed_id": followed_id]
                Alamofire.request(url, method: .post, parameters: parameters, headers: headers).responseJSON {
                    response in
                    if response.result.isSuccess {
                        print("disfollow him successfully")
                        self.followed = 0
                    } else {
                        print("disfollow him failed...")
                    }
                }
            }
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
