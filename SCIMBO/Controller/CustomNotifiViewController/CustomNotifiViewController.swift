//
//  CustomNotifiViewController.swift
//
//
//  Created by CASPERON on 09/02/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit

class CustomNotifiViewController: UIViewController {
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
    @IBAction func messageNotifyAction(_ sender: UIButton) {
        
        let  notifiListVC = storyboard?.instantiateViewController(withIdentifier: "NotificationListViewController") as! NotificationListViewController
        self.pushView(notifiListVC, animated: true)
    }
    
    @IBAction func backAction(_ sender: UIButton) {
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

