//
//  CommunityPageCollectionViewController.swift
//  SunnyMood
//
//  Created by bytedance on 2020/6/17.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import UIKit
import SDWebImage
import Alamofire
import SwiftyJSON
import MJRefresh

private let reuseIdentifier = "Cell"

class CommunityPageCollectionViewController: UICollectionViewController {
    
    var myCommunities = [CommunityModel]()
    var recommendedCommunities = [CommunityModel]()
    var config = Configuration()
    var selectedIndexPath: IndexPath?
    // 顶部刷新
    let header = MJRefreshNormalHeader()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getCommunities()
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // Do any additional setup after loading the view.
        
        //下拉刷新相关设置
        header.setRefreshingTarget(self, refreshingAction: #selector(headerRefresh))
        self.collectionView!.mj_header = header
    }
    
    //顶部下拉刷新
        @objc func headerRefresh(){
            print("下拉刷新...")
            self.getCommunities()
            //结束刷新
    //        self.collectionView!.mj_header!.endRefreshing()
        }
    
    func getCommunities() {
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
                        self.collectionView.reloadData()
                        self.collectionView!.mj_header!.endRefreshing()
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
                        self.collectionView.reloadData()
                        self.collectionView!.mj_header!.endRefreshing()
                    }
                }
            }
        }
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if (section == 0) {
            return self.myCommunities.count
        } else {
            return self.recommendedCommunities.count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedIndexPath = indexPath
        performSegue(withIdentifier: "toCommunityDetailSegue", sender: self)
    }
    
    //分区的header与footer
    override func collectionView(_ collectionView: UICollectionView,
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
    
    
    
    //返回每个单元格视图
    override func collectionView(_ collectionView: UICollectionView,
                            cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //获取单元格
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CommunityCell",
                                                      for: indexPath)
        var community = CommunityModel()
        if (indexPath.section == 0) {
            community = self.myCommunities[indexPath.row]
        } else {
            community = self.recommendedCommunities[indexPath.row]
        }
        //设置单元格中的图片
        let imageView = cell.viewWithTag(1) as! UIImageView
        imageView.sd_setImage(with: URL(string: community.avatar!), placeholderImage: UIImage(named: "pic" + String(indexPath.row)), completed: nil)
//        imageView.image = UIImage(named: "pic1")
        imageView.layer.cornerRadius = 5.0
        
        let nameLabel = cell.viewWithTag(2) as! UILabel
        nameLabel.text = community.name
        
        let resourceLabel = cell.viewWithTag(3) as! UILabel
        resourceLabel.text = community.resource_name
        
        let rangeTimeLabel = cell.viewWithTag(4) as! UILabel
        
        let time_texts = ["06.15 -> 09.03", "06.18 -> 10.01", "07.01 -> 08.01"]
        
        if indexPath.row < 3 {
            rangeTimeLabel.text = time_texts[indexPath.row]
        } else {
            rangeTimeLabel.text = time_texts[1]
        }

        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
     
     }
     */
    
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
//            let resource = self.resources[self.selectedIndex!]
//            destination.resource = resource
//            destination.selectedIndex = self.selectedIndex!
        }
    }
}

private let itemsPerRow: CGFloat = 2

private let sectionInsets = UIEdgeInsets(top: 50.0,
left: 20.0,
bottom: 50.0,
right: 20.0)


// MARK: - Collection View Flow Layout Delegate
extension CommunityPageCollectionViewController : UICollectionViewDelegateFlowLayout {
  //1
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    //2
    let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
    let availableWidth = view.frame.width - paddingSpace
    let widthPerItem = availableWidth / itemsPerRow
    
    return CGSize(width: widthPerItem, height: widthPerItem)
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



