//
//  UserModel.swift
//  SunnyMood
//
//  Created by bytedance on 2020/5/12.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import Foundation

struct UserModel {
    var _id: String = ""
    var name: String = ""
    var bio: String = ""
    var avatar: String = ""
    var gender: String = ""
    var professor: String = ""
    var fans_number: String = ""
    var follow_number: String = ""
    var coins: Int = 0
    
    init() {}
    
    init(_id: String, name: String, bio: String, avatar: String, gender: String, professor: String, fans_number: String, follow_number: String, coins: Int) {
        self._id = _id
        self.name = name
        self.bio = bio
        self.avatar = avatar
        self.gender = gender
        self.professor = professor
        self.fans_number = fans_number
        self.follow_number = follow_number
        self.coins = coins
    }
    init(_id: String, name: String, bio: String, avatar: String, gender: String, professor: String, fans_number: String, follow_number: String) {
        self._id = _id
        self.name = name
        self.bio = bio
        self.avatar = avatar
        self.gender = gender
        self.professor = professor
        self.fans_number = fans_number
        self.follow_number = follow_number
        self.coins = 0
    }
    
    init(userModel: UserModel) {
        self.init(_id: userModel._id, name: userModel.name, bio: userModel.bio, avatar: userModel.avatar, gender: userModel.gender, professor: userModel.professor, fans_number: userModel.fans_number, follow_number: userModel.follow_number, coins: userModel.coins)
    }
    
    func printInfo() {
        print("_id: \(_id) \n name: \(name) bio: \(bio) gender: \(gender) professor: \(professor) fans_number: \(fans_number) follow_number: \(follow_number) coins: \(coins)")
    }
}
