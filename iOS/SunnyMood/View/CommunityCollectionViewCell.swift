//
//  CommunityCollectionViewCell.swift
//  SunnyMood
//
//  Created by bytedance on 2020/8/9.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import UIKit

class CommunityCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var resourceLabel: UILabel!
    @IBOutlet weak var rangeTimeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func reloadData(imageUrl: String, placeHolderImageUrl: String, name: String, resourceName: String, rangeTime: String, navigationController: UINavigationController?) {
        self.imageView.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: placeHolderImageUrl), completed: nil)
                imageView.layer.cornerRadius = 5.0
        self.nameLabel.text = name
        self.resourceLabel.text = resourceName
        self.rangeTimeLabel.text = rangeTime
       }
    
}
