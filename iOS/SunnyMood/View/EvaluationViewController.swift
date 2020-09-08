//
//  EvaluationViewController.swift
//  ContestApp
//
//  Created by bytedance on 2020/5/12.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import UIKit

class EvaluationTableViewController: UIViewController {

    var userModel: UserModel?
    var test: String?
    var questionnaireList = [("生活平衡测试", "pic1.jpeg"), ("情绪指数测试", "pic2.jpeg"), ("潜能测试", "pic3.jpeg")]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questionnaireList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        let (name, image) = questionnaireList[indexPath.row]
        cell.textLabel?.text = name
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        self.navigationItem.setHidesBackButton(true, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("evaluation view page")
        if let test = self.test {
            print(test)
        }
        
        let def = UserDefaults.standard
        if let _id = def.object(forKey: "_id") as? String {
            let name = def.object(forKey: "name") as! String
            let bio = def.object(forKey: "bio") as! String
            let gender = def.object(forKey: "gender") as! String
            let professor = def.object(forKey: "professor") as! String
            let avatar = def.object(forKey: "avatar") as! String
            let fans_number = def.object(forKey: "fans_number") as! String
            let follow_number = def.object(forKey: "follow_number") as! String
            self.userModel = UserModel(_id: _id, name: name, bio: bio, avatar: avatar, gender: gender, professor: professor, fans_number: fans_number, follow_number: follow_number)
        }
        self.userModel?.printInfo()
        
        
        
//        self.navigationItem.hidesBackButton = true
//        self.navigationItem.setHidesBackButton(true, animated: true)

//        self.navigationController?.navigationBar.topItem?.backBarButtonItem = nil
        // UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
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
