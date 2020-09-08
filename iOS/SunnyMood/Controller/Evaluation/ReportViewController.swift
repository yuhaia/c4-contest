//
//  ReportViewController.swift
//  SunnyMood
//
//  Created by bytedance on 2020/8/2.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Charts

class ReportViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, tapDetail {
    func popOverDetail(detail: String) {
        
        // TODO 
        
//        print("show the detail popover...")
//        print("detail is \(detail)");
//        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "reportCellDetail") as! reportCellDetailViewController
//        //        if let popOverPresentController = popOverVC.popoverPresentationController {
//        //            popoverPresentationController?.permittedArrowDirections = .up
//        //            popoverPresentationController?.sourceView = self.view
//        //            popoverPresentationController?.delegate = self
//        //        }
//        popOverVC.modalPresentationStyle = .popover
//        popOverVC.detail = detail
//        popOverVC.detailLabel?.text = detail
////        self.addChild(popOverVC)
//        popOverVC.view.frame.size.width = 100.0
//        popOverVC.view.frame.size.height = 200.0
//        self.view.addSubview(popOverVC.view)
        
    }
    var lastContentOffset = CGFloat(0.0)
    
    // replace -100 with the height of your view. The left side of the range needs to be negative, in order to allow movement upward.
    // this example allows the view to move -100 points upward, and the maximum positive value it can hold is 0.
    let minimumConstantValue = CGFloat(-200) // Replace this with the negated height of your view.
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reportCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reportCell", for: indexPath) as! ReportTableViewCell
        let reportCell = reportCells[indexPath.row]
        let total_width = cell.totalScoreLabelBG.frame.width
        let score_width = CGFloat(reportCell.user_score! / 100.0) * total_width
        //        cell.scoreLabelBG.widthAnchor.constraint(equalToConstant: score_width).isActive = true
        
        //        cell.scoreLabelBG.frame.size.width = score_width;
        cell.tapDetailDelegate = self
        cell.reloadData(reportCell: reportCell, total_width:cell.totalScoreLabelBG.frame.width,  navigationController: self.navigationController)
        
        print("index: \(indexPath.row)");
        print("user score: \(reportCell.user_score!)");
        print("total width: \(total_width)");
        print("score width: \(score_width)");
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.estimatedRowHeight
    }
    
    
    // lazy
    var radarChartView:RadarChartView!
//    var a: Int;
//    func test(a:Int)  {
//        self.a = a;
//    }
    
    @IBOutlet weak var reportTableView: UITableView!
    
    let def = UserDefaults.standard
    let config = Configuration()
    var report: ReportModel? {
        didSet {
            print("report:")
            report?.printInfo()
        }
    }
    var keys: [String]?
    var scores: [Int]?
    var resultDataSet: RadarChartDataSet?

    var reportCells = [ReportCellModel]() {
        didSet {
            print("reportCells in ReportViewController has be setted...")
        }
    }
    var theme: String?
    var questionnaire: QuestionnaireModel?
    
    var fromSubmit = false
    
    func updateRadarChart() {
        var RadarChartDataEntryArray = [RadarChartDataEntry]()
        for score in self.scores! {
            RadarChartDataEntryArray.append(RadarChartDataEntry(value: Double(score)))
        }
        self.resultDataSet = RadarChartDataSet(
            entries: RadarChartDataEntryArray
        )

        // Customizing the Layout of a Data Set
        // 1
        self.resultDataSet!.lineWidth = 2

        // 2
        let greenColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        let greenFillColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
        self.resultDataSet!.colors = [greenColor]
        self.resultDataSet!.fillColor = greenFillColor
        self.resultDataSet!.drawFilledEnabled = true

        self.radarChartView.webLineWidth = 1.5
        self.radarChartView.innerWebLineWidth = 1.5
        self.radarChartView.webColor = .lightGray
        self.radarChartView.innerWebColor = .lightGray

        // 3
        let xAxis = self.radarChartView.xAxis
        xAxis.labelFont = .systemFont(ofSize: 12)
        xAxis.labelTextColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
//        xAxis.labelTextColor = .black
        xAxis.xOffset = 10
        xAxis.yOffset = 10
        xAxis.valueFormatter = XAxisFormatter(titles: self.keys!)

        // 4
        let yAxis = self.radarChartView.yAxis
        yAxis.labelFont = .systemFont(ofSize: 12)
        yAxis.labelTextColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        yAxis.labelCount = 6
        yAxis.drawTopYLabelEntryEnabled = false
        yAxis.axisMinimum = 0
        yAxis.valueFormatter = YAxisFormatter()

        // 5
        self.radarChartView.rotationEnabled = false
        self.radarChartView.legend.enabled = false
        // 3
        self.resultDataSet!.valueFormatter = DataSetValueFormatter()

        print(self.resultDataSet!)
        let data = RadarChartData(dataSets: [self.resultDataSet!])
        // 3
        self.radarChartView.data = data
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reportTableView.register(UINib(nibName: "ReportTableViewCell", bundle: nil), forCellReuseIdentifier: "reportCell")
        
        self.reportTableView.delegate = self
        self.reportTableView.dataSource = self
        
        self.reportTableView.allowsSelection = false
        radarChartView = RadarChartView(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 250))
        self.reportTableView.tableHeaderView = radarChartView
        
        if (self.fromSubmit == true) {
            self.requestData()
        } else {
            self.reportTableView.reloadData()
            self.updateRadarChart()
        }
        
//        self.radarChartView.slideY(y: -200)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backToRootVC(_ sender: UIBarButtonItem) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func reEvaluationAction(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "ReEvaluationSegue", sender: self)
        self.dismiss(animated: true, completion: nil)
    }
    
    //      In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ReEvaluationSegue" {
            let destination = segue.destination as! QuestionViewController
            destination.questionnaire = self.questionnaire
            //            destination.scores = self.scores
        }
    }
    
    func requestData() {
        
        print("not call here ???")
        
        let getReportURL = self.config.url + "reports/getReportByUserIDandQuesID"
        
        let user_id = def.string(forKey: "_id")
        let parameters = ["user_id": user_id!, "questionnaire_id": self.questionnaire!._id!]
        print("parameters:")
        print(parameters)
        Alamofire.request(getReportURL, method: .get, parameters: parameters).responseJSON {
            response in
            print("what is going on")
            if response.result.isSuccess {
                print("后台连接成功。。。")
                let reportResultData = try? JSONSerialization.data(withJSONObject: response.result.value!, options: .prettyPrinted)
                if let reportResultJson = try? JSON.init(data: reportResultData!) {
                    //                    print("resultJson: \(resultJson)")
                    
                    if let error = reportResultJson["error"].string {
                        print("error: \(error)")
                    } else {
                        let reportData = reportResultJson["data"]
                        let report_id = reportData["_id"].string!
                        let res = reportData["result"]
                        let general = res["general_evaluation"]
                        let scores_json = general["scores"]
                        
                        var scores = [Int]()
                        var keys = [String]()
                        for (key, first_level_result) in reportData["result"]["child_groups"] {
                            keys.append(key)
                            if self.questionnaire!.theme! == "潜能测试" {
                                scores.append(first_level_result["general_evaluation"]["average_score"].int ?? 0)
                            } else {
                                scores.append(Int(first_level_result["average_score"].number ?? 0))
                            }
                        }
                        self.keys = keys
                        self.scores = scores
                        
                        let time = reportData["time"].numberValue
                        let result = reportData["result"]
                        
                        let questionnaire_info = reportData["questionnaire_info"]
                        let questionnaire_id = questionnaire_info["_id"].string!
                        let questionnaire_theme = questionnaire_info["theme"].string!
                        
                        let report = ReportModel(_id: report_id, user_id: user_id!, questionnaire_id: questionnaire_id, questionnaire_theme: questionnaire_theme, scores: scores, time: time, result: result)
                        
                        let report_result = report.result!
                        let child_groups = report_result["child_groups"]
                        var reportCells = [ReportCellModel]()
                        for (key, value) in child_groups {
                            
                            var image_name = ""
                            
                            switch key {
                            case "疲劳":
                                image_name = "tired"
                            case "紧张不安":
                                image_name = "nervous"
                            case "愤怒":
                                image_name = "angry"
                            case "抑郁":
                                image_name = "depressed"
                            case "困惑":
                                image_name = "confused"
                            case "活力":
                                image_name = "energy"
                            default:
                                image_name = "pic" + String(Int.random(in: 1...6))
                            }
                            
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
                        self.reportCells = reportCells
                        self.reportTableView.reloadData()
                        self.updateRadarChart()
                    }
                }
            } else {
                print("后台连接失败。。。")
            }
        }
        print("what?")
    }
}

extension RadarChartView {

    func slideX(x:CGFloat) {

        let yPosition = self.frame.origin.y

        let height = self.frame.height
        let width = self.frame.width

        UIView.animate(withDuration: 1.0, animations: {

            self.frame = CGRect(x: x, y: yPosition, width: width, height: height)

        })
    }
    
    func slideY(y:CGFloat) {

        let xPosition = self.frame.origin.x

        let height = self.frame.height
        let width = self.frame.width

        UIView.animate(withDuration: 0.2, animations: {

            self.frame = CGRect(x: xPosition, y: y, width: width, height: height)

        })
    }
}

extension ReportViewController : ShowOrHideDetailDelegate {
    func changeHeight() {
        self.reportTableView.reloadData()
    }
    
    
}
