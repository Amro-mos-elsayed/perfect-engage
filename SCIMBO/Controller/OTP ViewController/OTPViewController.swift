
//
//  OTPViewController.swift
//
//
//  Created by CASPERON on 29/12/16.
//  Copyright © 2016 CASPERON. All rights reserved.
//

import UIKit
import JSSAlertView
import SWMessages
import PinCodeTextField
import SDWebImage

@available(iOS 10.0, *)
class OTPViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var pin_textFld: UITextField!
    @IBOutlet weak var mob_numberFld: CustomLblFont!
    @IBOutlet weak var timer_Lbl:UILabel!
    @IBOutlet weak var nextBtn:UIButton!
    
    @IBOutlet weak var resend_button: UIButton!
    @IBOutlet weak var wrapper_view: UIView!
    var otpNo:String = String()
    var mssidn_No:String = String()
    var User_id:String = String()
    var Name:String = String()
    var status:String = String()
    var  statusList_Array = NSMutableArray()
    var isFromProduction:Bool = Bool()
    var PhNumber:String = String()
    var CountryCode:String = String()
    
    var imageUrl:String=String()
    var minute:Double = Double()
    var seconds:Double = Double()
    var timer:Timer = Timer()
    var profilePic:String = String()
    var DetailDic:NSMutableDictionary = NSMutableDictionary()
    
    //var
    var URL_handler:URLhandler = URLhandler()
    var db_Handler = DatabaseHandler()
    override func viewDidLoad() {
        super.viewDidLoad()
        mob_numberFld.text = "Please Enter Verification code sent to \(CountryCode) \(PhNumber)"
        print(otpNo)
        print(mssidn_No)
        if(isFromProduction == false){
            pin_textFld.text = otpNo
        }else{
            pin_textFld.text = ""
        }
        //print(registerParams)
        self.resend_button.setTitleColor(UIColor.lightGray, for:.normal)
        self.resend_button.isUserInteractionEnabled = false
        seconds = 60
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:  #selector(OTPViewController.updateTimerLabel), userInfo: nil, repeats: true)
        statusList_Array = ["Available","At work","At the movies","Battery About to die","Busy","Can't talk,\(Themes.sharedInstance.GetAppname()) only","In a meeting","At the gym","Sleeping","Urgent calls only"]
        
        if(status != "")
        {
            status = Themes.sharedInstance.base64ToString(status)
        }
        
        // print(signup.code)
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidLayoutSubviews()
    {
        wrapper_view.layer.cornerRadius = 3.0
        wrapper_view.clipsToBounds = true
        wrapper_view.layer.borderWidth = 1.0
        wrapper_view.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.8).cgColor
        nextBtn.layer.cornerRadius = nextBtn.frame.size.width/2
        nextBtn.clipsToBounds = true
        nextBtn.layer.borderWidth = 1.0
        nextBtn.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.8).cgColor
        
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    @IBAction func resendAction(_ sender: UIButton) {
        self.resendOTP()
    }
    
    
    func resendOTP(){
        
        let param:NSDictionary = ["msisdn":mssidn_No, "manufacturer":"Apple","OS":"ios","Version":"\(Themes.sharedInstance.osVersion)","DeviceId":Themes.sharedInstance.getDeviceToken(),"DateTime":"\(Themes.sharedInstance.current_Time)","PhNumber":self.PhNumber,"CountryCode":self.CountryCode, "callToken":Themes.sharedInstance.getCallToken()]
        
        Themes.sharedInstance.activityView(View: self.view)
        URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.RegisterNo as String, param: param, completionHandler: {(responseObject, error) ->  () in
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
                    self.otpNo = Themes.sharedInstance.CheckNullvalue(Passed_value: result["code"])
                    self.resend_button.setTitleColor(UIColor.lightGray, for:.normal)
                    self.resend_button.isUserInteractionEnabled = false
                    self.seconds = 60
                    self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:  #selector(OTPViewController.updateTimerLabel), userInfo: nil, repeats: true)
                }
                else
                {
                    self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
    
    @IBAction func nextAction(_ sender: UIButton) {
        pin_textFld.resignFirstResponder()
        print(otpNo)
        // moveHomeVC()
        if pin_textFld.text == ""{
            Themes.sharedInstance.ShowNotification("Please enter OTP number", false)
        }
        else{
            otpCalling()
        }
    }
    func otpCalling(){
        
        let param:NSDictionary = ["msisdn":mssidn_No,"code":"\(pin_textFld.text!)","manufacturer":"Apple","OS":"ios","Version":"\(Themes.sharedInstance.osVersion)","DeviceId":Themes.sharedInstance.getDeviceToken(),"DateTime":"\(Themes.sharedInstance.current_Time)","PhNumber":self.PhNumber,"CountryCode":self.CountryCode,"pushToken":self.User_id, "callToken":Themes.sharedInstance.getCallToken()]
        
        let Checkfav:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: "\(Constant.sharedinstance.Login_details)", attribute: "user_id", FetchString: Themes.sharedInstance.Getuser_id())
        if(Checkfav == false){
            let Dict:Dictionary = ["user_id":self.User_id, "login_key":String(Date().ticks), "is_updated" : "0"]
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
                let message = result["message"]
                let errNo = result["errNum"] as! String
                if errNo != "1"{
                    var image_Url = Themes.sharedInstance.CheckNullvalue(Passed_value: self.profilePic)
                    if(image_Url.substring(to: 1) == ".")
                    {
                        image_Url.remove(at: image_Url.startIndex)
                    }
                    if(image_Url != "")
                    {
                        self.imageUrl = ("\(ImgUrl)\(image_Url)")
                    }
                    else
                    {
                        self.imageUrl = ""
                    }
                    if(self.status == "")
                    {
                        self.status = "Hey there! I am using \(Themes.sharedInstance.GetAppname())"
                        
                    }
                   
                    var user_id = Themes.sharedInstance.CheckNullvalue(Passed_value: result.value(forKey: "_id"))
                    if(user_id == "")
                    {
                        user_id = self.User_id
                    }
                    else
                    {
                        self.User_id = user_id
                    }
                    
                    Themes.sharedInstance.savepublicKey(DeviceToken: "")
                    Themes.sharedInstance.savesPrivatekey(DeviceToken: "")
                    Themes.sharedInstance.savesecurityToken(DeviceToken: "")

                    let token = Themes.sharedInstance.CheckNullvalue(Passed_value: result["token"])
                    KeychainService.removePassword()
                    KeychainService.savePassword(service: user_id, data: token)
                    Themes.sharedInstance.savesecurityToken(DeviceToken: token)
                    self.DetailDic=["user_id":user_id,"status":self.status,"mobilenumber":self.mssidn_No,"name":self.Name,"profilepic":self.imageUrl,"current_call_status":"0","call_id":"","wallpaper_type" : "default", "wallpaper" : "", "status_privacy" : "0", "otp" : Themes.sharedInstance.CheckNullvalue(Passed_value: self.pin_textFld.text)]

                    DatabaseHandler.sharedInstance.InserttoDatabase(Dict:  self.DetailDic , Entityname: Constant.sharedinstance.User_detail)
                    
                    let alertview = JSSAlertView().show(self,title: Themes.sharedInstance.GetAppname(),text:"Your number has been registered successfully",buttonText: "OK",color: CustomColor.sharedInstance.alertColor)
                    alertview.addAction(self.closeCallback)
                }
                else{
                    
                    self.view.makeToast(message: message as! String, duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        })
    }
    func getDBDetails(){
        
        let detail = db_Handler.FetchFromDatabase(Entityname: Constant.sharedinstance.User_detail, attribute: "", FetchString: "user_dp",SortDescriptor: nil)
        print(detail)
    }
    
    func moveHomeVC(){
        SDWebImageDownloader.shared().setValue(Themes.sharedInstance.getToken(), forHTTPHeaderField: "authorization")
        SDWebImageDownloader.shared().setValue(Themes.sharedInstance.Getuser_id(), forHTTPHeaderField: "userid")
        SDWebImageDownloader.shared().setValue("site", forHTTPHeaderField: "requesttype")
        SDWebImageDownloader.shared().setValue(ImgUrl, forHTTPHeaderField: "referer")

        let ProfileVC = self.storyboard?.instantiateViewController(withIdentifier:"ProfileInfoID" ) as! ProfileInfoViewController
        ProfileVC.username = self.Name
        ProfileVC.msisdn=self.mssidn_No
        ProfileVC.user_id=self.User_id
        self.pushView(ProfileVC, animated: true)
    }
    @IBAction func backAction(_ sender: UIButton) {
        self.pop(animated: true)
    }
    
    @objc func updateTimerLabel(){
        //        let dMinutes: Int = Int(seconds.truncatingRemainder(dividingBy: 3600) / 60)
        //        let dSeconds: Int = Int(seconds.truncatingRemainder(dividingBy: 60))
        //        let  DurationText: String =  String(format: "%02d:%02d", dMinutes,dSeconds)
        
        if(seconds == 0)
        {
            timer_Lbl.text = "00"
            timer.invalidate()
            self.resend_button.setTitleColor(CustomColor.sharedInstance.themeColor, for: .normal)
            self.resend_button.isUserInteractionEnabled = true
        }
        else
        {
            timer_Lbl.text = "\(Int(seconds))"
        }
        seconds -= 1
    }
    
    func closeCallback() {
        self.storeStatus()
        SocketIOManager.sharedInstance.isFromLogin = false
        (UIApplication.shared.delegate as! AppDelegate).IntitialiseSocket()
        DispatchQueue.main.async {
            self.moveHomeVC()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.view.updateConstraintsIfNeeded()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func storeStatus(){
        
        if(!statusList_Array.contains(status))
        {
            statusList_Array.add(status)
        }
        
        if(statusList_Array.count > 0)
        {
            for i in 0..<statusList_Array.count
            {
                let checkStatus = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.status_List, attribute: "status_title", FetchString: statusList_Array[i] as? String)
                if(!checkStatus)
                {
                    let Dict:NSMutableDictionary=["status_id":"\(i)","status_title":statusList_Array[i]]
                    DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict, Entityname:Constant.sharedinstance.status_List)
                }
            }
        }
        SettingHandler.sharedinstance.SaveSetting(user_ID: User_id, setting_type: .notification)
        
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



