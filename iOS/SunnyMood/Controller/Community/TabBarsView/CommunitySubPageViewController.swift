//
//  CommunitySubPageViewController.swift
//  SunnyMood
//
//  Created by bytedance on 2020/8/9.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import UIKit
import SDWebImage
import Alamofire
import SwiftyJSON
import MJRefresh

class CommunitySubPageViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (section == 0) {
            return self.myCommunities.count
        } else {
            return self.recommendedCommunities.count
        }
    }
    
    
    
    //分区的header与footer
    func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        var reusableview:UICollectionReusableView!
         
        //分区头
        if kind == UICollectionView.elementKindSectionHeader{
            reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                        withReuseIdentifier: "HeaderView", for: indexPath)
            //设置头部标题
            let label = reusableview.viewWithTag(1) as! UILabel
            if (indexPath.section == 0) {
                label.text = "我所在的小组"
            } else {
                label.text = "可能感兴趣的小组"
            }
        }
        //分区尾
        else if kind == UICollectionView.elementKindSectionFooter{
            reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                        withReuseIdentifier: "FooterView", for: indexPath)
             
        }
        print("what?")
        return reusableview
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var community = CommunityModel()
        if (indexPath.section == 0) {
            community = self.myCommunities[indexPath.row]
        } else {
            community = self.recommendedCommunities[indexPath.row]
        }
        
        let time_texts = ["06.15 -> 11.03", "06.18 -> 长期", "07.01 -> 12.01"]
        var rangeTime = ""
        if indexPath.row < 3 {
            rangeTime = time_texts[indexPath.row]
        } else {
            rangeTime = time_texts[1]
        }
        
        let cell = self.communityCollectionView.dequeueReusableCell(withReuseIdentifier: "newCommunityCell", for: indexPath) as! CommunityCollectionViewCell
        
        cell.layer.cornerRadius = 20.0
        cell.clipsToBounds = true
        cell.backgroundColor = #colorLiteral(red: 0.9959904552, green: 1, blue: 0.9959602952, alpha: 1)
        
        cell.reloadData(imageUrl: community.avatar!, placeHolderImageUrl: "pic" + String(indexPath.row), name: community.name!, resourceName: community.resource_name!, rangeTime: rangeTime, navigationController: self.navigationController)
        return cell
    }
    
    var myCommunities = [CommunityModel]()
    var recommendedCommunities = [CommunityModel]()
    var config = Configuration()
    var selectedIndexPath: IndexPath?
    // 顶部刷新
    let header = MJRefreshNormalHeader()
    
    // 底部加载
    let footer = MJRefreshAutoNormalFooter()
    
    @IBOutlet weak var communityCollectionView: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.requestData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.communityCollectionView.backgroundColor = #colorLiteral(red: 0.9724641442, green: 0.9726034999, blue: 0.9724336267, alpha: 1)
        
        
        self.communityCollectionView.register(UINib(nibName: "CommunityCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "newCommunityCell")
        
        self.communityCollectionView.delegate = self
        self.communityCollectionView.dataSource = self
        self.communityCollectionView.reloadData()
        
        //下拉刷新相关设置
        header.setRefreshingTarget(self, refreshingAction: #selector(headerRefresh))
        self.communityCollectionView!.mj_header = header
        
        //上拉刷新相关设置
        footer.setRefreshingTarget(self, refreshingAction: #selector(footerLoad))
        //是否自动加载（默认为true，即表格滑到底部就自动加载）
        footer.isAutomaticallyRefresh = true
//        self.communityCollectionView!.mj_footer = footer
        // Do any additional setup after loading the view.
    }
    
    //顶部下拉刷新
    @objc func headerRefresh(){
        print("下拉刷新...")
        self.requestData()
        //结束刷新
        //        self.collectionView!.mj_header!.endRefreshing()
    }
    
    //底部上拉加载
    @objc func footerLoad(){
        print("上拉加载.")
        // 请求并添加数据
        
//        let skip = self.recommendedCommunities.count
//        print("已经有了\(skip)个资源")
//        self.requestData(skip: skip)
        self.recommendedCommunities = [CommunityModel]()
        self.requestData()
        //
        //        self.tableView!.reloadData()
        //        //结束刷新
        //        self.tableView!.mj_footer!.endRefreshing()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedIndexPath = indexPath
        performSegue(withIdentifier: "toCommunityDetailSegue", sender: self)
    }
    
//    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//        self.selectedIndexPath = indexPath
//        performSegue(withIdentifier: "toCommunityDetailSegue", sender: self)
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "toCommunityDetailSegue" {
                print("into resource detail view")
                let destination = segue.destination as! CommunityDetailViewController
                var community: CommunityModel?
                let indexPath = self.selectedIndexPath!
                if (indexPath.section == 0) {
                    community = self.myCommunities[indexPath.row]
                } else {
                    community = self.recommendedCommunities[indexPath.row]
                }
                destination.community = community
            }
        }
    
    func requestData(skip: Int = 0) {
        let token = UserDefaults.standard.object(forKey: "token") as? String
        var url = config.url + "community/getCommunitiesByToken"
        let header = ["token": token!]
        Alamofire.request(url, method: .get, headers: header).responseJSON {
            response in
            if response.result.isSuccess {
                print("后台连接成功")
                let resultData = try? JSONSerialization.data(withJSONObject: response.result.value!, options: .prettyPrinted)
                if let resultJson = try? JSON.init(data: resultData!) {
                    //                    print("resultJson: \(resultJson)")
                    
                    if let error = resultJson["error"].string {
                        print("error: \(error)")
                        
                        //                        let alertController = UIAlertController(title: "暂无资源，请静候佳音", message: "", preferredStyle: .alert)
                        //                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        //                        alertController.addAction(defaultAction)
                        //                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        let communities_json = resultJson["data"].arrayValue
                        //                        var index = 0
                        print("community array of my:")
                        print(communities_json)
                        var communities_model = [CommunityModel]()
                        for community in communities_json {
                            let commu = CommunityModel()
                            commu.id = community["_id"].string!
                            commu.name = community["name"].string!
                            commu.avatar = community["avatar"].string!
                            commu.resource_name = community["resource_name"].string!
                            commu.des = community["description"].string ?? commu.name!
                            commu.frequency = community["frequency"].int ?? 2
                            commu.coins_needed = community["coins_needed"].int ?? 5
                            commu.sponsor_info = community["sponsor_info"]
                            
                            let users_id_json = community["users_id"].arrayValue
                            var users_id_string = [String]()
                            for value in users_id_json {
                                users_id_string.append(value.string!)
                            }
                            commu.users_id = users_id_string
                            
                            let moments_id_json = community["moments_id"].arrayValue
                            var moments_id_string = [String]()
                            for value in moments_id_json {
                                moments_id_string.append(value.string!)
                            }
                            commu.moments_id = moments_id_string
                            
                            commu.isMember = true
                            communities_model.append(commu)
                        }
                        
                        self.myCommunities = communities_model
                        self.communityCollectionView.reloadData()
                        self.communityCollectionView!.mj_header!.endRefreshing()
                    }
                }
            }
        }
        
        url = config.url + "community/getRecommendCommunities"
        Alamofire.request(url, method: .get, headers: header).responseJSON {
            response in
            if response.result.isSuccess {
                print("后台连接成功")
                let resultData = try? JSONSerialization.data(withJSONObject: response.result.value!, options: .prettyPrinted)
                if let resultJson = try? JSON.init(data: resultData!) {
                    print("resultJson: \(resultJson)")
                    
                    if let error = resultJson["error"].string {
                        print("error: \(error)")
                    } else {
                        let communities_json = resultJson["data"].arrayValue
                        //                        var index = 0
                        print("community array of recommend:")
                        print(communities_json)
                        var communities_model = [CommunityModel]()
                        for community in communities_json {
                            let commu = CommunityModel()
                            commu.id = community["_id"].string!
                            commu.name = community["name"].string!
                            commu.avatar = community["avatar"].string!
                            commu.resource_name = community["resource_name"].string!
                            commu.des = community["description"].string ?? commu.name!
                            commu.frequency = community["frequency"].int ?? 2
                            commu.coins_needed = community["coins_needed"].int ?? 5
                            commu.sponsor_info = community["sponsor_info"]
                            
                            let users_id_json = community["users_id"].arrayValue
                            var users_id_string = [String]()
                            for value in users_id_json {
                                users_id_string.append(value.string!)
                            }
                            commu.users_id = users_id_string
                            
                            let moments_id_json = community["moments_id"].arrayValue
                            var moments_id_string = [String]()
                            for value in moments_id_json {
                                moments_id_string.append(value.string!)
                            }
                            commu.moments_id = moments_id_string
                            
                            commu.isMember = false
                            
                            communities_model.append(commu)
                        }
                        
                        self.recommendedCommunities = communities_model
                        self.communityCollectionView.reloadData()
                        self.communityCollectionView!.mj_header!.endRefreshing()
                    }
                }
            }
        }
    }
    
    private let itemsPerRow: CGFloat = 2
    
    private let sectionInsets = UIEdgeInsets(top: 22.0,
                                             left: 40.0,
                                             bottom: 22.0,
                                             right: 40.0)
    
    
}

// MARK: - Collection View Flow Layout Delegate
extension CommunitySubPageViewController : UICollectionViewDelegateFlowLayout {
    //1
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        //2
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem * 1.5)
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    // 4
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}


