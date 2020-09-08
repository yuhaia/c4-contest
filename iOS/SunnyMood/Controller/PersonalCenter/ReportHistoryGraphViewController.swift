//
//  ReportHistoryGraphViewController.swift
//  SunnyMood
//
//  Created by bytedance on 2020/7/25.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import UIKit
import SwiftyJSON
import Charts

class ReportHistoryGraphViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "graphCell", for: indexPath) as! SingleGraphTableViewCell
        cell.reloadData(navigationController: self.navigationController)
        return cell
    }
    
    @IBOutlet weak var graphTableView: UITableView!
    
    var report_history: [JSON]?
    var questionnaire: QuestionnaireModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // 取出每个点的分数情况
        let theme = self.questionnaire?.theme
        
        self.graphTableView.register(UINib(nibName: "SingleGraphTableViewCell", bundle: nil), forCellReuseIdentifier: "graphCell")

        self.graphTableView.rowHeight = UITableView.automaticDimension
        self.graphTableView.estimatedRowHeight = 44.0
        self.graphTableView.reloadData()
        
        

//        var scores = [Int]()
//        var keys = [String]()
//        for (key, first_level_result) in report!["result"]["child_groups"] {
//            keys.append(key)
//
//            if self.questionnaire!["theme"].string! == "潜能测试" {
//                scores.append(first_level_result["general_evaluation"]["average_score"].int ?? 0)
//            } else {
//                scores.append(Int(first_level_result["average_score"].number ?? 0))
//            }
//        }
//        print("keys:")
//        print(keys)
//        print("scores:")
//        print(scores)

//        print("hello history~")
//        // Do any additional setup after loading the view.
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
