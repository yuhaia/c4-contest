//
//  QuestionViewController.swift
//  SunnyMood
//
//  Created by bytedance on 2020/5/14.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class QuestionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, addOrChangeScoreDelegate {
    func addOrChangeScore(controller: QuestionTableViewCell, score: Int, rowIndex: Int) {
        self.scores[rowIndex] = score
    }
    
    var index: Int? {
        didSet {
            print("you just taped index of \(index ?? 0)")
        }
    }
    
    var questionnaire: QuestionnaireModel? {
        didSet {
            print("pass questionnaire: ")
            questionnaire?.printInfo()
            self.scores = [Int?](repeating: 0, count: (self.questionnaire?.questions!.count)!)
        }
    }
    var scores = [Int?]()
    var keys = [String?]()
    var config = Configuration()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.questionnaire?.questions!.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "questionCell") as! QuestionTableViewCell
                let cell = tableView.dequeueReusableCell(withIdentifier: "questionCell", for: indexPath) as! QuestionTableViewCell
        cell.valueDelegate = self
        let index = indexPath.row
        // Configure the cell...
        cell.quesLabel?.text = String(index + 1) + ". " + (self.questionnaire?.questions![index].string!)!
        cell.minest_value = self.questionnaire?.minest_value!
        cell.maxest_value = self.questionnaire?.maxest_value!
        cell.stride_value = self.questionnaire?.stride_value!
        
        // MARK: -LEVEL DESCRIPTION
        var first_level = ""
        var last_level = ""
        var i = 0
        for value in self.questionnaire!.level_des! {
            if i == 0 {
                first_level = value.string!
            }
            i += 1
            last_level = value.string!
            print(last_level)
        }
        
        cell.levelLabel?.text = first_level
        cell.lastLevelLabel?.text = last_level
        
        cell.ansSlider.minimumValue = Float((self.questionnaire?.minest_value!)!)
        cell.ansSlider.maximumValue = Float((self.questionnaire?.maxest_value!)!)
        cell.ansSlider.tag = indexPath.row
        
        print("indexPath.row: \(indexPath.row)")
        print("value of slider: \(self.scores[indexPath.row])")
        cell.ansSlider.value = Float(self.scores[indexPath.row] ?? 0)   //  cell is reused and the value may be random, so we need to reassign the value
        cell.currentValueLabel.text = String(self.scores[indexPath.row] ?? 0)
        return cell
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.questionTableView.reloadData()
    }
    @IBOutlet weak var questionTableView: UITableView!
    
    @IBOutlet weak var submitBarButtonItem: UIBarButtonItem!
    
    @IBAction func submitAction(_ sender: UIBarButtonItem) {
        print("scores: ")
        print(self.scores)
        let scores = self.scores
        for score in scores {
            print(score!)
        }
        
        // 取出user_id
//        let user_id = UserDefaults.standard.object(forKey: "_id") as? String
        let token = UserDefaults.standard.object(forKey: "token") as? String
        let headers = ["token": token!]
        let questionnaire_id = self.questionnaire?._id!
//        let questionnaire_theme = self.questionnaire?.theme!
        var submit_scores = [Int]()
        for score in self.scores {
            submit_scores.append(score!)
        }
        // 提交网络请求
        let url = self.config.url + "reports/submit"
        
        let parameters = [
            "questionnaire_id": questionnaire_id!,
            "scores": submit_scores] as [String : Any]
        print("提交测评数据的网络请求")
        print(parameters)
//        let encoder = URLEncodedFormParameterEncoder(encoder: URLEncodedFormEncoder(arrayEncoding: .noBrackets))
        Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding(arrayEncoding: .noBrackets), headers: headers).responseJSON {
            response in
            if response.result.isSuccess {
                print("后台连接成功")
                let resultData = try? JSONSerialization.data(withJSONObject: response.result.value!, options: .prettyPrinted)
                if let resultJson = try? JSON.init(data: resultData!) {
//                    print("resultJson: \(resultJson)")
                    
                    if let error = resultJson["error"].string {
                        print("error: \(error)")
                    } else {
                        self.performSegue(withIdentifier: "SubmitToReportSegue", sender: self)
                    }
                }
            } else {
                print("token failed")
            }
        }
    }
    
    //    @IBOutlet weak var submitButton: UIButton!
    //    @IBAction func submitAction(_ sender: UIButton) {
    //        print("scores: ")
    //        print(self.scores)
    //        let scores = self.scores
    //        for score in scores {
    //            print(score as! Int)
    //        }
    //        performSegue(withIdentifier: "SubmitToReportSegue", sender: self)
    //
    //    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        print("toolbarItems:")
        print(self.toolbarItems)
        // Do any additional setup after loading the view.
        //        self.questionTableView.reloadData()
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "SubmitToReportSegue" {
            let destination = segue.destination as! ReportViewController
            destination.scores = self.scores as! [Int]
//            destination.keys = 
            // 为了方便用户在report界面里点击重测可以进来这里
            destination.questionnaire = self.questionnaire
            destination.theme = questionnaire?.theme

            destination.fromSubmit = true
        }
    }
    
    
}
