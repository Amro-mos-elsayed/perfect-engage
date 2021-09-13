//
//  StatusPrivacySettingViewController.swift
//  whatsUpStatus
//
//  Created by raguraman on 04/04/18.
//  Copyright © 2018 raguraman. All rights reserved.
//

import UIKit



class StatusPrivacySettingViewController: UIViewController {
    @IBOutlet weak var privacyTableView: UITableView!
    
    var contentTitleArray = ["My Contacts",
                             "My Contacts Except...",
                             "Only Share With..."]
    var contentDetailArray = ["Share with all of your contacts",
                              "Share with your contacts except people you select",
                              "Only share with selected contacts"]
    var headerText = "WHO WILL SEE MY UPDATES"
    var footerText = "Changes to your privacy settings won't affect status updates that you've sent already"
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    var choosenPrivacy = Int()
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        privacyTableView.dataSource = self
        privacyTableView.delegate = self
        var choosen = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.User_detail, attrib_name: "user_id", fetchString: Themes.sharedInstance.Getuser_id(), returnStr: "status_privacy")
        if(choosen == "")
        {
            choosen = "0"
        }
        choosenPrivacy = Int(choosen)!
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
    }
    
    func registerCell(){
        privacyTableView.register(UINib(nibName: "StatusPrivacyTableViewCell", bundle: nil), forCellReuseIdentifier: "StatusPrivacyTableViewCell")
        privacyTableView.register(UINib(nibName: "StatusHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "StatusHeaderView")
        privacyTableView.register(UINib(nibName: "MyStatusListFooter", bundle: nil), forHeaderFooterViewReuseIdentifier: "MyStatusListFooter")
    }
    
    @IBAction func didClickBackButton(_ sender: UIButton) {
        self.pop(animated: true)
    }
    
    
    
}

extension StatusPrivacySettingViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = privacyTableView.dequeueReusableCell(withIdentifier: "StatusPrivacyTableViewCell") as! StatusPrivacyTableViewCell
        cell.titleLabel.text = contentTitleArray[indexPath.row]
        cell.descriptionLabel.text = contentDetailArray[indexPath.row]
        if indexPath.row == choosenPrivacy{
            cell.tickImg.isHidden = false
        }
        else{
            cell.tickImg.isHidden = true
        }
        if (indexPath.row != 0)
        {
            cell.nextImg.isHidden = false
        }
        else
        {
            cell.nextImg.isHidden = true
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == 0)
        {
            let idArr = [String]()
            let emptyArr = [String]()
            let StatusdataUpdateempty : NSData = NSKeyedArchiver.archivedData(withRootObject: emptyArr) as NSData
            
            let param = ["status_except" : StatusdataUpdateempty, "status_only_with" : StatusdataUpdateempty, "status_privacy" : "0"] as [String : Any]
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail, FetchString: Themes.sharedInstance.Getuser_id(), attribute: "user_id", UpdationElements: param as NSDictionary)
            
            SocketIOManager.sharedInstance.StatusprivacySetting(from: Themes.sharedInstance.Getuser_id(), statusToID: idArr, privacy: "my_contacts")
            choosenPrivacy = 0
            self.privacyTableView.reloadData()
        }
        else if(indexPath.row == 1)
        {
            let  newGroupVC = storyboard?.instantiateViewController(withIdentifier: "NewGroupViewController") as! NewGroupViewController
            newGroupVC.fromStatusPrivacy = true
            newGroupVC.isExceptContact = true
            newGroupVC.delegate = self
            self.pushView(newGroupVC, animated: true)
        }
        else if(indexPath.row == 2)
        {
            let  newGroupVC = storyboard?.instantiateViewController(withIdentifier: "NewGroupViewController") as! NewGroupViewController
            newGroupVC.fromStatusPrivacy = true
            newGroupVC.isExceptContact = false
            newGroupVC.delegate = self
            self.pushView(newGroupVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let cell = privacyTableView.dequeueReusableHeaderFooterView(withIdentifier: "MyStatusListFooter") as! MyStatusListFooter
        cell.titleLabel.text = footerText
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = privacyTableView.dequeueReusableHeaderFooterView(withIdentifier: "StatusHeaderView") as! StatusHeaderView
        cell.headerLabel.text = headerText
        return cell
    }
    
    
}

extension StatusPrivacySettingViewController : NewGroupViewControllerDelegate
{
    func Privacy_Update(_ records : [NewGroupAdd],_ isExceptContact : Bool) {
        
        var idArr = [String]()
        records.forEach { rec in
            idArr.append(rec.id as String)
        }
        let emptyArr = [String]()
        let StatusdataUpdate : NSData = NSKeyedArchiver.archivedData(withRootObject: idArr) as NSData
        let StatusdataUpdateempty : NSData = NSKeyedArchiver.archivedData(withRootObject: emptyArr) as NSData
        
        var param = [AnyHashable : Any]()
        if(isExceptContact)
        {
            param = ["status_except" : StatusdataUpdate, "status_only_with" : StatusdataUpdateempty, "status_privacy" : "1"]
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail, FetchString: Themes.sharedInstance.Getuser_id(), attribute: "user_id", UpdationElements: param as NSDictionary)
            
            SocketIOManager.sharedInstance.StatusprivacySetting(from: Themes.sharedInstance.Getuser_id(), statusToID: idArr, privacy: "my_contacts_except")
            choosenPrivacy = 1
            
        }
        else
        {
            param = ["status_only_with" : StatusdataUpdate, "status_except" : StatusdataUpdateempty, "status_privacy" : "2"]
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail, FetchString: Themes.sharedInstance.Getuser_id(), attribute: "user_id", UpdationElements: param as NSDictionary)
            
            SocketIOManager.sharedInstance.StatusprivacySetting(from: Themes.sharedInstance.Getuser_id(), statusToID: idArr, privacy: "only_share")
            choosenPrivacy = 2
        }
        self.privacyTableView.reloadData()
    }
}

