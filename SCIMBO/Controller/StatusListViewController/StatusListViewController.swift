//
//  StatusListViewController.swift
//
//
//  Created by CASPERON on 14/02/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit

class StatusListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,SocketIOManagerDelegate{
    @IBOutlet weak var statusTbl_View: UITableView!
    
    
    
    var statusSelec_Arry:NSMutableArray = NSMutableArray()
    var statusList_Array:NSMutableArray = NSMutableArray()
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        
        let getDic = DatabaseHandler.sharedInstance.fetchTableAllData(Entityname: Constant.sharedinstance.status_List)
        getStatus()
        print(getDic)
        
        // statusSelec_Arry = ["Available"]
        //  statusList_Array = ["Available","At work","At the movies","Battery About to die","Busy","Can't tal,WhatsApp only","In a meeting","At the gym","Sleeping","Urgent calls only"]
        //        if statusRec.count == 0 {
        //           // self.getRec()
        //
        //        }
        //        else{
        //
        //            statusTbl_View.reloadData()
        //        }
        let nibName = UINib(nibName: "StatusListTableViewCell", bundle: nil)
        statusTbl_View.register(nibName, forCellReuseIdentifier: "StatusListTableViewCell")
        statusTbl_View.tableFooterView = UIView()
        // Do any additional setup after loading the view.
    }
    
    
    
    func getStatus(){
        
        statusList_Array.removeAllObjects()
        statusSelec_Arry.removeAllObjects()
        statusSelec_Arry.add(Themes.sharedInstance.setStatusTxt(Themes.sharedInstance.Getuser_id()))
        let getDic =   DatabaseHandler.sharedInstance.fetchTableAllData(Entityname: Constant.sharedinstance.status_List)
        
        for i in 0..<getDic.count
        {
            let statusDetail_Dic = getDic[i]  as! NSManagedObject
            let value = statusDetail_Dic.value(forKey: "status_title") as! String
            statusList_Array.add(value)
            
        }
        if languageHandler.ApplicationLanguage().contains("ar") {
            statusList_Array = [NSLocalizedString("Online", comment: "ava"),
                                NSLocalizedString("Away", comment: "ava"),
                                NSLocalizedString("Busy", comment: "ava"),
                                NSLocalizedString("In a meeting", comment: "ava") ,
                                NSLocalizedString("Do not disturb", comment: "ava") ,
                                NSLocalizedString("Business trip", comment: "ava") ,
                                NSLocalizedString("On vacation", comment: "ava"),
                                NSLocalizedString("Offline", comment: "ava")]
        }
        let app = Themes.sharedInstance.GetAppname()
        if getDic.count == 0{
            statusSelec_Arry.removeAllObjects()
            
            
        }
        else{
            getRec()
        }
        
        
    }
    
    func getRec(){
        
        let app = Themes.sharedInstance.GetAppname()
        var checkStatus:String = "status not found"
        statusRec.removeAll()
        for i in 0..<statusList_Array.count{
            if  Themes.sharedInstance.setStatusTxt(Themes.sharedInstance.Getuser_id()) == Themes.sharedInstance.CheckNullvalue(Passed_value: statusList_Array[i]) {
                checkStatus = "status found"
                let newStatusObject = StatusRec(status:statusList_Array[i] as! String,isSelect:true)
                statusRec.append(newStatusObject)
                statusSelec_Arry.removeAllObjects()
                statusSelec_Arry.add(statusList_Array[i])
            }
            else{
                let newStatusObject = StatusRec(status:statusList_Array[i] as! String,isSelect:false)
                statusRec.append(newStatusObject)
                if checkStatus == "status not found"
                {
                    statusSelec_Arry.removeAllObjects()
                    
                }
                
                
            }
            
        }
        if checkStatus == "status not found"
        {
            
            let UpdateDic:[String:Any]=["status": NSLocalizedString("Online", comment:"Hey there! I am using ")]
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail , FetchString:Themes.sharedInstance.Getuser_id() , attribute:"user_id", UpdationElements: UpdateDic as NSDictionary?)
        }
        
        statusTbl_View.reloadData()
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            
            return 50
            
        }
            
        else if  section == 1{
            return 50
        }
        else{
            return 30
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UITableViewHeaderFooterView()
        
        if section  == 0{
            let headerView = UITableViewHeaderFooterView()
            let label = UILabel(frame: CGRect(x: 0, y: 24 , width: self.view.frame.width, height: 30))
            label.font = UIFont.systemFont(ofSize: 15.0)
            label.textColor = UIColor.lightGray
            label.text = NSLocalizedString( "  YOUR CURRENT STATUS IS :", comment:  "  YOUR CURRENT STATUS IS :")
            headerView.addSubview(label)
            let bottomBorderColor = UIColor(red: 246/255.0, green: 246/255.0, blue: 246/255.0, alpha: 1)
            //headerView.backgroundColor = bottomBorderColor
            headerView.contentView.backgroundColor = bottomBorderColor
            return headerView
        }
        if section == 1{
            let headerView = UITableViewHeaderFooterView()
            let label = UILabel(frame: CGRect(x: 0, y: 24 , width: self.view.frame.width, height: 30))
            label.font = UIFont.systemFont(ofSize: 15.0)
            label.textColor = UIColor.lightGray
            label.text = NSLocalizedString("  SELECT YOUR NEW STATUS", comment: "  SELECT YOUR NEW STATUS")
            headerView.addSubview(label)
            let bottomBorderColor = UIColor(red: 246/255.0, green: 246/255.0, blue: 246/255.0, alpha: 1)
            // headerView.backgroundColor = bottomBorderColor
            headerView.contentView.backgroundColor = bottomBorderColor
            return headerView
            
        }
        //        let headerView = UILabel(frame: CGRect(origin: CGPointZero, size: CGSize(width: self.view.frame.width, height: 50)))
        //        let label = UILabel(frame: CGRect(x: 0, y: 20, width: self.view.frame.width, height: 30))
        //        label.text = "Some Text"
        //        headerView.addSubview(label)
        return headerView
        
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        
        if section  == 2{
            
            let header = view as! UITableViewHeaderFooterView
            header.textLabel?.font = UIFont.systemFont(ofSize: 0.0)
            header.textLabel?.textColor = UIColor.lightGray
            header.textLabel?.text = ""
        }
        else{
            
            //            let headerView = UILabel(frame: CGRect(origin: CGPointZero, size: CGSize(width: self.view.frame.width, height: 50)))
            //            let label = UILabel(frame: CGRect(x: 0, y: 20, width: self.view.frame.width, height: 30))
            //            label.text = "Some Text"
            //            headerView.addSubview(label)
            //           let header = view as! UITableViewHeaderFooterView
            //           header.textLabel?.font = UIFont(name: "Futura", size: 11)
            //             let bottomBorderColor = UIColor(red: 227/255.0, green: 227/255.0, blue: 227/255.0, alpha: 1)
            //           header.contentView.backgroundColor = bottomBorderColor
            //           header.textLabel?.textColor = UIColor.lightGray
            //            header.textLabel?.frame = CGRect(x: 0, y: header.frame.maxY, width: (header.textLabel?.frame.width)!, height: (header.textLabel?.frame.height)!)
            //
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            
            return  statusSelec_Arry.count
        }
        else if  section == 1{
            return  statusRec.count
        }
        else if  section == 2{
            return  0
        }
        
        
        
        return  statusRec.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier:"StatusListTableViewCell") as! StatusListTableViewCell
        cell.activityIndicator_View.isHidden = true
        
//        cell.statusLbl.textAlignment = NSTextAlignment.left
        cell.statusLbl.textColor  = UIColor.black
        
        if indexPath.section == 0 {
            
            cell.statusLbl.text = statusSelec_Arry[0] as? String
            
            
            
        }
        else if indexPath.section == 1 {
            let recValue:StatusRec = statusRec[indexPath.row] as StatusRec
            //            cell.statusLbl.text = statusList_Array[indexPath.row] as? String
            cell.statusLbl.text = recValue.status
            
            if recValue.isSelect == true {
                
                cell.tickImage_View.isHidden = false
                cell.activityIndicator_View.isHidden = true
                
                cell.tickImage_View.image = #imageLiteral(resourceName: "tickonly")
            }
            else{
                cell.tickImage_View.image = nil
            }
            
            
        }
        else if indexPath.section == 2{
            cell.tickImage_View.isHidden = true
            cell.activityIndicator_View.isHidden = true
            cell.activityIndicator_View.stopAnimating()
            //            cell.statusLbl.isHidden = true
            
            cell.statusLbl.textAlignment = NSTextAlignment.center
            cell.statusLbl.textColor  = UIColor.red
            cell.statusLbl.text = "Clear Status"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section ==  2{
            SocketIOManager.sharedInstance.Delegate = self
            SocketIOManager.sharedInstance.changeStatus(status:NSLocalizedString("Online", comment:"Hey there! I am using "), from:Themes.sharedInstance.Getuser_id())
        }
            
        else  if indexPath.section == 0 {
            
            let yourStatusVC = storyboard?.instantiateViewController(withIdentifier:"YourStatusViewController") as! YourStatusViewController
            yourStatusVC.yourstatus = statusSelec_Arry[0] as! String
            self.pushView(yourStatusVC, animated: true)
            
        }
        else if  indexPath.section == 1{
            
            _ = statusRec.map{$0.isSelect = false}
            statusRec[indexPath.row].isSelect = true
            self.statusSelec_Arry.removeAllObjects()
            self.statusSelec_Arry.add(statusRec[indexPath.row].status)
            let currentCell = tableView.cellForRow(at: indexPath)! as! StatusListTableViewCell
            
            currentCell.activityIndicator_View.isHidden = false
            currentCell.activityIndicator_View.startAnimating()
            SocketIOManager.sharedInstance.Delegate = self
            SocketIOManager.sharedInstance.changeStatus(status:self.statusSelec_Arry[0] as! String , from:Themes.sharedInstance.Getuser_id())

        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 36
    }
    
    
    func  statusUpdtFrmStatsLst(_ status: String){
        if status == "Updated"{
            self.statusTbl_View.reloadData()
            
            
        }
        else{
            
        }
        
        
    }
    func clearStatus(){
       let app = Themes.sharedInstance.GetAppname()
        let CheckUser:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.User_detail, attribute: "user_id", FetchString:Themes.sharedInstance.Getuser_id())
        if (!CheckUser){
            
        }
        else{
            
            let UpdateDic:[String:Any]=["status": NSLocalizedString("Online", comment:"Hey there! I am using ")]
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail , FetchString:Themes.sharedInstance.Getuser_id(), attribute:"user_id", UpdationElements: UpdateDic as NSDictionary?)
            getStatus()
        }
        
    }
    func  statusUpdated(_Updated:String)
    {
        
        if(_Updated != "CHECK")
        {
            if _Updated == "Updated"{
                
                getStatus()
                
                
            }
            else{
                
            }
        }
        
        
    }
    @IBAction func editAction(_ sender: UIButton) {
        let statusEditVC = storyboard?.instantiateViewController(withIdentifier: "StatusEditViewController") as! StatusEditViewController
        let transition = CATransition()
        transition.duration = 0.6
        transition.type = CATransitionType(rawValue: "flip")
        transition.subtype = CATransitionSubtype.fromRight
        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        
        statusEditVC.statusRecArray = statusRec
        self.pushView(statusEditVC, animated: false)
        
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        self.pop(animated: true)
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        getStatus()
        statusTbl_View.frame = CGRect(x:statusTbl_View.frame.origin.x , y: statusTbl_View.frame.origin.y, width:  statusTbl_View.frame.size.width, height: statusTbl_View.contentSize.height)
        
        // getRec()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        statusTbl_View.frame = CGRect(x:statusTbl_View.frame.origin.x , y: statusTbl_View.frame.origin.y, width:  statusTbl_View.frame.size.width, height: statusTbl_View.contentSize.height)
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        SocketIOManager.sharedInstance.Delegate = nil
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



