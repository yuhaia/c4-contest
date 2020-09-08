//
//  ReportTableViewCell.swift
//  SunnyMood
//
//  Created by bytedance on 2020/8/2.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import UIKit

protocol tapDetail {
    func popOverDetail(detail: String);
}

protocol ShowOrHideDetailDelegate {
    func changeHeight()
}

class ReportTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var scoreLabelBG: UILabel!
    @IBOutlet weak var totalScoreLabelBG: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var totalScoreLabel: UILabel!
    
    @IBOutlet weak var okImageView: UIImageView!
    @IBOutlet weak var resLabel: UILabel!
    @IBOutlet weak var toDetailButton: UIButton!
    
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var hideDetailButton: UIButton!
    
    var tapDetailDelegate: tapDetail?
    var showOrHideDetailDelegate: ShowOrHideDetailDelegate?
    
    var detail = "hello~"
    var hideDetail = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
//        self.detailLabel.isHidden = true
        self.toDetailButton.isHidden = true
        self.hideDetailButton.isHidden = true
                
//        self.frame.size.height = 160.0

        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//    @IBAction func toDetailAction(_ sender: UIButton) {
//        // method1: pop over
//        // ref: https://www.youtube.com/watch?v=FgCIRMz_3dE
////        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "reportCellDetail") as! reportCellDetailViewController
////        self.addChild
////        print("user tapped detail which is  \(self.detail)");
////        self.tapDetailDelegate?.popOverDetail(detail: self.detail)
//
//        // method2: just show and hide
//        self.hideDetail = false
//        self.detailLabel.isHidden = false
//        self.hideDetailButton.isHidden = false
//        self.toDetailButton.isHidden = true
//
//        self.detailLabel.text = self.detail
//
//        self.frame.size.height = 160.0 + self.detailLabel.frame.size.height + self.hideDetailButton.frame.size.height + 36
//
////        self.layoutIfNeeded();
//        self.setNeedsLayout()
//
//        showOrHideDetailDelegate?.changeHeight()
//    }
    
//    @IBAction func hideDetailAction(_ sender: UIButton) {
//        self.hideDetail = true
//        self.detailLabel.isHidden = true
//        self.hideDetailButton.isHidden = true
//        self.toDetailButton.isHidden = false
//
//        self.frame.size.height = 160.0
//
////        self.layoutIfNeeded()
//        self.setNeedsLayout()
//
//        showOrHideDetailDelegate?.changeHeight()
//
//    }
    
    
    func reloadData(reportCell: ReportCellModel, total_width: CGFloat, navigationController: UINavigationController?) {
        
        print("start to run cell.reloadData()")
        self.avatarImageView.image = UIImage(named: reportCell.image_name!)
        self.titleLabel.text = reportCell.title_name
        self.timeLabel.text = reportCell.time
        self.scoreLabel.text = String(reportCell.user_score!)
        self.totalScoreLabel.text = "100"
        self.resLabel.text = reportCell.eval_des
        self.detail = reportCell.suggestion!
        self.detailLabel.text = self.detail
        
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.width / 2
        self.scoreLabelBG.layer.cornerRadius = self.scoreLabelBG.frame.size.height/2.0
        self.totalScoreLabelBG.layer.cornerRadius = self.totalScoreLabelBG.frame.size.height/2.0

        self.contentView.layer.cornerRadius = 5.0
    
        let score_width = CGFloat(reportCell.user_score! / 100.0) * total_width
        
        //ref:https://stackoverflow.com/questions/40567804/swift-programmatically-create-uilabel-fixed-width-that-resizes-vertically-accor
        self.scoreLabelBG.widthAnchor.constraint(equalToConstant: score_width).isActive = true
        
//        self.scoreLabelBG.frame.size.width = score_width;
        
        
//        self.layoutIfNeeded();
        
//        self.frame.size.height = 160.0
        self.setNeedsLayout()
    }
    
}
