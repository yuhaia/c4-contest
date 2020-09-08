//
//  ResourceCVC.swift
//  SunnyMood
//
//  Created by bytedance on 2020/8/15.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import UIKit

class ResourceCVC: UICollectionViewCell {

    @IBOutlet weak var resourcePictureImageView: UIImageView!
    @IBOutlet weak var resourceNameLabel: UILabel!
    @IBOutlet weak var resourceLikeIcon: UIImageView!
    @IBOutlet weak var resourceLikesNumberLabel: UILabel!
    var resource: ResourceModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func reloadData(resource: ResourceModel, navigationController: UINavigationController?) {
        let url = URL(string: resource.picture_url!)
        
        resourcePictureImageView.sd_setImage(with: url)
        resourceNameLabel.text = resource.name!
        
        if resource.isUserLike == "1" {
            //            print("user likes the resource")
            resourceLikeIcon?.image = UIImage(systemName: "star.fill")
        } else {
            //            print("user dislikes the resource")
            resourceLikeIcon?.image = UIImage(systemName: "star")
        }
        
        resourceLikesNumberLabel.text = resource.likes!
        
        self.layer.cornerRadius = 20.0
        self.layer.backgroundColor = #colorLiteral(red: 0.9999127984, green: 1, blue: 0.9998814464, alpha: 1)
    }

}
