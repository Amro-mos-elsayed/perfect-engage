//
//  LoginVC.swift
//  SCIMBO
//
//  Created by Nirmal's Mac Mini on 01/07/19.
//  Copyright © 2019 CASPERON. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    @IBOutlet weak var phoneNo_txt: UITextField!
    @IBOutlet weak var countrycode_lbl: UILabel!
    @IBOutlet weak var flag_imgView: UIImageView!
    var country_Code = String()
    var phoneNo: String?
    var userEmail: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.statusBarView?.backgroundColor = CustomColor.sharedInstance.themeColor
        //NSLocalizedString("testTranslation", comment: "testLog")
        setUpPhoneNumber()
       
    }
    
    func setUpPhoneNumber() {
        phoneNo_txt.delegate = self
        Themes.sharedInstance.setCountryCode(self.countrycode_lbl, self.flag_imgView)
        country_Code = self.countrycode_lbl.text!
        if let phoneNo = phoneNo {
            phoneNo_txt.text = phoneNo
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    
    @IBAction func nextBtnAction(_ sender:UIButton) {
        self.view.endEditing(true)
        if let VC = self.storyboard?.instantiateViewController(withIdentifier: "SecondLoginVCID") as? SecondLoginVC{
            VC.phoneNo = phoneNo
            VC.userEmail = userEmail
            if self.navigationController != nil {
                self.navigationController?.pushViewController(VC, animated: false)
            }else{
                self.presentView(VC, animated: false)
            }
        }
    }
    
    @IBAction func countrycodeBtnAction(_ sender:UIButton) {
//        self.view.endEditing(true)
//        let picker = MICountryPicker()
//        picker.delegate = self
//        navigationController?.pushViewController(picker, animated: true)
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {


    }
    
}
extension LoginVC: MICountryPickerDelegate,UITextFieldDelegate {
    func countryPicker(_ picker: MICountryPicker, didSelectCountryWithName name: String, code: String) {
        picker.navigationController?.popToRootViewController(animated: true)
        picker.navigationController?.isNavigationBarHidden = true
    }
    
    func countryPicker(_ picker: MICountryPicker, didSelectCountryWithName name: String, code: String, dialCode: String,countryFlagImage:UIImage){
        picker.navigationController?.popToRootViewController(animated: true)
        countrycode_lbl.text = "\(dialCode)"
        country_Code = dialCode
        self.flag_imgView.image = countryFlagImage
        picker.navigationController?.isNavigationBarHidden = true
    }
    
}
extension UIApplication {
    var statusBarView: UIView? {
        let statusBarFrame: CGRect;
        if #available(iOS 13.0, *) {
            statusBarFrame = UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero
        } else {
            statusBarFrame = UIApplication.shared.statusBarFrame
        }
        let temp = UIView(frame: statusBarFrame)
        temp.backgroundColor = UIColor(white: 0.9, alpha: 1)
        return nil
        //        if responds(to: Selector("statusBar")) {
        //            return value(forKey: "statusBar") as? UIView
        //        }
    }
    
    
    //           statusBarView.backgroundColor = backgroundColor
    //           view.addSubview(statusBarView)
}


