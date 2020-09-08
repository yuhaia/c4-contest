//
//  MomentModel.swift
//  SunnyMood
//
//  Created by bytedance on 2020/5/22.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import Foundation
import SwiftyJSON

class MomentModel: NSObject {
    var _id: String?
    var user_id: String?
    var texts: String?
    var time: NSNumber?
    var pictures_number: Int?
    var pictures: [String]?
    var praises: Int?
    var user_info: JSON?
    
    override init() {}
    
    func printInfo() {
        print("moment info:")
        print("texts: \(self.texts!)")
        print("pictures_number: \(self.pictures_number!)")
        print("pictures: \(self.pictures!)")
        print("user_info: \(self.user_info!)")
    }
}
