//
//  ReportsListTableViewCell.swift
//  SunnyMood
//
//  Created by bytedance on 2020/7/25.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import UIKit

class ReportsListTableViewCell: UITableViewCell {

    
    @IBOutlet weak var themeLable: UILabel!
    @IBOutlet weak var flagLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func reloadData(theme: String, reportFlag: Bool, navigationController: UINavigationController?) {
        
        self.flagLabel.layer.cornerRadius = (self.flagLabel.frame.size.height)/2.0
        self.flagLabel.layer.masksToBounds = true
        
        self.themeLable.text = theme
        if reportFlag == true {
            self.flagLabel.text = "查看结果"
            self.flagLabel.backgroundColor = #colorLiteral(red: 0.4966237545, green: 0.6555117369, blue: 0.562161386, alpha: 1)
        } else {
            self.flagLabel.text = "进入测评"
            self.flagLabel.backgroundColor = #colorLiteral(red: 0.7066736356, green: 0.3337643046, blue: 0.3682053257, alpha: 1)
        }
    }
    
}
