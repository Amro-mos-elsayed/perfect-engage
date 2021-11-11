//
//  FullLoginViewController.swift
//  Raad
//
//  Created by Ahmed Labeeb on 9/28/21.
//  Copyright © 2021 CASPERON. All rights reserved.
//

import UIKit
import SwiftyJSON
import JSSAlertView
import Toast_Swift
import SWMessages
import SDWebImage



class FullLoginViewController: UIViewController {
    
    @IBOutlet var borderedViews: [UIView]!
    @IBOutlet weak var CountryFlag: UIImageView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var userNameView: UIView!
    @IBOutlet weak var userMobileView: UIView!
    @IBOutlet weak var CountryCode: UILabel!
    @IBOutlet weak var MobileTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var BottomViewBottom: NSLayoutConstraint!
    var keyboardheight : CGFloat = 0.0
    var URL_handler:URLhandler = URLhandler()
    var signUp = SignUp()
    var country_Code:String = String()
    var phoneNo: String?
    var userEmail: String?
    var userName: String?
    var customColor = CustomColor()
    var loginTypeEmployee: Bool = true
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        country_Code = self.CountryCode.text!
        if userEmail == "alabeeb@2p.com.sa" {
            self.CountryCode.text = "+20"
            country_Code = self.CountryCode.text!
        }
        
        if let phoneNo = phoneNo {
            MobileTextField.text = phoneNo
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ContactHandler.sharedInstance.GetPermission()
        self.SetUI()
        self.listenToKeyboard()
        emailView.isHidden = !loginTypeEmployee
        userNameView.isHidden = !loginTypeEmployee
        MobileTextField.keyboardType = .asciiCapableNumberPad
    }
    
    func listenToKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    
    @objc func keyboardWillShow(_ notification: Notification) {
        let keyboardHeight = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        BottomViewBottom.constant = keyboardHeight
        print(keyboardHeight)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        BottomViewBottom.constant = 0
    }
    
    
    func SetUI(){
        emailTextField.isUserInteractionEnabled = false
        userNameTextField.isUserInteractionEnabled = false
        MobileTextField.isUserInteractionEnabled = loginTypeEmployee ? false : true
        if !loginTypeEmployee {
            MobileTextField.backgroundColor = .clear
            userMobileView.backgroundColor = .clear
        }
        
        emailTextField.text = self.userEmail
        MobileTextField.placeholder = "Enter your mobile number".localized()
        MobileTextField.textAlignment = .natural
        userNameTextField.text = userName
        CountryCode.adjustsFontSizeToFitWidth = true
        Themes.sharedInstance.setCountryCode(CountryCode,CountryFlag)
        
        borderedViews.forEach { view in
            view.layer.cornerRadius = 25
            view.layer.borderWidth = 1
            view.layer.borderColor = UIColor.lightGray.cgColor
            if view is UIButton {
                view.layer.borderWidth = 0
            }
        }
        let tap: UIGestureRecognizer = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
               
    @objc func keyboardWillShow(notification: Notification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        keyboardheight = keyboardRectangle.height
        BottomViewBottom.constant = keyboardheight
    }
    
    @IBAction func didclickCountry(_ sender: Any) {
        let  country = MICountryPicker()
        country.delegate = self
        country.showCallingCodes = true
        if let navigator = self.navigationController
        {
            navigator.pushViewController(country, animated: true)
        }
    }
    
    func registerPhoneNo(){
        
        while (MobileTextField.text?.hasPrefix("0"))! {
            MobileTextField.text = MobileTextField.text?.substring(from: 1)
        }
        let param:NSDictionary = ["msisdn":"\(country_Code)\(MobileTextField.text!)","manufacturer":"Apple","OS":"ios","Version":"\(Themes.sharedInstance.osVersion)","DeviceId":Themes.sharedInstance.getDeviceToken(),"DateTime":"\(Themes.sharedInstance.current_Time)","PhNumber":"\(MobileTextField.text!)","CountryCode":"\(country_Code)", "callToken":Themes.sharedInstance.getCallToken()]
        Themes.sharedInstance.activityView(View: self.view)
        
        let url = loginTypeEmployee ? Constant.sharedinstance.RegisterNo : Constant.sharedinstance.RegisterGuestNo
        URLhandler.sharedinstance.makeCall(url:url as String, param: param, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            if(error != nil)
            {
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                
                print(error ?? "defaultValue")
                
            }
            else{
                print(responseObject ?? "response")
                let result = responseObject! as NSDictionary
                let errNo = result["errNum"] as! String
                let message = result["message"]
                if errNo == "0"{
                    self.appDelegate().pushnotificationSetup()
                    URLhandler.sharedinstance.makeGetCall(url: Constant.sharedinstance.Settings, param: [:], completionHandler: { [self](Object, error) ->  () in
                        if(error != nil)
                        {
                            self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                            print(error ?? "defaultValue")
                            
                        }
                        else{
                            print(Object ?? "response")
                            let setting_result = Object! as NSDictionary
                            let message = setting_result["message"]
                            let live = "\(String(describing: setting_result["live"]!))"
                            let twilio = setting_result["twilio"] as! String
                            
                            if errNo == "0"{
                                
                                if(live == "0" || twilio == "development"){
                                    self.NavigateToProfileWithOutOTP(otp: Themes.sharedInstance.CheckNullvalue(Passed_value: result["code"]), mssidn_No: "\(self.country_Code)\(self.MobileTextField.text!)", User_id: Themes.sharedInstance.CheckNullvalue(Passed_value: result["_id"]), profilepic: Themes.sharedInstance.CheckNullvalue(Passed_value: result["ProfilePic"]), Name: Themes.sharedInstance.CheckNullvalue(Passed_value: result["Name"]), status: Themes.sharedInstance.CheckNullvalue(Passed_value: result["Status"]), PhNumber: self.MobileTextField.text!, CountryCode: self.country_Code)
                                }
                                else{
                                    self.signUp.code =  Themes.sharedInstance.CheckNullvalue(Passed_value: result["code"] as AnyObject?)
                                    //print(self.signUp.code)
                                    self.signUp.user_Id =  Themes.sharedInstance.CheckNullvalue(Passed_value: result["_id"] as AnyObject?)
                                    UserDefaults.standard.set(self.signUp.user_Id, forKey: "id")
                                    print(self.signUp.user_Id)
                                    
                                    self.signUp.profilePic = Themes.sharedInstance.CheckNullvalue(Passed_value: result["ProfilePic"]as AnyObject?)
                                    self.signUp.status = Themes.sharedInstance.CheckNullvalue(Passed_value: result["Status"] as AnyObject?)
                                    let CheckLogin:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.User_detail, attribute: "user_id", FetchString: nil)
                                    if(CheckLogin)
                                    {
                                        DatabaseHandler.sharedInstance.truncateDataForTable(Entityname: Constant.sharedinstance.User_detail)
                                    }
                                    var userName: String
                                    if loginTypeEmployee {
                                        userName = userNameTextField.text!
                                    }else{
                                        userName = Themes.sharedInstance.CheckNullvalue(Passed_value: result["Name"])
                                    }
                                    
                                    
                                    let otpVC = SWCC_OTPViewController.init()
                                    otpVC.otpNo = self.signUp.code
                                    otpVC.mssidn_No = "\(self.country_Code)\(self.MobileTextField.text!)"
                                    otpVC.User_id =  self.signUp.user_Id
                                    otpVC.profilePic =  self.signUp.profilePic
                                    otpVC.isFromProduction = true
                                    otpVC.Name=userName
                                    otpVC.userEmail = self.userEmail
                                    otpVC.status=Themes.sharedInstance.CheckNullvalue(Passed_value: result["Status"])
                                    otpVC.PhNumber = self.MobileTextField.text!
                                    otpVC.CountryCode = self.country_Code
                                    self.pushView(otpVC, animated: true)
                                    
                                }
                            }
                            else
                            {
                                self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                            }
                        }
                    })
                }
                else
                {
                    Themes.sharedInstance.ShowNotification(message as! String , false)
                }
            }
        })
    }
    func NavigateToProfileWithOutOTP(otp:String, mssidn_No:String, User_id: String, profilepic: String, Name: String, status: String, PhNumber: String, CountryCode : String)
    {
        var finalUserName = userNameTextField.text!
        if finalUserName == ""{
            finalUserName = Name
        }
        let param:NSDictionary = ["code":otp,"msisdn":mssidn_No,"manufacturer":"Apple","OS":"ios","Version":"\(Themes.sharedInstance.osVersion)","DeviceId":Themes.sharedInstance.getDeviceToken(),"DateTime":"\(Themes.sharedInstance.current_Time)","PhNumber":PhNumber,"CountryCode":CountryCode,"pushToken":User_id, "callToken":Themes.sharedInstance.getCallToken()]
        
        let Checkfav:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: "\(Constant.sharedinstance.Login_details)", attribute: "user_id", FetchString: Themes.sharedInstance.Getuser_id())
        if(Checkfav == false){
            let Dict:Dictionary = ["user_id":User_id, "login_key":String(Date().ticks), "is_updated" : "0"]
            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict as NSDictionary, Entityname: Constant.sharedinstance.Login_details)
        }
        
        Themes.sharedInstance.activityView(View: self.view)
        URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.confirmOTP as String, param: param, completionHandler: {(responseObject, error) ->  () in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            
            if(error != nil)
            {
                print(error ?? "defaultValue")
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                
            }
            else{
                
                print(responseObject ?? "response")
                
                let result = responseObject! as NSDictionary
                let errNo = result["errNum"] as! String
                if errNo != "1"{
                    var image_Url = Themes.sharedInstance.CheckNullvalue(Passed_value: profilepic)
                    print("\(image_Url.count)")
                    print("\(image_Url.length)")
                    if(image_Url.substring(to: 1) == ".")
                    {
                        image_Url.remove(at: image_Url.startIndex)
                    }
                    if(image_Url != "")
                    {
                        image_Url = ("\(ImgUrl)\(image_Url)")
                    }
                    else
                    {
                        image_Url = ""
                    }
                    var status = status
                    if(status == "")
                    {
                        status = NSLocalizedString("Online", comment: "note" )
                        
                    }
                    
                    
                    var user_id = Themes.sharedInstance.CheckNullvalue(Passed_value: result.value(forKey: "_id"))
                    if(user_id == "")
                    {
                        user_id = User_id
                    }
                    
                    Themes.sharedInstance.savepublicKey(DeviceToken: "")
                    Themes.sharedInstance.savesPrivatekey(DeviceToken: "")
                    Themes.sharedInstance.savesecurityToken(DeviceToken: "")
                    
                    
                    
                    let token = Themes.sharedInstance.CheckNullvalue(Passed_value: result["token"])
                    KeychainService.removePassword()
                    KeychainService.savePassword(service: user_id, data: token)
                    Themes.sharedInstance.savesecurityToken(DeviceToken: token)
                    
                    let email = self.userEmail ?? Themes.sharedInstance.CheckNullvalue(Passed_value: result["Email"])
                    let isShowNumber = Themes.sharedInstance.CheckNullvalue(Passed_value: result["showNumber"])
                    let DetailDic=["user_id":user_id,"status":status,"mobilenumber":mssidn_No,"name":finalUserName,"profilepic":image_Url,"current_call_status":"0","call_id":"","wallpaper_type" : "default", "wallpaper" : "", "status_privacy" : "0", "otp" : otp, "email" : email,"showNumber": isShowNumber] as [String : Any]
                    
                    DatabaseHandler.sharedInstance.InserttoDatabase(Dict: DetailDic as NSDictionary, Entityname: Constant.sharedinstance.User_detail)
                    self.storeStatus(User_id: user_id, status: status)
                    SocketIOManager.sharedInstance.isFromLogin = true
                    (UIApplication.shared.delegate as! AppDelegate).IntitialiseSocket()
                    DispatchQueue.main.async {
                        self.moveHomeVC(Name: finalUserName, mssidn_No: mssidn_No, User_id: user_id, imageUrl: image_Url, email: email)
                    }
                }
            }
        })
    }
    func storeStatus(User_id: String, status: String){
        
        var status = status
        let app = Themes.sharedInstance.GetAppname()
        var  statusList_Array = NSMutableArray()
        
        statusList_Array = [NSLocalizedString("Online", comment: "ava"),
                            NSLocalizedString("Away", comment: "ava"),
                            NSLocalizedString("Busy", comment: "ava"),
                            NSLocalizedString("In a meeting", comment: "ava") ,
                            NSLocalizedString("Do not disturb", comment: "ava") ,
                            NSLocalizedString("Business trip", comment: "ava") ,
                            NSLocalizedString("On vacation", comment: "ava"),
                            NSLocalizedString("Offline", comment: "ava")]
        
        if(status != "")
        {
            status = Themes.sharedInstance.base64ToString(status)
            
        }
        if(!statusList_Array.contains(status))
        {
            statusList_Array.add(status)
        }
        let appName = NSLocalizedString("Online", comment: "test")
        if(!statusList_Array.contains(appName)) {
            statusList_Array.add(appName)
        }
        
        if(statusList_Array.count > 0)
        {
            for i in 0..<statusList_Array.count
            {
                let Dict:NSMutableDictionary=["status_id":"\(i)","status_title":statusList_Array[i]]
                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict, Entityname:Constant.sharedinstance.status_List)
            }
        }
        SettingHandler.sharedinstance.SaveSetting(user_ID: User_id, setting_type: .notification)
    }
    
    func moveHomeVC(Name : String, mssidn_No: String, User_id: String, imageUrl: String, email: String){
        
        SDWebImageDownloader.shared().setValue(Themes.sharedInstance.getToken(), forHTTPHeaderField: "authorization")
        SDWebImageDownloader.shared().setValue(Themes.sharedInstance.Getuser_id(), forHTTPHeaderField: "userid")
        SDWebImageDownloader.shared().setValue("site", forHTTPHeaderField: "requesttype")
        SDWebImageDownloader.shared().setValue(ImgUrl, forHTTPHeaderField: "referer")
        
        UpdateUserInfo(name: Name, imagedata: "", base64data: "", email: email)
    }
    
    func UpdateUserInfo(name:String,imagedata:String,base64data:String, email: String)
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            SocketIOManager.sharedInstance.changeName(name: Themes.sharedInstance.CheckNullvalue(Passed_value: name), from: Themes.sharedInstance.Getuser_id(), email: Themes.sharedInstance.CheckNullvalue(Passed_value: email))
                
        let updateDict=["name":Themes.sharedInstance.CheckNullvalue(Passed_value: name), "email":Themes.sharedInstance.CheckNullvalue(Passed_value: email)]
        
        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail, FetchString: Themes.sharedInstance.Getuser_id(), attribute: "user_id", UpdationElements: updateDict as NSDictionary?)
        SocketIOManager.sharedInstance.isFromLogin = false
        SocketIOManager.sharedInstance.EmitforGetOfflineDetails(Nickname: Themes.sharedInstance.Getuser_id() as NSString)
        }
        (UIApplication.shared.delegate as! AppDelegate).MovetoRooVC()
    }
    
    
    @IBAction func didclickNextButton(_ sender: Any) {
        
        if isValidFields() {
            registerPhoneNo()
        }
    }
    func isValidFields() -> Bool {
        if self.MobileTextField.text  == "" {
            Themes.sharedInstance.ShowNotification("Please enter mobile number".localized(), false)
            return false
        }
        if ((self.MobileTextField.text?.count)! <= 1 || (self.MobileTextField.text?.count)! >= 30) {
            Themes.sharedInstance.ShowNotification("Please enter a valid mobile number".localized(), false)
            return false
        }

        if(userNameTextField.text?.removingWhitespaces() == "" && loginTypeEmployee) {
            Themes.sharedInstance.ShowNotification("Please enter your name".localized(), false)
            return false
        }
        
        return true
    }
    
    
    @IBAction func didclickCancelButton(_ sender: Any) {
        self.pop(animated: false)
    }
    
    func appDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
}

extension FullLoginViewController: MICountryPickerDelegate {
    func countryPicker(_ picker: MICountryPicker, didSelectCountryWithName name: String, code: String) {
        
    }
    
    func countryPicker(_ picker: MICountryPicker, didSelectCountryWithName name: String, code: String, dialCode: String, countryFlagImage: UIImage) {
        CountryCode.text = dialCode
        country_Code = dialCode
        CountryFlag.image = countryFlagImage
        picker.pop(animated: false)
        MobileTextField.becomeFirstResponder()
    }
}

