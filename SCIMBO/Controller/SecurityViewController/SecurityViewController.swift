//
//  SecurityViewController.swift
//
//
//  Created by CASPERON on 22/12/16.
//  Copyright © 2016 CASPERON. All rights reserved.
//

import UIKit

class SecurityViewController: UIViewController {
    @IBOutlet weak var security_Lbl:UILabel!
    @IBOutlet weak var whenPossible_TxtView:UITextView!
    @IBOutlet weak var learn_More_Btn:UIButton!
    @IBOutlet weak var show_Security_Lbl:UILabel!
    @IBOutlet weak var turn_On_TxtView:UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.pop(animated: true)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.view.updateConstraintsIfNeeded()
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


