//
//  SignUpViewController.swift
//  SunnyMood
//
//  Created by bytedance on 2020/5/11.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SignUpViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var userNameText: UITextField!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userBioText: UITextView!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var passwordConfirmText: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    
    var name: String?
    var bio: String?
    var password: String?
    var passwordConfirm: String?
    var avatarImageFileName = "avatar.jpeg"
    var avatarFilePath: String?
    var config = Configuration()
    var userModel = UserModel()
    var token = ""
    
    @IBAction func done(){
        self.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            userBioText.resignFirstResponder()
            return false
        }
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 设置头像圆角
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        // 设置遮盖额外部分 注释掉之后就可以显示圆形了
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.backgroundColor = #colorLiteral(red: 0.9724641442, green: 0.9726034999, blue: 0.9724336267, alpha: 1)
        //        avatarImageView.layer.borderColor = UIColor.lightGray.cgColor
        avatarImageView.layer.borderColor = #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
        
        
        // 设置bio相关
//        userBioText.layer.borderColor = UIColor.lightGray.cgColor
        userBioText.layer.cornerRadius = 4
//        userBioText.layer.borderWidth = 0.5
        userBioText.text = "请输入个人简介（可选）"
        userBioText.textColor = UIColor.lightGray
        userBioText.delegate = self
        
        signupButton.layer.cornerRadius = 4
    }
    
    
    func textViewDidBeginEditing(_ userBioText: UITextView) {
        if userBioText.textColor == UIColor.lightGray {
            userBioText.text = nil
            userBioText.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if userBioText.text.isEmpty {
            userBioText.text = "请输入个人简介（可选）"
            userBioText.textColor = UIColor.lightGray
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userBioText.delegate = self
        // Do any additional setup after loading the view.
        // 为头像添加点击事件 （UIImageView默认不支持交互的)
        avatarImageView.isUserInteractionEnabled = true
        let avatarActionGR = UITapGestureRecognizer()
        avatarActionGR.addTarget(self, action: Selector.init(("selectAvatar")))
        avatarImageView.addGestureRecognizer(avatarActionGR)
        
        // 为view添加点击事件 用户点击屏幕其他区域便隐藏键盘
        //        let tapGesture = UITapGestureRecognizer()
        //        tapGesture.addTarget(self, action:Selector.init(("userTapBlank")))
        //        self.view.addGestureRecognizer(tapGesture)
        
        //        // 从文件读取用户头像
        //        let fullPath = ((NSHomeDirectory() as NSString) .stringByAppendingPathComponent("Documents") as NSString).stringByAppendingPathComponent(iconImageFileName)
        //        //可选绑定,若保存过用户头像则显示之
        //        if let savedImage = UIImage(contentsOfFile: fullPath){
        //            self.icon.image = savedImage
        //        }
    }
    
    @objc
    func userTapBlank(recoginzer: UITapGestureRecognizer) {
        self.userBioText.resignFirstResponder()
    }
    
    @objc
    func selectAvatar() {
        let avatarAlert = UIAlertController(title: "请选择操作", message: "", preferredStyle: .actionSheet)
        let chooseFromPhotoAlbum = UIAlertAction(title: "从相册选择", style: .default, handler: funcChooseFromPhotoAlbum)
        avatarAlert.addAction(chooseFromPhotoAlbum)
        
        let chooseFromCamera = UIAlertAction(title: "拍照", style: .default, handler: funcChooseFromCamera)
        avatarAlert.addAction(chooseFromCamera)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        avatarAlert.addAction(cancelAction)
        
        self.present(avatarAlert, animated: true, completion: nil)
    }
    
    func funcChooseFromPhotoAlbum(avc: UIAlertAction) -> Void {
        let imagePicker = UIImagePickerController()
        // 设置代理
        imagePicker.delegate = self
        // 允许编辑
        imagePicker.allowsEditing = true
        // 设置图片源
        imagePicker.sourceType =  UIImagePickerController.SourceType.photoLibrary
        // 模态弹出
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func funcChooseFromCamera(avc: UIAlertAction) -> Void {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = UIImagePickerController.SourceType.camera
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // UIImagePicker回调方法
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var image: UIImage?
        if picker.allowsEditing {
            image = (info as NSDictionary).object(forKey: UIImagePickerController.InfoKey.editedImage) as! UIImage
        } else {
            image = (info as NSDictionary).object(forKey: UIImagePickerController.InfoKey.originalImage) as! UIImage
        }
        //        avatarImageView.image = image!
        
        // 保存图片至沙盒
        self.saveAvatar(currentImage: image!, imageName: avatarImageFileName)
        let fullPath = ((NSHomeDirectory() as NSString).appendingPathComponent("Documents") as NSString).appendingPathComponent(avatarImageFileName)
        //存储后拿出更新头像
        let savedImage = UIImage(contentsOfFile: fullPath)
        self.avatarImageView.image = savedImage!
        print("存储后拿出更新头像操作ok")
        picker.dismiss(animated: true, completion: nil)
        
        print("图片地址：\(fullPath)")
        self.avatarFilePath = fullPath
        //        let avatarData = NSData(contentsOfFile: fullPath)
    }
    
    func saveAvatar(currentImage: UIImage, imageName: String) {
        print("调用saveAvatar方法")
        print("currentImage: \(currentImage)")
        var imageData = NSData()
        imageData = currentImage.jpegData(compressionQuality: 0.5)! as NSData
        // 获取沙盒目录
        let fullPath = ((NSHomeDirectory() as NSString).appendingPathComponent("Documents") as NSString).appendingPathComponent(imageName)
        // 将图片写入文件
        imageData.write(toFile: fullPath, atomically: false)
        print("图片地址：\(fullPath)")
    }
    
    @IBAction func signupAction(_ sender: UIButton) {
        self.name = userNameText.text
        self.bio = userBioText.text
        self.password = passwordText.text
        self.passwordConfirm = passwordConfirmText.text
        
        if self.password != nil, self.password != self.passwordConfirm {
            self.showAlert(title: "两次密码不匹配", message: "请重新输入", preferredStyle: .alert)
        } else if self.name == "" {
            self.showAlert(title: "用户昵称不可为空", message: "请重新输入", preferredStyle: .alert)
        } else if self.avatarFilePath == nil {
            self.showAlert(title: "用户头像为空", message: "请选择头像", preferredStyle: .alert)
        } else {
            print("user info:")
            print("name: \(String(describing: name)) bio: \(String(describing: bio))")
            // Url HERE
            let url = config.url + "users/signup"
            //Header HERE
            let headers = [
                "Content-type": "multipart/form-data",
                "Content-Disposition" : "form-data",
            ]
            let avatarImage = (UIImage(contentsOfFile: self.avatarFilePath!)?.jpegData(compressionQuality: 0.7)!)!
            //            let image = UIImage.init(named: "furkan")
            //            let imgData = image!.jpegData(compressionQuality: 0.7)!
            //Parameter HERE
            let image = UIImage(contentsOfFile: self.avatarFilePath!)
            let imageData = image!.pngData()!
            let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
            //            print("base64: \(strBase64)")
            
            
            let parameters = [
                "name": self.name!,
                "bio" : self.bio!,
                "password": self.password!,
                "repassword": self.passwordConfirm!,
//                "avatar": strBase64,
            ]
//            Alamofire.request(url, method: .post, parameters: parameters as Parameters, headers: headers).responseJSON {
//                response in
//                if response.result.isSuccess {
//                    let resultData = try? JSONSerialization.data(withJSONObject: response.result.value!, options: .prettyPrinted)
//                    if let resultJson = try? JSON.init(data: resultData!) {
//                        if let error = resultJson["error"].string {
//                            print("error: \(error)")
//                            
//                            let alertController = UIAlertController(title: "注册失败", message: "请重试", preferredStyle: .alert)
//                            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//                            alertController.addAction(defaultAction)
//                            self.present(alertController, animated: true, completion: nil)
//                        } else {
//                            print("send to backend to update likes successfully")
//                            let user_info = resultJson["data"]["user_info"]
//                            self.userModel._id = user_info["_id"].string!
//                            self.userModel.name = user_info["name"].string!
//                            self.userModel.bio = user_info["bio"].string!
//                            self.userModel.avatar = user_info["avatar"].string!
//                            self.userModel.gender = user_info["gender"].string!
//                            self.userModel.professor = user_info["professor"].string!
//                            self.userModel.fans_number = user_info["fans_number"].string!
//                            self.userModel.follow_number = user_info["follow_number"].string!
//                            self.userModel.coins = user_info["coins"].int!
//                            
//                            self.token = resultJson["data"]["token"].string!
//                            
//                            self.saveLoggedUserState()
//                            let sceneDelegate = self.view.window?.windowScene?.delegate as! SceneDelegate
//                            sceneDelegate.switchRVC2TBC()
//                            self.performSegue(withIdentifier: "SignUpToHomeSegue", sender: self)
//                        }
//                    }
//                } else {
//                    print("sign up failed...")
//                }
//            }
                        Alamofire.upload(multipartFormData: { multipartFormData in
                            //Parameter for Upload files
                            multipartFormData.append(avatarImage, withName: "avatar",fileName: self.avatarImageFileName , mimeType: "image/png")
            
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
                                        print("the resopnse code is : \(String(describing: response.response?.statusCode))")
                                        print("the response is : \(response)")
                                        print("response.result.value: \(String(describing: response.result.value))")
            
                                        let resultData = try? JSONSerialization.data(withJSONObject: response.result.value!, options: .prettyPrinted)
                                        if let resultJson = try? JSON.init(data: resultData!) {
                                            //                                print("resultJson: \(resultJson)")
            
                                            if let error = resultJson["error"].string {
                                                print("error: \(error)")
                                                self.showAlert(title: "用户昵称已被占用", message: "请重新输入昵称 ", preferredStyle: .alert)
                                            } else {
                                                let user_info = resultJson["data"]["user_info"]
                                                self.userModel._id = user_info["_id"].string!
                                                self.userModel.name = user_info["name"].string!
                                                self.userModel.bio = user_info["bio"].string!
                                                self.userModel.avatar = user_info["avatar"].string!
                                                self.userModel.gender = user_info["gender"].string!
                                                self.userModel.professor = user_info["professor"].string!
                                                self.userModel.fans_number = user_info["fans_number"].string!
                                                self.userModel.follow_number = user_info["follow_number"].string!
                                                self.userModel.coins = user_info["coins"].int!
            
                                                self.token = resultJson["data"]["token"].string!
            
                                                self.saveLoggedUserState()
                                                let sceneDelegate = self.view.window?.windowScene?.delegate as! SceneDelegate
                                                sceneDelegate.switchRVC2TBC()
                                                self.performSegue(withIdentifier: "SignUpToHomeSegue", sender: self)
                                            }
                                        }
                                    }
                                    break
                                case .failure(let encodingError):
                                    print("the error is  : \(encodingError.localizedDescription)")
                                    break
                                }
                        })
        }
        
    }
    
    func saveLoggedUserState() {
        let def = UserDefaults.standard
        def.set(true, forKey: "is_authenticated")
        def.set(self.token, forKey: "token")
        def.set(self.userModel._id, forKey: "_id")
        def.set(self.userModel.name, forKey: "name")
        def.set(self.userModel.bio, forKey: "bio")
        def.set(self.userModel.gender, forKey: "gender")
        def.set(self.userModel.professor, forKey: "professor")
        def.set(self.userModel.avatar, forKey: "avatar")
        def.set(self.userModel.fans_number, forKey: "fans_number")
        def.set(self.userModel.follow_number, forKey: "follow_number")
        def.set(self.userModel.coins, forKey: "coins")
        
        // 单独存一下密码，因为后面验证token失败后需要用name和password来换取token
        def.set(self.password!, forKey: "password")
        
        //        def.setValue(self.userModel, forKey: "userInfo")  // 不能存储复杂的数据
        def.synchronize()
    }
    
    func showAlert(title: String, message: String, preferredStyle: UIAlertController.Style) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "SignUpToHomeSegue" {
            print("prepare to home page...")
        }
    }
    
    
}
