//
//  EvaluationViewController.swift
//  SunnyMood
//
//  Created by bytedance on 2020/5/13.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MJRefresh

class EvaluationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var userModel = UserModel()
    var config = Configuration()
    var tablesData = [String: Any]()
    var questionnaireItems = [String: QuestionnaireModel]()
    var reportItems = [String: ReportModel]()
    var quesNumber = 3
    var scores = [String: [Int]]()
    
    // 顶部刷新
    let header = MJRefreshNormalHeader()
    
    func numberOfSections(in tableView: UITableView) -> Int {
        print("self.tablesData.count: \(self.tablesData.count)")
        // 这一个用来显示其他
        return self.tablesData.count
        
//        return self.questionnaireItems.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            print("self.questionnaireItems.count: \(self.questionnaireItems.count)")
            return self.questionnaireItems.count
        } else {
            return 1
        }
//        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell") // 默认table cell的话这里的reuse...参数貌似m已经不用写了
        // custom tableviewcell
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuesBriefCell") as! QuesBriefTableViewCell
//        cell.backgroundColor = #colorLiteral(red: 0.9999127984, green: 1, blue: 0.9998814464, alpha: 1)
//        cell.layer.cornerRadius = 15.0
//        cell.clipsToBounds = true
//        
//        
//        cell.contentView.backgroundColor = UIColor.clear
//
//        let whiteRoundedView : UIView = UIView(frame: CGRect(x: 10, y: 8, width: self.view.frame.size.width - 20, height: 149))
//
//        whiteRoundedView.layer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 0.8])
//        whiteRoundedView.layer.masksToBounds = false
//        whiteRoundedView.layer.cornerRadius = 2.0
//        whiteRoundedView.layer.shadowOffset = CGSize(width: -1, height: 1)
//        whiteRoundedView.layer.shadowOpacity = 0.2
//
//        cell.contentView.addSubview(whiteRoundedView)
//        cell.contentView.sendSubviewToBack(whiteRoundedView)
        
        
        if indexPath.section == 0 {
            let ids = Array(self.questionnaireItems.keys)
            let ques = questionnaireItems[ids[indexPath.row]]
            cell.themeLabel?.text = ques!.theme!
            cell.descriptionLabel?.text = ques!._description!
            cell.quesImageView?.image = UIImage(named: ques!.imageName!)

            // 调整ui格式
            cell.quesImageView?.layer.cornerRadius = (cell.quesImageView?.frame.width)! / 2
//            cell.toQuesOrReportLabel?.layer.cornerRadius = (cell.toQuesOrReportLabel?.frame.size.height)! / 2.0
            cell.toQuesOrReportLabel?.layer.cornerRadius = 15.0
            cell.toQuesOrReportLabel?.layer.masksToBounds = true
            cell.toQuesOrReportLabel?.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            if (ques?.isDone!)! {
                cell.toQuesOrReportLabel?.text = "查看结果"
                cell.toQuesOrReportLabel?.backgroundColor = #colorLiteral(red: 0.4966237545, green: 0.6555117369, blue: 0.562161386, alpha: 1)
            } else {
                cell.toQuesOrReportLabel?.text = "进入测评"
                cell.toQuesOrReportLabel?.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            }
        } else {
            cell.themeLabel?.text = "other"
        }
        
        // cell -> section to add space between cells
        // ref: https://stackoverflow.com/questions/6216839/how-to-add-spacing-between-uitableviewcell/33931591#33931591
        
//        cell.contentView.layoutMargins.left = 20
        
//        let ids = Array(self.questionnaireItems.keys)
//        let ques = questionnaireItems[ids[indexPath.section]]
//        cell.themeLabel?.text = ques!.theme!
//        cell.descriptionLabel?.text = ques!._description!
//        cell.quesImageView?.image = UIImage(named: ques!.imageName!)
//
//        // 调整ui格式
//        cell.quesImageView?.layer.cornerRadius = (cell.quesImageView?.frame.width)! / 2
//        //            cell.toQuesOrReportLabel?.layer.cornerRadius = (cell.toQuesOrReportLabel?.frame.size.height)! / 2.0
//        cell.toQuesOrReportLabel?.layer.cornerRadius = 15.0
//        cell.toQuesOrReportLabel?.layer.masksToBounds = true
//        cell.toQuesOrReportLabel?.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
//        if (ques?.isDone!)! {
//            cell.toQuesOrReportLabel?.text = "查看结果"
//            cell.toQuesOrReportLabel?.backgroundColor = #colorLiteral(red: 0.4966237545, green: 0.6555117369, blue: 0.562161386, alpha: 1)
//        } else {
//            cell.toQuesOrReportLabel?.text = "进入测评"
//            cell.toQuesOrReportLabel?.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
//        }
//
        
        return cell
    }
    

    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 15.0
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = self.evaluationTableView.indexPathForSelectedRow
        let index = indexPath?.row
        let ids = Array(self.questionnaireItems.keys)
        let questionnaire = self.questionnaireItems[ids[index!]]
        if (questionnaire?.isDone!)! {
            let def = UserDefaults.standard
            def.set(questionnaire?._id!, forKey: "selected_questionnaire_id")
            def.set(questionnaire?.theme!, forKey: "selected_questionnaire_theme")
            def.synchronize()
            print("saved the id and theme infor to userdefault")
            performSegue(withIdentifier: "ShowReportSegue", sender: self)
        } else {
            performSegue(withIdentifier: "ShowQuesSegue", sender: self)
        }
    }
    
    @IBOutlet weak var evaluationTableView: UITableView!
    
    func takeOutUser() {
        let userInfo = TakeUserInfo()
        self.userModel = userInfo.user!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.takeOutUser()
        self.requestQuesData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("view did load:")
        //下拉刷新相关设置
        header.setRefreshingTarget(self, refreshingAction: #selector(headerRefresh))
        self.evaluationTableView!.mj_header = header
        
        self.evaluationTableView.backgroundColor = #colorLiteral(red: 0.9685428739, green: 0.9686816335, blue: 0.9685124755, alpha: 1)
        
//        self.evaluationTableView.contentInset = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    }
    
    //顶部下拉刷新
    @objc func headerRefresh(){
        print("下拉刷新...")
        self.requestQuesData()
        //结束刷新
        //        self.collectionView!.mj_header!.endRefreshing()
    }
    
    func requestQuesData() {
        let url = config.url + "questionnaires/getAll"
        Alamofire.request(url, method: .get).responseJSON {
            response in
            if response.result.isSuccess {
                print("后台连接成功")
                let resultData = try? JSONSerialization.data(withJSONObject: response.result.value!, options: .prettyPrinted)
                if let resultJson = try? JSON.init(data: resultData!) {
                    //                    print("resultJson: \(resultJson)")
                    
                    if let error = resultJson["error"].string {
                        print("error: \(error)")
                        
                        let alertController = UIAlertController(title: "暂无评测数据", message: "请等待专家上架评测", preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertController.addAction(defaultAction)
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        if let quesDatas = resultJson["data"].array {
                            self.quesNumber = quesDatas.count
                            //                            print("请求到的评测问卷数据的data字段：\(quesDatas)")
                            var index = 0
                            for quesData in quesDatas {
                                index += 1
                                print("theme: \(quesData["theme"])")
                                let _id = quesData["_id"].string!
                                let theme = quesData["theme"].string!
                                let description = quesData["description"].string!
                                let questions = quesData["questions"].arrayValue
                                let minest_value = quesData["minest_value"].int!
                                let maxest_value = quesData["maxest_value"].int!
                                let stride_value = quesData["stride_value"].int!
                                let level_des = quesData["level_des"].arrayValue
                                let groups = quesData["groups"]
                                let anti_questions = quesData["anti_questions"].arrayValue
                                
                                let questionnaire = QuestionnaireModel(_id: _id, theme: theme, description: description, questions: questions, minest_value: minest_value, maxest_value: maxest_value, stride_value: stride_value, level_des: level_des, groups: groups, anti_questions: anti_questions, imageName: "pic" + String(index), isDone: false)
                                //                                questionnaire.printInfo()
                                //                                let questions_test = quesData["questions"].arrayValue
                                //                                print("questions_test: \(questions_test)")
                                //                                for q in questions_test {
                                //                                    print(q.string!)
                                //                                }
                                
                                // 获取每个questionnaire的report信息 如果没有结果便说明用户还没有进行评测 则修改对应questionnaire的isDone字段 然后再viewDidLoad函数里进行ui数据的设置
                                let getReportURL = self.config.url + "reports/getReportByUserIDandQuesID"
                                let parameters = ["user_id": self.userModel._id, "questionnaire_id": questionnaire._id!]
                                print("parameters:")
                                print(parameters)
                                Alamofire.request(getReportURL, method: .get, parameters: parameters as Parameters).responseJSON {
                                    response in
                                    if response.result.isSuccess {
                                        print("后台连接成功。。。")
                                        let reportResultData = try? JSONSerialization.data(withJSONObject: response.result.value!, options: .prettyPrinted)
                                        if let reportResultJson = try? JSON.init(data: reportResultData!) {
                                            //                    print("resultJson: \(resultJson)")
                                            
                                            if let error = reportResultJson["error"].string {
                                                print("error: \(error)")
                                                questionnaire.isDone = false
                                                //                                                self.reportItems.append(ReportModel())
                                                // 不用数组存了 用字典存 key是questionnaire_id
                                                self.reportItems[questionnaire._id!] = ReportModel()
                                            } else {
                                                questionnaire.isDone = true
                                                let reportData = reportResultJson["data"]
                                                let report_id = reportData["_id"].string!
                                                let res = reportData["result"]
                                                let general = res["general_evaluation"]
                                                let scores_json = general["scores"]
                                                
                                                var scores = [Int]()
                                                for (_, first_level_result) in reportData["result"]["child_groups"] {
                                                    if questionnaire.theme! == "潜能测试" {
                                                        scores.append(first_level_result["general_evaluation"]["average_score"].int ?? 0)
                                                    } else {
                                                        scores.append(Int(first_level_result["average_score"].number ?? 0))
                                                    }
                                                }
                                                
                                                let time = reportData["time"].numberValue
                                                let result = reportData["result"]
                                                
                                                let questionnaire_info = reportData["questionnaire_info"]
                                                let questionnaire_id = questionnaire_info["_id"].string!
                                                let questionnaire_theme = questionnaire_info["theme"].string!
                                                
                                                let reportItem = ReportModel(_id: report_id, user_id: self.userModel._id, questionnaire_id: questionnaire_id, questionnaire_theme: questionnaire_theme, scores: scores, time: time, result: result)
                                                self.reportItems[questionnaire._id!] = reportItem
                                            }
                                        }
                                    } else {
                                        print("后台连接失败。。。")
                                    }
                                    self.questionnaireItems[questionnaire._id!] = questionnaire
                                    self.tablesData["questionnaires"] = self.questionnaireItems
                                    print(self.tablesData["questionnaires"] ?? "no questionnaires")
                                    print((self.tablesData["questionnaires"] as? [String: QuestionnaireModel])?.count ?? 0)
                                    print(self.tablesData)
                                    if self.questionnaireItems.count == self.quesNumber {
                                        self.evaluationTableView.reloadData()
                                        self.evaluationTableView!.mj_header!.endRefreshing()
                                        print("hhhhhh: \(self.reportItems.count)")
                                    }
                                }
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
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let indexPath = self.evaluationTableView.indexPathForSelectedRow
        let index = indexPath?.row
        let ids = Array(self.questionnaireItems.keys)
        let report = self.reportItems[ids[index!]]
        let questionnaire = self.questionnaireItems[ids[index!]]
        
        switch segue.identifier! {
        case "ShowReportSegue":
            let destination = segue.destination as! ReportViewController
            //            destination.index = index
            destination.report = report
            destination.questionnaire = questionnaire
            destination.theme = questionnaire?.theme
            destination.scores = report?.scores
            
            var keys = [String]()
            let child_groups = report?.result!["child_groups"]
            var reportCells = [ReportCellModel]()
            for (key, value) in child_groups! {
                keys.append(key)
                
                let image_name = "pic1"
                let title_name = key
                let time = "15/4"
                
                var average_score = 0
                var total_score = 1
                var user_score = 0.0
                var eval_des = ""
                var suggestion = ""
                
                if value["average_score"].int != nil {
                    average_score = value["average_score"].int!
                    total_score = value["total_score"].int!
                    user_score = (Double(average_score) / Double(total_score)) * 100.0
                    eval_des = value["eval_des"].string!
                    suggestion = value["suggestion"].string!
                } else {
                    var child_value = value["general_evaluation"]
                    average_score = child_value["average_score"].int!
                    total_score = child_value["total_score"].int!
                    user_score = (Double(average_score) / Double(total_score)) * 100.0
                    eval_des = child_value["eval_des"].string!
                    suggestion = child_value["suggestion"].string!
                }
                
                
                var reportCell = ReportCellModel(image_name: image_name, title_name: title_name, time: time, user_score: user_score, total_score: 100, eval_des: eval_des, suggestion: suggestion)
                reportCells.append(reportCell)
            }
            destination.keys = keys
            destination.reportCells = reportCells
            
            
        case "ShowQuesSegue":
            let destination = segue.destination as! QuestionViewController
            destination.index = index
            destination.questionnaire = questionnaire
        default:
            print("no segue could be used")
        }
    }
    
    
}
