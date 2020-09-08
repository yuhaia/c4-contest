//
//  ChooseMomentOrCommunityToAddVC.swift
//  SunnyMood
//
//  Created by bytedance on 2020/5/21.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

struct community_basic_info {
    var id: String
    var name: String
}

class ChooseMomentOrCommunityToCreateVC: UIViewController {
    
    var token = ""
    var config = Configuration()
    var communities_basic_info = [community_basic_info]()  // 如果用户要发打卡动态，我要往下一个页面传递小组信息 这样用户可以选择在哪个小组打卡
    @IBAction func createMomentAction(_ sender: UIButton) {
        // 查看用户是否有加入的小组，如果没有便提醒用户创建或者加入小组
        if (self.communities_basic_info.count == 0) {
            let alertController = UIAlertController(title: "您还未创建或参与小组，无法发布打卡动态", message: "", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            performSegue(withIdentifier: "createMomentSegue", sender: self)
        }
    }
    @IBAction func createCommunityAction(_ sender: UIButton) {
        performSegue(withIdentifier: "createCommunitySegue", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestData()
    }
    
    func requestData() {
        let url = config.url + "users/verifyToken"
        let token = UserDefaults.standard.object(forKey: "token") as? String
        let headers = ["token": token!]
        
        Alamofire.request(url, method: .get, headers: headers).responseJSON {
            response in
            if response.result.isSuccess {
                print("后台连接成功")
                let resultData = try? JSONSerialization.data(withJSONObject: response.result.value!, options: .prettyPrinted)
                if let resultJson = try? JSON.init(data: resultData!) {
                    //                    print("resultJson: \(resultJson)")
                    if let error = resultJson["error"].string {
                        print("token有误")
                        print("error: \(error)")
                        let signin_url = self.config.url + "users/signin"
                        let user_name = UserDefaults.standard.object(forKey: "name") as? String
                        
                        let def = UserDefaults.standard
                        def.set("hhhhhh", forKey: "password")
                        
                        let user_password = UserDefaults.standard.object(forKey: "password") as? String
                        
                        print("userName: \(String(describing: user_name)) password: \(String(describing: user_password))")
                        
                        let parameters = ["name": user_name!, "password": user_password!]
                        Alamofire.request(signin_url, method: .post, parameters: parameters).responseJSON {
                            response in
                            if response.result.isSuccess {
                                print("后台连接成功")
                                let resultData = try? JSONSerialization.data(withJSONObject: response.result.value!, options: .prettyPrinted)
                                if let resultJson = try? JSON.init(data: resultData!) {
                                    print("resultJson: \(resultJson)")
                                    
                                    if let error = resultJson["error"].string {
                                        print("error: \(error)")
                                    } else {
                                        let new_token = resultJson["data"]["token"].string!
                                        self.token = new_token
                                        let def = UserDefaults.standard
                                        def.set(true, forKey: "is_authenticated")
                                        def.set(new_token, forKey: "token")
                                        self.getCommunities()
                                    }
                                }
                            } else {
                                print("后台连接失败")
                            }
                        }
                    } else {
                        print("token正常")
                        self.token = token!
                        self.getCommunities()
                    }
                }
            } else {
                print("后台连接失败")
            }
        }
    }
    
    func getCommunities() {
        let url = config.url + "community/getCommunitiesByToken"
        let headers = ["token": self.token]
        Alamofire.request(url, method: .get, headers: headers).responseJSON {
            response in
            if response.result.isSuccess {
                print("后台连接成功")
                let resultData = try? JSONSerialization.data(withJSONObject: response.result.value!, options: .prettyPrinted)
                if let resultJson = try? JSON.init(data: resultData!) {
                    print("resultJson: \(resultJson)")
                    
                    if let error = resultJson["error"].string {
                        print("error: \(error)")
                    } else {
                        let communities = resultJson["data"].array!
                        print("communities: ")
                        print(communities)
                        for community in communities {
                            let commu = community_basic_info(id: community["_id"].string!, name: community["name"].string!)
                            
                            self.communities_basic_info.append(commu)
                            print("self.communities_basic_info: ")
                            print(self.communities_basic_info)
                        }
                        print(self.communities_basic_info.count)
                    }
                }
            }
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "createMomentSegue" {
            let destination = segue.destination as! CreateMomentViewController
            destination.communities_basic_info = self.communities_basic_info
            var names = [String]()
            for community in self.communities_basic_info {
                names.append(community.name)
            }
            destination.communities_name = names
            destination.disappearDelegate = self
        } else if segue.identifier == "createCommunitySegue" {
            let destination = segue.destination as! CreateCommunityViewController
            destination.disappearDelegate = self
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //    override func viewWillDisappear(_ animated: Bool) {
    //        self.dismiss(animated: true, completion: nil)
    //    }
    
}

extension ChooseMomentOrCommunityToCreateVC: DisappearDelegate {
    func disappear() {
        self.dismiss(animated: false, completion: nil);
    }
}
