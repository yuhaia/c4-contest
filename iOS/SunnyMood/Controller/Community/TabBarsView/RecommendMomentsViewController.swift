//
//  RecommendMomentsViewController.swift
//  SunnyMood
//
//  Created by bytedance on 2020/6/18.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MJRefresh

//每月书籍
struct BookPreview {
    var title:String
    var images:[String]
}
class RecommendMomentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        return self.books.count
        return self.moments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "momentCell", for: indexPath) as! MomentTVC
        cell.selectionStyle = .none
        cell.frame = tableView.bounds
        cell.layoutIfNeeded()
        
        
        // 这里的交互点击 和 cell里面collectionview cell里的image添加的点击事件都没反应啊～
        cell.userAvatarImageView.tag = indexPath.row
        cell.userAvatarImageView.isUserInteractionEnabled = true
        cell.userAvatarImageView.addGestureRecognizer(UIGestureRecognizer.init(target: self, action: #selector(toUsersPersonalMomentsPage)))
        //        cell.imgEditCar.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(editCar(_:))))
        
        //        cell.reloadData(userName: books[indexPath.row].title, userAvatarPath: "pic1", images: books[indexPath.row].images)
        
        cell.reloadData(moment: self.moments[indexPath.row], navigationController: self.navigationController)
        return cell
    }
    // 现在知只是单纯查看他发过的动态 toMomentsSegue
    @objc func toUsersPersonalMomentsPage(_ tap: UITapGestureRecognizer) {
        let avatarImageView = tap.view as! UIImageView
        let row = avatarImageView.tag
        self.user_tapped_row = row
        print("点击查看第\(self.user_tapped_row!)行的用户的个人动态主页")
        performSegue(withIdentifier: "toMomentsSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.user_tapped_row = indexPath.row
        performSegue(withIdentifier: "toMomentsSegue", sender: self)
        print("在大的tableview cell里点击查看第\(self.user_tapped_row!)行的用户的个人动态主页")
    }
    @IBOutlet weak var momentsTableView: UITableView!
    
    //所有书籍数据
    let books = [
        BookPreview(title: "五月新书", images: ["pic1.jpg","pic2.jpg", "pic3.jpg",
                                                    "pic4.jpg","pic5.jpg","pic6.jpg"]),
        BookPreview(title: "六月新书", images: ["pic1.jpg", "pic2.jpg", "pic3.jpg"]),
        BookPreview(title: "七月新书", images: ["pic1.jpg", "pic2.jpg", "pic3.jpg", "pic4.jpg"])
    ]
    
    var config = Configuration()
    var takeUserInfo = TakeUserInfo()
    var moments = [MomentModel]()
    var user_tapped_row: Int?
    
    // 顶部刷新
    let header = MJRefreshNormalHeader()
    // 底部加载
    let footer = MJRefreshAutoNormalFooter()
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.requestRecommendData(skip: 0)
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
    
        //下拉刷新相关设置
        header.setRefreshingTarget(self, refreshingAction: #selector(headerRefresh))
        self.momentsTableView!.mj_header = header
        
        //上拉刷新相关设置
        footer.setRefreshingTarget(self, refreshingAction: #selector(footerLoad))
        //是否自动加载（默认为true，即表格滑到底部就自动加载）
        footer.isAutomaticallyRefresh = true
        self.momentsTableView!.mj_footer = footer
    }
    
    //顶部下拉刷新
        @objc func headerRefresh(){
            print("下拉刷新...")
            self.requestRecommendData(skip: 0)
            //结束刷新
    //        self.collectionView!.mj_header!.endRefreshing()
        }
    
    //底部上拉加载
    @objc func footerLoad(){
        print("上拉加载.")
        // 请求并添加数据
        
        let skip = self.moments.count
        self.requestRecommendData(skip: skip)
        //
        //        self.tableView!.reloadData()
        //        //结束刷新
        //        self.tableView!.mj_footer!.endRefreshing()
    }
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
        if (segue.identifier == "toMomentsSegue") {
            let destination = segue.destination as! PersonalMomentsViewController
            let selected_moment = self.moments[self.user_tapped_row!]
            let user_res = selected_moment.user_info!
            let user_id = user_res["_id"].string!
            destination.user_id = user_id
            
            var user_info = UserModel()
            user_info._id = user_res["_id"].string!
            user_info.name = user_res["name"].string!
            user_info.avatar = user_res["avatar"].string!
            user_info.bio = user_res["bio"].string!
            
            destination.user_info = user_info
        }
     }
     
    
    func requestRecommendData(skip: Int) {
        if (skip == 0) {
            self.moments = [MomentModel]()
        }
//        let url = config.url + "moment/getAllMoments"
        let url = config.url + "moment/getRecommendMoments"
        let token = UserDefaults.standard.object(forKey: "token") as? String
        let headers = ["token": token!]
        let limit = config.limit
        let parameters = ["skip": String(skip), "limit": String(limit)]

        Alamofire.request(url, method: .get, parameters: parameters, headers: headers).responseJSON {
            response in
            if response.result.isSuccess {
                print("后台连接成功")
                let resultData = try? JSONSerialization.data(withJSONObject: response.result.value!, options: .prettyPrinted)
                if let resultJson = try? JSON.init(data: resultData!) {
                    if let error = resultJson["error"].string {
                        print("error: \(error)")
                        
                        let alertController = UIAlertController(title: "暂无推荐信息", message: "请稍等几日", preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertController.addAction(defaultAction)
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        if let momentDatas = resultJson["data"].array {
                            print("请求到的moments结果的data字段：\(momentDatas)")
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
                                moment.user_info = momentData["user_info"]
                                //                                print("aaaaa user_info:")
                                //                                print(momentData)
                                
                                //                                print(moment.user_info)
                                
                                var pictures = [String]()
                                for pic in momentData["pictures"].array! {
                                    pictures.append(pic.string!)
                                }
                                moment.pictures = pictures
                                //                                moment.printInfo()
                                
                                self.moments.append(moment)
                            }
                            self.momentsTableView.reloadData()
                            self.momentsTableView!.mj_header!.endRefreshing()
                            self.momentsTableView!.mj_footer!.endRefreshing()
                            
                            if (momentDatas.count == 0) {
                                self.momentsTableView!.mj_footer!.endRefreshingWithNoMoreData()
                            }
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
