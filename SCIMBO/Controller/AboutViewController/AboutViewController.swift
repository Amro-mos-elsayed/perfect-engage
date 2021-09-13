//
//  AboutViewController.swift
//
//
//  Created by CASPERON on 21/12/16.
//  Copyright © 2016 CASPERON. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var about_Lbl:UILabel!
    @IBOutlet weak var aboutTableView:UITableView!
    
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    var optionsArray:NSArray = NSArray()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        
        let nibName = UINib(nibName: "AboutTableViewCell", bundle: nil)
        aboutTableView.register(nibName, forCellReuseIdentifier: "AboutTableViewCell")
        aboutTableView.tableFooterView = UIView()
        optionsArray = [/*NSLocalizedString("FAQ", comment: "FAQ"),*/NSLocalizedString("Contact Us", comment: "Contact Us") , NSLocalizedString("System Status", comment: "System Status")/*,NSLocalizedString("Terms and Privacy Policy", comment: "Terms and Privacy Policy") */, NSLocalizedString("About", comment: "About")]
        aboutTableView.estimatedRowHeight = 75
        // Do any additional setup after loading the view.
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return  optionsArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:AboutTableViewCell = aboutTableView.dequeueReusableCell(withIdentifier: "AboutTableViewCell") as! AboutTableViewCell
        
        cell.options_Lbl.text = optionsArray[indexPath.row] as? String
        if indexPath.row == 1
        {
            cell.needHelp_Lbl.isHidden  = false
        }
        else
        {
            cell.needHelp_Lbl.isHidden  = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if(indexPath.row == 0){
//            UIApplication.shared.open(URL(string: SocketCreateRoomUrl + "/faq")!, options: [:], completionHandler: nil)
//        }
//        else if(indexPath.row == 3){
//            UIApplication.shared.open(URL(string: SocketCreateRoomUrl + "/privacy-policy")!, options: [:], completionHandler: nil)
//        }
        if(indexPath.row == 1){
            let systemStatus = storyboard?.instantiateViewController(withIdentifier: "SystemStatusViewController") as! SystemStatusViewController
            self.pushView(systemStatus, animated: true)
        }else if(indexPath.row == 0){
            let contact = storyboard?.instantiateViewController(withIdentifier: "ContactUsViewController") as! ContactUsViewController
            
            self.pushView(contact, animated: true)
        }else if(indexPath.row == 2){
            let about = storyboard?.instantiateViewController(withIdentifier: "AboutPageViewController") as! AboutPageViewController
            self.pushView(about, animated: true)
        }
    }
    
    @IBAction func backBtnAction(_ sender: Any) {
        self.navigationController?.pop(animated:true )
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

