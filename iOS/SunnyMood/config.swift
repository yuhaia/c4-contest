//
//  config.swift
//  SunnyMood
//
//  Created by bytedance on 2020/5/12.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import Foundation

class Configuration {
//    let url = "https://xinqing.today/v1.0/"         // google server
    let url = "https://xinqing.mysspku.com/v1.0/" // huawei server
    let limit = 10      // 批量加载的每次加载数目
}

class TakeUserInfo {
    var user: UserModel?
    init() {
        let def = UserDefaults.standard
        if let _id = def.object(forKey: "_id") as? String {
            let name = def.object(forKey: "name") as! String
            let bio = def.object(forKey: "bio") as! String
            let gender = def.object(forKey: "gender") as! String
            let professor = def.object(forKey: "professor") as! String
            let avatar = def.object(forKey: "avatar") as! String
            let fans_number = def.object(forKey: "fans_number") as! String
            let follow_number = def.object(forKey: "follow_number") as! String
            if let coins = def.object(forKey: "coins") {
                self.user = UserModel(_id: _id, name: name, bio: bio, avatar: avatar, gender: gender, professor: professor, fans_number: fans_number, follow_number: follow_number, coins: coins as! Int)
            } else {
                self.user = UserModel(_id: _id, name: name, bio: bio, avatar: avatar, gender: gender, professor: professor, fans_number: fans_number, follow_number: follow_number)
            }
            
        }
        self.user?.printInfo()
    }
}
