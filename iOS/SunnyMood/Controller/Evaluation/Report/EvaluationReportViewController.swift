//
//  EvaluationReportViewController.swift
//  SunnyMood
//
//  Created by bytedance on 2020/5/17.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import UIKit

class EvaluationReportViewController: UIViewController {
    
    var index: Int? {
        didSet {
            print("you have taped index \(String(describing: index)) of the table")
        }
    }
    public var report: ReportModel? {
        didSet {
            print("report: ")
            //            report?.printInfo()
            //            self.scores = [Int?](repeating: 0, count: (report?.scores?.count)!)
            if let scores = report?.scores {
                self.scores = scores
            }
            
        }
    }
    var questionnaire: QuestionnaireModel? {
        didSet {
            print("pass questionnaire: ")
            questionnaire?.printInfo()
            self.scores = [Int?](repeating: 0, count: (questionnaire?.questions!.count)!)
        }
    }
    
    var scores = [Int?]()
    
    
    @IBAction func reEvaluationAction(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "ReEvaluationSegue", sender: self)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backToRootVC(_ sender: UIBarButtonItem) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        self.testLabel?.text = "ndex \(self.index!)"
        self.report?.printInfo()
        print("result scores: ")
        for value in scores {
            print(value!)
        }
        
        self.navigationItem.title = self.questionnaire?.theme
        
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ReEvaluationSegue" {
            let destination = segue.destination as! QuestionViewController
            destination.questionnaire = self.questionnaire
            destination.scores = self.scores
        }
    }
    
}


//import PolioPager
//
//class EvaluationReportViewController: PolioPagerViewController {
//
//    var index: Int? {
//        didSet {
//            print("you have taped index \(String(describing: index)) of the table")
//        }
//    }
//    public var report: ReportModel? {
//        didSet {
//            print("report: ")
////            report?.printInfo()
//            //            self.scores = [Int?](repeating: 0, count: (report?.scores?.count)!)
//            if let scores = report?.scores {
//                for score in scores {
//                    self.scores.append(score.int)
//                }
//            }
//
//        }
//    }
//
//    var questionnaire: QuestionnaireModel? {
//        didSet {
//            print("pass questionnaire: ")
//            questionnaire?.printInfo()
//            self.scores = [Int?](repeating: 0, count: (questionnaire?.questions!.count)!)
//        }
//    }
//
//    var scores = [Int?]()
//
//
//    @IBAction func reEvaluationAction(_ sender: UIBarButtonItem) {
//        performSegue(withIdentifier: "ReEvaluationSegue", sender: self)
//        self.dismiss(animated: true, completion: nil)
//    }
//
//    @IBAction func backToRootVC(_ sender: UIBarButtonItem) {
//        self.navigationController?.popToRootViewController(animated: true)
//    }
//
//
//    let purpleInspireColor = UIColor(red:0.13, green:0.03, blue:0.25, alpha:1.0)
//    let redColor = UIColor(red: 221/255.0, green: 0/255.0, blue: 19/255.0, alpha: 1.0)
//    let unselectedIconColor = UIColor(red: 73/255.0, green: 8/255.0, blue: 10/255.0, alpha: 1.0)
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        //        self.testLabel?.text = "ndex \(self.index!)"
//        self.report?.printInfo()
//        print("result scores: ")
//        for value in scores {
//            print(value!)
//        }
//        // Do any additional setup after loading the view.
//    }
//
//    override func tabItems() -> [TabItem] {
////        let x = [TabItem(isSearchTab: true, title: " ", image: "search"), TabItem(title: "测评结果"), TabItem(title: "详细解读"), TabItem(title: "相应分析"), TabItem(title: "发展建议")]
////        print("items.count:\(x.count)")
//        return [TabItem(isSearchTab: true, title: "", image: UIImage(named: "search.png")), TabItem(title: "测评结果"), TabItem(title: "详细解读"), TabItem(title: "发展建议")]
//    }
//    override func viewControllers() -> [UIViewController] {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let searchEvaluationViewController = storyboard.instantiateViewController(identifier: "searchEvaluationViewID")
//        let resultViewController = storyboard.instantiateViewController(withIdentifier: "resultViewID")
//        let detailsViewController = storyboard.instantiateViewController(withIdentifier: "detailsViewID")
//        let suggestionsViewController = storyboard.instantiateViewController(withIdentifier: "suggestionsViewID")
//        let x = [resultViewController, detailsViewController, suggestionsViewController]
//        print("vc.count:\(x.count)")
//        return [searchEvaluationViewController, resultViewController, detailsViewController, suggestionsViewController]
//    }
//
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//        if segue.identifier == "ReEvaluationSegue" {
//            let destination = segue.destination as! QuestionViewController
//            destination.questionnaire = self.questionnaire
//            destination.scores = self.scores
//        }
//    }

//}
