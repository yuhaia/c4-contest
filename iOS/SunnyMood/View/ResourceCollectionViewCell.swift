//
//  ResourceCollectionViewCell.swift
//  SunnyMood
//
//  Created by bytedance on 2020/5/16.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import UIKit
import SDWebImage

class ResourceCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var resourcePictureImageView: UIImageView!
    @IBOutlet weak var resourceNameLabel: UILabel!
    @IBOutlet weak var resourceLikeIcon: UIImageView!
    @IBOutlet weak var resourceLikesNumberLabel: UILabel!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var resource: ResourceModel? {
        didSet {
            if let resource = resource {
                let url = URL(string: resource.picture_url!)

                resourcePictureImageView.sd_setImage(with: url)
//                resourcePictureImageView.image = resource.picture!
                resourceNameLabel.text = resource.name!
                resourceLikesNumberLabel.text = resource.likes!
            }
        }
    }
}
