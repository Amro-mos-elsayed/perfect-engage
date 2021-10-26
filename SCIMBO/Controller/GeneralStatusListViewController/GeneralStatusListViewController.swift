//
//  ViewController.swift
//  WhatsAppStatus
//
//  Created by raguraman on 29/03/18.
//  Copyright © 2018 raguraman. All rights reserved.
//UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1)

import UIKit
import Photos
import MediaPlayer
import DKImagePickerController
import SDWebImage
import SwiftyGiphy

protocol GeneralStatusListViewControllerDelegate : class {
    func isStatusBarHidden(_:Bool)
}

class GeneralStatusListViewController: UIViewController, UIViewControllerTransitioningDelegate, EditViewControllerDelegate, StatusPageViewControllerDelegate, MyStatusViewControllerDelegate{
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var privacyButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusTableView: UITableView!
    weak var delegate: GeneralStatusListViewControllerDelegate?
    
    let transition = CircularTransition()
    var center = CGPoint()
    var displayImg: UIImage? = nil
    var userStatusResource = [PHAsset]()
    var statusBarHidden = false
    var chatModel:ChatModel=ChatModel()
    var ChatPrerecordArr = [Chatpreloadrecord]()
    var ChatRecorMyDict = [String : NSMutableArray]()
    var ChatRecorDict = [String : NSMutableArray]()
    var ChatRecorDictViewed = [String : NSMutableArray]()
    var ChatRecorDictMuted = [String : NSMutableArray]()
    var numberofUsersnotViewed : Int = Int()
    var numberofUsersViewed : Int = Int()
    var sectionDetail : NSMutableArray = NSMutableArray()
    var selectedAssets = [DKAsset]()

    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        statusLabel.text = "Stories".localized()
        addNotificationListener()
        center = self.view.center
        statusTableView.dataSource = self
        statusTableView.delegate = self
        privacyButton.isHidden = true
        registerCell()
    }
    
    func isStatusBarHidden(_ value: Bool) {
        statusBarHidden = value
        setNeedsStatusBarAppearanceUpdate()
        delegate?.isStatusBarHidden(value)
    }
    
    func ReloadLoaderView(_ notify: Notification)
    {
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadAllData()
    }
    
    
    func deleteIfStatusCrossed24hours()
    {
        
        let CheckPreloadRecord=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Status_initiated_details, attribute: "user_id", FetchString: Themes.sharedInstance.Getuser_id())
        
        if(CheckPreloadRecord)
        {
            let p1 = NSPredicate(format: "user_id = %@", Themes.sharedInstance.Getuser_id())
            
            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1])
            let chatintiatedDetailArr=DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Status_initiated_details, SortDescriptor: nil, predicate: predicate,Limit:0) as! NSArray
            if(chatintiatedDetailArr.count > 0)
            {
                chatintiatedDetailArr.forEach {  Reponse_Dict in
                    let Reponse_Dict:NSManagedObject = Reponse_Dict as! NSManagedObject
                    
                    let user_common_id = Themes.sharedInstance.CheckNullvalue(Passed_value: Reponse_Dict.value(forKey: "user_common_id"))
                    
                    let P1:NSPredicate = NSPredicate(format: "from = %@", user_common_id)
                    let fetch_predicate:NSCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [P1])
                    
                    var ChatArr = DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Status_one_one, SortDescriptor: "date", predicate: fetch_predicate, Limit: 0) as! NSArray
                    if(ChatArr.count > 0)
                    {
                        let descriptor: NSSortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
                        ChatArr = ChatArr.sortedArray(using: [descriptor]) as NSArray
                        var chatcount = 0
                        ChatArr.forEach({ ResponseDict in
                            let ResponseDict : NSManagedObject = ResponseDict as! NSManagedObject
                            let timeStamp = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "timestamp"))
                            let id = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "id"))
                            let thumbnail = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "thumbnail"))
                            
                            let notoneDayComplete = Themes.sharedInstance.checkTimeStampMorethan24Hours(timestamp: timeStamp)
                            if(!notoneDayComplete)
                            {
                                let p1 = NSPredicate(format: "id = %@", id)
                                
                                DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Status_one_one, Predicatefromat: p1, Deletestring: "id", AttributeName: "id")
                                
                                
                                
                                let predic = NSPredicate(format: "upload_data_id == %@",thumbnail)
                                
                                let uploadDetailArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Status_Upload_Details, attribute: "upload_data_id", FetchString: thumbnail, SortDescriptor: nil) as! NSArray
                                if(uploadDetailArr.count > 0)
                                {
                                    for i in 0..<uploadDetailArr.count
                                    {
                                        let uploadDict:NSManagedObject = uploadDetailArr[i] as! NSManagedObject
                                        let upload_Path:String = Themes.sharedInstance.CheckNullvalue(Passed_value: uploadDict.value(forKey: "upload_Path"))
                                        Filemanager.sharedinstance.DeleteFile(foldername: upload_Path)
                                    }
                                    DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Status_Upload_Details, Predicatefromat: predic, Deletestring: "chatobj.message.thumbnail", AttributeName: "id")
                                }
                                chatcount = chatcount + 1
                            }
                        })
                        if(chatcount == ChatArr.count)
                        {
                            let p1 = NSPredicate(format: "user_common_id = %@", user_common_id)
                            DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Status_initiated_details, Predicatefromat: p1, Deletestring: "id", AttributeName: "id")
                        }
                    }
                }
            }
        }
    }
    
    func loadAllData()
    {
        self.deleteIfStatusCrossed24hours()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.change_chat_count), object: nil , userInfo: nil)
        ChatPrerecordArr=[Chatpreloadrecord]()
        self.ChatRecorMyDict = [String : NSMutableArray]()
        self.ChatRecorDict = [String : NSMutableArray]()
        self.ChatRecorDictViewed = [String : NSMutableArray]()
        self.ChatRecorDictMuted = [String : NSMutableArray]()
        let CheckPreloadRecord=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Status_initiated_details, attribute: "user_id", FetchString: Themes.sharedInstance.Getuser_id())
        
        var servertimeStr:String = Themes.sharedInstance.getServerTime()
        if(servertimeStr == "")
        {
            servertimeStr = "0"
        }
        if(CheckPreloadRecord)
        {
            let p1 = NSPredicate(format: "user_id = %@", Themes.sharedInstance.Getuser_id())
            
            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1])
            let chatintiatedDetailArr=DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Status_initiated_details, SortDescriptor: nil, predicate: predicate,Limit:0) as! NSArray
            if(chatintiatedDetailArr.count > 0)
            {
                for i in 0..<chatintiatedDetailArr.count
                {
                    let Reponse_Dict:NSManagedObject = chatintiatedDetailArr[i] as! NSManagedObject
                    
                    let user_common_id = Themes.sharedInstance.CheckNullvalue(Passed_value: Reponse_Dict.value(forKey: "user_common_id"))
                    let opponent_id = user_common_id
                    let timestamp = Themes.sharedInstance.CheckNullvalue(Passed_value: Reponse_Dict.value(forKey: "timestamp"))
                    let chat_type = Themes.sharedInstance.CheckNullvalue(Passed_value: Reponse_Dict.value(forKey: "chat_type"))
                    let conv_id = Themes.sharedInstance.CheckNullvalue(Passed_value: Reponse_Dict.value(forKey: "conv_id"))
                    let is_mute = Themes.sharedInstance.CheckNullvalue(Passed_value: Reponse_Dict.value(forKey: "is_mute"))
                    
                    
                    let CheckUserChat:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Status_one_one, attribute: "user_common_id", FetchString: user_common_id)
                    
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
                        let ReponseDict:NSManagedObject = (DatabaseHandler.sharedInstance.FetchFromDatabaseWithLimit(Entityname: Constant.sharedinstance.Status_one_one, attribute: "user_common_id", Predicatefromat: "==", FetchString: user_common_id , Limit: 1, SortDescriptor: "date") as NSArray)[0] as! NSManagedObject
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
                    
                    
                    ChatPrerecordArr.append(chatprerecord)
                    if(is_mute == "1")
                    {
                        self.loadDataSource(chatprerecord.opponentid, isMute: true)
                    }
                    else
                    {
                        self.loadDataSource(chatprerecord.opponentid, isMute: false)
                    }
                    
                }
                
            }
            
        }
        sectionDetail = NSMutableArray()
        sectionDetail.add("")
        if(Array(ChatRecorDict.keys).count > 0)
        {
            sectionDetail.add("RECENT UPDATES".localized())
        }
        if(Array(ChatRecorDictViewed.keys).count > 0)
        {
            sectionDetail.add("VIEWED UPDATES".localized())
        }
        if(Array(ChatRecorDictMuted.keys).count > 0)
        {
            sectionDetail.add("MUTED UPDATES".localized())
        }
        self.statusTableView.reloadData()
    }
    
    
    func loadDataSource(_ id : String, isMute : Bool)
    {
        
        self.chatModel = ChatModel()
        var ChatArr:NSArray = NSArray()
        
        let P1:NSPredicate = NSPredicate(format: "from = %@", id)
        let fetch_predicate:NSCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [P1])
        
        ChatArr = DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Status_one_one, SortDescriptor: "date", predicate: fetch_predicate, Limit: 0) as! NSArray
        if(ChatArr.count > 0)
        {
            let descriptor: NSSortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
            ChatArr = ChatArr.sortedArray(using: [descriptor]) as NSArray
            for i in 0 ..< ChatArr.count {
                let ResponseDict = ChatArr[i] as! NSManagedObject
                var dic = [AnyHashable: Any]()
                
                dic  = ["type": Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "type")),"convId":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "convId")),"doc_id":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id")),"filesize":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "filesize")),"from":Themes.sharedInstance.CheckNullvalue(Passed_value:ResponseDict.value(forKey: "from")
                    ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:ResponseDict.value(forKey: "to")
                    ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "isStar")),"message_status":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "message_status")),"id":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "id")),"name":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "name")),"payload":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "payload"))
                    ,"recordId":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "recordId")),"thumbnail":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "thumbnail")),"width":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "width")),"height":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "height")),"msgId":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "msgId")),"contactmsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "contactmsisdn"))
                    ,"user_common_id":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "user_common_id"))
                    ,"timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "timestamp")),"message_from":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "message_from")),"info_type":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "info_type")),"chat_type":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "chat_type")), "is_deleted" : Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "is_deleted")), "is_viewed" : Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "is_viewed")), "duration" : Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "duration")),"theme_color":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "theme_color")),"theme_font":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "theme_font"))]
                print(dic)
                
                if(id == Themes.sharedInstance.Getuser_id())
                {
                    if (dic["type"] as! String == "2")
                    {
                        let videoPath:String = StatusUploadHandler.Sharedinstance.ReturnuploadDetails(pathid: dic["thumbnail"] as! String, upload_detail: "upload_Path") as! String
                        
                        let download_status:String = StatusUploadHandler.Sharedinstance.ReturnuploadDetails(pathid: dic["thumbnail"] as! String, upload_detail: "download_status") as! String
                        
                        if(videoPath != "" || download_status != "")
                        {
                            self.dealTheFunctionData(dic)
                        }
                    }
                    else
                    {
                        self.dealTheFunctionData(dic)
                    }
                    
                }
                else
                {
                    self.dealTheFunctionData(dic)
                    
                }
            }
            
            if(id == Themes.sharedInstance.Getuser_id())
            {
                self.ChatRecorMyDict[id] = self.chatModel.dataSource
            }
            else
            {
                if(isMute)
                {
                    self.ChatRecorDictMuted[id] = self.chatModel.dataSource
                }
                else
                {
                    var viewedArrCount = 0
                    self.chatModel.dataSource.forEach { messageFrame in
                        let messageFrame : UUMessageFrame = messageFrame as! UUMessageFrame
                        if(messageFrame.message.is_viewed == "1")
                        {
                            viewedArrCount = viewedArrCount + 1
                        }
                    }
                    if(viewedArrCount == self.chatModel.dataSource.count)
                    {
                        self.ChatRecorDictViewed[id] = self.chatModel.dataSource
                    }
                    else
                    {
                        self.ChatRecorDict[id] = self.chatModel.dataSource
                    }
                }
                
            }
        }
    }
    
    func dealTheFunctionData(_ dic : [AnyHashable : Any])
    {
        self.chatModel.addSpecifiedItem(dic, isPagination: false)
    }
    
    private func registerCell(){
        statusTableView.register(UINib(nibName: "MyStatusTableViewCell", bundle: nil), forCellReuseIdentifier: "MyStatusTableViewCell")
        statusTableView.register(UINib(nibName: "FriendsTableViewCell", bundle: nil), forCellReuseIdentifier: "FriendsTableViewCell")
        statusTableView.register(UINib(nibName: "StatusHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "StatusHeaderView")
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        print("called")
    }
    
    override var prefersStatusBarHidden: Bool {
        return statusBarHidden
        
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        transition.startingPoint = center
        transition.circleColor = .black
        
        return transition
    }
    
    func DidDismiss() {
        statusBarHidden = false
        setNeedsStatusBarAppearanceUpdate()
        delegate?.isStatusBarHidden(false)
        self.loadAllData()
    }
    
    func DidClickDelete(_ messageFrame: UUMessageFrame) {
        
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        transition.startingPoint = center
        transition.circleColor = dismissed.view.backgroundColor!
        
        return transition
    }
    
    
    @IBAction func didClickPrivacyButton(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "StatusPrivacySettingViewController") as! StatusPrivacySettingViewController
        self.pushView(vc, animated: true)
    }
    
    func InsertTextStatusToDB(text:String, colorCode:String, fontName:String){
        
        let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
        let user_common_id:String = Themes.sharedInstance.CheckNullvalue(Passed_value: from)
        let payload:String=text
        var timestamp:String =  String(Date().ticks)
        var servertimeStr:String = Themes.sharedInstance.getServerTime()
        
        if(servertimeStr == "")
        {
            servertimeStr = "0"
        }
        let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
        timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
        
        let Name:String=Themes.sharedInstance.setNameTxt(Themes.sharedInstance.Getuser_id(), "")
        let Phonenumber:String = Themes.sharedInstance.setPhoneTxt(Themes.sharedInstance.Getuser_id())
        let toDocId:String="\(from)-\(timestamp)"
        
        let dic:[AnyHashable: Any] = ["type": "0","convId":"","doc_id":Themes.sharedInstance.CheckNullvalue(Passed_value:toDocId
            ),"filesize":"","from":Themes.sharedInstance.CheckNullvalue(Passed_value:from
            ),"to": "","isStar":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
            ),"message_status":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
            ),"id":timestamp,"name":Themes.sharedInstance.CheckNullvalue(Passed_value:Name
            ),"payload":payload, "theme_font":fontName, "theme_color":colorCode, "recordId":"","timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
            ),"thumbnail":"","width":"0.0","height":"0.0","msgId":timestamp,"contactmsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value:Phonenumber
            ),"user_common_id":user_common_id,"message_from":"1","chat_type":"single","info_type":"0","created_by":from,"is_reply":"0", "date" : Themes.sharedInstance.getTimeStamp()]
        
        DatabaseHandler.sharedInstance.InserttoDatabase(Dict: dic as NSDictionary,Entityname: Constant.sharedinstance.Status_one_one)
        
        let chatarray:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Status_initiated_details, attribute: "user_common_id", FetchString: from)
        if(!chatarray)
        {
            let User_dict:[AnyHashable: Any] = ["user_common_id": from, "user_to_dp":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_type":"single","is_archived":"0","conv_id":"","timestamp":timestamp,"opponent_id":"","is_read":"0","chat_count":"0"]
            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: User_dict as NSDictionary,Entityname: "\(Constant.sharedinstance.Status_initiated_details)")
            
        }
        else
        {
            let User_dict:[AnyHashable: Any]=["timestamp":timestamp,"is_archived":"0","is_read":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_count":"0"]
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Status_initiated_details, FetchString: from , attribute: "user_common_id", UpdationElements: User_dict as NSDictionary?)
        }
        SocketIOManager.sharedInstance.SendStatusMessage(from: Themes.sharedInstance.Getuser_id(), to: "", payload: payload, type: "0", timestamp: Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp), DocID: toDocId, thumbnail: "", thumbnail_data: "",filesize: "",height: "",width: "",doc_name:"",numPages:"", duration:"", themeColor: colorCode, theme_font: fontName)
    }
    
    func EdittedImage(AssetArr: NSMutableArray, Status: String) {
        if(AssetArr.count > 0)
        {
            
            for i in 0..<AssetArr.count
            {
                let ObjMultiMedia:MultimediaRecord = AssetArr[i] as! MultimediaRecord
                if(!ObjMultiMedia.isVideo)
                {
                    let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
                    let user_common_id:String = from
                    let payload:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ObjMultiMedia.caption)
                    var timestamp:String =  String(Date().ticks)
                    var servertimeStr:String = Themes.sharedInstance.getServerTime()
                    
                    if(servertimeStr == "")
                    {
                        servertimeStr = "0"
                    }
                    let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
                    timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
                    let Name:String = Themes.sharedInstance.setNameTxt(Themes.sharedInstance.Getuser_id(), "")
                    let Phonenumber:String=Themes.sharedInstance.setPhoneTxt(Themes.sharedInstance.Getuser_id())
                    let toDocId:String="\(from)-\(timestamp)"
                    let mesageID:String =  timestamp
                    let dic:[AnyHashable: Any] = ["type": "1","convId":"","doc_id":Themes.sharedInstance.CheckNullvalue(Passed_value:toDocId
                        ),"filesize":"","from":Themes.sharedInstance.CheckNullvalue(Passed_value:from
                        ),"to":"","isStar":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
                        ),"message_status":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
                        ),"id":mesageID,"name":Themes.sharedInstance.CheckNullvalue(Passed_value:Name
                        ),"payload":payload,"recordId":"","timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
                        ),"thumbnail":ObjMultiMedia.PathId,"width":"0.0","height":"0.0","msgId":Themes.sharedInstance.CheckNullvalue(Passed_value:mesageID
                        ),"contactmsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value:Phonenumber
                        ),"user_common_id":user_common_id,"message_from":"1","chat_type":"single","info_type":"0","created_by":from,"is_reply":"0", "date" : Themes.sharedInstance.getTimeStamp()]
                    
                    DatabaseHandler.sharedInstance.InserttoDatabase(Dict: dic as NSDictionary,Entityname: Constant.sharedinstance.Status_one_one)
                    let chatarray:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: "\(Constant.sharedinstance.Status_initiated_details)", attribute: "user_common_id", FetchString: from)
                    if(!chatarray)
                    {
                        let User_dict:[AnyHashable: Any] = ["user_common_id": from, "user_to_dp":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_type":"single","is_archived":"0","conv_id":"","timestamp":timestamp,"opponent_id":"","is_read":"0","chat_count":"0"]
                        DatabaseHandler.sharedInstance.InserttoDatabase(Dict: User_dict as NSDictionary,Entityname: "\(Constant.sharedinstance.Status_initiated_details)")
                        
                    }
                    else
                    {
                        let User_dict:[AnyHashable: Any]=["timestamp":timestamp,"is_archived":"0","is_read":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_count":"0"]
                        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Status_initiated_details, FetchString: from , attribute: "user_common_id", UpdationElements: User_dict as NSDictionary?)
                    }
                }
                    
                else
                {
                    
                    let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
                    let user_common_id:String = Themes.sharedInstance.CheckNullvalue(Passed_value: from)
                    let payload:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ObjMultiMedia.caption)
                    var timestamp:String =  String(Date().ticks)
                    var servertimeStr:String = Themes.sharedInstance.getServerTime()
                    
                    if(servertimeStr == "")
                    {
                        servertimeStr = "0"
                    }
                    let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
                    timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
                    
                    let Name:String=Themes.sharedInstance.setNameTxt(Themes.sharedInstance.Getuser_id(), "")
                    let Phonenumber:String=Themes.sharedInstance.setPhoneTxt(Themes.sharedInstance.Getuser_id())
                    let toDocId:String="\(from)-\(timestamp)"
                    let duration = Themes.sharedInstance.getMediaDuration(url: NSURL(fileURLWithPath: Themes.sharedInstance.CheckNullvalue(Passed_value: StatusUploadHandler.Sharedinstance.ReturnuploadDetails(pathid: ObjMultiMedia.PathId, upload_detail: "upload_Path"))))
                    let dic:[AnyHashable: Any] = ["type": "2","convId":"","doc_id":Themes.sharedInstance.CheckNullvalue(Passed_value:toDocId
                        ),"filesize":"","from":Themes.sharedInstance.CheckNullvalue(Passed_value:from
                        ),"to": "","isStar":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
                        ),"message_status":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
                        ),"id":ObjMultiMedia.timestamp,"name":Themes.sharedInstance.CheckNullvalue(Passed_value:Name
                        ),"payload":payload,"recordId":"","timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
                        ),"thumbnail":ObjMultiMedia.PathId,"width":"0.0","height":"0.0","msgId":Themes.sharedInstance.CheckNullvalue(Passed_value:ObjMultiMedia.timestamp
                        ),"contactmsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value:Phonenumber
                        ),"user_common_id":user_common_id,"message_from":"1","chat_type":"single","info_type":"0","created_by":from,"is_reply":"0", "duration" : duration, "date" : Themes.sharedInstance.getTimeStamp()]
                    
                    DatabaseHandler.sharedInstance.InserttoDatabase(Dict: dic as NSDictionary,Entityname: Constant.sharedinstance.Status_one_one)
                    
                    let chatarray:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Status_initiated_details, attribute: "user_common_id", FetchString: from)
                    if(!chatarray)
                    {
                        let User_dict:[AnyHashable: Any] = ["user_common_id": from, "user_to_dp":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_type":"single","is_archived":"0","conv_id":"","timestamp":timestamp,"opponent_id":"","is_read":"0","chat_count":"0"]
                        DatabaseHandler.sharedInstance.InserttoDatabase(Dict: User_dict as NSDictionary,Entityname: "\(Constant.sharedinstance.Status_initiated_details)")
                        
                    }
                    else
                    {
                        let User_dict:[AnyHashable: Any]=["timestamp":timestamp,"is_archived":"0","is_read":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_count":"0"]
                        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Status_initiated_details, FetchString: from , attribute: "user_common_id", UpdationElements: User_dict as NSDictionary?)
                    }
                }
                
            }
            StatusUploadHandler.Sharedinstance.handleUpload()
        }
    }
    
    func addNotificationListener() {
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.incomingstatus), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            weak.loadAllData()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.statusloaderdata), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            weak.ReloadLoaderView(notify)
        }
    }
    
    func removeNotificationListener() {
        NotificationCenter.default.removeObserver(self)
    }

    deinit {
        removeNotificationListener()
    }

}

extension GeneralStatusListViewController: UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionDetail.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }
        else if(sectionDetail.object(at: section) as! String == "RECENT UPDATES".localized())
        {
            return Array(self.ChatRecorDict.keys).count
        }
        else if(sectionDetail.object(at: section) as! String == "VIEWED UPDATES".localized())
        {
            return Array(self.ChatRecorDictViewed.keys).count
        }
        else
        {
            return Array(self.ChatRecorDictMuted.keys).count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 30
        }
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if section == 3{
            return 40
        }
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = statusTableView.dequeueReusableCell(withIdentifier: "MyStatusTableViewCell") as! MyStatusTableViewCell
            let datasource = self.ChatRecorMyDict[Themes.sharedInstance.Getuser_id()]
            cell.statusLabel.isHidden = true
            cell.statusLabel.text = ""
            if datasource != nil, (datasource?.count)! > 0
            {
                let messageFrame = datasource?.object(at: (datasource?.count)!-1) as! UUMessageFrame
                
                cell.statusLabel.isHidden = true
                cell.statusLabel.text = ""

                if messageFrame.message.type != MessageType(rawValue: 0){
                    cell.currentUserImg.image = nil
                    StatusUploadHandler.Sharedinstance.loadMyImage(messageFrame: messageFrame, imageView: cell.currentUserImg, isLoaderShow: false, isGif: false, completion: nil)
                    
                }else{
                    cell.currentUserImg.image = nil
                    cell.statusLabel.isHidden = false
                    cell.statusLabel.text = messageFrame.message.payload
                    cell.statusLabel.font = UIFont(name: messageFrame.message.theme_font, size: cell.statusLabel.font.pointSize)
                    cell.currentUserImg.backgroundColor = UIColor(hexString: Themes.sharedInstance.CheckNullvalue(Passed_value: (messageFrame.message.theme_color)))
                }
                cell.plusIcon.isHidden = true
                cell.statusIndicatorView.numberOfStatus = CGFloat((datasource?.count)!)
                cell.statusIndicatorView.isHidden = false
                cell.statusIndicatorView.defaultStatusColour = CustomColor.sharedInstance.themeColor
                var count = 0
                datasource?.forEach({ messageFrame in
                    let messageFrame : UUMessageFrame = messageFrame as! UUMessageFrame
                    
                    if(messageFrame.message.message_status == "0")
                    {
                        count = count + 1
                    }
                    
                })
                
                if(count == 0)
                {
                    cell.addToMyStatusLabel.text = Themes.sharedInstance.returnStatusTime(from: messageFrame.message.timestamp!)
                    
                }
                else
                {
                    cell.addToMyStatusLabel.text = "🕘 Sending \(count)"
                    
                }
            }
            else
            {
                cell.plusIcon.isHidden = false
                cell.currentUserImg.setProfilePic(Themes.sharedInstance.Getuser_id(), "single")
                cell.statusIndicatorView.isHidden = true
              //  cell.addToMyStatusLabel.text = NSLocalizedString("Add to my status", comment: "sss")
            }
            
            cell.delegate = self
            cell.selectionStyle = .none
            return cell
        }
        else{
            let cell = statusTableView.dequeueReusableCell(withIdentifier: "FriendsTableViewCell") as! FriendsTableViewCell
            var datasource = NSMutableArray()
            var id = String()
            var viewedstatusCount = 0
            if(sectionDetail.object(at: indexPath.section) as! String == "RECENT UPDATES".localized())
            {
                datasource = self.ChatRecorDict[Array(self.ChatRecorDict.keys)[indexPath.row]]!
                id = Array(self.ChatRecorDict.keys)[indexPath.row]
                viewedstatusCount = 0
                datasource.forEach { messageFrame in
                    let messageFrame : UUMessageFrame = messageFrame as! UUMessageFrame
                    if(messageFrame.message.is_viewed == "1")
                    {
                        viewedstatusCount = viewedstatusCount + 1
                    }
                }
                cell.friendStatusIndicator.isHidden = false
                cell.blurview.isHidden = true
            }
            else if(sectionDetail.object(at: indexPath.section) as! String == "VIEWED UPDATES".localized())
            {
                datasource = self.ChatRecorDictViewed[Array(self.ChatRecorDictViewed.keys)[indexPath.row]]!
                id = Array(self.ChatRecorDictViewed.keys)[indexPath.row]
                viewedstatusCount = datasource.count
                cell.friendStatusIndicator.isHidden = false
                cell.blurview.isHidden = true
            }
            else
            {
                datasource = self.ChatRecorDictMuted[Array(self.ChatRecorDictMuted.keys)[indexPath.row]]!
                id = Array(self.ChatRecorDictMuted.keys)[indexPath.row]
                viewedstatusCount = datasource.count
                cell.friendStatusIndicator.isHidden = true
                cell.blurview.isHidden = false
            }
            
            
            if(datasource.count > 0)
            {
                let messageFrame = datasource.object(at: datasource.count-1) as! UUMessageFrame
                
                
                if messageFrame.message.type != MessageType(rawValue: 0){
                    cell.statusTextLabel.isHidden = true
                    cell.statusTextLabel.text = ""
                    cell.friendsImg.image = nil
                    StatusUploadHandler.Sharedinstance.loadFriendsImage(messageFrame: messageFrame, imageView: cell.friendsImg, isLoaderShow: false, isGif: false, completion: nil)
                }else{
                    cell.statusTextLabel.isHidden = false
                    cell.statusTextLabel.text = messageFrame.message.payload
                    cell.statusTextLabel.font = UIFont(name: messageFrame.message.theme_font, size: cell.statusTextLabel.font.pointSize)
                    cell.friendsImg.image = nil
                    cell.friendsImg.backgroundColor = UIColor(hexString: Themes.sharedInstance.CheckNullvalue(Passed_value: (messageFrame.message.theme_color)))
                    
                }

                
                cell.friendStatusIndicator.numberOfStatus = CGFloat(datasource.count)
                cell.friendStatusIndicator.viewedStatusCount = CGFloat(viewedstatusCount)
                cell.friendStatusIndicator.viewedStatusColour = .lightGray
                cell.friendStatusIndicator.defaultStatusColour = CustomColor.sharedInstance.themeColor
                cell.friendName.setNameTxt(id, "single")
                
                cell.statusUpdatedLabel.text = Themes.sharedInstance.returnStatusTime(from: messageFrame.message.timestamp!)

            }
            else
            {
                cell.friendsImg.setProfilePic(id, "single")
                cell.friendStatusIndicator.isHidden = true
                cell.blurview.isHidden = false
            }
            
            cell.selectionStyle = .none
            cell.layoutIfNeeded()
            
            if(sectionDetail.object(at: indexPath.section) as! String == "RECENT UPDATES".localized())
            {
                if(indexPath.row == 0 && Array(self.ChatRecorDict.keys).count == 1)
                {
                    cell.topLineView.isHidden = false
                    cell.bottomLineView.isHidden = false
                    cell.bottomHalfLineView.isHidden = true
                }
                else if(indexPath.row == 0){
                    cell.topLineView.isHidden = false
                    cell.bottomLineView.isHidden = true
                    cell.bottomHalfLineView.isHidden = false
                    
                }
                else if(indexPath.row == Array(self.ChatRecorDict.keys).count - 1){
                    cell.topLineView.isHidden = true
                    cell.bottomLineView.isHidden = false
                    cell.bottomHalfLineView.isHidden = true
                    
                }
                else
                {
                    cell.topLineView.isHidden = true
                    cell.bottomLineView.isHidden = true
                    cell.bottomHalfLineView.isHidden = false
                }
            }
            else if(sectionDetail.object(at: indexPath.section) as! String == "VIEWED UPDATES".localized())
            {
                
                if(indexPath.row == 0 && Array(self.ChatRecorDictViewed.keys).count == 1)
                {
                    cell.topLineView.isHidden = false
                    cell.bottomLineView.isHidden = false
                    cell.bottomHalfLineView.isHidden = true
                }
                else if(indexPath.row == 0){
                    cell.topLineView.isHidden = false
                    cell.bottomLineView.isHidden = true
                    cell.bottomHalfLineView.isHidden = false
                    
                }
                else if(indexPath.row == Array(self.ChatRecorDictViewed.keys).count - 1){
                    cell.topLineView.isHidden = true
                    cell.bottomLineView.isHidden = false
                    cell.bottomHalfLineView.isHidden = true
                    
                }
                else
                {
                    cell.topLineView.isHidden = true
                    cell.bottomLineView.isHidden = true
                    cell.bottomHalfLineView.isHidden = false
                }
            }
            else
            {
                cell.topLineView.isHidden = true
                cell.bottomLineView.isHidden = true
                cell.bottomHalfLineView.isHidden = true
            }
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0{
            return nil
        }
        let cell = statusTableView.dequeueReusableHeaderFooterView(withIdentifier: "StatusHeaderView") as! StatusHeaderView
        cell.headerLabel.text = sectionDetail.object(at: section) as? String
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0
        {
            let datasource = self.ChatRecorMyDict[Themes.sharedInstance.Getuser_id()]
            if(datasource != nil)
            {
                if((datasource?.count)! > 0)
                {
                    let vc = storyboard?.instantiateViewController(withIdentifier: "MyStatusViewController") as! MyStatusViewController
                    vc.myStatusArray = datasource!
                    vc.ChatRecorDict = self.ChatRecorMyDict
                    vc.delegate = self
                    self.pushView(vc, animated: true)
                }
                else
                {
                    statusBarHidden = true
                    setNeedsStatusBarAppearanceUpdate()
                    let cell = tableView.cellForRow(at: indexPath)
                    center = (cell?.convert((cell?.center)!, to: self.view))!
                    let imagePickerController = ImagePickerController()
                    imagePickerController.delegate = self
                    imagePickerController.view.backgroundColor = .black
                    imagePickerController.imageLimit = 10
                    imagePickerController.transitioningDelegate = self
                    imagePickerController.modalPresentationStyle = .custom
                    delegate?.isStatusBarHidden(true)
                    self.presentView(imagePickerController, animated: true)
                }
            }
            else
            {
                statusBarHidden = true
                setNeedsStatusBarAppearanceUpdate()
                let cell = tableView.cellForRow(at: indexPath)
                center = (cell?.convert((cell?.center)!, to: self.view))!
                let imagePickerController = ImagePickerController()
                imagePickerController.delegate = self
                imagePickerController.view.backgroundColor = .black
                imagePickerController.imageLimit = 10
                imagePickerController.transitioningDelegate = self
                imagePickerController.modalPresentationStyle = .custom
                delegate?.isStatusBarHidden(true)
                self.presentView(imagePickerController, animated: true)
            }
        }
        else{
            
            let cell = tableView.cellForRow(at: indexPath)
            center = (cell?.convert((cell?.center)!, to: self.view))!
            let vc = storyboard?.instantiateViewController(withIdentifier: "StatusPageViewController") as! StatusPageViewController
            vc.isMyStatus = false
            if(sectionDetail.object(at: indexPath.section) as! String == "RECENT UPDATES".localized())
            {
                vc.idArr = Array(self.ChatRecorDict.keys)
                vc.ChatRecorDict = self.ChatRecorDict
            }
            else if(sectionDetail.object(at: indexPath.section) as! String == "VIEWED UPDATES".localized())
            {
                vc.idArr = Array(self.ChatRecorDictViewed.keys)
                vc.ChatRecorDict = self.ChatRecorDictViewed
            }
            else
            {
                vc.idArr = Array(self.ChatRecorDictMuted.keys)
                vc.ChatRecorDict = self.ChatRecorDictMuted
            }
            vc.currentStatusIndex = indexPath.row
            vc.view.backgroundColor = .black
            vc.transitioningDelegate = self
            vc.modalPresentationStyle = .custom
            vc.customDelegate = self
            statusBarHidden = true
            setNeedsStatusBarAppearanceUpdate()
            delegate?.isStatusBarHidden(true)
            self.presentView(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if(indexPath.section == 0)
        {
            return nil
        }
        else{
            var messageFrame = UUMessageFrame()
            var id = String()
            
            if(sectionDetail.object(at: indexPath.section) as! String == "RECENT UPDATES".localized())
            {
                let datasource = self.ChatRecorDict[Array(self.ChatRecorDict.keys)[indexPath.row]]!
                messageFrame = datasource.lastObject as! UUMessageFrame
                id = Array(self.ChatRecorDict.keys)[indexPath.row]
            }
            else if(sectionDetail.object(at: indexPath.section) as! String == "VIEWED UPDATES".localized())
            {
                let datasource = self.ChatRecorDictViewed[Array(self.ChatRecorDictViewed.keys)[indexPath.row]]!
                messageFrame = datasource.lastObject as! UUMessageFrame
                id = Array(self.ChatRecorDictViewed.keys)[indexPath.row]
            }
            else
            {
                let datasource = self.ChatRecorDictMuted[Array(self.ChatRecorDictMuted.keys)[indexPath.row]]!
                messageFrame = datasource.lastObject as! UUMessageFrame
                id = Array(self.ChatRecorDictMuted.keys)[indexPath.row]
            }
            let checkMute = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Status_initiated_details, attrib_name: "user_common_id", fetchString: id, returnStr: "is_mute")
            var title = ""
            var btntitle = ""
            
            if(checkMute == "1")
            {
                title = "Unmute \(Themes.sharedInstance.setNameTxt(Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message.user_from), "single"))'s status updates? New status updates from \(Themes.sharedInstance.setNameTxt(Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message.user_from), "single")) will appear at the top of the status list."
                btntitle = "Unmute"
            }
            else
            {
                title = "Mute \(Themes.sharedInstance.setNameTxt(Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message.user_from), "single"))'s status updates? New status updates from \(Themes.sharedInstance.setNameTxt(Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message.user_from), "single")) won't appear at the top of the status list anymore."
                btntitle = "Mute"
                
            }
            let button = UITableViewRowAction(style: .normal , title: btntitle) { action, indexPath in
                
                let alertController = UIAlertController(title: nil, message: title, preferredStyle: .actionSheet)
                
                let muteAction = UIAlertAction(title: "Mute", style: .default, handler: { (alert: UIAlertAction) in
                    
                    let convId = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Status_one_one, attrib_name: "doc_id", fetchString: messageFrame.message.doc_id!, returnStr: "convId")
                    let dic:[AnyHashable: Any] = ["from":Themes.sharedInstance.Getuser_id(),"to":id,"status":"1","convId":convId]
                    SocketIOManager.sharedInstance.muteStatus(param: dic as! [String : Any])
                    let checkInitiated = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Status_initiated_details, attribute: "user_common_id", FetchString: id)
                    if(checkInitiated)
                    {
                        let param = ["is_mute" : "1"]
                        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Status_initiated_details, FetchString: id, attribute: "user_common_id", UpdationElements: param as NSDictionary)
                    }
                    self.loadAllData()
                })
                let unMuteAction = UIAlertAction(title: "Unmute", style: .default, handler: { (alert: UIAlertAction) in
                    
                    let convId = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Status_one_one, attrib_name: "doc_id", fetchString: messageFrame.message.doc_id!, returnStr: "convId")
                    let dic:[AnyHashable: Any] = ["from":Themes.sharedInstance.Getuser_id(),"to":id,"status":"0","convId":convId]
                    SocketIOManager.sharedInstance.muteStatus(param: dic as! [String : Any])
                    let checkInitiated = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Status_initiated_details, attribute: "user_common_id", FetchString: id)
                    if(checkInitiated)
                    {
                        let param = ["is_mute" : ""]
                        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Status_initiated_details, FetchString: id, attribute: "user_common_id", UpdationElements: param as NSDictionary)
                    }
                    self.loadAllData()
                })
                let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "comment"), style: .cancel, handler: { (alert: UIAlertAction) in
                })
                
                if(checkMute == "1")
                {
                    alertController.addAction(unMuteAction)
                }
                else
                {
                    alertController.addAction(muteAction)
                }
                alertController.addAction(cancelAction)
                self.presentView(alertController, animated: true, completion: nil)
            }
            return [button]
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if(indexPath.section == 0)
        {
            return false
        }
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
}


extension GeneralStatusListViewController: MyStatusTableViewCellDelegate, TextStatusViewControllerDelegate{
    
    func sendStatus(text: String, bgColor: String, fontName: String) {
        InsertTextStatusToDB(text: text, colorCode: bgColor, fontName: fontName)
    }
    
    func didClickCamera() {
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.view.backgroundColor = .black
        imagePickerController.imageLimit = 10
        imagePickerController.transitioningDelegate = self
        imagePickerController.modalPresentationStyle = .currentContext
        statusBarHidden = true
        setNeedsStatusBarAppearanceUpdate()
        delegate?.isStatusBarHidden(true)
        self.presentView(imagePickerController, animated: true)
    }
    
    func didClickText() {
        let VC = storyboard?.instantiateViewController(withIdentifier: "TextStatusViewController") as? TextStatusViewController
        VC?.delegate = self
        self.pushView(VC!, animated: true)
    }
    
    
}

extension GeneralStatusListViewController: ImagePickerDelegate{
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        imagePicker.dismissView(animated: true, completion: nil)
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [PHAsset]) {
        statusBarHidden = false
        setNeedsStatusBarAppearanceUpdate()
        delegate?.isStatusBarHidden(false)
        imagePicker.dismissView(animated: true, completion: nil)
        
        guard images.count > 0 else{return}
        
        var assets = [DKAsset]()
        
        images.forEach { image in
            let asset : DKAsset = DKAsset(originalAsset: image)
            assets.append(asset)
        }
        
        if(assets.count > 0)
        {
            self.selectedAssets = assets
            Themes.sharedInstance.activityView(View: self.view)
            AssetHandler.sharedInstance.isgroup = false
            
            AssetHandler.sharedInstance.ProcessAsset(assets: assets,oppenentID: "",isFromStatus: true, completionHandler: { [weak self] (AssetArr, error) -> ()? in
                if((AssetArr?.count)! > 0)
                {     DispatchQueue.main.async {
                    Themes.sharedInstance.RemoveactivityView(View: (self?.view)!)
                    let EditVC = self?.storyboard?.instantiateViewController(withIdentifier: "EditViewControllerID") as! EditViewController
                    EditVC.AssetArr = AssetArr!
                    EditVC.isfromStatus = true
                    EditVC.Delegate = self
                    EditVC.selectedAssets = (self?.selectedAssets)!
                    self?.pushView(EditVC, animated: true)
                    }
                }
                return ()
            })
        }
        
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        statusBarHidden = false
        setNeedsStatusBarAppearanceUpdate()
        delegate?.isStatusBarHidden(false)
        imagePicker.dismissView(animated: true, completion: nil)
    }
    
    func didclickGallery(_ imagePicker: ImagePickerController) {
        imagePicker.dismissView(animated: true) {
            
            let pickerController = DKImagePickerController()
            pickerController.maxSelectableCount = 10
            pickerController.assetType = .allAssets
            pickerController.sourceType = .photo
            pickerController.isFromChat = true
            pickerController.didSelectAssets = { (assets: [DKAsset]) in
                self.delegate?.isStatusBarHidden(false)
                if(assets.count > 0)
                {
                    self.selectedAssets = assets
                    Themes.sharedInstance.activityView(View: self.view)
                    AssetHandler.sharedInstance.isgroup = false
                    AssetHandler.sharedInstance.ProcessAsset(assets: assets,oppenentID: "",isFromStatus: true, completionHandler: { [weak self] (AssetArr, error) -> ()? in
                        if((AssetArr?.count)! > 0)
                        {     DispatchQueue.main.async {
                            Themes.sharedInstance.RemoveactivityView(View: (self?.view)!)
                            let EditVC = self?.storyboard?.instantiateViewController(withIdentifier: "EditViewControllerID") as! EditViewController
                            EditVC.AssetArr = AssetArr!
                            EditVC.isfromStatus = true
                            EditVC.Delegate = self
                            EditVC.selectedAssets = (self?.selectedAssets)!
                            self?.pushView(EditVC, animated: true)
                            }
                        }
                        return ()
                    })
                }
            }
            pickerController.didClickGif = {
                self.delegate?.isStatusBarHidden(false)
                let picker = SwiftyGiphyViewController()
                picker.delegate = self
                let navigation = UINavigationController(rootViewController: picker)
                self.presentView(navigation, animated: true)
            }
            self.presentView(pickerController, animated: true)
        }
    }
}

extension GeneralStatusListViewController : SwiftyGiphyViewControllerDelegate {
    
    func giphyControllerDidSelectGif(controller: SwiftyGiphyViewController, item: GiphyItem) {
        self.dismissView(animated: true, completion: {
            Themes.sharedInstance.showprogressAlert(controller: self)
            var url : URL?
            if(item.downsizedImage != nil)
            {
                url = item.downsizedImage?.url
            }
            else if(item.fixedHeightImage != nil)
            {
                url = item.fixedHeightImage?.url
            }
            else
            {
                url = item.originalImage?.url
            }
            
            SDWebImageDownloader.shared().downloadImage(with: url, options: .highPriority, progress: { (received, total, url) in
                DispatchQueue.main.async {
                    if(received != total)
                    {
                        Themes.sharedInstance.setprogressinAlert(controller: self, progress: Float(received) / Float(total), completionHandler: nil)
                    }
                }
            }) { (image, data, error, success) in
                if(error == nil)
                {
                    DispatchQueue.main.async {
                        Themes.sharedInstance.setprogressinAlert(controller: self, progress: 1.0, completionHandler: {
                            
                            Filemanager.sharedinstance.CreateFolder(foldername: "Temp")
                            
                            var timestamp:String = String(Date().ticks)
                            var servertimeStr:String = Themes.sharedInstance.getServerTime()
                            
                            if(servertimeStr == "")
                            {
                                servertimeStr = "0"
                            }
                            let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
                            timestamp =  "\((timestamp as NSString).longLongValue + Int64(0) - serverTimestamp)"
                            
                            
                            let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
                            let to:String=""
                            
                            let User_chat_id = (to == "") ? from : from + "-" + to;
                            
                            let url = Filemanager.sharedinstance.SaveImageFile(imagePath: "Temp/\(timestamp).gif", imagedata: data!)
                            
                            let ObjMultiRecord:MultimediaRecord = MultimediaRecord()
                            
                            let Pathextension:String = "GIF"
                            
                            ObjMultiRecord.assetname = "\(User_chat_id)-\(timestamp).\(Pathextension.lowercased())"
                            
                            ObjMultiRecord.timestamp = timestamp
                            ObjMultiRecord.userCommonID = User_chat_id
                            ObjMultiRecord.assetpathname = url
                            print(ObjMultiRecord.assetpathname)
                            ObjMultiRecord.toID = to
                            ObjMultiRecord.isVideo = false
                            ObjMultiRecord.StartTime = 0.0
                            ObjMultiRecord.Endtime = 0.0
                            ObjMultiRecord.Thumbnail = image
                            ObjMultiRecord.rawData = data
                            ObjMultiRecord.isGif = true
                            
                            ObjMultiRecord.CompresssedData = image!.jpegData(compressionQuality: 0.1)
//                            UIImageJPEGRepresentation(, 0.1)
                            ObjMultiRecord.Base64Str = Themes.sharedInstance.convertImageToBase64(imageData:ObjMultiRecord.CompresssedData)
                            
                            Filemanager.sharedinstance.DeleteFile(foldername: "Temp/\(timestamp).gif")
                            
                            let EditVC = self.storyboard?.instantiateViewController(withIdentifier: "EditViewControllerID") as! EditViewController
                            EditVC.AssetArr = NSMutableArray.init(array: [ObjMultiRecord])
                            EditVC.isfromStatus = true
                            EditVC.Delegate = self
                            EditVC.selectedAssets = []
                            self.pushView(EditVC, animated: true)
                        })
                    }
                }
                else {
                    Themes.sharedInstance.setprogressinAlert(controller: self, progress: 1.0, completionHandler: nil)
                }
            }
        })
    }
    func giphyControllerDidCancel(controller: SwiftyGiphyViewController) {
        self.dismissView(animated: true, completion: nil)
    }
}
