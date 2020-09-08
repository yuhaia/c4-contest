//
//  MedalCollectionViewCell.swift
//  SunnyMood
//
//  Created by bytedance on 2020/8/10.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import UIKit

class MedalCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var medalImageView: UIImageView!
    @IBOutlet weak var medalTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func reloadData(unlock: Bool, title: String, imageName: String, navigationController: UINavigationController) {
        self.medalTitleLabel.text = title
        self.medalImageView.image = UIImage(named: imageName)
//        self.bgView.layer.cornerRadius
        
        if unlock == true {
            self.bgView.layer.backgroundColor = #colorLiteral(red: 0.9724641442, green: 0.9726034999, blue: 0.9724336267, alpha: 1)
            self.medalTitleLabel.textColor = #colorLiteral(red: 0.6273892522, green: 0.6470953822, blue: 0.6195319295, alpha: 1)
        } else {
            self.bgView.layer.backgroundColor = #colorLiteral(red: 0.4744393229, green: 0.5647366643, blue: 0.4666071534, alpha: 1)
            self.medalTitleLabel.textColor = #colorLiteral(red: 0.2195785642, green: 0.2431526184, blue: 0.2234978378, alpha: 1)
        }
    }

}
