//
//  NotificationVC.swift
//
//
//  Created by MV Anand Casp iOS on 05/09/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit

class NotificationVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var messageNotificationDict:NSDictionary = NSDictionary()
    var groupNotificationDict:NSDictionary = NSDictionary()
    var iShowSingleNotification:Bool = Bool()
    var iShowgroupNotification:Bool = Bool()
    var group_sound:String = String()
    
    var single_sound:String = String()
    var is_sound:Bool = Bool()
    var is_vibrate:Bool = Bool()
    var GroupChoosenIndex:String = String()
    var SingleChoosenIndex:String = String()
    
    
    var GroupSoundname:String = String()
    var SingleSoundname:String = String()
    
    
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        tableView.tableFooterView = UIView()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool)
    {
        ReloadView()
    }
    
    func ReloadView()
    {
        let CheckSettings:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Notification_Setting, attribute: "user_id", FetchString: Themes.sharedInstance.Getuser_id())
        if(CheckSettings)
        {
            let NotificationArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Notification_Setting, attribute: "user_id", FetchString: Themes.sharedInstance.Getuser_id(), SortDescriptor: nil) as! NSArray
            for i in 0..<NotificationArr.count
            {
                let objRecord:NSManagedObject = NotificationArr[i] as! NSManagedObject
                group_sound = objRecord.value(forKey: "group_sound") as! String
                is_sound = objRecord.value(forKey: "is_sound")  as! Bool
                
                is_vibrate = objRecord.value(forKey: "is_vibrate")  as! Bool
                single_sound = objRecord.value(forKey: "single_sound") as! String
                
                iShowSingleNotification = objRecord.value(forKey: "is_show_notification_single") as! Bool
                iShowgroupNotification = objRecord.value(forKey: "is_show_notification_group")  as! Bool
                
                let  alertTonesDic = ["None":"0", "Default" : "Default", "Notes":"1012","Aurora":"1005","Bambo":"1006","Chord":"1001","Circles":"1007","Complete":"1008","Hello":"1009","Input":"1010","Keys":"1011","Popcorn":"1013","Pulse":"1015","Synth":"1014","Bell":"1020","Boing":"1021","Glass":"1022","Harp":"1023","Time Passing":"1024","Tri-Tome":"1025","Xylophone":"1026"]
                
                for (key, value) in alertTonesDic {
                    print("\(key): \(value)")
                    if(value == group_sound)
                    {
                        GroupChoosenIndex = value
                        GroupSoundname  = key
                        
                    }
                    if(value == single_sound)
                    {
                        SingleChoosenIndex = value
                        SingleSoundname = key
                    }
                    
                }
                
                
            }
        }
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellID")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func DidclickBack(_ sender: Any) {
        self.pop(animated: true)
    }
    
    @IBAction func singleNotificationChanged(sender: UISwitch) {
        let Dict:Dictionary = ["is_show_notification_single":sender.isOn]
        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Notification_Setting, FetchString: Themes.sharedInstance.Getuser_id(), attribute: "user_id", UpdationElements: Dict as NSDictionary?)
        iShowSingleNotification = sender.isOn
        let indexpath:IndexPath = IndexPath(row: 1, section: 0)
        if(sender.isOn)
        {
            tableView.insertRows(at: [indexpath], with: .right)
        }
        else
        {
            tableView.deleteRows(at: [indexpath], with: .right)
        }
        
        
    }
    @IBAction func groupNotificationChanged(sender: UISwitch) {
        let Dict:Dictionary = ["is_show_notification_group":sender.isOn]
        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Notification_Setting, FetchString: Themes.sharedInstance.Getuser_id(), attribute: "user_id", UpdationElements: Dict as NSDictionary?)
        
        let indexpath:IndexPath = IndexPath(row: 1, section: 1)
        iShowgroupNotification = sender.isOn
        if(sender.isOn)
        {
            tableView.insertRows(at: [indexpath], with: .right)
            
        }
        else
        {
            tableView.deleteRows(at: [indexpath], with: .right)
            
        }
        //        let indexpath2:IndexPath = IndexPath(row: 0, section: 1)
        //
        //        tableView.reloadRows(at: [indexpath2], with: .none)
        
        
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

extension NotificationVC:UITableViewDelegate,UITableViewDataSource
{
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section == 0)
        {
            return  NSLocalizedString("MESSAGE NOTIFICATION", comment: "COM")
        }
        if(section == 1)
        {
            return NSLocalizedString("GROUP NOTIFICATION", comment: "COM")
        }
        if(section == 2)
        {
            return ""
        }
        if(section == 3)
        {
            return ""
        }
        return ""
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0)
        {
            if(iShowSingleNotification)
            {
                return 2
            }
            else
            {
                return 1
            }
        }
        else  if(section == 1)
        {
            if(iShowgroupNotification)
            {
                return 2
            }
            else
            {
                return 1
            }
        }
        else  if(section == 2)
        {
            
            return 1
            
        }
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let Cell:UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "CellID")
        Cell.textLabel?.font = UIFont.systemFont(ofSize: 16.0)
        Cell.textLabel?.textColor = CustomColor.sharedInstance.themeColor
        let switchView = UISwitch(frame: CGRect.zero)
        switchView.onTintColor = CustomColor.sharedInstance.themeColor
        Cell.accessoryType = .none
        //Cell.accessoryView = nil
        if (indexPath.section == 0)
        {
            if(indexPath.row == 0)
            {
                Cell.textLabel?.text = NSLocalizedString("Show Notifications", comment: "COM")
                Cell.accessoryView = switchView
                switchView.addTarget(self, action: #selector(self.singleNotificationChanged(sender:)), for: .valueChanged)
            }
            else  if(indexPath.row == 1)
            {
                Cell.textLabel?.text = NSLocalizedString("Sound", comment: "COM")
                Cell.detailTextLabel?.text = "\(SingleSoundname)"
                
                Cell.accessoryType = .disclosureIndicator
            }
            
            
            switchView.setOn(iShowSingleNotification, animated: true)
            
        }
        else if(indexPath.section == 1)
        {
            if(indexPath.row == 0)
            {
                Cell.textLabel?.text = NSLocalizedString("Show Notifications", comment: "COM")
                Cell.accessoryView = switchView
                switchView.addTarget(self, action: #selector(self.groupNotificationChanged(sender:)), for: .valueChanged)
                
            }
            else  if(indexPath.row == 1)
            {
                Cell.textLabel?.text = NSLocalizedString("Sound", comment: "COM")
                Cell.detailTextLabel?.text = "\(GroupSoundname)"
                Cell.accessoryType = .disclosureIndicator
            }
            switchView.setOn(iShowgroupNotification, animated: true)
        }
        else if(indexPath.section == 2)
        {
            Cell.textLabel?.text = NSLocalizedString("In App Notifications", comment: "COM")
            Cell.accessoryType = .disclosureIndicator
            
        }
        else if(indexPath.section == 3)
        {
            Cell.textLabel?.textColor = UIColor.red
            
            Cell.textLabel?.text = NSLocalizedString("Reset Notification", comment: "COM")
        }
        return Cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (indexPath.section == 0)
        {
            if(indexPath.row == 1)
            {
                let  notifiListVC = storyboard?.instantiateViewController(withIdentifier: "NotificationListViewController") as! NotificationListViewController
                notifiListVC.Chattype = .single
                notifiListVC.ChoosedIndex = SingleChoosenIndex
                self.pushView(notifiListVC, animated: true)
            }
        }
        else if(indexPath.section == 1)
        {
            if(indexPath.row == 1)
            {
                let  notifiListVC = storyboard?.instantiateViewController(withIdentifier: "NotificationListViewController") as! NotificationListViewController
                notifiListVC.Chattype = .group
                notifiListVC.ChoosedIndex = GroupChoosenIndex
                self.pushView(notifiListVC, animated: true)
            }
            
        }
        else if(indexPath.section == 2)
        {
            let  AppNotificationVC = storyboard?.instantiateViewController(withIdentifier: "InAppNotificationVCID") as! InAppNotificationVC
            AppNotificationVC.Chattype = .single
            AppNotificationVC.is_sound = is_sound
            AppNotificationVC.is_vibrate = is_vibrate
            self.pushView(AppNotificationVC, animated: true)
        }
        else if(indexPath.section == 3)
        {
            SettingHandler.sharedinstance.SaveSetting(user_ID: Themes.sharedInstance.Getuser_id(), setting_type: .notification)
            self.ReloadView()
        }
        
    }
    
}

