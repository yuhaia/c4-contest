//
//  CommunityDetailViewController.swift
//  SunnyMood
//
//  Created by bytedance on 2020/6/18.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MJRefresh

class CommunityDetailViewController: UIViewController {
    
    var community: CommunityModel?
    var config = Configuration()
    var isMember = false
    var takeUserInfo = TakeUserInfo()
    var moments = [MomentModel]()
    var user_tapped_row: Int?
    
    @IBOutlet weak var communityAvatarImageView: UIImageView!
    @IBOutlet weak var sponsorAvatarImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var memberCountLabel: UILabel!
    @IBOutlet weak var desLabel: UILabel!
    
    @IBOutlet weak var frequencyLabel: UILabel!
    @IBOutlet weak var coinsNeededLabel: UILabel!
    @IBOutlet weak var addCommunityButton: UIButton!
    @IBOutlet weak var toWriteMomentButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    
    @IBOutlet weak var momentsTableView: UITableView!
    
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
        
        self.initPage()
        
        self.momentsTableView.delegate = self
        self.momentsTableView.dataSource = self
        
        self.momentsTableView.separatorStyle = .none
        
        self.momentsTableView.register(UINib(nibName: "MomentTVC", bundle: nil), forCellReuseIdentifier: "momentCell")
        
        self.momentsTableView.estimatedRowHeight = 44.0
        self.momentsTableView.rowHeight = UITableView.automaticDimension
        
        // Do any additional setup after loading the view.
        
        //上拉刷新相关设置
        footer.setRefreshingTarget(self, refreshingAction: #selector(footerLoad))
        //是否自动加载（默认为true，即表格滑到底部就自动加载）
        footer.isAutomaticallyRefresh = true
        self.momentsTableView!.mj_footer = footer
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
    
    func requestRecommendData(skip: Int) {
        let url = config.url + "moment/getMomentsByCommunityID"
        let community_id = self.community?.id
        let parameters = ["community_id": community_id!]
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
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
    
    func initPage() {
        //        print("community in detail page:")
        //        print(self.community)
        let avatarURL = URL(string: (self.community?.avatar)!)
        self.communityAvatarImageView.sd_setImage(with: avatarURL, placeholderImage: UIImage(named: "pic1.jpg"), completed: nil)
        self.communityAvatarImageView.layer.cornerRadius = 5.0
        
        self.nameLabel.text = self.community?.name
        
        let sponsor_info = self.community?.sponsor_info
        let sponsor_avatar_url = sponsor_info?["avatar"].string!
        let sponsorAvatarURL = URL(string: sponsor_avatar_url!)
        self.sponsorAvatarImageView.sd_setImage(with: sponsorAvatarURL, placeholderImage: UIImage(named: "pic2.jpg"), completed: nil)
        self.sponsorAvatarImageView.layer.cornerRadius = self.sponsorAvatarImageView.frame.width / 2
        
        self.desLabel.text = self.community?.des
        let member_count = self.community?.users_id?.count
        self.memberCountLabel.text = "等" + String(member_count ?? 1) + "人"
        self.frequencyLabel.text = "每周" + String(self.community?.frequency ?? 2) + "次"
        self.coinsNeededLabel.text =  String(self.community?.coins_needed ?? 5) + "枚"
        
        let isMember = self.community?.isMember
        self.isMember = isMember!
        if (self.isMember == true) {
            self.addCommunityButton.setImage(UIImage(systemName: "trash.circle"), for: .normal)
            self.addCommunityButton.setTitle("退出", for: .normal)
            
            self.toWriteMomentButton.isHidden = false
            self.toWriteMomentButton.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        } else {
            self.addCommunityButton.setImage(UIImage(systemName: "plus.circle"), for: .normal)
            self.addCommunityButton.setTitle("加入", for: .normal)
            
            self.toWriteMomentButton.isHidden = true
        }
        
        self.addCommunityButton.imageEdgeInsets = UIEdgeInsets(top: 3, left: 0, bottom: 0, right: 8)
        self.toWriteMomentButton.imageEdgeInsets = UIEdgeInsets(top: 3, left: 0, bottom: 0, right: 8)
        self.shareButton.imageEdgeInsets = UIEdgeInsets(top: 3, left: 0, bottom: 0, right: 8)
        
        self.shareButton.setImage(UIImage(systemName: "arrowshape.turn.up.right.circle"), for: .normal)
        self.shareButton.setTitle("分享", for: .normal)
    }
    
    
    @IBAction func addCommunityAction(_ sender: UIButton) {
        if (self.isMember == true) {
            // 用户要退出小组
            let alertController = UIAlertController(title: "确认退出么", message: "提前退出会扣除" + String((self.community?.coins_needed)!) + "枚金币", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            
            // 退出小组
            let token = UserDefaults.standard.object(forKey: "token") as! String
            let header = ["token": token]
            let url = self.config.url + "community/removeUser"
            let community_id = self.community?.id
            let parameters = ["community_id": community_id!]
            Alamofire.request(url, method: .post, parameters: parameters, headers: header).responseJSON {
                response in
                if response.result.isSuccess {
                    print("后台连接成功")
                    let resultData = try? JSONSerialization.data(withJSONObject: response.result.value!, options: .prettyPrinted)
                    if let resultJson = try? JSON.init(data: resultData!) {
                        if let error = resultJson["error"].string {
                            print("error: \(error)")
                            
                            let alertController = UIAlertController(title: "退出失败", message: "请退出app重新运行", preferredStyle: .alert)
                            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                            alertController.addAction(defaultAction)
                            self.present(alertController, animated: true, completion: nil)
                        } else {
                            let alertController = UIAlertController(title: "退出成功!",
                                                                    message: nil, preferredStyle: .alert)
                            //显示提示框
                            self.present(alertController, animated: true, completion: nil)
                            //1秒钟后自动消失
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                                self.presentedViewController?.dismiss(animated: false, completion: nil)
                                self.isMember = false
                                self.addCommunityButton.setImage(UIImage(systemName: "plus.circle"), for: .normal)
                                self.addCommunityButton.setTitle("加入", for: .normal)
                                
                                self.toWriteMomentButton.isHidden = true
                            }
                        }
                    }
                }
            }
        } else {
            // 加入小组
            let token = UserDefaults.standard.object(forKey: "token") as! String
            let header = ["token": token]
            let url = self.config.url + "community/addUser"
            let community_id = self.community?.id
            let parameters = ["community_id": community_id!]
            Alamofire.request(url, method: .post, parameters: parameters, headers: header).responseJSON {
                response in
                if response.result.isSuccess {
                    print("后台连接成功")
                    let resultData = try? JSONSerialization.data(withJSONObject: response.result.value!, options: .prettyPrinted)
                    if let resultJson = try? JSON.init(data: resultData!) {
                        if let error = resultJson["error"].string {
                            print("error: \(error)")
                            
                            let alertController = UIAlertController(title: "加入失败", message: "请退出重新运行", preferredStyle: .alert)
                            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                            alertController.addAction(defaultAction)
                            self.present(alertController, animated: true, completion: nil)
                        } else {
                            let alertController = UIAlertController(title: "加入成功!",
                                                                    message: nil, preferredStyle: .alert)
                            //显示提示框
                            self.present(alertController, animated: true, completion: nil)
                            //1秒钟后自动消失
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                                self.presentedViewController?.dismiss(animated: false, completion: nil)
                                self.isMember = true
                                self.addCommunityButton.setImage(UIImage(systemName: "trash.circle"), for: .normal)
                                self.addCommunityButton.setTitle("退出", for: .normal)
                                
                                self.toWriteMomentButton.isHidden = false
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    @IBAction func toWriteMomentAction(_ sender: UIButton) {
        if (self.isMember == true) {
            performSegue(withIdentifier: "toWriteMomentSegue", sender: sender)
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "toWriteMomentSegue") {
            let destination = segue.destination as! CreateMomentViewController
            // 额 应该统一到destination分配就好了
            var commus = [community_basic_info]()
            let commu = community_basic_info(id: (self.community?.id)!, name: (self.community?.name)!)
            commus.append(commu)
            destination.communities_basic_info = commus
            var names = [String]()
            for community in commus {
                names.append(community.name)
            }
            destination.communities_name = names
            
            print("commus: ")
            print(commus)
            print("communities_name to create moment:")
            print(names)
        } else if (segue.identifier == "toMomentsSegue") {
            let destination = segue.destination as! PersonalMomentsViewController
            let selected_moment = self.moments[self.user_tapped_row!]
            let user_res = selected_moment.user_info!
            let user_id = user_res["_id"].string!
            destination.user_id = user_id
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension CommunityDetailViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.user_tapped_row = indexPath.row
        performSegue(withIdentifier: "toMomentsSegue", sender: self)
        print("在大的tableview cell里点击查看第\(self.user_tapped_row!)行的用户的个人动态主页")
    }
    
}
