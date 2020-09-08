//
//  QuestionTableViewCell.swift
//  SunnyMood
//
//  Created by bytedance on 2020/5/13.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import UIKit

protocol addOrChangeScoreDelegate {
    func addOrChangeScore(controller: QuestionTableViewCell, score: Int, rowIndex: Int)
}
class QuestionTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var quesLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var lastLevelLabel: UILabel!
    @IBOutlet weak var ansSlider: UISlider!
    var minest_value: Int?
    var maxest_value: Int?
    var stride_value: Int?
    var valueDelegate: addOrChangeScoreDelegate! = nil
    @IBOutlet weak var currentValueLabel: UILabel!
    
    func configureDefaultSlider() {
        self.ansSlider.minimumValue = Float(self.minest_value!)
        self.ansSlider.maximumValue = Float(self.maxest_value!)
    }
    
    @IBAction func ansSliderChangeAction(_ sender: UISlider) {
        //        let currentValue = Int(sender.value)
        let currentValue = sender.value
        print("slider current value: \(currentValue)")
        let row = self.ansSlider.tag
        print("the row of users tap is \(row)")
        
        print("the sender is: \(sender.tag)")
        
        self.currentValueLabel.text = String(Int(currentValue))
        
        self.configureDefaultSlider()
        self.valueDelegate.addOrChangeScore(controller: self, score: Int(currentValue), rowIndex: row)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // found nil
        //        self.configureDefaultSlider()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
