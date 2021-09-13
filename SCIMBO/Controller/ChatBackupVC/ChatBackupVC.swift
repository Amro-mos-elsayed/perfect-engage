//
//  ChatBackupVC.swift
//
//
//  Created by Casperon iOS on 29/09/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit

class ChatBackupVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var table: UITableView!
    
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    var Datasource : [String : Any] = [:]
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        updateUI()
    }
    
    func updateUI() {
        ChatBackUpHandler.sharedInstance.getBackupFileInfo()
        var time : String = "-"
        var size : String = "-"
        var backup_setting : String = "Off"
        
        let BackupFileInfo = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Chat_Backup_Settings, attribute: "user_id", FetchString: Themes.sharedInstance.Getuser_id(), SortDescriptor: nil) as! NSArray
        
        if(BackupFileInfo.count > 0)
        {
            let BackupFileInfoDict : NSManagedObject = BackupFileInfo[0] as! NSManagedObject
            time = BackupFileInfoDict.value(forKey: "backup_time") as! String
            size = BackupFileInfoDict.value(forKey: "backup_size") as! String
            backup_setting = BackupFileInfoDict.value(forKey: "backup_option") as! String
            
            switch (Int(backup_setting))! {
            case 0:
                backup_setting = "Off"
                break
            case 1:
                backup_setting = "Daily"
                break
            case 2:
                backup_setting = "Weekly"
                break
            case 3:
                backup_setting = "Monthly"
                break
            default:
                break
            }
        }
        Datasource  = ["0" : [["Left" : "Last Backup: \(time)\nTotal Size: \(size)", "Right" : "Backup your chat history and media to iCloud so if you lose your iPhone or switch to a new one, your chat history is safe. You can restore your chat history and media when you reinstall \(Themes.sharedInstance.GetAppname())."]], "1" : ["Back Up Now"], "2" : [["Left" : "Auto Backup", "Right" : backup_setting]]]
        table.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func back(_ sender: Any) {
        self.pop(animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return Datasource.keys.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 35
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        if(section == 2)
        {
            return 80
        }
        else
        {
            return 0.01
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String?
    {
        if(section == 2)
        {
            return "To avoid excessive data charges, connect your phone to Wi-Fi or disable cellular data for iCloud: iPhone Settings > Cellular > iCloud Drive > OFF."
        }
        else
        {
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if(indexPath.section == 0)
        {
            let text = (((Datasource["\(indexPath.section)"] as! NSArray)[0]) as! NSDictionary)["Right"] as? String
            
            let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: table.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
            label.numberOfLines = 10
            label.lineBreakMode = NSLineBreakMode.byWordWrapping
            label.font = UIFont.systemFont(ofSize: 16.0)
            label.text = text
            label.sizeToFit()
            
            return label.frame.height + 80
            
        }
        else
        {
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return (Datasource["\(section)"] as! NSArray).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell : UITableViewCell = UITableViewCell()
        switch indexPath.section {
        case 0:
            print("\(indexPath.row)")
            cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "Cell")
            cell.textLabel?.attributedText = increaseLineSpacing(Text: ((((Datasource["\(indexPath.section)"] as! NSArray)[indexPath.row]) as! NSDictionary)["Left"] as? String)!)
            cell.detailTextLabel?.attributedText = increaseLineSpacing(Text: ((((Datasource["\(indexPath.section)"] as! NSArray)[indexPath.row]) as! NSDictionary)["Right"] as? String)!)
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16.0)
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13.0)
            cell.accessoryType = .none
            cell.textLabel?.textColor = .lightGray
            cell.detailTextLabel?.textColor = .black
            cell.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.detailTextLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.textLabel?.numberOfLines = 10
            cell.detailTextLabel?.numberOfLines = 10
            cell.selectionStyle = .none
            break
        case 1:
            print("\(indexPath.row)")
            cell = UITableViewCell.init(style: .value1, reuseIdentifier: "Cell1")
            cell.textLabel?.text = (Datasource["\(indexPath.section)"] as! NSArray)[indexPath.row] as? String
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16.0)
            cell.textLabel?.textColor = CustomColor.sharedInstance.themeColor
            cell.accessoryType = .none
            break
        case 2:
            print("\(indexPath.row)")
            cell = UITableViewCell.init(style: .value1, reuseIdentifier: "Cell2")
            cell.textLabel?.text = (((Datasource["\(indexPath.section)"] as! NSArray)[indexPath.row]) as! NSDictionary)["Left"] as? String
            cell.detailTextLabel?.text = (((Datasource["\(indexPath.section)"] as! NSArray)[indexPath.row]) as! NSDictionary)["Right"] as? String
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16.0)
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 16.0)
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.textColor = .black
            cell.detailTextLabel?.textColor = .lightGray
            break
        default:
            break
        }
        return cell
    }
    
    func increaseLineSpacing(Text: String) -> NSMutableAttributedString
    {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.3
        paragraphStyle.alignment = .left
        let attributedString = NSMutableAttributedString(string: Text)
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 13.0), range: NSRange(location: 0, length:attributedString.length))
        return attributedString
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        switch indexPath.section {
        case 0:
            print("\(indexPath.row)")
            break
        case 1:
            print("\(indexPath.row)")
            
            
            
            ChatBackUpHandler.sharedInstance.copyDocumentsToiCloudDrive(View: self.view, completionHandler: { (success) in
                self.updateUI()
            })
            break
        case 2:
            print("\(indexPath.row)")
            if(ChatBackUpHandler.sharedInstance.checkiCloud())
            {
                let alert : UIAlertController = UIAlertController(title: "Auto Backup", message: "", preferredStyle: .actionSheet)
                let daily_action : UIAlertAction = UIAlertAction(title: "Daily", style: .default, handler: { (alert : UIAlertAction) in
                    let dict : Dictionary = ["Left" : "Auto Backup", "Right" : "Daily"]
                    var DataArray : Array<Dictionary<String, Any>> = self.Datasource["\(indexPath.section)"] as! Array
                    DataArray[indexPath.row] = dict
                    self.Datasource["\(indexPath.section)"] = DataArray
                    ChatBackUpHandler.sharedInstance.updateAutoBackupSettings(Option: "1")
                    self.table.reloadData()
                });
                let Weekly_action : UIAlertAction = UIAlertAction(title: "Weekly", style: .default, handler: { (alert : UIAlertAction) in
                    let dict : Dictionary = ["Left" : "Auto Backup", "Right" : "Weekly"]
                    var DataArray : Array<Dictionary<String, Any>> = self.Datasource["\(indexPath.section)"] as! Array
                    DataArray[indexPath.row] = dict
                    self.Datasource["\(indexPath.section)"] = DataArray
                    ChatBackUpHandler.sharedInstance.updateAutoBackupSettings(Option: "2")
                    self.table.reloadData()
                });
                let Monthly_action : UIAlertAction = UIAlertAction(title: "Monthly", style: .default, handler: { (alert : UIAlertAction) in
                    let dict : Dictionary = ["Left" : "Auto Backup", "Right" : "Monthly"]
                    var DataArray : Array<Dictionary<String, Any>> = self.Datasource["\(indexPath.section)"] as! Array
                    DataArray[indexPath.row] = dict
                    self.Datasource["\(indexPath.section)"] = DataArray
                    ChatBackUpHandler.sharedInstance.updateAutoBackupSettings(Option: "3")
                    self.table.reloadData()
                });
                let Off_action : UIAlertAction = UIAlertAction(title: "Off", style: .default, handler: { (alert : UIAlertAction) in
                    let dict : Dictionary = ["Left" : "Auto Backup", "Right" : "Off"]
                    var DataArray : Array<Dictionary<String, Any>> = self.Datasource["\(indexPath.section)"] as! Array
                    DataArray[indexPath.row] = dict
                    self.Datasource["\(indexPath.section)"] = DataArray
                    ChatBackUpHandler.sharedInstance.updateAutoBackupSettings(Option: "0")
                    self.table.reloadData()
                });
                let cancel_action : UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "comment"), style: .cancel, handler: { (alert : UIAlertAction) in
                    print("Cancelled")
                });
                alert.addAction(daily_action)
                alert.addAction(Weekly_action)
                alert.addAction(Monthly_action)
                alert.addAction(Off_action)
                alert.addAction(cancel_action)
                self.presentView(alert, animated: true, completion: nil)
            }
            else
            {
                Themes.sharedInstance.ShowNotification("iCloud not enabled", false)
            }
            break
        default:
            break
        }
    }
}


