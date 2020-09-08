//
//  reportCellDetailViewController.swift
//  SunnyMood
//
//  Created by bytedance on 2020/8/6.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import UIKit

class reportCellDetailViewController: UIViewController {
    var detail: String? {
        didSet {
            self.detailLabel?.text = detail
        }
    }
    @IBOutlet weak var detailLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
