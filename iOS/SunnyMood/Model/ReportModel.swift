//
//  ReportModel.swift
//  SunnyMood
//
//  Created by bytedance on 2020/5/13.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import Foundation
import SwiftyJSON

class ReportModel: NSObject {
    var _id: String?
    var user_id: String?
    var questionnaire_id: String?
    var questionnaire_theme: String?
    var scores: [Int]?
    var time: NSNumber?
    var result: JSON?
    
    init(_id: String, user_id: String, questionnaire_id: String, questionnaire_theme: String, scores: [Int], time: NSNumber, result: JSON) {
        self._id = _id
        self.user_id = user_id
        self.questionnaire_id = questionnaire_id
        self.questionnaire_theme = questionnaire_theme
        self.scores = scores
        self.result = result
    }
    
    convenience override init() {
        self.init(_id: "", user_id: "", questionnaire_id: "", questionnaire_theme: "", scores: [Int](), time: 0, result: JSON())
    }
    
    func printInfo() {
        print("report info:")
        print("_id: \(self._id!)")
        print("scores:")
        print(self.scores!)
        print("result:")
        print(self.result!)
    }
}
