//
//  ResourceRelatedCommunitiesCVC.swift
//  SunnyMood
//
//  Created by bytedance on 2020/6/18.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

private let reuseIdentifier = "Cell"

class ResourceRelatedCommunitiesCVC: UICollectionViewController {
    
    var relatedComunities = [CommunityModel]()
    var resource_id: String?
    let config = Configuration()
    var selectedIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getResourceRelatedCommunities()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // Do any additional setup after loading the view.
    }
    
    func getResourceRelatedCommunities() {
        if let resource_id = self.resource_id {
            let url = self.config.url + "community/getCommunitiesByResourceID"
            let parameters = ["resource_id": resource_id]
            
            Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
                response in
                if response.result.isSuccess {
                    print("后台连接成功")
                    let resultData = try? JSONSerialization.data(withJSONObject: response.result.value!, options: .prettyPrinted)
                    if let resultJson = try? JSON.init(data: resultData!) {
                        //                    print("resultJson: \(resultJson)")
                        
                        if let error = resultJson["error"].string {
                            print("error: \(error)")
                            
                            let alertController = UIAlertController(title: "暂无小组，请静候佳音", message: "", preferredStyle: .alert)
                            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                            alertController.addAction(defaultAction)
                            self.present(alertController, animated: true, completion: nil)
                        } else {
                            let communities_json = resultJson["data"].arrayValue
                            //                        var index = 0
                            print("community array of resource related:")
                            print(communities_json)
                            var communities = [CommunityModel]()
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
                                let my_user_id = UserDefaults.standard.object(forKey: "_id") as! String
                                for user_id in commu.users_id! {
                                    if (user_id == my_user_id) {
                                        commu.isMember = true
                                        break
                                    }
                                }
                                communities.append(commu)
                            }
                            
                            self.relatedComunities = communities
                            self.collectionView.reloadData()
                        }
                    }
                } else {
                    let alertController = UIAlertController(title: "网络请求失败", message: "", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedIndexPath = indexPath
        performSegue(withIdentifier: "resourceToCommunityDetailSegue", sender: self)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "resourceToCommunityDetailSegue" {
            print("into community detail view")
            let destination = segue.destination as! CommunityDetailViewController
            var community: CommunityModel?
            let indexPath = self.selectedIndexPath!
            community = self.relatedComunities[indexPath.row]
            destination.community = community
            //            let resource = self.resources[self.selectedIndex!]
            //            destination.resource = resource
            //            destination.selectedIndex = self.selectedIndex!
        }
    }
    
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.relatedComunities.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //获取单元格
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "relatedCommunityCell",
                                                      for: indexPath)
        var community = self.relatedComunities[indexPath.row]
        
        //设置单元格中的图片
        let imageView = cell.viewWithTag(1) as! UIImageView
        imageView.sd_setImage(with: URL(string: community.avatar!), placeholderImage: UIImage(named: "pic" + String(indexPath.row)), completed: nil)
        //        imageView.image = UIImage(named: "pic1")
        
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
    
}
