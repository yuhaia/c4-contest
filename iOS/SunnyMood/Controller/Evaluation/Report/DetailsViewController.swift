//
//  DetailsViewController.swift
//  SunnyMood
//
//  Created by bytedance on 2020/5/15.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SwiftyJSON

public struct Detail {
    var itemTitle: String?
    var itemDes: String?
    var itemLevel: String?
    var itemSuggestion: String?
}

public var child_details = [Detail]()
public var parent_detail: Detail?

class DetailsViewController: UIViewController, IndicatorInfoProvider, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return child_details.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! DetailTableViewCell
        
        cell.frame = tableView.bounds
        cell.layoutIfNeeded()
        
        cell.detailLabel.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        let detail = child_details[indexPath.row]
        if (detail.itemLevel! == "A") {
            cell.levelLabel.textColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        } else if (detail.itemLevel! == "B") {
            cell.levelLabel.textColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        } else {
            cell.levelLabel.textColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
        }
        cell.reloadData(detail: detail, isSuggestion: false)
        
        return cell
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "详细解读")
    }
    
    @IBOutlet weak var themeLabel: UILabel!
    @IBOutlet weak var parentDesLabel: UILabel!
    @IBOutlet weak var parentLevelLabel: UILabel!
    
    @IBOutlet weak var detailTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (report != nil) {
            self.cleanData()
        }
        
        // Do any additional setup after loading the view.
        
        self.detailTableView.delegate = self
        self.detailTableView.dataSource = self
        
        self.detailTableView.separatorStyle = .none
        
        self.detailTableView.register(UINib(nibName: "DetailTableViewCell", bundle: nil), forCellReuseIdentifier: "detailCell")
        
        self.detailTableView.estimatedRowHeight = 44.0
        self.detailTableView.rowHeight = UITableView.automaticDimension
    }
    
    func cleanData() {
        print("report of global variable:")
        print(report!)
        
        let parent_data = report!["result"]["general_evaluation"]
        let item_title = parent_data["des"].string!
        var item_des = parent_data["eval_des"].string!
        item_des.removeLast()
        let item_level = parent_data["level"].string!
        let item_suggestion = parent_data["suggestion"].string!
        parent_detail = Detail(itemTitle: item_title, itemDes: item_des, itemLevel: item_level, itemSuggestion: item_suggestion)
        
        // 如果不加这个 就会累加数据
        child_details = [Detail]()
        
        self.themeLabel.text = parent_detail?.itemTitle
        self.parentDesLabel.text = parent_detail?.itemDes
        self.parentLevelLabel.text = parent_detail?.itemLevel
        if (parent_detail?.itemLevel! == "A") {
            self.parentLevelLabel.textColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        } else if (parent_detail?.itemLevel! == "B") {
            self.parentLevelLabel.textColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        } else {
            self.parentLevelLabel.textColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
        }
//        var scores = [Int]()
//        var keys = [String]()
//        var levels = [String]()
        for (key, first_level_result) in report!["result"]["child_groups"] {
//            keys.append(key)
//            var score = 0
            var itemLevel = "C"
            var itemDes = "h"
            var itemSuggestion = ""
            if theme! == "潜能测试" {
                // 如果 theme 是 潜能测试
//                score = first_level_result["general_evaluation"]["average_score"].int ?? 0
                itemLevel = (first_level_result["general_evaluation"]["level"].string)!
                itemDes = (first_level_result["general_evaluation"]["eval_des"].string)!
                itemDes.removeLast()
                
                itemSuggestion = (first_level_result["general_evaluation"]["suggestion"].string)!
            } else {
//                score = Int(first_level_result["average_score"].number ?? 0)
                itemLevel = (first_level_result["level"].string)!
                itemDes = (first_level_result["eval_des"].string)!
                itemDes.removeLast()
                
                itemSuggestion = (first_level_result["suggestion"].string)!
            }
            var detail = Detail(itemTitle: key, itemDes: itemDes, itemLevel: itemLevel, itemSuggestion: itemSuggestion)
            child_details.append(detail)
//            scores.append(score)
        }
//        print("keys:")
//        print(keys)
//        print("scores:")
//        print(scores)
        
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
