//
//  CoinsViewController.swift
//  SunnyMood
//
//  Created by bytedance on 2020/6/19.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class CoinsViewController: UIViewController {

    var user_info: UserModel?
    var config = Configuration()
    
    @IBOutlet weak var coinsLabel: UILabel!
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var ruleLabel: UILabel!
    
    @IBOutlet weak var seeDetailsButton: UIButton!
    
    @IBAction func payAction(_ sender: UIButton) {
        let alertController = UIAlertController(title: "暂未开通服务", message: "请耐心等待下一版本", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    @IBAction func seeDetailsAction(_ sender: UIButton) {
        let alertController = UIAlertController(title: "暂未开通服务", message: "请耐心等待下一版本", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rule_str = "金币的引入是为了完善小组打卡的奖惩机制，督促用户更好的完成预期的目标。在您注册系统时便会赠送100金币，后期您可以购买相关数目的金币。具体的奖惩机制为：系统在您加入小组时扣除5个金币，待小组期限截止之际，对于完成相关打卡的用户我们会如数退还这5个金币，此外，我们会把没有完成目标的用户的金币汇总平均分给已完成的用户。希望您再接再厉，完成预期目标噢，加油，奥利给！"
        //通过富文本来设置行间距
        let paraph = NSMutableParagraphStyle()
        //将行间距设置为28
        paraph.lineSpacing = 20
        //样式属性集合
        let attributes = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 15),
                          NSAttributedString.Key.paragraphStyle: paraph]
        self.ruleLabel.attributedText = NSAttributedString(string: rule_str, attributes: attributes)
        // Do any additional setup after loading the view.
        self.requestUserInfo()
    }
    
    func requestUserInfo() {
        let url = config.url + "users/getUserByID"
        let token = UserDefaults.standard.object(forKey: "token") as! String
        let user_id = self.user_info?._id
        let parameters = ["user_id": user_id!]
        let headers = ["token": token]
        Alamofire.request(url, method: .get, parameters: parameters, headers: headers).responseJSON {
            response in
            if response.result.isSuccess {
                print("后台连接成功")
                let resultData = try? JSONSerialization.data(withJSONObject: response.result.value!, options: .prettyPrinted)
                if let resultJson = try? JSON.init(data: resultData!) {
                    if let error = resultJson["error"].string {
                        print("error: \(error)")
                    } else {
                        let user_res = resultJson["data"]
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                            let coins = user_res["coins"].int
                            self.coinsLabel.text = "您的金币余额为: " + String(coins!) + "枚"
                        }
                    }
                }
            }
        }
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
