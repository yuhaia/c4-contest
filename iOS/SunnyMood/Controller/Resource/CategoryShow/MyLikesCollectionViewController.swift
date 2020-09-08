//
//  MyLikesCollectionViewController.swift
//  SunnyMood
//
//  Created by bytedance on 2020/6/19.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage
import MJRefresh

class MyLikesCollectionViewController: UICollectionViewController {
    
    var resources = [ResourceModel]()
    var image_urls = [URL]()
    var config = Configuration()
    var selectedIndex: Int?
    var user: UserModel?
    
    let header = MJRefreshNormalHeader()
    let footer = MJRefreshAutoNormalFooter()
    
    private let itemsPerRow: CGFloat = 2
    private let sectionInsets = UIEdgeInsets(top: 22.0,
                                             left: 40.0,
                                             bottom: 22.0,
                                             right: 40.0)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.reloadData()
        self.takeOutUser()
        self.requestData(skip: 0)
    }
    
    override func viewDidLoad() {
        self.collectionView.backgroundColor = #colorLiteral(red: 0.9724641442, green: 0.9726034999, blue: 0.9724336267, alpha: 1)
        
        super.viewDidLoad()
        
        //下拉刷新相关设置
        header.setRefreshingTarget(self, refreshingAction: #selector(headerRefresh))
        self.collectionView!.mj_header = header
        
        //上拉刷新相关设置
        footer.setRefreshingTarget(self, refreshingAction: #selector(footerLoad))
        //是否自动加载（默认为true，即表格滑到底部就自动加载）
        footer.isAutomaticallyRefresh = true
        self.collectionView!.mj_footer = footer
        
        self.collectionView.register(UINib(nibName: "ResourceCVC", bundle: nil), forCellWithReuseIdentifier: "resourceCell")
    }
    
    //顶部下拉刷新
    @objc func headerRefresh(){
        self.requestData(skip: 0)
    }
    
    //底部上拉加载
    @objc func footerLoad(){
        // 请求并添加数据
        let skip = self.resources.count
        print("已经有了\(skip)个资源")
        self.requestData(skip: skip)
    }
    
    func requestData(skip: Int) {
        // 请求资源数据
        let url = config.url + "resources/getMyLikes"
        let token = UserDefaults.standard.object(forKey: "token") as? String
        let headers = ["token": token!]
        print("token: \(token!)")
        
        if (skip == 0) {
            self.resources = [ResourceModel]()
        }
        let limit = config.limit
        
        let parameters = ["category": "all", "skip": String(skip), "limit": String(limit)]
        Alamofire.request(url, method: .get, parameters: parameters, headers: headers).responseJSON {
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
                        let resourceArray = resultJson["data"].arrayValue
                        for item in resourceArray {
                            let resource = ResourceModel()
                            resource._id = item["_id"].string!
                            resource.category = item["category"].string!
                            resource.name = item["name"].string!
                            resource.picture_url = item["picture"].string!
                            resource.time = item["time"].string!
                            resource.author = item["author"].string!
                            resource.link = item["link"].string!
                            resource._description = item["description"].string!
                            resource.likes = item["likes"].string!
                            resource.labels = item["labels"].string!
                            resource.isUserLike = "1"
                            
                            let commu_id_json = item["communities_id"].arrayValue
                            var commu_id_string_array = [String]()
                            for value in commu_id_json {
                                commu_id_string_array.append(value.string!)
                            }
                            resource.communities_id = commu_id_string_array
                            
                            self.resources.append(resource)
                            let picture_url = URL(string: resource.picture_url!)
                            self.image_urls.append(picture_url!)
                            
                        }
                        
                        self.collectionView.reloadData()
                        self.collectionView!.mj_header!.endRefreshing()
                        self.collectionView!.mj_footer!.endRefreshing()
                        
                        if (resourceArray.count == 0) {
                            self.collectionView!.mj_footer!.endRefreshingWithNoMoreData()
                        }
                    }
                }
            }
        }
    }
    
    func takeOutUser() {
        let userInfo = TakeUserInfo()
        self.user = userInfo.user
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedIndex = indexPath.row
        performSegue(withIdentifier: "toResourceDetailSegue", sender: self)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.resources.count // equals to self.image_urls.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Configure the cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "resourceCell", for: indexPath) as! ResourceCVC
        cell.reloadData(resource: self.resources[indexPath.row],navigationController: self.navigationController)
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toResourceDetailSegue" {
            print("into resource detail view")
            let destination = segue.destination as! ResourceDetailViewController
            let resource = self.resources[self.selectedIndex!]
            destination.resource = resource
            destination.selectedIndex = self.selectedIndex!
            destination.valueBackDelegate = self
        }
    }
}


extension MyLikesCollectionViewController: UICollectionViewDelegateFlowLayout {
    //1
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        //2
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        print("availableWidth: \(availableWidth)")
        print("widthPerItem: \(widthPerItem)")
        
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

extension MyLikesCollectionViewController: ValueBackDelegate {
    func valueBack(selectedIndex: Int, like: String, likes_number: String) {
        self.resources[selectedIndex].isUserLike = like
        self.resources[selectedIndex].likes = likes_number
        self.collectionView.reloadData()
    }
}
