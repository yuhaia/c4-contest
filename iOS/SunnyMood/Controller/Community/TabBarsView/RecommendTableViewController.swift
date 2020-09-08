//
//  RecommendTableViewController.swift
//  SunnyMood
//
//  Created by bytedance on 2020/5/20.
//  Copyright © 2020 edu.pku. All rights reserved.
//

// 参考：https://ashfurrow.com/blog/putting-a-uicollectionview-in-a-uitableviewcell-in-swift/
import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage

class RecommendTableViewController: UITableViewController {
    var config = Configuration()
    var takeUserInfo = TakeUserInfo()
    var moments = [MomentModel]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.requestRecommendData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.contentInset = UIEdgeInsets(top: 10.0, left: 0.0, bottom: 0.0, right: 0.0)
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.reloadData()
    }
    
    func requestRecommendData() {
        let url = config.url + "moment/getAllMoments"
        Alamofire.request(url, method: .get).responseJSON {
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

                                var pictures = [String]()
                                for pic in momentData["pictures"].array! {
                                    pictures.append(pic.string!)
                                }
                                moment.pictures = pictures
                                self.moments.append(moment)
                            }
                            self.tableView.reloadData()
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
        
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.moments.count
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tableViewCell = cell as? RecommendTableViewCell else { return }
        
        tableViewCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recommendCell", for: indexPath) as! RecommendTableViewCell
        
        let index = indexPath.row
        let moment = self.moments[index]
       
        let user_avatar_url = URL(string: moment.user_info!["avatar"].string!)
        cell.userAvatarImageView?.sd_setImage(with: user_avatar_url, completed: nil)
        cell.userAvatarImageView?.layer.cornerRadius = (cell.userAvatarImageView?.frame.width)! / 2
        cell.userAvatarImageView?.clipsToBounds = true
        cell.userAvatarImageView?.layer.backgroundColor = UIColor.lightGray.cgColor
        cell.userNameLabel?.text = moment.user_info!["name"].string!
        cell.textsLabel.text = self.moments[index].texts!
        cell.selectionStyle = .none
        return cell
    }

}

fileprivate let sectionInsets = UIEdgeInsets(top: 0.0, left: 0.5, bottom: 0.0, right: 0.0)

extension RecommendTableViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let moment = self.moments[collectionView.tag]
        let pictures_number = moment.pictures_number!
        return pictures_number
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MomentImageCollectionViewCell", for: indexPath) as! MomentImageCollectionViewCell
        
        //        cell.backgroundColor = model[collectionView.tag][indexPath.item]
        
        cell.imageOfMomentImageView?.frame = cell.contentView.frame
        cell.imageOfMomentImageView?.contentMode = .scaleToFill
        var picture_url_string = self.moments[collectionView.tag].pictures![indexPath.row]
        if String(picture_url_string.prefix(5)) != "https" {
            picture_url_string = "http" + picture_url_string
        }
        let picture_url = URL(string: picture_url_string)
        cell.imageOfMomentImageView.sd_setImage(with: picture_url, completed: nil)
        
        if (indexPath.row == 0) {
            // Set value according to user requirements
            cell.frame.origin.x = 0
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = 120
        return CGSize(width: size, height: size)
    }
}
