//
//  MomentTVC.swift
//  SunnyMood
//
//  Created by bytedance on 2020/6/18.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import UIKit
import SDWebImage

class MomentTVC: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageOfMomentCell", for: indexPath) as! MomentImageCVC
//        cell.imageView.image = UIImage(named: self.images[indexPath.item])
        let image_url = URL(string: self.images[indexPath.item])
        cell.imageView.sd_setImage(with: image_url, placeholderImage: UIImage(named: "pic2"), completed: nil)
        
        cell.imageView.tag = indexPath.item
        cell.imageView.contentMode = .scaleAspectFill
        cell.imageView.clipsToBounds = true
        //设置允许交互（后面要添加点击）
        cell.imageView.isUserInteractionEnabled = true
        //添加单击监听
        let tapSingle=UITapGestureRecognizer(target:self,
                                             action:#selector(imageViewTap(_:)))
        tapSingle.numberOfTapsRequired = 1
        tapSingle.numberOfTouchesRequired = 1
        cell.imageView.addGestureRecognizer(tapSingle)
        
        return cell
    }
    
    //缩略图imageView点击
    @objc func imageViewTap(_ recognizer:UITapGestureRecognizer){
        //图片索引
        let index = recognizer.view!.tag
        //进入图片全屏展示
        let previewVC = ImagePreviewVC(images: images, index: index)
        self.navigationController?.pushViewController(previewVC, animated: true)
    }
    
    
    @IBOutlet weak var slipperView: UIView!
    
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var momentTextsLabel: UILabel!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    // imageCollectionView的高度约束
    @IBOutlet weak var imageCollectionViewHeight: NSLayoutConstraint!
    var navigationController: UINavigationController?
    
    var images: [String] = []
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.imageCollectionView.delegate = self
        self.imageCollectionView.dataSource = self
        
        self.imageCollectionView.register(UINib(nibName: "MomentImageCVC", bundle: nil), forCellWithReuseIdentifier: "imageOfMomentCell")
    }

    // 加载数据
    func reloadData(moment: MomentModel, navigationController: UINavigationController?) {
        if let user_info = moment.user_info {
            let userName = user_info["name"].string!
            let userAvatarPath = user_info["avatar"].string!
            let momentTexts = moment.texts!
            let images = moment.pictures!
            
            self.navigationController = navigationController
            self.userNameLabel.text = userName
            self.momentTextsLabel.text = momentTexts
            
            self.userAvatarImageView.layer.cornerRadius = 5.0
            self.userAvatarImageView.sd_setImage(with: URL(string: userAvatarPath), placeholderImage: UIImage(named: "pic1"), completed: nil)
            self.images = images
            
            self.imageCollectionView.reloadData()
            
            let contentSize = self.imageCollectionView.collectionViewLayout.collectionViewContentSize
            self.imageCollectionViewHeight.constant = contentSize.height
            self.imageCollectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    //绘制单元格底部横线
    override func draw(_ rect: CGRect) {
        //线宽
        let lineWidth = 1 / UIScreen.main.scale
        //线偏移量
        let lineAdjustOffset = 1 / UIScreen.main.scale / 2
        //线条颜色
        let lineColor = UIColor(red: 0xe0/255, green: 0xe0/255, blue: 0xe0/255, alpha: 1)
         
        //获取绘图上下文
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
         
        //创建一个矩形，它的所有边都内缩固定的偏移量
        let drawingRect = self.bounds.insetBy(dx: lineAdjustOffset, dy: lineAdjustOffset)
         
        //创建并设置路径
        let path = CGMutablePath()
        path.move(to: CGPoint(x: drawingRect.minX, y: drawingRect.maxY))
        path.addLine(to: CGPoint(x: drawingRect.maxX, y: drawingRect.maxY))
         
        //添加路径到图形上下文
        context.addPath(path)
         
        //设置笔触颜色
        context.setStrokeColor(lineColor.cgColor)
        //设置笔触宽度
        context.setLineWidth(lineWidth)
         
        //绘制路径
        context.strokePath()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
