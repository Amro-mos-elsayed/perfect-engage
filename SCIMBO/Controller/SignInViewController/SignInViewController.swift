               //
               //  SignInViewController.swift
               //
               //
               //  Created by CASPERON on 19/12/16.
               //  Copyright © 2016 CASPERON. All rights reserved.
               //
               import UIKit
               import SwiftyJSON
               import JSSAlertView
               import Toast_Swift
               import SWMessages
               import SDWebImage
               
               class SignInViewController: UIViewController,UINavigationControllerDelegate,UITextFieldDelegate,SearchDelegate,tick{
                var istermsChecked:Bool = Bool()
                @IBOutlet weak var ChangeBtn: UIButton!
                @IBOutlet weak var signinheight: NSLayoutConstraint!
                @IBOutlet weak var signinwidth: NSLayoutConstraint!
                @IBOutlet weak var wrapper_View: UIView!
                @IBOutlet weak var Code_field: UITextField!
                @IBOutlet weak var CountryCode_field: UITextField!
                @IBOutlet weak var Check_Btn: UIButton!
                @IBOutlet weak var baseView: UIView!
                @IBOutlet weak var scrollView: TPKeyboardAvoidingScrollView!
                @IBOutlet weak var enterNOLbl:UILabel!
                @IBOutlet weak var signIn_Btn:UIButton!
                @IBOutlet weak var phoneNo_Txt:UITextField!
                var URL_handler:URLhandler = URLhandler()
                var signUp = SignUp()
                var country_Code:String = String()
                var customColor = CustomColor()
                var CodeStr:String=String()
                
                override func viewDidLoad() {
                    super.viewDidLoad()
                    SetView()
                    ChangeBtn.isHidden = Signing.Development ? false : true
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
                
                override func viewDidLayoutSubviews()
                {
                    wrapper_View.layer.cornerRadius = 3.0
                    wrapper_View.clipsToBounds = true
                    wrapper_View.layer.borderWidth = 1.0
                    wrapper_View.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.8).cgColor
                    signIn_Btn.layer.cornerRadius = signIn_Btn.frame.size.width/2
                    signIn_Btn.clipsToBounds = true
                    signIn_Btn.layer.borderWidth = 1.0
                    signIn_Btn.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.8).cgColor
                }
                func SetView()
                {
                    if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
                        print(countryCode)
                        country_Code = countryCode
                        let Code:NSArray=Themes.sharedInstance.getCountryList().object(forKey: country_Code as String) as! NSArray
                        if(Code.count > 0)
                        {
                            CodeStr=Themes.sharedInstance.CheckNullvalue(Passed_value: Code[1])
                            let CountryName:String = Themes.sharedInstance.CheckNullvalue(Passed_value: Code[0])
                            Code_field.text="\(CountryName) (+\(CodeStr))"
                            CountryCode_field.text = "+\(CodeStr)"
                            country_Code = "+\(CodeStr)"
                        }
                        else
                        {
                            CodeStr="";
                            Code_field.text="+"
                            CountryCode_field.text = "+"
                        }
                        
                    }
                }
                
                @IBAction func nextBtnAction(_ sender:UIButton) {
                    self.view.endEditing(true)
                    
                    if phoneNo_Txt.text  == "" {
                        Themes.sharedInstance.ShowNotification("Please enter mobile number", false)
                    }
                    else if ((phoneNo_Txt.text?.count)! <= 1 || (phoneNo_Txt.text?.count)! >= 30) {
                        Themes.sharedInstance.ShowNotification("Enter valid mobile number", false)
                    }
                    else  if(!istermsChecked)
                    {
                        Themes.sharedInstance.ShowNotification("Kindly accept the Terms and conditions", false)
                    }
                    else {
                        registerPhoneNo()
                    }
                }
                
                func registerPhoneNo(){
                    signIn_Btn.isUserInteractionEnabled = false
                    
                    while (phoneNo_Txt.text?.hasPrefix("0"))! {
                        phoneNo_Txt.text = phoneNo_Txt.text?.substring(from: 1)
                    }
                    
                    let param:NSDictionary = ["msisdn":"\(country_Code)\(phoneNo_Txt.text!)","manufacturer":"Apple","OS":"ios","Version":"\(Themes.sharedInstance.osVersion)","DeviceId":Themes.sharedInstance.getDeviceToken(),"DateTime":"\(Themes.sharedInstance.current_Time)","PhNumber":"\(phoneNo_Txt.text!)","CountryCode":"\(country_Code)", "callToken":Themes.sharedInstance.getCallToken()]
                    Themes.sharedInstance.activityView(View: self.view)
                    
                    
                    
                    URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.RegisterNo as String, param: param, completionHandler: {(responseObject, error) ->  () in
                        Themes.sharedInstance.RemoveactivityView(View: self.view)
                        self.signIn_Btn.isUserInteractionEnabled = true
                        
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
                                URLhandler.sharedinstance.makeGetCall(url: Constant.sharedinstance.Settings, param: [:], completionHandler: {(Object, error) ->  () in
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
                                                self.NavigateToProfileWithOutOTP(otp: Themes.sharedInstance.CheckNullvalue(Passed_value: result["code"]), mssidn_No: "\(self.country_Code)\(self.phoneNo_Txt.text!)", User_id: Themes.sharedInstance.CheckNullvalue(Passed_value: result["_id"]), profilepic: Themes.sharedInstance.CheckNullvalue(Passed_value: result["ProfilePic"]), Name: Themes.sharedInstance.CheckNullvalue(Passed_value: result["Name"]), status: Themes.sharedInstance.CheckNullvalue(Passed_value: result["Status"]), PhNumber: self.phoneNo_Txt.text!, CountryCode: self.country_Code)
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
                                                let otpVC = self.storyboard?.instantiateViewController(withIdentifier: "OTPViewController") as!  OTPViewController
                                                otpVC.otpNo = self.signUp.code
                                                otpVC.mssidn_No = "\(self.country_Code)\(self.phoneNo_Txt.text!)"
                                                otpVC.User_id =  self.signUp.user_Id
                                                otpVC.profilePic =  self.signUp.profilePic
                                                otpVC.isFromProduction = true
                                                otpVC.Name=Themes.sharedInstance.CheckNullvalue(Passed_value: result["Name"])
                                                otpVC.status=Themes.sharedInstance.CheckNullvalue(Passed_value: result["Status"])
                                                otpVC.PhNumber = self.phoneNo_Txt.text!
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
                                self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                            }
                        }
                    })
                }
                
                func NavigateToProfileWithOutOTP(otp:String, mssidn_No:String, User_id: String, profilepic: String, Name: String, status: String, PhNumber: String, CountryCode : String)
                {
                    
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
                                    status = "Hey there! I am using \(Themes.sharedInstance.GetAppname())"
                                    
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
                                
                                let DetailDic=["user_id":user_id,"status":status,"mobilenumber":mssidn_No,"name":Name,"profilepic":image_Url,"current_call_status":"0","call_id":"","wallpaper_type" : "default", "wallpaper" : "", "status_privacy" : "0", "otp" : otp] as [String : Any]
                                
                                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: DetailDic as NSDictionary, Entityname: Constant.sharedinstance.User_detail)
                                self.storeStatus(User_id: user_id, status: status)
                                SocketIOManager.sharedInstance.isFromLogin = true
                                (UIApplication.shared.delegate as! AppDelegate).IntitialiseSocket()
                                DispatchQueue.main.async {
                                    self.moveHomeVC(Name: Name, mssidn_No: mssidn_No, User_id: user_id, imageUrl: image_Url)
                                }
                            }
                        }
                    })
                }
                
                func storeStatus(User_id: String, status: String){
                    
                    var status = status
                    
                    var  statusList_Array = NSMutableArray()
                    
                    statusList_Array = ["Available","At work","At the movies","Battery About to die","Busy","Can't talk,\(Themes.sharedInstance.GetAppname()) only","In a meeting","At the gym","Sleeping","Urgent calls only"]
                    
                    if(status != "")
                    {
                        status = Themes.sharedInstance.base64ToString(status)
                        
                    }
                    if(!statusList_Array.contains(status))
                    {
                        statusList_Array.add(status)
                    }
                    if(!statusList_Array.contains("Hey there! I am using \(Themes.sharedInstance.GetAppname())")) {
                        statusList_Array.add("Hey there! I am using \(Themes.sharedInstance.GetAppname())")
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
                
                func moveHomeVC(Name : String, mssidn_No: String, User_id: String, imageUrl: String){
                    
                    SDWebImageDownloader.shared().setValue(Themes.sharedInstance.getToken(), forHTTPHeaderField: "authorization")
                    SDWebImageDownloader.shared().setValue(Themes.sharedInstance.Getuser_id(), forHTTPHeaderField: "userid")
                    SDWebImageDownloader.shared().setValue("site", forHTTPHeaderField: "requesttype")
                    SDWebImageDownloader.shared().setValue(ImgUrl, forHTTPHeaderField: "referer")
                    
                    let ProfileVC = self.storyboard?.instantiateViewController(withIdentifier:"ProfileInfoID" ) as! ProfileInfoViewController
                    ProfileVC.username = Name
                    ProfileVC.msisdn=mssidn_No
                    ProfileVC.user_id=User_id                    
                    self.pushView(ProfileVC, animated: true)
                }
                
                override var prefersStatusBarHidden: Bool {
                    return true
                }
                
                func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
                    if(textField == Code_field || textField == CountryCode_field)
                    {
                        self.MovetoSearchVC()
                        return false
                    }
                    return true
                }
                func MovetoSearchVC()
                {
                    let changeNoVC = storyboard?.instantiateViewController(withIdentifier:"SearchBarViewController" ) as! SearchBarViewController
                    changeNoVC.delegate = self
                    self.pushView(changeNoVC, animated: true)
                    
                }
                func didSelectLocation(countryName:String , countryCode:String)
                {
                    
                    if(countryCode != "")
                    {
                        CodeStr=Themes.sharedInstance.CheckNullvalue(Passed_value: countryCode)
                        let country_name = countryName.replacingOccurrences(of: "(\(CodeStr))", with: "")
                        Code_field.text="\(country_name)"
                        CountryCode_field.text = "\(CodeStr)"
                        country_Code = CodeStr
                    }
                    else
                        
                    {
                        CodeStr="";
                        Code_field.text=""
                        CountryCode_field.text = ""
                    }
                    
                    
                }
                func textFieldDidEndEditing(_ textField: UITextField) {
                    //self.resignFirstResponder()
                    textField.resignFirstResponder()
                }
                override func viewWillAppear(_ animated: Bool) {
                }
               
                func cancelCallback(){
                    
                }
                override func viewWillLayoutSubviews() {
                    super.viewWillLayoutSubviews()
                    
                    if UIScreen.main.bounds.width > 600{
                        
                        
                        
                    }
                    else{
                        
                    }
                    
                    //        phoneTxt_Leading = NSLayoutConstraint(item: phoneNo_Txt, attribute: .height, relatedBy: .equal, toItem: phoneNo_Txt, attribute: .height, multiplier: 0, Constant.sharedinstance: 30)
                    self.view.updateConstraintsIfNeeded()
                    
                }
                
                override func didReceiveMemoryWarning() {
                    super.didReceiveMemoryWarning()
                    // Dispose of any resources that can be recreated.
                }
                
                @IBAction func DidclickTermsandcondition(_ sender: Any) {
                    self.view.endEditing(true)
                    let termsAndCondition = storyboard?.instantiateViewController(withIdentifier:"TermAndConditionViewController" ) as! TermAndConditionViewController
                    termsAndCondition.delegate = self
                    self.pushView(termsAndCondition, animated: true)
                    
                    
                }
                
                /*
                 // MARK: - Navigation
                 
                 // In a storyboard-based application, you will often want to do a little preparation before navigation
                 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
                 // Get the new view controller using segue.destinationViewController.
                 // Pass the selected object to the new view controller.
                 }
                 */
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
                
                @IBAction func DidClickChangeURL(_ sender: Any) {
                    self.view.endEditing(true)
                    Themes.sharedInstance.changeURL()
                }
                
               }
               
               
