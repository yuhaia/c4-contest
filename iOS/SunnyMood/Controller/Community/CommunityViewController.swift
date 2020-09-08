//
//  CommunityViewController.swift
//  SunnyMood
//
//  Created by bytedance on 2020/5/12.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import UIKit
import PolioPager
import Alamofire
import SwiftyJSON

class CommunityViewController: PolioPagerViewController {

    var userModel:UserModel?
    
    override func tabItems() -> [TabItem] {
        return [TabItem(isSearchTab: true, title: "", image: UIImage(named: "search.png")), TabItem(title: "关注"), TabItem(title: "小组"), TabItem(title: "推荐")]
    }
    override func viewControllers() -> [UIViewController] {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let searchCommunityVC = storyboard.instantiateViewController(withIdentifier: "searchCommunityVC")
        let followedMomentsVC = storyboard.instantiateViewController(withIdentifier: "followedMomentsVC")
        let communityPageCV = storyboard.instantiateViewController(withIdentifier: "communityPageCV")
//        let recommendTVC = storyboard.instantiateViewController(withIdentifier: "recommendTVC")
        
        let recommendTVC = storyboard.instantiateViewController(withIdentifier: "recommendViewController")
        return [searchCommunityVC, followedMomentsVC, communityPageCV, recommendTVC]
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        print("community view page")
        self.takeOutUser()
        // Do any additional setup after loading the view.
    }
    
    func takeOutUser() {
        let userInfo = TakeUserInfo()
        self.userModel = userInfo.user!
    }
    
    @IBAction func addMomentOrCommunityAction(_ sender: UIBarButtonItem) {
        // code manually pop over
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "chooseCreateItemNAV") as! UINavigationController
        vc.preferredContentSize = CGSize(width: 150,height: 60)
        vc.modalPresentationStyle = .popover
        vc.view.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
        if let pres = vc.presentationController {
            pres.delegate = self
        }
        let popover: UIPopoverPresentationController = vc.popoverPresentationController!
        popover.barButtonItem = sender
        present(vc, animated: true, completion:nil)
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}

extension CommunityViewController : UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
