//
//  ChatVC.swift
//
//
//  Created by Casperon iOS on 29/09/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit

class ChatVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var table: UITableView!
    var Datasource : [String : Any] = [:]
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        updateTable()
    }
    
    func updateTable() {
        let checkArchived : Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "is_archived", FetchString: "0")
        
        if(checkArchived)
        {
            Datasource  = ["0" : [NSLocalizedString("Chat Wallpaper", comment: "comm")], "1" : ["Chat Backup"], "2" : [NSLocalizedString("Clear all Chats", comment: "comm"), NSLocalizedString("Delete all Chats", comment: "comm")]]
            
        }
        else
        {
            Datasource  = ["0" : [NSLocalizedString("Chat Wallpaper", comment: "comm")], "1" : ["Chat Backup"], "2" : [NSLocalizedString("Clear all Chats", comment: "comm"), NSLocalizedString("Delete all Chats", comment: "comm")]]
        }
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
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 44
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return (Datasource["\(section)"] as! NSArray).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell : UITableViewCell = UITableViewCell.init(style: .value1, reuseIdentifier: "Cell")
        cell.textLabel?.text = (Datasource["\(indexPath.section)"] as! NSArray)[indexPath.row] as? String
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16.0)
        
        switch indexPath.section {
        case 0:
            print("\(indexPath.row)")
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.textColor = .black
            break
        case 1:
            print("\(indexPath.row)")
            cell.accessoryType = .none
            cell.textLabel?.textColor = .black
            break
        case 2:
            print("\(indexPath.row)")
            cell.accessoryType = .none
            switch indexPath.row {
            case 0:
                print("\(indexPath.row)")
                cell.textLabel?.textColor = .red
                break
            case 1:
                print("\(indexPath.row)")
                cell.textLabel?.textColor = .red
                break
            case 2:
                print("\(indexPath.row)")
                cell.textLabel?.textColor = .red
                break
            default:
                break
            }
            break
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let cell : UITableViewCell = self.table.cellForRow(at: indexPath)!
        switch indexPath.section {
        case 0:
            print("\(indexPath.row)")
            let WallPaperOptionVC = self.storyboard?.instantiateViewController(withIdentifier: "WallPaperOptionVCID") as! WallPaperOptionVC
            self.pushView(WallPaperOptionVC, animated: true)
            break
        case 1:
//            print("\(indexPath.row)")
//            let ChatBackupVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatBackupVCID") as! ChatBackupVC
//            self.pushView(ChatBackupVC, animated: true)
//            break
    ChatBackUpHandler.sharedInstance.copyDocumentsToiCloudDrive(View: self.view, completionHandler: { (success) in
                        print("success")
            })
        break
        case 2:
            print("\(indexPath.row)")
            switch indexPath.row {
            
            case 0:
                print("\(indexPath.row)")
                let alert : UIAlertController = UIAlertController.init(title: NSLocalizedString("Clear all of your chats?", comment: "com") , message: "", preferredStyle: .actionSheet)
                let clearStarredAction = UIAlertAction(title: NSLocalizedString("Clear All Chats except starred", comment: "note") , style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    Themes.sharedInstance.executeClearChat("1", "", false)
                })
                let clearMessageAction = UIAlertAction(title: NSLocalizedString("Clear All Chats", comment: "note") , style: .destructive, handler: {
                    (alert: UIAlertAction!) -> Void in
                    Themes.sharedInstance.executeClearChat("0", "", false)
                })
                let cancel_action = UIAlertAction(title: NSLocalizedString("Cancel", comment: "comment"), style: .cancel, handler: { (alert: UIAlertAction!) in
                    print("Cancelled")
                })
                alert.addAction(clearStarredAction)
                alert.addAction(clearMessageAction)
                alert.addAction(cancel_action)
                self.presentView(alert, animated: true, completion: nil)
                break
            case 1:
                print("\(indexPath.row)")
                let alert : UIAlertController = UIAlertController.init(title: NSLocalizedString("Delete all of your chats?", comment: "com"), message: "", preferredStyle: .actionSheet)
                let delete_all_action = UIAlertAction(title: NSLocalizedString("Delete All Chats", comment: "com") , style: .destructive, handler: { (alert: UIAlertAction!) in
                    Themes.sharedInstance.executeClearChat("0", "", true)
                })
                let cancel_action = UIAlertAction(title: NSLocalizedString("Cancel", comment: "comment"), style: .cancel, handler: { (alert: UIAlertAction!) in
                    print("Cancelled")
                })
                alert.addAction(delete_all_action)
                alert.addAction(cancel_action)
                self.presentView(alert, animated: true, completion: nil)
                break
            default:
                break
            }
            break
        default:
            break
        }
    }
    
    func ExecuteArchiveChat(isArchived : Bool)
    {
        Themes.sharedInstance.activityView(View: self.view)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            let ChatArr = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_id", FetchString: Themes.sharedInstance.Getuser_id(), SortDescriptor: "timestamp") as! NSArray
            
            if(ChatArr.count > 0)
            {
                for i in 0..<ChatArr.count
                {
                    let ChatDetail : NSManagedObject = ChatArr[i] as! NSManagedObject
                    let type : String = ChatDetail.value(forKey: "chat_type") as! String
                    let conv_id : String = ChatDetail.value(forKey: "conv_id") as! String
                    let user_common_id : String = ChatDetail.value(forKey: "user_common_id") as! String
                    let status : String = (isArchived) ? "0" : "1"
                    let is_archived : String = (isArchived) ? "0" : "1"
                    if(conv_id != "")
                    {
                        let DataDict:NSDictionary = ["from":Themes.sharedInstance.Getuser_id(),"convId":conv_id,"type":type,"status":status]
                        SocketIOManager.sharedInstance.EmitArchivedetails(Dict: DataDict)
                    }
                    
                    let UpdateDict:NSDictionary =  ["is_archived":is_archived]
                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: user_common_id, attribute: "user_common_id", UpdationElements: UpdateDict)
                    
                }
                
            }
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            self.updateTable()
        })
    }
}

