 //
 //  ChatsViewController.swift
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
 
 
 typealias MoreActionCallback = (_ cancelled: Bool, _ deleted: Bool, _ actionIndex: Int) -> Void
 
 protocol ExampleContainer
 {
    var example: Example! { get set }
 }
 class ChatsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,MGSwipeTableCellDelegate,UISearchControllerDelegate, UISearchResultsUpdating,SocketIOManagerDelegate,UITextFieldDelegate, UISearchBarDelegate{
    
    lazy fileprivate var searchController = UISearchController(searchResultsController: nil)
    @IBOutlet weak var bottom_chatTable: NSLayoutConstraint!
    var searchArray = [NSObject]()
    var allArray:NSMutableArray = NSMutableArray()
    var OtherChats = [NSObject]()
    var searchActive:Bool = false
    var section:NSMutableArray = NSMutableArray()
    var favArray:NSMutableArray=NSMutableArray()
    var didnotShow:Bool = false
    var proceed_to_lock:Bool = false
    var to_id:NSMutableArray=NSMutableArray()
    var allChat_msg:NSMutableArray=NSMutableArray()
    var text_highlight:String = String()
    @IBOutlet weak var network_loader: UIActivityIndicatorView!{
        didSet{
            network_loader.isHidden = true
        }
    }
    @IBOutlet weak var tapBar: UIView!
    @IBOutlet weak var chats_Tblview:UITableView!
    @IBOutlet weak var btn_View:UIView!
    @IBOutlet weak var editBtn:UIButton!
    @IBOutlet weak var chatLbl:UILabel!
    @IBOutlet weak var broadCastBtn:UIButton!
    @IBOutlet weak var newgroupBtn:UIButton!
    @IBOutlet weak var Nochat_view: UIView!
    @IBOutlet weak var archive: UIButton!
    @IBOutlet weak var delete: UIButton!  // swap delete button
    @IBOutlet weak var read: UIButton!
    var filterMessage:NSMutableArray = NSMutableArray()
    var filterMessageContact = [NSObject]()
    var ChatPrerecordArr:NSMutableArray=NSMutableArray()
    var ChatActionIndex:NSMutableArray=NSMutableArray()
    var isBeginEditing:Bool = Bool()
    var cancel:Int = 0
    var read_all:Bool=true
    var read_msg:NSMutableArray=NSMutableArray()
    var delete_msg:NSMutableArray=NSMutableArray()
    var actionCallback: MoreActionCallback?;
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
        chats_Tblview.backgroundView?.backgroundColor = UIColor.white
        searchController.searchBar.backgroundColor = UIColor.white
        searchController.searchBar.barTintColor = UIColor.white
        searchController.searchBar.backgroundImage = UIImage()
        btn_View.backgroundColor = UIColor.white
        chats_Tblview.backgroundColor = UIColor.white
        chats_Tblview.allowsSelectionDuringEditing = true
        let searchField : UITextField = searchController.searchBar.value(forKey: "searchField") as! UITextField
        searchField.backgroundColor =  UIColor.lightGray
        searchField.alpha = 0.5
        self.view.bringSubviewToFront(broadCastBtn)
        self.view.bringSubviewToFront(newgroupBtn)
        
        let nibName = UINib(nibName: "ChatsTableViewCell", bundle: nil)
        self.chats_Tblview.register(nibName, forCellReuseIdentifier: "ChatsTableViewCell")
        
        let GroupnibName = UINib(nibName: "GroupChatTableViewCell", bundle:nil)
        self.chats_Tblview.register(GroupnibName, forCellReuseIdentifier: "GroupChatTableViewCell")
        
        let chatnibName = UINib(nibName: "FavouriteTableViewCell", bundle:nil)
        self.chats_Tblview.register(chatnibName, forCellReuseIdentifier: "FavouriteTableViewCell")
        //
        let msgnibName = UINib(nibName: "SearchMessageTableViewCell", bundle:nil)
        self.chats_Tblview.register(msgnibName, forCellReuseIdentifier: "SearchMessageTableViewCell")
        self.chats_Tblview.estimatedRowHeight = 85
        self.btn_View.layer.borderWidth = 1
        self.btn_View.layer.borderColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1).cgColor
        self.chats_Tblview.separatorColor=UIColor.clear
        Nochat_view.isHidden=true
        self.chats_Tblview.tableFooterView=UIView()
        chats_Tblview.allowsMultipleSelectionDuringEditing = true;
        self.tapBar.isHidden = true
        self.read.setTitle("Read", for:.normal)
        self.archive.setTitle("Archive", for:.normal)
        self.delete.setTitle("Delete", for:.normal)
        self.read.setTitleColor(UIColor.lightGray, for: .normal)
        self.archive.setTitleColor(UIColor.lightGray, for: .normal)
        self.delete.setTitleColor(UIColor.lightGray, for: .normal)
        self.archive.isUserInteractionEnabled = false
        self.delete.isUserInteractionEnabled = false
        self.read.isUserInteractionEnabled = false
        self.searchController.hidesNavigationBarDuringPresentation = false
        //
        //let ChatPrerecord : NSSet = NSSet(array: ChatPrerecordArr as! [Any])
        ///if ChatPrerecord.count > 0 {
        //ChatPrerecordArr = ChatPrerecord.allObjects as! NSMutableArray
       // ChatPrerecordArr  = [[NSSet setWithArray:ChatPrerecordArr] allObjects];
        //}
       // ReloadTable()
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        searchController.searchBar.resignFirstResponder()
        searchController.isActive = false
        searchActive = false
        SocketIOManager.sharedInstance.Delegate = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
       // ReloadTable()
    }
    
    @IBAction func archive_message(_ sender: UIButton) {
        print("archive")
        for i in 0..<ChatActionIndex.count{
            let record = ChatPrerecordArr[ChatActionIndex[i] as! Int]
            if(record is Chatpreloadrecord)
            {
                let chatprerecord:Chatpreloadrecord=ChatPrerecordArr[ChatActionIndex[i] as! Int] as! Chatpreloadrecord
                checking.add(chatprerecord.opponentid)
            }
            else
            {
                let chatprerecord:GroupDetail=ChatPrerecordArr[ChatActionIndex[i] as! Int] as! GroupDetail
                checking.add(chatprerecord.id)
            }
        }
        
        for i in 0..<checking.count{
            var index:Int = 0
            for j in 0..<ChatPrerecordArr.count{
                let record = ChatPrerecordArr[j]
                if(record is Chatpreloadrecord)
                {
                    let chatprerecord:Chatpreloadrecord=ChatPrerecordArr[j] as! Chatpreloadrecord
                    
                    if((checking[i] as! String).contains(chatprerecord.opponentid)){
                        index = j
                    }
                }
                else
                {
                    let chatprerecord:GroupDetail=ChatPrerecordArr[j] as! GroupDetail
                    if((checking[i] as! String).contains(chatprerecord.id)){
                        index = j
                    }
                }
            }
            self.ExecuteArchiveChat(indexpath: NSIndexPath(row: index, section: 0) as IndexPath)
        }
        chats_Tblview.setEditing(false, animated: true)
        isBeginEditing = false
        editBtn.setTitle(NSLocalizedString("Edit", comment: "Edit"), for: .normal)
        self.tapBar.isHidden = true
        ChatActionIndex = []
        read_all = false
        self.read.setTitle("Read", for:.normal)
        self.archive.setTitle("Archive", for:.normal)
        self.delete.setTitle("Delete", for:.normal)
        self.read.setTitleColor(UIColor.lightGray, for: .normal)
        self.archive.setTitleColor(UIColor.lightGray, for: .normal)
        self.delete.setTitleColor(UIColor.lightGray, for: .normal)
        self.archive.isUserInteractionEnabled = false
        self.delete.isUserInteractionEnabled = false
        self.bottom_chatTable.constant = 0
        ChatActionIndex = []
        checking = []
        read_msg = []
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
    
    @IBAction func read_messages(_ sender: UIButton) {
        if(read_all){
            for i in 0..<ChatPrerecordArr.count{
                let record = self.ChatPrerecordArr[i]
                if(record is Chatpreloadrecord)
                {
                    let chatpreloadRecord:Chatpreloadrecord = self.ChatPrerecordArr[i] as! Chatpreloadrecord
                    let user_common_id = "\(Themes.sharedInstance.Getuser_id())-\(chatpreloadRecord.opponentid)"
                    self.ClearUnreadMessages(user_common_id: user_common_id,status: "0",indexpath:NSIndexPath(row: i, section: 0) as IndexPath,convID:chatpreloadRecord.opponentlastmessageid)
                }
                else
                {
                    let chatpreloadRecord:GroupDetail = self.ChatPrerecordArr[i] as! GroupDetail
                    let user_common_id = "\(Themes.sharedInstance.Getuser_id())-\(chatpreloadRecord.id)"
                    self.ClearUnreadMessages(user_common_id: user_common_id,status: "0",indexpath:NSIndexPath(row: i, section: 0) as IndexPath,convID:chatpreloadRecord.id)
                }
            }
        }else{
            
            for i in 0..<ChatActionIndex.count{
                let record = self.ChatPrerecordArr[i]
                if(record is Chatpreloadrecord)
                {
                    let chatpreloadRecord:Chatpreloadrecord = self.ChatPrerecordArr[ChatActionIndex[i] as! Int] as! Chatpreloadrecord
                    let user_common_id = "\(Themes.sharedInstance.Getuser_id())-\(chatpreloadRecord.opponentid)"
                    self.ClearUnreadMessages(user_common_id: user_common_id,status: "0",indexpath:NSIndexPath(row: ChatActionIndex[i] as! Int, section: 0) as IndexPath,convID:chatpreloadRecord.opponentlastmessageid)
                }
                else
                {
                    let chatpreloadRecord:GroupDetail = self.ChatPrerecordArr[ChatActionIndex[i] as! Int] as! GroupDetail
                    let user_common_id = "\(Themes.sharedInstance.Getuser_id())-\(chatpreloadRecord.id)"
                    self.ClearUnreadMessages(user_common_id: user_common_id,status: "0",indexpath:NSIndexPath(row: ChatActionIndex[i] as! Int, section: 0) as IndexPath,convID:chatpreloadRecord.id)
                }
            }
            chats_Tblview.setEditing(false, animated: true)
            isBeginEditing = false
            editBtn.setTitle(NSLocalizedString("Edit", comment: "Edit"), for: .normal)
            self.tapBar.isHidden = true
            ChatActionIndex = []
            read_all = false
            self.read.setTitle("Read", for:.normal)
            self.archive.setTitle("Archive", for:.normal)
            self.delete.setTitle("Delete", for:.normal)
            self.read.setTitleColor(UIColor.lightGray, for: .normal)
            self.archive.setTitleColor(UIColor.lightGray, for: .normal)
            self.delete.setTitleColor(UIColor.lightGray, for: .normal)
            self.archive.isUserInteractionEnabled = false
            self.delete.isUserInteractionEnabled = false
            self.bottom_chatTable.constant = 0
            ChatActionIndex = []
            read_msg = []
        }
    }
    
    @IBAction func delete_messages(_ sender: UIButton) {
        print("delete")
        
        for i in 0..<ChatActionIndex.count{
            let record = ChatPrerecordArr[ChatActionIndex[i] as! Int]
            if(record is Chatpreloadrecord)
            {
                let chatprerecord:Chatpreloadrecord=ChatPrerecordArr[ChatActionIndex[i] as! Int] as! Chatpreloadrecord
                checking.add(chatprerecord.opponentid)
            }
            else
            {
                let chat_ino:GroupDetail = self.ChatPrerecordArr[ChatActionIndex[i] as! Int] as! GroupDetail
                Themes.sharedInstance.executeClearChat("0", chat_ino.id, true)
            }
        }
        
        for i in 0..<checking.count{
            var index:Int = 0
            for j in 0..<ChatPrerecordArr.count{
                let record = ChatPrerecordArr[j]
                if(record is Chatpreloadrecord)
                {
                    let chatprerecord:Chatpreloadrecord=ChatPrerecordArr[j] as! Chatpreloadrecord
                    if((checking[i] as! String).contains(chatprerecord.opponentid)){
                        index = j
                    }
                }
            }
            let record = ChatPrerecordArr[index]
            if(record is Chatpreloadrecord)
            {
                let chatprerecord:Chatpreloadrecord=ChatPrerecordArr[index] as! Chatpreloadrecord
                Themes.sharedInstance.executeClearChat("0", chatprerecord.opponentid, true)
            }
        }
        chats_Tblview.setEditing(false, animated: true)
        isBeginEditing = false
        editBtn.setTitle(NSLocalizedString("Edit", comment: "Edit"), for: .normal)
        self.tapBar.isHidden = true
        ChatActionIndex = []
        read_all = false
        self.read.setTitle("Read", for:.normal)
        self.archive.setTitle("Archive", for:.normal)
        self.delete.setTitle("Delete", for:.normal)
        self.read.setTitleColor(UIColor.lightGray, for: .normal)
        self.archive.setTitleColor(UIColor.lightGray, for: .normal)
        self.delete.setTitleColor(UIColor.lightGray, for: .normal)
        self.archive.isUserInteractionEnabled = false
        self.delete.isUserInteractionEnabled = false
        self.bottom_chatTable.constant = 0
        ChatActionIndex = []
        checking = []
        read_msg = []
    }
  
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        ReloadTable()
        btn_View.isHidden = false
        SocketIOManager.sharedInstance.Delegate = self
        searchActive = false
        isBeginEditing = false
        tapBar.isHidden = true
        self.tapBar.isHidden = true
        if(searchActive == true){
            editBtn.isHidden = true
        }else{
            chats_Tblview.setEditing(false, animated: true)
            isBeginEditing = false
            editBtn.setTitle(NSLocalizedString("Edit", comment: "Edit"), for: .normal)
        }
        ChatActionIndex = []
        checking = []
        read_msg = []
        self.read.setTitle("Read", for:.normal)
        self.archive.setTitle("Archive", for:.normal)
        self.delete.setTitle("Delete", for:.normal)
        self.read.setTitleColor(UIColor.lightGray, for: .normal)
        self.archive.setTitleColor(UIColor.lightGray, for: .normal)
        self.delete.setTitleColor(UIColor.lightGray, for: .normal)
        self.archive.isUserInteractionEnabled = false
        self.delete.isUserInteractionEnabled = false
        self.read.isUserInteractionEnabled = false
        read_all = false
    }
    
    func changeStatus(_ notify: Notification){
        Themes.sharedInstance.RemoveactivityView(View: self.view)
        if(notify.userInfo != nil)
        {
            let ResponseDict:NSDictionary = notify.userInfo! as NSDictionary
            if(ResponseDict.count > 0){
                let status:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "type") as AnyObject)
                if(status == "password"){
                    Themes.sharedInstance.ShowNotification("Password updated successfully", true)
                }else if(status == "unlock"){
                    Themes.sharedInstance.ShowNotification("Chat unlocked successfully", true)
                }
                self.chats_Tblview.allowsSelection = true
            }
        }
    }
    
    func TypingStatus(not:Notification)
    {
    }
    
    
    func ReloadAllTable()
    {
        
        favArray=NSMutableArray()
        let predicate = NSPredicate(format: "is_fav != %@", "2")
        let CheckFav = DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Favourite_Contact, SortDescriptor: nil, predicate: predicate, Limit: 0) as! NSArray
        if(CheckFav.count > 0)
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
                    favRecord.conv_id = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "conv_id"))

                    favArray.add(favRecord)
                }
            }
            
        }
        
    }
    
    func reload()
    {
        DispatchQueue.main.async {
            Themes.sharedInstance.RemoveactivityView(View: self.chats_Tblview)
            self.ReloadTable()
        }
    }
    
    func ReloadTable()
    {
//        DispatchQueue.global(qos: .background).async {
            if(self.isBeginEditing)
            {
                //            DidclickEdit(self.editBtn)
            }
            Themes.sharedInstance.RemoveactivityView(View: self.chats_Tblview)
            self.ChatPrerecordArr=NSMutableArray()
            let CheckPreloadRecord=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_id", FetchString: Themes.sharedInstance.Getuser_id())
            
            var servertimeStr:String = Themes.sharedInstance.getServerTime()
            if(servertimeStr == "")
            {
                servertimeStr = "0"
            }
            if(CheckPreloadRecord)
            {
                let p1 = NSPredicate(format: "user_id = %@", Themes.sharedInstance.Getuser_id())
                let p2 = NSPredicate(format: "chat_type != %@", "secret")
                
                let p3 = NSPredicate(format: "is_archived = %@", "0")
                
                let p4 = NSPredicate(format: "is_archived = %@", "1")
                let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2, p3])
                let chatintiatedDetailArr=DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Chat_intiated_details, SortDescriptor: "timestamp", predicate: predicate,Limit:0) as! NSArray
                let ChatArchPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2, p4])
                let chatArchivedArr=DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Chat_intiated_details, SortDescriptor: nil, predicate: ChatArchPredicate,Limit:0) as! NSArray
                if(chatArchivedArr.count > 0)
                {
                    self.broadCastBtn.setTitle(NSLocalizedString("Archived Chats (", comment:"Archived Chats (") + "\(chatArchivedArr.count)" + ")", for: .normal)
                }
                else
                {
                    self.broadCastBtn.setTitle(NSLocalizedString("Archived Chats (0)", comment:"Archived Chats (0)") , for: .normal)
                }
                if(chatintiatedDetailArr.count > 0)
                {
                    for i in 0..<chatintiatedDetailArr.count
                    {
                        let Reponse_Dict:NSManagedObject = chatintiatedDetailArr[i] as! NSManagedObject
                        
                        let chat_type = Themes.sharedInstance.CheckNullvalue(Passed_value: Reponse_Dict.value(forKey: "chat_type"))
                        if(chat_type == "single")
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
                            
                            let GetUserDetails:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "id", FetchString:  chatprerecord.opponentid, SortDescriptor: nil) as! NSArray
                            if(GetUserDetails.count > 0)
                            {
                                for i in 0 ..< GetUserDetails.count {
                                    let ResponseDict = GetUserDetails[i] as! NSManagedObject
                                    chatprerecord.is_online = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "is_online"))
                                    chatprerecord.timestamp = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "time_stamp"))
                                    chatprerecord.opponentname=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "name"))
                                    chatprerecord.isEmployee = (ResponseDict as! Favourite_Contact).isUserTypeEmployee
                                    chatprerecord.opponentimage=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "profilepic"))
                                    chatprerecord.oppopnentnumber=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "msisdn"))
                                    
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
                                if(chatprerecord.info_type != "72")
                                {
                                    chatprerecord.opponentlastmessageDate=Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "timestamp"))
                                }
                                else
                                {
                                    chatprerecord.opponentlastmessageDate=timestamp
                                }
                                
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
                            
                            
                            self.ChatPrerecordArr.add(chatprerecord)
                        }
                        else if(chat_type == "group")
                        {
                            let UserReponseDict:NSManagedObject = chatintiatedDetailArr[i] as! NSManagedObject
                            
                            let GroupDetailArr =  DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Group_details, attribute: "user_common_id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: UserReponseDict.value(forKey: "user_common_id")) , SortDescriptor: "timestamp") as! NSArray
                            if(GroupDetailArr.count > 0)
                            {
                                for j in 0..<GroupDetailArr.count
                                {
                                    let ReponseDict:NSManagedObject = GroupDetailArr[j] as! NSManagedObject
                                    
                                    let GroupDetailRec:GroupDetail=GroupDetail()
                                    let CheeckChat:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "user_common_id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: UserReponseDict.value(forKey: "user_common_id")))
                                    if(CheeckChat)
                                    {
                                        let Cht_dict:NSManagedObject = (DatabaseHandler.sharedInstance.FetchFromDatabaseWithLimit(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "user_common_id", Predicatefromat: "==", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: UserReponseDict.value(forKey: "user_common_id")), Limit: 1, SortDescriptor: "date") as NSArray)[0] as! NSManagedObject
                                        
                                        GroupDetailRec.infotype = Themes.sharedInstance.CheckNullvalue(Passed_value: Cht_dict.value(forKey: "info_type"))
                                        GroupDetailRec.otherGroupMessageID = Themes.sharedInstance.CheckNullvalue(Passed_value: Cht_dict.value(forKey: "id"))
                                        if(GroupDetailRec.infotype != "0")
                                        {                                            
                                            let id = Themes.sharedInstance.CheckNullvalue(Passed_value: Cht_dict.value(forKey: "id"))
                                            let from = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Other_Group_message, attrib_name: "id", fetchString: id, returnStr: "from")
                                            let to = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Other_Group_message, attrib_name: "id", fetchString: id, returnStr: "person_id")
                                            let group_type = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Other_Group_message, attrib_name: "id", fetchString: id, returnStr: "group_type")
                                            
                                            GroupDetailRec.Group_last_Message = Themes.sharedInstance.returnOtherMessages(from, to, group_type)
                                        }
                                        else
                                        {
                                            GroupDetailRec.Group_last_Message = Themes.sharedInstance.CheckNullvalue(Passed_value: Cht_dict.value(forKey: "payload"))
                                            
                                        }
                                        
                                        GroupDetailRec.Messagetype=Themes.sharedInstance.CheckNullvalue(Passed_value: Cht_dict.value(forKey: "type"))
                                        
                                        GroupDetailRec.TimeStamp=Themes.sharedInstance.CheckNullvalue(Passed_value: Cht_dict.value(forKey: "timestamp"))
                                        if(GroupDetailRec.infotype != "72")
                                        {
                                            GroupDetailRec.opponentlastmessageDate=Themes.sharedInstance.CheckNullvalue(Passed_value: Cht_dict.value(forKey: "timestamp"))
                                            GroupDetailRec.from =  Themes.sharedInstance.CheckNullvalue(Passed_value: Cht_dict.value(forKey: "from"))
                                        }
                                        else
                                        {
                                            GroupDetailRec.opponentlastmessageDate=Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "timestamp"))
                                            GroupDetailRec.from =  ""
                                        }
                                        
                                    }
                                    else
                                    {
                                        GroupDetailRec.Group_last_Message=""
                                        GroupDetailRec.TimeStamp=Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "timestamp"))
                                        GroupDetailRec.opponentlastmessageDate=Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "timestamp"))
                                        
                                        
                                    }
                                    let MessageCount:Int=Int(Themes.sharedInstance.CheckNullvalue(Passed_value: UserReponseDict.value(forKey: "chat_count")))!
                                    let is_read:String=Themes.sharedInstance.CheckNullvalue(Passed_value: UserReponseDict.value(forKey: "is_read"))
                                    if(is_read == "1")
                                    {
                                        GroupDetailRec.isUnreadMessages = true
                                        
                                    }
                                    else
                                    {
                                        GroupDetailRec.isUnreadMessages = false
                                    }
                                    
                                    if(MessageCount != 0)
                                    {
                                        GroupDetailRec.isUnreadMessages = true
                                        GroupDetailRec.Group_Message_Count="\(MessageCount)"
                                    }
                                    else
                                    {
                                        GroupDetailRec.Group_Message_Count=""
                                    }
                                    GroupDetailRec.displayName=Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "displayName"))
                                    GroupDetailRec.id=Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "id"))
                                    GroupDetailRec.displayavatar=Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "displayavatar"))
                                    GroupDetailRec.Group_userid=Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "from"))
                                    GroupDetailRec.is_archived=Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "is_archived"))
                                    GroupDetailRec.is_marked=Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "is_marked"))
                                    GroupDetailRec.isAdmin=Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "isAdmin"))
                                    
                                    let groupData:NSData?=ReponseDict.value(forKey: "groupUsers") as? NSData
                                    if(groupData != nil)
                                    {
                                        GroupDetailRec.groupUsers=NSKeyedUnarchiver.unarchiveObject(with: groupData! as Data) as! NSArray
                                    }
                                    
                                    var isYou : Bool = false
                                    for i in 0..<GroupDetailRec.groupUsers.count{
                                        let Dict:NSDictionary=GroupDetailRec.groupUsers[i] as! NSDictionary
                                        if(Themes.sharedInstance.CheckNullvalue(Passed_value: Dict.object(forKey: "id")) == Themes.sharedInstance.Getuser_id())
                                        {
                                            isYou = true
                                            break
                                        }
                                    }
                                    if(isYou)
                                    {
                                        GroupDetailRec.is_you_left = false
                                    }
                                    else
                                    {
                                        GroupDetailRec.is_you_left = true
                                    }
                                    var found : Bool = false
                                    if ChatPrerecordArr.count > 0 {
                                    for index in  0..<ChatPrerecordArr.count {
                                        if (ChatPrerecordArr[index] as? GroupDetail) != nil {
                                      var group = ChatPrerecordArr[index] as! GroupDetail
                                      var id2 = group.id
                                      var id3 = (GroupDetailRec as! GroupDetail).id
                                        if id2 == id3  {
                                           found = true
                                        }
                                    }
                                }
                            }
                                    if found == false {
                                        self.ChatPrerecordArr.add(GroupDetailRec)
                                    }
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    if(self.ChatPrerecordArr.count > 0)
                    {
                        var SortArray:NSArray=NSArray(array: self.ChatPrerecordArr)
                        let descriptor: NSSortDescriptor = NSSortDescriptor(key: "opponentlastmessageDate", ascending: false)
                        SortArray = SortArray.sorted{(Themes.sharedInstance.shouldSortChatObj(first: $0, second: $1))} as NSArray
//                        self.ChatPrerecordArr=NSMutableArray(array: SortArray)
//                        print(">>>>>>the count is\(self.ChatPrerecordArr.count)")
                        self.chats_Tblview.reloadData()
                        self.ReloadAllTable()
                        self.reloadMessages()
                        self.Nochat_view.isHidden=true
                        self.chats_Tblview.isHidden=false
                        self.editBtn.isHidden = false
                    }
                    else
                    {
                        self.Nochat_view.isHidden=false
                        self.tapBar.isHidden = true
                        self.chats_Tblview.isHidden=true
                        self.editBtn.isHidden = true
                    }
                    
                }
                else
                {
                    self.Nochat_view.isHidden=false
                    self.tapBar.isHidden = true
                    self.chats_Tblview.isHidden=true
                    self.editBtn.isHidden = true
                }
            }
            else
            {
                self.editBtn.isHidden = true
                self.Nochat_view.isHidden=false
                self.chats_Tblview.isHidden=true
                self.chats_Tblview.reloadData()
            }
//        }
        
    }
    
    func reloadMessages(){
        DispatchQueue.main.async {
            self.to_id = NSMutableArray()
            self.allChat_msg = NSMutableArray()
            
            let p1 = NSPredicate(format: "user_id = %@", Themes.sharedInstance.Getuser_id())
            let p2 = NSPredicate(format: "chat_type != %@", "secret")
            let p3 = NSPredicate(format: "is_archived = %@", "0")
            
            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2, p3])
            let chatintiatedDetailArr = DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Chat_intiated_details, SortDescriptor: "timestamp", predicate: predicate,Limit:0) as! [Chat_intiated_details]
            _ = chatintiatedDetailArr.map {
                
                let msg_contact:NSMutableArray = NSMutableArray()
                let all_msg:NSMutableArray = NSMutableArray()
                let record = $0
                if(Themes.sharedInstance.CheckNullvalue(Passed_value: record.chat_type) == "single")
                {
                    let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
                    let to:String=Themes.sharedInstance.CheckNullvalue(Passed_value: record.opponent_id)
                    let name:String=Themes.sharedInstance.setNameTxt(to, "single")
                    let phone_no:String = Themes.sharedInstance.setPhoneTxt(to)
                    let User_chat_id=from + "-" + to;
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
                            var message:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "payload"))
                            message = Themes.sharedInstance.getID_Range_Payload_Name(message: message)[2] as! String
                            let doc_ids:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id"))
                            let timestamp:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "timestamp"))
                            let messageStatus:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "message_status"))
                            messages.isRead = messageStatus
                            messages.timestamp = timestamp
                            messages.doc_id = doc_ids
                            messages.type = "single"
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
                                messages.type = "single"
                                msg_contact.add(messages)
                                all_msg.add(contact_name)
                            }
                        }else if(messageType == "4"){
                            var message:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "payload"))
                            message = Themes.sharedInstance.getID_Range_Payload_Name(message: message)[2] as! String
                            let doc_ids:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id"))
                            let timestamp:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "timestamp"))
                            let messageStatus:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "message_status"))
                            messages.isRead = messageStatus
                            messages.timestamp = timestamp
                            messages.doc_id = doc_ids
                            messages.type = "single"
                            msg_contact.add(messages)
                            all_msg.add(message)
                        }else if(messageType == "1"){
                            var message:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "payload"))
                            message = Themes.sharedInstance.getID_Range_Payload_Name(message: message)[2] as! String
                            let doc_ids:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id"))
                            let timestamp:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "timestamp"))
                            let messageStatus:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "message_status"))
                            messages.isRead = messageStatus
                            messages.timestamp = timestamp
                            messages.doc_id = doc_ids
                            messages.type = "single"
                            msg_contact.add(messages)
                            all_msg.add(message)
                        }
                    }
                    self.to_id.add(msg_contact)
                    self.allChat_msg.add(all_msg)
                }
                else if(Themes.sharedInstance.CheckNullvalue(Passed_value: record.chat_type) == "group")
                {
                    let groupDetail = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Group_details, attribute: "user_common_id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: record.user_common_id) , SortDescriptor: "timestamp") as! [Group_details]
                    guard groupDetail.count > 0 else {return}
                    let groupRec = groupDetail[0]
                    let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
                    let to:String=Themes.sharedInstance.CheckNullvalue(Passed_value: groupRec.id)
                    let name:String=Themes.sharedInstance.CheckNullvalue(Passed_value: groupRec.displayName)
                    let User_chat_id=from + "-" + to;
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
                        messages.name = name
                        if(messageType == "0"){
                            var message:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "payload"))
                            
                            message = Themes.sharedInstance.getID_Range_Payload_Name(message: message)[2] as! String
                            let doc_ids:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id"))
                            let timestamp:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "timestamp"))
                            let messageStatus:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "message_status"))
                            messages.isRead = messageStatus
                            messages.timestamp = timestamp
                            messages.doc_id = doc_ids
                            messages.type = "group"
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
                                messages.type = "group"
                                msg_contact.add(messages)
                                all_msg.add(contact_name)
                            }
                        }else if(messageType == "4"){
                            var message:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "payload"))
                            message = Themes.sharedInstance.getID_Range_Payload_Name(message: message)[2] as! String
                            let doc_ids:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id"))
                            let timestamp:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "timestamp"))
                            let messageStatus:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "message_status"))
                            messages.isRead = messageStatus
                            messages.timestamp = timestamp
                            messages.doc_id = doc_ids
                            messages.type = "group"
                            msg_contact.add(messages)
                            all_msg.add(message)
                        }else if(messageType == "1"){
                            var message:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "payload"))
                            message = Themes.sharedInstance.getID_Range_Payload_Name(message: message)[2] as! String
                            let doc_ids:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id"))
                            let timestamp:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "timestamp"))
                            let messageStatus:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "message_status"))
                            messages.isRead = messageStatus
                            messages.timestamp = timestamp
                            messages.doc_id = doc_ids
                            messages.type = "group"
                            msg_contact.add(messages)
                            all_msg.add(message)
                        }
                    }
                    self.to_id.add(msg_contact)
                    self.allChat_msg.add(all_msg)
                }
            }
        }
    }
    
    func CheckArchivedChat()
    {
        let p1 = NSPredicate(format: "user_id = %@", Themes.sharedInstance.Getuser_id())
        let p4 = NSPredicate(format: "is_archived = %@", "1")
        let ChatArchPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1,p4])
        let chatArchivedArr=DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Chat_intiated_details, SortDescriptor: nil, predicate: ChatArchPredicate,Limit:0) as! NSArray
        if(chatArchivedArr.count > 0)
        {
            broadCastBtn.setTitle("Archived Chats (\(chatArchivedArr.count))", for: .normal)
        }
        else
        {
            broadCastBtn.setTitle("Archived Chats (0)", for: .normal)
        }
        
    }
    
    @IBAction func openImageChats(sender:UIButton){
        let indexpath = NSIndexPath.init(row: sender.tag, section: 0)
        let cellItem = chats_Tblview.cellForRow(at: indexpath as IndexPath)
        if(cellItem is ChatsTableViewCell)
        {
            let configuration = ImageViewerConfiguration { config in
                config.imageView = (cellItem as! ChatsTableViewCell).user_Images
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
            else
            {
                let chatprerecord:GroupDetail=ChatPrerecordArr[indexPath.row] as! GroupDetail
                if(chatprerecord.from == "")
                {
                    return 68
                }
                else
                {
                    return 94
                }
            }
            
        }
        else if(searchActive == true && section[indexPath.section] as! String == "Chats"){
            let searchRecord:NSArray = allArray[indexPath.section] as! NSArray
            let record = searchRecord[indexPath.row]
            if(record is Chatpreloadrecord)
            {
                return 68
            }
            else
            {
                let chatprerecord:GroupDetail=searchRecord[indexPath.row] as! GroupDetail
                if(chatprerecord.from == "")
                {
                    return 68
                }
                else
                {
                    return 94
                }
            }
            
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
        
        //let ChatPrerecord : NSSet = NSSet(array: ChatPrerecordArr as! [Any])
        
//         if ChatPrerecord.count > 0 {
//            let allObjects = ChatPrerecord.allObjects as! [ChatBaseModel]
//            let sortedObjects = allObjects.sorted{Double($0.opponentlastmessageDate)! > Double($1.opponentlastmessageDate)!}
//            ChatPrerecordArr = NSMutableArray(array: sortedObjects)
//         }
       // Phonenumber = Themes.sharedInstance.CheckNullvalue(Passed_value: (($0.value ).value(forKey: "digits") as! String))
        
        if(searchActive == true && (self.section[section] as! String == "Chats" || self.section[section] as! String == "Other Chats")){
            guard allArray.count > section else{return 0}
            let row:NSArray = allArray[section] as! NSArray
            return row.count
        }else if(searchActive == true && self.section[section] as! String == "Messages"){
            return filterMessage.count
        }
        return ChatPrerecordArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard indexPath.row < ChatPrerecordArr.count else{ return UITableViewCell() }

        if(searchActive == false){
            
            if (ChatPrerecordArr[indexPath.row] as? Chatpreloadrecord) != nil
            {
                let cell:ChatsTableViewCell  = tableView.dequeueReusableCell(withIdentifier: "ChatsTableViewCell") as! ChatsTableViewCell
                cell.messageCount_Lbl.layer.backgroundColor  = UIColor(red: 255.0/255.0, green: 10.0/255.0, blue: 20.0/255.0, alpha: 0.9).cgColor
                cell.messageCount_Lbl.layer.cornerRadius = 13
                cell.selectionStyle = .default
                cell.messageCount_Lbl.layer.cornerRadius = 13
                let chatprerecord:Chatpreloadrecord=ChatPrerecordArr[indexPath.row] as! Chatpreloadrecord
                cell.user_Images.setProfilePic(chatprerecord.opponentid, chatprerecord.ischattype)
                cell.user.tag = indexPath.row
                cell.user.addTarget(self, action: #selector(self.openImageChats(sender:)), for: .touchUpInside)
                cell.user_Images.clipsToBounds=true
                cell.chat_status.setImage(#imageLiteral(resourceName: "mute"), for: .normal)
                cell.is_locked.setImage(#imageLiteral(resourceName: "chat_lock"), for: .normal)
                cell.chat_status.isHidden = !Themes.sharedInstance.CheckMuteChats(id: chatprerecord.opponentid, type: chatprerecord.ischattype)
                cell.is_locked.isHidden = !Themes.sharedInstance.isChatLocked(id: chatprerecord.opponentid, type: chatprerecord.ischattype)

                if(chatprerecord.MessageType == "0" || chatprerecord.MessageType == "7" || chatprerecord.MessageType == "4")
                {
                    let payload = chatprerecord.opponentlastmessage
                    chatprerecord.opponentlastmessage = Themes.sharedInstance.getID_Range_Payload_Name(message: payload)[2] as! String
                    
                    cell.message_Lbl.text = Themes.sharedInstance.CheckNullvalue(Passed_value: chatprerecord.opponentlastmessage)
                    
                    let RangeArr = Themes.sharedInstance.getID_Range_Payload_Name(message: payload)[1] as! [NSRange]
                    let attributed = NSMutableAttributedString(string: cell.message_Lbl.text!)
                    
                    attributed.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.darkGray, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15.0)], range: NSMakeRange(0, (cell.message_Lbl.text?.length)!))
                    
                    RangeArr.forEach { range in
                        attributed.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.darkGray, NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15.0)], range: range)
                    }
                    if(RangeArr.count > 0)
                    {
                        cell.message_Lbl.attributedText = attributed
                    }
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
                    
                }
                else if(chatprerecord.MessageType == "23"){
                    let from = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_one_one, attrib_name: "id", fetchString: chatprerecord.opponentlastmessageDate, returnStr: "from")
                    cell.message_Lbl.text = "\(Themes.sharedInstance.setNameTxt(from, chatprerecord.ischattype)) Security code changed"
                }
                else{
                    cell.message_Lbl.text = ""
                }
                
                cell.delegate = self
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
                    cell.startTyping(chat_type: "single", objRecord: chatprerecord)
                }
                cell.isEmployeeImage.image = chatprerecord.isEmployee ? UIImage() : #imageLiteral(resourceName: "guest-icon")
                cell.time_Lbl.text=Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.ConverttimeStamp(timestamp: chatprerecord.opponentlastmessageDate))
                NSLog("timestmp \(chatprerecord.opponentlastmessageDate)")
               // cell.time_Lbl.textColor = UIColor.red
                tableView.separatorStyle = .none
                cell.messageCount_Lbl.adjustsFontSizeToFitWidth = true
                cell.name_Lbl.font = UIFont.boldSystemFont(ofSize: 16.0)
                
                if isBeginEditing{
                    
                    if  ChatActionIndex.contains(indexPath.row) {
                       // cell.isSelected = true
                        cell.setEditing(true, animated: false)
                    }
                }
                
                
                return cell
            }
            else
            {
                let cell:GroupChatTableViewCell  = tableView.dequeueReusableCell(withIdentifier: "GroupChatTableViewCell") as! GroupChatTableViewCell
                cell.delegate = self
                cell.messageCount_Lbl.layer.backgroundColor  = UIColor(red: 255.0/255.0, green: 10.0/255.0, blue: 20.0/255.0, alpha: 0.9).cgColor
                cell.messageCount_Lbl.isHidden=true
                cell.selectionStyle = .default
                let chatprerecord:GroupDetail=ChatPrerecordArr[indexPath.row] as! GroupDetail
                cell.sender_nameLbl.text = "\(Themes.sharedInstance.setNameTxt(chatprerecord.from, "single")):"
                cell.sender_nameLbl.isHidden = chatprerecord.from == ""
                cell.user_Images.setProfilePic(chatprerecord.id, "group")
                cell.user.tag = indexPath.row
                cell.user.addTarget(self, action: #selector(self.openImageChats(sender:)), for: .touchUpInside)
                cell.user_Images.clipsToBounds=true
                cell.chat_status.setImage(#imageLiteral(resourceName: "mute"), for: .normal)
                cell.is_locked.setImage(#imageLiteral(resourceName: "chat_lock"), for: .normal)
                cell.chat_status.isHidden = !Themes.sharedInstance.CheckMuteChats(id: chatprerecord.id, type: "group")
                cell.is_locked.isHidden = !Themes.sharedInstance.isChatLocked(id: chatprerecord.id, type: "group")

                if(chatprerecord.Messagetype == "0" || chatprerecord.Messagetype == "7" || chatprerecord.Messagetype == "4")
                {
                    let payload = Themes.sharedInstance.CheckNullvalue(Passed_value: chatprerecord.Group_last_Message)
                    let arr = Themes.sharedInstance.getID_Range_Payload_Name(message: payload)
                    chatprerecord.Group_last_Message = arr[2] as! String
                    let rangeArr = arr[1] as! [NSRange]
                    cell.message_Lbl.text = chatprerecord.Group_last_Message
                    
                    let attributed = NSMutableAttributedString(string: cell.message_Lbl.text!)
                    
                    attributed.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.darkGray, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15.0)], range: NSMakeRange(0, (cell.message_Lbl.text?.length)!))
                    
                    rangeArr.forEach { range in
                        attributed.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.darkGray, NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15.0)], range: range)
                    }
                    if(rangeArr.count > 0)
                    {
                        cell.message_Lbl.attributedText = attributed
                    }
                }
                    
                else if(chatprerecord.Messagetype == "1")
                {
                    cell.message_Lbl.text = "📷 Photo"
                }
                else if(chatprerecord.Messagetype == "2")
                {
                    cell.message_Lbl.text = "📹 Video"
                    
                }
                else if(chatprerecord.Messagetype == "3")
                {
                    cell.message_Lbl.text = "🎵 Audio"
                    
                }
                else if(chatprerecord.Messagetype == "4")
                {
                    cell.message_Lbl.text = "🔗 Link"
                    
                }
                else if(chatprerecord.Messagetype == "5")
                {
                    cell.message_Lbl.text = "📝 Contact"
                    
                }
                else if(chatprerecord.Messagetype == "6" || chatprerecord.Messagetype == "20")
                {
                    cell.message_Lbl.text = "📄 Document"
                    
                }
                    
                else if(chatprerecord.Messagetype == "14")
                {
                    cell.message_Lbl.text = "📍 Location"
                    
                }
                else if(chatprerecord.Messagetype == "23"){
                    cell.message_Lbl.text = "\(Themes.sharedInstance.setNameTxt(chatprerecord.from, "single")) Security code changed"
                }
                cell.name_Lbl.setNameTxt(chatprerecord.id, "group")
                cell.time_Lbl.text=Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.ConverttimeStamp(timestamp: chatprerecord.opponentlastmessageDate))
                
                
                if(chatprerecord.Group_Message_Count == "" && chatprerecord.isUnreadMessages == false)
                {
                    cell.messageCount_Lbl.isHidden=true
                    cell.chat_status.frame.x = cell.messageCount_Lbl.frame.x
                }
                else    if(chatprerecord.Group_Message_Count == "" && chatprerecord.isUnreadMessages == true)
                {
                    cell.messageCount_Lbl.isHidden = false
                    cell.messageCount_Lbl.text = ""
                    cell.chat_status.frame.x = cell.messageCount_Lbl.frame.x - cell.messageCount_Lbl.frame.width
                }
                else if(chatprerecord.Group_Message_Count != "" && chatprerecord.isUnreadMessages == false)
                {
                    cell.messageCount_Lbl.isHidden=false
                    
                    let countStr:String = Themes.sharedInstance.CheckNullvalue(Passed_value: chatprerecord.Group_Message_Count)
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
                else if(chatprerecord.Group_Message_Count != "" && chatprerecord.isUnreadMessages == true)
                {
                    cell.messageCount_Lbl.isHidden=false
                    let countStr:String = Themes.sharedInstance.CheckNullvalue(Passed_value: chatprerecord.Group_Message_Count)
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
                // cell.time_Lbl.text=Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.ConverttimeStamp(timestamp: chatprerecord.TimeStamp))
                // cell.name_Lbl?.text="\(SampleArr[indexPath.row])";
                // cell.name_Lbl?.sizeToFit()
                tableView.separatorStyle = .none
                tableView.separatorColor = nil
                cell.messageCount_Lbl.adjustsFontSizeToFitWidth = true
                cell.name_Lbl.font = UIFont.boldSystemFont(ofSize: 16.0)
                cell.sender_nameLbl.font = UIFont.boldSystemFont(ofSize: 14.0)
                return cell
            }
            
        }else if(searchActive == true && section[indexPath.section] as! String == "Chats"){
            let searchRecord:NSArray = allArray[indexPath.section] as! NSArray
            if let record = searchRecord[indexPath.row] as? Chatpreloadrecord
            {
                let cell:ChatsTableViewCell  = tableView.dequeueReusableCell(withIdentifier: "ChatsTableViewCell") as! ChatsTableViewCell
                
                cell.messageCount_Lbl.layer.backgroundColor  = UIColor(red: 255.0/255.0, green: 10.0/255.0, blue: 20.0/255.0, alpha: 0.9).cgColor
                cell.messageCount_Lbl.layer.cornerRadius = 13
                cell.selectionStyle = .default
                cell.messageCount_Lbl.layer.cornerRadius = 13
                let chatprerecord:Chatpreloadrecord=searchRecord[indexPath.row] as! Chatpreloadrecord
                cell.user_Images.setProfilePic(record.opponentid, record.ischattype)
                cell.user.isUserInteractionEnabled = false
                cell.user_Images.clipsToBounds=true
                cell.message_Lbl.text=Themes.sharedInstance.CheckNullvalue(Passed_value: chatprerecord.opponentlastmessage)
                cell.delegate = self
                cell.chat_status.setImage(#imageLiteral(resourceName: "mute"), for: .normal)
                cell.is_locked.setImage(#imageLiteral(resourceName: "chat_lock"), for: .normal)
                cell.chat_status.isHidden = !Themes.sharedInstance.CheckMuteChats(id: record.opponentid, type: record.ischattype)
                cell.is_locked.isHidden = !Themes.sharedInstance.isChatLocked(id: record.opponentid, type: record.ischattype)
                cell.name_Lbl.setNameTxt(record.opponentid, record.ischattype)

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
                cell.isEmployeeImage.image = chatprerecord.isEmployee ? UIImage() : #imageLiteral(resourceName: "guest-icon")
                cell.time_Lbl.text=Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.ConverttimeStamp(timestamp: chatprerecord.opponentlastmessageDate))
                tableView.separatorStyle = .singleLine
                tableView.separatorColor = nil
                cell.messageCount_Lbl.adjustsFontSizeToFitWidth = true
                return cell
            }
            else
            {
                let cell:GroupChatTableViewCell  = tableView.dequeueReusableCell(withIdentifier: "GroupChatTableViewCell") as! GroupChatTableViewCell
                cell.delegate = self
                cell.messageCount_Lbl.layer.backgroundColor  = UIColor(red: 255.0/255.0, green: 10.0/255.0, blue: 20.0/255.0, alpha: 0.9).cgColor
                cell.messageCount_Lbl.isHidden=true
                cell.selectionStyle = .default
                let chatprerecord:GroupDetail=searchRecord[indexPath.row] as! GroupDetail
                cell.sender_nameLbl.text = "\(Themes.sharedInstance.setNameTxt(chatprerecord.from, "single")):"
                cell.sender_nameLbl.isHidden = chatprerecord.from == ""
                cell.user_Images.setProfilePic(chatprerecord.id, "group")
                cell.user.isUserInteractionEnabled = false
                cell.user_Images.clipsToBounds=true
                var payload = Themes.sharedInstance.CheckNullvalue(Passed_value: chatprerecord.Group_last_Message)
                let groupUsers = chatprerecord.groupUsers as! [NSDictionary]
                groupUsers.forEach { dict in
                    let id = "@@***" + Themes.sharedInstance.CheckNullvalue(Passed_value: dict.value(forKey: "id")) + "@@***"
                    let name = Themes.sharedInstance.setNameTxt(Themes.sharedInstance.CheckNullvalue(Passed_value: dict.value(forKey: "id")), "single")
                    payload = payload.replacingOccurrences(of: id, with: "@"+name)
                }
                
                cell.message_Lbl.text = payload
                cell.name_Lbl.setNameTxt(chatprerecord.id, "group")
                cell.time_Lbl.text=Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.ConverttimeStamp(timestamp: chatprerecord.opponentlastmessageDate))
                cell.chat_status.setImage(#imageLiteral(resourceName: "mute"), for: .normal)
                cell.is_locked.setImage(#imageLiteral(resourceName: "chat_lock"), for: .normal)
                cell.chat_status.isHidden = !Themes.sharedInstance.CheckMuteChats(id: chatprerecord.id, type: "group")
                cell.is_locked.isHidden = !Themes.sharedInstance.isChatLocked(id: chatprerecord.id, type: "group")

                if(chatprerecord.Group_Message_Count == "" && chatprerecord.isUnreadMessages == false)
                {
                    cell.messageCount_Lbl.isHidden=true
                    cell.chat_status.frame.x = cell.messageCount_Lbl.frame.x
                }
                else    if(chatprerecord.Group_Message_Count == "" && chatprerecord.isUnreadMessages == true)
                {
                    cell.messageCount_Lbl.isHidden = false
                    cell.messageCount_Lbl.text = ""
                    cell.chat_status.frame.x = cell.messageCount_Lbl.frame.x - cell.messageCount_Lbl.frame.width
                }
                else if(chatprerecord.Group_Message_Count != "" && chatprerecord.isUnreadMessages == false)
                {
                    cell.messageCount_Lbl.isHidden=false
                    let countStr:String = Themes.sharedInstance.CheckNullvalue(Passed_value: chatprerecord.Group_Message_Count)
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
                else if(chatprerecord.Group_Message_Count != "" && chatprerecord.isUnreadMessages == true)
                {
                    cell.messageCount_Lbl.isHidden=false
                    let countStr:String = Themes.sharedInstance.CheckNullvalue(Passed_value: chatprerecord.Group_Message_Count)
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
                cell.messageCount_Lbl.adjustsFontSizeToFitWidth = true
                tableView.separatorStyle = .singleLine
                tableView.separatorColor = nil
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
    
    func enterToChat(id:String,type:String,indexpath:IndexPath){
        self.searchController.dismissView(animated:true, completion:nil)
        let record = ChatPrerecordArr[indexpath.row]
        if(record is Chatpreloadrecord)
        {
            Themes.sharedInstance.enterTochat(id: id, type: type) { (success) in
                if(success)
                {
                    let chatprerecord:Chatpreloadrecord = self.ChatPrerecordArr[indexpath.row] as! Chatpreloadrecord
                    let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                    ObjInitiateChatViewController.Chat_type = type
                    ObjInitiateChatViewController.opponent_id = chatprerecord.opponentid
                    self.searchController.searchBar.resignFirstResponder()
                    self.searchController.isActive = false
                    self.pushView(ObjInitiateChatViewController, animated: true)
                }
            }
        }
        else
        {
            Themes.sharedInstance.enterTochat(id: id, type: type) { (success) in
                if(success)
                {
                    let chatprerecord:GroupDetail = self.ChatPrerecordArr[indexpath.row] as! GroupDetail
                    let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                    ObjInitiateChatViewController.Chat_type = type
                    ObjInitiateChatViewController.conv_id = chatprerecord.id
                    ObjInitiateChatViewController.opponent_id = chatprerecord.id
                    self.searchController.searchBar.resignFirstResponder()
                    self.searchController.isActive = false
                    self.pushView(ObjInitiateChatViewController, animated: true)
                }
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if(searchActive == false){
            if(!isBeginEditing)
            {
                let record = ChatPrerecordArr[indexPath.row]
                if(record is Chatpreloadrecord)
                {
                    let chatprerecord:Chatpreloadrecord=ChatPrerecordArr[indexPath.row] as! Chatpreloadrecord
                    let chatLocked = Themes.sharedInstance.isChatLocked(id: chatprerecord.opponentid, type: chatprerecord.ischattype)
                    if(chatLocked){
                        self.enterToChat(id: chatprerecord.opponentid,type: "single", indexpath:indexPath)
                    }else{
                        let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                        ObjInitiateChatViewController.Chat_type="single"
                        ObjInitiateChatViewController.opponent_id = chatprerecord.opponentid
                        self.searchController.dismissView(animated:true, completion:nil)
                        self.searchController.searchBar.resignFirstResponder()
                        self.searchController.isActive = false
                        self.pushView(ObjInitiateChatViewController, animated: true)
                    }
                }
                else
                {
                    let chatprerecord:GroupDetail=ChatPrerecordArr[indexPath.row] as! GroupDetail
                    let chatLocked = Themes.sharedInstance.isChatLocked(id: chatprerecord.id, type: "group")
                    if(chatLocked == true){
                        self.enterToChat(id: chatprerecord.id, type: "group", indexpath: indexPath)
                    }else{
                        let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                        ObjInitiateChatViewController.Chat_type="group"
                        ObjInitiateChatViewController.opponent_id = chatprerecord.id
                        self.searchController.dismissView(animated:true, completion:nil)
                        self.searchController.searchBar.resignFirstResponder()
                        self.searchController.isActive = false
                        self.pushView(ObjInitiateChatViewController, animated: true)
                    }
                    
                    
                }
                
            }else{
                print("index",indexPath.row)
                if(!ChatActionIndex.contains(indexPath.row))
                {
                    ChatActionIndex.add(indexPath.row)
                }
                read_msg = NSMutableArray()
                delete_msg = NSMutableArray()
                
                for i in 0..<ChatActionIndex.count{
                    let record = ChatPrerecordArr[ChatActionIndex[i] as! Int]
                    if(record is Chatpreloadrecord)
                    {
                        let chatprerecord:Chatpreloadrecord=ChatPrerecordArr[ChatActionIndex[i] as! Int] as! Chatpreloadrecord
                        
                        if(chatprerecord.isUnreadMessages){
                            read_msg.add(true)
                        }else{
                            read_msg.add(false)
                        }
                    }
                    else
                    {
                        let chatprerecord:GroupDetail=ChatPrerecordArr[ChatActionIndex[i] as! Int] as! GroupDetail
                        if(chatprerecord.isUnreadMessages){
                            read_msg.add(true)
                        }else{
                            read_msg.add(false)
                        }
                    }
                    
                }
                
                for i in 0..<ChatActionIndex.count{
                    let record = ChatPrerecordArr[ChatActionIndex[i] as! Int]
                    if(record is GroupDetail)
                    {
                        let chatprerecord:GroupDetail=ChatPrerecordArr[ChatActionIndex[i] as! Int] as! GroupDetail
                        if(chatprerecord.is_you_left){
                            let chatLocked = Themes.sharedInstance.isChatLocked(id: chatprerecord.id, type: "group")
                            if(chatLocked){
                                delete_msg.add(false)
                                
                            }else{
                                delete_msg.add(true)
                            }
                        }else{
                            delete_msg.add(false)
                        }
                    }
                    else
                    {
                        let chatprerecord:Chatpreloadrecord=ChatPrerecordArr[ChatActionIndex[i] as! Int] as! Chatpreloadrecord
                        let chatLocked = Themes.sharedInstance.isChatLocked(id: chatprerecord.opponentid, type: chatprerecord.ischattype)
                        if(chatLocked)
                        {
                            delete_msg.add(false)
                            
                        }
                        else
                        {
                            delete_msg.add(true)
                            
                        }
                    }
                }
                
                
                if(ChatActionIndex.count>0){
                    self.archive.isUserInteractionEnabled = true
                    self.archive.setTitleColor(UIColor(red:1/255, green:169/255, blue:229/255, alpha: 1), for:.normal)
                }
                else
                {
                    self.archive.isUserInteractionEnabled = false
                    self.archive.setTitleColor(UIColor.lightGray, for:.normal)
                }
                if(read_msg.contains(true))
                {
                    read_all = false
                    self.read.isUserInteractionEnabled = true
                    self.read.setTitleColor(UIColor(red:1/255, green:169/255, blue:229/255, alpha: 1), for:.normal)
                }
                else
                {
                    read_all = false
                    self.read.isUserInteractionEnabled = false
                    self.read.setTitleColor(UIColor.lightGray, for:.normal)
                }
                if(delete_msg.contains(false) || delete_msg.count == 0)
                {
                    self.delete.isUserInteractionEnabled = false
                    self.delete.setTitleColor(UIColor.lightGray, for:.normal)
                }
                else
                {
                    self.delete.isUserInteractionEnabled = true
                    self.delete.setTitleColor(UIColor(red:1/255, green:169/255, blue:229/255, alpha: 1), for:.normal)
                }
                
                
            }
            
        }else if(searchActive == true && section[indexPath.section] as! String == "Chats"){
            let searchRecord:NSArray = allArray[indexPath.section] as! NSArray
            let record  = searchRecord[indexPath.row]
            if(record is Chatpreloadrecord)
            {
                let chatprerecord:Chatpreloadrecord=searchRecord[indexPath.row] as! Chatpreloadrecord
                let chatLocked = Themes.sharedInstance.isChatLocked(id: chatprerecord.opponentid, type: chatprerecord.ischattype)
                if(chatLocked){
                    self.enterToChat(id: chatprerecord.opponentid,type: "single", indexpath:indexPath)
                }else{
                    let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                    ObjInitiateChatViewController.Chat_type="single"
                    ObjInitiateChatViewController.opponent_id = chatprerecord.opponentid
                    self.searchController.dismissView(animated:true, completion:nil)
                    self.searchController.searchBar.resignFirstResponder()
                    self.searchController.isActive = false
                    self.pushView(ObjInitiateChatViewController, animated: true)
                }
            }
            else
            {
                let chatprerecord:GroupDetail=searchRecord[indexPath.row] as! GroupDetail
                let chatLocked = Themes.sharedInstance.isChatLocked(id: chatprerecord.id, type: "group")
                if(chatLocked == true){
                    self.enterToChat(id: chatprerecord.id, type: "group", indexpath: indexPath)
                }else{
                    let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                    ObjInitiateChatViewController.Chat_type="group"
                    ObjInitiateChatViewController.opponent_id = chatprerecord.id
                    self.searchController.dismissView(animated:true, completion:nil)
                    self.searchController.searchBar.resignFirstResponder()
                    self.searchController.isActive = false
                    self.pushView(ObjInitiateChatViewController, animated: true)
                }
            }
        }else if(searchActive == true && section[indexPath.section] as! String == "Other Chats"){
            let searchRecord:NSArray = allArray[indexPath.section] as! NSArray
            let favRecord:FavRecord=searchRecord[indexPath.row] as! FavRecord
            if(Themes.sharedInstance.isChatLocked(id: favRecord.id, type: "single"))
            {
                Themes.sharedInstance.enterTochat(id: favRecord.id, type: "single") { (success) in
                    if(success)
                    {
                        let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                        ObjInitiateChatViewController.Chat_type="single"
                        ObjInitiateChatViewController.opponent_id = favRecord.id
                        self.searchController.dismissView(animated:true, completion:nil)
                        self.searchController.searchBar.resignFirstResponder()
                        self.searchController.isActive = false
                        self.pushView(ObjInitiateChatViewController, animated: true)
                    }
                }
            }
            else
            {
                let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                ObjInitiateChatViewController.Chat_type="single"
                ObjInitiateChatViewController.opponent_id = favRecord.id
                self.searchController.dismissView(animated:true, completion:nil)
                self.searchController.searchBar.resignFirstResponder()
                self.searchController.isActive = false
                self.pushView(ObjInitiateChatViewController, animated: true)
            }
        }else if(searchActive == true && section[indexPath.section] as! String == "Messages"){

            let info_msg:SearchMessage = filterMessageContact[indexPath.row] as! SearchMessage
            
            if(info_msg.type == "single")
            {
                if(Themes.sharedInstance.isChatLocked(id: info_msg.to_id, type: "single"))
                {
                    Themes.sharedInstance.enterTochat(id: info_msg.to_id, type: "single") { (success) in
                        if(success)
                        {
                            let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                            ObjInitiateChatViewController.from_search_msg = true
                            ObjInitiateChatViewController.from_search_msg_id = info_msg.timestamp!
                            ObjInitiateChatViewController.from_message = (self.filterMessage[indexPath.row] as? String)!
                            ObjInitiateChatViewController.Chat_type="single"
                            ObjInitiateChatViewController.opponent_id = info_msg.to_id
                            self.searchController.dismissView(animated:true, completion:nil)
                            self.searchController.searchBar.resignFirstResponder()
                            self.searchController.isActive = false
                            self.pushView(ObjInitiateChatViewController, animated: true)
                        }
                    }
                }
                else{
                    let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                    ObjInitiateChatViewController.from_search_msg = true
                    ObjInitiateChatViewController.from_search_msg_id = info_msg.timestamp!
                    ObjInitiateChatViewController.from_message = (filterMessage[indexPath.row] as? String)!
                    ObjInitiateChatViewController.Chat_type="single"
                    ObjInitiateChatViewController.opponent_id = info_msg.to_id
                    self.searchController.dismissView(animated:true, completion:nil)
                    self.searchController.searchBar.resignFirstResponder()
                    self.searchController.isActive = false
                    self.pushView(ObjInitiateChatViewController, animated: true)
                }
                
            }
            else
            {
                if(Themes.sharedInstance.isChatLocked(id: info_msg.to_id, type: "group"))
                {
                    Themes.sharedInstance.enterTochat(id: info_msg.to_id, type: "group") { (success) in
                        if(success)
                        {
                            let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                            ObjInitiateChatViewController.from_search_msg = true
                            ObjInitiateChatViewController.from_search_msg_id = info_msg.timestamp!
                            ObjInitiateChatViewController.from_message = (self.filterMessage[indexPath.row] as? String)!
                            ObjInitiateChatViewController.Chat_type="group"
                            ObjInitiateChatViewController.opponent_id = info_msg.to_id
                            self.searchController.dismissView(animated:true, completion:nil)
                            self.searchController.searchBar.resignFirstResponder()
                            self.searchController.isActive = false
                            self.pushView(ObjInitiateChatViewController, animated: true)
                        }
                    }
                }
                else
                {
                    let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                    ObjInitiateChatViewController.from_search_msg = true
                    ObjInitiateChatViewController.from_search_msg_id = info_msg.timestamp!
                    ObjInitiateChatViewController.from_message = (filterMessage[indexPath.row] as? String)!
                    ObjInitiateChatViewController.Chat_type="group"
                    ObjInitiateChatViewController.opponent_id = info_msg.to_id
                    searchController.dismissView(animated:true, completion:nil)
                    self.searchController.searchBar.resignFirstResponder()
                    self.searchController.isActive = false
                    self.pushView(ObjInitiateChatViewController, animated: true)
                }
               
            }
        }
        searchController.searchBar.resignFirstResponder()
        searchController.isActive = false
    }
        
    @IBAction func DidclickNewgroup(_ sender: Any) {
        let predicate = NSPredicate(format: "is_fav != %@", "2")
        let CheckFav = DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Favourite_Contact, SortDescriptor: nil, predicate: predicate, Limit: 0) as! NSArray
        if(CheckFav.count > 0)
        {
            
            let  newGroupVC = storyboard?.instantiateViewController(withIdentifier: "NewGroupViewController") as! NewGroupViewController
            self.searchController.searchBar.resignFirstResponder()
            self.searchController.isActive = false
            self.pushView(newGroupVC, animated: true)
        }
        else
            
        {
            Themes.sharedInstance.jssAlertView(viewController: self, title: Themes.sharedInstance.GetAppname(), text: "No Contact kindly invite friends", buttonTxt: "Ok", color: CustomColor.sharedInstance.alertColor)
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func DidclickNewChat(_ sender: UIButton) {
        
        
        self.searchController.dismissView(animated:true, completion:nil)
        if(ContactHandler.sharedInstance.CheckCheckPermission())
        {
            let favouritesVC:FavouritesViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FavouritesViewController") as! FavouritesViewController
            let navController = UINavigationController(rootViewController: favouritesVC)
            navController.navigationBar.isHidden = true
          
            if #available(iOS 13.0, *) {
                navController.isModalInPresentation = false
            } else {
                // Fallback on earlier versions
            }
            navController.modalPresentationStyle = .fullScreen
            navController.isModalInPopover = false
            favouritesVC.delegate = self
            self.searchController.dismissView(animated:true, completion:nil)
            self.searchController.searchBar.resignFirstResponder()
            self.searchController.isActive = false
            self.presentView(navController, animated: true)
            //self.pushView(navController, animated: true)
            
        }
        else
        {
            self.searchController.dismissView(animated:true, completion:nil)
            self.presentView(Themes.sharedInstance.showContactPermissionAlert, animated: true)
        }
        
    }
    
    
    func deleteMail(_ path:IndexPath) {
    }
    
    func readButtonText(_ read:Bool) -> String
    {
        return read ? "Mark as\nunread" : "Mark as\nread";
    }
    func swipeTableCell(_ cell: MGSwipeTableCell, swipeButtonsFor direction: MGSwipeDirection, swipeSettings: MGSwipeSettings, expansionSettings: MGSwipeExpansionSettings) -> [UIView]?
    {
        if let indexPath = self.chats_Tblview.indexPath(for: cell) {
            swipeSettings.transition = MGSwipeTransition.border;
            expansionSettings.buttonIndex = 0;
            let record = self.ChatPrerecordArr[indexPath.row]
            if(record is Chatpreloadrecord)
            {
                if direction == MGSwipeDirection.leftToRight {
                    expansionSettings.fillOnTrigger = false;
                    expansionSettings.threshold = 2;
                    let color = UIColor.init(red:0.0, green:122/255.0, blue:1.0, alpha:1.0);
                    var titlr:String = String()
                    let chatpreloadRecord:Chatpreloadrecord = self.ChatPrerecordArr[indexPath.row] as! Chatpreloadrecord
                    if(chatpreloadRecord.isUnreadMessages)
                    {
                        titlr = NSLocalizedString("Read", comment:"Readcommernt")
                    }
                    else
                    {
                        titlr = NSLocalizedString("Unread", comment:"Unread" )
                        
                    }
                    let read = MGSwipeButton(title: titlr,icon:titlr == NSLocalizedString("Read", comment:"") ? UIImage(named: "read") : UIImage(named: "unread") , backgroundColor: color, callback: { (cell) -> Bool in
                        guard let indexPath = self.chats_Tblview.indexPath(for: cell) else{return true}
                        let chatpreloadRecord:Chatpreloadrecord = self.ChatPrerecordArr[indexPath.row] as! Chatpreloadrecord
                        cell.hideSwipe(animated: true)
                        let user_common_id = "\(Themes.sharedInstance.Getuser_id())-\(chatpreloadRecord.opponentid)"
                        if(chatpreloadRecord.isUnreadMessages)
                        {
                            chatpreloadRecord.isUnreadMessages  = false
                            chatpreloadRecord.opponentunreadmessagecount = ""
                            self.ClearUnreadMessages(user_common_id: user_common_id,status: "0",indexpath: indexPath,convID:chatpreloadRecord.opponentlastmessageid)
                            (cell.leftButtons[0] as! UIButton).setTitle(NSLocalizedString("Unread", comment:"Unread" ), for: UIControl.State())
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.change_chat_count), object: nil , userInfo: nil)
                            
                        }
                        else
                        {
                            chatpreloadRecord.isUnreadMessages  = true
                            chatpreloadRecord.opponentunreadmessagecount = ""
                            self.ClearUnreadMessages(user_common_id: user_common_id,status: "1",indexpath: indexPath,convID:chatpreloadRecord.opponentlastmessageid)
                            (cell.leftButtons[0] as! UIButton).setTitle(NSLocalizedString("Read", comment:"Read"), for: UIControl.State());
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.change_chat_count), object: nil , userInfo: nil)
                        }
                        return true;
                    })
                    read.centerIconOverText()
                    return [read]
                }
                else {
                    expansionSettings.fillOnTrigger = true;
                    expansionSettings.threshold = 1.1;
                    
                    //let color1 = CustomColor.sharedInstance.themeColor;
                    let color2 = UIColor.lightGray
                    
//                    let trash = `MGSwipeButton`(title:NSLocalizedString("Archive", comment: "Archive") ,icon: UIImage(named: "archive"), backgroundColor: color1, callback: { (cell) -> Bool in
//                        guard let indexPath = self.chats_Tblview.indexPath(for: cell) else{return true}
//                        cell.hideSwipe(animated: true)
//                        cell.refreshContentView()
//                        self.ExecuteArchiveChat(indexpath:indexPath)
//                        return false;
//                    });
//                    trash.centerIconOverText()
                         
                    let more = MGSwipeButton(title: NSLocalizedString("More", comment: "Moreeeee") ,icon: UIImage(named: "more"), backgroundColor: color2, callback: { (cell) -> Bool in
                        guard let indexPath = self.chats_Tblview.indexPath(for: cell) else{return true}
                        self.showMoreActions(indexpath: indexPath, callback: { (cancelled, deleted, index) in
                            let chatpreloadRecord:Chatpreloadrecord = self.ChatPrerecordArr[indexPath.row] as! Chatpreloadrecord
                            if cancelled {
                                return;
                            }
                            else if deleted {
                                Themes.sharedInstance.executeClearChat("0", chatpreloadRecord.opponentid, true)
                            }
                            else if index == 0
                            {
                                self.searchController.dismissView(animated:true, completion:nil)
                                Themes.sharedInstance.Mute_unMutechats(id: chatpreloadRecord.opponentid, type: "single")
                            }
                            else if index == 1 {
                                let singleInfoVC:SingleInfoViewController=self.storyboard?.instantiateViewController(withIdentifier: "SingleInfoViewController") as! SingleInfoViewController
                                let chat_ino:Chatpreloadrecord = self.ChatPrerecordArr[indexPath.row] as! Chatpreloadrecord
                                singleInfoVC.user_id = chat_ino.opponentid
                                self.searchController.searchBar.resignFirstResponder()
                                self.searchController.isActive = false
                                self.pushView(singleInfoVC, animated: true)
                            }
                            else if index == 2 {
                                
                            }
                            else if index == 3 {
                                let chat_info:Chatpreloadrecord = self.ChatPrerecordArr[indexPath.row] as! Chatpreloadrecord
                                let chatLocked = Themes.sharedInstance.isChatLocked(id: chat_info.opponentid, type: chat_info.ischattype)
                                if(chatLocked){
                                    Themes.sharedInstance.LockAction(id: chatpreloadRecord.opponentid, type: "single")
                                }
                                else
                                {
                                    let optionMenu = UIAlertController(title: nil, message: NSLocalizedString("Choose Option", comment:"ds" ) , preferredStyle: .actionSheet)
                                    let deleteStarredAction = UIAlertAction(title: NSLocalizedString("Delete all except starred", comment: "hj") , style: .default, handler: {
                                        (alert: UIAlertAction!) -> Void in
                                        print("File Deleted")
                                        Themes.sharedInstance.executeClearChat("1", chat_info.opponentid, false)
                                    })
                                    let deleteMessageAction = UIAlertAction(title: NSLocalizedString("Delete all messages", comment: "d") , style: .default, handler: {
                                        (alert: UIAlertAction!) -> Void in
                                        print("File Saved")
                                        Themes.sharedInstance.executeClearChat("0", chat_info.opponentid, false)
                                    })
                                    let cancelAction = UIAlertAction(title:NSLocalizedString("Cancel", comment: "Cancel") , style: .cancel, handler: {
                                        (alert: UIAlertAction!) -> Void in
                                        print("Cancelled")
                                    })
                                    optionMenu.addAction(deleteStarredAction)
                                    optionMenu.addAction(deleteMessageAction)
                                    optionMenu.addAction(cancelAction)
                                    self.searchController.dismissView(animated:true, completion:nil)
                                    self.presentView(optionMenu, animated: true, completion: nil)
                                }
                                
                                
                            }
                            else if index == 4
                            {
                                self.ExecuteArchiveChat(indexpath:indexPath)
                            }
                        })
                        cell.hideSwipe(animated: true)
                        cell.refreshContentView()
                        return false;
                        // Don't autohide
                    });
                    more.centerIconOverText()
                    cell.rightSwipeSettings.transition = .border
                    cell.leftSwipeSettings.transition = .border
                    return [more];
                }
            }
            else{
                if direction == MGSwipeDirection.leftToRight {
                    expansionSettings.fillOnTrigger = false;
                    expansionSettings.threshold = 2;
                    let color = UIColor.init(red:0.0, green:122/255.0, blue:1.0, alpha:1.0);
                    let chatpreloadRecord:GroupDetail = self.ChatPrerecordArr[indexPath.row] as! GroupDetail
                    var titlr:String = String()
                    if(chatpreloadRecord.isUnreadMessages)
                    {
                        titlr = NSLocalizedString("Read", comment: "Read")
                    }
                    else
                    {
                        titlr = NSLocalizedString(" Unread", comment: "unRead")
                        
                    }
                    let read = MGSwipeButton(title: titlr,icon: titlr == NSLocalizedString("Read", comment: "Read") ? UIImage(named: "read") : UIImage(named: "unread"), backgroundColor: color, callback: { (cell) -> Bool in
                        guard let indexPath = self.chats_Tblview.indexPath(for: cell) else{return true}
                        let chatpreloadRecord:GroupDetail = self.ChatPrerecordArr[indexPath.row] as! GroupDetail
                        cell.hideSwipe(animated: true)
                        cell.refreshContentView()
                        let user_common_id = "\(Themes.sharedInstance.Getuser_id())-\(chatpreloadRecord.id)"
                        if(chatpreloadRecord.isUnreadMessages)
                        {
                            chatpreloadRecord.isUnreadMessages  = false
                            
                            self.ClearUnreadMessages(user_common_id: user_common_id,status: "0",indexpath: indexPath,convID:chatpreloadRecord.id)
                            (cell.leftButtons[0] as! UIButton).setTitle(" \(titlr)", for: UIControl.State());
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.change_chat_count), object: nil , userInfo: nil)
                            
                        }
                        else
                        {
                            chatpreloadRecord.isUnreadMessages  = true
                            self.ClearUnreadMessages(user_common_id: user_common_id,status: "1",indexpath: indexPath,convID:chatpreloadRecord.id)
                            (cell.leftButtons[0] as! UIButton).setTitle(" \(titlr)", for: UIControl.State());
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.change_chat_count), object: nil , userInfo: nil)
                            
                        }
                        return true;
                    })
                    read.centerIconOverText()
                    return [read]
                }
                else {
                    expansionSettings.fillOnTrigger = true;
                    expansionSettings.threshold = 1.1;
                    let color1 = CustomColor.sharedInstance.themeColor;
                    let color2 = UIColor.lightGray;
                    
//                    let trash = MGSwipeButton(title: "Archive", icon: UIImage(named: "archive"), backgroundColor: color1, callback: { (cell) -> Bool in
//                        guard let indexPath = self.chats_Tblview.indexPath(for: cell) else{return true}
//                        cell.hideSwipe(animated: true)
//                        cell.refreshContentView()
//                        self.ExecuteArchiveChat(indexpath:indexPath)
//                        return false;
//                    });
//                    trash.centerIconOverText()
                    
                    let more = MGSwipeButton(title: "More", icon: UIImage(named: "more"), backgroundColor: color2, callback: { (cell) -> Bool in
                        guard let indexPath = self.chats_Tblview.indexPath(for: cell) else{return true}
                        let chatpreloadRecord:GroupDetail = self.ChatPrerecordArr[indexPath.row] as! GroupDetail
                        self.showMoreActions(indexpath: indexPath, callback: { (cancelled, deleted, index) in
                                if cancelled {
                                    return;
                                }
                                else if deleted {
                                }
                                else if index == 0 {
                                    
                                    self.searchController.dismissView(animated:true, completion:nil)
                                    Themes.sharedInstance.Mute_unMutechats(id: chatpreloadRecord.id, type: "group")
                                    
                                }
                                else if index == 1 {
                                    let chat_ino:GroupDetail = self.ChatPrerecordArr[indexPath.row] as! GroupDetail
                                    
                                    let GroupInfoVC:GroupInfoViewController=self.storyboard?.instantiateViewController(withIdentifier: "GroupInfoVCID") as! GroupInfoViewController
                                    GroupInfoVC.common_id="\(Themes.sharedInstance.Getuser_id())-\(chat_ino.id)"
                                    self.searchController.searchBar.resignFirstResponder()
                                    self.searchController.isActive = false
                                    self.pushView(GroupInfoVC, animated: true)
                                }
                                else if index == 2 {
                                    
                                }
                                else if index == 3 {
                                    let chatLocked = Themes.sharedInstance.isChatLocked(id: chatpreloadRecord.id, type: "group")
                                    if(chatLocked == true){
                                        Themes.sharedInstance.LockAction(id: chatpreloadRecord.id, type: "group")
                                    }
                                    else{
                                        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
                                        let chat_info:GroupDetail = self.ChatPrerecordArr[indexPath.row] as! GroupDetail
                                        let deleteStarredAction = UIAlertAction(title: "Delete all except starred", style: .default, handler: {
                                            (alert: UIAlertAction!) -> Void in
                                            print("File Deleted")
                                            Themes.sharedInstance.executeClearChat("1", chat_info.id, false)
                                        })
                                        let deleteMessageAction = UIAlertAction(title: "Delete all messages", style: .default, handler: {
                                            (alert: UIAlertAction!) -> Void in
                                            print("File Saved")
                                            Themes.sharedInstance.executeClearChat("0", chat_info.id, false)
                                        })
                                        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                                            (alert: UIAlertAction!) -> Void in
                                            print("Cancelled")
                                        })
                                        optionMenu.addAction(deleteStarredAction)
                                        optionMenu.addAction(deleteMessageAction)
                                        optionMenu.addAction(cancelAction)
                                        self.searchController.dismissView(animated:true, completion:nil)
                                        self.presentView(optionMenu, animated: true, completion: nil)
                                    }
                                    
                                }
                                else if index == 4
                                {
                                    let chatLocked = Themes.sharedInstance.isChatLocked(id: chatpreloadRecord.id, type: "group")
                                    if(chatLocked == true){
                                        
                                        Themes.sharedInstance.LockAction(id: chatpreloadRecord.id, type: "group")
                                        
                                    }
                                    else{
                                        let chat_ino:GroupDetail = self.ChatPrerecordArr[indexPath.row] as! GroupDetail
                                        
                                        let from : String = Themes.sharedInstance.Getuser_id()
                                        let to : String = chat_ino.id
                                        var timestamp:String = String(Date().ticks)
                                        var servertimeStr:String = Themes.sharedInstance.getServerTime()
                                        
                                        if(servertimeStr == "")
                                        {
                                            servertimeStr = "0"
                                        }
                                        let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
                                        timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
                                        
                                        let toDocId : String = "\(from)-\(to)-\(timestamp)"
                                        let param = ["from" : Themes.sharedInstance.Getuser_id(),"groupType" : "8","groupId" : Themes.sharedInstance.CheckNullvalue(Passed_value:chat_ino.id), "id" : timestamp, "toDocId" : toDocId] as [String : Any];
                                        Themes.sharedInstance.activityView(View: self.view)
                                        SocketIOManager.sharedInstance.Groupevent(param: param)
                                        let param_removeuser = ["_id":Themes.sharedInstance.CheckNullvalue(Passed_value:chat_ino.id)]
                                        SocketIOManager.sharedInstance.Removeuser(param: param_removeuser)
                                        let updatedict = ["is_deleted":"1"]
                                        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Group_details, FetchString: chat_ino.id, attribute: "id", UpdationElements: updatedict as NSDictionary?)
                                        //                        self.ExecuteArchiveChat(indexpath:self.callTableView.indexPath(for: cell)!)
                                    }
                                    
                                }
                                    
                                else if index == 5
                                {
                                    let chatLocked = Themes.sharedInstance.isChatLocked(id: chatpreloadRecord.id, type: "group")
                                    if(chatLocked == true){
                                        Themes.sharedInstance.LockAction(id: chatpreloadRecord.id, type: "group")
                                    }
                                    else{
                                        
                                        let chat_ino:GroupDetail = self.ChatPrerecordArr[indexPath.row] as! GroupDetail
                                        Themes.sharedInstance.executeClearChat("0", chat_ino.id, true)
                                    }
                                    
                                }
                                else if index == 6
                                {
                                    let chatLocked = Themes.sharedInstance.isChatLocked(id: chatpreloadRecord.id, type: "group")
                                    if(chatLocked == true){
                                        Themes.sharedInstance.LockAction(id: chatpreloadRecord.id, type: "group")
                                    }else{
                                        
                                        let chat_ino:GroupDetail = self.ChatPrerecordArr[indexPath.row] as! GroupDetail
                                        let from : String = Themes.sharedInstance.Getuser_id()
                                        let to : String = Themes.sharedInstance.CheckNullvalue(Passed_value: chat_ino.id)
                                        var timestamp:String =  String(Date().ticks)
                                        var servertimeStr:String = Themes.sharedInstance.getServerTime()
                                        
                                        if(servertimeStr == "")
                                        {
                                            servertimeStr = "0"
                                        }
                                        let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
                                        timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
                                        let toDocId : String = "\(from)-\(to)-\(timestamp)"
                                        let param = ["from" : Themes.sharedInstance.Getuser_id(),"groupType" : "8","groupId" : Themes.sharedInstance.CheckNullvalue(Passed_value:chat_ino.id), "id" : timestamp, "toDocId" : toDocId] as [String : Any];
                                        Themes.sharedInstance.activityView(View: self.view)
                                        SocketIOManager.sharedInstance.Groupevent(param: param)
                                        let param_removeuser = ["_id":Themes.sharedInstance.CheckNullvalue(Passed_value:chat_ino.id)]
                                        SocketIOManager.sharedInstance.Removeuser(param: param_removeuser)
                                    }
                                    
                                }
                        })
                        cell.hideSwipe(animated: true)
                        cell.refreshContentView()
                        return false;
                        // Don't autohide
                    });
                    more.centerIconOverText()
                    cell.rightSwipeSettings.transition = .border
                    cell.leftSwipeSettings.transition = .border
                    return [more];
                }
            }
        }
        return [UIView()]
    }
    
    func DeleteGroup(opponentID:String,index:IndexPath, fromEdit : Bool)
    {
        let CheckOtherMessages:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Group_details, attribute: "id", FetchString: opponentID)
        if(CheckOtherMessages)
        {
            let predic1 = NSPredicate(format: "id = %@",opponentID)
            DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Group_details, Predicatefromat: predic1, Deletestring: opponentID, AttributeName: "id")
        }
        
        let CheckinitiatedDetails:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: "\(Themes.sharedInstance.Getuser_id())-\(opponentID)")
        if(CheckinitiatedDetails)
        {
            let predic1 = NSPredicate(format: "user_common_id = %@","\(Themes.sharedInstance.Getuser_id())-\(opponentID)")
            
            DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Chat_intiated_details, Predicatefromat: predic1, Deletestring: opponentID, AttributeName: "id")
        }
        if(!fromEdit)
        {
            ChatPrerecordArr.removeObject(at: index.row)
            chats_Tblview.deleteRows(at: [index], with: .fade)
            ReloadTable()
        }
    }
    
    func ClearUnreadMessages(user_common_id:String,status:String,indexpath:IndexPath,convID:String)
    {
        let record = ChatPrerecordArr[indexpath.row]
        if(record is Chatpreloadrecord)
        {
            let param:NSDictionary = ["is_read":"\(status)","chat_count":"0"]
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: user_common_id, attribute: "user_common_id", UpdationElements: param)
            chats_Tblview.reloadRows(at: [indexpath], with: .none)
            let Emitparam:NSDictionary = ["from":Themes.sharedInstance.Getuser_id(),"convId":convID,"status":"\(status)","type":"single"]
            SocketIOManager.sharedInstance.EmitmarkedDetails(Dict: Emitparam)
            
            if(status == "0")
            {
                self.readAllMessages(User_chat_id: user_common_id)
            }
            
        }
        else
        {
            let param:NSDictionary = ["is_read":"\(status)","chat_count":"0"]
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: user_common_id, attribute: "user_common_id", UpdationElements: param)
            let GroupDetailRec:GroupDetail = ChatPrerecordArr[indexpath.row] as! GroupDetail
            
            if(status == "1")
            {
                GroupDetailRec.isUnreadMessages = true
                
            }
            else
            {
                GroupDetailRec.isUnreadMessages = false
            }
            GroupDetailRec.Group_Message_Count = ""
            chats_Tblview.reloadRows(at: [indexpath], with: .none)
            let Emitparam:NSDictionary = ["from":Themes.sharedInstance.Getuser_id(),"convId":convID,"status":"\(status)","type":"group"]
            SocketIOManager.sharedInstance.EmitmarkedDetails(Dict: Emitparam)
            if(status == "0")
            {
                self.readAllMessages(User_chat_id: user_common_id)
            }
            else
            {
                
            }
        }
        self.ReloadTable()
    }
    
    func readAllMessages(User_chat_id:String)
    {
        let Predicate1:NSPredicate = NSPredicate(format: "message_status == 1")
        let Predicate2:NSPredicate = NSPredicate(format: "message_status == 2")
        let CompounPredicate1:NSCompoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [Predicate1,Predicate2])
        let Predicate3:NSPredicate = NSPredicate(format: "user_common_id == %@",User_chat_id)
        let CompounPredicate2:NSCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [CompounPredicate1,Predicate3])
        
        let ChatArr:NSArray =  DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Chat_one_one, SortDescriptor: "timestamp", predicate: CompounPredicate2, Limit: 0) as! NSArray
        
        if(ChatArr.count > 0)
        {
            for i in 0 ..< ChatArr.count {
                let ResponseDict = ChatArr[i] as! NSManagedObject
                
                let chat_type:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "chat_type"));
                if(chat_type == "single")
                {
                    let convId:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "convId"))
                    let Doc_id:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id"));
                    let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "from"));
                    let to:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "to"));
                    let message_status:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "message_status"));
                    let msgID:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "msgId"));
                    print("the msg status is \(message_status)")
                    var toID:String=String()
                    if(from != Themes.sharedInstance.Getuser_id())
                    {
                        toID=from
                    }
                    else
                        
                    {
                        toID=to
                    }
                    if(from != Themes.sharedInstance.Getuser_id())
                    {
                        if(message_status == "0" || message_status == "1" || message_status == "2")
                        {
                            SocketIOManager.sharedInstance.AcknowledegmentHandler(from: Themes.sharedInstance.Getuser_id() as NSString, to: toID as NSString, status: "3", doc_id: Doc_id as NSString, timestamp: msgID as NSString,isEmit_status: false, is_deleted_message_ack: false, chat_type: "single", convId: convId)
                        }
                    }
                }
                else if(chat_type == "group")
                {
                    let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "from"));
                    
                    //                let to:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "to"));
                    
                    let message_status:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "message_status"));
                    let msgID:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "msgId"));
                    print("the msg status is \(message_status)")
                    let convId:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "convId"));
                    
                    if(from != Themes.sharedInstance.Getuser_id())
                    {
                        let param_ack=["groupType": "12", "from": Themes.sharedInstance.Getuser_id(), "groupId": convId, "status":"3", "msgId": msgID]
                        SocketIOManager.sharedInstance.GroupmessageAcknowledgement(Param: param_ack)
                    }
                }
                
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath)
    {
        print("index",indexPath.row)
        if(ChatActionIndex.contains(indexPath.row))
        {
            ChatActionIndex.remove(indexPath.row)
        }
        read_msg = NSMutableArray()
        delete_msg = NSMutableArray()
        
        for i in 0..<ChatActionIndex.count{
            let record = ChatPrerecordArr[ChatActionIndex[i] as! Int]
            if(record is Chatpreloadrecord)
            {
                let chatprerecord:Chatpreloadrecord=ChatPrerecordArr[ChatActionIndex[i] as! Int] as! Chatpreloadrecord
                
                if(chatprerecord.isUnreadMessages){
                    read_msg.add(true)
                }else{
                    read_msg.add(false)
                }
            }
            else
            {
                let chatprerecord:GroupDetail=ChatPrerecordArr[ChatActionIndex[i] as! Int] as! GroupDetail
                if(chatprerecord.isUnreadMessages){
                    read_msg.add(true)
                }else{
                    read_msg.add(false)
                }
            }
            
        }
        
        for i in 0..<ChatActionIndex.count{
            let record = ChatPrerecordArr[ChatActionIndex[i] as! Int]
            if(record is GroupDetail)
            {
                let chatprerecord:GroupDetail=ChatPrerecordArr[ChatActionIndex[i] as! Int] as! GroupDetail
                if(chatprerecord.is_you_left){
                    delete_msg.add(true)
                }else{
                    delete_msg.add(false)
                }
            }
            else
            {
                delete_msg.add(true)
            }
        }
        
        
        if(ChatActionIndex.count>0){
            self.archive.isUserInteractionEnabled = true
            self.archive.setTitleColor(UIColor(red:1/255, green:169/255, blue:229/255, alpha: 1), for:.normal)
        }
        else
        {
            self.archive.isUserInteractionEnabled = false
            self.archive.setTitleColor(UIColor.lightGray, for:.normal)
        }
        if(read_msg.contains(true))
        {
            read_all = false
            self.read.isUserInteractionEnabled = true
            self.read.setTitleColor(UIColor(red:1/255, green:169/255, blue:229/255, alpha: 1), for:.normal)
        }
        else
        {
            read_all = false
            self.read.isUserInteractionEnabled = false
            self.read.setTitleColor(UIColor.lightGray, for:.normal)
        }
        if(delete_msg.contains(false) || delete_msg.count == 0)
        {
            self.delete.isUserInteractionEnabled = false
            self.delete.setTitleColor(UIColor.lightGray, for:.normal)
        }
        else
        {
            self.delete.isUserInteractionEnabled = true
            self.delete.setTitleColor(UIColor(red:1/255, green:169/255, blue:229/255, alpha: 1), for:.normal)
        }
    }
    
    @IBAction func DidclickEdit(_ sender: Any) {
        if(isBeginEditing)
        {
            
            chats_Tblview.setEditing(false, animated: true)
            isBeginEditing = false
            editBtn.setTitle(NSLocalizedString("Edit", comment: "Edit"), for: .normal)
            self.tapBar.isHidden = true
            ChatActionIndex = []
            read_all = false
            self.read.setTitle("Read", for:.normal)
            self.archive.setTitle("Archive", for:.normal)
            self.delete.setTitle("Delete", for:.normal)
            self.read.setTitleColor(UIColor.lightGray, for: .normal)
            self.archive.setTitleColor(UIColor.lightGray, for: .normal)
            self.delete.setTitleColor(UIColor.lightGray, for: .normal)
            self.archive.isUserInteractionEnabled = false
            self.delete.isUserInteractionEnabled = false
            self.read.isUserInteractionEnabled = false
            UIView.animate(withDuration: 1, animations: {
                self.bottom_chatTable.constant = 0
            })
            
        }
        else
        {
            chats_Tblview.setEditing(true, animated: true)
            isBeginEditing = true
            editBtn.setTitle("Done", for: .normal)
            UIView.animate(withDuration: 1, animations: {
                self.tapBar.isHidden = false
                self.bottom_chatTable.constant += self.tapBar.frame.size.height/2
                self.bottom_chatTable.constant += self.tapBar.frame.size.height/2
            })
        }
    }
    func attach_media(indexpath: IndexPath){
        let record = ChatPrerecordArr[indexpath.row]
        if(record is Chatpreloadrecord)
        {
            let chatprerecord:Chatpreloadrecord=ChatPrerecordArr[indexpath.row] as! Chatpreloadrecord
            let picture_path:NSMutableArray = NSMutableArray()
            let contact_path:NSMutableArray = NSMutableArray()
            var save_msg:String = String()
            let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
            let to:String=chatprerecord.opponentid
            let User_chat_id=from + "-" + to
            var to_name:String = String()
            let check_user = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "id", FetchString: to)
            if(check_user){
                let favArray:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "id", FetchString: to, SortDescriptor: nil) as! NSArray
                if(favArray.count > 0){
                    for i in 0..<favArray.count{
                        let ResponseDict = favArray[i] as! NSManagedObject
                        let name:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "name"))
                        to_name = name
                    }
                }
            }
            var ChatArr:NSArray=DatabaseHandler.sharedInstance.FetchFromDatabaseWithLimit(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "user_common_id", Predicatefromat: "==", FetchString: User_chat_id, Limit: 0, SortDescriptor: "timestamp") as NSArray
            if(ChatArr.count > 0)
            {
                let descriptor: NSSortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
                ChatArr = ChatArr.sortedArray(using: [descriptor]) as NSArray
            }
            for i in 0 ..< ChatArr.count {
                let ResponseDict = ChatArr[i] as! NSManagedObject
                let message:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "payload"))
                let timestamp:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "timestamp"))
                let type:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "type"))
                let message_from:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "message_from"))
                let thumbnail:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "thumbnail"))
                let doc_id:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id"))
                var temp_msg:String = String()
                var attachment_name:String = ""
                
                let path_array:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: "\(Constant.sharedinstance.Upload_Details)", attribute: "upload_data_id", FetchString: thumbnail, SortDescriptor: nil) as! NSArray
                if(path_array.count > 0){
                    for i in 0..<path_array.count{
                        let ResponseDict = path_array[i] as! NSManagedObject
                        let upload_path = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "upload_Path"))
                        if(upload_path != "") {
                            let splittedStringsArray = upload_path.split(separator: "/", maxSplits: 1, omittingEmptySubsequences: true).map(String.init)
                            let first_split = splittedStringsArray[1].split(separator: "-", maxSplits: 1, omittingEmptySubsequences: true).map(String.init)
                            let second_split = first_split[1].split(separator: "-", maxSplits: 1, omittingEmptySubsequences: true).map(String.init)
                            attachment_name = second_split[1]
                            picture_path.add(upload_path)
                        }
                    }
                }
                if(type == "5"){
                    let contact_details:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Contact_details, attribute: "doc_id", FetchString: doc_id, SortDescriptor: nil) as! NSArray
                    if(contact_details.count > 0){
                        for i in 0..<contact_details.count{
                            let ResponseDict = contact_details[i] as! NSManagedObject
                            let contact_details:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "contact_details"))
                            let contact_name:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "contact_name"))
                            var phone_num:[CNLabeledValue<CNPhoneNumber>] = []
                            
                            var email:[CNLabeledValue<NSString>] = []
                            var address:[CNLabeledValue<CNPostalAddress>] = []
                            
                            let contact = CNMutableContact()
                            contact.givenName = contact_name
                            attachment_name = contact_name
                            let data = contact_details.data(using:.utf8)
                            
                            do {
                                
                                var jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSArray
                                let contact_address = CNMutablePostalAddress()
                                // Parse JSON data
                                if(jsonResult == nil)
                                {
                                    jsonResult = []
                                }
                                for jsonL in jsonResult! {
                                    
                                    let value_p:NSDictionary = jsonL as! NSDictionary
                                    let type = value_p.value(forKey:"type") as! String
                                    let value_ph = value_p.value(forKey:"value") as! String
                                    
                                    let label = value_p.value(forKey:"label") as! String
                                    if(type == "phone_number"){
                                        let values = CNLabeledValue(label:label , value:CNPhoneNumber(stringValue:value_ph))
                                        phone_num.append(values)
                                    }else if(type == "email"){
                                        let values = CNLabeledValue(label:label , value:value_ph as NSString)
                                        email.append(values)
                                    }else if(type == "street"){
                                        contact_address.street = value_ph
                                    }else if(type == "city"){
                                        contact_address.city = value_ph
                                    }else if(type == "state"){
                                        contact_address.state = value_ph
                                    }else if(type == "postalCode"){
                                        contact_address.postalCode = value_ph
                                    }else if(type == "country"){
                                        contact_address.country = value_ph
                                    }
                                }
                                
                                let values = CNLabeledValue<CNPostalAddress>(label:"home" , value:contact_address)
                                address.append(values)
                                
                                
                                
                            } catch {
                                
                            }
                            
                            if(phone_num.count > 0){
                                
                                contact.phoneNumbers = phone_num
                                contact.emailAddresses = email
                                contact.postalAddresses = address
                                
                            }
                            contact_path.add(contact)
                        }
                    }
                }
                if(message_from == "1"){
                    let name = Themes.sharedInstance.setNameTxt(Themes.sharedInstance.Getuser_id(), "")
                    if(type == "1"){
                        temp_msg = "\(Themes.sharedInstance.ReturnDateTimeSeconds(timestamp: timestamp)) : \(name) : \(message) \(attachment_name)<attached> \n"
                    }else if(type == "2"){
                        temp_msg = "\(Themes.sharedInstance.ReturnDateTimeSeconds(timestamp: timestamp)) : \(name) : \(message) \(attachment_name)<attached> \n"
                    }else if(type == "6" || type == "20"){
                        temp_msg = "\(Themes.sharedInstance.ReturnDateTimeSeconds(timestamp: timestamp)) : \(name) : \(message) \(attachment_name)<attached> \n"
                    }else if(type == "3"){
                        temp_msg = "\(Themes.sharedInstance.ReturnDateTimeSeconds(timestamp: timestamp)) : \(name) : \(message) \(attachment_name)<attached> \n"
                    }else if(type == "5"){
                        temp_msg = "\(Themes.sharedInstance.ReturnDateTimeSeconds(timestamp: timestamp)) : \(name) : \(message) \(attachment_name).vcf<attached> \n"
                    }else{
                        temp_msg = "\(Themes.sharedInstance.ReturnDateTimeSeconds(timestamp: timestamp)) : \(name) : \(message) \n"
                    }
                }else{
                    if(type == "1"){
                        temp_msg = "\(Themes.sharedInstance.ReturnDateTimeSeconds(timestamp: timestamp)) : \(to_name) : \(message) \(attachment_name)<attached> \n"
                    }else if(type == "2"){
                        temp_msg = "\(Themes.sharedInstance.ReturnDateTimeSeconds(timestamp: timestamp)) : \(to_name) : \(message) \(attachment_name)<attached> \n"
                    }else if(type == "6" || type == "20"){
                        temp_msg = "\(Themes.sharedInstance.ReturnDateTimeSeconds(timestamp: timestamp)) : \(to_name) : \(message) \(attachment_name)<attached> \n"
                    }else if(type == "3"){
                        temp_msg = "\(Themes.sharedInstance.ReturnDateTimeSeconds(timestamp: timestamp)) : \(to_name) : \(message) \(attachment_name)<attached> \n"
                    }else if(type == "5"){
                        temp_msg = "\(Themes.sharedInstance.ReturnDateTimeSeconds(timestamp: timestamp)) : \(to_name) : \(message) \(attachment_name).vcf<attached> \n"
                    }else{
                        temp_msg = "\(Themes.sharedInstance.ReturnDateTimeSeconds(timestamp: timestamp)) : \(to_name) : \(message) \n"
                    }
                }
                
                save_msg = save_msg + temp_msg
            }
            
            Filemanager.sharedinstance.zipMediaFiles(file: save_msg, pics: picture_path, contacts: contact_path)
            Themes.sharedInstance.activityView(View: self.chats_Tblview)
            let dir = CommondocumentDirectory()
            let fileURL = dir.appendingPathComponent("chats")
            SSZipArchive.createZipFile(atPath: dir.path.appending("/chats.zip"), withContentsOfDirectory: fileURL.path, keepParentDirectory: false, withPassword: nil, andProgressHandler: { (entryNumber, total) in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                    if(entryNumber == total){
                        Themes.sharedInstance.RemoveactivityView(View: self.view)
                    }
                })
            })
            self.share()
        }
        else
        {
            let chatprerecord:GroupDetail=ChatPrerecordArr[indexpath.row] as! GroupDetail
            let picture_path:NSMutableArray = NSMutableArray()
            let contact_path:NSMutableArray = NSMutableArray()
            var save_msg:String = String()
            let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
            let to:String=chatprerecord.id
            let User_chat_id=from + "-" + to
            var to_name:String = String()
            var place:String = ""
            var ChatArr:NSArray=DatabaseHandler.sharedInstance.FetchFromDatabaseWithLimit(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "user_common_id", Predicatefromat: "==", FetchString: User_chat_id, Limit: 0, SortDescriptor: "timestamp") as NSArray
            if(ChatArr.count > 0)
            {
                let descriptor: NSSortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
                ChatArr = ChatArr.sortedArray(using: [descriptor]) as NSArray
            }
            for i in 0 ..< ChatArr.count {
                let ResponseDict = ChatArr[i] as! NSManagedObject
                var message:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "payload"))
                let timestamp:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "timestamp"))
                let type:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "type"))
                let message_id:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "msgId"))
                let thumbnail:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "thumbnail"))
                let doc_id:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id"))
                let from:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "from"))
                var temp_msg:String = String()
                var attachment_name:String = ""
                let checkOtherMessages:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Other_Group_message, attribute: "id", FetchString: message_id)
                if(checkOtherMessages){
                    let MessageInfoArr:NSArray=DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Other_Group_message, attribute: "id", FetchString: message_id, SortDescriptor: nil) as! NSArray
                    
                    if(MessageInfoArr.count > 0)
                    {
                        for i in 0..<MessageInfoArr.count
                        {
                            let messageDict=MessageInfoArr[i] as! NSManagedObject
                            let GrounInfo=Themes.sharedInstance.CheckNullvalue(Passed_value: messageDict.value(forKey: "group_type"))
                            let CreatedUserID = Themes.sharedInstance.CheckNullvalue(Passed_value: messageDict.value(forKey: "from"))
                            
                            message = Themes.sharedInstance.returnOtherMessages(CreatedUserID, Themes.sharedInstance.CheckNullvalue(Passed_value: messageDict.value(forKey: "person_id")), GrounInfo)

                        }
                    }
                    
                }
                let GroupDetailArr =  DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Group_details, attribute: "user_common_id", FetchString: User_chat_id, SortDescriptor: "timestamp") as! NSArray
                if(GroupDetailArr.count > 0)
                {
                    for j in 0..<GroupDetailArr.count
                    {
                        let ReponseDict:NSManagedObject = GroupDetailArr[j] as! NSManagedObject
                        let groupData:NSData?=ReponseDict.value(forKey: "groupUsers") as? NSData
                        
                        if(groupData != nil)
                        {
                            chatprerecord.groupUsers=NSKeyedUnarchiver.unarchiveObject(with: groupData! as Data) as! NSArray
                        }
                    }
                }
                
                let groupNameArr:NSMutableArray=NSMutableArray()
                let groupIdArr:NSMutableArray = NSMutableArray()
                if(chatprerecord.groupUsers.count > 0)
                {
                    for j in 0..<chatprerecord.groupUsers.count
                    {
                        let Dict:NSDictionary=chatprerecord.groupUsers[j] as! NSDictionary
                        let Grouppeoplerecord:Group_people_record=Group_people_record()
                        Grouppeoplerecord.id=Themes.sharedInstance.CheckNullvalue(Passed_value: Dict.object(forKey: "id") as! String) as NSString
                        Grouppeoplerecord.Name = Themes.sharedInstance.setNameTxt(Grouppeoplerecord.id as String, "single") as NSString
                        groupNameArr.add("\(Grouppeoplerecord.Name)")

                        groupIdArr.add("\(Grouppeoplerecord.id)")
                        
                    }
                }
                let index = groupIdArr.index(of: from)
                to_name = groupNameArr[index] as! String
                let path_array:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: "\(Constant.sharedinstance.Upload_Details)", attribute: "upload_data_id", FetchString: thumbnail, SortDescriptor: nil) as! NSArray
                if(path_array.count > 0){
                    for i in 0..<path_array.count{
                        let ResponseDict = path_array[i] as! NSManagedObject
                        let upload_path = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "upload_Path"))
                        if(upload_path != "") {
                            let splittedStringsArray = upload_path.split(separator: "/", maxSplits: 1, omittingEmptySubsequences: true).map(String.init)
                            let first_split = splittedStringsArray[1].split(separator: "-", maxSplits: 1, omittingEmptySubsequences: true).map(String.init)
                            let second_split = first_split[1].split(separator: "-", maxSplits: 1, omittingEmptySubsequences: true).map(String.init)
                            attachment_name = second_split[1]
                            picture_path.add(upload_path)
                        }
                    }
                }
                if(type == "14"){
                    let ChekLocation:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Location_details, attribute: "doc_id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id")))
                    if(ChekLocation)
                    {
                        let LocationArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Location_details, attribute: "doc_id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id")), SortDescriptor: nil) as! NSArray
                        for i in 0..<LocationArr.count
                        {
                            let ObjRecord:NSManagedObject = LocationArr[i] as! NSManagedObject
                            let title_place = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "title"))
                            let Stitle_place = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "stitle"))
                            place = "\(title_place), \(Stitle_place)"
                        }
                    }
                }
                if(type == "5"){
                    let contact_details:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Contact_details, attribute: "doc_id", FetchString: doc_id, SortDescriptor: nil) as! NSArray
                    if(contact_details.count > 0){
                        for i in 0..<contact_details.count{
                            let ResponseDict = contact_details[i] as! NSManagedObject
                            let contact_details:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "contact_details"))
                            let contact_name:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "contact_name"))
                            var phone_num:[CNLabeledValue<CNPhoneNumber>] = []
                            
                            var email:[CNLabeledValue<NSString>] = []
                            var address:[CNLabeledValue<CNPostalAddress>] = []
                            
                            let contact = CNMutableContact()
                            contact.givenName = contact_name
                            attachment_name = contact_name
                            let data = contact_details.data(using:.utf8)
                            
                            do {
                                
                                var jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSArray
                                let contact_address = CNMutablePostalAddress()
                                // Parse JSON data
                                if(jsonResult == nil)
                                {
                                    jsonResult = []
                                }
                                for jsonL in jsonResult! {
                                    
                                    let value_p:NSDictionary = jsonL as! NSDictionary
                                    let type = value_p.value(forKey:"type") as! String
                                    let value_ph = value_p.value(forKey:"value") as! String
                                    
                                    let label = value_p.value(forKey:"label") as! String
                                    if(type == "phone_number"){
                                        let values = CNLabeledValue(label:label , value:CNPhoneNumber(stringValue:value_ph))
                                        phone_num.append(values)
                                    }else if(type == "email"){
                                        let values = CNLabeledValue(label:label , value:value_ph as NSString)
                                        email.append(values)
                                    }else if(type == "street"){
                                        contact_address.street = value_ph
                                    }else if(type == "city"){
                                        contact_address.city = value_ph
                                    }else if(type == "state"){
                                        contact_address.state = value_ph
                                    }else if(type == "postalCode"){
                                        contact_address.postalCode = value_ph
                                    }else if(type == "country"){
                                        contact_address.country = value_ph
                                    }
                                }
                                
                                let values = CNLabeledValue<CNPostalAddress>(label:"home" , value:contact_address)
                                address.append(values)
                                
                                
                                
                            } catch {
                                
                            }
                            
                            if(phone_num.count > 0){
                                
                                contact.phoneNumbers = phone_num
                                contact.emailAddresses = email
                                contact.postalAddresses = address
                                
                            }
                            contact_path.add(contact)
                        }
                    }
                }
                
                if(type == "1"){
                    temp_msg = "\(Themes.sharedInstance.ReturnDateTimeSeconds(timestamp: timestamp)) : \(to_name) : \(message) \(attachment_name)<attached> \n"
                }else if(type == "2"){
                    temp_msg = "\(Themes.sharedInstance.ReturnDateTimeSeconds(timestamp: timestamp)) : \(to_name) : \(message) \(attachment_name)<attached> \n"
                }else if(type == "6" || type == "20"){
                    temp_msg = "\(Themes.sharedInstance.ReturnDateTimeSeconds(timestamp: timestamp)) : \(to_name) : \(message) \(attachment_name)<attached> \n"
                }else if(type == "3"){
                    temp_msg = "\(Themes.sharedInstance.ReturnDateTimeSeconds(timestamp: timestamp)) : \(to_name) : \(message) \(attachment_name)<attached> \n"
                }else if(type == "5"){
                    temp_msg = "\(Themes.sharedInstance.ReturnDateTimeSeconds(timestamp: timestamp)) : \(to_name) : \(message) \(attachment_name).vcf<attached> \n"
                }else if(type == "14"){
                    temp_msg = "\(Themes.sharedInstance.ReturnDateTimeSeconds(timestamp: timestamp)) : \(to_name) : \(place) \n"
                }
                else{
                    temp_msg = "\(Themes.sharedInstance.ReturnDateTimeSeconds(timestamp: timestamp)) : \(to_name) : \(message) \n"
                }
                
                save_msg = save_msg + temp_msg
            }
            
            Filemanager.sharedinstance.zipMediaFiles(file: save_msg, pics: picture_path, contacts: contact_path)
            Themes.sharedInstance.activityView(View: self.chats_Tblview)
            let dir = CommondocumentDirectory()
            let fileURL = dir.appendingPathComponent("chats")
            SSZipArchive.createZipFile(atPath: dir.path.appending("/chats.zip"), withContentsOfDirectory: fileURL.path, keepParentDirectory: false, withPassword: nil, andProgressHandler: { (entryNumber, total) in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                    if(entryNumber == total){
                        Themes.sharedInstance.RemoveactivityView(View: self.view)
                    }
                })
            })
            self.share()
        }
        
    }
    
    func attach_without_media(indexpath: IndexPath){
        let record = ChatPrerecordArr[indexpath.row]
        if(record is Chatpreloadrecord)
        {
            let chatprerecord:Chatpreloadrecord=ChatPrerecordArr[indexpath.row] as! Chatpreloadrecord
            var save_msg:String = String()
            let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
            let to:String=chatprerecord.opponentid
            let User_chat_id=from + "-" + to
            var to_name:String = String()
            let check_user = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "id", FetchString: to)
            if(check_user){
                let favArray:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "id", FetchString: to, SortDescriptor: nil) as! NSArray
                if(favArray.count > 0){
                    for i in 0..<favArray.count{
                        let ResponseDict = favArray[i] as! NSManagedObject
                        let name:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "name"))
                        to_name = name
                    }
                }
            }
            var ChatArr:NSArray=DatabaseHandler.sharedInstance.FetchFromDatabaseWithLimit(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "user_common_id", Predicatefromat: "==", FetchString: User_chat_id, Limit: 0, SortDescriptor: "timestamp") as NSArray
            if(ChatArr.count > 0)
            {
                let descriptor: NSSortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
                ChatArr = ChatArr.sortedArray(using: [descriptor]) as NSArray
            }
            for i in 0 ..< ChatArr.count {
                let ResponseDict = ChatArr[i] as! NSManagedObject
                let message:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "payload"))
                let timestamp:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "timestamp"))
                let type:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "type"))
                let message_from:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "message_from"))
                //let message_status:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "message_status"))
                var temp_msg:String = String()
                
                
                if(type == "0"){
                    let name = Themes.sharedInstance.setNameTxt(Themes.sharedInstance.Getuser_id(), "")
                    if(message_from == "1"){
                        temp_msg = "\(Themes.sharedInstance.ReturnDateTimeSeconds(timestamp: timestamp)) : \(name) : \(message) \n"
                    }else{
                        temp_msg = "\(Themes.sharedInstance.ReturnDateTimeSeconds(timestamp: timestamp)) : \(to_name) : \(message) \n"
                    }
                    save_msg =  save_msg + temp_msg
                }
                
            }
            Filemanager.sharedinstance.convertTextFile(file: save_msg)
            Themes.sharedInstance.activityView(View: self.view)
            let dir = CommondocumentDirectory()
            let fileURL = dir.appendingPathComponent("chats")
            SSZipArchive.createZipFile(atPath: dir.path.appending("/chats.zip"), withContentsOfDirectory: fileURL.path, keepParentDirectory: false, withPassword: nil, andProgressHandler: { (entryNumber, total) in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                    if(entryNumber == total){
                        Themes.sharedInstance.RemoveactivityView(View: self.view)
                    }
                })
            })
            self.share()
        }
        else
        {
            let chatprerecord:GroupDetail=ChatPrerecordArr[indexpath.row] as! GroupDetail
            var save_msg:String = String()
            let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
            let to:String=chatprerecord.id
            let User_chat_id=from + "-" + to
            var to_name:String = String()
            
            var ChatArr:NSArray=DatabaseHandler.sharedInstance.FetchFromDatabaseWithLimit(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "user_common_id", Predicatefromat: "==", FetchString: User_chat_id, Limit: 0, SortDescriptor: "timestamp") as NSArray
            if(ChatArr.count > 0)
            {
                let descriptor: NSSortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
                ChatArr = ChatArr.sortedArray(using: [descriptor]) as NSArray
            }
            for i in 0 ..< ChatArr.count {
                let ResponseDict = ChatArr[i] as! NSManagedObject
                var message:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "payload"))
                let from:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "from"))
                let timestamp:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "timestamp"))
                let type:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "type"))
                //let message_status:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "message_status"))
                let message_id:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "msgId"))
                let checkOtherMessages:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Other_Group_message, attribute: "id", FetchString: message_id)
                if(checkOtherMessages){
                    let MessageInfoArr:NSArray=DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Other_Group_message, attribute: "id", FetchString: message_id, SortDescriptor: nil) as! NSArray
                    
                    if(MessageInfoArr.count > 0)
                    {
                        for i in 0..<MessageInfoArr.count
                        {
                            let messageDict=MessageInfoArr[i] as! NSManagedObject
                            let GrounInfo=Themes.sharedInstance.CheckNullvalue(Passed_value: messageDict.value(forKey: "group_type"))
                            let CreatedUserID = Themes.sharedInstance.CheckNullvalue(Passed_value: messageDict.value(forKey: "from"))
                            
                            message = Themes.sharedInstance.returnOtherMessages(CreatedUserID, Themes.sharedInstance.CheckNullvalue(Passed_value: messageDict.value(forKey: "person_id")), GrounInfo)

                        }
                    }
                    
                }
                var temp_msg:String = String()
                let GroupDetailArr =  DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Group_details, attribute: "user_common_id", FetchString: User_chat_id, SortDescriptor: "timestamp") as! NSArray
                if(GroupDetailArr.count > 0)
                {
                    for j in 0..<GroupDetailArr.count
                    {
                        let ReponseDict:NSManagedObject = GroupDetailArr[j] as! NSManagedObject
                        let groupData:NSData?=ReponseDict.value(forKey: "groupUsers") as? NSData
                        
                        if(groupData != nil)
                        {
                            chatprerecord.groupUsers=NSKeyedUnarchiver.unarchiveObject(with: groupData! as Data) as! NSArray
                        }
                    }
                }
                
                let groupNameArr:NSMutableArray=NSMutableArray()
                let groupIdArr:NSMutableArray = NSMutableArray()
                if(chatprerecord.groupUsers.count > 0)
                {
                    for j in 0..<chatprerecord.groupUsers.count
                    {
                        let Dict:NSDictionary=chatprerecord.groupUsers[j] as! NSDictionary
                        let Grouppeoplerecord:Group_people_record=Group_people_record()
                        Grouppeoplerecord.id=Themes.sharedInstance.CheckNullvalue(Passed_value: Dict.object(forKey: "id") as! String) as NSString
                        Grouppeoplerecord.Name = Themes.sharedInstance.setNameTxt(Grouppeoplerecord.id as String, "single") as NSString
                        groupNameArr.add("\(Grouppeoplerecord.Name)")

                        groupIdArr.add("\(Grouppeoplerecord.id)")
                        
                    }
                }
                let index = groupIdArr.index(of: from)
                to_name = groupNameArr[index] as! String
                if(type == "0"){
                    
                    temp_msg = "\(Themes.sharedInstance.ReturnDateTimeSeconds(timestamp: timestamp)) : \(to_name) : \(message) \n"
                    
                    save_msg =  save_msg + temp_msg
                }
                
            }
            Filemanager.sharedinstance.convertTextFile(file: save_msg)
            Themes.sharedInstance.activityView(View: self.view)
            let dir = CommondocumentDirectory()
            let fileURL = dir.appendingPathComponent("chats")
            SSZipArchive.createZipFile(atPath: dir.path.appending("/chats.zip"), withContentsOfDirectory: fileURL.path, keepParentDirectory: false, withPassword: nil, andProgressHandler: { (entryNumber, total) in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                    if(entryNumber == total){
                        Themes.sharedInstance.RemoveactivityView(View: self.view)
                    }
                })
            })
            self.share()
        }
        
    }
    
    func share(){
        let dir = CommondocumentDirectory()
        let objectsToShare = [dir.appendingPathComponent("chats.zip")]
        let activityController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        let excludedActivities = [UIActivity.ActivityType.postToFlickr, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.print, UIActivity.ActivityType.assignToContact, UIActivity.ActivityType.postToFlickr, UIActivity.ActivityType.postToVimeo, UIActivity.ActivityType.postToTencentWeibo]
        
        activityController.excludedActivityTypes = excludedActivities
        self.searchController.dismissView(animated:true, completion:nil)
        self.presentView(activityController, animated: true)
    }
//    func exportChat(indexpath: IndexPath){
//        let sheet_action: UIAlertController = UIAlertController(title: nil, message: "Choose option", preferredStyle: .actionSheet)
//        let MediaAction: UIAlertAction = UIAlertAction(title: "Attach Media", style: .default) { action -> Void in
//            self.attach_media(indexpath: indexpath)
//        }
//        let noMediaAction: UIAlertAction = UIAlertAction(title: "Without Media", style: .default) { action -> Void in
//            self.attach_without_media(indexpath: indexpath)
//        }
//        let CancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
//
//        }
//        sheet_action.addAction(MediaAction)
//        sheet_action.addAction(noMediaAction)
//        sheet_action.addAction(CancelAction)
//        self.searchController.dismissView(animated:true, completion:nil)
//        self.presentView(sheet_action, animated: true, completion: nil)
//    }
    func showMoreActions(indexpath: IndexPath, callback: @escaping MoreActionCallback)
    {
        actionCallback = callback;
        
        let record = ChatPrerecordArr[indexpath.row]
        if(record is Chatpreloadrecord)
        {
            var index:Int!
            var isDeleteBtn:Bool!
            var isCancelBtn:Bool!
            let sheet_action: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let chatprerecord : Chatpreloadrecord = ChatPrerecordArr[indexpath.row] as! Chatpreloadrecord
            
            let muteTitle = Themes.sharedInstance.CheckMuteChats(id: chatprerecord.opponentid, type: "single") ? NSLocalizedString("Unmute", comment: "Unmute")  :  NSLocalizedString("Mute", comment: "Mute")
            
            let MuteAction: UIAlertAction = UIAlertAction(title: muteTitle, style: .default) { action -> Void in
                index = 0
                isDeleteBtn = false
                isCancelBtn = false
                if let action = self.actionCallback {
                    action(isCancelBtn,
                           isDeleteBtn,
                           index);
                    self.actionCallback = nil;
                }
            }
            let ContactAction: UIAlertAction = UIAlertAction(title:NSLocalizedString("Contact Info", comment: "Contact Info") , style: .default) { action -> Void in
                index = 1
                isDeleteBtn = false
                isCancelBtn = false
                if let action = self.actionCallback {
                    action(isCancelBtn,
                           isDeleteBtn,
                           index);
                    self.actionCallback = nil;
                }
                
                
            }
//            let ExportAction: UIAlertAction = UIAlertAction(title:NSLocalizedString("Export Chat", comment: "Export Chat") , style: .default) { action -> Void in
//                index = 2
//                self.exportChat(indexpath: indexpath)
//            }
            
            let actionTitle = Themes.sharedInstance.isChatLocked(id: chatprerecord.opponentid, type: "single") ? NSLocalizedString("Unlock Chat", comment: "Export Chat")  : NSLocalizedString("Lock Chat", comment: "Lock Chat")

            let LockAction: UIAlertAction = UIAlertAction(title: actionTitle, style: .default) { action -> Void in
                index = 5
                
                Themes.sharedInstance.LockAction(id: chatprerecord.opponentid, type: "single")
                self.actionCallback = nil;
            }
            let CancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment:"Cancel"), style: .cancel) { action -> Void in
                index = 0
                isDeleteBtn = false
                isCancelBtn = true
                if let action = self.actionCallback {
                    action(isCancelBtn,
                           isDeleteBtn,
                           index);
                    self.actionCallback = nil;
                }
            }
            sheet_action.addAction(MuteAction)
            sheet_action.addAction(ContactAction)
           // sheet_action.addAction(ExportAction)
            //sheet_action.addAction(LockAction)
            sheet_action.addAction(CancelAction)
            self.searchController.dismissView(animated:true, completion:nil)
            self.presentView(sheet_action, animated: true, completion: nil)
        }
        else
        {
            var index:Int!
            var isDeleteBtn:Bool!
            var isCancelBtn:Bool!
            let sheet_action: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let chatprerecord : GroupDetail = ChatPrerecordArr[indexpath.row] as! GroupDetail
            let muteTitle = Themes.sharedInstance.CheckMuteChats(id: chatprerecord.id, type: "group") ? "Unmute" : "Mute"
            
            let MuteAction: UIAlertAction = UIAlertAction(title: muteTitle, style: .default) { action -> Void in
                index = 0
                isDeleteBtn = false
                isCancelBtn = false
                if let action = self.actionCallback {
                    action(isCancelBtn,
                           isDeleteBtn,
                           index);
                    self.actionCallback = nil;
                }
            }
            let ContactAction: UIAlertAction = UIAlertAction(title: "Group Info", style: .default) { action -> Void in
                index = 1
                isDeleteBtn = false
                isCancelBtn = false
                if let action = self.actionCallback {
                    action(isCancelBtn,
                           isDeleteBtn,
                           index);
                    self.actionCallback = nil;
                }
                
                
            }
//            let ExportAction: UIAlertAction = UIAlertAction(title: "Export Chat", style: .default) { action -> Void in
//                index = 2
//                self.exportChat(indexpath: indexpath)
//            }
            let ClearAction: UIAlertAction = UIAlertAction(title: "Clear Chat", style: .default) { action -> Void in
                index = 3
                isDeleteBtn = false
                isCancelBtn = false
                if let action = self.actionCallback {
                    action(isCancelBtn,
                           isDeleteBtn,
                           index);
                    self.actionCallback = nil;
                }
                
            }
           
            let actionTitle = Themes.sharedInstance.isChatLocked(id: chatprerecord.id, type: "group") ? "Unlock Chat" : "Lock Chat"
            
            let is_deleted = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Group_details, attrib_name: "id", fetchString: chatprerecord.id, returnStr: "is_deleted")
            
//            let LockAction: UIAlertAction = UIAlertAction(title: actionTitle, style: .default) { action -> Void in
//                index = 4
//                if(is_deleted == "1")
//                {
//                    Themes.sharedInstance.ShowNotification("You have left the group so this conversation can't be locked", false)
//                }
//                else
//                {
//                    Themes.sharedInstance.LockAction(id: chatprerecord.id, type: "group")
//                }
//            }
            
            var DelAction: UIAlertAction!

            if(is_deleted == "1")
            {
                DelAction = UIAlertAction(title: "Delete group", style: .destructive) { action -> Void in
                    index = 5
                    
                    isDeleteBtn = false
                    isCancelBtn = false
                    if let action = self.actionCallback {
                        action(isCancelBtn,
                               isDeleteBtn,
                               index);
                        self.actionCallback = nil;
                    }
                }
            }
                
            else
            {
                DelAction = UIAlertAction(title: "Exit Group", style: .destructive) { action -> Void in
                    index = 6
                    
                    isDeleteBtn = false
                    isCancelBtn = false
                    if let action = self.actionCallback {
                        action(isCancelBtn,
                               isDeleteBtn,
                               index);
                        self.actionCallback = nil;
                    }
                    
                }
            }
            
            let CancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
                index = 0
                isDeleteBtn = false
                isCancelBtn = true
                if let action = self.actionCallback {
                    action(isCancelBtn,
                           isDeleteBtn,
                           index);
                    self.actionCallback = nil;
                }
            }
            sheet_action.addAction(MuteAction)
            sheet_action.addAction(ContactAction)
//            sheet_action.addAction(ExportAction)
            sheet_action.addAction(ClearAction)
//            sheet_action.addAction(LockAction)
            sheet_action.addAction(DelAction)
            sheet_action.addAction(CancelAction)
            self.searchController.dismissView(animated:true, completion:nil)
            self.presentView(sheet_action, animated: true, completion: nil)
        }
        
    }
    
    func DeleteAction(index:Int,indexpath:IndexPath)
    {
        var isDeleteBtn:Bool!
        var isCancelBtn:Bool!
        let chatprerecord:Chatpreloadrecord=ChatPrerecordArr[indexpath.row] as! Chatpreloadrecord
        let chat_locked = Themes.sharedInstance.isChatLocked(id: chatprerecord.opponentid, type: chatprerecord.ischattype)
        if(!chat_locked)
        {
            let sheet_action: UIAlertController = UIAlertController(title: "Delete Chat with \(chatprerecord.opponentname)", message: nil, preferredStyle: .actionSheet)
            
            let DeleteAction: UIAlertAction = UIAlertAction(title: "Delete Chat", style: .destructive) { action -> Void in
                isDeleteBtn = true
                isCancelBtn = false
                if let action = self.actionCallback {
                    action(isCancelBtn,
                           isDeleteBtn,
                           index);
                    self.actionCallback = nil;
                }
            }
            let ArchiveAction: UIAlertAction = UIAlertAction(title: "Archive Instead", style: .default) { action -> Void in
                isDeleteBtn = false
                isCancelBtn = false
                if let action = self.actionCallback {
                    action(isCancelBtn,
                           isDeleteBtn,
                           4);
                    self.actionCallback = nil;
                }
            }
            let CancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            }
            sheet_action.addAction(ArchiveAction)
            sheet_action.addAction(DeleteAction)
            sheet_action.addAction(CancelAction)
            self.searchController.dismissView(animated:true, completion:nil)
            self.presentView(sheet_action, animated: true, completion: nil)
        }
        else
        {
            Themes.sharedInstance.LockAction(id: chatprerecord.opponentid, type: "single")
        }
    }
    
    func ExecuteArchiveChat(indexpath:IndexPath)
    {
        if searchActive{
            guard (allArray.count > indexpath.section), ((allArray[indexpath.section] as! NSArray).count > indexpath.row) else{return}
        }else{
            guard ChatPrerecordArr.count > indexpath.row else{return}
        }
        //        guard searchActive ? ((allArray.count > indexpath.section)&&((allArray[indexpath.section] as! NSArray).count > indexpath.row)) : ChatPrerecordArr.count > indexpath.row else{return}
        guard chats_Tblview.numberOfSections > indexpath.section, chats_Tblview.numberOfRows(inSection: indexpath.section) > indexpath.row else{return}
        let record = searchActive ? (allArray[indexpath.section]as!NSArray)[indexpath.row] : ChatPrerecordArr[indexpath.row]
        var indexInChatPrerecordArr = 0
        if let chatprerecord = record as? Chatpreloadrecord
        {
            let user_common_id = "\(Themes.sharedInstance.Getuser_id())-\(chatprerecord.opponentid)"
            
            let CheckinitiatedDetails:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: user_common_id)
            if(CheckinitiatedDetails)
            {
                let conv_id:String = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_one_one, attrib_name: "user_common_id", fetchString: user_common_id, returnStr: "convId")
                if(conv_id != "")
                {
                    let DataDict:NSDictionary = ["from":Themes.sharedInstance.Getuser_id(),"convId":conv_id,"type":"single","status":"1"]
                    SocketIOManager.sharedInstance.EmitArchivedetails(Dict: DataDict)
                }
                
                let UpdateDict:NSDictionary =  ["is_archived":"1"]
                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: user_common_id, attribute: "user_common_id", UpdationElements: UpdateDict)
            }
            if searchActive{
                indexInChatPrerecordArr = ChatPrerecordArr.index(of: chatprerecord)
                allArray.removeObject(at: indexpath.row)
                if ChatPrerecordArr.count > indexInChatPrerecordArr{
                    ChatPrerecordArr.removeObject(at: indexInChatPrerecordArr)
                }
            }else{
                ChatPrerecordArr.removeObject(at: indexpath.row)
            }
            
            chats_Tblview.deleteRows(at: [indexpath], with: .fade)
            CheckData()
            CheckArchivedChat()
        }
        else if let chatprerecord = record as? GroupDetail
        {
            //            var chatprerecord = GroupDetail()
            //            chatprerecord = searchActive ? allArray[indexpath.row] as! GroupDetail : ChatPrerecordArr[indexpath.row] as! GroupDetail
            
            let user_common_id = "\(Themes.sharedInstance.Getuser_id())-\(chatprerecord.id)"
            
            let CheckinitiatedDetails:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: user_common_id)
            if(CheckinitiatedDetails)
            {
                let conv_id:String = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_one_one, attrib_name: "user_common_id", fetchString: user_common_id, returnStr: "convId")
                if(conv_id != "")
                {
                    let DataDict:NSDictionary = ["from":Themes.sharedInstance.Getuser_id(),"convId":conv_id,"type":"group","status":"1"]
                    SocketIOManager.sharedInstance.EmitArchivedetails(Dict: DataDict)
                }
                
                let UpdateDict:NSDictionary =  ["is_archived":"1"]
                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: user_common_id, attribute: "user_common_id", UpdationElements: UpdateDict)
                
            }
            
            if searchActive{
                indexInChatPrerecordArr = ChatPrerecordArr.index(of: chatprerecord)
                allArray.removeObject(at: indexpath.row)
                if ChatPrerecordArr.count > indexInChatPrerecordArr{
                    ChatPrerecordArr.removeObject(at: indexInChatPrerecordArr)
                }
            }else{
                ChatPrerecordArr.removeObject(at: indexpath.row)
            }
            chats_Tblview.deleteRows(at:[indexpath], with: .fade)
            CheckData()
            CheckArchivedChat()
        }
    }
    func CheckData()
    {
        if(ChatPrerecordArr.count == 0)
            
        {
            Nochat_view.isHidden=false
            chats_Tblview.isHidden=true
        }
    }
    @IBAction func DidclickArchChat(_ sender: Any)
    {
        let ArchVC:UIViewController = self.storyboard?.instantiateViewController(withIdentifier: "ArchivedViewControllerID") as! ArchivedViewController
        self.searchController.searchBar.resignFirstResponder()
        self.searchController.isActive = false
        self.pushView(ArchVC, animated: true)
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
            
//            let groupnamesBeginningWithLetterPredicate = NSPredicate(format: "(displayName BEGINSWITH[cd] $letter)")
            
//            let chatsnamesBeginningWithLetterPredicate = NSPredicate(format: "(opponentname BEGINSWITH[cd] $letter)")
            
//            let messagesWithLetterPredicate = NSPredicate(format: "SELF CONTAINS[c]     $letter")
            
            let array_chat = (ChatArr as NSArray).filter{(($0 as? Chatpreloadrecord)?.opponentname.lowercased().hasPrefix(Themes.sharedInstance.CheckNullvalue(Passed_value: searchController.searchBar.text).lowercased()) ?? false)}
            
            let array_group = (GroupArr as NSArray).filter{(($0 as? GroupDetail)?.displayName.lowercased().hasPrefix(Themes.sharedInstance.CheckNullvalue(Passed_value: searchController.searchBar.text).lowercased()) ?? false)}
            
            
            var array = [Any]()
            array.append(contentsOf: array_chat)
            array.append(contentsOf: array_group)
            let OtherChatArray = (favArray as NSArray).filter{(($0 as? FavRecord)?.name.lowercased().hasPrefix(Themes.sharedInstance.CheckNullvalue(Passed_value: searchController.searchBar.text).lowercased()) ?? false)}
//            filtered(using: namesBeginningWithLetterPredicate.withSubstitutionVariables(["letter": searchController.searchBar.text!]))
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
            editBtn.isHidden = true
            btn_View.isHidden = true
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
            editBtn.isHidden = false
            btn_View.isHidden = false
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
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.outgoingmessage), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            weak.reload()
        }
        
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.reloadChats), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            weak.reload()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            weak.changeStatus(notify)
            weak.chats_Tblview.reloadData()
        }
        
    }
    
    func NetworkDisconneted(_ isConnected: Bool) {
        if isConnected {
            chatLbl.text = "Waiting for network.."
            network_loader.isHidden = false
            network_loader.hidesWhenStopped = true
            network_loader.style = .white
            network_loader.startAnimating()
        }else{
            chatLbl.text = "Chats"
            network_loader.stopAnimating()
            network_loader.isHidden = true
        }
    }
    
    func removeNotificationListener() {
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        removeNotificationListener()
    }
 }
 
 
 extension ChatsViewController:FavouritesViewControllerDelegate
 {
    func MovetoChatView(viewcontroller: UIViewController) {
        self.searchController.searchBar.resignFirstResponder()
        self.searchController.isActive = false
        self.pushView(viewcontroller, animated: true)
    }
    
    func newgroup() {
        self.DidclickNewgroup(UIButton())
    }
 }
 
 extension String {
    //: ### Base64 encoding a string
    func base64Encoded() -> String? {
        if let data = self.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }
    
    //: ### Base64 decoding a string
    func base64Decoded() -> String? {
        if let data = Data(base64Encoded: self) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
 }
