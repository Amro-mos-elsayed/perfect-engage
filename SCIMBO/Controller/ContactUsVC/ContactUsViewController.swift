//
//  ContactUsViewController.swift
//
//
//  Created by Prem Mac on 19/01/18.
//  Copyright © 2018 CASPERON. All rights reserved.
//

import UIKit
import DKImagePickerController
import Photos
import MessageUI

class ContactUsViewController: UIViewController,UITextViewDelegate,MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn3: UIButton!
    
    @IBOutlet weak var screen_shot_three: UIImageView!
    @IBOutlet weak var screen_shot_two: UIImageView!
    @IBOutlet weak var screenshot_one: UIImageView!
    @IBOutlet weak var textview: UITextView!
    
    @IBOutlet weak var delete_sshot_one: UIButton!
    @IBOutlet weak var delete_sshot_two: UIButton!
    @IBOutlet weak var delete_sshot_three: UIButton!
    var screen_shot:NSMutableArray = NSMutableArray()
    var attachment:NSMutableArray = NSMutableArray()
    var mail_id:String = String()
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        textview.text = "Please describe your problem"
        textview.textColor = UIColor.lightGray
        let checkBool:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.User_detail, attribute: "user_id", FetchString: Themes.sharedInstance.Getuser_id())
        if(checkBool){
            let getInfo:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.User_detail, attribute: "user_id", FetchString: Themes.sharedInstance.Getuser_id(), SortDescriptor: nil) as! NSArray
            if(getInfo.count > 0){
                for i in 0..<getInfo.count{
                    let dict:NSManagedObject = getInfo[i] as! NSManagedObject
                    mail_id = Themes.sharedInstance.CheckNullvalue(Passed_value: dict.value(forKey: "contact_us"))
                }
            }
        }
        delete_sshot_one.isHidden = true
        delete_sshot_two.isHidden = true
        delete_sshot_three.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    @IBAction func delete_sshot(_ sender: UIButton) {
        screen_shot.removeObject(at: sender.tag)
        self.deleteScreenShot(AssetArr: screen_shot)
        
    }
    
    
    func setImages(AssetArr: NSMutableArray) {
        attachment = NSMutableArray()
        screen_shot = AssetArr
        if(AssetArr.count > 0)
        {
            
            for i in 0..<AssetArr.count
            {
                let ObjMultiMedia:MultimediaRecord = AssetArr[i] as! MultimediaRecord
                if(!ObjMultiMedia.isVideo)
                {
                    if(AssetArr.count == 1){
                        if(i == 0){
                            screenshot_one.image = ObjMultiMedia.Thumbnail
                            attachment.add(ObjMultiMedia.Thumbnail)
                        }
                        self.btn1.isHidden = true
                        self.delete_sshot_one.isHidden = false
                        self.delete_sshot_two.isHidden = true
                        self.delete_sshot_three.isHidden = true
                        self.btn2.isHidden = false
                        self.btn3.isHidden = false
                        screen_shot_two.image = nil
                        screen_shot_three.image = nil
                        
                    }
                    
                    if(AssetArr.count == 2){
                        if(i == 0){
                            screenshot_one.image = ObjMultiMedia.Thumbnail
                            attachment.add(ObjMultiMedia.Thumbnail)
                        }else if(i == 1){
                            screen_shot_two.image = ObjMultiMedia.Thumbnail
                            attachment.add(ObjMultiMedia.Thumbnail)
                        }
                        self.btn1.isHidden = true
                        self.btn2.isHidden = true
                        self.delete_sshot_one.isHidden = false
                        self.delete_sshot_two.isHidden = false
                        self.delete_sshot_three.isHidden = true
                        self.btn3.isHidden = false
                        screen_shot_three.image = nil
                        
                    }
                    
                    if(AssetArr.count == 3){
                        if(i == 0){
                            screenshot_one.image = ObjMultiMedia.Thumbnail
                            attachment.add(ObjMultiMedia.Thumbnail)
                        }else if(i == 1){
                            screen_shot_two.image = ObjMultiMedia.Thumbnail
                            attachment.add(ObjMultiMedia.Thumbnail)
                        }else if(i == 2){
                            screen_shot_three.image = ObjMultiMedia.Thumbnail
                            attachment.add(ObjMultiMedia.Thumbnail)
                        }
                        
                        self.btn1.isHidden = true
                        self.btn2.isHidden = true
                        self.btn3.isHidden = true
                        self.delete_sshot_one.isHidden = false
                        self.delete_sshot_two.isHidden = false
                        self.delete_sshot_three.isHidden = false
                        
                        
                    }
                }
            }
        }
    }
    
    func deleteScreenShot(AssetArr:NSMutableArray){
        attachment = NSMutableArray()
        if(AssetArr.count > 0)
        {
            
            for i in 0..<AssetArr.count
            {
                let ObjMultiMedia:MultimediaRecord = AssetArr[i] as! MultimediaRecord
                if(!ObjMultiMedia.isVideo)
                {
                    if(AssetArr.count == 1){
                        if(i == 0){
                            screenshot_one.image = ObjMultiMedia.Thumbnail
                            attachment.add(ObjMultiMedia.Thumbnail)
                        }
                        self.btn1.isHidden = true
                        self.delete_sshot_one.isHidden = false
                        self.delete_sshot_two.isHidden = true
                        self.delete_sshot_three.isHidden = true
                        self.btn2.isHidden = false
                        self.btn3.isHidden = false
                        screen_shot_two.image = nil
                        screen_shot_three.image = nil
                        
                    }
                    
                    if(AssetArr.count == 2){
                        if(i == 0){
                            screenshot_one.image = ObjMultiMedia.Thumbnail
                            attachment.add(ObjMultiMedia.Thumbnail)
                        }else if(i == 1){
                            screen_shot_two.image = ObjMultiMedia.Thumbnail
                            attachment.add(ObjMultiMedia.Thumbnail)
                        }
                        btn3.backgroundColor = UIColor.clear
                        self.btn1.isHidden = true
                        self.btn2.isHidden = true
                        self.delete_sshot_one.isHidden = false
                        self.delete_sshot_two.isHidden = false
                        self.delete_sshot_three.isHidden = true
                        self.btn3.isHidden = false
                        screen_shot_three.image = nil
                        
                    }
                    
                    if(AssetArr.count == 3){
                        if(i == 0){
                            screenshot_one.image = ObjMultiMedia.Thumbnail
                            attachment.add(ObjMultiMedia.Thumbnail)
                        }else if(i == 1){
                            screen_shot_two.image = ObjMultiMedia.Thumbnail
                            attachment.add(ObjMultiMedia.Thumbnail)
                        }else if(i == 2){
                            screen_shot_three.image = ObjMultiMedia.Thumbnail
                            attachment.add(ObjMultiMedia.Thumbnail)
                        }
                        
                        self.btn1.isHidden = true
                        self.btn2.isHidden = true
                        self.btn3.isHidden = true
                        self.delete_sshot_one.isHidden = false
                        self.delete_sshot_two.isHidden = false
                        self.delete_sshot_three.isHidden = false
                        
                        
                    }
                }
            }
        }else{
            screenshot_one.image = nil
            self.btn1.isHidden = false
            btn1.backgroundColor = UIColor.clear
            self.delete_sshot_one.isHidden = true
        }
    }
    
    @IBAction func did_click_add_photo(_ sender: UIButton) {
        
        let pickerController = DKImagePickerController()
        pickerController.maxSelectableCount = 3
        pickerController.assetType = .allPhotos
        pickerController.sourceType = .photo
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            if(assets.count > 0)
            {
                Themes.sharedInstance.activityView(View: self.view)
                AssetHandler.sharedInstance.ProcessAsset(assets: assets,oppenentID: Themes.sharedInstance.Getuser_id(),isFromStatus: false, completionHandler: { [weak self] (AssetArr, error) -> ()? in
                    if((AssetArr?.count)! > 0)
                    {
                        DispatchQueue.main.async {
                            Themes.sharedInstance.RemoveactivityView(View: (self?.view)!)
                            self?.setImages(AssetArr: AssetArr!)
                            
                        }
                        
                    }
                    return ()
                })
            }
        }
        
        self.presentView(pickerController, animated: true)
        
    }
    
    @IBAction func click_next(_ sender: UIButton) {
        if(textview.text != "Please describe your problem"){
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self;
                mail.setToRecipients([mail_id])
                mail.setSubject("Problem with the app")
                mail.setMessageBody(textview.text, isHTML: false)
                for i in 0..<attachment.count{
                    let fileName:NSString = "file\(i).png" as NSString
                    var mimeType:String = String()
                    mimeType = "image/png"
                    let data:Data = (attachment[i] as! UIImage).pngData()!
                    mail.addAttachmentData(data, mimeType: mimeType, fileName: fileName as String)
                }
                
                self.presentView(mail, animated: true)
            }
            else
            {
                self.view.makeToast(message: "Please login to a mail account to share", duration: 3, position: HRToastActivityPositionDefault)
            }
        }else{
            Themes.sharedInstance.ShowNotification("description is missing", false)
        }
        
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismissView(animated: true, completion: nil)
    }
    
    @IBAction func did_click_back(_ sender: UIButton) {
        self.pop(animated: true)
        
    }
    
    @IBAction func did_click_faq(_ sender: UIButton) {
        UIApplication.shared.open(URL(string: "\(SocketCreateRoomUrl)/faq")!, options:[:] , completionHandler: nil)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textview.textColor == UIColor.lightGray {
            textview.text = nil
            textview.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textview.text.isEmpty {
            textview.text = "Please describe your problem"
            textview.textColor = UIColor.lightGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

