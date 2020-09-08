//
//  MedalViewController.swift
//  SunnyMood
//
//  Created by bytedance on 2020/8/10.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import UIKit

class MedalViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 14
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.medalCollectionView.dequeueReusableCell(withReuseIdentifier: "medalCell", for: indexPath) as! MedalCollectionViewCell
        var index = indexPath.row
        var unlock = false
        if index >= 2 {
            index = 2
            unlock = true
        }
        cell.reloadData(unlock: unlock, title: medalTitles[index], imageName: medalImages[index], navigationController: self.navigationController!)
        
//        cell.medalImageView.tag = indexPath.row
//        //设置允许交互（后面要添加点击）
//        cell.medalImageView.isUserInteractionEnabled = true
//        //添加单击监听
//        let tapSingle = UITapGestureRecognizer(target:self,
//                                             action:#selector(imageViewTap(_:)))
//        tapSingle.numberOfTapsRequired = 1
//        tapSingle.numberOfTouchesRequired = 1
//        cell.medalImageView.addGestureRecognizer(tapSingle)
        return cell
    }
    
    
    @IBOutlet weak var medalCollectionView: UICollectionView!
    var medalTitles = ["阅读王", "圈子王", "未解锁"]
    
    var medalImages = ["readingKing", "circleKing", "unlock"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.medalCollectionView.delegate = self
        self.medalCollectionView.dataSource = self
        
        self.medalCollectionView.register(UINib(nibName: "MedalCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "medalCell")
        
        self.medalCollectionView.reloadData()
        
        //修改导航栏返回按钮文字
        let item = UIBarButtonItem(title: "返回", style: .plain, target: self, action: nil)
        self.navigationItem.backBarButtonItem = item;
        // Do any additional setup after loading the view.
    }
    
    //缩略图imageView点击
    @objc func imageViewTap(_ recognizer:UITapGestureRecognizer){
        //图片索引
        let index = recognizer.view!.tag
        //进入图片全屏展示
        let previewVC = ImagePreviewVC(images: medalImages, index: index)
        self.navigationController?.pushViewController(previewVC, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    private let itemsPerRow: CGFloat = 3
    
    private let sectionInsets = UIEdgeInsets(top: 30.0,
                                             left: 30.0,
                                             bottom: 30.0,
                                             right: 30.0)
}

// MARK: - Collection View Flow Layout Delegate
extension MedalViewController : UICollectionViewDelegateFlowLayout {
    //1
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        print("hhhhhhhhh")
        //2
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        print("widthPerItem: \(widthPerItem)")
        print("view.frame.width: \(view.frame.width)")
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    // 4
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20.0
    }
}


