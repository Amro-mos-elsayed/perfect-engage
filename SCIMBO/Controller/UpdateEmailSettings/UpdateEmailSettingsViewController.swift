//
//  UpdateEmailSettingsViewController.swift
//
//
//  Created by PremMac on 08/11/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit
import SWMessages
protocol openLock : class {
    func openLock(updated : Bool, id : String, type : String)
}
class UpdateEmailSettingsViewController: UIViewController,SocketIOManagerDelegate,UITextFieldDelegate {
    
    @IBOutlet weak var check_box: UIButton!
    @IBOutlet weak var box_textview: UITextView!
    @IBOutlet weak var next_button: UIButton!
    @IBOutlet weak var recovery_phone: UITextField!
    @IBOutlet weak var recovery_email: UITextField!
    @IBOutlet weak var email: UITextField!
    var settings_changed:Bool = false
    var isterms:Bool = false
    var email_verify:Bool = false
    var recovery_mail_verify:Bool = false
    var phone_verify:Bool  = false
    weak var delegate:openLock!
    @IBOutlet weak var check_btn: UIButton!
    @IBOutlet weak var scrollView: TPKeyboardAvoidingScrollView!
    @IBOutlet weak var phone_check: UIButton!
    @IBOutlet weak var recovery_email_check: UIButton!
    @IBOutlet weak var email_check: UIButton!
    @IBOutlet weak var sub_view: UIView!
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var EmailReach: UITextView!
    @IBOutlet weak var RecoveryEmail: UITextView!
    
    @IBOutlet weak var RecoveryPhone: UITextView!
    var id = String()
    var type = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        EmailReach.text = NSLocalizedString("Your email is used to reach you incase you accidentally get locked out", comment: "note")
        RecoveryEmail.text = NSLocalizedString("Your recovery e-mail is used to reach you incase we detect unusual activity in your account or you accidentally get locked out", comment: "note")
        RecoveryPhone.text = NSLocalizedString("Your recovery phone is used to reach you incase we detect unusual activity in your account or you accidentally get locked out", comment: "note")
        //
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        addNotificationListener()
        check_box.isHidden = true
        box_textview.isHidden = true
        SocketIOManager.sharedInstance.Delegate = self
        reloadData()
    }
    func reloadData(){
        let lockChats:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.User_detail, attribute: "user_id", FetchString: Themes.sharedInstance.Getuser_id(), SortDescriptor: nil) as! NSArray
        var email:String = ""
        var recovery_email:String = ""
        var recovery_phone:String = ""
        if(lockChats.count > 0){
            for i in 0..<lockChats.count{
                let response = lockChats[i] as! NSManagedObject
                email = Themes.sharedInstance.CheckNullvalue(Passed_value: response.value(forKey: "email"))
                recovery_email = Themes.sharedInstance.CheckNullvalue(Passed_value: response.value(forKey: "recovery_email"))
                recovery_phone = Themes.sharedInstance.CheckNullvalue(Passed_value: response.value(forKey: "recovery_phone"))
            }
        }
        
        self.email.placeholder = NSLocalizedString("Enter Email id", comment: "not")
        self.recovery_email.placeholder = NSLocalizedString("Recovery Email id", comment: "not")
        self.recovery_phone.placeholder = NSLocalizedString("Recovery Mobile No.", comment: "not")

        if(email != "")
        {
            self.email.text = email
            self.email.isUserInteractionEnabled = false
            email_check.setImage(#imageLiteral(resourceName: "btn_double_tick-1"), for: .normal)
            email_verify = true
        }
        if(recovery_email != "")
        {
            self.recovery_email.text = recovery_email
            self.recovery_email.isUserInteractionEnabled = false
            recovery_email_check.setImage(#imageLiteral(resourceName: "btn_double_tick-1"), for: .normal)
            recovery_mail_verify = true
        }
        if(recovery_phone != "")
        {
            self.recovery_phone.text = recovery_phone
            self.recovery_phone.isUserInteractionEnabled = false
            phone_check.setImage(#imageLiteral(resourceName: "btn_double_tick-1"), for: .normal)
            phone_verify = true
        }
        
        if(email_verify && recovery_mail_verify && phone_verify)
        {
            next_button.setTitle(NSLocalizedString("Change Settings", comment:"note") , for:.normal)
            settings_changed = true
        }
        else
        {
            next_button.setTitle(NSLocalizedString("Next", comment:"note"), for:.normal)
            settings_changed = false
        }
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if(textField.tag == 0){
            if(SocketIOManager.sharedInstance.socket.status == .connected)
            {
                if(Themes.sharedInstance.isValidEmail(testStr: email.text!) == false){
                    Themes.sharedInstance.ShowNotification("Enter valid email id", false)
                }else{
                    Themes.sharedInstance.activityView(View: self.view)
                    SocketIOManager.sharedInstance.change_mail(from: Themes.sharedInstance.Getuser_id(), email: email.text!)
                }
                
            }else{
                Themes.sharedInstance.RemoveactivityView(View: self.view)
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage, duration: 3, position: HRToastActivityPositionDefault)
            }
        }else if(textField.tag == 1){
            if(SocketIOManager.sharedInstance.socket.status == .connected)
            {
                if(Themes.sharedInstance.isValidEmail(testStr: recovery_email.text!) == false){
                    Themes.sharedInstance.ShowNotification("Enter valid email id", false)
                }else{
                    Themes.sharedInstance.activityView(View: self.view)
                    SocketIOManager.sharedInstance.recovery_mail(from: Themes.sharedInstance.Getuser_id(), recovery_email: recovery_email.text!)
                }
            }else{
                Themes.sharedInstance.RemoveactivityView(View: self.view)
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage, duration: 3, position: HRToastActivityPositionDefault)
            }
        }else if(textField.tag == 2){
            if(SocketIOManager.sharedInstance.socket.status == .connected)
            {
                if(Themes.sharedInstance.isValidPhNo(value: recovery_phone.text!) == false){
                    Themes.sharedInstance.ShowNotification("Enter valid mobile number", false)
                }else{
                    Themes.sharedInstance.activityView(View: self.view)
                    SocketIOManager.sharedInstance.recovery_phone(from: Themes.sharedInstance.Getuser_id(), recovery_phone: recovery_phone.text!)
                }
            }else{
                Themes.sharedInstance.RemoveactivityView(View: self.view)
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage, duration: 3, position: HRToastActivityPositionDefault)
            }
        }
    }
    
    @IBAction func updateField(_ sender: UIButton)
    {
        if(sender.tag == 0){
            if(SocketIOManager.sharedInstance.socket.status == .connected)
            {
                if(Themes.sharedInstance.isValidEmail(testStr: email.text!) == false){
                    Themes.sharedInstance.ShowNotification("Enter valid email id", false)
                }else{
                    Themes.sharedInstance.activityView(View: self.view)
                    SocketIOManager.sharedInstance.change_mail(from: Themes.sharedInstance.Getuser_id(), email: email.text!)
                }
                
            }else{
                Themes.sharedInstance.RemoveactivityView(View: self.view)
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage, duration: 3, position: HRToastActivityPositionDefault)
            }
        }else if(sender.tag == 1){
            if(SocketIOManager.sharedInstance.socket.status == .connected)
            {
                if(Themes.sharedInstance.isValidEmail(testStr: recovery_email.text!) == false){
                    Themes.sharedInstance.ShowNotification("Enter valid email id", false)
                }else{
                    Themes.sharedInstance.activityView(View: self.view)
                    SocketIOManager.sharedInstance.recovery_mail(from: Themes.sharedInstance.Getuser_id(), recovery_email: recovery_email.text!)
                }
            }else{
                Themes.sharedInstance.RemoveactivityView(View: self.view)
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage, duration: 3, position: HRToastActivityPositionDefault)
            }
        }else if(sender.tag == 2){
            if(SocketIOManager.sharedInstance.socket.status == .connected)
            {
                if(Themes.sharedInstance.isValidPhNo(value: recovery_phone.text!) == false){
                    Themes.sharedInstance.ShowNotification("Enter valid mobile number", false)

                }else{
                    Themes.sharedInstance.activityView(View: self.view)
                    SocketIOManager.sharedInstance.recovery_phone(from: Themes.sharedInstance.Getuser_id(), recovery_phone: recovery_phone.text!)
                }
            }else{
                Themes.sharedInstance.RemoveactivityView(View: self.view)
                self.view.makeToast(message: Constant.sharedinstance.ErrorMessage, duration: 3, position: HRToastActivityPositionDefault)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scrollView.contentSize = CGSize(width: self.sub_view.frame.size.width, height: 500)
    }
    func changeStatus(_ notify: Notification){
        Themes.sharedInstance.RemoveactivityView(View: self.view)
        if let ResponseDict = notify.userInfo {
            if(ResponseDict.count > 0){
                let status:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict["type"] as AnyObject)
                if(status == "email"){
                    Themes.sharedInstance.ShowNotification("Email id updated successfully", true)
                }else if(status == "recovery_email"){
                    Themes.sharedInstance.ShowNotification("Alternate Email id updated successfully", true)
                }else if(status == "recovery_phone"){
                    Themes.sharedInstance.ShowNotification("Recovery Phone number updated successfully", true)
                }else if(status == "recovery email not same"){
                    Themes.sharedInstance.ShowNotification("Email and Alternate mail same", false)
                }
            }
        }
    }
    
    @IBAction func check_click(_ sender: UIButton) {
        if(isterms == false){
            isterms = true
            check_btn.setImage(#imageLiteral(resourceName: "check"), for: .normal)
        }else{
            isterms = false
            check_btn.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
        }
    }
    @IBAction func next_action(_ sender: UIButton) {
        if(settings_changed == true){
            email_verify = false
            recovery_mail_verify = false
            phone_verify = false
            self.email.isUserInteractionEnabled = true
            self.recovery_email.isUserInteractionEnabled = true
            self.recovery_phone.isUserInteractionEnabled = true
            self.email.text = ""
            self.recovery_email.text = ""
            self.recovery_phone.text = ""
            self.email.placeholder = NSLocalizedString("Enter Email id", comment: "not")
            self.recovery_email.placeholder = NSLocalizedString("Recovery Email id", comment: "not")
            self.recovery_phone.placeholder = NSLocalizedString("Recovery Mobile No.", comment: "not")
            next_button.setTitle(NSLocalizedString("Next", comment: "not") , for:.normal)
            email_check.setImage(#imageLiteral(resourceName: "btn_singlr_tick-1"), for: .normal)
            recovery_email_check.setImage(#imageLiteral(resourceName: "btn_singlr_tick-1"), for: .normal)
            phone_check.setImage(#imageLiteral(resourceName: "btn_singlr_tick-1"), for: .normal)
            settings_changed = false
        }else{
            if(email_verify == true && recovery_mail_verify == true && phone_verify == true){
                
                next_button.setTitle("Change Settings", for:.normal)
                settings_changed = true
                Themes.sharedInstance.ShowNotification("Email setting updated successfully", true)                
                self.pop(animated: true)
                if(self.delegate != nil)
                {
                    self.delegate.openLock(updated: true, id: self.id, type: self.type)
                }
            }else{
                Themes.sharedInstance.ShowNotification("Please update settings", false)
            }
        }
        
    }
    
    @IBAction func back_action(_ sender: UIButton) {
        self.pop(animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func addNotificationListener() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            weak.changeStatus(notify)
            weak.reloadData()
        }
    }
    
    func removeNotificationListener() {
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        removeNotificationListener()
    }

}
