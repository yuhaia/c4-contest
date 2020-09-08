//
//  ReportsListViewController.swift
//  SunnyMood
//
//  Created by bytedance on 2020/7/24.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ReportsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "已完成测评"
        } else {
            return "推荐测评"
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var num = 1
        if self.ques_themes.count != 0 {
            num = 2
        }
        return num
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var num = 1
        if section == 0 {
            num = self.report_themes.count
        } else if section == 1 {
            num = self.ques_themes.count
        }
        return num
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "themeCell", for: indexPath) as! ReportsListTableViewCell
        
//        cell.flagLabel.layer.cornerRadius = (cell.flagLabel.frame.size.height)/2.0
        cell.flagLabel.layer.cornerRadius = 16.0
        cell.flagLabel.layer.masksToBounds = true
                
        if indexPath.section == 0 {
//            cell.flagLabel.text = "查看结果"
//            cell.flagLabel.backgroundColor = #colorLiteral(red: 0.4966237545, green: 0.6555117369, blue: 0.562161386, alpha: 1)
//            cell.themeLable.text = self.report_themes[indexPath.row]
            
            cell.reloadData(theme: self.report_themes[indexPath.row], reportFlag: true, navigationController: self.navigationController)
        } else if indexPath.section == 1 {
//            cell.flagLabel.text = "进入测评"
//            cell.flagLabel.backgroundColor = #colorLiteral(red: 0.7066736356, green: 0.3337643046, blue: 0.3682053257, alpha: 1)
//            cell.themeLable.text = self.ques_themes[indexPath.row]

            cell.reloadData(theme: self.ques_themes[indexPath.row], reportFlag: false, navigationController: self.navigationController)
        }
        print("self.themes: \(self.report_themes)")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        if (selectedIndex <= self.report_themes.count) {
            performSegue(withIdentifier: "toHistoryGraphSegue", sender: self)
        } else {
            performSegue(withIdentifier: "toQuestionnaireSegue", sender: self)
        }
    }
    
    
    
    @IBOutlet weak var themeList: UITableView!
    
    var selectedIndex = 0
    let userInfo = TakeUserInfo()
    let config = Configuration()
    var report_themes = [String]()
    var ques_themes = [String]()
    
    var reports = [String: [JSON]]()
    var finished_queses = [QuestionnaireModel]()
    
    var questionnaires = [QuestionnaireModel]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.clearData()
        self.themeList.reloadData()
        self.requestData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.themeList.register(UINib(nibName: "ReportsListTableViewCell", bundle: nil), forCellReuseIdentifier: "themeCell")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toQuestionnaireSegue" {
            let destination = segue.destination as! QuestionViewController
            destination.index = selectedIndex
            destination.questionnaire = self.questionnaires[selectedIndex]
        } else if segue.identifier == "toHistoryGraphSegue" {
            let destination = segue.destination as! ReportHistoryGraphViewController
            let theme = self.report_themes[selectedIndex]
            let report_history = self.reports[theme]
            destination.report_history = report_history
            destination.questionnaire = self.finished_queses[selectedIndex]
        }
    }
    
    func clearData() {
        self.report_themes = [String]()
        self.ques_themes = [String]()
        self.reports = [String: [JSON]]()
        self.finished_queses = [QuestionnaireModel]()
        self.questionnaires = [QuestionnaireModel]()
    }
    
    func requestData() {
        let token = UserDefaults.standard.object(forKey: "token") as? String
        var url = config.url + "reports/getReportsByToken"
        let headers = ["token": token!]
        
        Alamofire.request(url, method: .get, headers: headers).responseJSON {
            response in
//            print("response:\(response)")
            if response.result.isSuccess {
                print("后台连接成功")
                let resultData = try? JSONSerialization.data(withJSONObject: response.result.value!, options: .prettyPrinted)
                if let resultJson = try? JSON.init(data: resultData!) {
                    //                    print("resultJson: \(resultJson)")
                    
                    if let error = resultJson["error"].string {
                        print("error: \(error)")
                        print("user has not yet finished any questionnaire")
                    } else {
                        let reportsDict = resultJson["data"]
                        for (theme, report_array) in reportsDict {
                            self.report_themes.append(theme)
                            self.reports[theme] = report_array.array
                            
                            let quesData = report_array.array![0]["questionnaire_info"]
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
                            
                            let questionnaire = QuestionnaireModel(_id: _id, theme: theme, description: description, questions: questions, minest_value: minest_value, maxest_value: maxest_value, stride_value: stride_value, level_des: level_des, groups: groups, anti_questions: anti_questions, imageName: "pic0", isDone: true)
                            self.finished_queses.append(questionnaire)
                            
                        }
                        self.themeList.reloadData()
                    }
                }
            } else {
                let alertController = UIAlertController(title: "后台连接失败", message: "", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
        url = config.url + "questionnaire/getRecommendQues"
        
        Alamofire.request(url, method: .get, headers: headers).responseJSON {
            response in
            if response.result.isSuccess {
                print("后台连接成功")
                let resultData = try? JSONSerialization.data(withJSONObject: response.result.value!, options: .prettyPrinted)
                if let resultJson = try? JSON.init(data: resultData!) {
                    
                    if let error = resultJson["error"].string {
                        print("error: \(error)")
                    } else {
                        if let quesDatas = resultJson["data"].array {
                            //                       print("请求到的评测问卷数据的data字段：\(quesDatas)")
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
                                
                                self.questionnaires.append(questionnaire)
                                self.ques_themes.append(questionnaire.theme!)
                            }
                            self.themeList.reloadData()
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
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
