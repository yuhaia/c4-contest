//
//  questionnaireBrief.swift
//  SunnyMood
//
//  Created by bytedance on 2020/5/12.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import Foundation
import SwiftyJSON

// 用户从首页的table里点击进入详情问卷页面完成后 应该设置delegate使得首页的状态发生变化（进入or查看完成结果）
class QuestionnaireModel: NSObject {
    var _id: String?
    var theme: String?
    var _description: String?  // 与父亲的description冲突
    var questions: [JSON]?
    var minest_value: Int?
    var maxest_value: Int?
    var stride_value: Int?
    var level_des: [JSON]?
    var groups: JSON?
    var anti_questions:[JSON]?
    var imageName: String?
    var isDone: Bool?
    // isDone 这个是可以根据user id和ques id 查看是否有report来得到用户是否完成该评测
    // 这里暂时写死3个评测数据 放在UserDefaults里 
    
    init(_id: String, theme: String, description: String, questions: [JSON], minest_value: Int, maxest_value: Int, stride_value: Int, level_des: [JSON], groups: JSON, anti_questions: [JSON], imageName: String, isDone: Bool) {
        self._id = _id
        self.theme = theme
        self._description = description
        self.questions = questions
        self.minest_value = minest_value
        self.maxest_value = maxest_value
        self.stride_value = stride_value
        self.level_des = level_des
        self.groups = groups
        self.anti_questions = anti_questions
        self.imageName = imageName
        self.isDone = isDone
    }
    
    func changeIsDoneState() {
        self.isDone = !(self.isDone!)
    }
    
    func printInfo() {
        print("_id: \(_id!) theme: \(theme!) description: \(_description!) imageName: \(imageName!) isDone: \(isDone!)")
        print("questions:")
        print(questions!)
        print("groups")
        print(groups!)
    }
}
