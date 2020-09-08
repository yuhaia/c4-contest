//
//  ResourceModel.swift
//  SunnyMood
//
//  Created by bytedance on 2020/5/15.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import Foundation
import UIKit

class ResourceModel: NSObject {
    var _id: String?
    var category: String?
    var name: String?
    var picture_url: String?
    var time: String?
    var author: String?
    var link: String?
    var _description: String?
    var likes: String?
    var labels: String?
    var isUserLike: String?
    var communities_id: [String]?
    
    init(_id: String?, category: String?, name: String?, picture_url: String?, time: String?, author: String?, link: String?, _description: String?, likes: String?, labels: String?, isUserLike: String?, communities_id: [String]?
    ) {
        self._id = _id
        self.category = category
        self.name = name
        self.picture_url = picture_url
        self.time = time
        self.author = author
        self.link = link
        self._description = _description
        self.likes = likes
        self.labels = labels
        self.isUserLike = isUserLike
        self.communities_id = communities_id
    }
    convenience override init() {
        self.init(_id: "", category: "", name: "", picture_url: "", time: "", author: "", link: "", _description: "", likes: "", labels: "", isUserLike: "0", communities_id: [])
    }
    
    func printInfo() {
        print("resource: ")
        print("_id: \(_id!) name: \(name!)")
        print("picture_url: \(picture_url!)")
        
        print("communities_id:")
        print(communities_id!)
    }
}
