//
//  ViewController.swift
//  SunnyMood
//
//  Created by bytedance on 2020/5/11.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

// TODO: 加个indicator表示在进行网络请求
class SignInViewController: UIViewController {
    @IBOutlet weak var userNameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var wechatImageView: UIImageView!
    @IBOutlet weak var weiboImageView: UIImageView!
    @IBOutlet weak var zhifubaoImageView: UIImageView!
    
    var configuration = Configuration()
    var userName: String?
    var password: String?
    var url: String?
    var userModel = UserModel()
    var token = ""
    
    @IBAction func done(){
        self.passwordText.resignFirstResponder()
    }
    
    @IBAction func signIn(_ sender: UIButton) {
        print("url: \(configuration.url)")
        self.url = configuration.url + "users/signin"
        self.userName = userNameText.text
        self.password = passwordText.text
        print("userName: \(String(describing: userName)) password: \(String(describing: password))")
        
        let parameters = ["name": self.userName!, "password": self.password!]
        Alamofire.request(url!, method: .post, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("后台连接成功")
                let resultData = try? JSONSerialization.data(withJSONObject: response.result.value!, options: .prettyPrinted)
                if let resultJson = try? JSON.init(data: resultData!) {
                    print("resultJson: \(resultJson)")
                    
                    if let error = resultJson["error"].string {
                        print("error: \(error)")
                        
                        let alertController = UIAlertController(title: "昵称或密码错误", message: "请输入正确的昵称及密码", preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertController.addAction(defaultAction)
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        let user_info = resultJson["data"]["user_info"]
                        self.userModel._id = user_info["_id"].string!
                        self.userModel.name = user_info["name"].string!
                        self.userModel.bio = user_info["bio"].string!
                        self.userModel.avatar = user_info["avatar"].string!
                        self.userModel.gender = user_info["gender"].string!
                        self.userModel.professor = user_info["professor"].string!
                        self.userModel.fans_number = user_info["fans_number"].string!
                        self.userModel.follow_number = user_info["follow_number"].string!
                        self.userModel.coins = user_info["coins"].int!

                        
                        self.token = resultJson["data"]["token"].string!
                        
                        self.saveLoggedUserState()
                        // 切换根视图的话会影响segue的传值
                        let sceneDelegate = self.view.window?.windowScene?.delegate as! SceneDelegate
                        sceneDelegate.switchRVC2TBC()
                        self.performSegue(withIdentifier: "SignInToHomeSegue", sender: self)
                    }
                }
            } else {
                
                print("后台连接失败")
                let alertController = UIAlertController(title: "后台连接失败", message: "请重试", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func saveLoggedUserState() {
        let def = UserDefaults.standard
        def.set(true, forKey: "is_authenticated")
        def.set(self.token, forKey: "token")
        def.set(self.userModel._id, forKey: "_id")
        def.set(self.userModel.name, forKey: "name")
        def.set(self.userModel.bio, forKey: "bio")
        def.set(self.userModel.gender, forKey: "gender")
        def.set(self.userModel.professor, forKey: "professor")
        def.set(self.userModel.avatar, forKey: "avatar")
        def.set(self.userModel.fans_number, forKey: "fans_number")
        def.set(self.userModel.follow_number, forKey: "follow_number")
        def.set(self.userModel.coins, forKey: "coins")

        //        def.setValue(self.userModel, forKey: "userInfo")  // 不能存储复杂的数据
        def.synchronize()
    }
    @IBAction func signUp(_ sender: UIButton) {
        performSegue(withIdentifier: "SignUpSegue", sender: sender)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        signinButton.layer.cornerRadius = 4
        signupButton.layer.cornerRadius = 4
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let def = UserDefaults.standard
        let is_authenticated = def.bool(forKey: "is_authenticated")
        if is_authenticated {
            self.verifyToken()
            let sceneDelegate = self.view.window?.windowScene?.delegate as! SceneDelegate
            sceneDelegate.switchRVC2TBC()
        }
        
        
//        let url = "https://xinqing.today/v1.0/users/getAllUsers"
//        Alamofire.request(url, method: .get).responseJSON {
//            response in
//            if response.result.isSuccess {
//                print("后台连接成功")
//                let resultData = try? JSONSerialization.data(withJSONObject: response.result.value!, options: .prettyPrinted)
//                if let resultJson = try? JSON.init(data: resultData!) {
//                    print("resultJson: \(resultJson)")
//
//                    if let error = resultJson["error"].string {
//                        print("error: \(error)")
//
//                        let alertController = UIAlertController(title: "昵称或密码错误", message: "请输入正确的昵称及密码", preferredStyle: .alert)
//                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//                        alertController.addAction(defaultAction)
//                        self.present(alertController, animated: true, completion: nil)
//                    } else {
//                        //                    self.userModel._id = resultJson["data"]["_id"].string!
//                        //                    self.userModel.name = resul
//                    }
//                }
//            }
//
//        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userNameText.layer.cornerRadius = 15.0
        self.passwordText.layer.cornerRadius = 15.0
        
        self.signupButton.layer.borderWidth = 1.0
        self.signupButton.layer.borderColor = #colorLiteral(red: 0.6610732675, green: 0.7325825095, blue: 0.6741165519, alpha: 1)
        self.signupButton.layer.cornerRadius = self.signupButton.layer.frame.size.height / 2.0
        self.signupButton.clipsToBounds = true
        
        self.signinButton.layer.borderWidth = 1.0
        self.signinButton.layer.borderColor = #colorLiteral(red: 0.6610732675, green: 0.7325825095, blue: 0.6741165519, alpha: 1)
        self.signinButton.layer.cornerRadius = 15.0
        self.signinButton.clipsToBounds = true
        
        let wechatClick = UITapGestureRecognizer(target: self, action: #selector(wechatSignInAction))
        self.wechatImageView.addGestureRecognizer(wechatClick)
        //开启 isUserInteractionEnabled 手势否则点击事件会没有反应
        self.wechatImageView.isUserInteractionEnabled = true
        
        let weiboClick = UITapGestureRecognizer(target: self, action: #selector(weiboSignInAction))
        self.weiboImageView.addGestureRecognizer(weiboClick)
        self.weiboImageView.isUserInteractionEnabled = true
        
        let zhifubaoClick = UITapGestureRecognizer(target: self, action: #selector(zhifubaoSignInAction))
        self.zhifubaoImageView.addGestureRecognizer(zhifubaoClick)
        self.zhifubaoImageView.isUserInteractionEnabled = true
    }
    
    @objc func wechatSignInAction() -> Void {
        print("wechat icon 点击事件")
        let alertController = UIAlertController(title: "暂未开通该服务", message: "请注册或登录本机账号", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func weiboSignInAction() -> Void {
        print("weibo icon 点击事件")
        let alertController = UIAlertController(title: "暂未开通该服务", message: "请注册或登录本机账号", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func zhifubaoSignInAction() -> Void {
        print("zhifubao icon 点击事件")
        let alertController = UIAlertController(title: "暂未开通该服务", message: "请注册或登录本机账号", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func verifyToken() {
        // 验证token
        let url = configuration.url + "users/verifyToken"
        let token = UserDefaults.standard.object(forKey: "token") as? String
        let headers = ["token": token!]
        
        Alamofire.request(url, method: .get, headers: headers).responseJSON {
            response in
            if response.result.isSuccess {
                print("后台连接成功")
                let resultData = try? JSONSerialization.data(withJSONObject: response.result.value!, options: .prettyPrinted)
                if let resultJson = try? JSON.init(data: resultData!) {
                    print("resultJson: \(resultJson)")
                    if let error = resultJson["error"].string {
                        print("token有误")
                        print("error: \(error)")
                        //                       let alertController = UIAlertController(title: "token有误", message: "", preferredStyle: .alert)
                        
                        let signin_url = self.configuration.url + "users/signin"
                        let user_name = UserDefaults.standard.object(forKey: "name") as? String
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
                                        print("token: \(new_token)")
                                        let def = UserDefaults.standard
                                        def.set(true, forKey: "is_authenticated")
                                        def.set(new_token, forKey: "token")
                                    }
                                    
                                }
                            } else {
                                print("后台连接失败")
                            }
                        }
                    } else {
                        print("token正常")
                        print("token: \(token)")
                    }
                }
            } else {
                print("后台连接失败")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("into sign up view")
        self.navigationItem.setHidesBackButton(true, animated: true)
        if segue.identifier == "SignInToHomeSegue" {
            print("prepare to home page...")
            // 切换根视图的话这里segue传值就没用了
            let barViewControllers = segue.destination as! UITabBarController
            let evaluationVC = ((segue.destination as! UITabBarController).viewControllers![0] as! UINavigationController).topViewController as! EvaluationViewController
            evaluationVC.userModel = self.userModel
            //                evaluationVC.test = "hhhhhhaaaa"
            
            //            let barViewControllers = segue.destination as! UITabBarController
            //            let nav0 = barViewControllers.viewControllers![0] as! UINavigationController
            //            let evaluationVC = nav0.topViewController as! EvaluationViewController
            //
            //            evaluationVC.userModel = self.userModel
            //            evaluationVC.test = "hhhhhhaaaa"
            // 经过上一步之后userModel是有值的，应该是切换root view时把signin view给删除了
            
            
            let nav1 = barViewControllers.viewControllers![1] as! UINavigationController
            let resourceVC = nav1.topViewController as! ResourceViewController
            resourceVC.userModel = self.userModel
            
            let nav2 = barViewControllers.viewControllers![2] as! UINavigationController
            let communityVC = nav2.topViewController as! CommunityViewController
            communityVC.userModel = self.userModel
            
            let nav3 = barViewControllers.viewControllers![3] as! UINavigationController
            let myVC = nav3.topViewController as! MyViewController
            myVC.user = self.userModel
            
            
            //            if let barViewControllers = segue.destination as? UITabBarController {
            //                barViewControllers.viewControllers?.forEach {
            //                    if let vc = $0 as? YourViewController {
            //                        // pass data
            //                    }
            //                }
            //            }
            
        }
    }
}

