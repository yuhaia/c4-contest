//
//  ResultViewController.swift
//  SunnyMood
//
//  Created by bytedance on 2020/5/15.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import UIKit
import Charts
import Alamofire
import SwiftyJSON

let def = UserDefaults.standard
public var report: JSON?
public var theme: String?

class ResultViewController: UIViewController {
    //    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
    //        return IndicatorInfo(title: "测评结果")
    //    }
    
    var config = Configuration()
    
    var questionnaire: JSON?
    var resultDataSet: RadarChartDataSet?

    @IBOutlet weak var radarChart: RadarChartView!
    
    //    @IBOutlet weak var radarChart: RadarChartView!
    public override func viewDidLoad() {
        
        let token = UserDefaults.standard.object(forKey: "token") as! String
        print("token: \(token)")
        
        super.viewDidLoad()
        print("parameters before:")
        let selected_questionnaire_id = def.string(forKey: "selected_questionnaire_id")
        let user_id = def.string(forKey: "_id")
        let url = config.url + "reports/getReportByUserIDandQuesID"
        let parameters = ["user_id": user_id!, "questionnaire_id": selected_questionnaire_id!]
        print("parameters:")
        print(parameters)
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("后台连接成功")
                let resultData = try? JSONSerialization.data(withJSONObject: response.result.value!, options: .prettyPrinted)
                if let resultJson = try? JSON.init(data: resultData!) {
//                    print("resultJson: \(resultJson)")
                    
                    if let error = resultJson["error"].string {
                        print("error: \(error)")
                        
                        let alertController = UIAlertController(title: "暂无报告", message: "", preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertController.addAction(defaultAction)
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        report = resultJson["data"]
                        self.questionnaire = resultJson["data"]["questionnaire_info"]
                        theme = self.questionnaire!["theme"].string!
                        
                        // 取出每个点的分数情况
                        print("report.result:")
                        print(report!["result"])
                        var scores = [Int]()
                        var keys = [String]()
                        for (key, first_level_result) in report!["result"]["child_groups"] {
                            keys.append(key)
                            
                            if self.questionnaire!["theme"].string! == "潜能测试" {
                                scores.append(first_level_result["general_evaluation"]["average_score"].int ?? 0)
                            } else {
                                scores.append(Int(first_level_result["average_score"].number ?? 0))
                            }
                        }
                        print("keys:")
                        print(keys)
                        print("scores:")
                        print(scores)
                        if Thread.isMainThread {
                            print("Main Thread")
                        }

                        var RadarChartDataEntryArray = [RadarChartDataEntry]()
                        for score in scores {
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

                        self.radarChart.webLineWidth = 1.5
                        self.radarChart.innerWebLineWidth = 1.5
                        self.radarChart.webColor = .lightGray
                        self.radarChart.innerWebColor = .lightGray

                        // 3
                        let xAxis = self.radarChart.xAxis
                        xAxis.labelFont = .systemFont(ofSize: 9, weight: .bold)
                        xAxis.labelTextColor = .black
                        xAxis.xOffset = 10
                        xAxis.yOffset = 10
                        xAxis.valueFormatter = XAxisFormatter(titles: keys)

                        // 4
                        let yAxis = self.radarChart.yAxis
                        yAxis.labelFont = .systemFont(ofSize: 9, weight: .light)
                        yAxis.labelCount = 6
                        yAxis.drawTopYLabelEntryEnabled = false
                        yAxis.axisMinimum = 0
                        yAxis.valueFormatter = YAxisFormatter()

                        // 5
                        self.radarChart.rotationEnabled = false
                        self.radarChart.legend.enabled = false
                        // 3
                        self.resultDataSet!.valueFormatter = DataSetValueFormatter()

                        print(self.resultDataSet!)
                        let data = RadarChartData(dataSets: [self.resultDataSet!])
                        // 3
                        self.radarChart.data = data
                    }
                }
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


// 1
class DataSetValueFormatter: IValueFormatter {
    
    func stringForValue(_ value: Double,
                        entry: ChartDataEntry,
                        dataSetIndex: Int,
                        viewPortHandler: ViewPortHandler?) -> String {
        ""
    }
}

// 2
class XAxisFormatter: IAxisValueFormatter {
    let questionnaire_theme = def.string(forKey: "selected_questionnaire_theme")
    var titles: [String]?
    init(titles: [String]) {
        self.titles = titles
    }
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
//        let titles = "ABCDEFGH".map { "Party \($0)" }
//        var titles = [String]()
//        if questionnaire_theme! == "生活平衡测试" {
//            titles = ["职业发展", "财务状况", "身心健康", "朋友家人", "亲密关系", "个人成长", "消遣娱乐", "自然环境"]
//        } else if questionnaire_theme! == "情绪指数测试" {
//            titles = ["愤怒", "困惑", "抑郁", "紧张不安", "疲劳", "活力"]
//        }
        return (titles![Int(value) % titles!.count])
    }
}

// 3
class YAxisFormatter: IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        "\(Int(value))"
    }
}

