//
//  AboutPageViewController.swift
//
//
//  Created by Prem Mac on 19/01/18.
//  Copyright © 2018 CASPERON. All rights reserved.
//

import UIKit

class AboutPageViewController: UIViewController {
    
    @IBOutlet weak var lblversion: UILabel!
    @IBOutlet weak var about_page_tail: UILabel!
    @IBOutlet weak var about_page_header: UILabel!
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        
        about_page_header.text = Themes.sharedInstance.GetAppname()
        about_page_tail.text = "© 2020 \(Themes.sharedInstance.GetAppname()) LLC"
        lblversion.text = "Version \(Themes.sharedInstance.getAppVersion())"
        // Do any additional setup after loading the view.
    }
    
    @IBAction func did_click_back(_ sender: UIButton) {
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

