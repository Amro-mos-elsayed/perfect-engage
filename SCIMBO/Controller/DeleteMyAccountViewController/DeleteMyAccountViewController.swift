//
//  DeleteMyAccountViewController.swift
//
//
//  Created by PremMac on 11/10/17.
//  Copyright © 2017 CASPERON. All rights reserved.

import UIKit
import DropDown
import JSSAlertView

class DeleteMyAccountViewController: UIViewController {
    
    let chooseReasonDropDown = DropDown()
    lazy var dropDowns: [DropDown] = {
        return [
            self.chooseReasonDropDown
        ]
    }()
    
    @IBOutlet weak var delete_my_account: UIButton!
    @IBOutlet weak var chooseButton: UIButton!
    @IBOutlet weak var feedback: UITextField!
    @IBOutlet weak var select_reason: UILabel!
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupDropDown()
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        dropDowns.forEach{ $0.direction = .bottom }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func delete_account(_ sender: UIButton) {
        if(select_reason.text == "Select reason"){
            _ = JSSAlertView().show(self,title: Themes.sharedInstance.GetAppname(),text: "Please select a reason" ,buttonText: "OK",color: CustomColor.sharedInstance.alertColor)
        }else{
            SocketIOManager.sharedInstance.deleteAccount(from: Themes.sharedInstance.Getuser_id(), msisdn:Themes.sharedInstance.GetMyPhonenumber() , reason: select_reason.text!, messagetext: feedback.text!)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.Logout()
            })
        }
    }
    func Logout()
    {
        (UIApplication.shared.delegate as! AppDelegate).Logout()
        ChatBackUpHandler.sharedInstance.deleteBackup()
    }
    
    @IBAction func select_reason(_ sender: UIButton) {
        chooseReasonDropDown.show()
    }
    
    func setupDropDown(){
        chooseReasonDropDown.anchorView = chooseButton
        chooseReasonDropDown.bottomOffset = CGPoint(x: 0, y: chooseButton.bounds.height)
        chooseReasonDropDown.dataSource = ["Select reason","I am changing my device","I am changing my phone number","I am deleting my account temporarily","\(Themes.sharedInstance.GetAppname()) is missing a feature","\(Themes.sharedInstance.GetAppname()) is not working","Other"]
        chooseReasonDropDown.selectionAction = { [unowned self] (index, item) in
            self.select_reason.text = item
        }
    }
    @IBAction func back_action(_ sender: UIButton) {
        self.pop(animated: true)
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

