//
//  QuesBriefTableViewCell.swift
//  SunnyMood
//
//  Created by bytedance on 2020/5/13.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import UIKit

class QuesBriefTableViewCell: UITableViewCell {

    @IBOutlet weak var quesImageView: UIImageView!
    @IBOutlet weak var themeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var toQuesOrReportLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
