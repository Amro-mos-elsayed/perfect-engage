//
//  DataUsageViewController.swift
//
//
//  Created by CASPERON on 26/12/16.
//  Copyright © 2016 CASPERON. All rights reserved.
//

import UIKit

class DataUsageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var table: UITableView!
    var headers : NSArray = NSArray()
    var footers : NSArray = NSArray()
    var Datasource : [String : Any] = [:]
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        
        headers = [NSLocalizedString("MEDIA AUTO-DOWNLOAD", comment: "com") , ""]
        footers = [NSLocalizedString("Voice Messages are always automatically downloaded for the best communication experience.", comment: "com") , ""]
        let DataUsageCount : Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Data_Usage_Settings, attribute: "user_id", FetchString: Themes.sharedInstance.Getuser_id())
        var UserReponseDict:NSManagedObject?
        if(DataUsageCount)
        {
            let DataUsageSettingArr = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Data_Usage_Settings, attribute: "user_id", FetchString: Themes.sharedInstance.Getuser_id(), SortDescriptor: nil) as! NSArray
            if(DataUsageSettingArr.count > 0)
            {
                UserReponseDict = DataUsageSettingArr[0] as? NSManagedObject
                Datasource  = ["\(headers[0])" : [["Left" : NSLocalizedString("Photos", comment: "com") , "Right" : "\((UserReponseDict?.value(forKey: "photos"))!)"], ["Left" : NSLocalizedString("Audio", comment: "com") , "Right" : "\((UserReponseDict?.value(forKey: "audio"))!)"], ["Left" : NSLocalizedString("Videos", comment: "com") , "Right" : "\((UserReponseDict?.value(forKey: "videos"))!)"], ["Left" : NSLocalizedString( "Documents", comment: "com"), "Right" : "\((UserReponseDict?.value(forKey: "documents"))!)"], ["Left" :  NSLocalizedString("Reset Auto-Download Settings", comment: "com") , "Right" : ""]], "" : [["Left" : NSLocalizedString("Network Usage", comment: "com") , "Right" : ""]]]
            }
        }
        else
        {
            let Dic : NSDictionary = ["photos" : "2", "audio" : "2", "videos" : "2", "documents" : "2", "user_id" : Themes.sharedInstance.Getuser_id()]
            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dic, Entityname: Constant.sharedinstance.Data_Usage_Settings)
            Datasource  = ["\(headers[0])" : [["Left" : "Photos", "Right" : "\((Dic.value(forKey: "photos"))!)"], ["Left" : "Audio", "Right" : "\((Dic.value(forKey: "audio"))!)"], ["Left" : "Videos", "Right" : "\((Dic.value(forKey: "videos"))!)"], ["Left" : "Documents", "Right" : "\((Dic.value(forKey: "documents"))!)"], ["Left" : NSLocalizedString("Reset Auto-Download Settings", comment: "com"), "Right" : ""]], "" : [["Left" : NSLocalizedString("Network Usage", comment: "com"), "Right" : ""]]]
            
        }
        table.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func backBtnAction(_ sender: Any) {
        self.pop(animated: true)
    }
        
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return headers.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return headers[section] as? String
    }
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String?
    {
        return footers[section] as? String
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if(section == 0)
        {
            return 40
        }
        else
        {
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        if(section == 0)
        {
            return 60
        }
        else
        {
            return 0.01
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 44
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return (Datasource["\(headers[section])"] as! NSArray).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell : UITableViewCell = UITableViewCell.init(style: .value1, reuseIdentifier: "Cell")
        cell.textLabel?.text = ((Datasource["\(headers[indexPath.section])"] as! NSArray)[indexPath.row] as! Dictionary)["Left"]
        if(((Datasource["\(headers[indexPath.section])"] as! NSArray)[indexPath.row] as! Dictionary)["Right"] == "0")
        {
            cell.detailTextLabel?.text = NSLocalizedString("Never", comment: "never")
        }
        else if(((Datasource["\(headers[indexPath.section])"] as! NSArray)[indexPath.row] as! Dictionary)["Right"] == "1")
        {
            cell.detailTextLabel?.text = NSLocalizedString("Wi-Fi", comment: "never")
        }
        else if(((Datasource["\(headers[indexPath.section])"] as! NSArray)[indexPath.row] as! Dictionary)["Right"] == "2")
        {
            cell.detailTextLabel?.text = NSLocalizedString("Wi-Fi and Cellular", comment: "never")
        }
        if(indexPath.section == 0 && indexPath.row > 3)
        {
            if(CompareWithDefault())
            {
                cell.textLabel?.textColor = .lightGray
            }
            else{
                cell.textLabel?.textColor = CustomColor.sharedInstance.themeColor
            }
            cell.accessoryType = .none
        }
        else{
            cell.textLabel?.textColor = .black
            cell.accessoryType = .disclosureIndicator
        }
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16.0)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 16.0)
        return cell
    }
    
    func CompareWithDefault() -> Bool {
        
        let rowArray = Datasource["\(headers[0])"]
        for rowDict : Dictionary in (rowArray as! Array<Dictionary<String, Any>>) {
            if(rowDict["Right"] as? String != Constant.sharedinstance.Datausagesetting[(rowArray as! NSArray).index(of: rowDict)]["Right"])
            {
                return false
            }
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if(indexPath.section == 0 && indexPath.row < 4)
        {
            var keys = ""
            if indexPath.row == 0 {
                keys = "Photos"
            }
            else if indexPath.row == 1 {
                keys = "Audio"
            }
            else if indexPath.row == 2 {
                keys = "Videos"
            }
            else if indexPath.row == 3 {
                keys = "Documents"
            }
            
            let alert : UIAlertController = UIAlertController.init(title: keys, message: "", preferredStyle: .actionSheet)
            let neverAction : UIAlertAction = UIAlertAction.init(title:NSLocalizedString("Never", comment: "Never"), style: .default, handler: { (alert: UIAlertAction!) in
                let dict : Dictionary = ["Left" : keys, "Right" : "0"]
                var DataArray : Array<Dictionary<String, Any>> = self.Datasource["\(self.headers[indexPath.section])"] as! Array
                DataArray[indexPath.row] = dict
                self.Datasource["\(self.headers[indexPath.section])"] = DataArray
                self.updateDB(field: keys, value: "0")
                self.table.reloadData()
            })
            let wifiAction : UIAlertAction = UIAlertAction.init(title: NSLocalizedString("Wi-Fi", comment: "Wi-Fi") , style: .default, handler: { (alert: UIAlertAction!) in
                let dict : Dictionary = ["Left" : keys, "Right" : "1"]
                var DataArray : Array<Dictionary<String, Any>> = self.Datasource["\(self.headers[indexPath.section])"] as! Array
                DataArray[indexPath.row] = dict
                self.Datasource["\(self.headers[indexPath.section])"] = DataArray
                self.updateDB(field: keys, value: "1")
                self.table.reloadData()
            })
            let wifi_cellular_Action : UIAlertAction = UIAlertAction.init(title: NSLocalizedString("Wi-Fi and Cellular", comment: "Wi-Fi"), style: .default, handler: { (alert: UIAlertAction!) in
                let dict : Dictionary = ["Left" : keys, "Right" : "2"]
                var DataArray : Array<Dictionary<String, Any>> = self.Datasource["\(self.headers[indexPath.section])"] as! Array
                DataArray[indexPath.row] = dict
                self.Datasource["\(self.headers[indexPath.section])"] = DataArray
                self.updateDB(field: keys, value: "2")
                self.table.reloadData()
            })
            let CancelAction : UIAlertAction = UIAlertAction.init(title: NSLocalizedString("Cancel", comment:"Cancel") , style: .cancel, handler: { (alert: UIAlertAction!) in
                print("Cancelled")
            })
            alert.addAction(neverAction)
            alert.addAction(wifiAction)
            alert.addAction(wifi_cellular_Action)
            alert.addAction(CancelAction)
            self.presentView(alert, animated: true, completion: nil)
        }
        else if(indexPath.section == 0)
        {
            if(CompareWithDefault() == false)
            {
                self.Datasource["\(headers[0])"] = Constant.sharedinstance.Datausagesetting
                let Dic : NSDictionary = ["photos" : "2", "audio" : "1", "videos" : "1", "documents" : "1", "user_id" : Themes.sharedInstance.Getuser_id()]
                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Data_Usage_Settings, FetchString: Themes.sharedInstance.Getuser_id(), attribute:"user_id", UpdationElements: Dic)
                self.table.reloadData()
            }
        }
        else if(indexPath.section == 1)
        {
            let NetworkUsageVC = self.storyboard?.instantiateViewController(withIdentifier:"NetworkUsageVCID" ) as! NetworkUsageVC
            self.pushView(NetworkUsageVC, animated: true)
        }
    }
    
    func updateDB(field : String, value : String)
    {
        let param = [field.lowercased() : value]
        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Data_Usage_Settings, FetchString: Themes.sharedInstance.Getuser_id(), attribute: "user_id", UpdationElements: param as NSDictionary?)
    }
    
}
