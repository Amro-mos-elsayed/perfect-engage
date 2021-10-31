
//
//  SelectShareContactViewController.swift
//
//
//  Created by CASPERON on 05/04/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit
import SDWebImage
class SelectShareContactViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate{
    @IBOutlet weak var addNameLbl: UILabel!
    var passingRecord:FavRecord = FavRecord()
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var shareContact_TableView: UITableView!
    fileprivate var hasSearchIndex = true
    var selectedName:String = String()
    //    lazy fileprivate var searchController = UISearchController(searchResultsController: nil)
    var ChatPrerecordArr:NSMutableArray=NSMutableArray()
    var countSortArr:NSMutableArray = NSMutableArray()
    var headerTitle:NSArray = NSArray()
    var searchActive:Bool = false
    var searchArray = [NSObject]()
    var user_id:String = String()
    var searchCountArry = [NSObject]()
    var searchContactArr = [NSObject]()
    var addNameArr = NSMutableArray()
    var addIdArr = NSMutableArray()
    var groupUsersArray:NSArray = NSArray()
    var groupUseNameArr:NSMutableArray = NSMutableArray()
    var GroupnameStr:String = String()
    var contact_share:Bool = false
    var contactID:String = String()
    var usersList:NSArray = NSArray()
    var FavList : NSMutableArray=NSMutableArray()
    var userfavRecord:[FavRecord]=[FavRecord]()
    var Share : NSMutableArray=NSMutableArray()
    var type:NSMutableArray=NSMutableArray()
    var userNames:NSMutableArray=NSMutableArray()
    
    var messageDatasourceArr:NSMutableArray = NSMutableArray()
    var isFromStatus : Bool = Bool()
    fileprivate var data_Source: DataSource!
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    var isFromForward:Bool = Bool()
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        
        print(contactID)
        let nibName = UINib(nibName:"SelectContactTableViewCell", bundle: nil)
        shareContact_TableView.register(nibName, forCellReuseIdentifier: "SelectContactTableViewCell")
        shareContact_TableView.tableFooterView = UIView()
        let bottomBorder = CALayer()
        let bottomWidth = CGFloat(2.0)
        bottomBorder.borderColor = UIColor.blue.cgColor
        bottomBorder.frame = CGRect(x: 0, y:  bottomView.frame.minY+4, width:  shareContact_TableView.frame.size.width, height: 1)
        // shareContact_TableView.estimatedRowHeight = 20
        bottomBorder.borderWidth = bottomWidth
        bottomView.layer.addSublayer(bottomBorder)
        bottomView.layer.masksToBounds = true
        
        headerTitle = ["FREQUENTLY CONTACTED","RECENT CHATS"]
        searchBar.delegate  = self
        searchBar.showsCancelButton = false
        
        //        searchController.delegate=self
        //        searchController.searchResultsUpdater = self
        
        bottomAnimation()
        getRecentChat()
        GetFavContact()
        
        // Do any additional setup after loading the view.
    }
    
    //    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    //            self.searchBar.showsCancelButton = false;
    //    }
    
    
    func LoadSearchArr()
    {
        
        
        //        oppid
        //        name
        //        Substringname
        //        isgroup
        //
        
    }
    
    func bottomAnimation(){
        
        if addNameArr.count != 0{
            
            addNameLbl.text!.remove(at: (addNameLbl.text?.startIndex)!)
            self.bottomView.isHidden = false
        }
        else{
            self.bottomView.isHidden = true
        }
        
    }
    
    func getRecentChat(){
        
        ChatPrerecordArr = NSMutableArray()
        let CheckPreloadRecord=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_id", FetchString: Themes.sharedInstance.Getuser_id())
        if(CheckPreloadRecord)
        {
            let UsercommonidArr:NSMutableArray=NSMutableArray()
            let p1 = NSPredicate(format: "user_id = %@", Themes.sharedInstance.Getuser_id())
            let p2 = NSPredicate(format: "chat_type != %@", "secret")
            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2])
            let chatintiatedDetailArr=DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Chat_intiated_details, SortDescriptor: nil, predicate: predicate,Limit:0) as! NSArray
            if(chatintiatedDetailArr.count > 0)
            {
                for i in 0..<chatintiatedDetailArr.count
                {
                    let ReponseDict:NSManagedObject = chatintiatedDetailArr[i] as! NSManagedObject
                    UsercommonidArr.add(Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "user_common_id")));
                }
                if(UsercommonidArr.count > 0)
                {
                    for i in 0..<UsercommonidArr.count
                    {
                        let CheckUserChat:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "user_common_id", FetchString: UsercommonidArr[i] as? String)
                        if(CheckUserChat)
                        {
                            
                            let ReponseDict:NSManagedObject = (DatabaseHandler.sharedInstance.FetchFromDatabaseWithLimit(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "user_common_id", Predicatefromat: "==", FetchString: UsercommonidArr[i] as? String, Limit: 1, SortDescriptor: "date") as NSArray)[0] as! NSManagedObject
                            let chatprerecord=Chatpreloadrecord()
                            
                            chatprerecord.ismessagetype = Themes.sharedInstance.CheckNullvalue(Passed_value:ReponseDict.value(forKey: "type"))
                            
                            chatprerecord.ischattype=Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "chat_type"))
                            
                            chatprerecord.ismessagestatus=Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "message_status"))
                            
                            if(chatprerecord.ischattype == "single")
                            {
                                if(Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "to")) == Themes.sharedInstance.Getuser_id())
                                {
                                    chatprerecord.opponentid=Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "from"))
                                }
                                else
                                {
                                    chatprerecord.opponentid=Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "to"))
                                }
                                
                                if(chatprerecord.opponentid != Themes.sharedInstance.Getuser_id())
                                {
                                    chatprerecord.oppopnentnumber=Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "contactmsisdn"))
                                }
                                
                                let FavDict:NSArray = (DatabaseHandler.sharedInstance.FetchFromDatabaseWithLimit(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "id", Predicatefromat: "==", FetchString: chatprerecord.opponentid, Limit: 1, SortDescriptor: nil) as NSArray)
                                
                                
                                if(FavDict.count > 0)
                                {
                                    let favddetail:NSManagedObject=FavDict[0] as! NSManagedObject
                                    
                                    chatprerecord.opponentname=Themes.sharedInstance.CheckNullvalue(Passed_value: favddetail.value(forKey: "name"))
                                    
                                    if(chatprerecord.opponentname == "")
                                    {
                                        chatprerecord.opponentname=Themes.sharedInstance.CheckNullvalue(Passed_value: favddetail.value(forKey: "msisdn"))
                                        
                                    }
                                    chatprerecord.opponentimage=Themes.sharedInstance.CheckNullvalue(Passed_value: favddetail.value(forKey: "profilepic"))
                                    
                                    chatprerecord.oppopnentnumber=Themes.sharedInstance.CheckNullvalue(Passed_value: favddetail.value(forKey: "msisdn"))
                                }
                                else
                                {
                                    chatprerecord.opponentname=Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "contactmsisdn"))
                                    
                                    chatprerecord.opponentimage=""
                                }
                            }
                            else if(chatprerecord.ischattype == "group")
                            {
                                let groupFavArr:NSArray=DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: "\(Constant.sharedinstance.Group_details)", attribute: "user_common_id", FetchString: UsercommonidArr[i] as? String, SortDescriptor: "timestamp") as! NSArray
                                
                                if(groupFavArr.count > 0)
                                {
                                    let groupDict = groupFavArr[0] as! NSManagedObject
                                    
                                    chatprerecord.opponentid = Themes.sharedInstance.CheckNullvalue(Passed_value: groupDict.value(forKey: "id"))
                                    chatprerecord.opponentname = Themes.sharedInstance.CheckNullvalue(Passed_value: groupDict.value(forKey: "displayName"))
                                    
                                    let groupData:NSData?=groupDict.value(forKey: "groupUsers") as? NSData
                                    var usersList = NSArray()
                                    if(groupData != nil)
                                    {
                                        usersList = NSKeyedUnarchiver.unarchiveObject(with: groupData! as Data) as! NSArray
                                    }
                                    userNames = NSMutableArray()
                                    for user in usersList{
                                        let getVal = user as! NSDictionary
                                        if(getVal["ContactName"] as! String != Themes.sharedInstance.GetMyPhonenumber())
                                        {
                                            userNames.add(getVal["ContactName"] as! String)
                                        }
                                        else
                                        {
                                            userNames.add("You".localized())
                                        }
                                    }
                                    
                                    chatprerecord.oppopnentnumber = userNames.componentsJoined(by: ",")
                                    chatprerecord.opponentimage = Themes.sharedInstance.CheckNullvalue(Passed_value: groupDict.value(forKey: "displayavatar"))
                                    
                                }
                            }
                            
                            
                            
                            let p3 = NSPredicate(format: "user_common_id = %@", (UsercommonidArr[i] as? String)!)
                            
                            let p4 = NSPredicate(format: "(from != %@) AND message_status != 3", Themes.sharedInstance.Getuser_id())
                            
                            let predicate1 = NSCompoundPredicate(andPredicateWithSubpredicates: [p3, p4])
                            
                            let MessageCount:NSArray=DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Chat_one_one, SortDescriptor: nil, predicate: predicate1, Limit: 0) as! NSArray
                            if(MessageCount.count != 0)
                            {
                                chatprerecord.opponentunreadmessagecount="\(MessageCount.count)"
                            }
                            else
                            {
                                chatprerecord.opponentunreadmessagecount=""
                            }
                            print("\(chatprerecord.opponentunreadmessagecount)")
                            
                            chatprerecord.opponentlastmessage=Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "payload"))
                            
                            chatprerecord.opponentlastmessageDate=Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "timestamp"))
                            
                            chatprerecord.opponentlastmessageid=Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "convId"))
                            
                            chatprerecord.userCommonID = Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "user_common_id"))
                            
                            
                            chatprerecord.isSelect = false
                            
                            print(ReponseDict.value(forKey: "payload")!)
                            let ChatArr:NSArray=DatabaseHandler.sharedInstance.FetchFromDatabaseWithLimit(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "user_common_id", Predicatefromat: "==", FetchString: UsercommonidArr[i] as? String, Limit: 0, SortDescriptor: "timestamp") as NSArray
                            
                            
                            print(ChatArr.count)
                            chatprerecord.messageCount = String(ChatArr.count)
                            
                            if userNames.contains("You".localized()) || userNames.contains("You"){
                                ChatPrerecordArr.add(chatprerecord)
                            }else if(chatprerecord.ischattype == "single"){
                                ChatPrerecordArr.add(chatprerecord)
                            }
                            else if(chatprerecord.ischattype == "group")
                            {
                                ChatPrerecordArr.add(chatprerecord)
                            }
                            
                            
                        }
                    }
                    
                    
                }
                if(ChatPrerecordArr.count > 0)
                {
                    var SortArray:NSArray=NSArray(array: ChatPrerecordArr)
                    SortArray = SortArray.sorted{(Themes.sharedInstance.shouldSortChatObj(first: $0, second: $1))} as NSArray
                    
                    ChatPrerecordArr=NSMutableArray(array: SortArray)
                    var sortCountArr:NSArray=NSArray(array: ChatPrerecordArr)
                    sortCountArr = sortCountArr.filter{($0 as? Chatpreloadrecord != nil)}.sorted{(($0 as! Chatpreloadrecord).messageCount > ($1 as! Chatpreloadrecord).messageCount)} as NSArray
                    countSortArr=NSMutableArray(array: sortCountArr)
                    
                    
                    for  _ in 0..<ChatPrerecordArr.count/2{
                        countSortArr.removeObject(at: countSortArr.count-1)
                    }
                    
                }
                
            }
            
            
        }
        
        for item in ChatPrerecordArr {
            if let item = item as? Chatpreloadrecord {
                if item.opponentid == contactID{
                    ChatPrerecordArr.remove(item)
                    break // very important
                }
            }
        }
        
        for item in countSortArr {
            if let item = item as? Chatpreloadrecord {
                if item.opponentid == contactID{
                    countSortArr.remove(item)
                    break // very important
                }
            }
        }
        
        shareContact_TableView.reloadData()
    }
    
    
    func GetFavContact()
    {
        FavList = self.returnFavArr()
    }
    
    
    func returnFavArr() ->NSMutableArray
    {
        let SortedArr=NSMutableArray()
        let FavArr:NSArray=DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "user_id", FetchString: Themes.sharedInstance.Getuser_id(), SortDescriptor: "name") as! NSArray
        var j=0;
        for _ in 0..<FavArr.count
        {
            
            if(FavArr.count > 0)
            {
                let favRecord:FavRecord=FavRecord()
                
                let ResponseDict = FavArr[j] as! NSManagedObject
                
                favRecord.name=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "name"))
                
                favRecord.countrycode=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "countrycode"))
                
                favRecord.id=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "id"))
                favRecord.is_add=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "is_add"))
                
                favRecord.msisdn=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "msisdn"))
                
                favRecord.phnumber=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "phnumber"))
                
                favRecord.profilepic=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "profilepic"))
                favRecord.type = "single"
                
                favRecord.status = Themes.sharedInstance.base64ToString(Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "status")))
                
                favRecord.contact_ID = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "contact_id"))
                
                if(favRecord.contact_ID == contactID){
                    //SortedArr.add(favRecord)
                }else{
                    SortedArr.add(favRecord)
                }
                j=j+1
                
            }
            
            
        }
        
        let p1 = NSPredicate(format: "user_id = %@", Themes.sharedInstance.Getuser_id())
        let p2 = NSPredicate(format: "chat_type = %@", "group")
        
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2])
        let chatlist=DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Chat_intiated_details, SortDescriptor: nil, predicate: predicate,Limit:0) as! NSArray
        
        for index in chatlist
        {
            let ResponseDict = index as! NSManagedObject
            
            let groupFavArr:NSArray=DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: "\(Constant.sharedinstance.Group_details)", attribute: "user_common_id", FetchString: ResponseDict.value(forKey: "user_common_id") as? String, SortDescriptor: "displayName") as! NSArray
            
            
            for index in groupFavArr
            {
                
                let favRecord:FavRecord=FavRecord()
                
                let ResponseDict = index as! NSManagedObject
                
                favRecord.name=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "displayName"))
                favRecord.id=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "id"))
                favRecord.profilepic = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "displayavatar"))
                favRecord.type = "group"
                
                let groupData:NSData?=ResponseDict.value(forKey: "groupUsers") as? NSData
                var usersList = NSArray()
                if(groupData != nil)
                {
                    usersList = NSKeyedUnarchiver.unarchiveObject(with: groupData! as Data) as! NSArray
                }
                let userNames = NSMutableArray()
                for user in usersList{
                    let getVal = user as! NSDictionary
                    
                    if(getVal["id"] as! String != Themes.sharedInstance.Getuser_id())
                    {
                        if(getVal["ContactName"] as? String != nil){
                            userNames.add(getVal["ContactName"] as! String)
                        }
                        
                    }
                    else
                    {
                        userNames.add("You".localized())
                    }
                }
                
                favRecord.phnumber = userNames.componentsJoined(by: ",")
                
                SortedArr.add(favRecord)
            }
            
            
        }
        return SortedArr
    }
    
    func sortContactArr(){
        
        
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        
        
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            
            return 40
            
        }
            
        else if  section == 1{
            return 50
        }
        else{
            return 30
        }
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if searchActive == false {
            return 2
        }
        else
        {
            return 1
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UITableViewHeaderFooterView()
        
        if(searchActive)
        {
            
            let headerView = UITableViewHeaderFooterView()
            let label = UILabel(frame: CGRect(x: 20, y: 10 , width: self.view.frame.width, height: 30))
            label.font = UIFont.systemFont(ofSize: 12.0)
            label.textColor = UIColor.lightGray
            label.text = "CONTACTS :"
            headerView.addSubview(label)
            let bottomBorderColor = UIColor(red: 246/255.0, green: 246/255.0, blue: 246/255.0, alpha: 1)
            let headerBottom_Clr = UIColor(red: 224/255.0, green: 224/255.0, blue: 224/255.0, alpha: 1)
            //headerView.backgroundColor = bottomBorderColor
            headerView.contentView.backgroundColor = bottomBorderColor
            let bottomBorder = CALayer()
            let bottomWidth = CGFloat(2.0)
            bottomBorder.borderColor = headerBottom_Clr.cgColor
            bottomBorder.frame = CGRect(x: 0, y: label.frame.maxY-1, width:  shareContact_TableView.frame.size.width, height: 1)
            bottomBorder.borderWidth = bottomWidth
            headerView.contentView.layer.addSublayer(bottomBorder)
            headerView.contentView.layer.masksToBounds = true
            return headerView
        }
        else{
            if section  == 0{
                
                let headerView = UITableViewHeaderFooterView()
                let label = UILabel(frame: CGRect(x: 20, y: 10 , width: self.view.frame.width, height: 30))
                label.font = UIFont.systemFont(ofSize: 12.0)
                label.textColor = UIColor.lightGray
                label.text = "FREQUENTLY CONTACTED :"
                headerView.addSubview(label)
                let bottomBorderColor = UIColor(red: 246/255.0, green: 246/255.0, blue: 246/255.0, alpha: 1)
                let headerBottom_Clr = UIColor(red: 224/255.0, green: 224/255.0, blue: 224/255.0, alpha: 1)
                //headerView.backgroundColor = bottomBorderColor
                headerView.contentView.backgroundColor = bottomBorderColor
                let bottomBorder = CALayer()
                let bottomWidth = CGFloat(2.0)
                bottomBorder.borderColor = headerBottom_Clr.cgColor
                bottomBorder.frame = CGRect(x: 0, y: label.frame.maxY-1, width:  shareContact_TableView.frame.size.width, height: 1)
                bottomBorder.borderWidth = bottomWidth
                headerView.contentView.layer.addSublayer(bottomBorder)
                headerView.contentView.layer.masksToBounds = true
                return headerView
            }
            if section == 1{
                
                let headerView = UITableViewHeaderFooterView()
                let label = UILabel(frame: CGRect(x: 20, y: 23 , width: self.view.frame.width, height: 30))
                label.font = UIFont.systemFont(ofSize: 12.0)
                label.textColor = UIColor.lightGray
                label.text = "RECENT CONTACTS"
                headerView.addSubview(label)
                let bottomBorderColor = UIColor(red: 246/255.0, green: 246/255.0, blue: 246/255.0, alpha: 1)
                let headerBottom_Clr = UIColor(red: 224/255.0, green: 224/255.0, blue: 224/255.0, alpha: 1)
                // headerView.backgroundColor = bottomBorderColor
                headerView.contentView.backgroundColor = bottomBorderColor
                
                let bottomBorder = CALayer()
                let bottomWidth = CGFloat(2.0)
                bottomBorder.borderColor = headerBottom_Clr.cgColor
                bottomBorder.frame = CGRect(x: 0, y: label.frame.maxY-4, width:  shareContact_TableView.frame.size.width, height: 1)
                bottomBorder.borderWidth = bottomWidth
                headerView.contentView.layer.addSublayer(bottomBorder)
                headerView.contentView.layer.masksToBounds = true
                return headerView
            }
        }
        
        return headerView
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchActive == false{
            if section == 0{
                return countSortArr.count
            }
            else{
                return ChatPrerecordArr.count
            }
        }
        else
        {
            if searchContactArr.count > 0
            {
                return searchContactArr.count
            }
            else
            {
                return 1
            }
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let shareCell:SelectContactTableViewCell = shareContact_TableView.dequeueReusableCell(withIdentifier: "SelectContactTableViewCell") as! SelectContactTableViewCell
        
        shareCell.contact_ImageView?.layer.cornerRadius =  (shareCell.contact_ImageView?.frame.size.width)!/2
        shareCell.contact_ImageView?.clipsToBounds=true
        shareCell.nameTopConstraint.constant = 5
        
        if searchActive == false{
            
            if indexPath.section == 0
            {
                if(countSortArr.count > 0)
                {
                    let freqntRec:Chatpreloadrecord=countSortArr[indexPath.row] as! Chatpreloadrecord
                    
                    
                    if   freqntRec.ischattype == "single" {
                        
                        shareCell.nameLbl.setNameTxt(freqntRec.opponentid, freqntRec.ischattype)
                        
                        print(freqntRec.opponentid)
                        
                        if freqntRec.isSelect{
                            
                            shareCell.roundTick.image =  #imageLiteral(resourceName: "roundtick")
                        }
                        else{
                            
                            shareCell.roundTick.image =  #imageLiteral(resourceName: "uncheckround")
                        }
                        shareCell.nameTopConstraint.constant = shareCell.nameTopConstraint.constant+10
                        
                        shareCell.subDecLbl.isHidden = true
                        shareCell.contact_ImageView.setProfilePic(freqntRec.opponentid, freqntRec.ischattype)
                        return shareCell
                        
                        
                    }
                        
                    else if freqntRec.ischattype == "group"
                    {
                        shareCell.subDecLbl.text = freqntRec.oppopnentnumber
                        shareCell.nameTopConstraint.constant = shareCell.nameTopConstraint.constant-10
                        shareCell.nameLbl.setNameTxt(freqntRec.opponentid, freqntRec.ischattype)
                        if freqntRec.isSelect{
                            shareCell.roundTick.image =  #imageLiteral(resourceName: "roundtick")
                        }
                        else{
                            
                            shareCell.roundTick.image =  #imageLiteral(resourceName: "uncheckround")
                        }
                        
                        shareCell.subDecLbl.isHidden = false
                        shareCell.contact_ImageView?.setProfilePic(freqntRec.opponentid, freqntRec.ischattype)
                        return shareCell
                    }
                }
                else
                {
                    let cell : UITableViewCell = UITableViewCell.init(style: UITableViewCell.CellStyle.default , reuseIdentifier: "Cell")
                    cell.textLabel?.text = "No results"
                    cell.textLabel?.font = UIFont.systemFont(ofSize: 12.0)
                    cell.textLabel?.textAlignment = NSTextAlignment.center
                    return cell
                }
            }
            else if indexPath.section == 1{
                
                if(ChatPrerecordArr.count > 0)
                {
                    let chatprerecord:Chatpreloadrecord=ChatPrerecordArr[indexPath.row] as! Chatpreloadrecord
                    if chatprerecord.ischattype == "single"{
                        shareCell.nameLbl.setNameTxt(chatprerecord.opponentid, chatprerecord.ischattype)
                        
                        if chatprerecord.isSelect{
                            shareCell.roundTick.image =  #imageLiteral(resourceName: "roundtick")
                        }
                        else{
                            
                            shareCell.roundTick.image =  #imageLiteral(resourceName: "uncheckround")
                        }
                        
                        shareCell.nameTopConstraint.constant = shareCell.nameTopConstraint.constant+10
                        
                        shareCell.subDecLbl.isHidden = true
                        
                        shareCell.contact_ImageView?.setProfilePic(chatprerecord.opponentid, chatprerecord.ischattype)
                        return shareCell
                        
                    }
                        
                    else if chatprerecord.ischattype == "group"{
                        
                        shareCell.subDecLbl.text = chatprerecord.oppopnentnumber
                        shareCell.nameLbl.setNameTxt(chatprerecord.opponentid, chatprerecord.ischattype)
                        if chatprerecord.isSelect{
                            shareCell.roundTick.image =  #imageLiteral(resourceName: "roundtick")
                        }
                        else{
                            
                            shareCell.roundTick.image =  #imageLiteral(resourceName: "uncheckround")
                        }
                        
                        shareCell.subDecLbl.isHidden = false
                        shareCell.nameTopConstraint.constant = shareCell.nameTopConstraint.constant-10
                        shareCell.contact_ImageView?.setProfilePic(chatprerecord.opponentid, chatprerecord.ischattype)
                        return shareCell
                    }
                }
                else
                {
                    let cell : UITableViewCell = UITableViewCell.init(style: UITableViewCell.CellStyle.default , reuseIdentifier: "Cell")
                    cell.textLabel?.text = "No results"
                    cell.textLabel?.font = UIFont.systemFont(ofSize: 12.0)
                    cell.textLabel?.textAlignment = NSTextAlignment.center
                    return cell
                }
            }
        }
        else{
            if searchContactArr.count > 0{
                let searchRec:FavRecord = searchContactArr[indexPath.row] as! FavRecord
                if addNameArr.contains(searchRec.name) && addIdArr.contains(searchRec.id){
                    shareCell.roundTick.image =  #imageLiteral(resourceName: "roundtick")
                }
                else{
                    shareCell.roundTick.image =  #imageLiteral(resourceName: "uncheckround")
                }
                if(searchRec.type == "single")
                {
                    shareCell.nameLbl.setNameTxt(searchRec.id, "single")
                    shareCell.subDecLbl.isHidden =  true
                    shareCell.nameTopConstraint.constant = shareCell.nameTopConstraint.constant+10
                    shareCell.contact_ImageView?.setProfilePic(searchRec.id, "single")
                }
                else
                {
                    shareCell.nameLbl.setNameTxt(searchRec.id, "group")
                    shareCell.nameTopConstraint.constant = shareCell.nameTopConstraint.constant-10
                    shareCell.subDecLbl.isHidden = false
                    shareCell.subDecLbl.text = searchRec.phnumber
                    shareCell.contact_ImageView?.setProfilePic(searchRec.id, "group")
                }
                return shareCell
            }
            else
            {
                let cell : UITableViewCell = UITableViewCell.init(style: UITableViewCell.CellStyle.default , reuseIdentifier: "Cell")
                cell.textLabel?.text = "No results found for \(searchBar.text!)"
                cell.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
                cell.textLabel?.textAlignment = NSTextAlignment.center
                return cell
            }
        }
        return shareCell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.resignFirstResponder()
        if searchActive == false{
            
            if indexPath.section == 0{
                let getCrrentCountSortArr:Chatpreloadrecord = countSortArr[indexPath.row] as! Chatpreloadrecord
                if  getCrrentCountSortArr.isSelect{
                    getCrrentCountSortArr.isSelect = false
                    addNameArr.remove(getCrrentCountSortArr.opponentname)
                    addIdArr.remove(getCrrentCountSortArr.userCommonID)
                    Share.remove(getCrrentCountSortArr.opponentid)
                }
                else{
                    getCrrentCountSortArr.isSelect = true
                    addNameArr.add(getCrrentCountSortArr.opponentname)
                    addIdArr.add(getCrrentCountSortArr.userCommonID)
                    self.user_id = getCrrentCountSortArr.opponentid
                    Share.add(getCrrentCountSortArr.opponentid)
                    print(getCrrentCountSortArr.opponentid)
                    self.selectedName = getCrrentCountSortArr.opponentname
                }
            }
            
            if indexPath.section == 1{
                
                
                let getCurrentRec:Chatpreloadrecord =  ChatPrerecordArr[indexPath.row] as! Chatpreloadrecord
                if getCurrentRec.isSelect{
                    
                    getCurrentRec.isSelect = false
                    addNameArr.remove(getCurrentRec.opponentname)
                    addIdArr.remove(getCurrentRec.userCommonID)
                    Share.remove(getCurrentRec.opponentid)
                    
                }
                else{
                    
                    getCurrentRec.isSelect = true
                    addNameArr.add(getCurrentRec.opponentname)
                    addIdArr.add(getCurrentRec.userCommonID)
                    Share.add(getCurrentRec.opponentid)
                    
                }
            }
            
            addNameLbl.text = ""
            for name in addNameArr{
                
                // addNameLbl.text = ")",\(name
                // addNameLbl.text? =
                addNameLbl.text! += ",\(name)"
                
                // addNameLbl.text?.append(name)
                //addNameLbl.text?.appending(name as! String)
                //  addNameLbl.text?.append(name)
            }
            
            
            if addNameLbl.text != ""{
                addNameLbl.text!.remove(at: (addNameLbl.text?.startIndex)!)
                self.bottomView.isHidden = false
            }
            else{
                self.bottomView.isHidden = true
            }
        }
        else {
            if searchContactArr.count > 0
            {
                let searchArr_Rec:FavRecord = searchContactArr[indexPath.row] as! FavRecord
                if  addNameArr.contains(searchArr_Rec.name) && addIdArr.contains(searchArr_Rec.id){
                    addNameArr.remove(searchArr_Rec.name)
                    addIdArr.remove(searchArr_Rec.id)
                    
                }
                else{
                    addNameArr.add(searchArr_Rec.name)
                    addIdArr.add(searchArr_Rec.id)
                }
            }
            
            addNameLbl.text = ""
            for name in addNameArr{
                
                // addNameLbl.text = ")",\(name
                // addNameLbl.text? =
                addNameLbl.text! += ",\(name)"
                // addNameLbl.text?.append(name)
                //addNameLbl.text?.appending(name as! String)
                //  addNameLbl.text?.append(name)
            }
            if addNameLbl.text != ""{
                
                addNameLbl.text!.remove(at: (addNameLbl.text?.startIndex)!)
                self.bottomView.isHidden = false
                
            }
            else{
                self.bottomView.isHidden = true
            }
            
        }
        
        shareContact_TableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        
        // searchController.responds(to: )
        // searchController.dimsBackgroundDuringPresentation = true
        //        searchController.obscuresBackgroundDuringPresentation = false
        
        searchActive = true
        //if (searchBar.text?.count)! > 0 {
        // searchActive = true
        
        let NewText = (searchBar.text! as NSString).replacingCharacters(in: range, with:text)
        print(NewText);
        let range = (NewText as String).startIndex ..< (NewText as String).endIndex
        var searchString = String()
        (NewText as String).enumerateSubstrings(in: range, options: .byComposedCharacterSequences,{ (substring, substringRange, enclosingRange, success) in
            searchString.append(substring!)
            print(searchString)
            //searchString.append("*")
            
        })
        
        if   searchString != ""{
            
            if   searchString.contains("\n"){
                
            }
            else{
                
                searchArray.removeAll(keepingCapacity: false)
                // searchGroupArr.removeAll(keepingCapacity: false)
                
                //  checkTable = "changeTblView"
                //            let NewText = (searchController.searchBar.text! as NSString).replacingCharacters(in: range, with:text)
                //            print(NewText)
                //            let range = (NewText as String).startIndex ..< (NewText as String).endIndex
                //            var searchString = String()
                //            (NewText as String).enumerateSubstrings(in: range, options: .byComposedCharacterSequences,{(substring, substringRange, enclosingRange, success) in
                //                searchString.append(substring!)
                //            })
                
                //   let searchPredicate = NSPredicate(format: "SELF LIKE[c] %@", searchController.searchBar.text!)
                //  let array = (Themes.sharedInstance.codename as NSArray).filtered(using: searchPredicate)
//                var namesBeginningWithLetterPredicate = NSPredicate(format: "(opponentname BEGINSWITH[cd] $letter)")
                
                let array = (ChatPrerecordArr as NSArray).filter{(($0 as? Chatpreloadrecord)?.opponentname.lowercased().hasPrefix(searchString.lowercased()) ?? false)}
//                    .filtered(using: namesBeginningWithLetterPredicate.withSubstitutionVariables(["letter": searchString]))
                let msgCountArray = (countSortArr as NSArray).filter{(($0 as? Chatpreloadrecord)?.opponentname.lowercased().hasPrefix(searchString.lowercased()) ?? false)}
                
//                namesBeginningWithLetterPredicate = NSPredicate(format: "(name BEGINSWITH[cd] $letter)")
                
                let contactsArray = (FavList as NSArray).filter{(($0 as? FavRecord)?.name.lowercased().hasPrefix(searchString.lowercased()) ?? false)}
                
                
                searchArray = array as! [NSObject]
                searchCountArry  = msgCountArray as! [NSObject]
                searchContactArr = contactsArray as! [NSObject]
                
                shareContact_TableView.reloadData()
            }
        }
        else{
            searchActive = false
            shareContact_TableView.reloadData()
        }
        
        return true
    }
    
    
    
    func getGroupDetails(){
        
    }
    //    - (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
    //    {
    //    [searchBar resignFirstResponder];
    //
    //    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        if searchText == ""{
            searchActive = false
            shareContact_TableView.reloadData()
            searchBar.resignFirstResponder()
            
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        searchBar.resignFirstResponder()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
        
//        self.pop(animated: true)
    }
    @IBAction func backAction(_ sender: UIButton) {
        self.searchBar.resignFirstResponder()
        
        self.pop(animated: true)
    }
    
    func SetData(id:String,i:Int)
    {
        let Checkuser:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "id", FetchString: id)
        if(Checkuser)
        {
            let GetUserDetails:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "id", FetchString:  id, SortDescriptor: nil) as! NSArray
            if(GetUserDetails.count > 0)
            {
                for i in 0 ..< GetUserDetails.count {
                    let ResponseDict = GetUserDetails[i] as! NSManagedObject
                    let favRecord:FavRecord=FavRecord()
                    favRecord.name=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "name"))
                    favRecord.countrycode=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "countrycode"))
                    favRecord.id=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "id"))
                    favRecord.is_add=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "is_add"))
                    favRecord.msisdn=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "msisdn"))
                    favRecord.phnumber=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "phnumber"))
                    favRecord.profilepic=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "profilepic"))
                    favRecord.status=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "status"))
                    favRecord.contact_ID = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "contact_id"))
                    
                    userfavRecord.append(favRecord)
                }
            }
            type.add("single")
        }else{
            type.add("group")
            let favRecord:FavRecord=FavRecord()
            favRecord.id = id
            favRecord.name = addNameArr[i] as! String
            userfavRecord.append(favRecord)
        }
    }
    
    @IBAction func shareAction(_ sender: UIButton) {
        if((!isFromForward) && (!contact_share))
        {
            let shareDtlVC = storyboard?.instantiateViewController(withIdentifier: "ShareDetailViewController") as! ShareDetailViewController
            shareDtlVC.contctID = contactID
            self.searchBar.resignFirstResponder()
            
            self.pushView(shareDtlVC, animated: true)
        }else if(contact_share == true){
            
            let shareDtlVC = storyboard?.instantiateViewController(withIdentifier: "ShareDetailViewController") as! ShareDetailViewController
            //self.SetData()
            for i in 0..<Share.count{
                self.SetData(id: Share[i] as! String ,i: i)
            }
            
            shareDtlVC.chat_type = type
            shareDtlVC.contctID = contactID
            shareDtlVC.toChat = userfavRecord
            shareDtlVC.passingFromSelect = passingRecord
            self.searchBar.resignFirstResponder()
            
            self.pushView(shareDtlVC, animated: true)
            
        }
        else
        {
            let personsArray = NSMutableArray()
            for i in 0..<addNameArr.count{
                
                for j in 0..<countSortArr.count{
                    let chatprerecord:Chatpreloadrecord=countSortArr[j] as! Chatpreloadrecord
                    if chatprerecord.opponentname == addNameArr[i] as? String && chatprerecord.userCommonID == addIdArr[i] as? String
                    {
                        if(!personsArray.contains(["name" : chatprerecord.opponentname, "id" : chatprerecord.opponentid, "type" : chatprerecord.ischattype, "image" : chatprerecord.opponentimage, "number" : chatprerecord.oppopnentnumber]))
                        {
                            personsArray.add(["name" : chatprerecord.opponentname, "id" : chatprerecord.opponentid, "type" : chatprerecord.ischattype, "image" : chatprerecord.opponentimage, "number" : chatprerecord.oppopnentnumber])
                        }
                    }
                }
                
                
                for k in 0..<ChatPrerecordArr.count{
                    let chatprerecord:Chatpreloadrecord=ChatPrerecordArr[k] as! Chatpreloadrecord
                    if chatprerecord.opponentname == addNameArr[i] as? String && chatprerecord.userCommonID == addIdArr[i] as? String
                    {
                        if(!personsArray.contains(["name" : chatprerecord.opponentname, "id" : chatprerecord.opponentid, "type" : chatprerecord.ischattype, "image" : chatprerecord.opponentimage, "number" : chatprerecord.oppopnentnumber]))
                        {
                            personsArray.add(["name" : chatprerecord.opponentname, "id" : chatprerecord.opponentid, "type" : chatprerecord.ischattype, "image" : chatprerecord.opponentimage, "number" : chatprerecord.oppopnentnumber])
                        }
                    }
                    
                }
                for l in 0..<searchContactArr.count{
                    let favCon :FavRecord = searchContactArr[l] as! FavRecord
                    if favCon.name == addNameArr[i] as! String && favCon.id == addIdArr[i] as! String
                    {
                        if(!personsArray.contains(["name" : favCon.name, "id" : favCon.id, "type" : favCon.type, "image" : favCon.profilepic, "number" : favCon.phnumber]))
                        {
                            personsArray.add(["name" : favCon.name, "id" : favCon.id, "type" : favCon.type, "image" : favCon.profilepic, "number" : favCon.phnumber])
                        }
                    }
                }
            }
            Themes.sharedInstance.activityView(View: self.view)
            if(isFromStatus)
            {
                StatusForwardHandler.sharedInstance.forward(messageArr: messageDatasourceArr as [AnyObject], toPersons: personsArray as [AnyObject], completion:  {(success : Bool, sentcount: Int, personcount: Int) ->  () in
                    if success == true
                    {
                        self.view.makeToast(message: "Message has been forwarded", duration: 3, position: HRToastActivityPositionDefault)
                        if sentcount == self.messageDatasourceArr.count && personcount == personsArray.count
                        {
                            Themes.sharedInstance.RemoveactivityView(View: self.view)
                            if(personsArray.count > 1)
                            {
                                self.searchBar.resignFirstResponder()
                                
                                self.pop(animated: true)
                            }
                            else
                            {
                                let userDict : NSDictionary = personsArray[0] as! NSDictionary
                                if(userDict["type"] as! String == "single")
                                {
                                    let chatLocked = Themes.sharedInstance.isChatLocked(id: Themes.sharedInstance.CheckNullvalue(Passed_value: userDict["id"]), type: "single")
                                    if(chatLocked == true){
                                        self.enterToChat(id: Themes.sharedInstance.CheckNullvalue(Passed_value: userDict["id"]), type: "single",userDict: userDict)
                                    }else{
                                        let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                                        ObjInitiateChatViewController.Chat_type = Themes.sharedInstance.CheckNullvalue(Passed_value: userDict["type"])
                                        ObjInitiateChatViewController.opponent_id = Themes.sharedInstance.CheckNullvalue(Passed_value: userDict["id"])
                                        ObjInitiateChatViewController.fromForward = true;
                                        self.searchBar.resignFirstResponder()
                                        self.pushView(ObjInitiateChatViewController, animated: true)
                                    }
                                    
                                }
                                else
                                {
                                    let chatLocked = Themes.sharedInstance.isChatLocked(id: Themes.sharedInstance.CheckNullvalue(Passed_value: userDict["id"]), type: "group")
                                    if(chatLocked == true){
                                        self.enterToChat(id: Themes.sharedInstance.CheckNullvalue(Passed_value: userDict["id"]), type: "group",userDict: userDict)
                                    }else{
                                        let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                                        ObjInitiateChatViewController.Chat_type = Themes.sharedInstance.CheckNullvalue(Passed_value: userDict["type"])
                                        ObjInitiateChatViewController.opponent_id = Themes.sharedInstance.CheckNullvalue(Passed_value: userDict["id"])
                                        ObjInitiateChatViewController.fromForward = true;
                                        self.searchBar.resignFirstResponder()
                                        self.pushView(ObjInitiateChatViewController, animated: true)
                                    }
                                    
                                }
                            }
                        }
                    }
                })
            }
            else
            {
                ForwardHandler.sharedInstance.forward(messageArr: messageDatasourceArr as [AnyObject], toPersons: personsArray as [AnyObject], completion:  {(success : Bool, sentcount: Int, personcount: Int) ->  () in
                    if success == true
                    {
                        self.view.makeToast(message: "Message has been forwarded", duration: 3, position: HRToastActivityPositionDefault)
                        if sentcount == self.messageDatasourceArr.count && personcount == personsArray.count
                        {
                            Themes.sharedInstance.RemoveactivityView(View: self.view)
                            if(personsArray.count > 1)
                            {
                                self.searchBar.resignFirstResponder()
                                
                                self.pop(animated: true)
                            }
                            else
                            {
                                let userDict : NSDictionary = personsArray[0] as! NSDictionary
                                if(userDict["type"] as! String == "single")
                                {
                                    let chatLocked = Themes.sharedInstance.isChatLocked(id: Themes.sharedInstance.CheckNullvalue(Passed_value: userDict["id"]), type: "single")
                                    if(chatLocked == true){
                                        self.enterToChat(id: Themes.sharedInstance.CheckNullvalue(Passed_value: userDict["id"]), type: "single",userDict: userDict)
                                    }else{
                                        let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                                        ObjInitiateChatViewController.Chat_type = Themes.sharedInstance.CheckNullvalue(Passed_value: userDict["type"])
                                        ObjInitiateChatViewController.opponent_id = Themes.sharedInstance.CheckNullvalue(Passed_value: userDict["id"])
                                        ObjInitiateChatViewController.fromForward = true;
                                        self.searchBar.resignFirstResponder()
                                        self.pushView(ObjInitiateChatViewController, animated: true)
                                    }
                                    
                                }
                                else
                                {
                                    let chatLocked = Themes.sharedInstance.isChatLocked(id: Themes.sharedInstance.CheckNullvalue(Passed_value: userDict["id"]), type: "group")
                                    if(chatLocked == true){
                                        self.enterToChat(id: Themes.sharedInstance.CheckNullvalue(Passed_value: userDict["id"]), type: "group",userDict: userDict)
                                    }else{
                                        let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                                        ObjInitiateChatViewController.Chat_type = Themes.sharedInstance.CheckNullvalue(Passed_value: userDict["type"])
                                        ObjInitiateChatViewController.opponent_id = Themes.sharedInstance.CheckNullvalue(Passed_value: userDict["id"])
                                        
                                        ObjInitiateChatViewController.fromForward = true;
                                        self.searchBar.resignFirstResponder()
                                        
                                        self.pushView(ObjInitiateChatViewController, animated: true)
                                    }
                                    
                                }
                            }
                        }
                    }
                })
            }
        }
    }
    
    func enterToChat(id:String,type:String,userDict:NSDictionary){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            Themes.sharedInstance.enterTochat(id: id, type: type) { (success) in
                if(success)
                {
                    let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                    ObjInitiateChatViewController.Chat_type = type
                    ObjInitiateChatViewController.opponent_id = id
                    ObjInitiateChatViewController.fromForward = true;
                    self.searchBar.resignFirstResponder()
                    self.pushView(ObjInitiateChatViewController, animated: true)
                }
            }
        })
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


