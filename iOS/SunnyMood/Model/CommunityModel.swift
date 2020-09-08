//
//  CommunityModel.swift
//  SunnyMood
//
//  Created by bytedance on 2020/6/17.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import Foundation
import SwiftyJSON

class CommunityModel: NSObject {
    var id: String?
    var name: String?
    var des: String?
    var avatar: String?
    var resource_name: String?
    var resource_id: String?
    var time_start: NSNumber?
    var time_end: NSNumber?
    var frequency: Int?
    var way: String?
    var ps: String?
    var coins_needed: Int?
    var sponsor_id: String?
    var sponsor_info: JSON?
    var time_create: String?
    var users_id: [String]?
    var moments_id: [String]?
    var praises: Int?
    
    var isMember: Bool?
    
    override init() {
        super.init()
    }
//    init(name: String, des: String) {
//        self.name = name
//        self.des = des
//    }
//
//    convenience override init() {
//        self.init(name: "", des: "")
//    }
//
//    override convenience init(community_json: JSON) {
//        let name = community_json["name"].string!
//        let des = community_json["description"].string!
//        self.init(name: name, des: des)
//    }
    
    func printInfo() {
        print("community info:")
        print("name: \(self.name!)")
        print("description: \(self.des!)")
        print("sponsor_id: \(self.sponsor_id!)")
    }
}
