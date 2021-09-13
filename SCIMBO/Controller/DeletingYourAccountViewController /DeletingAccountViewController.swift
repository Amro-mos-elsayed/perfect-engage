//
//  DeletingAccountViewController.swift
//
//
//  Created by CASPERON on 22/12/16.
//  Copyright © 2016 CASPERON. All rights reserved.
//

import UIKit
import JSSAlertView

class DeletingAccountViewController: UIViewController,SearchDelegate {
    
    @IBOutlet weak var countryBtn:UIButton!
    @IBOutlet weak var countryCodeBtn:UIButton!
    @IBOutlet weak var changeNo_Lbl:UILabel!
    @IBOutlet weak var deletingYour:UILabel!
    @IBOutlet weak var deleteYourAcc_Lbl:UILabel!
    @IBOutlet weak var eraseYour:UILabel!
    @IBOutlet weak var deleteYou:UILabel!
    @IBOutlet weak var insteadNo_Change:UIButton!
    @IBOutlet weak var toDelete_Lbl:UILabel!
    @IBOutlet weak var countrycode_Lbl:UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var deleteMyAcc_Btn:UIButton!
    @IBOutlet weak var baseView: UIView!
    var my_phone_num:String = String()
    var country_Code:String = String()
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var phone_no: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        //let countryCode =  UserDefaults.standard.string(forKey: ("countryphone"))!
        country_Code = "+91"
        countryCodeBtn.setTitle(country_Code, for: .normal)
        //countrycode_Lbl.text  = "+\(countryCode)"
        //        if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
        //
        //            print(countryCode)
        //            country_Code = countryCode
        //        }
        self.my_phone_num = Themes.sharedInstance.GetMyPhonenumber()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func changeNum(_ sender: UIButton) {
        let enterPhoneNoVC = storyboard?.instantiateViewController(withIdentifier:"ChangeNumberViewController" ) as! ChangeNumberViewController
        self.pushView(enterPhoneNoVC, animated: true)
    }
    @IBAction func delete_account(_ sender: UIButton) {
        if("\(country_Code)\(phone_no.text!)" == my_phone_num){
            let deleteVC = storyboard?.instantiateViewController(withIdentifier:"DeleteMyAccountViewController" ) as! DeleteMyAccountViewController
            self.pushView(deleteVC, animated: true)
        }else if(phone_no.text == ""){
            _ = JSSAlertView().show(self,title: Themes.sharedInstance.GetAppname(),text: "Please enter your phone number" ,buttonText: "OK",color: CustomColor.sharedInstance.alertColor)
        }else{
            _ = JSSAlertView().show(self,title: Themes.sharedInstance.GetAppname(),text: "The phone number you entered doesn't match your account's" ,buttonText: "OK",color: CustomColor.sharedInstance.alertColor)
        }
    }
    
    @IBAction func back_button(_ sender: UIButton) {
        self.pop(animated: true)
    }
    
    //    func setCountry(){
    //        if Singleton.sharedInstance.countryName != "" {
    //        countryBtn.setTitle(Singleton.sharedInstance.countryName, for: UIControlState.normal)
    //        countryCodeBtn.setTitle(Singleton.sharedInstance.countryCode, for: UIControlState.normal)
    //        }
    //
    //    }
    @IBAction func selectCountryAction(_ sender: UIButton) {
        let changeNoVC = storyboard?.instantiateViewController(withIdentifier:"SearchBarViewController" ) as! SearchBarViewController
        changeNoVC.delegate = self
        self.pushView(changeNoVC, animated: true)
    }
    
    func didSelectLocation(countryName: String, countryCode: String) {
        print(countryName)
        print(countryCode)
        country_Code = countryCode
        countryBtn.setTitle(countryName, for: UIControl.State.normal)
        countryCodeBtn.setTitle(countryCode, for: UIControl.State.normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

