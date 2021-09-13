 //
 //  SecretChatsController.swift
 //
 //
 //  Created by CASPERON on 16/12/16.
 //  Copyright © 2016 CASPERON. All rights reserved.
 //
 
 import UIKit
 import SWMessages
 import Contacts
 import SDWebImage
 import SimpleImageViewer
 

 class SecretChatsController: UIViewController,UITableViewDelegate,UITableViewDataSource,MGSwipeTableCellDelegate,UISearchControllerDelegate, UISearchResultsUpdating,SocketIOManagerDelegate,UITextFieldDelegate, UISearchBarDelegate{
    lazy fileprivate var searchController = UISearchController(searchResultsController: nil)
    @IBOutlet weak var bottom_chatTable: NSLayoutConstraint!
    var searchArray = [NSObject]()
    var allArray:NSMutableArray = NSMutableArray()
    var OtherChats = [NSObject]()
    var searchActive:Bool = false
    var section:NSMutableArray = NSMutableArray()
    var favArray:NSMutableArray=NSMutableArray()
    var to_id:NSMutableArray=NSMutableArray()
    var allChat_msg:NSMutableArray=NSMutableArray()
    var text_highlight:String = String()
    @IBOutlet weak var chats_Tblview:UITableView!
    @IBOutlet weak var chatLbl:UILabel!
    @IBOutlet weak var Nochat_view: UIView!
    var filterMessage:NSMutableArray = NSMutableArray()
    var filterMessageContact = [NSObject]()
    var ChatPrerecordArr:NSMutableArray=NSMutableArray()
    var checking:NSMutableArray=NSMutableArray()
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        addNotificationListener()
        searchActive = false
        searchController.delegate=self
        searchController.searchBar.delegate=self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = true
        chats_Tblview.tableHeaderView = searchController.searchBar
        searchController.searchBar.showsScopeBar = false
        
        let nibName = UINib(nibName: "SecretChatsTableViewCell", bundle: nil)
        self.chats_Tblview.register(nibName, forCellReuseIdentifier: "SecretChatsTableViewCell")
        
        let chatnibName = UINib(nibName: "FavouriteTableViewCell", bundle:nil)
        self.chats_Tblview.register(chatnibName, forCellReuseIdentifier: "FavouriteTableViewCell")
        
        let msgnibName = UINib(nibName: "SearchMessageTableViewCell", bundle:nil)
        self.chats_Tblview.register(msgnibName, forCellReuseIdentifier: "SearchMessageTableViewCell")
        self.chats_Tblview.estimatedRowHeight = 85
        self.chats_Tblview.separatorColor=UIColor.clear
        Nochat_view.isHidden=true
        self.chats_Tblview.tableFooterView=UIView()
        chats_Tblview.allowsMultipleSelectionDuringEditing = true;
        
        self.searchController.hidesNavigationBarDuringPresentation = false
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        
        searchController.searchBar.resignFirstResponder()
        searchController.isActive = false
        SocketIOManager.sharedInstance.Delegate = nil
        
    }
    
    
    @IBAction func openImage(sender:UIButton){
        let indexpath = NSIndexPath.init(row: sender.tag, section: 0)
        let cellItem:FavouriteTableViewCell? = chats_Tblview.cellForRow(at: indexpath as IndexPath) as? FavouriteTableViewCell
        let configuration = ImageViewerConfiguration { config in
            config.imageView = cellItem?.profileImage
        }
        self.searchController.dismissView(animated:true, completion:nil)
        self.searchController.searchBar.resignFirstResponder()
        self.searchController.isActive = false
        self.presentView(ImageViewerController(configuration: configuration), animated: true)
    }
        
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        SocketIOManager.sharedInstance.Delegate = self
        searchActive = false
        self.ReloadTable()
        self.ReloadAllTable()
        self.reloadMessages()
    }
    
    func TypingStatus(not:Notification)
    {
        let ResponseDict:NSDictionary = not.object as! NSDictionary
        if(ResponseDict.count > 0)
        {
            let from:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from") as AnyObject)
            if(from != Themes.sharedInstance.Getuser_id())
            {
                
                
            }
        }
    }
    
    func ReloadAllTable()
    {
        
        favArray=NSMutableArray()
        let CheckFav:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "user_id", FetchString: Themes.sharedInstance.Getuser_id())
        if(CheckFav)
        {
            let p1 = NSPredicate(format: "user_id = %@", Themes.sharedInstance.Getuser_id())
            let p2 = NSPredicate(format: "is_fav = %@", "1")
            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2])
            let Fav_Arr=DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Favourite_Contact, SortDescriptor: nil, predicate: predicate,Limit:0) as! NSArray
            
            if(Fav_Arr.count > 0)
            {
                for i in 0 ..< Fav_Arr.count {
                    let ResponseDict = Fav_Arr[i] as! NSManagedObject
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
                    favRecord.is_online = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "is_online"))
                    favRecord.time_stamp = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "time_stamp"))
                    favArray.add(favRecord)
                }
            }
            
        }
        
    }
    
    func reload()
    {
        Themes.sharedInstance.RemoveactivityView(View: self.chats_Tblview)
        ReloadTable()
        self.reloadMessages()
    }
    
    func ReloadTable()
    {
        Themes.sharedInstance.RemoveactivityView(View: self.chats_Tblview)
        ChatPrerecordArr=NSMutableArray()
        let CheckPreloadRecord=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_id", FetchString: Themes.sharedInstance.Getuser_id())
        
        var servertimeStr:String = Themes.sharedInstance.getServerTime()
        if(servertimeStr == "")
        {
            servertimeStr = "0"
        }
        if(CheckPreloadRecord)
        {
            let p1 = NSPredicate(format: "user_id = %@", Themes.sharedInstance.Getuser_id())
            let p2 = NSPredicate(format: "chat_type = %@", "secret")
            
            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2])
            let chatintiatedDetailArr=DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Chat_intiated_details, SortDescriptor: "timestamp", predicate: predicate,Limit:0) as! NSArray
            
            if(chatintiatedDetailArr.count > 0)
            {
                for i in 0..<chatintiatedDetailArr.count
                {
                    let Reponse_Dict:NSManagedObject = chatintiatedDetailArr[i] as! NSManagedObject
                    
                    let chat_type = Themes.sharedInstance.CheckNullvalue(Passed_value: Reponse_Dict.value(forKey: "chat_type"))
                    if(chat_type == "secret")
                    {
                        let user_common_id = Themes.sharedInstance.CheckNullvalue(Passed_value: Reponse_Dict.value(forKey: "user_common_id"))
                        let opponent_id = Themes.sharedInstance.CheckNullvalue(Passed_value: Reponse_Dict.value(forKey: "opponent_id"))
                        let timestamp = Themes.sharedInstance.CheckNullvalue(Passed_value: Reponse_Dict.value(forKey: "timestamp"))
                        let conv_id = Themes.sharedInstance.CheckNullvalue(Passed_value: Reponse_Dict.value(forKey: "conv_id"))

                        
                        let CheckUserChat:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "user_common_id", FetchString: user_common_id)
                        
                        let chatprerecord=Chatpreloadrecord()
                        chatprerecord.ismessagetype="0"
                        chatprerecord.ischattype=chat_type
                        chatprerecord.opponentid = opponent_id
                        
                        let FavDict:NSArray = (DatabaseHandler.sharedInstance.FetchFromDatabaseWithLimit(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "id", Predicatefromat: "==", FetchString: chatprerecord.opponentid, Limit: 1, SortDescriptor: nil) as NSArray)
                        let GetUserDetails:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "id", FetchString:  chatprerecord.opponentid, SortDescriptor: nil) as! NSArray
                        if(GetUserDetails.count > 0)
                        {
                            for i in 0 ..< GetUserDetails.count {
                                let ResponseDict = GetUserDetails[i] as! NSManagedObject
                                chatprerecord.is_online = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "is_online"))
                                chatprerecord.timestamp = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "time_stamp"))
                                
                                if(FavDict.count > 0)
                                {
                                    let favddetail:NSManagedObject=FavDict[0] as! NSManagedObject
                                    
                                    if(Themes.sharedInstance.CheckNullvalue(Passed_value: favddetail.value(forKey: "name")) != "")
                                    {
                                        chatprerecord.opponentname=Themes.sharedInstance.CheckNullvalue(Passed_value: favddetail.value(forKey: "name"))
                                        chatprerecord.opponentimage=Themes.sharedInstance.CheckNullvalue(Passed_value: favddetail.value(forKey: "profilepic"))
                                        chatprerecord.oppopnentnumber=Themes.sharedInstance.CheckNullvalue(Passed_value: favddetail.value(forKey: "msisdn"))
                                    }
                                    else
                                    {
                                        chatprerecord.opponentname=""
                                        chatprerecord.opponentimage=""
                                        chatprerecord.oppopnentnumber=Themes.sharedInstance.CheckNullvalue(Passed_value: favddetail.value(forKey: "msisdn"))
                                    }
                                }
                                else
                                {
                                    if(chatprerecord.opponentid != Themes.sharedInstance.Getuser_id())
                                    {
                                        let param_userDetails:[String:Any]=["userId":chatprerecord.opponentid]
                                        SocketIOManager.sharedInstance.EmituserDetails(Param: param_userDetails)
                                    }
                                    chatprerecord.opponentname=""
                                    chatprerecord.opponentimage=""
                                }
                            }
                        }
                        else
                        {
                            if(chatprerecord.opponentid != Themes.sharedInstance.Getuser_id())
                            {
                                let param_userDetails:[String:Any]=["userId":chatprerecord.opponentid]
                                SocketIOManager.sharedInstance.EmituserDetails(Param: param_userDetails)
                            }
                        }
                        if(CheckUserChat)
                        {
                            let ReponseDict:NSManagedObject = (DatabaseHandler.sharedInstance.FetchFromDatabaseWithLimit(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "user_common_id", Predicatefromat: "==", FetchString: user_common_id , Limit: 1, SortDescriptor: "date") as NSArray)[0] as! NSManagedObject
                            let MessageCount:Int=Int(Themes.sharedInstance.CheckNullvalue(Passed_value: Reponse_Dict.value(forKey: "chat_count")))!
                            let is_read:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Reponse_Dict.value(forKey: "is_read"))
                            if(is_read == "1")
                            {
                                chatprerecord.isUnreadMessages = true
                                
                            }
                            else
                            {
                                chatprerecord.isUnreadMessages = false
                            }
                            if(MessageCount != 0)
                            {
                                chatprerecord.opponentunreadmessagecount="\(MessageCount)"
                                chatprerecord.isUnreadMessages = true
                            }
                            else
                            {
                                chatprerecord.opponentunreadmessagecount=""
                            }
                            print("\(chatprerecord.opponentunreadmessagecount)")
                            chatprerecord.opponentlastmessage=Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "payload"))
                            chatprerecord.MessageType = Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "type"))
                            chatprerecord.info_type = Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "info_type"))
                            
                            chatprerecord.ismessagestatus=Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "message_status"))
                            //      if(chatprerecord.opponentid != Themes.sharedInstance.Getuser_id())
                            //                {
                            //                    chatprerecord.oppopnentnumber=Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "contactmsisdn"))
                            //
                            //                    }
                            chatprerecord.opponentlastmessageDate=Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "timestamp"))
                            
                            chatprerecord.opponentlastmessageid=Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "convId"))
                            
                            
                        }
                        else
                        {
                            chatprerecord.opponentunreadmessagecount = ""
                            chatprerecord.opponentlastmessage = ""
                            chatprerecord.ismessagestatus = ""
                            chatprerecord.opponentlastmessageDate=timestamp
                            chatprerecord.opponentlastmessageid=conv_id
                            
                        }
                        
                        
                        ChatPrerecordArr.add(chatprerecord)
                    }
                }
                if(ChatPrerecordArr.count > 0)
                {
                    var SortArray:NSArray=NSArray(array: ChatPrerecordArr)
                    SortArray = SortArray.sorted{(Themes.sharedInstance.shouldSortChatObj(first: $0, second: $1))} as NSArray
                    ChatPrerecordArr=NSMutableArray(array: SortArray)
                    print(">>>>>>the count is\(ChatPrerecordArr.count)")
                    chats_Tblview.reloadData()
                }
                
                Nochat_view.isHidden=true
                chats_Tblview.isHidden=false
            }
            else
            {
                Nochat_view.isHidden=false
                chats_Tblview.isHidden=true
            }
        }
        else
        {
            Nochat_view.isHidden=false
            chats_Tblview.isHidden=true
        }
        self.ReloadAllTable()
    }
    
    func reloadMessages(){
        
        to_id=NSMutableArray()
        allChat_msg = NSMutableArray()
        
        for i in 0..<ChatPrerecordArr.count{
            let msg_contact:NSMutableArray = NSMutableArray()
            let all_msg:NSMutableArray = NSMutableArray()
            let record = ChatPrerecordArr[i]
            if(record is Chatpreloadrecord)
            {
                let chatprerecord:Chatpreloadrecord=ChatPrerecordArr[i] as! Chatpreloadrecord
                let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
                let to:String=Themes.sharedInstance.CheckNullvalue(Passed_value: chatprerecord.opponentid)
                let name:String=Themes.sharedInstance.CheckNullvalue(Passed_value: chatprerecord.opponentname)
                let phone_no:String = Themes.sharedInstance.CheckNullvalue(Passed_value: chatprerecord.oppopnentnumber)
                let User_chat_id=to + "-" + from;
                var ChatArr:NSArray=DatabaseHandler.sharedInstance.FetchFromDatabaseWithLimit(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "user_common_id", Predicatefromat: "==", FetchString: User_chat_id, Limit: 0, SortDescriptor: "timestamp") as NSArray
                if(ChatArr.count > 0)
                {
                    let descriptor: NSSortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
                    ChatArr = ChatArr.sortedArray(using: [descriptor]) as NSArray
                }
                for i in 0 ..< ChatArr.count {
                    let messages:SearchMessage = SearchMessage()
                    let ResponseDict = ChatArr[i] as! NSManagedObject
                    let messageType:String = ResponseDict.value(forKey: "type") as! String
                    messages.to_id = to
                    if(name != ""){
                        messages.name = name
                    }else{
                        messages.name = phone_no
                    }
                    
                    if(messageType == "0"){
                        let message:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "payload"))
                        let doc_ids:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id"))
                        let timestamp:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "timestamp"))
                        let messageStatus:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "message_status"))
                        messages.isRead = messageStatus
                        messages.timestamp = timestamp
                        messages.doc_id = doc_ids
                        messages.type = "secret"
                        msg_contact.add(messages)
                        all_msg.add(message)
                        
                        
                    }else if(messageType == "5"){
                        let ChekLocation:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Contact_details, attribute: "doc_id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id")))
                        if(ChekLocation)
                        {
                            let ContactArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Contact_details, attribute: "doc_id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id")), SortDescriptor: nil) as! NSArray
                            var contact_name:String = ""
                            for i in 0..<ContactArr.count
                            {
                                let ObjRecord:NSManagedObject = ContactArr[i] as! NSManagedObject
                                contact_name = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "contact_name"))
                            }
                            let doc_ids:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id"))
                            let timestamp:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "timestamp"))
                            let messageStatus:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "message_status"))
                            messages.isRead = messageStatus
                            messages.timestamp = timestamp
                            messages.doc_id = doc_ids
                            messages.type = "secret"
                            msg_contact.add(messages)
                            all_msg.add(contact_name)
                        }
                    }else if(messageType == "4"){
                        let message:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "payload"))
                        let doc_ids:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id"))
                        let timestamp:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "timestamp"))
                        let messageStatus:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "message_status"))
                        messages.isRead = messageStatus
                        messages.timestamp = timestamp
                        messages.doc_id = doc_ids
                        messages.type = "secret"
                        msg_contact.add(messages)
                        all_msg.add(message)
                    }else if(messageType == "1"){
                        let message:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "payload"))
                        let doc_ids:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id"))
                        let timestamp:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "timestamp"))
                        let messageStatus:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "message_status"))
                        messages.isRead = messageStatus
                        messages.timestamp = timestamp
                        messages.doc_id = doc_ids
                        messages.type = "secret"
                        msg_contact.add(messages)
                        all_msg.add(message)
                    }
                }
                to_id.add(msg_contact)
                allChat_msg.add(all_msg)
            }
        }
    }
    
    @IBAction func openImageChats(sender:UIButton){
        let indexpath = NSIndexPath.init(row: sender.tag, section: 0)
        let cellItem = chats_Tblview.cellForRow(at: indexpath as IndexPath)
        if(cellItem is SecretChatsTableViewCell)
        {
            let configuration = ImageViewerConfiguration { config in
                config.imageView = (cellItem as! SecretChatsTableViewCell).user_Images
            }
            self.searchController.dismissView(animated:true, completion:nil)
            self.searchController.searchBar.resignFirstResponder()
            self.searchController.isActive = false
            self.presentView(ImageViewerController(configuration: configuration), animated: true)
        }
        else
        {
            let configuration = ImageViewerConfiguration { config in
                config.imageView = (cellItem as! GroupChatTableViewCell).user_Images
            }
            self.searchController.dismissView(animated:true, completion:nil)
            self.searchController.searchBar.resignFirstResponder()
            self.searchController.isActive = false
            self.presentView(ImageViewerController(configuration: configuration), animated: true)
            
        }
    }
    
    @IBAction func openImageFav(sender:UIButton){
        let indexpath = NSIndexPath.init(row: sender.tag, section: 0)
        let cellItem:FavouriteTableViewCell? = chats_Tblview.cellForRow(at: indexpath as IndexPath) as? FavouriteTableViewCell
        let configuration = ImageViewerConfiguration { config in
            config.imageView = cellItem?.profileImage
        }
        self.searchController.dismissView(animated:true, completion:nil)
        self.searchController.searchBar.resignFirstResponder()
        self.searchController.isActive = false
        self.presentView(ImageViewerController(configuration: configuration), animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        
        if(searchActive == false){
            let record = ChatPrerecordArr[indexPath.row]
            if(record is Chatpreloadrecord)
            {
                return 68
            }
            return 48
        }
        else if(searchActive == true && section[indexPath.section] as! String == "Chats"){
            let searchRecord:NSArray = allArray[indexPath.section] as! NSArray
            let record = searchRecord[indexPath.row]
            if(record is Chatpreloadrecord)
            {
                return 68
            }
            return 68
            
        }
        else
        {
            return 68
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if(searchActive == true){
            return self.section.count
        }
        return 1
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(searchActive == true){
            return self.section[section] as? String
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive == true && (self.section[section] as! String == "Chats" || self.section[section] as! String == "Other Chats")){
            let row:NSArray = allArray[section] as! NSArray
            return row.count
        }else if(searchActive == true && self.section[section] as! String == "Messages"){
            return filterMessage.count
        }
        return ChatPrerecordArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(searchActive == false){
            if let record = (ChatPrerecordArr[indexPath.row] as? Chatpreloadrecord)
            {
                let cell:SecretChatsTableViewCell  = tableView.dequeueReusableCell(withIdentifier: "SecretChatsTableViewCell") as! SecretChatsTableViewCell
                cell.messageCount_Lbl.layer.backgroundColor  = UIColor(red: 255.0/255.0, green: 10.0/255.0, blue: 20.0/255.0, alpha: 0.9).cgColor
                cell.messageCount_Lbl.layer.cornerRadius = 13
                cell.selectionStyle = .default
                cell.messageCount_Lbl.layer.cornerRadius = 13
                let chatprerecord:Chatpreloadrecord=ChatPrerecordArr[indexPath.row] as! Chatpreloadrecord
                
                
                cell.user_Images.setProfilePic(record.opponentid, record.ischattype)
                cell.user_Images.tag = indexPath.row
                cell.user.addTarget(self, action: #selector(self.openImageChats(sender:)), for: .touchUpInside)
                cell.user_Images.clipsToBounds=true
                
                cell.chat_status.isHidden = true
                cell.is_locked.isHidden = true
                
                if(chatprerecord.MessageType == "0" || chatprerecord.MessageType == "7" || chatprerecord.MessageType == "4")
                {
                    cell.message_Lbl.text = Themes.sharedInstance.CheckNullvalue(Passed_value: chatprerecord.opponentlastmessage)
                }
                else if(chatprerecord.MessageType == "1")
                {
                    cell.message_Lbl.text = "📷 Photo"
                }
                else if(chatprerecord.MessageType == "2")
                {
                    cell.message_Lbl.text = "📹 Video"
                    
                }
                else if(chatprerecord.MessageType == "3")
                {
                    cell.message_Lbl.text = "🎵 Audio"
                    
                }
                else if(chatprerecord.MessageType == "4")
                {
                    cell.message_Lbl.text = "🔗 Link"
                    
                }
                else if(chatprerecord.MessageType == "5")
                {
                    cell.message_Lbl.text = "📝 Contact"
                    
                }
                else if(chatprerecord.MessageType == "6" || chatprerecord.MessageType == "20")
                {
                    cell.message_Lbl.text = "📄 Document"
                    
                }
                    
                else if(chatprerecord.MessageType == "14")
                {
                    cell.message_Lbl.text = "📍 Location"
                    
                }
                else if(chatprerecord.MessageType == "21")
                {
                    cell.message_Lbl.text = "☎︎ Missed Call"
                    
                }else{
                    cell.message_Lbl.text = ""
                }
                
                cell.name_Lbl.setNameTxt(chatprerecord.opponentid, chatprerecord.ischattype)
                
                if(chatprerecord.opponentunreadmessagecount == "" && chatprerecord.isUnreadMessages == false)
                {
                    cell.messageCount_Lbl.isHidden=true
                    cell.chat_status.frame.x = cell.messageCount_Lbl.frame.x
                }
                else    if(chatprerecord.opponentunreadmessagecount == "" && chatprerecord.isUnreadMessages == true)
                {
                    cell.messageCount_Lbl.isHidden = false
                    cell.messageCount_Lbl.text = ""
                    cell.chat_status.frame.x = cell.messageCount_Lbl.frame.x - cell.messageCount_Lbl.frame.width
                }
                else if(chatprerecord.opponentunreadmessagecount != "" && chatprerecord.isUnreadMessages == false)
                {
                    cell.messageCount_Lbl.isHidden=false
                    let countStr:String = Themes.sharedInstance.CheckNullvalue(Passed_value: chatprerecord.opponentunreadmessagecount)
                    if(countStr.count <= 2)
                    {
                        cell.messageCount_Lbl.text = countStr
                    }
                    else
                    {
                        cell.messageCount_Lbl.text = "99+"
                    }
                    cell.chat_status.frame.x = cell.messageCount_Lbl.frame.x - cell.messageCount_Lbl.frame.width
                    
                }
                else if(chatprerecord.opponentunreadmessagecount != "" && chatprerecord.isUnreadMessages == true)
                {
                    cell.messageCount_Lbl.isHidden=false
                    let countStr:String = Themes.sharedInstance.CheckNullvalue(Passed_value: chatprerecord.opponentunreadmessagecount)
                    if(countStr.count <= 2)
                    {
                        cell.messageCount_Lbl.text = countStr
                    }
                    else
                    {
                        cell.messageCount_Lbl.text = "99+"
                    }
                    cell.chat_status.frame.x = cell.messageCount_Lbl.frame.x - cell.messageCount_Lbl.frame.width
                    
                }
                cell.objRecordSingle = chatprerecord
                if(chatprerecord.isTyping)
                {
                    cell.startTyping(chat_type: "secret", objRecord: chatprerecord)
                }
                
                cell.time_Lbl.text=Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.ConverttimeStamp(timestamp: chatprerecord.opponentlastmessageDate))
                tableView.separatorStyle = .none
                cell.messageCount_Lbl.adjustsFontSizeToFitWidth = true
                cell.name_Lbl.font = UIFont.boldSystemFont(ofSize: 16.0)
                return cell
            }
            
        }else if(searchActive == true && section[indexPath.section] as! String == "Chats"){
            let searchRecord:NSArray = allArray[indexPath.section] as! NSArray
            let record = searchRecord[indexPath.row]
            if(record is Chatpreloadrecord)
            {
                let cell:SecretChatsTableViewCell  = tableView.dequeueReusableCell(withIdentifier: "SecretChatsTableViewCell") as! SecretChatsTableViewCell
                
                cell.messageCount_Lbl.layer.backgroundColor  = UIColor(red: 255.0/255.0, green: 10.0/255.0, blue: 20.0/255.0, alpha: 0.9).cgColor
                cell.messageCount_Lbl.layer.cornerRadius = 13
                cell.selectionStyle = .default
                cell.messageCount_Lbl.layer.cornerRadius = 13
                let chatprerecord:Chatpreloadrecord=searchRecord[indexPath.row] as! Chatpreloadrecord
                cell.user_Images.setProfilePic(chatprerecord.opponentid, chatprerecord.ischattype)
                cell.user_Images.isUserInteractionEnabled = false
                
                cell.user_Images.clipsToBounds=true
                cell.message_Lbl.text=Themes.sharedInstance.CheckNullvalue(Passed_value: chatprerecord.opponentlastmessage)
               
                cell.chat_status.isHidden = true
                cell.is_locked.isHidden = true
                cell.name_Lbl.setNameTxt(chatprerecord.opponentid, chatprerecord.ischattype)
                if(chatprerecord.opponentunreadmessagecount == "" && chatprerecord.isUnreadMessages == false)
                {
                    cell.messageCount_Lbl.isHidden=true
                    cell.chat_status.frame.x = cell.messageCount_Lbl.frame.x
                }
                else    if(chatprerecord.opponentunreadmessagecount == "" && chatprerecord.isUnreadMessages == true)
                {
                    cell.messageCount_Lbl.isHidden = false
                    cell.messageCount_Lbl.text = ""
                    cell.chat_status.frame.x = cell.messageCount_Lbl.frame.x - cell.messageCount_Lbl.frame.width
                }
                else if(chatprerecord.opponentunreadmessagecount != "" && chatprerecord.isUnreadMessages == false)
                {
                    cell.messageCount_Lbl.isHidden=false
                    let countStr:String = Themes.sharedInstance.CheckNullvalue(Passed_value: chatprerecord.opponentunreadmessagecount)
                    if(countStr.count <= 2)
                    {
                        cell.messageCount_Lbl.text = countStr
                    }
                    else
                    {
                        cell.messageCount_Lbl.text = "99+"
                    }
                    cell.chat_status.frame.x = cell.messageCount_Lbl.frame.x - cell.messageCount_Lbl.frame.width
                    
                }
                else if(chatprerecord.opponentunreadmessagecount != "" && chatprerecord.isUnreadMessages == true)
                {
                    cell.messageCount_Lbl.isHidden=false
                    let countStr:String = Themes.sharedInstance.CheckNullvalue(Passed_value: chatprerecord.opponentunreadmessagecount)
                    if(countStr.count <= 2)
                    {
                        cell.messageCount_Lbl.text = countStr
                    }
                    else
                    {
                        cell.messageCount_Lbl.text = "99+"
                    }
                    cell.chat_status.frame.x = cell.messageCount_Lbl.frame.x - cell.messageCount_Lbl.frame.width
                }
                
                cell.time_Lbl.text=Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.ConverttimeStamp(timestamp: chatprerecord.opponentlastmessageDate))
                tableView.separatorStyle = .singleLine
                tableView.separatorColor = nil
                cell.messageCount_Lbl.adjustsFontSizeToFitWidth = true
                return cell
            }
            
        }else if(searchActive == true && section[indexPath.section] as! String == "Other Chats"){
            let cell:FavouriteTableViewCell  = tableView.dequeueReusableCell(withIdentifier: "FavouriteTableViewCell") as! FavouriteTableViewCell
            let searchRecord:NSArray = allArray[indexPath.section] as! NSArray
            let favRecord:FavRecord=searchRecord[indexPath.row] as! FavRecord
            cell.selectionStyle = .none
            cell.nameLbl.setNameTxt(favRecord.id, "single")
            cell.profileImage.setProfilePic(favRecord.id, "single")
            cell.profileImage.isUserInteractionEnabled = false
            cell.statusLbl.setStatusTxt(favRecord.id)
            cell.statusLbl.isHidden = cell.statusLbl.text == ""
            tableView.separatorStyle = .singleLine
            tableView.separatorColor = nil
            cell.nameLbl.font = UIFont.boldSystemFont(ofSize: 16.0)
            return cell
        }else if(searchActive == true && section[indexPath.section] as! String == "Messages"){
            let cell:SearchMessageTableViewCell  = tableView.dequeueReusableCell(withIdentifier: "SearchMessageTableViewCell") as! SearchMessageTableViewCell
            let info_msg:SearchMessage = filterMessageContact[indexPath.row] as! SearchMessage
            let attributedText = NSMutableAttributedString(string: (filterMessage[indexPath.row] as? String)! , attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 15.0)])
            let boldFontAttribute = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize:15.0),NSAttributedString.Key.foregroundColor: UIColor.black]
            
            attributedText.addAttributes(boldFontAttribute, range: (filterMessage[indexPath.row] as? NSString)!.range(of: text_highlight))
            
            cell.message.attributedText = attributedText
            
            if(info_msg.isRead == "1"){
                cell.image_button.setImage(UIImage(named: "singletick"), for: .normal)
            }else if(info_msg.isRead == "2"){
                cell.image_button.setImage(UIImage(named: "doubletick"), for: .normal)
            }else if(info_msg.isRead == "3"){
                cell.image_button.setImage(UIImage(named: "doubletickgreen"), for: .normal)
            }
            tableView.separatorStyle = .singleLine
            tableView.separatorColor = nil
            cell.name.setNameTxt(info_msg.to_id, info_msg.type)
            let date = Date(timeIntervalSince1970: TimeInterval((info_msg.timestamp as NSString).longLongValue/1000))
            let dateFormatters = DateFormatter()
            dateFormatters.dateFormat = "yyyy-MM-dd"
            dateFormatters.timeZone = TimeZone(abbreviation: "GMT")
            dateFormatters.timeZone = NSTimeZone.system
            let dateStr:String = dateFormatters.string(from: date as Date)
            cell.timestamp.text = dateStr
            return cell
            
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if(searchActive == false){
            let record = ChatPrerecordArr[indexPath.row]
            if(record is Chatpreloadrecord)
            {
                let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                ObjInitiateChatViewController.is_fromSecret = true
                ObjInitiateChatViewController.Chat_type="secret"
                let chatprerecord:Chatpreloadrecord=ChatPrerecordArr[indexPath.row] as! Chatpreloadrecord
                ObjInitiateChatViewController.opponent_id = chatprerecord.opponentid
                self.searchController.dismissView(animated:true, completion:nil)
                self.searchController.searchBar.resignFirstResponder()
                self.searchController.isActive = false
                self.pushView(ObjInitiateChatViewController, animated: true)
            }
            
        }else if(searchActive == true && section[indexPath.section] as! String == "Chats"){
            let searchRecord:NSArray = allArray[indexPath.section] as! NSArray
            let record  = searchRecord[indexPath.row]
            if(record is Chatpreloadrecord)
            {
                
                let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                ObjInitiateChatViewController.is_fromSecret = true
                ObjInitiateChatViewController.Chat_type="secret"
                let chatprerecord:Chatpreloadrecord=searchRecord[indexPath.row] as! Chatpreloadrecord
                ObjInitiateChatViewController.opponent_id = chatprerecord.opponentid
                self.searchController.dismissView(animated:true, completion:nil)
                self.searchController.searchBar.resignFirstResponder()
                self.searchController.isActive = false
                self.pushView(ObjInitiateChatViewController, animated: true)
                
            }
        }else if(searchActive == true && section[indexPath.section] as! String == "Other Chats"){
            let searchRecord:NSArray = allArray[indexPath.section] as! NSArray
            let favRecord:FavRecord=searchRecord[indexPath.row] as! FavRecord
            let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
            ObjInitiateChatViewController.is_fromSecret = true
            ObjInitiateChatViewController.Chat_type="secret"
            ObjInitiateChatViewController.opponent_id = favRecord.id
            self.searchController.dismissView(animated:true, completion:nil)
            self.searchController.searchBar.resignFirstResponder()
            self.searchController.isActive = false
            self.pushView(ObjInitiateChatViewController, animated: true)
        }else if(searchActive == true && section[indexPath.section] as! String == "Messages"){
            let info_msg:SearchMessage = filterMessageContact[indexPath.row] as! SearchMessage
            
            if(info_msg.type == "secret")
            {
                let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                ObjInitiateChatViewController.from_search_msg = true
                ObjInitiateChatViewController.from_search_msg_id = info_msg.timestamp!
                ObjInitiateChatViewController.from_message = (filterMessage[indexPath.row] as? String)!
                ObjInitiateChatViewController.is_fromSecret = true
                ObjInitiateChatViewController.Chat_type="secret"
                ObjInitiateChatViewController.opponent_id = info_msg.to_id
                self.searchController.dismissView(animated:true, completion:nil)
                self.searchController.searchBar.resignFirstResponder()
                self.searchController.isActive = false
                self.pushView(ObjInitiateChatViewController, animated: true)
                
            }
        }
        searchController.searchBar.resignFirstResponder()
        searchController.isActive = false
    }
        
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func DidclickBack(_ sender : UIButton)
    {
        self.pop(animated: true)
    }
    
    @IBAction func DidclickNewChat(_ sender: UIButton) {
        
        
        self.searchController.dismissView(animated:true, completion:nil)
        if(ContactHandler.sharedInstance.CheckCheckPermission())
        {
            
            let favouritesVC:SecretChatContactVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SecretChatContactVC") as! SecretChatContactVC
            let navController = UINavigationController(rootViewController: favouritesVC)
            navController.navigationBar.isHidden = true
            navController.modalPresentationStyle = .fullScreen
            favouritesVC.delegate = self
            self.searchController.dismissView(animated:true, completion:nil)
            self.searchController.searchBar.resignFirstResponder()
            self.searchController.isActive = false
            self.presentView(navController, animated: true)
            
        }
        else
        {
            self.searchController.dismissView(animated:true, completion:nil)
            self.presentView(Themes.sharedInstance.showContactPermissionAlert, animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath)
    {
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        searchActive = true
        searchController.obscuresBackgroundDuringPresentation = false
        if (searchController.searchBar.text?.isEmpty == false) {
            text_highlight = searchController.searchBar.text!
            filterMessage = []
            filterMessageContact = []
            searchActive = true
            searchArray.removeAll(keepingCapacity: false)
            
            var ChatArr = [Any]()
            var GroupArr = [Any]()
            ChatPrerecordArr.forEach { data in
                if(data is Chatpreloadrecord)
                {
                    ChatArr.append(data)
                }
                else
                {
                    GroupArr.append(data)
                }
            }
            
//            let namesBeginningWithLetterPredicate = NSPredicate(format: "(name BEGINSWITH[cd] $letter)")
//
//            let groupnamesBeginningWithLetterPredicate = NSPredicate(format: "(displayName BEGINSWITH[cd] $letter)")
//
//            let chatsnamesBeginningWithLetterPredicate = NSPredicate(format: "(opponentname BEGINSWITH[cd] $letter)")
//
//            let messagesWithLetterPredicate = NSPredicate(format: "SELF CONTAINS[c]     $letter")
            
            let array_chat = (ChatArr as NSArray).filter{(($0 as? Chatpreloadrecord)?.opponentname.lowercased().hasPrefix(Themes.sharedInstance.CheckNullvalue(Passed_value: searchController.searchBar.text).lowercased()) ?? false)}
            
            let array_group = (GroupArr as NSArray).filter{(($0 as? GroupDetail)?.displayName.lowercased().hasPrefix(Themes.sharedInstance.CheckNullvalue(Passed_value: searchController.searchBar.text).lowercased()) ?? false)}
            
//            let array_chat = (ChatArr as NSArray).filtered(using: chatsnamesBeginningWithLetterPredicate.withSubstitutionVariables(["letter": searchController.searchBar.text!]))
//
//            let array_group = (GroupArr as NSArray).filtered(using: groupnamesBeginningWithLetterPredicate.withSubstitutionVariables(["letter": searchController.searchBar.text!]))
            
            
            var array = [Any]()
            array.append(contentsOf: array_chat)
            array.append(contentsOf: array_group)
            let OtherChatArray = (favArray as NSArray).filter{(($0 as? FavRecord)?.name.lowercased().hasPrefix(Themes.sharedInstance.CheckNullvalue(Passed_value: searchController.searchBar.text).lowercased()) ?? false)}
//            let OtherChatArray = (favArray as NSArray).filtered(using: namesBeginningWithLetterPredicate.withSubstitutionVariables(["letter": searchController.searchBar.text!]))
            for i in 0..<allChat_msg.count{
                let msg = (allChat_msg[i] as! NSArray).filter{(($0 as? String)?.contains(searchController.searchBar.text!) ?? false)}
//                let msg = (allChat_msg[i] as! NSArray).filtered(using: messagesWithLetterPredicate.withSubstitutionVariables(["letter": searchController.searchBar.text!]))
                let deleteChat:NSMutableArray = allChat_msg[i] as! NSMutableArray
                let contact:NSMutableArray = to_id[i] as! NSMutableArray
                //let save:NSMutableArray = []
                if(msg.count > 0){
                    for j in 0..<deleteChat.count{
                        for k in 0..<msg.count{
                            if((deleteChat[j] as! String) == (msg[k] as! String)){
                                filterMessage.add(msg[k])
                                filterMessageContact.append(contact[j] as! NSObject)
                            }
                        }
                    }
                }
            }
            allArray = []
            section = []
            searchArray = array as! [NSObject]
            OtherChats = OtherChatArray as! [NSObject]
            if(searchArray.count > 0){
                for i in 0..<searchArray.count{
                    let record = searchArray[i]
                    if(record is Chatpreloadrecord)
                    {
                        let chatprerecord:Chatpreloadrecord=searchArray[i] as! Chatpreloadrecord
                        for j in 0..<OtherChats.count{
                            let fav:FavRecord=OtherChats[j] as! FavRecord
                            if(chatprerecord.opponentid == fav.id){
                                OtherChats.remove(at: j)
                                break
                            }
                        }
                    }
                }
            }
            if(searchArray.count>0){
                allArray.add(searchArray)
                section.add("Chats")
            }
            if(OtherChats.count>0){
                allArray.add(OtherChats)
                section.add("Other Chats")
            }
            if(filterMessage.count > 0){
                section.add("Messages")
            }
            chats_Tblview.reloadData()
        }else{
            searchActive = false;
            filterMessage = []
            allArray = []
            section = []
            chats_Tblview.reloadData()
        }
    }
    
    func addNotificationListener() {
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.Incomingmessage), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            weak.reload()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            weak.reload()
        }
        
    }
    
    func removeNotificationListener() {
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        removeNotificationListener()
    }

 }
 
 extension SecretChatsController:SecretChatContactVCDelegate
 {
    func MovetoSecretChatView(viewcontroller: UIViewController) {
        self.searchController.searchBar.resignFirstResponder()
        self.searchController.isActive = false
        self.pushView(viewcontroller, animated: true)
    }
 }
