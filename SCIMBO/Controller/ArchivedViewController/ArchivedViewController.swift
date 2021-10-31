//
//  ArchivedViewController.swift
//
//
//  Created by MV Anand Casp iOS on 28/07/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit
import Contacts
import SDWebImage
import SimpleImageViewer
import SWMessages

class ArchivedViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,SocketIOManagerDelegate,MGSwipeTableCellDelegate {
    var GroupPrerecordArr:NSMutableArray=NSMutableArray()
    @IBOutlet weak var noArchiveView: UIView!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var Header_Lbl: CustomLblFont!
    var ChatPrerecordArr:NSMutableArray = NSMutableArray()
    var actionCallback: MoreActionCallback?;
    var received_id:String = ""
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        addNotificationListener()
        let nibName = UINib(nibName: "GroupChatTableViewCell", bundle:nil)
        self.tableview.register(nibName, forCellReuseIdentifier: "GroupChatTableViewCell")
        
        let nibName1 = UINib(nibName: "ChatsTableViewCell", bundle:nil)
        self.tableview.register(nibName1, forCellReuseIdentifier: "ChatsTableViewCell")
        
        self.tableview.estimatedRowHeight = 85
        self.tableview.allowsSelection = true
        self.tableview.tableFooterView=UIView()
        self.tableview.separatorColor=UIColor.clear
        tableview.delegate = self
        tableview.dataSource = self
        SocketIOManager.sharedInstance.Delegate=self
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ReloadTable()
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
                self.tableview.allowsSelection = true
            }
        }
    }
    
    func messageArchive(_ notify: Notification){
        let ResponseDict:NSDictionary = notify.object  as! NSDictionary
        if(ResponseDict.count > 0)
        {
            if(notify.userInfo?["user_common_id"] != nil)
            {
                let to:String = Themes.sharedInstance.CheckNullvalue(Passed_value: notify.userInfo?["user_common_id"])
                received_id = "\(Themes.sharedInstance.Getuser_id())-\(to)"
                ExecuteArchiveChatReceiving(id: received_id)
                ReloadTable()
            }
        }
    }
    func ReloadTable()
    {
        Themes.sharedInstance.RemoveactivityView(View: self.tableview)
        
        ReloadSingleChat()
        ReloadGroup()
        
        ChatPrerecordArr.addObjects(from: GroupPrerecordArr as! [Any])
        
        if(ChatPrerecordArr.count > 0)
        {
            var SortArray:NSArray=NSArray(array: ChatPrerecordArr)
            SortArray = SortArray.sorted{(Themes.sharedInstance.shouldSortChatObj(first: $0, second: $1))} as NSArray
            ChatPrerecordArr=NSMutableArray(array: SortArray)
            print(">>>>>>the count is\(ChatPrerecordArr.count)")
        }
        
        if(ChatPrerecordArr.count == 0)
        {
            noArchiveView.isHidden=false
            tableview.isHidden=true
        }
        else
        {
            noArchiveView.isHidden=true
            tableview.isHidden=false
            tableview.reloadData()
        }
        
        if(ChatPrerecordArr.count > 0)
        {
            var SortArray:NSArray=NSArray(array: ChatPrerecordArr)
            SortArray = SortArray.sorted{(Themes.sharedInstance.shouldSortChatObj(first: $0, second: $1))} as NSArray
            ChatPrerecordArr=NSMutableArray(array: SortArray)
            print(">>>>>>the count is\(ChatPrerecordArr.count)")
            tableview.reloadData()
            
            noArchiveView.isHidden=true
            tableview.isHidden=false
        }
        else
        {
            noArchiveView.isHidden=false
            tableview.isHidden=true
        }
        
    }
    
    func ReloadSingleChat()
    {
        ChatPrerecordArr=NSMutableArray()
        let CheckPreloadRecord=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_id", FetchString: Themes.sharedInstance.Getuser_id())
        if(CheckPreloadRecord)
        {
            let p1 = NSPredicate(format: "user_id = %@", Themes.sharedInstance.Getuser_id())
            let p2 = NSPredicate(format: "chat_type = %@", "single")
            let p3 = NSPredicate(format: "is_archived = %@", "1")
            
            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2,p3])
            let chatintiatedDetailArr=DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Chat_intiated_details, SortDescriptor: nil, predicate: predicate,Limit:0) as! NSArray
            
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
                        
                        
                        ChatPrerecordArr.add(chatprerecord)
                    }
                }
                //                Nochat_view.isHidden=true
            }
            
        }
        
    }
    
    func ReloadGroup()
    {
        GroupPrerecordArr=NSMutableArray()
        
        let p1 = NSPredicate(format: "user_id = %@", Themes.sharedInstance.Getuser_id())
        let p2 = NSPredicate(format: "chat_type = %@", "group")
        let p3 = NSPredicate(format: "is_archived = %@", "1")
        
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2,p3])
        
        let chatintiatedDetailArr=DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Chat_intiated_details, SortDescriptor: nil, predicate: predicate,Limit:0) as! NSArray
        
        if(chatintiatedDetailArr.count > 0)
        {
            for i in 0..<chatintiatedDetailArr.count
            {
                let Reponse_Dict:NSManagedObject = chatintiatedDetailArr[i] as! NSManagedObject
                
                let chat_type = Themes.sharedInstance.CheckNullvalue(Passed_value: Reponse_Dict.value(forKey: "chat_type"))
                if(chat_type == "group")
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
                            GroupPrerecordArr.add(GroupDetailRec)
                        }
                        
                    }
                    
                }
                
            }
        }
        
        
    }
    
    @IBAction func openImageChats(sender:UIButton){
        let indexpath = NSIndexPath.init(row: sender.tag, section: 0)
        let cellItem = tableview.cellForRow(at: indexpath as IndexPath)
        if(cellItem is ChatsTableViewCell)
        {
            let configuration = ImageViewerConfiguration { config in
                config.imageView = (cellItem as! ChatsTableViewCell).user_Images
            }
            self.presentView(ImageViewerController(configuration: configuration), animated: true)
        }
        else
        {
            let configuration = ImageViewerConfiguration { config in
                config.imageView = (cellItem as! GroupChatTableViewCell).user_Images
            }
            self.presentView(ImageViewerController(configuration: configuration), animated: true)
            
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ChatPrerecordArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        guard indexPath.row < ChatPrerecordArr.count else{ return UITableViewCell() }
        
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
            
            cell.time_Lbl.text=Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.ConverttimeStamp(timestamp: chatprerecord.opponentlastmessageDate))
            tableView.separatorStyle = .none
            cell.messageCount_Lbl.adjustsFontSizeToFitWidth = true
            cell.name_Lbl.font = UIFont.boldSystemFont(ofSize: 16.0)
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
            tableView.separatorStyle = .none
            tableView.separatorColor = nil
            cell.messageCount_Lbl.adjustsFontSizeToFitWidth = true
            cell.name_Lbl.font = UIFont.boldSystemFont(ofSize: 16.0)
            cell.sender_nameLbl.font = UIFont.boldSystemFont(ofSize: 14.0)
            return cell
        }
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell, swipeButtonsFor direction: MGSwipeDirection, swipeSettings: MGSwipeSettings, expansionSettings: MGSwipeExpansionSettings) -> [UIView]?
    {
        if let indexPath = self.tableview.indexPath(for: cell) {
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
                        titlr = "Read"
                    }
                    else
                    {
                        titlr = "Unread"
                        
                    }
                    let read = MGSwipeButton(title: titlr,icon:titlr == "Read" ? UIImage(named: "read") : UIImage(named: "unread") , backgroundColor: color, callback: { (cell) -> Bool in
                        guard let indexPath = self.tableview.indexPath(for: cell) else{return true}
                        let chatpreloadRecord:Chatpreloadrecord = self.ChatPrerecordArr[indexPath.row] as! Chatpreloadrecord
                        cell.hideSwipe(animated: true)
                        let user_common_id = "\(Themes.sharedInstance.Getuser_id())-\(chatpreloadRecord.opponentid)"
                        if(chatpreloadRecord.isUnreadMessages)
                        {
                            chatpreloadRecord.isUnreadMessages  = false
                            chatpreloadRecord.opponentunreadmessagecount = ""
                            self.ClearUnreadMessages(user_common_id: user_common_id,status: "0",indexpath: indexPath,convID:chatpreloadRecord.opponentlastmessageid)
                            (cell.leftButtons[0] as! UIButton).setTitle(" Unread", for: UIControl.State())
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.change_chat_count), object: nil , userInfo: nil)
                            
                        }
                        else
                        {
                            chatpreloadRecord.isUnreadMessages  = true
                            chatpreloadRecord.opponentunreadmessagecount = ""
                            self.ClearUnreadMessages(user_common_id: user_common_id,status: "1",indexpath: indexPath,convID:chatpreloadRecord.opponentlastmessageid)
                            (cell.leftButtons[0] as! UIButton).setTitle("Read", for: UIControl.State());
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
                    
                    let trash = MGSwipeButton(title: NSLocalizedString("Unarchive", comment: "tes"),icon: UIImage(named: "archive"), backgroundColor: color1, callback: { (cell) -> Bool in
                        guard let indexPath = self.tableview.indexPath(for: cell) else{return true}
                        cell.hideSwipe(animated: true)
                        cell.refreshContentView()
                        self.ExecuteArchiveChat(indexpath:indexPath)
                        return false;
                    });
                    trash.centerIconOverText()
                    
                    let more = MGSwipeButton(title: "More",icon: UIImage(named: "more"), backgroundColor: color2, callback: { (cell) -> Bool in
                        guard let indexPath = self.tableview.indexPath(for: cell) else{return true}
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
                                Themes.sharedInstance.Mute_unMutechats(id: chatpreloadRecord.opponentid, type: "single")
                            }
                            else if index == 1 {
                                let singleInfoVC:SingleInfoViewController=self.storyboard?.instantiateViewController(withIdentifier: "SingleInfoViewController") as! SingleInfoViewController
                                let chat_ino:Chatpreloadrecord = self.ChatPrerecordArr[indexPath.row] as! Chatpreloadrecord
                                singleInfoVC.user_id = chat_ino.opponentid
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
                                    let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
                                    let deleteStarredAction = UIAlertAction(title: "Delete all except starred", style: .default, handler: {
                                        (alert: UIAlertAction!) -> Void in
                                        print("File Deleted")
                                        Themes.sharedInstance.executeClearChat("1", chat_info.opponentid, false)
                                    })
                                    let deleteMessageAction = UIAlertAction(title: "Delete all messages", style: .default, handler: {
                                        (alert: UIAlertAction!) -> Void in
                                        print("File Saved")
                                        Themes.sharedInstance.executeClearChat("0", chat_info.opponentid, false)
                                    })
                                    let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "comment"), style: .cancel, handler: {
                                        (alert: UIAlertAction!) -> Void in
                                        print("Cancelled")
                                    })
                                    optionMenu.addAction(deleteStarredAction)
                                    optionMenu.addAction(deleteMessageAction)
                                    optionMenu.addAction(cancelAction)
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
                    return [trash, more];
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
                        titlr = "Read"
                    }
                    else
                    {
                        titlr = " Unread"
                        
                    }
                    let read = MGSwipeButton(title: titlr,icon: titlr == "Read" ? UIImage(named: "read") : UIImage(named: "unread"), backgroundColor: color, callback: { (cell) -> Bool in
                        guard let indexPath = self.tableview.indexPath(for: cell) else{return true}
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
                    
                    let trash = MGSwipeButton(title: NSLocalizedString("Unarchive", comment: "tes"), icon: UIImage(named: "archive"), backgroundColor: color1, callback: { (cell) -> Bool in
                        guard let indexPath = self.tableview.indexPath(for: cell) else{return true}
                        cell.hideSwipe(animated: true)
                        cell.refreshContentView()
                        self.ExecuteArchiveChat(indexpath:indexPath)
                        return false;
                    });
                    trash.centerIconOverText()
                    
                    let more = MGSwipeButton(title: "More", icon: UIImage(named: "more"), backgroundColor: color2, callback: { (cell) -> Bool in
                        guard let indexPath = self.tableview.indexPath(for: cell) else{return true}
                        let chatpreloadRecord:GroupDetail = self.ChatPrerecordArr[indexPath.row] as! GroupDetail
                        self.showMoreActions(indexpath: indexPath, callback: { (cancelled, deleted, index) in
                            if cancelled {
                                return;
                            }
                            else if deleted {
                            }
                            else if index == 0 {
                                
                                Themes.sharedInstance.Mute_unMutechats(id: chatpreloadRecord.id, type: "group")
                                
                            }
                            else if index == 1 {
                                let chat_ino:GroupDetail = self.ChatPrerecordArr[indexPath.row] as! GroupDetail
                                
                                let GroupInfoVC:GroupInfoViewController=self.storyboard?.instantiateViewController(withIdentifier: "GroupInfoVCID") as! GroupInfoViewController
                                GroupInfoVC.common_id="\(Themes.sharedInstance.Getuser_id())-\(chat_ino.id)"
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
                                    let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "comment"), style: .cancel, handler: {
                                        (alert: UIAlertAction!) -> Void in
                                        print("Cancelled")
                                    })
                                    optionMenu.addAction(deleteStarredAction)
                                    optionMenu.addAction(deleteMessageAction)
                                    optionMenu.addAction(cancelAction)
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
                    return [trash, more];
                }
            }
        }
        return [UIView()]
    }
    
    func ClearUnreadMessages(user_common_id:String,status:String,indexpath:IndexPath,convID:String)
    {
        
        let param:NSDictionary = ["is_read":"\(status)"]
        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: user_common_id, attribute: "user_common_id", UpdationElements: param)
        tableview.reloadRows(at: [indexpath], with: .none)
        var currentStatus:String = String()
        let record = ChatPrerecordArr[indexpath.row]
        if(record is Chatpreloadrecord)
        {
            currentStatus = "single"
        }
        else
        {
            currentStatus = "group"
        }
        let Emitparam:NSDictionary = ["from":Themes.sharedInstance.Getuser_id(),"convId":convID,"status":"\(status)","type":"\(currentStatus)"]
        SocketIOManager.sharedInstance.EmitmarkedDetails(Dict: Emitparam)
        
    }
    
    func ExecuteArchiveChat(indexpath:IndexPath)
    {
        let record = ChatPrerecordArr[indexpath.row]
        if(record is Chatpreloadrecord)
        {
            
            let chatprerecord:Chatpreloadrecord=ChatPrerecordArr[indexpath.row] as! Chatpreloadrecord
            
            let user_common_id = "\(Themes.sharedInstance.Getuser_id())-\(chatprerecord.opponentid)"
            
            let CheckinitiatedDetails:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: user_common_id)
            if(CheckinitiatedDetails)
            {
                let conv_id:String = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_one_one, attrib_name: "user_common_id", fetchString: user_common_id, returnStr: "convId")
                if(conv_id != "")
                {
                    let DataDict:NSDictionary = ["from":Themes.sharedInstance.Getuser_id(),"convId":conv_id,"type":"single","status":"0"]
                    SocketIOManager.sharedInstance.EmitArchivedetails(Dict: DataDict)
                }
                
                let UpdateDict:NSDictionary =  ["is_archived":"0"]
                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: user_common_id, attribute: "user_common_id", UpdationElements: UpdateDict)
            }
            ChatPrerecordArr.removeObject(at: indexpath.row)
            tableview.deleteRows(at: [indexpath], with: .fade)
        }
        else
        {
            let chatprerecord:GroupDetail=ChatPrerecordArr[indexpath.row] as! GroupDetail
            
            let user_common_id = "\(Themes.sharedInstance.Getuser_id())-\(chatprerecord.id)"
            
            let CheckinitiatedDetails:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: user_common_id)
            if(CheckinitiatedDetails)
            {
                let conv_id:String = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_one_one, attrib_name: "user_common_id", fetchString: user_common_id, returnStr: "convId")
                if(conv_id != "")
                {
                    let DataDict:NSDictionary = ["from":Themes.sharedInstance.Getuser_id(),"convId":conv_id,"type":"group","status":"0"]
                    SocketIOManager.sharedInstance.EmitArchivedetails(Dict: DataDict)
                }
                
                let UpdateDict:NSDictionary =  ["is_archived":"0"]
                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: user_common_id, attribute: "user_common_id", UpdationElements: UpdateDict)
            }
            ChatPrerecordArr.removeObject(at: indexpath.row)
            tableview.deleteRows(at: [indexpath], with: .fade)
        }
        
        CheckData()
    }
    
    func ExecuteArchiveChatReceiving(id:String)
    {
        
        let CheckinitiatedDetails:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: id)
        if(CheckinitiatedDetails)
        {
            let conv_id:String = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_one_one, attrib_name: "user_common_id", fetchString: id, returnStr: "convId")
            let chat_type:String = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_one_one, attrib_name: "user_common_id", fetchString: id, returnStr: "chat_type")
            if(conv_id != "")
            {
                let DataDict:NSDictionary = ["from":Themes.sharedInstance.Getuser_id(),"convId":conv_id,"type":chat_type,"status":"0"]
                SocketIOManager.sharedInstance.EmitArchivedetails(Dict: DataDict)
            }
            
            let UpdateDict:NSDictionary =  ["is_archived":"0"]
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: id, attribute: "user_common_id", UpdationElements: UpdateDict)
        }
        
    }
    
    func CheckData()
    {
        
        if(ChatPrerecordArr.count == 0)
        {
            noArchiveView.isHidden=false
            tableview.isHidden=true
        }
        else
        {
            noArchiveView.isHidden=true
            tableview.isHidden=false
            tableview.reloadData()
        }
        
    }
    
    func attach_media_group(indexpath: IndexPath){
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
            let message:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "payload"))
            let timestamp:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "timestamp"))
            let type:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "type"))
            let thumbnail:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "thumbnail"))
            let doc_id:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id"))
            let from:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "from"))
            var temp_msg:String = String()
            var attachment_name:String = ""
            
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
                    if(upload_path != "")
                    {
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
                        place = "\(title_place),\(Stitle_place)"
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
            }
            else if(type == "14"){
                temp_msg = "\(Themes.sharedInstance.ReturnDateTimeSeconds(timestamp: timestamp)) : \(to_name) : \(place) \n"
            }else{
                temp_msg = "\(Themes.sharedInstance.ReturnDateTimeSeconds(timestamp: timestamp)) : \(to_name) : \(message) \n"
            }
            
            save_msg = save_msg + temp_msg
        }
        
        Filemanager.sharedinstance.zipMediaFiles(file: save_msg, pics: picture_path, contacts: contact_path)
        Themes.sharedInstance.activityView(View: self.tableview)
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first{
            let fileURL = dir.appendingPathComponent("chats")
            SSZipArchive.createZipFile(atPath: dir.path.appending("/chats.zip"), withContentsOfDirectory: fileURL.path, keepParentDirectory: false, withPassword: nil, andProgressHandler: { (entryNumber, total) in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                    if(entryNumber == total){
                        Themes.sharedInstance.RemoveactivityView(View: self.tableview)
                    }
                })
            })
        }
        self.share()
    }
    func attach_without_media_group(indexpath: IndexPath){
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
            let message:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "payload"))
            let from:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "from"))
            let timestamp:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "timestamp"))
            let type:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "type"))
            //let message_status:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "message_status"))
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
                    let CheckFavContact:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "id", FetchString: Grouppeoplerecord.id as String)
                    if(CheckFavContact)
                    {
                        let CheckFavContactArr:NSArray=DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "id", FetchString: Grouppeoplerecord.id as String, SortDescriptor: nil) as! NSArray 
                        if(CheckFavContactArr.count > 0)
                        {
                            let Responsedict=CheckFavContactArr[0] as! NSManagedObject
                            if(Themes.sharedInstance.CheckNullvalue(Passed_value: Responsedict.value(forKey: "name")) != "")
                            {
                                Grouppeoplerecord.Name=Themes.sharedInstance.CheckNullvalue(Passed_value: Responsedict.value(forKey: "name") as! String) as NSString
                            }
                            else
                            {
                                Grouppeoplerecord.Name=Themes.sharedInstance.CheckNullvalue(Passed_value: Dict.object(forKey: "PhNumber") as! String) as NSString
                            }
                        }
                        else
                        {
                            Grouppeoplerecord.Name=Themes.sharedInstance.CheckNullvalue(Passed_value: Dict.object(forKey: "msisdn") as! String) as NSString
                        }
                        groupNameArr.add("\(Grouppeoplerecord.Name)")
                    }
                    else if(Grouppeoplerecord.id as String == Themes.sharedInstance.Getuser_id())
                    {
                        Grouppeoplerecord.Name = "You".localized() as NSString
                        groupNameArr.add("\(Grouppeoplerecord.Name)")
                    }
                    else
                    {
                        Grouppeoplerecord.Name = Themes.sharedInstance.setNameTxt(Grouppeoplerecord.id as String, "single") as NSString
                        groupNameArr.add("\(Grouppeoplerecord.Name)")
                    }
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
        Themes.sharedInstance.activityView(View: self.tableview)
        let dir = CommondocumentDirectory()
        let fileURL = dir.appendingPathComponent("chats")
        SSZipArchive.createZipFile(atPath: dir.path.appending("/chats.zip"), withContentsOfDirectory: fileURL.path, keepParentDirectory: false, withPassword: nil, andProgressHandler: { (entryNumber, total) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                if(entryNumber == total){
                    Themes.sharedInstance.RemoveactivityView(View: self.tableview)
                }
            })
        })
        self.share()
    }
    
    func attach_media(indexpath: IndexPath){
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
        Themes.sharedInstance.activityView(View: self.tableview)
        let dir = CommondocumentDirectory()
        let fileURL = dir.appendingPathComponent("chats")
        SSZipArchive.createZipFile(atPath: dir.path.appending("/chats.zip"), withContentsOfDirectory: fileURL.path, keepParentDirectory: false, withPassword: nil, andProgressHandler: { (entryNumber, total) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                if(entryNumber == total){
                    Themes.sharedInstance.RemoveactivityView(View: self.tableview)
                }
            })
        })
        self.share()
    }
    
    func attach_without_media(indexpath: IndexPath){
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
        Themes.sharedInstance.activityView(View: self.tableview)
        let dir = CommondocumentDirectory()
        let fileURL = dir.appendingPathComponent("chats")
        SSZipArchive.createZipFile(atPath: dir.path.appending("/chats.zip"), withContentsOfDirectory: fileURL.path, keepParentDirectory: false, withPassword: nil, andProgressHandler: { (entryNumber, total) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                if(entryNumber == total){
                    Themes.sharedInstance.RemoveactivityView(View: self.tableview)
                }
            })
        })
        self.share()
    }
    
    func share(){
        let dir = CommondocumentDirectory()
        let objectsToShare = [dir.appendingPathComponent("chats.zip")]
        let activityController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        let excludedActivities = [UIActivity.ActivityType.postToFlickr, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.print, UIActivity.ActivityType.assignToContact, UIActivity.ActivityType.postToFlickr, UIActivity.ActivityType.postToVimeo, UIActivity.ActivityType.postToTencentWeibo]
        
        activityController.excludedActivityTypes = excludedActivities
        self.presentView(activityController, animated: true)
    }
    func exportChat(indexpath: IndexPath){
        let sheet_action: UIAlertController = UIAlertController(title: nil, message: "Choose option", preferredStyle: .actionSheet)
        let MediaAction: UIAlertAction = UIAlertAction(title: "Attach Media", style: .default) { action -> Void in
            let record = self.ChatPrerecordArr[indexpath.row]
            if(record is Chatpreloadrecord)
            {
                self.attach_media(indexpath: indexpath)
            }
            else
            {
                self.attach_media_group(indexpath: indexpath)
            }
        }
        let noMediaAction: UIAlertAction = UIAlertAction(title: "Without Media", style: .default) { action -> Void in
            let record = self.ChatPrerecordArr[indexpath.row]
            if(record is Chatpreloadrecord)
            {
                self.attach_without_media(indexpath: indexpath)
            }
            else
            {
                self.attach_without_media_group(indexpath: indexpath)
            }
            
        }
        let CancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "comment"), style: .cancel) { action -> Void in
            
        }
        sheet_action.addAction(MediaAction)
        sheet_action.addAction(noMediaAction)
        sheet_action.addAction(CancelAction)
        self.presentView(sheet_action, animated: true, completion: nil)
    }
    
    func showMoreActions(indexpath: IndexPath, callback: @escaping MoreActionCallback)
    {
        let record = ChatPrerecordArr[indexpath.row]
        if(record is Chatpreloadrecord)
        {
            actionCallback = callback;
            var index:Int!
            var isDeleteBtn:Bool!
            var isCancelBtn:Bool!
            let sheet_action: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let chatprerecord:Chatpreloadrecord=ChatPrerecordArr[indexpath.row] as! Chatpreloadrecord
            
            let muteTitle = Themes.sharedInstance.CheckMuteChats(id: chatprerecord.opponentid, type: "single") ? NSLocalizedString("Unmute", comment: "")  : NSLocalizedString("Mute", comment: "")
            
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
            let ContactAction: UIAlertAction = UIAlertAction(title:NSLocalizedString("Contact Info", comment:"co" ), style: .default) { action -> Void in
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
            let ExportAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Export Chat", comment: "com") , style: .default) { action -> Void in
                index = 2
                self.exportChat(indexpath: indexpath)
            }
            let ClearAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Clear Chat", comment: "com") , style: .default) { action -> Void in
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
            
            let actionTitle = Themes.sharedInstance.isChatLocked(id: chatprerecord.opponentid, type: "single") ? NSLocalizedString("Unlock Chat", comment: "com")  :  NSLocalizedString("Lock Chat", comment: "com")
            
            let LockAction: UIAlertAction = UIAlertAction(title: actionTitle, style: .default) { action -> Void in
                index = 5
                Themes.sharedInstance.LockAction(id: chatprerecord.opponentid, type: "single")
                self.actionCallback = nil;
            }
            let DelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Delete", comment:"com" ) , style: .destructive) { action -> Void in
                index = 6
                self.DeleteAction(index: index,indexpath: indexpath)
            }
            let CancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "comment"), style: .cancel) { action -> Void in
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
            sheet_action.addAction(ExportAction)
            sheet_action.addAction(ClearAction)
            sheet_action.addAction(LockAction)
            sheet_action.addAction(DelAction)
            sheet_action.addAction(CancelAction)
            self.presentView(sheet_action, animated: true, completion: nil)
        }
        else
        {
            actionCallback = callback;
            var index:Int!
            var isDeleteBtn:Bool!
            var isCancelBtn:Bool!
            let sheet_action: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let chatprerecord:GroupDetail=ChatPrerecordArr[indexpath.row] as! GroupDetail
            
            let muteTitle = Themes.sharedInstance.CheckMuteChats(id: chatprerecord.id, type: "group") ? NSLocalizedString("Unmute", comment: "")  : NSLocalizedString("Mute", comment: "")
            
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
            let ContactAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Group Info", comment: ""), style: .default) { action -> Void in
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
            let ExportAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Export Chat", comment: ""), style: .default) { action -> Void in
                index = 2
                self.exportChat(indexpath: indexpath)
            }
            let ClearAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Clear Chat", comment: "") , style: .default) { action -> Void in
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

            let actionTitle = Themes.sharedInstance.isChatLocked(id: chatprerecord.id, type: "group") ? NSLocalizedString("Unlock Chat", comment: "com")  : NSLocalizedString("Lock Chat", comment: "com")
            
            let is_deleted = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Group_details, attrib_name: "id", fetchString: chatprerecord.id, returnStr: "is_deleted")

            let LockAction: UIAlertAction = UIAlertAction(title: actionTitle, style: .default) { action -> Void in
                index = 4
                if(is_deleted == "1")
                {
                    Themes.sharedInstance.ShowNotification("You have left the group so this conversation can't be locked", false)
                }
                else
                {
                    Themes.sharedInstance.LockAction(id: chatprerecord.id, type: "group")
                }
            }
            
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
                DelAction = UIAlertAction(title: NSLocalizedString("Exit Group", comment: "tes") , style: .destructive) { action -> Void in
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
            
            let CancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "tes") , style: .cancel) { action -> Void in
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
            sheet_action.addAction(ExportAction)
            sheet_action.addAction(ClearAction)
            sheet_action.addAction(LockAction)
            sheet_action.addAction(DelAction)
            sheet_action.addAction(CancelAction)
            self.presentView(sheet_action, animated: true, completion: nil)
        }
    }
    
    func DeleteAction(index:Int,indexpath:IndexPath)
    {
        var isDeleteBtn:Bool!
        var isCancelBtn:Bool!
        let chatprerecord:Chatpreloadrecord=ChatPrerecordArr[indexpath.row] as! Chatpreloadrecord
        
        let sheet_action: UIAlertController = UIAlertController(title: NSLocalizedString("Delete Chat with", comment: "com") + " "  + chatprerecord.opponentname, message: nil, preferredStyle: .actionSheet)
        
        let DeleteAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Delete Chat", comment: "com") , style: .destructive) { action -> Void in
            isDeleteBtn = true
            isCancelBtn = false
            if let action = self.actionCallback {
                action(isCancelBtn,
                       isDeleteBtn,
                       index);
                self.actionCallback = nil;
            }
        }
        let ArchiveAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("UnArchive Instead", comment: "tes"), style: .default) { action -> Void in
            isDeleteBtn = false
            isCancelBtn = false
            if let action = self.actionCallback {
                action(isCancelBtn,
                       isDeleteBtn,
                       4);
                self.actionCallback = nil;
            }
        }
        let CancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "tes"), style: .cancel) { action -> Void in
        }
        sheet_action.addAction(ArchiveAction)
        sheet_action.addAction(DeleteAction)
        sheet_action.addAction(CancelAction)
        self.presentView(sheet_action, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let record = ChatPrerecordArr[indexPath.row]
        if(record is Chatpreloadrecord)
        {
            let chatprerecord:Chatpreloadrecord=ChatPrerecordArr[indexPath.row] as! Chatpreloadrecord
            let chatLocked = Themes.sharedInstance.isChatLocked(id: chatprerecord.opponentid, type: "single")
            if(chatLocked){
                self.enterToSingleChat(id: chatprerecord.opponentid,type: "single", indexpath:indexPath)
            }else{
                let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                ObjInitiateChatViewController.Chat_type="single"
                ObjInitiateChatViewController.opponent_id = chatprerecord.opponentid
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
                self.pushView(ObjInitiateChatViewController, animated: true)
            }
        }
    }
    
    func enterToChat(id:String,type:String,indexpath:IndexPath){
        
        Themes.sharedInstance.enterTochat(id: id, type: type) { (success) in
            if(success)
            {
                let chatprerecord:GroupDetail = self.ChatPrerecordArr[indexpath.row] as! GroupDetail
                let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                ObjInitiateChatViewController.Chat_type = type
                ObjInitiateChatViewController.opponent_id = chatprerecord.id
                self.pushView(ObjInitiateChatViewController, animated: true)
            }
        }
    }
    
    func enterToSingleChat(id:String,type:String,indexpath:IndexPath){
        Themes.sharedInstance.enterTochat(id: id, type: type) { (success) in
            if(success)
            {
                let chatprerecord:Chatpreloadrecord = self.ChatPrerecordArr[indexpath.row] as! Chatpreloadrecord
                let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                ObjInitiateChatViewController.Chat_type = type
                ObjInitiateChatViewController.opponent_id = chatprerecord.opponentid
                self.pushView(ObjInitiateChatViewController, animated: true)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    @IBAction func DidclickBack_Btn(_ sender: Any) {
        self.pop(animated: true)
    }
    
    func addNotificationListener() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.Incomingmessage), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            weak.messageArchive(notify)
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            weak.changeStatus(notify)
            weak.tableview.reloadData()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.reloadChats), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            weak.ReloadTable()
        }
    }
    
    func removeNotificationListener() {
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        removeNotificationListener()
    }

}
