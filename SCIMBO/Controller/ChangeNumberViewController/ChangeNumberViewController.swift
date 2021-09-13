//
//  ChangeNumberViewController.swift
//
//
//  Created by CASPERON on 23/12/16.
//  Copyright © 2016 CASPERON. All rights reserved.
//

import UIKit

class ChangeNumberViewController: UIViewController {
    @IBOutlet weak var change_No_lbl:UILabel!
    @IBOutlet weak var next_Btn:UIButton!
    @IBOutlet weak var changing_Descrip:UITextView!
    @IBOutlet weak var before_Descrip:UITextView!
    @IBOutlet weak var ifyouHave_Descrip:UITextView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scroll_Height: NSLayoutConstraint!
    
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
    @IBAction func backBtnAction(_ sender: Any) {
        self.pop(animated: true)
    }
    @IBAction func nextBtnAction(_ sender: UIButton) {
        let enterPhoneNoVC = storyboard?.instantiateViewController(withIdentifier:"EnterPhoneNumberViewController" ) as! EnterPhoneNumberViewController
        self.pushView(enterPhoneNoVC, animated: true)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.scroll_Height.constant = baseView.frame.height
        self.view.updateConstraintsIfNeeded()
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height:scroll_Height.constant)
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

