//
//  EnterPhoneNumberViewController.swift
//
//
//  Created by CASPERON on 27/12/16.
//  Copyright © 2016 CASPERON. All rights reserved.
//

import UIKit

class EnterPhoneNumberViewController: UIViewController,SearchDelegate {
    @IBOutlet weak var oldCountry_Lbl:UITextView!
    @IBOutlet weak var newCountry_Lbl:UITextView!
    @IBOutlet weak var changeNo_Lbl:UILabel!
    
    @IBOutlet weak var oldCode_Btn: UIButton!
    @IBOutlet weak var newCode_Btn: UIButton!
    var enterPhone = EnterPhoneNumber()
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        let countryCode =  UserDefaults.standard.string(forKey: ("countryphone"))!
        //        oldCountry_Lbl.text  = "+\(countryCode)"
        //        newCountry_Lbl.text  = "+\(countryCode)"
        oldCode_Btn.setTitle("+\(countryCode)", for: UIControl.State.normal)
        newCode_Btn.setTitle("+\(countryCode)", for: UIControl.State.normal)
        // Do any additional setup after loading the view.
    }
    @IBAction func oldBtnAction(_ sender: UIButton) {
        enterPhone.btn_Tag = sender.tag
        let changeNoVC = storyboard?.instantiateViewController(withIdentifier:"SearchBarViewController" ) as! SearchBarViewController
        changeNoVC.delegate = self
        self.pushView(changeNoVC, animated: true)
        
        
    }
    func didSelectLocation(countryName: String, countryCode: String) {
        print(countryName)
        print(countryCode)
        if oldCode_Btn.tag ==  enterPhone.btn_Tag {
            oldCode_Btn.setTitle(countryCode, for: UIControl.State.normal)
        }
        else{
            newCode_Btn.setTitle(countryCode, for: UIControl.State.normal)
        }
        
        
        
    }
    
    
    
    
    
    @IBAction func backBtnAction(_ sender: UIButton){
        self.pop(animated: true)
    }
    
    override func didReceiveMemoryWarning(){
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

