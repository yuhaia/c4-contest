//
//  RecommendTableViewCell.swift
//  SunnyMood
//
//  Created by bytedance on 2020/5/21.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import UIKit

// 推荐其他用户的动态或者小组
class RecommendTableViewCell: UITableViewCell{
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return (self.pictures?.count)!
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = self.picturesCollectionView.dequeueReusableCell(withReuseIdentifier: "ImageOfMomentCell", for: indexPath) as! ImageOfMomentCVC
//        cell.imageView.frame = cell.contentView.frame
//        cell.imageView.contentMode = .scaleToFill
//        //        cell.imageView.clipsToBounds = true
//        cell.imageView.image = (self.pictures?[indexPath.row])!
//        cell.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
//        //        cell.imageView.image = UIImage(systemName: "heart")
//        if (indexPath.row == 0) {
//            // Set value according to user requirements
//            cell.frame.origin.x = 0
//        }
//        return cell
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let noOfCellsInRow = 3

        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout

        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))

        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))

        return CGSize(width: size, height: size)
    }
    
    func setCollectionViewDataSourceDelegate(dataSourceDelegate: UICollectionViewDataSource & UICollectionViewDelegate & UICollectionViewDelegateFlowLayout, forRow row: Int) {
        self.picturesCollectionView.delegate = dataSourceDelegate
        self.picturesCollectionView.dataSource = dataSourceDelegate
//        self.picturesCollectionView
        self.picturesCollectionView.tag = row
        self.picturesCollectionView.reloadData()
    }
    
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var textsLabel: UILabel!
    @IBOutlet weak var picturesCollectionView: UICollectionView!
    var pictures: [UIImage]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
