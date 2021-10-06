//
//  CallLogVC.swift
//
//
//  Created by MV Anand Casp iOS on 24/10/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit

class CallLogVC: UIViewController,UISearchControllerDelegate,UISearchResultsUpdating,UISearchBarDelegate {
    lazy fileprivate var searchController = UISearchController(searchResultsController: nil)
    var searchActive:Bool = false
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var calldet_switch: UISegmentedControl!
    @IBOutlet weak var noLogView: UIView!

    @IBOutlet weak var clearall_Btn: UIButton!
    @IBOutlet weak var Edit_Btn: UIButton!
    
    var DataSource:NSMutableArray = NSMutableArray()
    var DataSourceDictArr:NSMutableArray!
    var SearchSourceDictArr:NSMutableArray!
    var ismissedCall:Bool = Bool()
    var isbeginEdit:Bool = Bool()
    
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        addNotificationListener()
        let nibName = UINib(nibName: "CallLogCell", bundle:nil)
        self.tableView.register(nibName, forCellReuseIdentifier: "CallLogCellID")
        self.tableView.estimatedRowHeight = 50
        searchActive = false
        searchController.delegate=self
        searchController.searchBar.delegate=self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = true
        //self.definesPresentationContext = true
        self.tableView.tableHeaderView = searchController.searchBar
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.tableFooterView = UIView()
        noLogView.isHidden = true
        ismissedCall = false
        calldet_switch.addTarget(self, action: #selector(self.segmentedControlValueChanged(segment:)), for: .valueChanged)
        isbeginEdit = false
        calldet_switch.selectedSegmentIndex = 0
        clearall_Btn.addTarget(self, action: #selector(self.ClearAll(Button:)), for: .touchUpInside)
        self.searchController.hidesNavigationBarDuringPresentation = false
        // Do any additional setup after loading the view.
    }
    
    @objc func ClearAll(Button:UIButton)
    {
        
        let sheet_action: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let clearAll: UIAlertAction = UIAlertAction(title: NSLocalizedString("Clear All", comment: "comment"), style: .destructive) { action -> Void in
            self.clearAllCalls()
            
        }
        let CancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "comment"), style: .cancel) { action -> Void in
        }
        sheet_action.addAction(clearAll)
        sheet_action.addAction(CancelAction)
        self.presentView(sheet_action, animated: true, completion: nil)
        
        
        
        
    }
    
    func clearAllCalls() {
        tableView.setEditing(false, animated: true)
        isbeginEdit = false
        clearall_Btn.isHidden = true
        Edit_Btn.setTitle(NSLocalizedString("Edit", comment: "Edit"), for: .normal)
        if(DataSourceDictArr.count > 0)
        {
            let predicate:NSPredicate = NSPredicate(format: "user_id == %@", Themes.sharedInstance.Getuser_id())
            DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Call_detail, Predicatefromat: predicate, Deletestring: "user_id", AttributeName: Themes.sharedInstance.Getuser_id())
            ReloadData()
        }
    }
    
    
    @objc func segmentedControlValueChanged(segment: UISegmentedControl) {
        if segment.selectedSegmentIndex == 0 {
            ismissedCall = false
        }
        else
        {
            ismissedCall = true
        }
        searchController.searchBar.resignFirstResponder()
        searchController.isActive = false
        searchActive = false
        if SearchSourceDictArr != nil , SearchSourceDictArr.count >= 1 {
        SearchSourceDictArr.removeAllObjects()
        }
        ReloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ReloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        searchController.searchBar.resignFirstResponder()
        searchController.isActive = false
        SocketIOManager.sharedInstance.Delegate = nil
        
    }
    
    func ReloadData()
    {
        
        Edit_Btn.isHidden = true
        DataSourceDictArr = NSMutableArray()
        SearchSourceDictArr = NSMutableArray()
        let predicate1:NSPredicate = NSPredicate(format: "user_id == %@", Themes.sharedInstance.Getuser_id())
        let predicate2:NSPredicate = NSPredicate(format: "call_status == %@","2")
        let predicate3:NSPredicate = NSPredicate(format: "call_status == %@","5")
        let typePredicate:NSCompoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate2,predicate3])
        var CallRecordArr:NSArray = NSArray()
        if(ismissedCall)
        {
            
            let CompoundPre:NSCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1,typePredicate])
            CallRecordArr   = DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Call_detail, SortDescriptor: "timestamp", predicate: CompoundPre, Limit: 0) as! NSArray
            
        }
        else
        {
            
            CallRecordArr   = DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Call_detail, SortDescriptor: "timestamp", predicate: predicate1, Limit: 0) as! NSArray
            
        }
        
        let descriptor: NSSortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
        let sortedResults = CallRecordArr.sortedArray(using: [descriptor])
        
        CallRecordArr = sortedResults as NSArray
        if(CallRecordArr.count > 0)
        {
            Edit_Btn.isHidden = false
            noLogView.isHidden = true
            if(CallRecordArr.count > 0)
            {
                DataSource = NSMutableArray()
                for i in 0..<CallRecordArr.count
                {
                    let objCall_Record:calllog_Record = calllog_Record()
                    let objCall_Detail:NSManagedObject = CallRecordArr[i] as! NSManagedObject
                    objCall_Record.call_status = Themes.sharedInstance.CheckNullvalue(Passed_value: objCall_Detail.value(forKey: "call_status"))
                    objCall_Record.call_type = Themes.sharedInstance.CheckNullvalue(Passed_value: objCall_Detail.value(forKey: "call_type"))
                    objCall_Record.doc_id = Themes.sharedInstance.CheckNullvalue(Passed_value: objCall_Detail.value(forKey: "doc_id"))
                    objCall_Record.from = Themes.sharedInstance.CheckNullvalue(Passed_value: objCall_Detail.value(forKey: "from"))
                    objCall_Record.id = Themes.sharedInstance.CheckNullvalue(Passed_value:  objCall_Detail.value(forKey: "id"))
                    objCall_Record.timestamp = Themes.sharedInstance.CheckNullvalue(Passed_value:objCall_Detail.value(forKey: "timestamp"))
                    objCall_Record.to = Themes.sharedInstance.CheckNullvalue(Passed_value:objCall_Detail.value(forKey: "to"))
                    objCall_Record.call_duration = Themes.sharedInstance.CheckNullvalue(Passed_value:objCall_Detail.value(forKey: "call_duration"))
                    objCall_Record.msidn = Themes.sharedInstance.CheckNullvalue(Passed_value:objCall_Detail.value(forKey: "msidn"))
                    objCall_Record.duration = Themes.sharedInstance.CheckNullvalue(Passed_value:objCall_Detail.value(forKey: "duration"))
                    objCall_Record.date = self.ReturnDate(timestamp: objCall_Record.timestamp)
                    
                    if(objCall_Record.from != Themes.sharedInstance.Getuser_id())
                    {
                        objCall_Record.user_name = Themes.sharedInstance.ReturnFavName(opponentDetailsID: objCall_Record.from, msginid: objCall_Record.msidn)
                        objCall_Record.user_id = objCall_Record.from
                        objCall_Record.OppUser_id = objCall_Record.from
                    }
                    else
                    {
                        objCall_Record.user_name = Themes.sharedInstance.ReturnFavName(opponentDetailsID: objCall_Record.to, msginid: objCall_Record.msidn)
                        objCall_Record.user_id = objCall_Record.to
                        objCall_Record.OppUser_id = objCall_Record.to
                        
                    }
                    
                    if(objCall_Record.call_status == "5" || objCall_Record.call_status == "2")
                    {
                        objCall_Record.calllog_type = "0"
                    }
                    else  if(objCall_Record.from == Themes.sharedInstance.Getuser_id())
                    {
                        objCall_Record.calllog_type = "1"
                        
                    }
                    else if(objCall_Record.from != Themes.sharedInstance.Getuser_id())
                    {
                        objCall_Record.calllog_type = "2"
                    }
                    
                    if(objCall_Record.calllog_type == "0")
                    {
                        if(objCall_Record.from == Themes.sharedInstance.Getuser_id())
                        {
                            objCall_Record.calllog_type = "1"
                        }
                    }
                    if(CallRecordArr.count > 0 && objCall_Record.calllog_type == "0" && ismissedCall)
                    {
                        DataSource.add(objCall_Record)
                    }
                    else if(!ismissedCall)
                    {
                        DataSource.add(objCall_Record)
                    }
                }
                DataSource = NSMutableArray(array: DataSource.reversed())
                print(DataSource.count)
                if(DataSource.count > 0)
                {
                    var Dict:[String:Any] = [:]
                    repeat
                    {
                        
                        let objrec:calllog_Record = DataSource[0] as! calllog_Record
                        Dict["timestamp"] = objrec.timestamp
                        Dict["name"] = objrec.user_name
                        Dict["call_type"] = objrec.call_type
//                        let predicate1 = NSPredicate(format: "date == %@",objrec.date)
//                        let predicate2 = NSPredicate(format: "calllog_type == %@",objrec.calllog_type)
//                        let predicate3 = NSPredicate(format: "msidn == %@",objrec.msidn)
//                        let predicate4 = NSPredicate(format: "call_type == %@",objrec.call_type)
//                        let cmpPredicate:NSCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1,predicate2,predicate3,predicate4])
//                        let FilteredArr:NSArray = DataSource.filtered(using: cmpPredicate) as NSArray
                        let FilteredArr:NSArray = DataSource.filter{((($0 as? calllog_Record)?.date == objrec.date)
                            && (($0 as? calllog_Record)?.calllog_type == objrec.calllog_type)
                            && (($0 as? calllog_Record)?.msidn == objrec.msidn)
                            && (($0 as? calllog_Record)?.call_type == objrec.call_type))} as NSArray
                        
                        if(FilteredArr.count > 0)
                        {
                            Dict["detail"] = FilteredArr
                            for i in 0..<FilteredArr.count
                            {
                                let objrec:calllog_Record = FilteredArr[i] as! calllog_Record
                                DataSource.remove(objrec)
                            }
                            Dict["call_count"] = "\(FilteredArr.count)"
                            
                            DataSourceDictArr.add(Dict)
                        }
                        else
                        {
                            DataSource.remove(objrec)
                        }
                        
                        
                    } while DataSource.count > 0
                    
                    print(DataSourceDictArr)
                    
                }
                
                //                DataSource.add(objCall_Record)
                self.tableView.isHidden = false
                self.tableView.reloadData()
            }
            else
            {
                self.tableView.isHidden = true
                noLogView.isHidden = false
                
            }
            
        }
        else
        {
            self.tableView.isHidden = true
            noLogView.isHidden = false
        }
    }
    
    func ReturnDate(timestamp:String)->String
    {
        var dateFormatStr:String = ""
        
        if(timestamp != "")
        {
            let date = Date(timeIntervalSince1970: TimeInterval(timestamp)!/1000)
            let dateFormatters = DateFormatter()
            dateFormatters.dateFormat = "dd/MM/yyyy"
            dateFormatters.timeZone = TimeZone(abbreviation: "GMT")
            dateFormatters.timeZone = NSTimeZone.system
            dateFormatStr = dateFormatters.string(from: date)
            
        }
        return dateFormatStr
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        searchActive = true
        searchController.obscuresBackgroundDuringPresentation = false
        if (searchController.searchBar.text?.isEmpty == false) {
            SearchSourceDictArr.removeAllObjects()
            if(searchController.searchBar.text! == ""){
                searchActive = false
            }
            else
            {
                let namesBeginningWithLetterPredicate = NSPredicate(format: "(name CONTAINS[c] $letter)")
                let array = (DataSourceDictArr as NSMutableArray).filtered(using: namesBeginningWithLetterPredicate.withSubstitutionVariables(["letter": searchController.searchBar.text!]))
                SearchSourceDictArr = NSMutableArray(array: array)
            }
            tableView.reloadData()
            
        }
        else{
            searchActive = false;
            SearchSourceDictArr.removeAllObjects()
            tableView.reloadData()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func CheckDate(fromtimestamp:String,totimestamp:String)->Int
    {
        var _:String = ""
        var numberOfDays:Int = 0
        if(totimestamp != "")
        {
            var fromdate = Date(timeIntervalSince1970: TimeInterval(fromtimestamp)!/1000)
            var todate = Date(timeIntervalSince1970: TimeInterval(totimestamp)!/1000)
            
            let dateFormatters = DateFormatter()
            dateFormatters.dateFormat = "dd/MM/yyyy"
            dateFormatters.timeZone = TimeZone(abbreviation: "GMT")
            dateFormatters.timeZone = NSTimeZone.system
            let dateStr:String = dateFormatters.string(from: fromdate as Date)
            let dateStr1:String = dateFormatters.string(from: todate as Date)
            
            
            fromdate = dateFormatters.date(from: dateStr as String)!
            todate = dateFormatters.date(from: dateStr1 as String)!
            
            numberOfDays = self.ReturnNumberofDays(fromdate: fromdate, todate: todate)!
            
        }
        
        return numberOfDays
        
    }
    func ReturnNumberofDays(fromdate:Date,todate:Date)->Int?
    {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: fromdate, to: todate)
        if(components.day! == 0)
        {
            
            if(Calendar.current.isDate(fromdate, inSameDayAs: todate))
            {
                return 0
            }
            else
            {
                return 0
            }
            
        }
        return components.day
        
    }
    
    @IBAction func DidclickEditBtn(_ sender: Any) {
        if(isbeginEdit)
        {
            Edit_Btn.setTitle(NSLocalizedString("Edit", comment: "Edit"), for: .normal)
            isbeginEdit = false
            clearall_Btn.isHidden = true
            tableView.setEditing(false, animated: true)
        }
        else
        {
            Edit_Btn.setTitle("Done", for: .normal)
            isbeginEdit = true
            clearall_Btn.isHidden = false
            tableView.setEditing(true, animated: true)
        }
        
    }
    
    func addNotificationListener() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            weak.ReloadData()
        }
        
    }
    
    func removeNotificationListener() {
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        removeNotificationListener()
    }

}

extension CallLogVC:UITableViewDataSource,UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int {
        
        
        return 1
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return ""
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive == true){
            return SearchSourceDictArr.count
        }
        
        return DataSourceDictArr.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:CallLogCell  = tableView.dequeueReusableCell(withIdentifier: "CallLogCellID") as! CallLogCell
        var Dict:NSDictionary = NSDictionary()
        if(searchActive == true)
        {
            Dict =   SearchSourceDictArr[indexPath.row] as! NSDictionary
        }
        else
        {
            Dict =   DataSourceDictArr[indexPath.row] as! NSDictionary
        }
        let objCallRecord:calllog_Record = (Dict["detail"] as! NSArray)[0] as! calllog_Record
        if(objCallRecord.call_type == "0")
        {
            cell.calltype_imgView.image = #imageLiteral(resourceName: "call_icon")
        }
        else
        {
            cell.calltype_imgView.image = #imageLiteral(resourceName: "video_icon")
        }
        cell.call_statusLbl.textColor = UIColor.lightGray
        
        if(objCallRecord.calllog_type == "0")
        {
            cell.call_statusLbl.text = NSLocalizedString("Missed", comment: "Missed")
            cell.user_name_Lbl.textColor = UIColor.red
        }
        else if(objCallRecord.calllog_type == "1")
        {
            cell.call_statusLbl.text = NSLocalizedString("Outgoing", comment: "Outgoing")
            cell.user_name_Lbl.textColor = UIColor.black
            
        }
        else if (objCallRecord.calllog_type == "2")
        {
            cell.call_statusLbl.text = NSLocalizedString("Incoming", comment: "Incoming")
            cell.user_name_Lbl.textColor = UIColor.black
        }
        cell.user_image.setProfilePic(objCallRecord.user_id, "single")
        
        let DayStr:String = Themes.sharedInstance.ReturnDateTimeFormat(timestamp: objCallRecord.timestamp)
        let TimeStr:String = Themes.sharedInstance.ReturnTimeForChat(timestamp: objCallRecord.timestamp)
        
        if(DayStr == "Today")
        {
            cell.time_Lbl.text = TimeStr
        }
        else
        {
            cell.time_Lbl.text = DayStr
        }
        cell.user_name_Lbl.setNameTxt(objCallRecord.user_id, "single")

        if(Int(Dict["call_count"] as! String)! > 1)
        {
            cell.user_name_Lbl.text?.append("(\(Themes.sharedInstance.CheckNullvalue(Passed_value: Dict["call_count"])))")
        }
        
        cell.callinfo_Btn.tag = indexPath.row
        cell.callinfo_Btn.addTarget(self, action: #selector(self.DidclickInfoBtn(sender:)), for: .touchUpInside)
        cell.callinfo_Btn.tintColor = CustomColor.sharedInstance.themeColor
        return cell
    }
    @objc func DidclickInfoBtn(sender:UIButton)
    {
        searchController.searchBar.resignFirstResponder()
        searchController.isActive = false
        
        var Dict:NSDictionary = NSDictionary()
        if(searchActive == true)
        {
            Dict =   SearchSourceDictArr[sender.tag] as! NSDictionary
        }
        else
        {
            Dict =   DataSourceDictArr[sender.tag] as! NSDictionary
        }
        
        let objArr:NSArray = Dict["detail"] as! NSArray
        
        let objCallRecord:calllog_Record = (Dict["detail"] as! NSArray)[0] as! calllog_Record
        
        let ObjCalldetailVC:CalldetailVC=self.storyboard?.instantiateViewController(withIdentifier: "CalldetailVCID") as! CalldetailVC
        ObjCalldetailVC.DataSourceDictArr  = NSMutableArray(array: objArr)
        ObjCalldetailVC.user_id = objCallRecord.OppUser_id
        ObjCalldetailVC.status =  Dict["call_type"] as! String
        self.searchController.searchBar.resignFirstResponder()
        self.searchController.isActive = false
        self.pushView(ObjCalldetailVC, animated: true)
        
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            let objDict:NSDictionary = DataSourceDictArr.object(at: indexPath.row) as! NSDictionary
            let objArr:NSArray = objDict["detail"] as! NSArray
            if(objArr.count > 0)
            {
                for i in 0..<objArr.count
                {
                    let objCall_record:calllog_Record = objArr[i] as! calllog_Record
                    let predicate:NSPredicate = NSPredicate(format: "timestamp == %@", objCall_record.timestamp)
                    DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Call_detail, Predicatefromat: predicate, Deletestring: "timestamp", AttributeName: objCall_record.timestamp)
                }
            }
            DataSourceDictArr.removeObject(at: indexPath.row)
            if(DataSourceDictArr.count == 0)
            {
                Edit_Btn.isHidden = true
                tableView.isHidden = true
                noLogView.isHidden = false
                tableView.setEditing(false, animated: true)
                isbeginEdit = false
                clearall_Btn.isHidden = true
                Edit_Btn.setTitle(NSLocalizedString("Edit", comment: "Edit"), for: .normal)
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else if editingStyle == .insert {
            // Not used in our example, but if you were adding a new row, this is where you would do it.
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var Dict:NSDictionary = NSDictionary()
        if(!isbeginEdit)
        {
            if(searchActive == true)
            {
                Dict =   SearchSourceDictArr[indexPath.row] as! NSDictionary
            }
            else
            {
                Dict =   DataSourceDictArr[indexPath.row] as! NSDictionary
            }
            
            let objCallRecord:calllog_Record = (Dict["detail"] as! NSArray)[0] as! calllog_Record
            
            if(!Themes.sharedInstance.checkBlock(id: objCallRecord.OppUser_id))
            {
                if(SocketIOManager.sharedInstance.socket.status == .connected)
                {
                    let status:String = Dict["call_type"] as! String
                    
                    
                    
                    var timestamp:String =  String(Date().ticks)
                    var servertimeStr:String = Themes.sharedInstance.getServerTime()
                    
                    if(servertimeStr == "")
                    {
                        servertimeStr = "0"
                    }
                    let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
                    timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
                    
                    let docID = "\(Themes.sharedInstance.Getuser_id())-\(objCallRecord.OppUser_id)-\(timestamp)"
                    let param:NSDictionary = ["from":Themes.sharedInstance.Getuser_id(),"to":Themes.sharedInstance.CheckNullvalue(Passed_value: objCallRecord.OppUser_id),"type":Int(status)!,"id":Int64(timestamp)!,"toDocId":docID, "roomid" : timestamp]
                    SocketIOManager.sharedInstance.emitCallDetail(Param: param as! [String : Any])
                    AppDelegate.sharedInstance.openCallPage(type: status, roomid: timestamp, id: objCallRecord.OppUser_id)
                    
                    
                    
                }
                else
                {
                    self.view.makeToast(message: Constant.sharedinstance.ErrorMessage, duration: 3, position: HRToastActivityPositionDefault)
                }
            }
            else
            {
                Themes.sharedInstance.showBlockalert(id: objCallRecord.OppUser_id)
            }
            
            
            
        }
    }
    
}
