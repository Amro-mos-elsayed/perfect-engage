//
//  StatusEditViewController.swift
//
//
//  Created by CASPERON on 14/02/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit

class StatusEditViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,reloadTable {
    
    @IBOutlet weak var edit_TableView: UITableView!
    var statusRecArray = [NSObject]()
    var selectedStatus:String = String()
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
        
        edit_TableView.delegate = self
        edit_TableView.dataSource = self
        edit_TableView.isEditing = true
        edit_TableView.backgroundColor = UIColor.white
        print(statusRecArray)
        
        let nibName = UINib(nibName: "EditStatusTableViewCell", bundle: nil)
        edit_TableView.register(nibName, forCellReuseIdentifier: "EditStatusTableViewCell")
        edit_TableView.tableFooterView = UIView()
        
        
        // Do any additional setup after loading the view.
    }
    
    func reloadStatus() {
        self.getStatus()
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
        if getDic.count == 0{
            statusSelec_Arry.removeAllObjects()
            statusSelec_Arry.add("Hey there! I am using \(Themes.sharedInstance.GetAppname())")
            
        }
        else{
            getRec()
        }
        
        
    }
    
    func getRec(){
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
                    statusSelec_Arry.add("Hey there! I am using \(Themes.sharedInstance.GetAppname())")
                    
                }
                
                
            }
            
            //            let newStatusObject = StatusRec(status:statusList_Array[i] as! String,isSelect:false)
            //            statusRec.append(newStatusObject)
            
            
        }
        if checkStatus == "status not found"
        {
            
            let UpdateDic:[String:Any]=["status": "Hey there! I am using \(Themes.sharedInstance.GetAppname())"]
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail , FetchString:Themes.sharedInstance.Getuser_id() , attribute:"user_id", UpdationElements: UpdateDic as NSDictionary?)
        }
        
        edit_TableView.reloadData()
        
    }
    
    func tapFunction(tag:Int){
        
    }
    func storeDB() -> Bool{
        
        DatabaseHandler.sharedInstance.truncateDataForTable(Entityname: Constant.sharedinstance.status_List)
        for i in 0..<statusRec.count{
            
            let  getRec:StatusRec = statusRec[i]
            
            let checkStatus = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.status_List, attribute: "status_title", FetchString: getRec.status)
            if(!checkStatus)
            {
                let Dict:NSMutableDictionary=["status_id":"\(i)","status_title": getRec.status]
                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict, Entityname:Constant.sharedinstance.status_List)
            }
        }
        return  true
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statusRec.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = edit_TableView.dequeueReusableCell(withIdentifier: "EditStatusTableViewCell") as! EditStatusTableViewCell
        
        let getRec:StatusRec = statusRec[indexPath.row]
        cell.statusBtn.setTitleColor(UIColor.black, for: UIControl.State.normal)
        cell.statusBtn.setTitle(getRec.status, for: UIControl.State.normal)
        
        cell.statusBtn.addTarget(self, action: #selector(selectStatus), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("dwfdwf")
        
        
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCell.EditingStyle.delete {
            if((statusRec[indexPath.row] as StatusRec).isSelect == false)
            {
                statusRec.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            }
            else
            {
                Themes.sharedInstance.ShowNotification("You can't able to delete the current status", false)
            }
            
        }
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 38
    }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        //
        //        let itemToMove = statusRecArray[sourceIndexPath.row]
        //        statusRecArray.remove(at: sourceIndexPath.row)
        //        statusRecArray.insert(itemToMove, at: destinationIndexPath.row)
        
        let itemToMoveBase = statusRec[sourceIndexPath.row]
        statusRec.remove(at: sourceIndexPath.row)
        statusRec.insert(itemToMoveBase , at: destinationIndexPath.row)
    }
    
    
    func menuAction(){
        // edit_TableView.isEditing = true
        
    }
    
    @IBAction func deleteAll_Action(_ sender: UIButton) {
        
        
        let optionMenu = UIAlertController(title: nil, message: NSLocalizedString("Choose Option", comment: "comment") , preferredStyle: .actionSheet)
        
        // 2
        
        let  exitGroupAction = UIAlertAction(title: NSLocalizedString("Delete all status", comment: "comment") , style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            print("File Deleted")
            self.deleteStatusAction()
            //            currentCell.subDesc_Lbl.text =  "8 hours"
        })
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "comment"), style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        
        // 4
        optionMenu.addAction(exitGroupAction)
        optionMenu.addAction(cancelAction)
        
        // 5
        self.presentView(optionMenu, animated: true, completion: nil)
    }
    
    
    func deleteStatusAction(){
        
        if(statusRec.count == 1)
        {
            Themes.sharedInstance.ShowNotification("You can't able to delete the current status", false)
        }
        DatabaseHandler.sharedInstance.truncateDataForTable(Entityname: Constant.sharedinstance.status_List)
        var temp = Array<StatusRec>()
        for status in statusRec
        {
            if(status.isSelect == true)
            {
                temp.append(status)
            }
        }
        statusRec = temp
        //        statusRec.removeAll()
        let transition = CATransition()
        transition.duration = 0.6
        transition.type = CATransitionType(rawValue: "flip")
        transition.subtype = CATransitionSubtype.fromLeft
        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        edit_TableView.reloadData()
        let getBool:Bool = storeDB()
        
        if getBool == true{
            
            self.pop(animated: true)
            
        }
        
        
    }
    
    @IBAction func doneAction(_ sender: UIButton) {
        let transition = CATransition()
        transition.duration = 0.6
        transition.type = CATransitionType(rawValue: "flip")
        transition.subtype = CATransitionSubtype.fromLeft
        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        let getBool:Bool = storeDB()
        
        if getBool == true{
            
            self.pop(animated: true)
        }
    }
    
    @objc func selectStatus(sender:UIButton){
        if(sender.titleLabel?.text != nil)
        {
            
            selectedStatus = (sender.titleLabel?.text)!
            let yourStatusVC = storyboard?.instantiateViewController(withIdentifier:"YourStatusViewController") as! YourStatusViewController
            yourStatusVC.yourstatus = selectedStatus
            yourStatusVC.delagate = self
            self.pushView(yourStatusVC, animated: true)
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        edit_TableView.reloadData()
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

