//
//  NotificationViewController.swift
//
//
//  Created by CASPERON on 26/12/16.
//  Copyright © 2016 CASPERON. All rights reserved.
//

import UIKit

class NotificationViewController: UIViewController,UIScrollViewDelegate {
    @IBOutlet weak var checkBoxBtn: UIButton!
    @IBOutlet weak var notification:UILabel!
    @IBOutlet weak var conver_Tone_Lbl:UILabel!
    @IBOutlet weak var playSound_txtView:UITextView!
    @IBOutlet weak var message_Notif_Lbl:UILabel!
    @IBOutlet weak var notif_Tone_Lbl:UILabel!
    @IBOutlet weak var defaultRing_Lbl:UILabel!
    @IBOutlet weak var contact_Tone_Lbl:UILabel!
    @IBOutlet weak var noLonger_Desp:UITextView!
    @IBOutlet weak var  vibrate_Lbl:UILabel!
    @IBOutlet weak var vibrate_On_Lbl:UILabel!
    @IBOutlet weak var pop_Up_Notif:UILabel!
    @IBOutlet weak var no_Pop_Lbl:UILabel!
    @IBOutlet weak var light_Lbl:UILabel!
    @IBOutlet weak var color_Lbl:UILabel!
    @IBOutlet weak var call_Notif_Lbl:UILabel!
    @IBOutlet weak var call_Pop:UILabel!
    @IBOutlet weak var call_No_Pop:UILabel!
    @IBOutlet weak var call_Contact_Tone_Lbl:UILabel!
    @IBOutlet weak var call_NoLonger_Desp:UITextView!
    @IBOutlet weak var call_Vibrate_Lbl:UILabel!
    @IBOutlet weak var call_Vibrate_On_Lbl:UILabel!
    @IBOutlet weak var callCheck_BoxBtn: UIButton!
    
    
    
    @IBOutlet weak var notifi_ScrollView:UIScrollView!
    @IBOutlet weak var baseView:UIView!
    @IBOutlet weak var baseViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    var setImageString:NSString = NSString()
    var call_ImageString:NSString = NSString()
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        
        setImageString = "unchecked"
        call_ImageString = "unchecked"
        // Do any additional setup after loading the view.
    }
    @IBAction func checkBoxBtnAction(_ sender: Any) {
        if setImageString == "unchecked"{
            setImageString = "checked"
            checkBoxBtn.setImage(#imageLiteral(resourceName: "checkbox"), for: UIControl.State.normal)
        }
        else if setImageString == "checked"{
            setImageString = "unchecked"
            checkBoxBtn.setImage(#imageLiteral(resourceName: "uncheckbox"), for: UIControl.State.normal)
        }
        else{
            
        }
        
    }
    
    @IBAction func callCheckBtn_Action(_ sender: UIButton) {
        
        if call_ImageString == "unchecked"{
            call_ImageString = "checked"
            callCheck_BoxBtn.setImage(#imageLiteral(resourceName: "checkbox"), for: UIControl.State.normal)
        }
        else if call_ImageString == "checked"{
            call_ImageString = "unchecked"
            callCheck_BoxBtn.setImage(#imageLiteral(resourceName: "uncheckbox"), for: UIControl.State.normal)
        }
        else{
            
        }
        
        
    }
    @IBAction func backBtnAction(_ sender: Any) {
        self.pop(animated: true)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.baseViewHeight.constant = baseView.frame.height
        self.view.updateConstraintsIfNeeded()
        notifi_ScrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height:baseViewHeight.constant)
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

