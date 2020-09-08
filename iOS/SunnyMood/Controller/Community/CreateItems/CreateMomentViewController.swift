//
//  AddMomentViewController.swift
//  SunnyMood
//
//  Created by bytedance on 2020/5/21.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import UIKit
import BSImagePicker
import Photos
import Alamofire
import SwiftyJSON

class CreateMomentViewController: UIViewController, UITextViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            momentTextView.resignFirstResponder()
            return false
        }
        return true
    }
    
    var disappearDelegate: DisappearDelegate?

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        print("self.communities_name")
        print(self.communities_name)
        return self.communities_name.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.communities_name[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("user tapped \(self.communities_name[row])")
        self.selected_community_index = row
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = self.imagesCollectionView.dequeueReusableCell(withReuseIdentifier: "ImageOfMomentCell", for: indexPath) as! ImageOfMomentCVC
        cell.imageView.frame = cell.contentView.frame
        cell.imageView.contentMode = .scaleAspectFill
        cell.imageView.image = self.images[indexPath.row]
        cell.imageView.layer.cornerRadius = 10.0
        cell.imageView.clipsToBounds = true
        
        
        
        cell.backgroundColor = #colorLiteral(red: 0.9724641442, green: 0.9726034999, blue: 0.9724336267, alpha: 1)
        cell.layer.cornerRadius = 10.0
        cell.clipsToBounds = true
        //        cell.imageView.image = UIImage(systemName: "heart")
        if (indexPath.row == 0) {
            // Set value according to user requirements
            cell.frame.origin.x = 0
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let noOfCellsInRow = 3
        
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
        
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
        
        return CGSize(width: size, height: size)
    }
    
    
    @IBOutlet weak var postMomentButton: UIButton!
    @IBOutlet weak var momentTextView: UITextView!
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    @IBOutlet weak var communityPickerView: UIPickerView!
    
    var images = [UIImage]()
    let maxNumberOfImages = 9
    var hasAddIcon = true
    let placeholderOfText = "说点什么吧~"
    let userInfo = TakeUserInfo()
    let config = Configuration()
    var communities_basic_info = [community_basic_info]()     // 只包含_id name供用户在发布打卡动态时选择对应的小组
    var communities_name = [String]()
    var selected_community_index = 0
    var token = ""
    
    func textViewDidBeginEditing(_ momentTextView: UITextView) {
        if momentTextView.textColor == UIColor.lightGray {
            momentTextView.text = nil
            momentTextView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if momentTextView.text.isEmpty {
            momentTextView.text = self.placeholderOfText
            momentTextView.textColor = UIColor.lightGray
        }
    }
    @IBAction func postMomentAction(_ sender: UIButton) {
        if (self.momentTextView.text.isEmpty || self.momentTextView.text == self.placeholderOfText) && self.images.count == 1 {
            let alertController = UIAlertController(title: "请至少输入文本或上传一张图片", message: "", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            
            if self.hasAddIcon == false {
                print("images count: \(self.maxNumberOfImages)")
            } else {
                self.images.remove(at: self.images.count - 1)
                print("images count: \(self.images.count - 1)")
            }
            
            print("user texts of moment:\(String(describing: self.momentTextView.text))")
            
            
            // Url HERE
            let url = config.url + "community/addMoment"
            //Header HERE
            let token = UserDefaults.standard.object(forKey: "token") as? String
            //            print("token: \(token)")
            let headers = [
                "Content-type": "multipart/form-data",
                "Content-Disposition" : "form-data",
                "token": token!
            ]
            let imageDataArray = self.images.map {$0.jpegData(compressionQuality: 0.7)!}
            
            let date = Date()
            // "Nov 2, 2016, 4:48 AM" <-- local time
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
            let time = formatter.string(from: date)
            print("time of now: \(time)")
            
            //Parameter HERE
            let community_id = self.communities_basic_info[self.selected_community_index].id
            let parameters = [
                "ios_user": "true",     // 因为上传图片的机制暂时不改动 所以与小程序不一致 因此后台会区分开来
                "texts": (self.momentTextView.text)!,
                "community_id": community_id,
                "pictures_number": String(self.images.count)
            ]
            
            Alamofire.upload(multipartFormData: { multipartFormData in
                //Parameter for Upload files
                for i in 0 ..< imageDataArray.count {
                    multipartFormData.append(imageDataArray[i], withName: "picture" + String(i), fileName: "picture" + String(i) + ".jpeg",  mimeType: "image/png")
                }
                
                
                for (key, value) in parameters
                {
                    multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                }
                
            }, usingThreshold:UInt64.init(),
               to: url, //URL Here
                method: .post,
                headers: headers, //pass header dictionary here
                encodingCompletion: { (result) in
                    
                    switch result {
                    case .success(let upload, _, _):
                        print("the status code is :")
                        
                        upload.uploadProgress(closure: { (progress) in
                            print("uploading...")
                        })
                        
                        upload.responseJSON { response in
                            if let response_code = response.response?.statusCode {
                                print("the resopnse code is : \(response_code)")
                                print("the response is : \(response)")
                                print("response.result.value: \(String(describing: response.result.value))")
                                
                                let resultData = try? JSONSerialization.data(withJSONObject: response.result.value!, options: .prettyPrinted)
                                if let resultJson = try? JSON.init(data: resultData!) {
                                    //                                print("resultJson: \(resultJson)")
                                    
                                    if let error = resultJson["error"].string {
                                        print("error: \(error)")
                                        self.showAlert(title: "动态上传失败", message: "请重新上传", preferredStyle: .alert)
                                    } else {
                                        print("上传成功～")
                                    }
                                }
                            } else {
                                self.showAlert(title: "连接服务器失败", message: "请确认网络正常", preferredStyle: .alert)
                            }
                        }
                        break
                    case .failure(let encodingError):
                        print("the error is  : \(encodingError.localizedDescription)")
                        break
                    }
            })
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func showAlert(title: String, message: String, preferredStyle: UIAlertController.Style) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.momentTextView.delegate = self
        self.momentTextView.text = self.placeholderOfText
        self.momentTextView.textColor = UIColor.lightGray
//        self.momentTextView.layer.borderColor = UIColor.gray.cgColor
//        self.momentTextView.layer.borderWidth = 0.5
        self.momentTextView.layer.cornerRadius = 5
        
        self.momentTextView.selectedTextRange = self.momentTextView.textRange(from: self.momentTextView.beginningOfDocument, to: self.momentTextView.beginningOfDocument)
        
        self.imagesCollectionView.delegate = self
        self.imagesCollectionView.dataSource = self
        let addImage = UIImage(systemName: "plus")
        self.images.append(addImage!)
        self.imagesCollectionView.reloadData()
        print(self.images.count)
        
        self.communityPickerView.delegate = self
        self.communityPickerView.dataSource = self
    }
    
    
    fileprivate func imageRequestOptions() -> PHImageRequestOptions {
        let requestOption = PHImageRequestOptions()
        requestOption.deliveryMode = .highQualityFormat
        return requestOption
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.row
        if index == self.images.count - 1 {
            let imagePicker = ImagePickerController()
            imagePicker.settings.selection.max = self.maxNumberOfImages
            imagePicker.settings.theme.selectionStyle = .numbered
            imagePicker.settings.fetch.assets.supportedMediaTypes = [.image, .video]
            imagePicker.settings.selection.unselectOnReachingMax = true
            
            let start = Date()
            
            var selected_assets = [PHAsset]()
            self.presentImagePicker(imagePicker, select: { (asset) in
                print("Selected: \(asset)")
            }, deselect: { (asset) in
                print("Deselected: \(asset)")
            }, cancel: { (assets) in
                print("Canceled with selections: \(assets)")
            }, finish: { (assets) in
                print("Finished with selections: \(assets)")
                selected_assets = assets
                print("selected_assets.count: \(selected_assets.count)")
                
                for asset in selected_assets {
                    PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: self.imageRequestOptions()) { (image, info) in
                        
                        self.images.insert(image!, at: self.images.count - 1)
                        if self.images.count == self.maxNumberOfImages + 1 {
                            self.images.remove(at: self.images.count - 1)
                            self.hasAddIcon = false
                        }
                        self.imagesCollectionView.reloadData()
                        
                    }
                }
                
            }, completion: {
                let finish = Date()
                print(finish.timeIntervalSince(start))
                
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.disappearDelegate?.disappear()
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
