//
//  ProfileInfoViewController.swift

//
//  Created by Casp iOS on 02/02/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit
import RSKImageCropper
import JSSAlertView

class ProfileInfoViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,SocketIOManagerDelegate,RSKImageCropViewControllerDelegate,UITextFieldDelegate,tick{
    
    @IBOutlet weak var enterchat_view: UIView!
    @IBOutlet weak var imageBtn: UIButton!
    @IBOutlet weak var Check_Btn: UIButton!
    @IBOutlet weak var go_btn: UIButton!
    @IBOutlet weak var Entername_field: UITextField!
    @IBOutlet weak var Enteremail_field: UITextField!
    @IBOutlet weak var HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var termsCondition: UIButton!
    
    @IBOutlet weak var user_image: UIImageView!
    var picker = UIImagePickerController()
    
    var username:String=String()
    var email:String=String()
    var msisdn:String=String()
    var user_id:String=String()
    
    var fullImage:NSArray = NSArray()
    var imageName:String = String()
    var istermsChecked:Bool = Bool()
    override func viewDidLoad() {
        super.viewDidLoad()
        Entername_field.text=username
        Enteremail_field.text="Guest"
        Enteremail_field.isUserInteractionEnabled = false
        if UIDevice.isIphoneX {
            HeightConstraint.constant = 250
        } else {
            HeightConstraint.constant = 350
        }
        print("userId",Themes.sharedInstance.Getuser_id())
        let Dict:Dictionary = ["single_sound":"1015","group_sound":"1015"]
        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Notification_Setting, FetchString: Themes.sharedInstance.Getuser_id(), attribute: "user_id", UpdationElements: Dict as NSDictionary?)
        // Do any additional setup after loading the view.
    }
    func tnc(agree: Bool) {
        if(agree == true){
            istermsChecked = true
            Check_Btn.setImage(#imageLiteral(resourceName: "check"), for: .normal)
        }else{
            istermsChecked = false
            Check_Btn.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
        }
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppDelegate.sharedInstance.Delegate = self
        user_image.layer.cornerRadius=user_image.frame.size.width/2
        user_image.clipsToBounds=true
        user_image.layer.borderWidth = 1.0
        user_image.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.8).cgColor
        
        imageBtn.layer.cornerRadius=imageBtn.frame.size.width/2
        imageBtn.clipsToBounds=true
        imageBtn.layer.borderWidth = 2.0
        imageBtn.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
        
        Entername_field.layer.cornerRadius=Entername_field.frame.size.height/2
        Entername_field.layer.borderWidth = 0.5
        Entername_field.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.8).cgColor
        Entername_field.layer.masksToBounds = false
        
        Enteremail_field.layer.cornerRadius=Enteremail_field.frame.size.height/2
        Enteremail_field.layer.borderWidth = 0.5
        Enteremail_field.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.8).cgColor
        Enteremail_field.layer.masksToBounds = false
        
//        Entername_field.layer.shadowRadius = 8.0
//        Entername_field.layer.shadowColor = UIColor.lightGray.cgColor
//        Entername_field.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
//        Entername_field.layer.shadowOpacity = 1.0
        
        go_btn.layer.cornerRadius = go_btn.frame.size.height/2
        go_btn.clipsToBounds = true
        go_btn.layer.borderWidth = 1.0
        go_btn.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.8).cgColor

        reloadData()
    }
    
    func reloadData()
    {
        user_image.setProfilePic(Themes.sharedInstance.Getuser_id(), "login")
    }
    
    
    func loginUpdated(_Updated: String) {
        print(_Updated)
    }
    
    func UpdateUserInfo(name:String,imagedata:String,base64data:String, email: String)
    {
        guard let user = Themes.sharedInstance.GetuserDetails() else {
            return
        }
        SocketIOManager.sharedInstance.changeName(name: Themes.sharedInstance.CheckNullvalue(Passed_value: name), from: Themes.sharedInstance.Getuser_id(), email: Themes.sharedInstance.CheckNullvalue(Passed_value: email))
        
        let updateDict=["name":Themes.sharedInstance.CheckNullvalue(Passed_value: name), "email":Themes.sharedInstance.CheckNullvalue(Passed_value: email)]
        
        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail, FetchString: Themes.sharedInstance.Getuser_id(), attribute: "user_id", UpdationElements: updateDict as NSDictionary?)
        SocketIOManager.sharedInstance.isFromLogin = false
        SocketIOManager.sharedInstance.EmitforGetOfflineDetails(Nickname: Themes.sharedInstance.Getuser_id() as NSString)
        (UIApplication.shared.delegate as! AppDelegate).MovetoRooVC()
    }
    
    func moveHomeVC()
    {
        let dict:NSDictionary=["name":username]
        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail, FetchString: user_id, attribute: "user_id", UpdationElements: dict as NSDictionary?)
        
        (UIApplication.shared.delegate as! AppDelegate).MovetoRooVC()
        
    }
    @IBAction func DidclickTermsandcondition(_ sender: Any) {
        self.view.endEditing(true)
        let termsAndCondition = storyboard?.instantiateViewController(withIdentifier:"TermAndConditionViewController" ) as! TermAndConditionViewController
        termsAndCondition.delegate = self
        self.pushView(termsAndCondition, animated: true)
        
        
    }
    @IBAction func DIdclickCheck_Btn(_ sender: Any) {
        self.view.endEditing(true)
        if(istermsChecked)
        {
            istermsChecked = false
            Check_Btn.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
            
        }
        else
        {
            istermsChecked = true
            Check_Btn.setImage(#imageLiteral(resourceName: "check"), for: .normal)
            
        }
    }
    
    @IBAction func goAction(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if !istermsChecked {
            Themes.sharedInstance.ShowNotification("Please agree the terms and conditions", false)
        } else if(Enteremail_field.text?.count == 0) {
            Themes.sharedInstance.jssAlertView(viewController: self, title: Themes.sharedInstance.GetAppname(), text: "Enter Email", buttonTxt: "Ok", color: CustomColor.sharedInstance.themeColor)
        } else if(Entername_field.text?.removingWhitespaces() != "") {
            let userid = Themes.sharedInstance.Getuser_id()
            let login_key = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Login_details, attrib_name: "user_id", fetchString: userid, returnStr: "login_key")
            ///
            ChatBackUpHandler.sharedInstance.retriveDocumentFromiCloud(View: self.view, completionHandler: { (success) in

                                DatabaseHandler.sharedInstance.truncateDataForTable(Entityname: Constant.sharedinstance.Login_details)
                                let Dict:Dictionary = ["user_id": userid, "login_key": login_key, "is_updated" : "0"]
                                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict as NSDictionary, Entityname: Constant.sharedinstance.Login_details)

                                self.openEnterChat()
                            })
            
            let checkBackup : Bool = false

            if(checkBackup)
            {
                let alertview = JSSAlertView().show(self,title: Themes.sharedInstance.GetAppname(),text: "Backup Found" ,buttonText: "Restore",cancelButtonText: "Cancel" ,color: CustomColor.sharedInstance.alertColor)
                alertview.addAction {
                    ChatBackUpHandler.sharedInstance.retriveDocumentFromiCloud(View: self.view, completionHandler: { (success) in
                        
                        DatabaseHandler.sharedInstance.truncateDataForTable(Entityname: Constant.sharedinstance.Login_details)
                        let Dict:Dictionary = ["user_id": userid, "login_key": login_key, "is_updated" : "0"]
                        DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict as NSDictionary, Entityname: Constant.sharedinstance.Login_details)
                        
                        self.openEnterChat()
                    })
                }
                alertview.addCancelAction {
                    let param:[String:Any] = ["from":Themes.sharedInstance.Getuser_id()]
                    SocketIOManager.sharedInstance.EmitSkipMessages(Param: param)
                    self.openEnterChat()
                }
            }
            else
            {
//                let param:[String:Any] = ["from":Themes.sharedInstance.Getuser_id()]
//                SocketIOManager.sharedInstance.EmitSkipMessages(Param: param)
//                openEnterChat()
            }
        } else {
            Themes.sharedInstance.jssAlertView(viewController: self, title: Themes.sharedInstance.GetAppname(), text: "Enter Full Name", buttonTxt: "Ok", color: CustomColor.sharedInstance.themeColor)
        }
    }
    
    
    func openEnterChat()
    {
        self.UpdateUserInfo(name: self.Entername_field.text!, imagedata: "", base64data: "", email: self.Enteremail_field.text!)
        
//        let identityAnimation = CGAffineTransform.identity
//        let scaleOfIdentity = identityAnimation.scaledBy(x: 0.001, y: 0.001)
//        enterchat_view.transform = scaleOfIdentity
//        enterchat_view.isHidden = false
//        UIView.animate(withDuration: 0.3/1.5, animations: {
//            let scaleOfIdentity = identityAnimation.scaledBy(x: 1.1, y: 1.1)
//            self.enterchat_view.transform = scaleOfIdentity
//        }, completion: {finished in
//            UIView.animate(withDuration: 0.3/2, animations: {
//                let scaleOfIdentity = identityAnimation.scaledBy(x: 0.9, y: 0.9)
//                self.enterchat_view.transform = scaleOfIdentity
//            }, completion: {finished in
//                UIView.animate(withDuration: 0.3/2, animations: {
//                    self.enterchat_view.transform = identityAnimation
//                })
//            })
//        })
    }
  
    
    @IBAction func DidclickenterChat(_ sender: Any) {
        self.UpdateUserInfo(name: self.Entername_field.text!, imagedata: "", base64data: "", email: self.Enteremail_field.text!)
    }
    
    @IBAction func DidclickimageBtn(_ sender: Any) {
        let alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertAction.Style.default)
        {
            UIAlertAction in
            self.openCamera()
        }
        let gallaryAction = UIAlertAction(title: "Gallery", style: UIAlertAction.Style.default)
        {
            UIAlertAction in
            self.openGallary()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
        {
            UIAlertAction in
        }
        // Add the actions
        picker.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        // Present the controller
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            self.presentView(alert, animated: true, completion: nil)
        }
        else
        {
            
        }
        
    }
    
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
        {
            picker.sourceType = UIImagePickerController.SourceType.camera
            picker.delegate=self
            self.presentView(picker, animated: true)
        }
        else
        {
            openGallary()
        }
    }
    
    func openGallary()
    {
        picker.sourceType = UIImagePickerController.SourceType.photoLibrary
        picker.delegate=self
        
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            self.presentView(picker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image : UIImage = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage)!
        let compressedimg = image.jpegData(compressionQuality: 0.3)
//            UIImageJPEGRepresentation(image, 0.3)
        let imageCropVC = RSKImageCropViewController(image: UIImage(data: compressedimg!)!)
        imageCropVC.delegate = self
        self.pushView(imageCropVC, animated: true)
        picker.dismissView(animated: true, completion: nil)
    }
    
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        self.pop(animated: true)
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
        user_image.image = croppedImage
        self.pop(animated: true)
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat)
    {
        self.pop(animated: true)
        user_image.image = croppedImage
        Themes.sharedInstance.activityView(View: self.view)
        self.go_btn.isUserInteractionEnabled=false

        self.go_btn.setTitleColor(UIColor.lightGray, for: .normal)
        self.perform(#selector(NewGroupSetNameViewController.DismissLoader(IsfromUploader:)), with: nil, afterDelay: TimeInterval(Constant.sharedinstance.UploadImageDelayTime))
        splitImage(image: croppedImage)
        user_image.image=croppedImage
    }
    
    func splitImage(image:UIImage)
    {
        let imageForSplit = image
        let imageData = imageForSplit.jpegData(compressionQuality: 0.3)
        getArrayOfBytesFromImage(imageData!)
    }
    
    func getArrayOfBytesFromImage(_ imageData:Data) {
        let count = imageData.count / MemoryLayout<UInt8>.size
        var bytes = [UInt8](repeating: 0, count: count)
        let byteArray:NSMutableArray = NSMutableArray()
        
        (imageData as NSData).getBytes(&bytes, length:count * MemoryLayout<UInt8>.size)
        for i in 0 ..< count {
            byteArray.add(NSNumber(value: bytes[i]))
        }
        let NewArr=NSArray(array: byteArray)
        let endMarker = NSData(bytes:NewArr as! [UInt8] , length: byteArray.count)
        print(endMarker)
        fullImage = NSArray(array: byteArray)
        var timestamp:String =  String(Date().ticks)
        var servertimeStr:String = Themes.sharedInstance.getServerTime()
        
        if(servertimeStr == "")
        {
            servertimeStr = "0"
        }
        let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
        timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
        imageName = "\(Themes.sharedInstance.Getuser_id())-\(timestamp).jpg"
        SocketIOManager.sharedInstance.Delegate = self
        SocketIOManager.sharedInstance.uploadImage(from:Themes.sharedInstance.Getuser_id(),imageName:imageName,uploadType:"single",bufferAt:"0",imageByte:endMarker,file_end: "1")
    }
    
    func statusUpdated(_Updated: String) {
        if(_Updated != "CHECK")
        {
            if(_Updated != "")
            {
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(NewGroupSetNameViewController.DismissLoader(IsfromUploader:)), object: nil)
                reloadData()
                self.DismissLoader(IsfromUploader: true)
            }
            else
            {
                self.DismissLoader(IsfromUploader: false)
            }
        }
    }
    
    func DismissLoader(IsfromUploader:Bool)
    {
        Themes.sharedInstance.RemoveactivityView(View: self.view)
        
        if(!IsfromUploader)
        {
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            self.view.makeToast(message: "Request time out")
            self.go_btn.isUserInteractionEnabled = true

            self.go_btn.setTitleColor(UIColor.white, for: .normal)
        }
        else
        {
            self.view.makeToast(message: "Profile picture updated.")
            self.go_btn.isUserInteractionEnabled = true

            self.go_btn.setTitleColor(UIColor.white, for: .normal)
        }
        
    }
    
}

extension ProfileInfoViewController : AppDelegateDelegates {
    func ReceivedBuffer(Status: String, imagename: String) {
        
        if(Status != "CHECK")
        {
            if Status == "Updated"{
                SocketIOManager.sharedInstance.updateProfilepic(file: imagename, from: Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id()),type: "single")
            }
        }
        
    }
}


