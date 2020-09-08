//
//  CreateCommunityViewController.swift
//  SunnyMood
//
//  Created by bytedance on 2020/5/21.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import UIKit
import SwiftForms
import SwiftyJSON
import Alamofire

protocol DisappearDelegate {
    func disappear()
}

class CreateCommunityViewController: FormViewController {
    var disappearDelegate: DisappearDelegate?
    var config = Configuration()
    var already_has_resource = false
    var community_resource_name = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "创建小组"
        
        //创建form实例
        let form = FormDescriptor()
        form.title = "创建小组"
        
        //第一个section分区
        let section1 = FormSectionDescriptor(headerTitle: "基本信息", footerTitle: nil)
        //小组名称
        var row = FormRowDescriptor(tag: "name", type: .text, title: "小组名称")
        row.configuration.cell.appearance =
            ["textField.placeholder" : " 午间读书群" as AnyObject,
             "textField.textAlignment" : NSTextAlignment.left.rawValue as AnyObject]
        
        section1.rows.append(row)
        
        // 小组简介
        row = FormRowDescriptor(tag: "des", type: .multilineText, title: "小组简介")
        // multilineText has no placeholder such as "textField.placeholder" : "小组简介" as AnyObject,
        row.configuration.cell.appearance = ["textField.textAlignment" : NSTextAlignment.left.rawValue as AnyObject]
        section1.rows.append(row)
        
        
        let community_resource_name = UserDefaults.standard.object(forKey: "community_resource_name") as? String
        
        // 相关资源
        if (community_resource_name != nil) {
            self.already_has_resource = true
            self.community_resource_name = community_resource_name!
            print("already_has_resource: ")
            print(self.already_has_resource)   // 传不过来true啊卧槽 那就放 UserDefault里吧
            print("user is going to create community with resource of: \(self.community_resource_name)")
            
            // 不展示这个表单
//            row = FormRowDescriptor(tag: "resource_name", type: .label, title: "相关资源")
//            row.configuration.cell.appearance =
//                ["textField.placeholder" : self.default_resource_name as AnyObject,
//                 "textField.textAlignment" : NSTextAlignment.left.rawValue as AnyObject]
            
        } else {
            row = FormRowDescriptor(tag: "resource_name", type: .text, title: "相关资源")
            row.configuration.cell.appearance =
                ["textField.placeholder" : "认知天性" as AnyObject,
                 "textField.textAlignment" : NSTextAlignment.left.rawValue as AnyObject]
            section1.rows.append(row)
        }
        
        //第二个section分区
        let section2 = FormSectionDescriptor(headerTitle: "小组目标期限", footerTitle: nil)
        row = FormRowDescriptor(tag: "time_start", type: .dateAndTime, title: "开始时间")
        section2.rows.append(row)
        row = FormRowDescriptor(tag: "time_end", type: .dateAndTime, title: "结束时间")
        section2.rows.append(row)
        
        //第三个section分区
        let section3 = FormSectionDescriptor(headerTitle: "打卡相关", footerTitle: nil)
        
        // 打卡方式
        row = FormRowDescriptor(tag: "way", type: .multilineText, title: "打卡方式")
        row.configuration.cell.appearance = ["textField.textAlignment" : NSTextAlignment.left.rawValue as AnyObject]
        section3.rows.append(row)
        
        row = FormRowDescriptor(tag: "frequency", type: .stepper, title: "每周次数")
        //允许的最大值
        row.configuration.stepper.maximumValue = 7
        //允许的最小值
        row.configuration.stepper.minimumValue = 1
        //每次增减的值
        row.configuration.stepper.steps = 1
        section3.rows.append(row)
        
        row = FormRowDescriptor(tag: "coins_needed", type: .stepper, title: "所需金币")
        //允许的最大值
        row.configuration.stepper.maximumValue = 10
        //允许的最小值
        row.configuration.stepper.minimumValue = 5
        //每次增减的值
        row.configuration.stepper.steps = 1
        section3.rows.append(row)
        
        
        // 其他
        row = FormRowDescriptor(tag: "ps", type: .multilineText, title: "其他")
        row.configuration.cell.appearance = ["textField.textAlignment" : NSTextAlignment.left.rawValue as AnyObject]
        section3.rows.append(row)
        
        
        
        //提交的section分区
        let section4 = FormSectionDescriptor(headerTitle: nil, footerTitle: nil)
        //提交按钮
        row = FormRowDescriptor(tag: "button", type: .button, title: "创建")
        row.configuration.button.didSelectClosure = { _ in
            self.submit()
        }
        section4.rows.append(row)
        
        //将两个分区添加到form中
        form.sections = [section1, section2, section3, section4]
        self.form = form
        // Do any additional setup after loading the view.
    }
    
    // 创建按钮点击
    func submit() {
        //取消当前编辑状态
        self.view.endEditing(true)
        
        //将表单中输入的内容打印出来
        //        let message = self.form.formValues().description
        let form_content = self.form.formValues()
        print(form_content)
//        print(form_content["name"])
        
        let name = form_content["name"] as? String
        let description = form_content["des"] as? String
        
        var resource_name = ""
        if (self.already_has_resource == true) {
            resource_name = self.community_resource_name
        } else {
            if (form_content["resource_name"] as? String == nil) {
                let alertController = UIAlertController(title: "请输入相关资源名称", message: "", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
               resource_name = (form_content["resource_name"] as? String)!
            }
        }
        
//        print(form_content["time_start"])
        
        // TODO: time有问题
        //        print(type(of: form_content["time_start"]))
        //        print(form_content["time_start"] as? String)
        
        //        let time_start = String(decoding: (form_content["time_start"] as? String)!, as: UTF8.self)
        
        //        let time = timeStr2timeInterval(timeStr: time_start, dateFormat: nil)
        
        //        print("time: \(time)")
        
        //        let time_end = form_content["time_end"] as? String
        
        let time_start = 1592382888
        let time_end = 1600504488
        let way = form_content["way"] as? String
        let frequency = form_content["frequency"] as? Int
        let coins_needed = form_content["coins_needed"] as? Int
        let ps = form_content["ps"] as? String
        
        if let name = name {
            // Url HERE
            let url = config.url + "community/create"
            //Header HERE
            let token = UserDefaults.standard.object(forKey: "token") as? String
//            print("token: \(token)")
            let headers = [
                "token": token!
            ]
            
            //            let date = Date()
            //            // "Nov 2, 2016, 4:48 AM" <-- local time
            //
            //            let formatter = DateFormatter()
            //            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
            //            let time = formatter.string(from: date)
            //            print("time of now: \(time)")
            
            //Parameter HERE
            
            let parameters = [
                "ios_user": "true",
                "name": name,
                "description": description ?? "",
                "resource_name": resource_name,
                
                "time_start": time_start,
                "time_end": time_end,
                
                "way": way ?? "",
                "frequency": frequency ?? 2,
                "coins_needed": coins_needed ?? 5,
                "ps": ps ?? ""
                ]  as [String : Any]
            print(parameters)
            Alamofire.request(url, method: .post, parameters: parameters as Parameters, headers: headers).responseJSON {
                response in
                if response.result.isSuccess {
                    print("create community successfully")
                } else {
                    print("create community failed...")
                }
            }
            
            self.dismiss(animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "请输入小组名称", message: "", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //字符串转时间戳
    func timeStr2timeInterval(timeStr: String?, dateFormat:String?) -> String {
        if timeStr?.count ?? 0 > 0 {
            return ""
        }
        let format = DateFormatter.init()
        format.dateStyle = .medium
        format.timeStyle = .short
        if dateFormat == nil {
            format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        }else{
            format.dateFormat = dateFormat
        }
        let date = format.date(from: timeStr!)
        return String(date!.timeIntervalSince1970)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.disappearDelegate?.disappear()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
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
