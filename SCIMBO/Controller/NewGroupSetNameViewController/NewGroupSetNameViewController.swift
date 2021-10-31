//
//  NewGroupSetNameViewController.swift
//
//
//  Created by CASPERON on 01/02/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit
import SWMessages
import RSKImageCropper


protocol LoadTableView : class {
    func  changeSelecFrmColl(ID: String , from:String)
}

class NewGroupSetNameViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPopoverControllerDelegate,SocketIOManagerDelegate,RSKImageCropViewControllerDelegate,UITextFieldDelegate {
    
    @IBOutlet weak var groupNameTxt: UITextField!
    
    @IBOutlet weak var text_count: UILabel!
    @IBOutlet weak var noOfParticipantsLbl: UILabel!
    @IBOutlet weak var createBtn: UIButton!
    
    @IBOutlet weak var collection_ViewSetName: UICollectionView!
    
    @IBOutlet weak var profileImg: UIButton!
    @IBOutlet weak var profileImgBtn: UIImageView!

    //var collectionArray:NSMutableArray = NSMutableArray()
    var collectionArray = [NSObject]()
    var collectionImgArray:NSMutableArray = NSMutableArray()
    var tagCpyArry:NSMutableArray = NSMutableArray()
    var picker = UIImagePickerController()
    weak var delegate:LoadTableView!
    var ProfilePic:String!
    
    var fullImage:NSArray = NSArray()
    var imageName:String = String()
    var User_idArr:NSMutableArray=NSMutableArray()
    var isimageSelected:Bool = Bool()
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        
        SetView()
        profileImgBtn.image = #imageLiteral(resourceName: "groupavatar")
        groupNameTxt.delegate = self
        groupNameTxt.placeholder = "Group Subject".localized()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppDelegate.sharedInstance.Delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SocketIOManager.sharedInstance.Delegate = nil
    }
    func SetView()
    {
        if languageHandler.ApplicationLanguage().contains("ar") {
            noOfParticipantsLbl.text = "المشتركون \(collectionArray.count) من 256"
        }else{
            noOfParticipantsLbl.text = "PARTICIPANTS: \(collectionArray.count) OF 256"
        }
        
        for i in 0..<collectionArray.count{
            collectionImgArray.add(collectionArray[i])
        }
        ProfilePic=""
        profileImgBtn.layer.cornerRadius=profileImgBtn.frame.size.width/2
        profileImgBtn.clipsToBounds=true
    }
    @objc func GroupCreated()
    {
        self.DismissLoader(IsfromUploader: true)
        Themes.sharedInstance.ShowNotification("Group successfully created".localized(), true)
        let indexDic = ["index":1]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.getPageIndex), object: nil, userInfo: indexDic)
        self.popToRoot(animated: true)
        
    }
    func callBackImageUploaded(UploadedStr: String) {
        if(UploadedStr != "CHECK")
        {
            if(UploadedStr == "group")
            {
                self.perform(#selector(self.GroupCreated), with: nil, afterDelay: 2.0)
                
            }
            else if(UploadedStr != "")
            {
                ProfilePic=UploadedStr
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(NewGroupSetNameViewController.DismissLoader(IsfromUploader:)), object: nil)
                self.DismissLoader(IsfromUploader: true)
            }
            else
            {
                self.DismissLoader(IsfromUploader: false)
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:NewGroupSetNameCollCell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewGroupSetNameCollCell", for: indexPath) as! NewGroupSetNameCollCell
        cell.deleteBtn.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        cell.deleteBtn.tag = indexPath.row
        let contactRecImage : NewGroupAdd =  collectionArray[indexPath.row] as! NewGroupAdd
        cell.imageView.layer.cornerRadius=cell.imageView.frame.size.width/2
        cell.imageView.clipsToBounds=true
        cell.imageView.sd_setImage(with: URL(string: "\(contactRecImage.image as String)"), placeholderImage: UIImage(named: "avatar"), options: .refreshCached)
        cell.name_lbl.setNameTxt(contactRecImage.id as String, "single")
        return cell
    }
    
    @objc func deleteAction(sender:UIButton){
        newGroup.checkReldFrmSetName = "Reload"
        let getObj = collectionArray[sender.tag] as! NewGroupAdd
        let  getPhoneno = getObj.id as String
        collectionArray.remove(at: sender.tag)
        self.delegate.changeSelecFrmColl(ID: getPhoneno , from: "setName")
        if languageHandler.ApplicationLanguage().contains("ar") {
            noOfParticipantsLbl.text = "المشتركون \(collectionArray.count) من 256"
        }else{
            noOfParticipantsLbl.text = "PARTICIPANTS: \(collectionArray.count) OF 256"
        }
        //tagCpyArry.removeObject(at:  sender.tag)
        if collectionArray.count == 0{
            createBtn.setTitleColor(UIColor.gray, for: UIControl.State.normal)
        }
        else{
            createBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
        }
        collection_ViewSetName.reloadData()
    }
    @IBAction func profileBtnAction(_ sender: UIButton) {
        
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let nsString = NSString(string: textField.text!)
        let newText = nsString.replacingCharacters(in: range, with: string)
        if(newText.length <= 25){
            text_count.text = "\(25 - newText.length)"
        }
        return  newText.count <= 25
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
        picker.dismissView(animated: true, completion: {
            let imageCropVC = RSKImageCropViewController(image: UIImage(data: compressedimg!)!)
            imageCropVC.delegate = self
            self.pushView(imageCropVC, animated: true)
        })
    }
    
    
    
    @objc func DismissLoader(IsfromUploader:Bool)
    {
        Themes.sharedInstance.RemoveactivityView(View: self.view)
        
        if(!IsfromUploader)
        {
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            self.view.makeToast(message: "Request time out")
            self.createBtn.isUserInteractionEnabled=true
            self.createBtn.setTitleColor(UIColor.white, for: .normal)
        }
        else
        {
            self.createBtn.isUserInteractionEnabled=true
            self.createBtn.setTitleColor(UIColor.white, for: .normal)
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        print("picker cancel.")
        picker.dismissView(animated: true, completion: nil)
    }
    
    @IBAction func createBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if(collectionArray.count != 0){
            if groupNameTxt.text?.trimmingCharacters(in: .whitespaces).isEmpty == true{
                Themes.sharedInstance.ShowNotification("Please enter group name".localized(), false)
            }
            else{
                User_idArr = NSMutableArray()
                for i in 0..<collectionArray.count
                {
                    let contactRecImage : NewGroupAdd =  collectionArray[i] as! NewGroupAdd
                    User_idArr.add(contactRecImage.id)
                }
                User_idArr.add(Themes.sharedInstance.Getuser_id())
                
                if(isimageSelected)
                {
                    Themes.sharedInstance.activityView(View: self.view)
                    splitImage(image: (profileImgBtn.image)!)
                    self.createBtn.isUserInteractionEnabled = false
                    
                }
                else
                {
                    imageName = ""
                    self.create_group()
                    self.createBtn.isUserInteractionEnabled = false
                }
                
                
                
                
            }
        }else{
            Themes.sharedInstance.ShowNotification("Atleast 1 contact must be selected", false)
        }
        
    }
    
    func create_group()
    {
        SocketIOManager.sharedInstance.Delegate=self
        let param = ["from":Themes.sharedInstance.Getuser_id(),"groupType":"1","groupName":Themes.sharedInstance.CheckNullvalue(Passed_value: groupNameTxt.text),"groupMembers":(User_idArr as NSArray) as! [String],"profilePic":imageName] as [String : Any];
        
        SocketIOManager.sharedInstance.Groupevent(param: param)
        Themes.sharedInstance.activityView(View: self.view)
        self.createBtn.setTitleColor(UIColor.lightGray, for: .normal)
        self.perform(#selector(NewGroupSetNameViewController.DismissLoader(IsfromUploader:)), with: nil, afterDelay: 120)
        
    }
    @IBAction func backAction(_ sender: UIButton) {
        self.pop(animated: true)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func ReloadGroupTable() {
        
    }
    
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        self.pop(animated: true)
    }
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect)
    {
        profileImgBtn.image  = croppedImage
        self.pop(animated: true)
        isimageSelected = true
    }
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat)
    {
        self.pop(animated: true)
        profileImgBtn.image  = croppedImage
        SocketIOManager.sharedInstance.Delegate = self
        isimageSelected = true
        
    }
    func splitImage(image:UIImage){
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
        imageName = "\(Themes.sharedInstance.Getuser_id())-\(timestamp).jpeg"
        SocketIOManager.sharedInstance.Delegate = self
        SocketIOManager.sharedInstance.uploadImage(from:Themes.sharedInstance.Getuser_id(),imageName:imageName,uploadType:"group",bufferAt:"0",imageByte:endMarker ,file_end: "1")
    }
    func imageCropViewController(_ controller: RSKImageCropViewController, willCropImage originalImage: UIImage) {
        
    }
}

extension NewGroupSetNameViewController : AppDelegateDelegates {
    
    func ReceivedBuffer(Status: String, imagename: String)
    {
        
        if(Status != "CHECK")
        {
            if Status == "Updated"{
                imageName = imagename
                create_group()
                
            }
            
        }
        
    }
}
