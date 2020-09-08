//
//  ReportCellModel.swift
//  SunnyMood
//
//  Created by bytedance on 2020/8/2.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import Foundation

//
//  ReportCellModel.swift
//  SunnyMood
//
//  Created by bytedance on 2020/5/13.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import Foundation
import SwiftyJSON

class ReportCellModel: NSObject {
    var image_name: String?
    var title_name: String?
    var time: String?
    var user_score: Double?
    var total_score: Int?
    var eval_des: String?
    var suggestion: String?
    
    init(image_name: String, title_name: String, time: String, user_score: Double, total_score: Int, eval_des: String, suggestion: String) {
        self.image_name = image_name
        self.title_name = title_name
        self.time = time
        self.user_score = user_score
        self.total_score = total_score
        self.eval_des = eval_des
        self.suggestion = suggestion
    }
    
    convenience override init() {
        self.init(image_name: "", title_name: "", time: "", user_score: 0.0, total_score: 100, eval_des: "", suggestion: "")
    }
    
    func printInfo() {
        print("report cell info:")
        print("title_name: \(self.title_name!)")
        print("user_score:")
        print(self.user_score!)
        print("suggestion:")
        print(self.suggestion!)
    }
}
