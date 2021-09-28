//
//  EditProfileViewController.swift
//
//
//  Created by CASPERON on 13/02/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit
import GSImageViewerController
import SDWebImage
import RSKImageCropper
class EditProfileViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPopoverControllerDelegate,UITextFieldDelegate,RSKImageCropViewControllerDelegate, SocketIOManagerDelegate{
    
    @IBOutlet weak var baseView:UIView!
    @IBOutlet weak var imageDetailViewHeight: NSLayoutConstraint!
    @IBOutlet weak var activityIndctr_Image: UIActivityIndicatorView!
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var imageView_Detail: UIImageView!
    @IBOutlet weak var imageShow_View: UIView!
    @IBOutlet weak var switchControl: UISwitch!
    @IBOutlet weak var nameCount_Lbl: UILabel!
    @IBOutlet weak var statusBtn: UIButton!
    @IBOutlet weak var phoneLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var emailAddressLbl: UILabel!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var profileImg: UIButton!
    @IBOutlet weak var profileImg_Btn: UIImageView!

    @IBOutlet weak var nameTxt: UITextField!
    
    var picker = UIImagePickerController()
    //    var popover:UIPopoverController?=nil
    var customColor = CustomColor()
    var activityView:UIActivityIndicatorView =  UIActivityIndicatorView()
    var fullImage:NSArray = NSArray()
    var imageName:String = String()
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        addNotificationListener()
        setBorderColor()
        activityView.stopAnimating()
        activityView.isHidden = true
        activityIndctr_Image.isHidden = true
        imageShow_View.isHidden = true
        profileImg_Btn.backgroundColor = .clear
        profileImg_Btn.layer.cornerRadius =  profileImg_Btn.frame.width/2
        profileImg_Btn.clipsToBounds = true
        profileImg_Btn.layer.borderWidth = 1
        profileImg_Btn.layer.borderColor = UIColor.lightGray.cgColor
        doneBtn.isHidden = true
    }
    
    @IBAction func switchButtonChanged(_ sender: UISwitch) {
        if let user = Themes.sharedInstance.GetuserDetails() {
            let id = Themes.sharedInstance.Getuser_id()
            let name = user.name ?? ""
            let email = user.email ?? ""
            let showNumber = switchControl.isOn
            SocketIOManager.sharedInstance.changeName(name: name, from:id , email: email,showNumber: showNumber)
        }
    }
    
    func setBorderColor()
    {
        let borderBottom = CALayer()
        let borderWidth = CGFloat(2.0)
        borderBottom.borderColor =  customColor.lightgrayColor.cgColor
        borderBottom.frame = CGRect(x: 0, y: statusBtn.frame.height - 1.0, width: Themes.sharedInstance.screenSize.width , height: statusBtn.frame.height - 1.0)
        borderBottom.borderWidth = borderWidth
        statusBtn.layer.addSublayer(borderBottom)
        statusBtn.layer.masksToBounds = true
        let borderTop = CALayer()
        borderTop.borderColor = customColor.lightgrayColor.cgColor
        borderTop.frame = CGRect(x: 0, y: 0, width: Themes.sharedInstance.screenSize.width, height: 1)
        borderTop.borderWidth = borderWidth
        statusBtn.layer.addSublayer(borderTop)
        statusBtn.layer.masksToBounds = true
        statusBtn.titleLabel?.textAlignment = .left
        let lblBorderBottom = CALayer()
        let lblBorderWidth = CGFloat(2.0)
        lblBorderBottom.borderColor =  customColor.lightgrayColor.cgColor
        lblBorderBottom.frame = CGRect(x: 0, y: phoneLbl.frame.height - 1.0, width: Themes.sharedInstance.screenSize.width , height: 10)
        borderBottom.borderWidth = lblBorderWidth
        phoneLbl.layer.addSublayer(lblBorderBottom)
        phoneLbl.layer.masksToBounds = true
        let lblBorderTop = CALayer()
        lblBorderTop.borderColor = customColor.lightgrayColor.cgColor
        lblBorderTop.frame = CGRect(x: 0, y: 0, width: Themes.sharedInstance.screenSize.width, height: 1)
        lblBorderTop.borderWidth = lblBorderWidth
        phoneLbl.layer.addSublayer(lblBorderTop)
        phoneLbl.layer.masksToBounds = true
        
        let lblBorderTop2 = CALayer()
        lblBorderTop2.borderColor = customColor.lightgrayColor.cgColor
        lblBorderTop2.frame = CGRect(x: 0, y: 0, width: Themes.sharedInstance.screenSize.width, height: 1)
        lblBorderTop2.borderWidth = lblBorderWidth
        emailAddressLbl.layer.addSublayer(lblBorderTop2)
        emailAddressLbl.layer.masksToBounds = true
    }
    
    
    func setUserDetails(){
        
        if let user = Themes.sharedInstance.GetuserDetails() {
            phoneLbl.text = " " + (user.mobilenumber ?? "")
            nameTxt.text = user.name ?? "You"
            profileImg_Btn.setProfilePic(Themes.sharedInstance.Getuser_id(), "single")
            emailAddressLbl.text = user.email ?? ""
            let isShowNumber = user.showNumber
            switchControl.setOn(isShowNumber, animated: false)
            
            let status = user.status ?? ""
            var lang = Locale.preferredLanguages[0].substring(to: 2)
            if lang == "ar"{
                statusBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.right
            }else{
                statusBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
            }
            
            if  status != ""{
                
                statusBtn.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 10, bottom: 0.0, right: 0.0)
                statusBtn.setTitle(status, for: UIControl.State.normal)
            }
            else
            {
                statusBtn.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 10, bottom: 0.0, right: 0.0)
                statusBtn.setTitle(NSLocalizedString("Hey there! I am using", comment: "test")  + " " + Themes.sharedInstance.GetAppname(), for: UIControl.State.normal)
            }
        }
        
    }
    @IBAction func availableBtn_Action(_ sender: UIButton) {
        
        let statusVC = storyboard?.instantiateViewController(withIdentifier: "StatusListViewController") as! StatusListViewController
        self.pushView(statusVC, animated: true)
        
    }
    @IBAction func profileImg_Action(_ sender: UIButton) {
        
        if  (profileImg_Btn.image?.isEqual(UIImage(named: "avatar")))!
        {
            let alert:UIAlertController=UIAlertController(title: NSLocalizedString("Choose Image", comment: "") , message: nil, preferredStyle: .actionSheet)
            
            let cameraAction = UIAlertAction(title: NSLocalizedString("Camera", comment: "") , style: UIAlertAction.Style.default)
            {
                
                UIAlertAction in
                self.openCamera()
            }
            
            let gallaryAction = UIAlertAction(title: NSLocalizedString("Gallery", comment: "") , style: UIAlertAction.Style.default)
            {
                UIAlertAction in
                self.openGallary()
            }
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel)
            {
                UIAlertAction in
            }
            // Add the actions
            picker.delegate = self
            alert.addAction(cameraAction)
            alert.addAction(gallaryAction)
            alert.addAction(cancelAction)
            self.presentView(alert, animated: true, completion: nil)
        }
            
        else{
            
            let imageInfo   = GSImageInfo(image: (profileImg_Btn.image)! , imageMode: .aspectFit)
            
            let transitionInfo = GSTransitionInfo(fromView: profileImg_Btn)
            let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
            self.doneBtn.isHidden = false
            self.doneBtn.setTitle(NSLocalizedString("Edit", comment: "Edit"), for: UIControl.State.normal)
            self.headerTitle.text = "Profile Photo"
            self.presentView(imageViewer, animated: true)
            
        }
        
    }
    
    func openCamera()
    {     if let activeController = self.navigationController?.visibleViewController{
        if activeController.isKind(of: GSImageViewerController.self){
            
            self.dismissView(animated: true, completion: {
                if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
                {
                    self.picker.sourceType = UIImagePickerController.SourceType.camera
                    
                    if let activeController = self.navigationController?.visibleViewController{
                        
                        if activeController.isKind(of: GSImageViewerController.self){
                            UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.presentView(self.picker, animated: true)
                            
                            
                        }
                        else{
                            self.presentView(self.picker, animated: true)
                        }
                    }
                }
                else
                {
                    self.openGallary()
                }
            })
        }
        else
        {
            if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
            {
                self.picker.sourceType = UIImagePickerController.SourceType.camera
                
                if let activeController = self.navigationController?.visibleViewController{
                    
                    if activeController.isKind(of: GSImageViewerController.self){
                        UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.presentView(self.picker, animated: true)
                        
                        
                    }
                    else{
                        self.presentView(self.picker, animated: true)
                    }
                }
            }
            else
            {
                self.openGallary()
            }
        }
        }
        
    }
    
    func openGallary()
    {
        
        if let activeController = self.navigationController?.visibleViewController{
            if activeController.isKind(of: GSImageViewerController.self){
                
                self.dismissView(animated: true, completion: {
                    self.picker.sourceType = UIImagePickerController.SourceType.photoLibrary
                    if UIDevice.current.userInterfaceIdiom == .phone
                    {
                        
                        if let activeController = self.navigationController?.visibleViewController{
                            
                            if activeController.isKind(of: GSImageViewerController.self){
                                
                                UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.presentView(self.picker, animated: true)
                                
                                
                            }
                            else{
                                self.presentView(self.picker, animated: true)
                            }
                        }
                        
                    }
                    else
                    {
                    }
                })
            }
            else
                
            {
                picker.sourceType = UIImagePickerController.SourceType.photoLibrary
                if UIDevice.current.userInterfaceIdiom == .phone
                {
                    
                    if let activeController = self.navigationController?.visibleViewController{
                        
                        if activeController.isKind(of: GSImageViewerController.self){
                            
                            UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.presentView(picker, animated: true)
                            
                            
                        }
                        else{
                            self.presentView(picker, animated: true)
                        }
                    }
                    
                }
                else
                {
                }
            }
        }
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        let profilpic = Themes.sharedInstance.setProfilePic(Themes.sharedInstance.Getuser_id(), "single")
        if  profilpic != "" && profilpic.substring(to: 1) != "."
        {
            SDImageCache.shared().removeImage(forKey: profilpic, fromDisk: true)
        }
        if let activeController = self.navigationController?.visibleViewController{
            if activeController.isKind(of: GSImageViewerController.self){
                self.dismissView(animated: true, completion: nil)
            }
        }
        let image : UIImage = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage)!
        let compressedimg = image.jpegData(compressionQuality: 0.3)
        let imageCropVC = RSKImageCropViewController(image: UIImage(data: compressedimg!)!)
        imageCropVC.delegate = self
        self.pushView(imageCropVC, animated: true)
        picker.dismissView(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismissView(animated: true, completion: nil)
    }
    
    
    @IBAction func backAction(_ sender: UIButton) {
        
        if let activeController = self.navigationController?.visibleViewController{
            
            if activeController.isKind(of: GSImageViewerController.self){
                UIView.animate(withDuration: 5, animations: {
                    self.imageShow_View.isHidden = true
                    self.doneBtn.isHidden = false
                    self.doneBtn.setTitle( "Done", for: UIControl.State.normal)
                    self.headerTitle.text = "Edit Profile"
                    
                })
                
                self.dismissView(animated: true, completion: nil)
                
                
            }
            else{
                
                if doneBtn.titleLabel?.text == "Done" {
                    self.pop(animated: true)
                    
                }
                    
                else{
                    
                    UIView.animate(withDuration: 5, animations: {
                        self.imageShow_View.isHidden = true
                        self.doneBtn.isHidden = false
                        self.doneBtn.setTitle( "Done", for: UIControl.State.normal)
                        self.headerTitle.text = "Edit Profile"
                    })
                }
                
            }
            
        }
        
    }
    
    
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        
        self.pop(animated: true)
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
        self.imageView_Detail?.image = croppedImage
        self.pop(animated: true)
    }
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        self.pop(animated: true)
        guard !croppedImage.isPanaroma() else{
            self.view.makeToast(message: "Please crop the image in correct resolution", duration: 3, position: HRToastActivityPositionDefault)
            self.activityView.stopAnimating()
            self.activityView.isHidden = true
            return
        }
        self.imageView_Detail?.image = croppedImage
        splitImage(image: croppedImage)
        SocketIOManager.sharedInstance.Delegate = self
        self.imageShow_View.isHidden = true
        self.doneBtn.isHidden = false
        self.doneBtn.setTitle( "Done", for: UIControl.State.normal)
        self.headerTitle.text = "Edit Profile"
        self.imageShow_View.isHidden = true
        //        setUserDetails()
    }
    func splitImage(image:UIImage){
        let imageForSplit = image
        let imageData = imageForSplit.jpegData(compressionQuality: 0.3)
//        UIImageJPEGRepresentation(imageForSplit, 0.3)
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
        imageName = "\(Themes.sharedInstance.Getuser_id())-\(timestamp).jpeg"
        SocketIOManager.sharedInstance.Delegate = self
        SocketIOManager.sharedInstance.uploadImage(from:Themes.sharedInstance.Getuser_id(),imageName:imageName,uploadType:"single",bufferAt:"0",imageByte:endMarker ,file_end: "1")
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, willCropImage originalImage: UIImage) {
        // Use when `applyMaskToCroppedImage` set to YES.
        // SVProgressHUD.show()
        doneBtn.isHidden = true
        activityView = UIActivityIndicatorView(style: .gray)
        
        profileImg.addSubview(activityView)
        activityView.center =  CGPoint(x: 29, y: 29)
        activityView.startAnimating()
    }
    
    func statusUpdated(_Updated: String) {
        if(_Updated != "CHECK")
        {
            
            if _Updated == "Updated" || _Updated == "Updated Name"{
                if(_Updated == "Updated Name")
                {
                    activityView.stopAnimating()
                    activityView.isHidden = true
                    setUserDetails()
                    self.view.makeToast(message: "Profile name updated successfully", duration: 3, position: HRToastActivityPositionDefault)
                }
                else
                {
                    setUserDetails()
                    self.activityView.stopAnimating()
                    self.activityView.isHidden = true
                    self.view.makeToast(message: "Profile picture updated successfully.", duration: 3, position: HRToastActivityPositionDefault)
                }
            }
            else{
                activityView.stopAnimating()
                activityView.isHidden = true
                self.view.makeToast(message: "error in connection" , duration: 3, position: HRToastActivityPositionDefault)
            }
        }
    }
    
    @IBAction func doneAction(_ sender: UIButton) {
        nameTxt.resignFirstResponder()
        
        if doneBtn.titleLabel?.text == "Done"{
            
            if nameTxt.text?.trimmingCharacters(in: .whitespaces).isEmpty == false{
                Themes.sharedInstance.activityView(View: self.view)
                SocketIOManager.sharedInstance.Delegate = self
                guard let user = Themes.sharedInstance.GetuserDetails() else {
                    return
                }
                SocketIOManager.sharedInstance.changeName(name: nameTxt.text! , from: Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id()), email: user.email ?? "")
                
            }else{
                Themes.sharedInstance.ShowNotification("Name field cannot be empty", false)
            }
        }
        else {
            let alert:UIAlertController=UIAlertController(title:nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
            let deleteAction = UIAlertAction(title: "Delete Photo", style: UIAlertAction.Style.default)
            {
                UIAlertAction in
                
                //                SocketIOManager.sharedInstance.delegate = self
                //                SocketIOManager.sharedInstance.updateProfilepic(file: "", from: Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id()),type: "single")
                
                
                let UpdateDict:[String:Any]=["profilepic": ""]
                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail , FetchString: Themes.sharedInstance.Getuser_id() , attribute:"user_id" , UpdationElements: UpdateDict as NSDictionary?)
                self.imageShow_View.isHidden = true
                self.doneBtn.isHidden = false
                self.doneBtn.setTitle( "Done", for: UIControl.State.normal)
                self.headerTitle.text = "Edit Profile"
                //var array: [Any]? = self.navigationController?.viewControllers
                //self.navigationController?.popToViewController(array?[0] as! UIViewController, animated: true)
                self.imageShow_View.isHidden = true
                self.dissmissViewController()
                let dict:NSDictionary = ["from":Themes.sharedInstance.Getuser_id(),"type":"single","ImageName":"","removePhoto":"yes"]
                SocketIOManager.sharedInstance.EmitRemovePhoto(Dict: dict)
                //self.imageShow_View.removeFromSuperview()
                // self.pop(animated: true)
                //self.openCamera()
            }
            
            let cameraAction = UIAlertAction(title:NSLocalizedString("Take Photo", comment: "com") , style: UIAlertAction.Style.default)
            {
                UIAlertAction in
                
                self.openCamera()
            }
            let gallaryAction = UIAlertAction(title:NSLocalizedString("Choose Photo", comment: "com") , style: UIAlertAction.Style.default)
            {
                UIAlertAction in
                self.openGallary()
            }
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "com"), style: UIAlertAction.Style.cancel)
            {
                UIAlertAction in
            }
            // Add the actions
            picker.delegate = self
            alert.addAction(deleteAction)
            alert.addAction(cameraAction)
            alert.addAction(gallaryAction)
            alert.addAction(cancelAction)
            // Present the controller
            
            if UIDevice.current.userInterfaceIdiom == .phone
            {
                
                _   = GSImageInfo(image: (profileImg_Btn.image)! , imageMode: .aspectFit)
                
                _ = GSTransitionInfo(fromView: sender)
                UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.presentView(alert, animated: true, completion: nil)
            }
            else
            {
            }
            
            
            
            
        }
        
    }
    
    func dissmissViewController(){
        
        
        
        if let activeController = self.navigationController?.visibleViewController{
            
            if activeController.isKind(of: GSImageViewerController.self){
                UIView.animate(withDuration: 5, animations: {
                    self.imageShow_View.isHidden = true
                    self.doneBtn.isHidden = false
                    self.doneBtn.setTitle( "Done", for: UIControl.State.normal)
                    self.headerTitle.text = "Edit Profile"
                    
                    
                })
                
                self.dismissView(animated: true, completion: nil)
                
            }
            
        }
        self.setUserDetails()
        
    }
    func hiddenBottomView()
    {
        
        print("bottom view hidden")
    }
    
    func removeActivity(){
        
        Themes.sharedInstance.RemoveactivityView(View: self.view)
        
    }
    
    func setHeaderTitles(){
        
        UIView.animate(withDuration: 5, animations: {
            self.imageShow_View.isHidden = true
            self.doneBtn.isHidden = false
            self.doneBtn.setTitle(NSLocalizedString("Done", comment: "com") , for: UIControl.State.normal)
            self.headerTitle.text = "Edit Profile"
            
        })
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let length = (textField.text?.count)! - range.length + string.count
        
        
        if length > 0
        {
            if length > 25{
                return false
            }
            nameCount_Lbl.text = "\(25 - length)"
            doneBtn.isHidden = false
        }
        else
        {
            doneBtn.isHidden = true
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    override func viewDidLayoutSubviews() {
        // imageDetailViewHeight.constant = 1000
        
        profileImg_Btn.backgroundColor = .clear
        profileImg_Btn.layer.cornerRadius = 30
        profileImg_Btn.layer.borderWidth = 1
        profileImg_Btn.layer.borderColor = UIColor.black.cgColor
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppDelegate.sharedInstance.Delegate = self
        setUserDetails()
        doneBtn.isHidden = true
        activityIndctr_Image.isHidden = true
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        
        SocketIOManager.sharedInstance.Delegate = nil
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addNotificationListener() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.RemoveActivity), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            weak.removeActivity()
        }
    }
    
    func removeNotificationListener() {
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        removeNotificationListener()
    }

}

extension EditProfileViewController : AppDelegateDelegates{
    func ReceivedBuffer(Status: String, imagename: String) {
        
        if(Status != "CHECK")
        {
            if Status == "Updated"{
                SocketIOManager.sharedInstance.updateProfilepic(file: imagename, from: Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id()),type: "single")
            }
        }
        
    }
}




