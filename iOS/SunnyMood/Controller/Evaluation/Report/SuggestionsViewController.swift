//
//  SuggestionsViewController.swift
//  SunnyMood
//
//  Created by bytedance on 2020/5/15.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class SuggestionsViewController: UIViewController, IndicatorInfoProvider, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return child_details.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! DetailTableViewCell
        
        cell.frame = tableView.bounds
        cell.layoutIfNeeded()
        
        cell.detailLabel.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        let detail = child_details[indexPath.row]
        cell.reloadData(detail: detail, isSuggestion: true)
        
        return cell
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "发展建议")
    }
    
    @IBOutlet weak var suggestionTableView: UITableView!
    
    @IBOutlet weak var parentSuggestionLabel: UILabel!
    @IBOutlet weak var themeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.themeLabel.text = parent_detail?.itemTitle
        if let suggestion_str = parent_detail?.itemSuggestion {
            //通过富文本来设置行间距
            let paraph = NSMutableParagraphStyle()
            //将行间距设置为28
            paraph.lineSpacing = 15
            //样式属性集合
            let attributes = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 15),
                              NSAttributedString.Key.paragraphStyle: paraph]
            self.parentSuggestionLabel.attributedText = NSAttributedString(string: suggestion_str, attributes: attributes)
        }
        
        
        
        if (theme! == "生活平衡测试") {
            self.suggestionTableView.isHidden = true
        }
        
        self.suggestionTableView.delegate = self
        self.suggestionTableView.dataSource = self
        
        self.suggestionTableView.separatorStyle = .none
        
        self.suggestionTableView.register(UINib(nibName: "DetailTableViewCell", bundle: nil), forCellReuseIdentifier: "detailCell")
        
        self.suggestionTableView.estimatedRowHeight = 44.0
        self.suggestionTableView.rowHeight = UITableView.automaticDimension
        
        
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
