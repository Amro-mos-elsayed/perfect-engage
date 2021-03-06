//
//  AccountViewController.swift
//
//
//  Created by CASPERON on 21/12/16.
//  Copyright © 2016 CASPERON. All rights reserved.
//

import UIKit
import JSSAlertView
class AccountViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    @IBOutlet weak var account_TblView:UITableView!
    @IBOutlet weak var account_Lbl:UILabel!
    @IBOutlet weak var logoutView:UIView!
    
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    var optionsArray:NSArray = NSArray()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        
        let nibName = UINib(nibName: "AccountTableViewCell", bundle: nil)
        account_TblView.register(nibName, forCellReuseIdentifier:"AccountTableViewCell")
        account_TblView.estimatedRowHeight = 72
        account_TblView.tableFooterView = UIView()
        optionsArray = []//NSLocalizedString("Privacy", comment: "note")]
       // optionsArray = ["Privacy","Delete my account"]
        // Do any additional setup after loading the view.
    }
    override func viewDidLayoutSubviews() {
        logoutView.layer.cornerRadius = logoutView.frame.height / 2
        logoutView.clipsToBounds = true
        logoutView.dropShadow(shadowRadius: 8)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return optionsArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:AccountTableViewCell = tableView.dequeueReusableCell(withIdentifier: "AccountTableViewCell") as! AccountTableViewCell
        cell.optionas_Lbl.text = optionsArray[indexPath.row] as? String
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            let  privacyVC = storyboard?.instantiateViewController(withIdentifier: "PrivacyViewController") as! PrivacyViewController
            self.pushView(privacyVC, animated: true)
            
            
        }
        else if indexPath.row == 1{
            let deletingVC = storyboard?.instantiateViewController(withIdentifier: "DeletingAccountViewController") as! DeletingAccountViewController
            self.pushView(deletingVC, animated: true)
            
            
        }
        else if indexPath.row == 2{
            let securityVC = storyboard?.instantiateViewController(withIdentifier: "SecurityViewController") as! SecurityViewController
            self.pushView(securityVC, animated: true)
            let changeNoVC = storyboard?.instantiateViewController(withIdentifier:"ChangeNumberViewController" ) as! ChangeNumberViewController
            self.pushView(changeNoVC, animated: true)
            
        }
        else if indexPath.row == 3{
            let deletingVC = storyboard?.instantiateViewController(withIdentifier: "DeletingAccountViewController") as! DeletingAccountViewController
            self.pushView(deletingVC, animated: true)
            
            
        }
        else{
            
        }
    }
    @IBAction func backAction(_ sender: Any) {
        self.pop(animated: true)
    }
    @IBAction func logoutAction(_ sender: UIButton) {
        self.OpenactionSheet()
    }

    func OpenactionSheet()
    {
        let sheet_action: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let Logout: UIAlertAction = UIAlertAction(title: NSLocalizedString("Logout", comment: "comment"), style: .destructive) { action -> Void in
            
            (UIApplication.shared.delegate as! AppDelegate).Logout()
        }
        let CancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "comment"), style: .cancel) { action -> Void in
        }
        sheet_action.addAction(Logout)
        sheet_action.addAction(CancelAction)
        self.presentView(sheet_action, animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

