 //
 //  InitiateChatViewController.swift
 //  ChatApp
 //
 //  Created by Casp iOS on 28/12/16.
 //  Copyright © 2016 Casp iOS. All rights reserved.
 import UIKit
 import CoreData
 import Photos
 import DKImagePickerController
 import AVKit
 import SDWebImage
 import JSSAlertView
 import Contacts
 import ContactsUI
 import MessageUI
 import Social
 import SimpleImageViewer
 import ActionSheetPicker_3_0
 import SwiftyGiphy
 import SwiftyGif
 import VisionKit
 import PDFKit
 
 

  class InitiateChatViewController: UIViewController,UUInputFunctionViewDelegate,UUMessageCellDelegate,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,EditViewControllerDelegate,UserDetlUpdationDelegate,UIActionSheetDelegate,VNDocumentCameraViewControllerDelegate, UINavigationControllerDelegate,UUAVAudioPlayerDelegate,ReplyDetailViewDelegate,MapViewViewControllerDelegate,contactShare,CNContactViewControllerDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate,unKnownPerson,secretTime, UIViewControllerTransitioningDelegate, CustomTableViewCellDelegate, AudioManagerDelegate, UIGestureRecognizerDelegate
 {
    
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var videocall_Btn: UIButton!
    @IBOutlet var audiocall_Btn: UIButton!
    @IBOutlet var left_item: UIBarButtonItem!
    @IBOutlet weak var link_bottom: NSLayoutConstraint!
    @IBOutlet var right_item: UIBarButtonItem!
    @IBOutlet var center_item: UIBarButtonItem!
    @IBOutlet weak var link_view: URLEmbeddedView!
    @IBOutlet var selectiontoolbar: UIToolbar!
    @IBOutlet var Group_name_Lbl: UILabel!
    @IBOutlet var infoButtonTap: UIButton!
    @IBOutlet var Chat_imageView: UIImageView!
    @IBOutlet var chat_background_imageview: UIImageView!
    @IBOutlet weak var secretButton: UIButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var expiration_lbl: UILabel!
    @IBOutlet weak var expiration_time: UIButton!
    @IBOutlet weak var bottomnavigateView: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet var not_member_view_bottom: UIView!
    @IBOutlet var group_user_lbl: UILabel!
    @IBOutlet var secret_view: UIView!
    @IBOutlet var profile_view: UIView!

    var pathname:String = ""
    var locationR:Bool = false
    var is_fromSecret:Bool = false
    var fromForward : Bool = Bool()
    var latitudeR:CLLocationDegrees!
    var longitudeR:CLLocationDegrees!
    var address:String = String()
    var Title_D:String = String()
    var userfavRecord:FavRecord = FavRecord()
    var appear:Bool = false
    var goBack:Bool = false
    var scanedDocumentsCount:Int = 0
    var from_search_msg:Bool = false
    var from_search_msg_id:String = ""
    var from_message:String = ""
    var is_chatPage_contact:Bool = false
    let ObjMultiRecord:MultimediaRecord = MultimediaRecord()
    var scannerViewControllerTemp = UIViewController()
    
    let funcView = UUInputFunctionView()
    
    var conv_id:String = String()
    var contact_details:String = String()
    var Title_str:String = String()
    var ImageURl:String = String()
    var Desc:String = String()
    var Url_str:String = String()
    var link_str:String = String()
    var D:String = String()
    var linkUrl:String = String()
    var isFromUrl:Bool = Bool()
    var scanedDocuments = [DKAsset]()
    var isNotContact:Bool = Bool()
    var chatModel:ChatModel=ChatModel()
    var Chat_type:String=String()
    var Is:String=String()
    var newFrame:CGRect=CGRect()
    var isKeyboardShown:Bool=Bool()
    var previousTime: String? = nil
    var isBeginEditing:Bool = Bool()
    var pause_row:NSInteger = NSInteger()
    var initial = 0
    var Firstindexpath:IndexPath = IndexPath()
    var isForwardAction:Bool = Bool()
    var isShowBottomView:Bool = Bool()
    var isReplyMessage:Bool = Bool()
    var document_doc_id:String = String()
    var document_msg_id:String = String()
    var IFView:UUInputFunctionView!
    var ReplyView:ReplyDetailView!;
    var ReplyMessageRecord:UUMessageFrame = UUMessageFrame()
    let refreshControl = UIRefreshControl()
    var messageRecord:UUMessageFrame = UUMessageFrame()
    var is_you_removed:Bool = Bool()
    var go:Bool = false
    var istartTyping:Bool = false
    var typingTimer:Timer?
    var isYou : Bool = false
    var center = CGPoint()
    let transition = CircularTransition()
    var tagView : PersonViewedStatusView!
    var TagIdArr = [String]()
    var TagPersonRange = [NSRange]()
    var TagNameArr = [String]()
    var audioPlayBtn : UIButton?
    var selectedAssets = [DKAsset]()
    var popovershow = false
    var opponent_id = String()
    var groupUsers = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        addNotificationListener()
        self.UpdateUI()
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                self.LoadBaseView(limit: 0)
            }
        }
        SecretmessageHandler.sharedInstance.delegate = self
        chatTableView.rowHeight = UITableView.automaticDimension
        chatTableView.estimatedRowHeight = 10
        chatTableView.semanticContentAttribute = .forceLeftToRight
        chatTableView.registerCell()
        if Chat_type == "single" {
            group_user_lbl.text = "Tap here for contact info"
        }else{
            group_user_lbl.text = "Tap here for group info"
        }
    }
    
    func UpdateUI()
    {
        addRefreshViews();
        var rect : CGRect = not_member_view_bottom.frame
        rect.origin.y = self.view.frame.size.height
        not_member_view_bottom.frame = rect
        link_view.isHidden = true
        self.bottomConstraint.constant = 50
        chatTableView.backgroundColor=UIColor(red:0.94, green:0.94, blue:0.94, alpha:1.0)
        Chat_imageView.layer.cornerRadius = Chat_imageView.frame.size.width/2
        Chat_imageView.clipsToBounds=true
        bottomnavigateView.isHidden = true
        chatTableView.allowsMultipleSelectionDuringEditing = true
        //        UIMenuController.shared.update()
        ReplyView = Bundle.main.loadNibNamed("ReplyDetailView", owner: self, options: nil)?[0] as? ReplyDetailView
        tagView = Bundle.main.loadNibNamed("PersonViewedStatusView", owner: self, options: nil)?[0] as? PersonViewedStatusView
        tagView.isFromTag = true
        setBackground()
        if(is_fromSecret == true){
            setSecretView()
        }
        if(conv_id == "")
        {
            let from = Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
            let to = Themes.sharedInstance.CheckNullvalue(Passed_value: opponent_id)
            let user_common_id:String = from + "-" + to
            conv_id = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_intiated_details, attrib_name: "user_common_id", fetchString: user_common_id, returnStr: "conv_id")
        }
        self.Title_str = ""
        self.ImageURl = ""
        self.Desc = ""
        self.Url_str = ""
        self.link_view.title_Str = ""
        self.link_view.image_Url = ""
        self.link_view.desc_Str = ""
        self.link_str = ""
        updateChatViewAtLoad()
    }
    
    func setExpirationLabel(){
        if(self.Chat_type == "secret"){
            let user_common_id = opponent_id + "-" + Themes.sharedInstance.Getuser_id()
            expiration_lbl.isHidden = false
            let checkBool:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Secret_Chat, attribute: "user_common_id", FetchString: user_common_id)
            var expiration_time_lbl:NSString = ""
            if(checkBool){
                var timer:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Secret_Chat, attribute: "user_common_id", FetchString: user_common_id, SortDescriptor: "timestamp") as! NSArray
                timer = timer.reversed() as NSArray
                if(timer.count > 0){
                    let dict:NSManagedObject = timer[0] as! NSManagedObject
                    expiration_time_lbl = Themes.sharedInstance.CheckNullvalue(Passed_value: dict.value(forKey: "expiration_time")) as NSString
                    
                    if(expiration_time_lbl == "5 seconds"){
                        expiration_lbl.text = "5 sec"
                    }else if(expiration_time_lbl == "10 seconds"){
                        expiration_lbl.text = "10 sec"
                    }else if(expiration_time_lbl == "30 seconds"){
                        expiration_lbl.text = "30 sec"
                    }else if(expiration_time_lbl == "1 minute"){
                        expiration_lbl.text = "1 min"
                    }else if(expiration_time_lbl == "1 hour"){
                        expiration_lbl.text = "1 hr"
                    }else if(expiration_time_lbl == "1 day"){
                        expiration_lbl.text = "1 day"
                    }else if(expiration_time_lbl == "1 week"){
                        expiration_lbl.text = "1 week"
                    }else{
                        expiration_lbl.isHidden = true
                    }
                }
            }
            else
            {
                expiration_lbl.text = "1 hr"
            }
            
        }
    }
    
    func setSecretView(){
        expiration_lbl.layer.masksToBounds = true
        expiration_lbl.layer.cornerRadius = expiration_lbl.layer.frame.width/4
        setExpirationLabel()
        secretButton.setImage(#imageLiteral(resourceName: "spyblack"), for: .normal)
    }
    
    func time(time: String) {
        var timestamp:String = String(Date().ticks)
        var servertimeStr:String = Themes.sharedInstance.getServerTime()
        if(servertimeStr == "")
        {
            servertimeStr = "0"
        }
        
        let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
        timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
        let from = Themes.sharedInstance.Getuser_id()
        let to = opponent_id
        let toDocId = from + "-" + to + "-" + timestamp
        var seconds:String = "0"
        var timer:String = ""
        if(time == "5 seconds" || time == ""){
            Themes.sharedInstance.activityView(View: self.chatTableView)
            timer = "5000"
            seconds = "5"
            
        }else if(time == "10 seconds"){
            Themes.sharedInstance.activityView(View: self.chatTableView)
            timer = "10000"
            seconds = "10"
        }else if(time == "30 seconds"){
            Themes.sharedInstance.activityView(View: self.chatTableView)
            timer = "30000"
            seconds = "30"
            
        }else if(time == "1 minute"){
            Themes.sharedInstance.activityView(View: self.chatTableView)
            timer = "60000"
            seconds = "60"
            
        }else if(time == "1 hour"){
            Themes.sharedInstance.activityView(View: self.chatTableView)
            timer = "3600000"
            seconds = "3600"
            
        }
        else if(time == "1 day"){
            Themes.sharedInstance.activityView(View: self.chatTableView)
            let calcseconds:Int64 = Int64(24 * 3600)
            seconds = "\(calcseconds)"
            timer = "86400000"
            
        }
        else if(time == "1 week"){
            Themes.sharedInstance.activityView(View: self.chatTableView)
            timer = "604800000"
            let calcseconds:Int64 = Int64(24 * 7 *  3600)
            seconds = "\(calcseconds)"
            
        }
        
        
        if(seconds != "0")
        {
            let chatarray:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: to + "-" + from)
            if(!chatarray)
            {
                let User_dict:[AnyHashable: Any] = ["user_common_id": to + "-" + from,"user_to_dp":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_type":Chat_type,"is_archived":"0","conv_id":"","timestamp":timestamp,"opponent_id":to,"is_read":"0","chat_count":"0"]
                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: User_dict as NSDictionary,Entityname: Constant.sharedinstance.Chat_intiated_details)
                
            }
            
            let dic = ["from":from,"to":to,"incognito_timer_mode":time,"payload":time,"chat_type":"secret","type":"13","toDocId":toDocId,"incognito_timer":timer,"id":timestamp]
            SocketIOManager.sharedInstance.changeExpirationTime(param: dic)
            let DBdic = ["user_id":to,"incognito_timer":time,"timestamp":timestamp,"doc_id":toDocId,"expiration_time":time,"user_common_id": to + "-" + from,"expire_time_seconds":seconds] as [String : Any]
            let checkBool:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Secret_Chat, attribute: "doc_id", FetchString: toDocId)
            if(checkBool){
                
                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Secret_Chat, FetchString: to, attribute: "user_id", UpdationElements: DBdic as NSDictionary)
            }else{
                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: DBdic as NSDictionary, Entityname: Constant.sharedinstance.Secret_Chat)
            }
            let Phonenumber:String=Themes.sharedInstance.setPhoneTxt(Themes.sharedInstance.Getuser_id())
            
            let  loaddic = ["type": "13","convId":"","doc_id":Themes.sharedInstance.CheckNullvalue(Passed_value:toDocId
                ),"filesize":"","from":Themes.sharedInstance.CheckNullvalue(Passed_value:from
                ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:to
                ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
                ),"message_status":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
                ),"id":timestamp,"name":"","payload":time,"recordId":"","timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
                ),"thumbnail":"","width":"0.0","height":"0.0","msgId":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
                ),"contactmsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value:Phonenumber
                ),"user_common_id":to + "-" + from,"message_from":"1","chat_type":Chat_type,"info_type":"13","created_by":from,"is_reply":"0","secret_msg_id":"","secret_timestamp":"", "date" : Themes.sharedInstance.getTimeStamp(), "while_blocked" : Themes.sharedInstance.isImBlocked(to) ? "1" : "0"]
            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: loaddic as NSDictionary,Entityname: Constant.sharedinstance.Chat_one_one)
            
            DispatchQueue.main.async {
                self.dealTheFunctionData(loaddic, fromOrdering: false)
            }
        }
        else
        {
            self.view.makeToast("Invalid time")
        }
    }
    
    @IBAction func did_click_expiration(_ sender: UIButton) {
        
        let pickerVC:PickerVC = storyboard?.instantiateViewController(withIdentifier: "PickerVC") as! PickerVC
        pickerVC.pickerDataSource = ["5 seconds","10 seconds","30 seconds","1 minute","1 hour","1 day","1 week"]
        pickerVC.delegate = self
        self.presentView(pickerVC, animated: true)        
    }
    
    func TypingStatus(not:Notification)
    {
        let ResponseDict:NSDictionary = not.object as! NSDictionary
        if(ResponseDict.count > 0)
        {
            let _conv_id = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "convId"))
            let from = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from"))
            let type = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "type"))
            if(from != Themes.sharedInstance.Getuser_id())
            {
                
                if(_conv_id == conv_id)
                {
                    if(!istartTyping)
                    {
                        if(typingTimer != nil)
                        {
                            typingTimer = nil
                            typingTimer?.invalidate()
                        }
                        istartTyping = true
                        if(type == "single")
                        {
                            group_user_lbl.text = "typing..."
                        }
                        else
                        {
                            group_user_lbl.text = Themes.sharedInstance.setNameTxt(from, "single") + " typing..."
                        }
                        typingTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.StopTimer), userInfo: nil, repeats: false)
                    }
                }
            }
        }
    }
    
    func setBackground()
    {
        //        chat background
        let type = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.User_detail, attrib_name: "user_id", fetchString: Themes.sharedInstance.Getuser_id(), returnStr: "wallpaper_type")
        
        let value = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.User_detail, attrib_name: "user_id", fetchString: Themes.sharedInstance.Getuser_id(), returnStr: "wallpaper")
        
        if(type == "image")
        {
            SDImageCache.shared().removeImage(forKey: value, fromDisk: false)
            self.chat_background_imageview.sd_setImage(with: URL(string: value))
            self.chat_background_imageview.backgroundColor = UIColor.clear
        }
        else if (type == "color")
        {
            self.chat_background_imageview.image = nil
            self.chat_background_imageview.backgroundColor = Themes.sharedInstance.colorWithHexString(hex: value)
            
        }
        else if (type == "default")
        {
            self.chat_background_imageview.image = #imageLiteral(resourceName: "chat background")
            self.chat_background_imageview.backgroundColor = UIColor.clear
        }
        else if (type == "no_wallpaper")
        {
            self.chat_background_imageview.image = nil
            self.chat_background_imageview.backgroundColor = Themes.sharedInstance.colorWithHexString(hex: "#ECECEC")
        }
    }
    
    @objc func StopTimer()
    {
        istartTyping = false
        if(typingTimer != nil)
        {
            typingTimer = nil
            typingTimer?.invalidate()
        }
        reloaddata()
    }
    
    func isConnectedToNetwork() -> Bool
    {
        return (UIApplication.shared.delegate as! AppDelegate).IsInternetconnected
    }
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.updateUIatViewWillAppear()
        self.videocall_Btn.isUserInteractionEnabled = true
        self.audiocall_Btn.isUserInteractionEnabled = true
        chat_background_imageview.isHidden = false
        Group_name_Lbl.font = UIFont.boldSystemFont(ofSize: 15.0)
        if Chat_type == "single" {
            group_user_lbl.text = "Tap here for contact info"
        }else{
            group_user_lbl.text = "Tap here for group info"
        }
        self.reloaddata()
    }
    
    func reloaddata()
    {
        let id = Themes.sharedInstance.CheckNullvalue(Passed_value: opponent_id)
        
        Group_name_Lbl.setNameTxt(opponent_id, Chat_type)
        Chat_imageView.setProfilePic(opponent_id, Chat_type)
        
        if(Chat_type == "single" || Chat_type == "secret") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
                
                if Themes.sharedInstance.LastSeenTxt(id) != "" {
                    self.group_user_lbl.text = Themes.sharedInstance.LastSeenTxt(id)
                }else{
                    if self.Chat_type == "single" {
                        self.group_user_lbl.text = "Tap here for contact info"
                    }else{
                        self.group_user_lbl.text = "Tap here for group info"
                    }
                }
                
            }
        }
        else
        {
            let opponentArr = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Group_details, attribute: "id", FetchString: id, SortDescriptor: nil) as! [Group_details]
            var nameArr = [String]()
            _ = opponentArr.map{
                let opponent = $0
                groupUsers = NSKeyedUnarchiver.unarchiveObject(with: opponent.groupUsers as! Data) as! NSArray
                nameArr.removeAll()
                isYou = false
                _ = groupUsers.map {
                    let dict = $0 as! [String : Any]
                    let id = Themes.sharedInstance.CheckNullvalue(Passed_value: dict["id"])
                    var name = ""
                    if(id == Themes.sharedInstance.Getuser_id()) {
                        name = NSLocalizedString("You", comment: "You are")
                        isYou = true
                    }
                    else
                    {
                        name = Themes.sharedInstance.ReturnFavName(opponentDetailsID: id, msginid: Themes.sharedInstance.CheckNullvalue(Passed_value: dict["msisdn"]))
                    }
                    nameArr.append(name)
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
                
                if nameArr.count > 0 {
                    self.group_user_lbl.text = nameArr.joined(separator: ", ")
                }else{
                    if self.Chat_type == "single" {
                        self.group_user_lbl.text = "Tap here for contact info"
                    }else{
                        self.group_user_lbl.text = "Tap here for group info"
                    }
                }
               
            }
        }
        if(!Themes.sharedInstance.contactExist_Fav(opponent_id) && Chat_type != "group") {
            if(self.chatTableView.numberOfSections == 2){
                self.chatTableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .none)
            }
            else
            {
                self.chatTableView.reloadData()
            }
        }
        else
        {
            if(self.chatTableView.numberOfSections == 2){
                self.chatTableView.reloadData()
            }
        }
        if(Chat_type == "group") {
            update_memberView(isYou)
        }
    }
    
    func updateChatViewAtLoad()
    {
        chatTableView.register(UINib(nibName: "ChatInfoCell", bundle: nil), forCellReuseIdentifier: "ChatInfoCell")
        chatTableView.register(UINib(nibName: "UnknownCell", bundle: nil), forCellReuseIdentifier: "UnknownCell")
        chatTableView.register(UINib(nibName: "EncryptionTableViewCell", bundle: nil), forCellReuseIdentifier: "EncryptionTableViewCell")
        

        self.loadBaseViewsAndData();
        SetMenuView()
        right_item.action = #selector(self.ReleaseEditing)
        left_item.action = #selector(self.DoMessageAction)
        center_item.action = #selector(self.DoClearChat)
        HideToolBar()
        
        audiocall_Btn.isUserInteractionEnabled = true
        videocall_Btn.isUserInteractionEnabled = true
        
        audiocall_Btn.isHidden = Chat_type != "single"
        videocall_Btn.isHidden = Chat_type != "single"
        
        secretButton.isHidden = Chat_type != "secret"
        
        secret_view.isHidden = Chat_type != "secret"

        SocketIOManager.sharedInstance.lastSeen(from: Themes.sharedInstance.Getuser_id(), to: opponent_id)
    }
    
    func updateUIatViewWillAppear()
    {
        istartTyping = false
    }
    
    
    func setBool(view: Bool) {
        appear = view
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        self.view.endEditing(true)
        typingTimer = nil
        typingTimer?.invalidate()
        chat_background_imageview.isHidden = true
        PausePlayingAudioIfAny()
        self.pauseGif()
    }
    
    func share(rec: NSMutableArray) {
        
        let from = Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
        let to = Themes.sharedInstance.CheckNullvalue(Passed_value: opponent_id)
        var user_common_id = to + "-" + from
        let checkBool:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Secret_Chat, attribute: "user_common_id", FetchString: user_common_id)
        if(!checkBool && Chat_type == "secret")
        {
            self.time(time:"1 hour")
        }
        var secret_msg_id:String = ""
        if(Chat_type == "secret"){
            user_common_id = Themes.sharedInstance.CheckNullvalue(Passed_value: to + "-" + from)
            
            
            var checksecretmessagecount:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Secret_Chat, attribute: "user_common_id", FetchString: user_common_id, SortDescriptor: "timestamp") as! NSArray
            checksecretmessagecount = checksecretmessagecount.reversed() as NSArray
            if(checksecretmessagecount.count > 0)
            {
                
                secret_msg_id = Themes.sharedInstance.CheckNullvalue(Passed_value: (checksecretmessagecount[0] as! NSManagedObject).value(forKey: "doc_id"))
            }
        }else{
            user_common_id = Themes.sharedInstance.CheckNullvalue(Passed_value: from + "-" + to)
        }
        _ = rec.map {
            let record:FavRecord = $0 as! FavRecord
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
            
            var toDocId:String="\(from)-\(to)-\(timestamp)"
            
            if(Chat_type == "group")
            {
                toDocId="\(from)-\(to)-g-\(timestamp)"
            }
            
            var dic:[AnyHashable: Any]!
            
            getContact_details(phone:record.msisdn)
            
            if(contact_details == "")
            {
                getContact_details(phone:record.phnumber)
            }
            else
            {
                record.phnumber = record.msisdn
            }
            
            dic = ["type": "5","convId":"","doc_id":Themes.sharedInstance.CheckNullvalue(Passed_value:toDocId
                ),"filesize":"","from":Themes.sharedInstance.CheckNullvalue(Passed_value:from
                ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:to
                ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
                ),"message_status":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
                ),"id":timestamp,"name":Themes.sharedInstance.CheckNullvalue(Passed_value:Name
                ),"payload":Themes.sharedInstance.CheckNullvalue(Passed_value:record.name),"recordId":"","timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp),"thumbnail":"","width":"0.0","height":"0.0","msgId":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
                ),"contactmsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value:Phonenumber
                ),"user_common_id":Themes.sharedInstance.CheckNullvalue(Passed_value:user_common_id
                ),"message_from":"1","chat_type":Chat_type,"info_type":"0","created_by":from,"contact_profile":Themes.sharedInstance.CheckNullvalue(Passed_value:record.profilepic),"contact_phone":Themes.sharedInstance.CheckNullvalue(Passed_value:record.phnumber),"contact_id":Themes.sharedInstance.CheckNullvalue(Passed_value:record.id),"contact_name":Themes.sharedInstance.CheckNullvalue(Passed_value:record.name),"contact_details":Themes.sharedInstance.CheckNullvalue(Passed_value:contact_details),"secret_msg_id":secret_msg_id,"secret_timestamp":"", "date" : Themes.sharedInstance.getTimeStamp(), "while_blocked" : Themes.sharedInstance.isImBlocked(to) ? "1" : "0"]
            //addRefreshViews()
            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: dic as NSDictionary,Entityname: Constant.sharedinstance.Chat_one_one)

            let contact_dic:[AnyHashable: Any] = ["doc_id":Themes.sharedInstance.CheckNullvalue(Passed_value:toDocId
                ),"contact_profile":Themes.sharedInstance.CheckNullvalue(Passed_value:record.profilepic),"contact_phone":Themes.sharedInstance.CheckNullvalue(Passed_value:record.phnumber),"contact_id":Themes.sharedInstance.CheckNullvalue(Passed_value:record.id),"contact_name":Themes.sharedInstance.CheckNullvalue(Passed_value:record.name),"contact_details":Themes.sharedInstance.CheckNullvalue(Passed_value:contact_details)]
            
            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: contact_dic as NSDictionary,Entityname: Constant.sharedinstance.Contact_details)
            
            if(appear)
            {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.0) {
                    self.dealTheFunctionData(dic as [AnyHashable : Any], fromOrdering: false)
                }
            }
            
            if(Chat_type == "secret"){
                let chatarray:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: to + "-" + from)
                if(!chatarray)
                {
                    let User_dict:[AnyHashable: Any] = ["user_common_id": to + "-" + from,"user_to_dp":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_type":Chat_type,"is_archived":"0","conv_id":"","timestamp":timestamp,"opponent_id":to,"is_read":"0","chat_count":"0"]
                    DatabaseHandler.sharedInstance.InserttoDatabase(Dict: User_dict as NSDictionary,Entityname: Constant.sharedinstance.Chat_intiated_details)
                    
                }
                else
                {
                    let User_dict:[AnyHashable: Any]=["timestamp":timestamp,"is_archived":"0","is_read":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_count":"0"]
                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: to + "-" + from , attribute: "user_common_id", UpdationElements: User_dict as NSDictionary?)
                }
            }else{
                let chatarray:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: from + "-" + to)
                if(!chatarray)
                {
                    let User_dict:[AnyHashable: Any] = ["user_common_id": from + "-" + to,"user_to_dp":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_type":Chat_type,"is_archived":"0","conv_id":"","timestamp":timestamp,"opponent_id":to,"is_read":"0","chat_count":"0"]
                    DatabaseHandler.sharedInstance.InserttoDatabase(Dict: User_dict as NSDictionary,Entityname: Constant.sharedinstance.Chat_intiated_details)
                    
                }
                else
                {
                    let User_dict:[AnyHashable: Any]=["timestamp":timestamp,"is_archived":"0","is_read":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_count":"0"]
                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: from + "-" + to , attribute: "user_common_id", UpdationElements: User_dict as NSDictionary?)
                }
            }
            
            let details:NSMutableDictionary = ["contact_profile":Themes.sharedInstance.CheckNullvalue(Passed_value:record.profilepic),"contact_phone":Themes.sharedInstance.CheckNullvalue(Passed_value:record.phnumber),"id":Themes.sharedInstance.CheckNullvalue(Passed_value:record.id),"contactDetails":Themes.sharedInstance.CheckNullvalue(Passed_value:contact_details)]
            
            if(self.Chat_type == "single" || self.Chat_type == "secret")
            {
                //createdTomsisdn = phonenumber
                //contact_name = id
                
                if let json = try?JSONSerialization.data(withJSONObject: details, options: []) {
                    // here `json` is your JSON data
                    if String(data: json, encoding: String.Encoding.utf8) != nil {
                        // here `content` is the JSON data decoded as a String
                        
                        if(self.Chat_type == "single"){
                            
                            let Dict:Dictionary = ["from":Themes.sharedInstance.Getuser_id(),"to":to,"payload":"","id":EncryptionHandler.sharedInstance.encryptmessage(str:"\(timestamp)",toid:to, chat_type: self.Chat_type),"type":"5","toDocId":EncryptionHandler.sharedInstance.encryptmessage(str:"\(toDocId)",toid:to, chat_type: self.Chat_type),"contact_name":Themes.sharedInstance.CheckNullvalue(Passed_value:record.name),"createdTomsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value:record.phnumber),"contactDetails":EncryptionHandler.sharedInstance.encryptmessage(str:  contact_details,toid:to, chat_type: self.Chat_type),"createdTo":Themes.sharedInstance.CheckNullvalue(Passed_value:record.id)] as [String : Any]
                            
                            SocketIOManager.sharedInstance.EmitMessage(param: Dict)
                        }else{
                            
                            let Dict:Dictionary = ["from":Themes.sharedInstance.Getuser_id(),"to":to,"payload":"","id":EncryptionHandler.sharedInstance.encryptmessage(str:"\(timestamp)",toid:to, chat_type: self.Chat_type),"type":"5","toDocId":EncryptionHandler.sharedInstance.encryptmessage(str:"\(toDocId)",toid:to, chat_type: self.Chat_type),"contact_name":Themes.sharedInstance.CheckNullvalue(Passed_value:record.name),"createdTomsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value:record.phnumber),"contactDetails":EncryptionHandler.sharedInstance.encryptmessage(str:  contact_details,toid:to, chat_type: self.Chat_type),"createdTo":Themes.sharedInstance.CheckNullvalue(Passed_value:record.id),"chat_type":"secret"] as [String : Any]
                            
                            SocketIOManager.sharedInstance.EmitMessage(param: Dict)
                        }
                        
                    }
                }
            }
            else
            {
                let displayName = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Group_details, attrib_name: "id", fetchString: to, returnStr: "displayName")
                
                if let json = try?JSONSerialization.data(withJSONObject: details, options: []) {
                    // here `json` is your JSON data
                    if String(data: json, encoding: String.Encoding.utf8) != nil {
                        // here `content` is the JSON data decoded as a String
                        
                        let Dict:Dictionary = ["from":Themes.sharedInstance.Getuser_id(),"to":to,"payload":"","id":EncryptionHandler.sharedInstance.encryptmessage(str:"\(timestamp)",toid:to, chat_type: self.Chat_type),"type":"5","toDocId":EncryptionHandler.sharedInstance.encryptmessage(str:toDocId,toid:to, chat_type: self.Chat_type),"contact_name":Themes.sharedInstance.CheckNullvalue(Passed_value:record.name),"createdTomsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value:record.phnumber),"contactDetails":EncryptionHandler.sharedInstance.encryptmessage(str:  contact_details,toid:to, chat_type: self.Chat_type),"createdTo":Themes.sharedInstance.CheckNullvalue(Passed_value:record.id),"chat_type":"group","groupType":"9","userName":displayName,"convId":to] as [String : Any]
                        SocketIOManager.sharedInstance.Groupevent(param: Dict)
                    }
                }
                
            }
            
            funcView.changeSendBtn(withPhoto: true)
        }
    }
    @objc func ReleaseEditing()
    {
        isBeginEditing = false
        HideToolBar()
    }
    
    fileprivate func moveToShareContactVC(_ Indexpath: [IndexPath]) {
        let Chat_arr:NSMutableArray = NSMutableArray()
        _ = Indexpath.map {
            let indexpath = $0
            let chatobj:UUMessageFrame = self.chatModel.dataSource[indexpath.row] as! UUMessageFrame
            Chat_arr.add(chatobj)
        }
        if(Chat_arr.count > 0)
        {
            let selectShareVC = storyboard?.instantiateViewController(withIdentifier:"SelectShareContactViewController" ) as! SelectShareContactViewController
            selectShareVC.messageDatasourceArr =  Chat_arr
            selectShareVC.isFromForward = true
            self.pushView(selectShareVC, animated: true)
        }
    }
    
    @objc func DoClearChat()
    {
        if self.center_item.title?.length ?? 0 >= 2 {
        if let indexPaths = chatTableView.indexPathsForSelectedRows, indexPaths.count != 0
        {
            let deleteActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let deleteForEveryOneAction = UIAlertAction(title: NSLocalizedString("Clear for Everyone", comment:"Clear for Everyone") , style: .destructive) { (delete) in
                
                let lastobject:UUMessageFrame = self.chatModel.dataSource.lastObject as! UUMessageFrame
//                print(lastobject.message.conv_id)
//                print(lastobject.message.timestamp)
                
                var timestamp  = ""
                if lastobject.message.timestamp != "" {
                    timestamp = lastobject.message.timestamp
                }else{
                    timestamp = "0"
                }
                Themes.sharedInstance.showDeleteView(self.view, false)
                Themes.sharedInstance.ClearChat("1", "", true,timestamp)
                self.HideToolBar()
            }
            let deleteForMe = UIAlertAction(title: NSLocalizedString("Clear for Me",comment:"Clear for Me") , style: .destructive) { [unowned self] (delete) in
                
                let lastobject:UUMessageFrame = self.chatModel.dataSource.lastObject as! UUMessageFrame
//                print(lastobject.message.conv_id)
//                print(lastobject.message.timestamp)
                var timestamp  = ""
                if lastobject.message.timestamp != "" {
                    timestamp = lastobject.message.timestamp
                }else{
                    timestamp = "0"
                }
                Themes.sharedInstance.showDeleteView(self.view, false)
                Themes.sharedInstance.ClearChat("1", "", false,timestamp)
                self.HideToolBar()
            }
            
            let Cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment:"Cancel" ) , style: .cancel) { (cancel) in
            }
            deleteActionSheet.addAction(deleteForEveryOneAction)
            
            deleteActionSheet.addAction(deleteForMe)
            deleteActionSheet.addAction(Cancel)
            self.presentView(deleteActionSheet, animated: true, completion: nil)
        }
        }
    }
    
    @objc func DoMessageAction()
    {
        if(isForwardAction)
        {
            if let Indexpath = chatTableView.indexPathsForSelectedRows, Indexpath.count != 0 {
                moveToShareContactVC(Indexpath)
            }
            self.HideToolBar()
        }
        else
        {
            if let indexPaths = chatTableView.indexPathsForSelectedRows, indexPaths.count != 0
            {
                let deleteActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let deleteForEveryOneAction = UIAlertAction(title: NSLocalizedString("Delete for Everyone", comment:"Delete for Everyone" ) , style: .destructive) { (delete) in
                    let Indexpath:[IndexPath] = self.chatTableView.indexPathsForSelectedRows!
                    _ = Indexpath.map {
                        
                        let indexpath = $0
                        
                        self.tableView(self.chatTableView, didDeselectRowAt: indexpath)
                        
                        
                        let chatobj:UUMessageFrame = self.chatModel.dataSource[indexpath.row] as! UUMessageFrame
                        
                        if($0 == Indexpath.last)
                        {
                            self.RemovechatForEveryOne(type: self.Chat_type, convId: chatobj.message.conv_id, status: "1", recordId: chatobj.message.recordId, last_msg: "1")
                        }
                        else
                        {
                            self.RemovechatForEveryOne(type: self.Chat_type, convId: chatobj.message.conv_id, status: "1", recordId: chatobj.message.recordId, last_msg: "0")
                            
                        }
                    }
                    self.HideToolBar()
                }
                let deleteForMe = UIAlertAction(title:NSLocalizedString("Delete for Me", comment:"Delete for Me") , style: .destructive) { [unowned self] (delete) in
                    var Indexpath:[IndexPath] = self.chatTableView.indexPathsForSelectedRows!
                    _ = Indexpath.map {
                        let indexpath = $0
                        self.tableView(self.chatTableView, didDeselectRowAt: indexpath)
                        
                        
                        let chatobj:UUMessageFrame = self.chatModel.dataSource[indexpath.row] as! UUMessageFrame
                        
                        if($0 == Indexpath.last)
                        {
                            self.Removechat(type: self.Chat_type, convId: chatobj.message.conv_id, status: "1", recordId: chatobj.message.recordId, last_msg: "1")
                        }
                        else
                            
                        {
                            self.Removechat(type: self.Chat_type, convId: chatobj.message.conv_id, status: "1", recordId: chatobj.message.recordId, last_msg: "0")
                            
                        }
                        
                        if(chatobj.message.message_type == "0" || chatobj.message.message_type == "4" || chatobj.message.message_type == "5" || chatobj.message.message_type == "14" || chatobj.message.message_type == "11")
                        {
                            let p1 = NSPredicate(format: "id = %@", chatobj.message._id)
                            DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Chat_one_one, Predicatefromat: p1, Deletestring: "id", AttributeName: "id")
                            
                        }
                        else
                            
                        {
                            let p1 = NSPredicate(format: "id = %@", chatobj.message._id)
                            DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Chat_one_one, Predicatefromat: p1, Deletestring: "id", AttributeName: "id")
                            
                            let predic = NSPredicate(format: "upload_data_id == %@",chatobj.message.thumbnail)
                            
                            let uploadDetailArr = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Upload_Details, attribute: "upload_data_id", FetchString: chatobj.message.thumbnail, SortDescriptor: nil) as! [NSManagedObject]
                            _ = uploadDetailArr.map {
                                let uploadDict = $0
                                
                                let upload_Path:String = Themes.sharedInstance.CheckNullvalue(Passed_value: uploadDict.value(forKey: "upload_Path"))
                                Filemanager.sharedinstance.DeleteFile(foldername: upload_Path)
                            }
                            DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Upload_Details, Predicatefromat: predic, Deletestring: "chatobj.message.thumbnail", AttributeName: "id")
                        }
                    }
                    
                    Indexpath = (self.chatTableView.indexPathsForSelectedRows!).sorted {$0.row < $1.row}
                    let indexset = NSMutableIndexSet()
                    _ = Indexpath.map {
                        indexset.add($0.row)
                    }
                    self.chatModel.dataSource.removeObjects(at: indexset as IndexSet)
                    self.chatTableView.deleteRows(at: Indexpath, with: .fade)
                    self.chatTableView.reloadData()
                    self.HideToolBar()
                }
                
                let Cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment:"Cancel") , style: .cancel) { (cancel) in
                }
                var Indexpath:[IndexPath] = self.chatTableView.indexPathsForSelectedRows!
                Indexpath = (self.chatTableView.indexPathsForSelectedRows!).sorted {$0.row < $1.row}
                let indexset = NSMutableIndexSet()
                _ = Indexpath.map {
                    indexset.add($0.row)
                }
                var ShowEveryOne = true
                indexset.forEach({ i in
                    
                    let chatobj:UUMessageFrame = self.chatModel.dataSource[i] as! UUMessageFrame
                    if(chatobj.message.from == MessageFrom(rawValue: 0) || chatobj.message.is_deleted == "1" || chatobj.message.message_status == "0")
                    {
                        ShowEveryOne = false
                    }
                })
                var isLesser = true
                indexset.forEach({ i in
                    
                    let chatobj:UUMessageFrame = self.chatModel.dataSource[i] as! UUMessageFrame
                    let lesser = Themes.sharedInstance.checkTimeStampMorethan10Mins(timestamp: chatobj.message.timestamp!)
                    
                    if(!lesser)
                    {
                        isLesser = false
                    }
                })
                
                if(ShowEveryOne && isLesser)
                {
                    deleteActionSheet.addAction(deleteForEveryOneAction)
                }
                
                deleteActionSheet.addAction(deleteForMe)
                deleteActionSheet.addAction(Cancel)
                self.presentView(deleteActionSheet, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func DidclickVideo(_ sender: Any)
    {
        self.view.endEditing(true)
        guard !Themes.sharedInstance.checkBlock(id: opponent_id) else
        {
            Themes.sharedInstance.showBlockalert(id: opponent_id)
            return
        }
        
        self.audiocall_Btn.isUserInteractionEnabled = false
        self.videocall_Btn.isUserInteractionEnabled = false
        
        if(SocketIOManager.sharedInstance.socket.status == .connected)
        {
            var timestamp:String =  String(Date().ticks)
            var servertimeStr:String = Themes.sharedInstance.getServerTime()
            
            if(servertimeStr == "")
            {
                servertimeStr = "0"
            }
            let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
            timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
            let docID = Themes.sharedInstance.Getuser_id() + "-" + opponent_id + "-" + timestamp
            let param:NSDictionary = ["from":Themes.sharedInstance.Getuser_id(),"to":Themes.sharedInstance.CheckNullvalue(Passed_value: opponent_id),"type":1,"id":Int64(timestamp)!,"toDocId":docID, "roomid" : timestamp]
            SocketIOManager.sharedInstance.emitCallDetail(Param: param as! [String : Any])
            AppDelegate.sharedInstance.openCallPage(type: "1", roomid: timestamp, id: opponent_id)
        }
        else
        {
            self.view.makeToast(message: Constant.sharedinstance.ErrorMessage, duration: 3, position: HRToastActivityPositionDefault)
            self.audiocall_Btn.isUserInteractionEnabled = true
            self.videocall_Btn.isUserInteractionEnabled = true
        }
        self.perform(#selector(self.updateCallbtn), with: nil, afterDelay: 3.0)
    }
    
    @IBAction func DidclickAudio(_ sender: Any)
    {
        self.view.endEditing(true)
        guard !Themes.sharedInstance.checkBlock(id: opponent_id) else
        {
            Themes.sharedInstance.showBlockalert(id: opponent_id)
            return
        }
        
        self.audiocall_Btn.isUserInteractionEnabled = false
        self.videocall_Btn.isUserInteractionEnabled = false
        
        if(SocketIOManager.sharedInstance.socket.status == .connected)
        {
            var timestamp:String =  String(Date().ticks)
            var servertimeStr:String = Themes.sharedInstance.getServerTime()
            
            if(servertimeStr == "")
            {
                servertimeStr = "0"
            }
            let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
            timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
            let docID = Themes.sharedInstance.Getuser_id() + "-" + opponent_id + "-" + timestamp
            let param:NSDictionary = ["from":Themes.sharedInstance.Getuser_id(),"to":Themes.sharedInstance.CheckNullvalue(Passed_value: opponent_id),"type":0,"id":Int64(timestamp)!,"toDocId":docID, "roomid" : timestamp]
            SocketIOManager.sharedInstance.emitCallDetail(Param: param as! [String : Any])
            AppDelegate.sharedInstance.openCallPage(type: "0", roomid: timestamp, id: opponent_id)
        }
        else
        {
            self.view.makeToast(message: Constant.sharedinstance.ErrorMessage, duration: 3, position: HRToastActivityPositionDefault)
            self.audiocall_Btn.isUserInteractionEnabled = true
            self.videocall_Btn.isUserInteractionEnabled = true
        }
        self.perform(#selector(self.updateCallbtn), with: nil, afterDelay: 3.0)
    }
    
    @objc func updateCallbtn()
    {
        self.audiocall_Btn.isUserInteractionEnabled = true
        self.videocall_Btn.isUserInteractionEnabled = true
    }
    
    // MARK: -  ReplyView Delegate
    func PassCloseAction() {
        ReplyView.isHidden = true
        isShowBottomView = false
        ReplyView.isHidden = true
        isReplyMessage = false
        if(!isKeyboardShown)
        {
            self.bottomConstraint.constant = 50
        }
        else
        {
            IFView.resign_FirtResponder()
        }
    }
    
    
    func ShowReplyView(_ messageFrame: UUMessageFrame){
        
        isShowBottomView = true
        isReplyMessage = true
        ReplyView.isHidden = false
        
        let message_type:String = Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message.message_type)
        var payload = Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message.payload)
        
        let arr = Themes.sharedInstance.getID_Range_Payload_Name(message: payload)
        
        let ReplyrangeArr = arr[1] as! [NSRange]
        
        payload = arr[2] as! String
        
        if(messageFrame.message.from == MessageFrom(rawValue: 1))
        {
            ReplyView.name_Lbl.text = NSLocalizedString("You", comment: "You are")
            ReplyView.name_Lbl.textColor = UIColor(red:23/255, green:109/255, blue:69/255, alpha:1.0)
        }
        else
        {
            ReplyView.name_Lbl.setNameTxt(Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message.user_from), "single")
            ReplyView.name_Lbl.textColor = UIColor.orange
        }
        
        if(message_type == "1")
        {
            ReplyView.thumbnail_Image.isHidden = false
            
            if(ReplyView.name_Lbl.text == NSLocalizedString("You", comment: "You are"))
            {
                UploadHandler.Sharedinstance.loadMyImage(messageFrame: messageFrame, imageView: ReplyView.thumbnail_Image, isLoaderShow: false)
            }
            else
            {
                UploadHandler.Sharedinstance.loadFriendsImage(messageFrame: messageFrame, imageView: ReplyView.thumbnail_Image, isLoaderShow: false)
            }
            ReplyView.message_Lbl.text = "📷 Photo"
        }
        else if(message_type == "2")
        {
            ReplyView.thumbnail_Image.isHidden = false
            if(ReplyView.name_Lbl.text == NSLocalizedString("You", comment: "You are"))
            {
                UploadHandler.Sharedinstance.loadVideoThumbnailOfMe(messageFrame: messageFrame, ImageView: ReplyView.thumbnail_Image)
            }
            else
            {
                UploadHandler.Sharedinstance.loadVideoThumbnailOfOthers(messageFrame: messageFrame, ImageView: ReplyView.thumbnail_Image)
            }
            ReplyView.message_Lbl.text = "📹 Video"
        }
        else if(message_type == "3")
        {
            ReplyView.thumbnail_Image.isHidden = true
            ReplyView.message_Lbl.text = "🎵 Audio"
            
        }
        else if(message_type == "5")
        {
            ReplyView.thumbnail_Image.isHidden = true
            ReplyView.message_Lbl.text = "📝 \(Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message.contact_name))"
            
        }
        else if(message_type == "6" || message_type == "20")
        {
            ReplyView.thumbnail_Image.isHidden = true
            ReplyView.message_Lbl.text = "📄 Document"
            
        }
        else if(message_type == "14")
        {
            ReplyView.thumbnail_Image.isHidden = true
            ReplyView.message_Lbl.text = payload
            
        }
        else if(message_type == "4"){
            ReplyView.thumbnail_Image.isHidden = true
            ReplyView.message_Lbl.text = payload
            
        }
        else if(message_type == "0")
        {
            ReplyView.thumbnail_Image.isHidden = true
            ReplyView.message_Lbl.text = payload
            
        }else if(message_type == "7")
        {
            ReplyView.thumbnail_Image.isHidden = true
            ReplyView.message_Lbl.text = payload
        }
        
        if(payload.length > 0)
        {
            let attributed = NSMutableAttributedString(string: ReplyView.message_Lbl.text!)
            
            attributed.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15.0)], range: NSMakeRange(0, (ReplyView.message_Lbl.text?.length)!))
            _ = ReplyrangeArr.map {
                attributed.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15.0)], range: $0)
            }
            if(ReplyrangeArr.count > 0)
            {
                ReplyView.message_Lbl.attributedText = attributed
            }
        }
        
        ReplyMessageRecord = messageFrame
        
        let previousReplyH = ReplyView.message_Lbl.frame.size.height
        
        var height = ReplyView.message_Lbl.text?.height(withConstrainedWidth: ReplyView.message_Lbl.frame.size.width, font: UIFont.boldSystemFont(ofSize: 15.0))
        
        IFView.become_FirtResponder()
        if(Double(height!) > Double(previousReplyH))
        {
            if(Double(height!) > 62.0){
                height = 62
            }
            var rect = ReplyView.message_Lbl.frame
            rect.size.height = height!
            rect.size.width = rect.size.width - 10
            ReplyView.message_Lbl.frame = rect
            
            rect = ReplyView.frame
            rect.size.height = ReplyView.frame.size.height + (height! - previousReplyH)
            rect.origin.y = ReplyView.frame.origin.y - (height! - previousReplyH)
            ReplyView.frame = rect
            self.view.layoutIfNeeded()
        }
        else
        {
            var rect = ReplyView.message_Lbl.frame
            rect.size.height = height!
            ReplyView.message_Lbl.frame = rect
            ReplyView.frame = CGRect(x: 0, y: IFView.frame.origin.y - 50 , width: ReplyView.frame.size.width, height: 50)
            self.view.layoutIfNeeded()
        }
    }
    
    func Removechat(type:String,convId:String,status:String,recordId:String,last_msg:String)
    {
        let param:NSDictionary = ["from":Themes.sharedInstance.Getuser_id(),"convId":convId,"status":status,"recordId":recordId,"last_msg":last_msg, "type" : type]
        SocketIOManager.sharedInstance.EmitDeletedetails(Dict: param)
    }
    
    func RemovechatForEveryOne(type:String,convId:String,status:String,recordId:String,last_msg:String)
    {
        let param:NSDictionary = ["from":Themes.sharedInstance.Getuser_id(),"convId":convId,"recordId":recordId, "type" : type]
        SocketIOManager.sharedInstance.EmitDeletedetailsForEveryone(Dict: param)
    }
    
    func ReloadLoaderView(_ notify: Notification)
    {
        DispatchQueue.main.async {
            if(self.isModal()  || AppDelegate.sharedInstance.isVideoViewPresented)
            {
                if let thumbnail_id = notify.object as? String {
                    let messageFrame = (self.chatModel.dataSource as! [UUMessageFrame]).filter({$0.message.thumbnail  == thumbnail_id}).first
                    if(messageFrame != nil)
                    {
                        let index = self.chatModel.dataSource.index(of: messageFrame!)
                        let indexPath = IndexPath(row: index, section: 0)
                        
                        let upload_status = notify.userInfo?["upload_status"] as? String
                        if(upload_status! == "1")
                        {
                            let Status = notify.userInfo?["status"] as? String
                            if(Status! == "0")
                            {
                                let total_byte_count = notify.userInfo?["total_byte_count"] as? String
                                let upload_byte_count = notify.userInfo?["upload_byte_count"] as? String
                                
                                if(messageFrame?.message.type == .UUMessageTypeDocument)
                                {
                                    let trackCell = self.chatTableView.cellForRow(at: indexPath) as? DocTableViewCell
                                    let precentage:Float = Float(((100.0*Double(upload_byte_count!)!)/Double(total_byte_count!)!)/100.0);
                                    trackCell?.isDownloadInProgress(.running, precentage)
                                }
                                else if(messageFrame?.message.type == .UUMessageTypeVoice)
                                {
                                    let trackCell = self.chatTableView.cellForRow(at: indexPath) as? AudioTableViewCell
                                    let precentage:Float = Float(((100.0*Double(upload_byte_count!)!)/Double(total_byte_count!)!)/100.0);
                                    trackCell?.isDownloadInProgress(.running, precentage)
                                }
                                else
                                {
                                    let trackCell = self.chatTableView.cellForRow(at: indexPath) as? CustomTableViewCell
                                    trackCell?.SetLoader_data(messageFrame, total_byte_count!, upload_byte_count!)
                                }
                            }
                            else if(Status! == "1")
                            {
                                DispatchQueue.main.async {
                                    self.chatTableView.reloadRows(at: [indexPath], with: .none)
                                }
                            }
                        }
                        else
                        {
                            DispatchQueue.main.async {
                                self.chatTableView.reloadRows(at: [indexPath], with: .none)
                            }
                        }
                    }
                }
            }
        }
    }

    override func viewDidLayoutSubviews() {
        chatTableView.backgroundColor = UIColor.clear
        Chat_imageView.clipsToBounds=true
        bottomnavigateView.layer.cornerRadius=4.0
        bottomnavigateView.clipsToBounds = true
        let gesturerecogniser:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tableViewScrollToBottom))
        gesturerecogniser.numberOfTapsRequired = 1
        bottomnavigateView.addGestureRecognizer(gesturerecogniser)
    }
    //tableView Scroll to bottom
    func tableViewScrollToRow(row:Int){
        DispatchQueue.main.async {
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            self.chatTableView.scrollToRow(at: IndexPath(row: row, section: 0), at: .bottom, animated: false)
            self.chatTableView.isHidden = false
        }
    }
    @objc func tableViewScrollToBottom() {
        
        if self.chatModel.dataSource.count == 0 ||  self.chatModel.dataSource.count == 1{
            return
        }
        
        let indexPath = IndexPath(row: self.chatTableView.numberOfRows(inSection: 0)-1, section: 0)
        self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
    }
    
    func Replacespecifieditem(_ MessageStatus: String,_ recordId: String,_ convId: String, index:Int)
    {
        var messageFrame = UUMessageFrame()
        
        if(index <= chatModel.dataSource.count - 1)
        {
            let PreviousmessageFrame:UUMessageFrame = self.chatModel.dataSource[index] as! UUMessageFrame
            messageFrame = PreviousmessageFrame
            messageFrame.message.message_status = MessageStatus
            if(recordId != "")
            {
                messageFrame.message.recordId = recordId
            }
            if(convId != "")
            {
                messageFrame.message.conv_id = convId
            }
            
            
        }
        self.chatModel.dataSource.replaceObject(at: index, with: messageFrame)
        
        
    }
    
    func starMessageUpdate(_ notify: Notification)
    {
        let ResponseDict:NSDictionary = notify.object  as! NSDictionary
        
        let doc_id = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id"))
        let messageFrame = (chatModel.dataSource as! [UUMessageFrame]).filter({$0.message.doc_id  == doc_id}).first
        if(messageFrame != nil)
        {
            messageFrame?.message.isStar = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "status"))
            let index = chatModel.dataSource.index(of: messageFrame!)
            let indexpath:IndexPath=IndexPath(row: index, section: 0)
            DispatchQueue.main.async{
                self.chatTableView.reloadRows(at: [indexpath], with: .none)
            }
            
        }
    }
    
    func sendMessage(_ notify : Notification) {
        if(self.isModal()  || AppDelegate.sharedInstance.isVideoViewPresented)
        {
            if let chat_type = notify.userInfo?["chat_type"] as? String {
                let ResponseDict:NSDictionary = notify.object  as! NSDictionary
                if(ResponseDict.count > 0)
                {
                    let to = Themes.sharedInstance.CheckNullvalue(Passed_value: opponent_id)
                    
                    var User_chat_id = Themes.sharedInstance.Getuser_id() + "-" + to
                    if(Chat_type == "secret")
                    {
                        User_chat_id = to + "-" + Themes.sharedInstance.Getuser_id()
                    }
                    var commonId:String = ""
                    var info_type:String = "0"
                    let _type:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "type"))
                    
                    if(_type == "71")
                    {
                        info_type = "71"
                    }
                    if(chat_type == "single" || chat_type == "messagestatus" || chat_type == "starredstatus" || chat_type == "secret")
                    {
                        let chat_type_frommsg:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "secret_type"));
                        
                        let to_id:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "to"));
                        if(chat_type_frommsg == "yes")
                        {
                            commonId = "\(to_id)-\(Themes.sharedInstance.Getuser_id())"
                            
                        }
                        else
                        {
                            commonId = "\(Themes.sharedInstance.Getuser_id())-\(to_id)"
                        }
                    }
                    else if(chat_type == "groupmessagestatus" || chat_type == "group")
                    {
                        
                        let groupId:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "groupId"));
                        if(groupId == "")
                        {
                            let to_id:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "to"));
                            commonId = "\(Themes.sharedInstance.Getuser_id())-\(to_id)"
                            if(to_id == ""){
                                commonId = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "user_common_id"));
                            }
                        }
                        else
                        {
                            commonId = "\(Themes.sharedInstance.Getuser_id())-\(groupId)"
                            
                        }
                    }
                    if(User_chat_id == commonId)
                    {
                        if(chat_type == "single" || chat_type == "secret")
                        {
                            var ChatInterlinkID:String=String()
                            let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from"));
                            let to:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "to"));
                            var message_from:String=""
                            let timestamp:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "timestamp"));
                            
                            if(from == Themes.sharedInstance.Getuser_id())
                            {
                                ChatInterlinkID=to;
                                message_from="1";
                            }
                            else
                            {
                                message_from="0";
                            }
                            if(to == Themes.sharedInstance.Getuser_id())
                            {
                                ChatInterlinkID=from;
                            }
                            var ThumbnailID:String = ""
                            var type:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "type"))
                            if(type == "20")
                            {
                                type = "6"
                            }
                            
                            if(type == "13"){
                                info_type = "13"
                                Themes.sharedInstance.RemoveactivityView(View: self.chatTableView)
                                setExpirationLabel()
                            }
                            
                            if(type == "1" || type == "2" || type == "3" || type == "6")
                            {
                                ThumbnailID = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "doc_id"))
                            }
                            else
                            {
                                ThumbnailID = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "thumbnail"))
                            }
                            
                            var title:String = String()
                            var image_url:String = String()
                            var url_str:String = String()
                            var desc:String = String()
                            
                            var contact_id:String = ""
                            var contact_profile:String = ""
                            var contact_name:String = ""
                            var contact_phone:String = ""
                            var contact_details:String = ""
                            
                            var Latitude:String = String()
                            var longitude:String = String()
                            var title_place:String = String()
                            var Stitle_place:String = String()
                            var image_link:String = String()
                            
                            var docPageCount:String = ""
                            var docName:String = ""
                            var docType:String = ""
                            
                            let FetchDocumentDetails = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Upload_Details, attribute: "upload_data_id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id")), SortDescriptor: nil) as! [Upload_Details]
                            if(FetchDocumentDetails.count > 0)
                            {
                                _ = FetchDocumentDetails.map {
                                    let FetchdocumentRecord = $0
                                    docPageCount = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchdocumentRecord.doc_pagecount)
                                    docName =  Themes.sharedInstance.CheckNullvalue(Passed_value: FetchdocumentRecord.doc_name)
                                    docType = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchdocumentRecord.doc_type)
                                }
                            }
                            
                            let FetchLocationDetails = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Location_details, attribute: "doc_id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id")), SortDescriptor: nil) as! [NSManagedObject]
                            if(FetchLocationDetails.count > 0)
                            {
                                _ = FetchLocationDetails.map {
                                    let FetchLocationRecord = $0
                                    
                                    Latitude = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchLocationRecord.value(forKey: "lat"))
                                    longitude = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchLocationRecord.value(forKey: "long"))
                                    title_place   = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchLocationRecord.value(forKey: "title"))
                                    Stitle_place = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchLocationRecord.value(forKey: "stitle"))
                                    image_link = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchLocationRecord.value(forKey: "image_link"))
                                    
                                }
                            }
                            
                            let FetchLinkDetails = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Link_details, attribute: "doc_id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id")), SortDescriptor: nil) as! [NSManagedObject]
                            
                            if(FetchLinkDetails.count > 0)
                            {
                                _ = FetchLinkDetails.map {
                                    let FetchLinkDetails = $0
                                    title = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchLinkDetails.value(forKey: "title"))
                                    image_url = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchLinkDetails.value(forKey: "image_url"))
                                    desc = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchLinkDetails.value(forKey: "desc"))
                                    url_str = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchLinkDetails.value(forKey: "url_str"))
                                    
                                }
                            }
                            
                            let FetchContactDetails = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Contact_details, attribute: "doc_id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id")), SortDescriptor: nil) as! [NSManagedObject]
                            
                            if(FetchContactDetails.count > 0)
                            {
                                _ = FetchContactDetails.map {
                                    let FetchContactDetails = $0
                                    
                                    contact_id = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchContactDetails.value(forKey: "contact_id"))
                                    contact_profile = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchContactDetails.value(forKey: "contact_profile"))
                                    contact_name = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchContactDetails.value(forKey: "contact_name"))
                                    contact_phone = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchContactDetails.value(forKey: "contact_phone"))
                                    contact_details = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchContactDetails.value(forKey: "contact_details"))
                                }
                            }
                            
                            let dic:[AnyHashable: Any] = ["type": type,"convId":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "convId")),"doc_id":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "doc_id")),"filesize":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "filesize")),"from":Themes.sharedInstance.CheckNullvalue(Passed_value:from
                                ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:to
                                ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "isStar")),"message_status":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "message_status")),"id":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id")),"name":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "contact_name")),"payload":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "payload")).encoded
                                ,"recordId":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "recordId")),"thumbnail":ThumbnailID,"width":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "width")),"height":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "height")),"msgId":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "msgId")),"contactmsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "ContactMsisdn"))
                                ,"user_common_id":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(from)-\(ChatInterlinkID)"
                                ),"message_from":message_from,"chat_type":Chat_type,"info_type":info_type,"created_by":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from")),"timestamp":timestamp, "docType":docType,"docName":docName,"docPageCount":docPageCount, "title":title ,"image_url":image_url,"desc":desc,"url_str":url_str, "contact_id":contact_id ,"contact_profile":contact_profile,"contact_phone":contact_phone,"contact_name":contact_name,"contact_details":contact_details, "latitude":Latitude ,"longitude":longitude,"title_place":title_place,"Stitle_place":Stitle_place,"imagelink":image_link, "reply_type" : Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "reply_type"))]
                            
                            self.dealTheFunctionData(dic, fromOrdering: false)
                        }
                        else if(chat_type == "group")
                        {
                            let recordId:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "recordId"));
                            let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from"));
                            let to:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "to"));
                            var message_from:String=""
                            let doc_id:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "doc_id"));
                            let timestamp:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "timestamp"));
                            let groupId:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "groupId"));
                            var ThumbnailID = ""
                            
                            if(from == Themes.sharedInstance.Getuser_id())
                            {
                                message_from="1";
                            }
                            else
                            {
                                message_from="0";
                            }
                            var type:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "type"))
                            
                            if(type == "20"){
                                type = "6"
                            }
                            
                            if(type == "1" || type == "2" || type == "3" || type == "6")
                            {
                                ThumbnailID = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "doc_id"))
                            }
                            else
                            {
                                ThumbnailID = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "thumbnail"))
                            }
                            
                            var title:String = String()
                            var image_url:String = String()
                            var url_str:String = String()
                            var desc:String = String()
                            
                            var contact_id:String = ""
                            var contact_profile:String = ""
                            var contact_name:String = ""
                            var contact_phone:String = ""
                            var contact_details:String = ""
                            
                            var Latitude:String = String()
                            var longitude:String = String()
                            var title_place:String = String()
                            var Stitle_place:String = String()
                            var image_link:String = String()
                            
                            var docPageCount:String = ""
                            var docName:String = ""
                            var docType:String = ""
                            
                            let FetchDocumentDetails = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Upload_Details, attribute: "upload_data_id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id")), SortDescriptor: nil) as! [Upload_Details]
                            if(FetchDocumentDetails.count > 0)
                            {
                                _ = FetchDocumentDetails.map {
                                    let FetchdocumentRecord = $0
                                    docPageCount = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchdocumentRecord.doc_pagecount)
                                    docName =  Themes.sharedInstance.CheckNullvalue(Passed_value: FetchdocumentRecord.doc_name)
                                    docType = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchdocumentRecord.doc_type)
                                }
                            }
                            
                            let FetchLocationDetails = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Location_details, attribute: "doc_id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id")), SortDescriptor: nil) as! [NSManagedObject]
                            if(FetchLocationDetails.count > 0)
                            {
                                _ = FetchLocationDetails.map {
                                    let FetchLocationRecord = $0
                                    
                                    Latitude = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchLocationRecord.value(forKey: "lat"))
                                    longitude = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchLocationRecord.value(forKey: "long"))
                                    title_place   = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchLocationRecord.value(forKey: "title"))
                                    Stitle_place = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchLocationRecord.value(forKey: "stitle"))
                                    image_link = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchLocationRecord.value(forKey: "image_link"))
                                    
                                }
                            }
                            
                            let FetchLinkDetails = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Link_details, attribute: "doc_id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id")), SortDescriptor: nil) as! [NSManagedObject]
                            
                            if(FetchLinkDetails.count > 0)
                            {
                                
                                _ = FetchLinkDetails.map {
                                    let FetchLinkDetails = $0
                                    
                                    title = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchLinkDetails.value(forKey: "title"))
                                    image_url = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchLinkDetails.value(forKey: "image_url"))
                                    desc = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchLinkDetails.value(forKey: "desc"))
                                    url_str = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchLinkDetails.value(forKey: "url_str"))
                                }
                            }
                            
                            let FetchContactDetails = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Contact_details, attribute: "doc_id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id")), SortDescriptor: nil) as! [NSManagedObject]
                            
                            if(FetchContactDetails.count > 0)
                            {
                                _ = FetchContactDetails.map {
                                    let FetchContactDetails = $0
                                    
                                    contact_id = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchContactDetails.value(forKey: "contact_id"))
                                    contact_profile = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchContactDetails.value(forKey: "contact_profile"))
                                    contact_name = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchContactDetails.value(forKey: "contact_name"))
                                    contact_phone = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchContactDetails.value(forKey: "contact_phone"))
                                    contact_details = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchContactDetails.value(forKey: "contact_details"))
                                }
                            }
                            
                            let dic:[AnyHashable: Any] = ["type": Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "type")),"convId":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "convId")),"doc_id":doc_id,"filesize":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "filesize")),"from":Themes.sharedInstance.CheckNullvalue(Passed_value:from
                                ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:to
                                ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "isStar")),"message_status":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "message_status")),"id":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id")),"name":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "contact_name")),"payload":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "payload")).encoded
                                ,"recordId":recordId,"thumbnail":ThumbnailID,"width":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "width")),"height":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "height")),"msgId":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id")),"contactmsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "ContactMsisdn"))
                                ,"user_common_id":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(Themes.sharedInstance.Getuser_id())-\(groupId)"
                                ),"message_from":message_from,"timestamp":timestamp,"chat_type":"group","info_type":"0","created_by":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from")), "docType":docType,"docName":docName,"docPageCount":docPageCount,"title":title ,"image_url":image_url,"desc":desc,"url_str":url_str, "contact_id":contact_id ,"contact_profile":contact_profile,"contact_phone":contact_phone,"contact_name":contact_name,"contact_details":contact_details,"latitude":Latitude ,"longitude":longitude,"title_place":title_place,"Stitle_place":Stitle_place,"imagelink":image_link, "reply_type" : Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "reply_type"))]
                            self.dealTheFunctionData(dic, fromOrdering: false)
                            
                        }
                        else if(chat_type == "messagestatus" || chat_type == "starredstatus" || chat_type == "groupmessagestatus")
                        {
                            let type:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "type"))
                            if(type == "13"){
                                info_type = "13"
                                Themes.sharedInstance.RemoveactivityView(View: self.chatTableView)
                                setExpirationLabel()
                            }
                            var doc_id:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "doc_id"));
                            var messageStatus:String = ""
                            var recordId:String = ""
                            var convId:String = ""
                            if(chat_type == "groupmessagestatus")
                            {
                                messageStatus  = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "message_status"))
                                
                                recordId  = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_one_one, attrib_name: "msgId", fetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "message_id")), returnStr: "recordId")
                                
                                convId  = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_one_one, attrib_name: "msgId", fetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "message_id")), returnStr: "convId")
                                
                                doc_id = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "message_id"))
                                
                                let messageFrame = (chatModel.dataSource as! [UUMessageFrame]).filter({$0.message._id == doc_id}).first
                                if(messageFrame != nil)
                                {
                                    messageFrame?.message.message_status = messageStatus
                                    messageFrame?.message.recordId = recordId
                                    messageFrame?.message.conv_id = convId
                                    let index = chatModel.dataSource.index(of: messageFrame!)
                                    let indexpath:IndexPath=IndexPath(row: index, section: 0)
                                    DispatchQueue.main.async{
                                        self.chatTableView.reloadRows(at: [indexpath], with: .none)
                                    }
                                }
                                
                                if(Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "message_status")) == "3"){
                                    self.readMessages()
                                }
                            }
                            else
                            {
                                messageStatus  = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "message_status"))
                                recordId  = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "recordId"))
                                convId  = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "convId"))
                                
                                let messageFrame = (chatModel.dataSource as! [UUMessageFrame]).filter({$0.message.doc_id == doc_id && $0.message.message_status != "3"}).first
                                if(messageFrame != nil)
                                {
                                    messageFrame?.message.message_status = messageStatus
                                    
                                    if(recordId != "")
                                    {
                                        messageFrame?.message.recordId = recordId
                                    }
                                    if(convId != "")
                                    {
                                        messageFrame?.message.conv_id = convId
                                    }
                                    
                                    
                                    let index = chatModel.dataSource.index(of: messageFrame!)
                                    let indexpath:IndexPath=IndexPath(row: index, section: 0)
                                    DispatchQueue.main.async{
                                        self.chatTableView.reloadRows(at: [indexpath], with: .none)
                                    }
                                }
                                
                                if(Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "message_status")) == "3"){
                                    self.readMessages()
                                }
                            }
                            
                        }
                        else if(chat_type == "delete_action")
                        {
                            let doc_id:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "doc_id"));
                            
                            let messageFrame = (chatModel.dataSource as! [UUMessageFrame]).filter({$0.message.doc_id  == doc_id}).first
                            if(messageFrame != nil)
                            {
                                let index = chatModel.dataSource.index(of: messageFrame!)
                                let indexpath:IndexPath=IndexPath(row: index, section: 0)
                                
                                chatModel.dataSource.removeObject(at: index)
                                self.chatTableView.deleteRows(at: [indexpath], with: .fade)
                                self.chatTableView.reloadData()
                            }
                        }
                    }
                }
                
            }
        }
    }
    
    func receiveMessage(_ notify: Notification) {
        istartTyping = false
        if(self.isModal()  || AppDelegate.sharedInstance.isVideoViewPresented)
        {
            let ResponseDict:NSDictionary = notify.object  as! NSDictionary
            if let chat_type = notify.userInfo?["chat_type"] as? String {
                // do something with your image
                var Blockmessage:Bool = false
                if(chat_type == "secret" && !is_fromSecret)
                {
                    Blockmessage = true
                }
                if(Blockmessage == false)
                {
                    if(ResponseDict.count > 0)
                    {
                        let to:String=Themes.sharedInstance.CheckNullvalue(Passed_value: opponent_id)
                        var User_chat_id = Themes.sharedInstance.Getuser_id() + "-" + to
                        if(chat_type == "secret")
                        {
                            User_chat_id = to + "-" + Themes.sharedInstance.Getuser_id()
                        }
                        var from_response:String!
                        if(chat_type == "single" || chat_type == "secret")
                        {
                            from_response=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from"));
                            
                        }
                        else if(chat_type == "group")
                        {
                            from_response=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "convId"));
                            
                        }
                        var commonId="\(Themes.sharedInstance.Getuser_id())-\(from_response!)"
                        if(chat_type == "secret")
                        {
                            commonId = "\(from_response!)-\(Themes.sharedInstance.Getuser_id())"
                            
                        }
                        if(chat_type == "single" || chat_type == "secret")
                        {
                            if(from_response! == opponent_id)
                            {
                                self.ClearUnreadMessages(user_common_id: commonId)
                            }
                        }
                        else
                        {
                            if(from_response! == opponent_id)
                            {
                                self.ClearUnreadMessages(user_common_id: commonId)
                            }
                        }
                        if(User_chat_id == commonId)
                        {
                            if(chat_type == "single" || chat_type == "secret")
                            {
                                let type:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "type"))
                                var dic:Dictionary<AnyHashable,Any>!
                                
                                var Latitude:String = String()
                                var longitude:String = String()
                                var title_place:String = String()
                                var Stitle_place:String = String()
                                var image_link:String = String()
                                
                                var title:String = String()
                                var image_url:String = String()
                                var url_str:String = String()
                                var desc:String = String()
                                
                                var contact_id:String = ""
                                var contact_profile:String = ""
                                var contact_name:String = ""
                                var contact_phone:String = ""
                                var contact_details:String = ""
                                
                                var docPageCount:String = ""
                                var docName:String = ""
                                var docType:String = ""
                                
                                let FetchDocumentDetails = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Upload_Details, attribute: "upload_data_id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id")), SortDescriptor: nil) as! [Upload_Details]
                                if(FetchDocumentDetails.count > 0)
                                {
                                    _ = FetchDocumentDetails.map {
                                        let FetchDocumentRecord = $0
                                        
                                        docPageCount = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchDocumentRecord.doc_pagecount)
                                        docName = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchDocumentRecord.doc_name)
                                        docType   = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchDocumentRecord.doc_type)
                                    }
                                }
                                
                                let FetchLocationDetails = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Location_details, attribute: "doc_id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id")), SortDescriptor: nil) as! [NSManagedObject]
                                if(FetchLocationDetails.count > 0)
                                {
                                    _ = FetchLocationDetails.map {
                                        let FetchLocationRecord = $0
                                        
                                        Latitude = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchLocationRecord.value(forKey: "lat"))
                                        longitude = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchLocationRecord.value(forKey: "long"))
                                        title_place   = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchLocationRecord.value(forKey: "title"))
                                        Stitle_place = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchLocationRecord.value(forKey: "stitle"))
                                        image_link = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchLocationRecord.value(forKey: "image_link"))
                                        
                                    }
                                }
                                
                                let FetchLinkDetails = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Link_details, attribute: "doc_id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id")), SortDescriptor: nil) as! [NSManagedObject]
                                
                                if(FetchLinkDetails.count > 0)
                                {
                                    _ = FetchLinkDetails.map {
                                        let FetchLinkDetails = $0
                                        
                                        title = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchLinkDetails.value(forKey: "title"))
                                        image_url = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchLinkDetails.value(forKey: "image_url"))
                                        desc = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchLinkDetails.value(forKey: "desc"))
                                        url_str = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchLinkDetails.value(forKey: "url_str"))
                                        
                                    }
                                }
                                
                                let FetchContactDetails = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Contact_details, attribute: "doc_id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id")), SortDescriptor: nil) as! [NSManagedObject]
                                
                                if(FetchContactDetails.count > 0)
                                {
                                    _ = FetchContactDetails.map {
                                        let FetchContactDetails = $0
                                        
                                        contact_id = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchContactDetails.value(forKey: "contact_id"))
                                        contact_profile = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchContactDetails.value(forKey: "contact_profile"))
                                        contact_name = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchContactDetails.value(forKey: "contact_name"))
                                        contact_phone = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchContactDetails.value(forKey: "contact_phone"))
                                        contact_details = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchContactDetails.value(forKey: "contact_details"))
                                    }
                                }
                                
                                let info_type = (type == "21" || type == "23" || type == "71" || type == "13") ? type : "0"
                                
                                
                                if(info_type == "13" && self.Chat_type != "secret") {
                                    return
                                }
                                else
                                {
                                    Themes.sharedInstance.RemoveactivityView(View: self.chatTableView)
                                    setExpirationLabel()
                                }
                                
                                dic = ["type": Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "type")),"convId":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "convId")),"doc_id":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id")),"filesize":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "filesize")),"from":Themes.sharedInstance.CheckNullvalue(Passed_value:ResponseDict.value(forKey: "from")
                                    ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:ResponseDict.value(forKey: "to")
                                    ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "isStar")),"message_status":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "message_status")),"id":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "id")),"name":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "name")),"payload":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "payload"))
                                    ,"recordId":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "recordId")),"thumbnail":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "thumbnail")),"width":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "width")),"height":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "height")),"msgId":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "msgId")),"contactmsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "contactmsisdn"))
                                    ,"user_common_id":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "user_common_id"))
                                    ,"timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "timestamp")),"message_from":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "message_from")),"created_by":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from")),"info_type":info_type,"chat_type":chat_type, "latitude":Latitude ,"longitude":longitude,"title_place":title_place,"Stitle_place":Stitle_place,"imagelink":image_link, "title":title ,"image_url":image_url,"desc":desc,"url_str":url_str, "contact_id":contact_id ,"contact_profile":contact_profile,"contact_phone":contact_phone,"contact_name":contact_name,"contact_details":contact_details, "docType":docType,"docName":docName,"docPageCount":docPageCount, "reply_type" : Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "reply_type"))]
                                
                                DispatchQueue.main.async {
                                    let messageFrame = (self.chatModel.dataSource as! [UUMessageFrame]).filter({$0.message._id!  == Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "id"))}).first
                                    if(messageFrame == nil)
                                    {
                                        self.dealTheFunctionData(dic, fromOrdering: false)
                                    }
                                }
                                
                                if(chat_type == "secret")
                                {
                                    let type:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "type"))
                                    let Pred:NSPredicate = NSPredicate(format: "doc_id == %@",Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id")))
                                    var checksecretmessagecount:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Secret_Chat, attribute: "user_common_id", FetchString: User_chat_id, SortDescriptor: "timestamp") as! NSArray
                                    checksecretmessagecount = checksecretmessagecount.reversed() as NSArray
                                    
                                    var expire_timestamp:String = ""
                                    var secret_msg_id:String = ""
                                    expire_timestamp = "\(Int64(String(Date().ticks))!)"
                                    if(checksecretmessagecount.count > 0)
                                    {
                                        if(type != "13")
                                        {
                                            secret_msg_id = Themes.sharedInstance.CheckNullvalue(Passed_value: (checksecretmessagecount[0] as! NSManagedObject).value(forKey: "doc_id"))
                                        }
                                    }
                                    
                                    var incognito_timer_mode =  Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "incognito_timer_mode"))
                                    
                                    if(incognito_timer_mode == "")
                                    {
                                        incognito_timer_mode =  Themes.sharedInstance.CheckNullvalue(Passed_value: (checksecretmessagecount[0] as! NSManagedObject).value(forKey: "incognito_timer"))
                                    }
                                    let getUpdatedtimestamp:String = Themes.sharedInstance.returnupdatedSecrettimestamp(incognito_timer_mode: incognito_timer_mode)
                                    expire_timestamp =  getUpdatedtimestamp
                                    
                                    let dict:NSDictionary = ["secret_timestamp":expire_timestamp,"secret_msg_id":secret_msg_id]
                                    DatabaseHandler.sharedInstance.UpdateDataWithPredicate(Entityname: Constant.sharedinstance.Chat_one_one, predicate: Pred, UpdationElements: dict)
                                }
                                
                                let status = UIApplication.shared.applicationState
                                if(status == .active)
                                {
                                    if (chat_type == "secret" && self.Chat_type == "secret") || (chat_type != "secret" && self.Chat_type != "secret"){

                                        SocketIOManager.sharedInstance.AcknowledegmentHandler(from: Themes.sharedInstance.Getuser_id() as NSString, to: Themes.sharedInstance.CheckNullvalue(Passed_value:ResponseDict.value(forKey: "from")) as NSString, status: "3", doc_id: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id")) as NSString, timestamp: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "msgId")) as NSString,isEmit_status: true, is_deleted_message_ack: false,chat_type: chat_type, convId: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "convId")))
                                    }
                                }
                            }
                            else if(chat_type == "group")
                            {
                                var dic:Dictionary<AnyHashable,Any>!
                                let timestamp:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "timestamp"));
                                let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from"));
                                let to:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "to"));
                                let Doc_id:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "doc_id"));
                                let id:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id"));
                                let groupId:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "convId"));
                                let recordId:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "recordId"));
                                
                                var Latitude:String = String()
                                var longitude:String = String()
                                var title_place:String = String()
                                var Stitle_place:String = String()
                                var image_link:String = String()
                                
                                var title:String = String()
                                var image_url:String = String()
                                var url_str:String = String()
                                var desc:String = String()
                                
                                var contact_id:String = ""
                                var contact_profile:String = ""
                                var contact_name:String = ""
                                var contact_phone:String = ""
                                var contact_details:String = ""
                                
                                var docPageCount:String = ""
                                var docName:String = ""
                                var docType:String = ""
                                
                                let FetchDocumentDetails = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Upload_Details, attribute: "upload_data_id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id")), SortDescriptor: nil) as! [Upload_Details]
                                if(FetchDocumentDetails.count > 0)
                                {
                                    _ = FetchDocumentDetails.map {
                                        let FetchDocumentRecord = $0
                                        
                                        docPageCount = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchDocumentRecord.doc_pagecount)
                                        docName = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchDocumentRecord.doc_name)
                                        docType   = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchDocumentRecord.doc_type)
                                    }
                                }
                                
                                let FetchLocationDetails = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Location_details, attribute: "doc_id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id")), SortDescriptor: nil) as! [NSManagedObject]
                                if(FetchLocationDetails.count > 0)
                                {
                                    _ = FetchLocationDetails.map {
                                        let FetchLocationRecord = $0
                                        
                                        Latitude = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchLocationRecord.value(forKey: "lat"))
                                        longitude = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchLocationRecord.value(forKey: "long"))
                                        title_place   = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchLocationRecord.value(forKey: "title"))
                                        Stitle_place = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchLocationRecord.value(forKey: "stitle"))
                                        image_link = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchLocationRecord.value(forKey: "image_link"))
                                        
                                    }
                                }
                                
                                let FetchLinkDetails = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Link_details, attribute: "doc_id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id")), SortDescriptor: nil) as! [NSManagedObject]
                                
                                if(FetchLinkDetails.count > 0)
                                {
                                    _ = FetchLinkDetails.map {
                                        let FetchLinkDetails = $0
                                        
                                        title = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchLinkDetails.value(forKey: "title"))
                                        image_url = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchLinkDetails.value(forKey: "image_url"))
                                        desc = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchLinkDetails.value(forKey: "desc"))
                                        url_str = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchLinkDetails.value(forKey: "url_str"))
                                    }
                                }
                                
                                let FetchContactDetails = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Contact_details, attribute: "doc_id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id")), SortDescriptor: nil) as! [NSManagedObject]
                                
                                if(FetchContactDetails.count > 0)
                                {
                                    _ = FetchContactDetails.map {
                                        let FetchContactDetails = $0
                                        
                                        contact_id = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchContactDetails.value(forKey: "contact_id"))
                                        contact_profile = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchContactDetails.value(forKey: "contact_profile"))
                                        contact_name = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchContactDetails.value(forKey: "contact_name"))
                                        contact_phone = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchContactDetails.value(forKey: "contact_phone"))
                                        contact_details = Themes.sharedInstance.CheckNullvalue(Passed_value: FetchContactDetails.value(forKey: "contact_details"))
                                    }
                                }
                                
                                let info_type = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "info_type"))
                                
                                dic = ["type": Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "type")),"convId":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "convId")),"doc_id":Doc_id,"filesize":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "filesize")),"from":Themes.sharedInstance.CheckNullvalue(Passed_value:from
                                    ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:to
                                    ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "isStar")),"message_status":"1","id":id,"name":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "contact_name")),"payload":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "payload"))
                                    ,"recordId":recordId,"thumbnail":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "thumbnail")),"width":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "width")),"height":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "height")),"msgId":id,"contactmsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "contactmsisdn"))
                                    ,"user_common_id":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(Themes.sharedInstance.Getuser_id())-\(groupId)"
                                    ),"message_from":"0","timestamp":timestamp,"chat_type":"group","info_type":info_type,"created_by":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from")), "latitude":Latitude ,"longitude":longitude,"title_place":title_place,"Stitle_place":Stitle_place,"imagelink":image_link, "title":title ,"image_url":image_url,"desc":desc,"url_str":url_str, "contact_id":contact_id ,"contact_profile":contact_profile,"contact_phone":contact_phone,"contact_name":contact_name,"contact_details":contact_details, "docType":docType,"docName":docName,"docPageCount":docPageCount, "reply_type" : Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "reply_type"))]
                                
                                DispatchQueue.main.async {
                                    self.dealTheFunctionData(dic, fromOrdering: false)
                                }
                                
                                let status = UIApplication.shared.applicationState
                                if(status == .active)
                                {
                                    let param_ack=["groupType": 12, "from": Themes.sharedInstance.Getuser_id(), "groupId": Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "convId")), "status":2, "msgId": (id as NSString).longLongValue] as [String : Any]
                                    SocketIOManager.sharedInstance.GroupmessageAcknowledgement(Param: param_ack)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    func addRefreshViews() {
        chatTableView.tableFooterView=UIView();
        chatTableView.separatorColor=UIColor.clear
    }
    func refresh(_ refreshControl: UIRefreshControl) {
        weak var weakSelf = self
        let pageNum = 3
        if (weakSelf?.chatModel.dataSource.count)! > pageNum {
            let indexPath = IndexPath(row: pageNum, section: 0)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
                weakSelf?.chatTableView.reloadData()
                weakSelf?.chatTableView.scrollToRow(at: indexPath, at: .top, animated: false)
            })
        }
        refreshControl.endRefreshing()
        // Do your job, when done:
    }
    
    func keyboardChangeShow(_ notification: Notification) {
        self.pauseGif()
        isKeyboardShown=true;
        var userInfo = notification.userInfo!
        let animationCurve: UIView.AnimationCurve=UIView.AnimationCurve(rawValue: Int(userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber))!
        let animationDuration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let keyboardEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(animationDuration)
        UIView.setAnimationCurve(animationCurve)
        
        
        //adjust ChatTableView's height
        if notification.name == UIResponder.keyboardWillShowNotification && link_view.isHidden {
            if(isShowBottomView)
            {
                self.bottomConstraint.constant = keyboardEndFrame.size.height + 100
                
            }
            else
            {
                self.bottomConstraint.constant = keyboardEndFrame.size.height + 50
            }
            if(link_view.isHidden == true)
            {
                self.bottomConstraint.constant = keyboardEndFrame.size.height + 50
                self.link_bottom.constant=keyboardEndFrame.size.height + 50
            }
        }
        else if(!link_view.isHidden){
            
            UIView.animate(withDuration: 0.1,
                           delay: 0.1,
                           options: UIView.AnimationOptions.curveEaseIn,
                           animations: { () -> Void in
                            self.link_bottom.constant=keyboardEndFrame.size.height + 50
            }, completion: { (finished) -> Void in
                self.bottomConstraint.constant = keyboardEndFrame.size.height + self.link_view.frame.size.height + 50
            })
            
            
        }
        else {
            if(isShowBottomView)
            {
                self.bottomConstraint.constant = 50+50
            }
            else
            {
                self.bottomConstraint.constant = 50
                self.bottomConstraint.constant = 50+link_view.frame.size.height
                self.link_bottom.constant=50
            }
        }
        self.view.layoutIfNeeded()
        //adjust UUInputFunctionView's originPoint
        newFrame = IFView.frame
        newFrame.origin.y = keyboardEndFrame.origin.y - newFrame.size.height
        IFView.frame = newFrame
        ReplyView.frame.origin.y =  newFrame.origin.y-50
        tagView.frame.origin.y = newFrame.origin.y-tagView.frame.size.height
        IFView.set_Frame()
        if(bottomnavigateView.isHidden == true)
        {
            self.tableViewScrollToBottom()
        }
        UIView.commitAnimations()
        
    }
    
    func keyboardChangeHide(_ notification: Notification) {
        isKeyboardShown=false
        var userInfo = notification.userInfo!
        let animationCurve: UIView.AnimationCurve=UIView.AnimationCurve(rawValue: Int(userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber))!
        let animationDuration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let keyboardEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(animationDuration)
        UIView.setAnimationCurve(animationCurve)
        //adjust ChatTableView's height
        if notification.name == UIResponder.keyboardWillShowNotification {
            
            if(isShowBottomView)
            {
                self.bottomConstraint.constant = keyboardEndFrame.size.height + 100
                
            }
            else
            {
                self.bottomConstraint.constant = keyboardEndFrame.size.height + 50
            }
            
        }else if(link_view.isHidden){
            
            if(isReplyMessage)
            {
                self.bottomConstraint.constant = 50 + self.ReplyView.frame.size.height
            }
            else
            {
                self.bottomConstraint.constant = 50
                self.link_bottom.constant=50
            }
        }
        else {
            
            if(isShowBottomView)
            {
                self.bottomConstraint.constant = 50+50
            }else if(link_view.isHidden == false){
                self.bottomConstraint.constant = 50 + 55
                self.link_bottom.constant=50
            }
            else
            {
                self.bottomConstraint.constant = 50
            }
            
        }
        self.view.layoutIfNeeded()
        //adjust UUInputFunctionView's originPoint
        newFrame = IFView.frame
        if UIDevice.isIphoneX {
            newFrame.origin.y = keyboardEndFrame.origin.y - newFrame.size.height - 30
        } else {
            newFrame.origin.y = keyboardEndFrame.origin.y - newFrame.size.height
        }
        IFView.frame = newFrame
        ReplyView.frame.origin.y =  newFrame.origin.y-50
        tagView.frame.origin.y = newFrame.origin.y-tagView.frame.size.height
        IFView.set_Frame()
        UIView.commitAnimations()
    }
    func ClearUnreadMessages(user_common_id:String)
    {
        
        let param:NSDictionary = ["chat_count":"0","is_read":"0"]
        let P1:NSPredicate = NSPredicate(format: "user_common_id = %@", user_common_id)
        DatabaseHandler.sharedInstance.UpdateDataWithPredicate(Entityname: Constant.sharedinstance.Chat_intiated_details, predicate: P1, UpdationElements: param)
        
    }
    
    func loadBaseViewsAndData() {
        Checkencryptedmessage()
        self.chatModel = ChatModel()
        self.chatTableView.reloadData()
        self.chatModel.isGroupChat = false
        if(IFView == nil)
        {
            IFView = Bundle.main.loadNibNamed("UUInputFunctionView", owner: self, options: nil)?[0] as? UUInputFunctionView
            IFView.setVC()
            IFView.delegate = self
            if UIDevice.isIphoneX {
                IFView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height-80, width: UIScreen.main.bounds.size.width, height: 50)
            } else {
                IFView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height-50, width: UIScreen.main.bounds.size.width, height: 50)
            }
            IFView.set_Frame()
            if(!self.view.subviews.contains(IFView)) {
                self.view.addSubview(IFView)
            }
        }
        ReplyView.Delegate = self
        ReplyView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height-100, width: UIScreen.main.bounds.size.width, height: 50)
        tagView.delegate = self
        tagView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height-tagView.frame.size.height, width: self.view.frame.size.width, height: tagView.frame.size.height)
        ReplyView.awakeFromNib()
        ReplyView.message_Lbl.frame = CGRect(x: ReplyView.message_Lbl.frame.origin.x, y: ReplyView.message_Lbl.frame.origin.y, width: ReplyView.close_Btn.frame.origin.x - 10, height: ReplyView.message_Lbl.frame.size.height)
        self.view.addSubview(ReplyView)
        self.view.addSubview(tagView)
        ReplyView.isHidden = true
        tagView.isHidden = true
        left_item.isEnabled = false
        
        //    self.selectiontoolbar.bringSubview(toFront: self.view)
        let from = Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
        let to = Themes.sharedInstance.CheckNullvalue(Passed_value: opponent_id)
        var User_chat_id:String = ""
        
        if(self.Chat_type == "secret"){
            User_chat_id=to + "-" + from
        }else{
            User_chat_id=from + "-" + to
        }
        
        let p1 = NSPredicate(format: "user_common_id = %@", User_chat_id)
        let p2 = NSPredicate(format: "message_status != %@", "3")
        let p3 = NSPredicate(format: "message_status != %@", "0")
        let p4 = NSPredicate(format: "chat_type == %@", self.Chat_type)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2, p3,p4])
        
        let AcknowledgeChathandlerArr = DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Chat_one_one, SortDescriptor: "timestamp", predicate: predicate,Limit:0) as! NSArray
        if(AcknowledgeChathandlerArr.count > 0)
        {
            let ResponseDict = AcknowledgeChathandlerArr.firstObject as! NSManagedObject
            let timestamp:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "msgId"));
            let id:String =  Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "id"))
            let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "from"));
            let to:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "to"));
            var toID:String=String()
            if(from != Themes.sharedInstance.Getuser_id())
            {
                toID=from
            }
            else
            {
                toID=to
            }
            let Doc_id:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id"));
            let convId:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "convId"));
            if(Chat_type == "single" || Chat_type == "secret")
            {
                SocketIOManager.sharedInstance.AcknowledegmentHandler(from: Themes.sharedInstance.Getuser_id() as NSString, to: toID as NSString, status: "3", doc_id: Doc_id as NSString, timestamp: timestamp as NSString,isEmit_status: true, is_deleted_message_ack: false, chat_type: Chat_type, convId: convId)
            }
            else
            {
                let param_ack=["groupType": 12, "from": Themes.sharedInstance.Getuser_id(), "groupId": convId, "status":2, "msgId":(id as NSString).longLongValue] as [String : Any]
                SocketIOManager.sharedInstance.GroupmessageAcknowledgement(Param: param_ack)
            }
        }
        
        
        
        self.ClearUnreadMessages(user_common_id: User_chat_id)
        
        
        
        
        let checkArr = DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Chat_one_one, SortDescriptor: "timestamp", predicate: p1, Limit: 0) as! NSArray
        
        if(checkArr.count > 0){
            let lastMessage:NSManagedObject = checkArr.firstObject as! NSManagedObject
            if(lastMessage.value(forKey: "message_status") as! String == "3" && lastMessage.value(forKey: "info_type") as! String == "0"){
                self.readMessages()
            }
        }
        
        if(self.Chat_type == "secret"){
            self.updateSecrettimestamp()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func Checkencryptedmessage()
    {
        let from = Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
        let to = Themes.sharedInstance.CheckNullvalue(Passed_value: opponent_id)
        var User_chat_id:String = ""
        if(self.Chat_type == "secret"){
            User_chat_id=to + "-" + from
        }else{
            User_chat_id=from + "-" + to
        }
        let checkBool:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "user_common_id", FetchString: User_chat_id)
        if(checkBool)
        {
            
            let P1:NSPredicate = NSPredicate(format: "type = %@", "72")
            let P2:NSPredicate = NSPredicate(format: "user_common_id = %@", User_chat_id)
            let fetch_predicate:NSCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [P1,P2])
            let checkencryption = DatabaseHandler.sharedInstance.FetchFromDatabaseWithRange(Entityname: Constant.sharedinstance.Chat_one_one, SortDescriptor: "timestamp", predicate: fetch_predicate, Limit: 0, StartRange: 0) as! [NSManagedObject]
            if(checkencryption.count == 0)
            {
                var ChatDetailArr = DatabaseHandler.sharedInstance.FetchFromDatabaseWithascending(Entityname: Constant.sharedinstance.Chat_one_one, SortDescriptor: "timestamp", predicate: P2, Limit: 1, StartRange: 0) as! [NSManagedObject]
                if(ChatDetailArr.count > 0)
                {
                    let dict:NSManagedObject = ChatDetailArr[0]
                    var timestamp:String = Themes.sharedInstance.CheckNullvalue(Passed_value: dict.value(forKey: "timestamp"))
                    if(timestamp.length != 0)
                    {
                        timestamp =  "\((timestamp as NSString).longLongValue - 20)"
                        insertEncryptedmessage(timestamp:timestamp)
                    }
                }
            }
        }
        else
        {
            var timestamp:String = String(Date().ticks)
            let servertimeStr:String = Themes.sharedInstance.getServerTime()
            let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
            timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
            insertEncryptedmessage(timestamp:timestamp)
        }
    }
    func insertEncryptedmessage(timestamp:String)
    {
        let from = Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
        let to = Themes.sharedInstance.CheckNullvalue(Passed_value: opponent_id)
        
        var User_chat_id:String = ""
        if(self.Chat_type == "secret"){
            User_chat_id=to + "-" + from
        }else{
            User_chat_id=from + "-" + to
        }
        let Phonenumber:String=Themes.sharedInstance.setPhoneTxt(Themes.sharedInstance.Getuser_id())
        let toDocId:String="\(from)-\(to)-\(timestamp)"
        let  loaddic = ["type": "72","convId":"","doc_id":Themes.sharedInstance.CheckNullvalue(Passed_value:toDocId
            ),"filesize":"","from":Themes.sharedInstance.CheckNullvalue(Passed_value:from
            ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:to
            ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
            ),"message_status":"3","id":timestamp,"name":"","payload":"","recordId":"","timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
            ),"thumbnail":"","width":"0.0","height":"0.0","msgId":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
            ),"contactmsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value:Phonenumber
            ),"user_common_id":User_chat_id,"message_from":"1","chat_type":Chat_type,"info_type":"72","created_by":from,"is_reply":"0","secret_msg_id":"","secret_timestamp":"", "while_blocked" : Themes.sharedInstance.isImBlocked(to) ? "1" : "0"] as [String : String]
        DatabaseHandler.sharedInstance.InserttoDatabase(Dict: loaddic as NSDictionary,Entityname: Constant.sharedinstance.Chat_one_one)
    }
    func LoadBaseView(limit:NSInteger)
    {
        if(from_search_msg == true)
        {
            self.chatTableView.isHidden = true
        }
        else
        {
            self.chatTableView.isHidden = false
        }
        let from = Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
        let to = Themes.sharedInstance.CheckNullvalue(Passed_value: opponent_id)
        var User_chat_id:String = ""
        if(self.Chat_type == "secret"){
            User_chat_id=to + "-" + from
        }else{
            User_chat_id=from + "-" + to
        }
        
        let P1:NSPredicate = NSPredicate(format: "chat_type = %@", self.Chat_type)
        let P2:NSPredicate = NSPredicate(format: "user_common_id = %@", User_chat_id)
        let fetch_predicate:NSCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [P1,P2])
        var ChatArr = DatabaseHandler.sharedInstance.FetchFromDatabaseWithRange(Entityname: Constant.sharedinstance.Chat_one_one, SortDescriptor: "timestamp", predicate: fetch_predicate, Limit: 20, StartRange: 0) as! [NSManagedObject]
        ChatArr = ChatArr.reversed()
        if(ChatArr.count > 0)
        {
//            let descriptor: NSSortDescriptor = NSSortDescriptor(key: "date", ascending: true)
//            ChatArr = (ChatArr as NSArray).sortedArray(using: [descriptor]) as! [NSManagedObject]
            _ = ChatArr.map {
                let ResponseDict = $0
                var dic = [AnyHashable: Any]()
                
                var docPageCount:String = ""
                var docName:String = ""
                var docType:String = ""
                
                var ChekLocation : Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Upload_Details, attribute: "upload_data_id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id")))
                if(ChekLocation)
                {
                    let DocumentArr = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Upload_Details, attribute: "upload_data_id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id")), SortDescriptor: nil) as! [Upload_Details]
                    _ = DocumentArr.map {
                        let ObjRecord = $0
                        
                        docPageCount = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.doc_pagecount)
                        docName =  Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.doc_name)
                        docType = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.doc_type)
                    }
                }
                
                
                var Latitude:String = ""
                var longitude:String = ""
                var title_place:String = ""
                var Stitle_place:String = ""
                var image_link:String = ""
                
                ChekLocation = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Location_details, attribute: "doc_id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id")))
                if(ChekLocation)
                {
                    let LocationArr = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Location_details, attribute: "doc_id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id")), SortDescriptor: nil) as! [NSManagedObject]
                    _ = LocationArr.map {
                        let ObjRecord = $0
                        
                        Latitude = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "lat"))
                        longitude =  Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "long"))
                        title_place = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "title"))
                        Stitle_place = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "stitle"))
                        image_link = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "image_link"))
                        
                    }
                }
                
                var title:String = ""
                var image_url:String = ""
                var desc:String = ""
                var url_str:String = ""
                
                ChekLocation = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Link_details, attribute: "doc_id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id")))
                
                if(ChekLocation)
                {
                    let LocationArr = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Link_details, attribute: "doc_id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id")), SortDescriptor: nil) as! [NSManagedObject]
                    _ = LocationArr.map {
                        let ObjRecord = $0
                        title = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "title"))
                        image_url =  Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "image_url"))
                        desc = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "desc"))
                        url_str = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "url_str"))
                        
                    }
                }
                
                var contact_id:String = ""
                var contact_profile:String = ""
                var contact_name:String = ""
                var contact_phone:String = ""
                var contact_details:String = ""
                
                ChekLocation = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Contact_details, attribute: "doc_id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id")))
                
                if(ChekLocation)
                {
                    let ContactArr = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Contact_details, attribute: "doc_id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id")), SortDescriptor: nil) as! [NSManagedObject]
                    _ = ContactArr.map {
                        let ObjRecord = $0
                        contact_id = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "contact_id"))
                        contact_profile =  Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "contact_profile"))
                        contact_name = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "contact_name"))
                        contact_phone = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "contact_phone"))
                        contact_details = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "contact_details"))
                    }
                }
                
                dic  = ["type": Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "type")),"convId":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "convId")),"doc_id":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id")),"filesize":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "filesize")),"from":Themes.sharedInstance.CheckNullvalue(Passed_value:ResponseDict.value(forKey: "from")
                    ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:ResponseDict.value(forKey: "to")
                    ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "isStar")),"message_status":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "message_status")),"id":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "id")),"name":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "name")),"payload":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "payload"))
                    ,"recordId":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "recordId")),"thumbnail":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "thumbnail")),"width":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "width")),"height":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "height")),"msgId":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "msgId")),"contactmsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "contactmsisdn"))
                    ,"user_common_id":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "user_common_id"))
                    ,"timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "timestamp")),"message_from":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "message_from")),"info_type":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "info_type")),"chat_type":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "chat_type")), "is_deleted" :  Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "is_deleted")), "docType":docType,"docName":docName,"docPageCount":docPageCount,"latitude":Latitude ,"longitude":longitude,"title_place":title_place,"Stitle_place":Stitle_place,"imagelink":image_link,"title":title ,"image_url":image_url,"desc":desc,"url_str":url_str,"contact_id":contact_id ,"contact_profile":contact_profile,"contact_phone":contact_phone,"contact_name":contact_name,"contact_details":contact_details, "reply_type" : Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "reply_type")), "while_blocked" : Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "while_blocked"))]
                
                self.dealTheFunctionData(dic, fromOrdering: true)
            }
            
            self.chatTableView.isHidden = true
            self.chatTableView.reloadData()
            
            DispatchQueue.main.async {
                if(self.chatTableView.contentSize.height > self.chatTableView.frame.size.height)
                {
                    if !self.from_search_msg {
                        self.chatTableView.isHidden = false
                    }
                    let scrollPoint = CGPoint(x: 0, y: self.chatTableView.contentSize.height - self.chatTableView.frame.size.height)
                    self.chatTableView.setContentOffset(scrollPoint, animated: false)
                }
                else
                {
                    if !self.from_search_msg {
                        self.chatTableView.isHidden = false
                    }
                }
            }
            
            if(from_search_msg == true && self.chatTableView.isHidden == true){
                Themes.sharedInstance.activityView(View: self.view)
                let messageFrame = (self.chatModel.dataSource as! [UUMessageFrame]).filter({$0.message.timestamp!  == self.from_search_msg_id}).first
                if(messageFrame != nil)
                {
                    let index = self.chatModel.dataSource.index(of: messageFrame!)
                    self.tableViewScrollToRow(row: index)
                }
                else
                {
                    DispatchQueue.main.async {
                        self.PerformPagination()
                    }
                }
            }
        }
    }
    
    func readMessages(){
        
        updateSecrettimestamp()
        let from = Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
        let to = Themes.sharedInstance.CheckNullvalue(Passed_value: opponent_id)
        
        var User_chat_id=from + "-" + to;
        if(Chat_type == "secret")
        {
            User_chat_id = to + "-" + from
        }
        
        let P1 = NSPredicate(format: "user_common_id = %@", User_chat_id)
        let P2:NSPredicate = NSPredicate(format: "message_from == 1")
        let P3:NSPredicate = NSPredicate(format: "message_status != 3")
        let P4:NSPredicate = NSPredicate(format: "message_status != 0")
        let P5:NSPredicate = NSPredicate(format: "while_blocked != 1")

        let status_update:NSCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [P1,P2,P3,P4,P5])
        let dict:NSDictionary = ["message_status":"3"]
        
        DatabaseHandler.sharedInstance.UpdateDataWithPredicate(Entityname: Constant.sharedinstance.Chat_one_one, predicate: status_update, UpdationElements: dict)
        
        let check_upload:NSCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [P1])
        
        let upload_detailArr = DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Upload_Details, SortDescriptor: nil, predicate: check_upload, Limit: 0) as! [NSManagedObject]
        
        
        if(upload_detailArr.count > 0)
        {
            _ = upload_detailArr.map {
                let uploadReponseDict = $0
                let upload_data_id = Themes.sharedInstance.CheckNullvalue(Passed_value: uploadReponseDict.value(forKey: "upload_data_id"))
                let upload_status = Themes.sharedInstance.CheckNullvalue(Passed_value: uploadReponseDict.value(forKey: "upload_status"))
                if(upload_status != "1")
                {
                    let dict:NSDictionary = ["message_status":"0"]
                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_one_one, FetchString: upload_data_id, attribute: "thumbnail", UpdationElements: dict)
                }
            }
        }
        
        let messageFrameArr = (chatModel.dataSource as! [UUMessageFrame]).filter({$0.message.message_status != "3" && $0.message.message_status != "0" && $0.message.while_blocked != "1" && $0.message.from == MessageFrom(rawValue: 1)})
        if(messageFrameArr.count > 0)
        {
            var indexes = [IndexPath]()
            _ = messageFrameArr.map {
                let index = chatModel.dataSource.index(of: $0)
                let indexpath:IndexPath=IndexPath(row: index, section: 0)
                let upload_status = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Upload_Details, attrib_name: "upload_data_id", fetchString: $0.message.thumbnail!, returnStr: "upload_status")
                if(upload_status == "1" || upload_status == "")
                {
                    $0.message.message_status = "3"
                    indexes.append(indexpath)
                }
            }
            if(indexes.count > 0)
            {
                DispatchQueue.main.async{
                    self.chatTableView.reloadRows(at: indexes, with: .none)
                }
            }
        }
    }
    
    func updateSecrettimestamp()
    {
        if(Chat_type == "secret")
        {
            let from = Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
            let to = Themes.sharedInstance.CheckNullvalue(Passed_value: opponent_id)
            let  User_chat_id = to + "-" + from
            let P1 = NSPredicate(format: "user_common_id = %@", User_chat_id)
            let P2:NSPredicate = NSPredicate(format: "secret_timestamp == %@","")
            
            let P3:NSPredicate = NSPredicate(format: "chat_type == %@","secret")
            let p4:NSPredicate = NSPredicate(format: "from != %@",Themes.sharedInstance.Getuser_id())
            
            let status_update:NSCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [P1,P2,P3,p4])
            
            let fectchArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Chat_one_one, SortDescriptor: nil, predicate: status_update, Limit: 0) as! NSArray
            if(fectchArr.count > 0)
            {
                _ =  (fectchArr as! [NSManagedObject]).map{
                    let secret_msg_id = Themes.sharedInstance.CheckNullvalue(Passed_value: $0.value(forKey: "secret_msg_id"))
                    let doc_id = Themes.sharedInstance.CheckNullvalue(Passed_value: $0.value(forKey: "doc_id"))
                    let type = Themes.sharedInstance.CheckNullvalue(Passed_value: $0.value(forKey: "type"))
                    
                    
                    var expire_timestamp:String = ""
                    if(type == "13")
                    {
                        let incognito_timer_mode =  Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Secret_Chat, attrib_name: "doc_id", fetchString: doc_id, returnStr: "incognito_timer")
                        
                        if(incognito_timer_mode == "")
                        {
                            expire_timestamp = "\(Int64(String(Date().ticks))!)"
                        }
                        else
                        {
                            expire_timestamp = Themes.sharedInstance.returnupdatedSecrettimestamp(incognito_timer_mode: incognito_timer_mode)
                        }
                    }
                    else
                    {
                        let incognito_timer_mode =  Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Secret_Chat, attrib_name: "doc_id", fetchString: secret_msg_id, returnStr: "incognito_timer")
                        
                        
                        if(incognito_timer_mode == "")
                        {
                            expire_timestamp = "\(Int64(String(Date().ticks))!)"
                        }
                        else
                        {
                            expire_timestamp = Themes.sharedInstance.returnupdatedSecrettimestamp(incognito_timer_mode: incognito_timer_mode)
                        }
                        
                        
                    }
                    
                    let dict:NSDictionary = ["secret_timestamp":expire_timestamp]
                    let predicate:NSPredicate = NSPredicate(format: "doc_id == %@", Themes.sharedInstance.CheckNullvalue(Passed_value: $0.value(forKey: "doc_id")))
                    DatabaseHandler.sharedInstance.UpdateDataWithPredicate(Entityname: Constant.sharedinstance.Chat_one_one, predicate: predicate, UpdationElements: dict)
                    
                    
                }
            }
            
        }
        
    }
    
    func DidclickContentBtn(messagFrame: UUMessageFrame)
    {
        let objVC:DocViewController = self.storyboard?.instantiateViewController(withIdentifier: "DocViewControllerID") as! DocViewController
        objVC.webViewTitle = messagFrame.message.docName
        var id = messagFrame.message.thumbnail!
        if(id == "")
        {
            id = messagFrame.message.doc_id!
        }
        
        let upload_Path:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: id, upload_detail: "upload_Path") as! String
        
        let download_status:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: id, upload_detail: "download_status") as! String
        
        let serverpath:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: id, upload_detail: "serverpath") as! String
        
        
        if(download_status == "2"),(upload_Path != ""),FileManager.default.fileExists(atPath: upload_Path)
        {
            objVC.webViewURL = upload_Path
        }
        else
        {
            if download_status != "1"{
                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Upload_Details, FetchString: id, attribute: "upload_data_id", UpdationElements: ["download_status" : "0"])
                DownloadHandler.sharedinstance.handleDownLoad(true)
            }
            
            if(serverpath != "")
            {
                objVC.webViewURL = Themes.sharedInstance.getDownloadURL(serverpath)
            }
        }
        
        self.pushView(objVC, animated: true)
    }
    func uuInputFunctionView(_ funcView: UUInputFunctionView, sendMessage message: String)
    {
        guard !Themes.sharedInstance.checkBlock(id: opponent_id) else
        {
            Themes.sharedInstance.showBlockalert(id: opponent_id)
            return
        }
        
        var message = message.trimmingCharacters(in: .whitespacesAndNewlines)
        var is_tag = ""
        if(self.TagIdArr.count > 0)
        {
            is_tag = "1"
        }
        
        let user_common_id = opponent_id + "-" + Themes.sharedInstance.Getuser_id()
        
        let checkBool:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Secret_Chat, attribute: "user_common_id", FetchString: user_common_id)
        if(!checkBool && Chat_type == "secret")
        {
            self.time(time:"1 hour")
        }
        link_view.isHidden = true
        var secret_msg_id:String = ""
        if(message.removingWhitespaces() != "")
        {
            let from = Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
            let to = Themes.sharedInstance.CheckNullvalue(Passed_value: opponent_id)
            var user_common_id:String = ""
            if(Chat_type == "secret"){
                user_common_id = Themes.sharedInstance.CheckNullvalue(Passed_value: to + "-" + from)
                
                
                var checksecretmessagecount:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Secret_Chat, attribute: "user_common_id", FetchString: user_common_id, SortDescriptor: "timestamp") as! NSArray
                checksecretmessagecount = checksecretmessagecount.reversed() as NSArray
                
                if(checksecretmessagecount.count > 0)
                {
                    
                    secret_msg_id = Themes.sharedInstance.CheckNullvalue(Passed_value: (checksecretmessagecount[0] as! NSManagedObject).value(forKey: "doc_id"))
                }
            }else{
                user_common_id = Themes.sharedInstance.CheckNullvalue(Passed_value: from + "-" + to)
            }
            var timestamp:String = String(Date().ticks)
            var servertimeStr:String = Themes.sharedInstance.getServerTime()
            
            if(servertimeStr == "")
            {
                servertimeStr = "0"
            }
            let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
            timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
            if(self.TagIdArr.count > 0)
            {
                self.TagIdArr.forEach { id in
                    let index = self.TagIdArr.index(of: id)
                    message = message.replacingOccurrences(of: self.TagNameArr[index!], with: "@@***\(id)@@***")
                }
            }
            
            let Name:String=Themes.sharedInstance.setNameTxt(Themes.sharedInstance.Getuser_id(), "")
            let Phonenumber:String=Themes.sharedInstance.setPhoneTxt(Themes.sharedInstance.Getuser_id())
            
            var toDocId:String="\(from)-\(to)-\(timestamp)"
            if(Chat_type == "group")
            {
                toDocId = "\(from)-\(to)-g-\(timestamp)"
            }
            var dic:[AnyHashable: Any]
            
            
            if(isReplyMessage)
            {
                dic = ["type": "7","convId":"","doc_id":Themes.sharedInstance.CheckNullvalue(Passed_value:toDocId
                    ),"filesize":"","from":Themes.sharedInstance.CheckNullvalue(Passed_value:from
                    ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:to
                    ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
                    ),"message_status":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
                    ),"id":timestamp,"name":Themes.sharedInstance.CheckNullvalue(Passed_value:Name
                    ),"payload":Themes.sharedInstance.CheckNullvalue(Passed_value:message
                    ),"recordId":"","timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
                    ),"thumbnail":"","width":"0.0","height":"0.0","msgId":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
                    ),"contactmsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value:Phonenumber
                    ),"user_common_id":Themes.sharedInstance.CheckNullvalue(Passed_value:from + "-" + to
                    ),"message_from":"1","chat_type":Chat_type,"info_type":"0","created_by":from,"is_reply":"1","secret_msg_id":secret_msg_id,"secret_timestamp":"", "date" : Themes.sharedInstance.getTimeStamp(), "while_blocked" : Themes.sharedInstance.isImBlocked(to) ? "1" : "0"]
                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: dic as NSDictionary,Entityname: Constant.sharedinstance.Chat_one_one)

                var Fromid:String = String()
                var CompressedData:String = String()
                
                Fromid = ReplyMessageRecord.message.doc_id.components(separatedBy: "-").first!
                
                
                if(ReplyMessageRecord.message.type == MessageType(rawValue: 1)! || ReplyMessageRecord.message.type == MessageType(rawValue: 2)! || ReplyMessageRecord.message.type == MessageType(rawValue: 3)! || ReplyMessageRecord.message.type == MessageType(rawValue: 6)! || ReplyMessageRecord.message.type == MessageType(rawValue: 4)!)
                {
                    CompressedData = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Upload_Details, attrib_name: "upload_data_id", fetchString: ReplyMessageRecord.message.thumbnail, returnStr: "compressed_data")
                }
                else
                {
                    CompressedData = ""
                }
                
                let recordID:String = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_one_one, attrib_name: "msgId", fetchString: ReplyMessageRecord.message.msgId, returnStr: "recordId")
                if(ReplyMessageRecord.message.type == MessageType(rawValue: 5)! ){
                    let Dict:NSDictionary = ["compressed_data":CompressedData,"from_id":Fromid,"recordId":recordID,"message_type":ReplyMessageRecord.message.message_type,"payload":ReplyMessageRecord.message.contact_name,"contactmsisdn":ReplyMessageRecord.message.contactmsisdn,"doc_id":Themes.sharedInstance.CheckNullvalue(Passed_value:toDocId
                        )]
                    DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict, Entityname: Constant.sharedinstance.Reply_detail)
                }else if(ReplyMessageRecord.message.type == MessageType(rawValue: 6)!){
                    let Dict:NSDictionary = ["compressed_data":CompressedData,"from_id":Fromid,"recordId":recordID,"message_type":ReplyMessageRecord.message.message_type,"payload":ReplyMessageRecord.message.docName!,"contactmsisdn":ReplyMessageRecord.message.contactmsisdn,"doc_id":Themes.sharedInstance.CheckNullvalue(Passed_value:toDocId
                        )]
                    DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict, Entityname: Constant.sharedinstance.Reply_detail)
                }else{
                    let Dict:NSDictionary = ["compressed_data":CompressedData,"from_id":Fromid,"recordId":recordID,"message_type":ReplyMessageRecord.message.message_type,"payload":ReplyMessageRecord.message.payload,"contactmsisdn":ReplyMessageRecord.message.contactmsisdn,"doc_id":Themes.sharedInstance.CheckNullvalue(Passed_value:toDocId
                        )]
                    DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict, Entityname: Constant.sharedinstance.Reply_detail)
                }
                
            }
            else  if(isFromUrl)
            {
                
                dic = ["type": "4","convId":"","doc_id":Themes.sharedInstance.CheckNullvalue(Passed_value:toDocId
                    ),"filesize":"","from":Themes.sharedInstance.CheckNullvalue(Passed_value:from
                    ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:to
                    ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
                    ),"message_status":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
                    ),"id":timestamp,"name":Themes.sharedInstance.CheckNullvalue(Passed_value:Name
                    ),"payload":Themes.sharedInstance.CheckNullvalue(Passed_value:message
                    ),"recordId":"","timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
                    ),"thumbnail":"","width":"0.0","height":"0.0","msgId":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
                    ),"contactmsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value:Phonenumber
                    ),"user_common_id":user_common_id,"message_from":"1","chat_type":Chat_type,"info_type":"0","created_by":from,"title":Themes.sharedInstance.CheckNullvalue(Passed_value: Title_str),"image_url":Themes.sharedInstance.CheckNullvalue(Passed_value: ImageURl),"desc":Themes.sharedInstance.CheckNullvalue(Passed_value: Desc),"url_str":Themes.sharedInstance.CheckNullvalue(Passed_value: Url_str),"secret_msg_id":secret_msg_id,"secret_timestamp":"", "date" : Themes.sharedInstance.getTimeStamp(), "while_blocked" : Themes.sharedInstance.isImBlocked(to) ? "1" : "0"]
                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: dic as NSDictionary,Entityname: Constant.sharedinstance.Chat_one_one)

                let link_dic:[AnyHashable: Any] = ["doc_id":Themes.sharedInstance.CheckNullvalue(Passed_value:toDocId
                    ),"title":Themes.sharedInstance.CheckNullvalue(Passed_value: Title_str),"thumbnail_data":Themes.sharedInstance.CheckNullvalue(Passed_value: ImageURl),"image_url":Themes.sharedInstance.CheckNullvalue(Passed_value: ImageURl),"desc":Themes.sharedInstance.CheckNullvalue(Passed_value: Desc),"url_str":Themes.sharedInstance.CheckNullvalue(Passed_value: Url_str)]
                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: link_dic as NSDictionary,Entityname: Constant.sharedinstance.Link_details)
                
                
            }
            else
            {
                dic = ["type": "0","convId":"","doc_id":Themes.sharedInstance.CheckNullvalue(Passed_value:toDocId
                    ),"filesize":"","from":Themes.sharedInstance.CheckNullvalue(Passed_value:from
                    ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:to
                    ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
                    ),"message_status":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
                    ),"id":timestamp,"name":Themes.sharedInstance.CheckNullvalue(Passed_value:Name
                    ),"payload":Themes.sharedInstance.CheckNullvalue(Passed_value:message
                    ),"recordId":"","timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
                    ),"thumbnail":"","width":"0.0","height":"0.0","msgId":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
                    ),"contactmsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value:Phonenumber
                    ),"user_common_id":user_common_id,"message_from":"1","chat_type":Chat_type,"info_type":"0","created_by":from,"is_reply":"0","secret_msg_id":secret_msg_id,"secret_timestamp":"", "date" : Themes.sharedInstance.getTimeStamp(), "while_blocked" : Themes.sharedInstance.isImBlocked(to) ? "1" : "0"]
                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: dic as NSDictionary,Entityname: Constant.sharedinstance.Chat_one_one)
            }
            
            if(Chat_type == "secret"){
                let chatarray:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: to + "-" + from)
                if(!chatarray)
                {
                    let User_dict:[AnyHashable: Any] = ["user_common_id": to + "-" + from,"user_to_dp":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_type":Chat_type,"is_archived":"0","conv_id":"","timestamp":timestamp,"opponent_id":to,"is_read":"0","chat_count":"0"]
                    DatabaseHandler.sharedInstance.InserttoDatabase(Dict: User_dict as NSDictionary,Entityname: Constant.sharedinstance.Chat_intiated_details)
                    
                }
                else
                {
                    let User_dict:[AnyHashable: Any]=["timestamp":timestamp,"is_archived":"0","is_read":"0","user_id":Themes.sharedInstance.Getuser_id()]
                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: to + "-" + from , attribute: "user_common_id", UpdationElements: User_dict as NSDictionary?)
                }
            }else{
                let chatarray:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: from + "-" + to)
                if(!chatarray)
                {
                    let User_dict:[AnyHashable: Any] = ["user_common_id": from + "-" + to,"user_to_dp":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_type":Chat_type,"is_archived":"0","conv_id":"","timestamp":timestamp,"opponent_id":to,"is_read":"0","chat_count":"0"]
                    DatabaseHandler.sharedInstance.InserttoDatabase(Dict: User_dict as NSDictionary,Entityname: Constant.sharedinstance.Chat_intiated_details)
                    
                }
                else
                {
                    let User_dict:[AnyHashable: Any]=["timestamp":timestamp,"is_archived":"0","is_read":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_count":"0"]
                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: from + "-" + to , attribute: "user_common_id", UpdationElements: User_dict as NSDictionary?)
                }
            }
            funcView.textView.text = ""
            if(isReplyMessage)
            {
                let recordID:String = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_one_one, attrib_name: "msgId", fetchString: ReplyMessageRecord.message.msgId, returnStr: "recordId")
                if(Chat_type == "single")
                {
                    
                    let ReplyDict:[AnyHashable: Any] = ["from":Themes.sharedInstance.Getuser_id(),"to":to,"type":"0","payload":EncryptionHandler.sharedInstance.encryptmessage(str: message.decoded,toid:to, chat_type: Chat_type),"toDocId":EncryptionHandler.sharedInstance.encryptmessage(str: toDocId,toid:to, chat_type: Chat_type),"id":EncryptionHandler.sharedInstance.encryptmessage(str:timestamp,toid:to, chat_type: self.Chat_type),"recordId":recordID]
                    SocketIOManager.sharedInstance.EmitReplyMessage(param: ReplyDict as NSDictionary)
                }
                else if(Chat_type == "secret"){
                    let ReplyDict:[AnyHashable: Any] = ["from":Themes.sharedInstance.Getuser_id(),"to":to,"type":"0","payload": EncryptionHandler.sharedInstance.encryptmessage(str: message.decoded,toid:to, chat_type: Chat_type),"toDocId":EncryptionHandler.sharedInstance.encryptmessage(str: toDocId,toid:to, chat_type: Chat_type),"id":EncryptionHandler.sharedInstance.encryptmessage(str:timestamp,toid:to, chat_type: self.Chat_type),"recordId":recordID,"chat_type":"secret"]
                    SocketIOManager.sharedInstance.EmitReplyMessage(param: ReplyDict as NSDictionary)
                }
                else
                {
                    let displayName = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Group_details, attrib_name: "id", fetchString: to, returnStr: "displayName")
                    
                    let ReplyDict:[AnyHashable: Any] = ["from":Themes.sharedInstance.Getuser_id(),"to":to,"type":"0","payload":EncryptionHandler.sharedInstance.encryptmessage(str: message.decoded,toid:to, chat_type: Chat_type),"toDocId":EncryptionHandler.sharedInstance.encryptmessage(str: toDocId,toid:to, chat_type: Chat_type),"id": EncryptionHandler.sharedInstance.encryptmessage(str: timestamp,toid:to, chat_type: Chat_type),"recordId":recordID,"groupType":"18","userName":displayName,"convId":to, "is_tag_applied" : is_tag]
                    
                    SocketIOManager.sharedInstance.EmitGroupReplyMessage(param: ReplyDict as NSDictionary)
                }
                PassCloseAction()
                
            }
            else if(Chat_type == "single" || Chat_type == "secret")
            {
                if(isFromUrl == false)
                {
                    if(Chat_type == "single"){
                        let secrettype:String = Themes.sharedInstance.returnisSecret(user_id: to)
                        SocketIOManager.sharedInstance.SendMessage(from: Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id()), to: to, payload: message, type: "0", timestamp: timestamp, DocID:toDocId,thumbnail: "",thumbnail_data: "",filesize: "",height: "0",width: "0",doc_name:"",numPages: "", duration: "", is_secret_chat: secrettype)
                    }else{
                        SocketIOManager.sharedInstance.secretMessage(from: Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id()), to: to, payload: message, type: "0", timestamp: timestamp, DocID:toDocId,thumbnail: "",thumbnail_data: "",filesize: "",height: "0",width: "0",doc_name:"",numPages: "", duration: "",chat_type: self.Chat_type)
                    }
                }
                else
                {
                    var base64str:String = ""
                    SDWebImageManager.shared().imageDownloader?.downloadImage(with: URL(string:ImageURl), options: .highPriority, progress: nil, completed: { (image:UIImage?, data:Data?, erro:Error?, downloaded:Bool) in
                        if(image != nil)
                        {
                            let imageData:Data = image!.jpegData(compressionQuality: 1.0)!
                            base64str = Themes.sharedInstance.convertImageToBase64(imageData:imageData)
                        }
                    })
                    let param:NSDictionary = ["title":Themes.sharedInstance.CheckNullvalue(Passed_value: self.Title_str),"host":"","url":Themes.sharedInstance.CheckNullvalue(Passed_value: self.Url_str),"description":Themes.sharedInstance.CheckNullvalue(Passed_value:self.Desc).decoded,"image":Themes.sharedInstance.CheckNullvalue(Passed_value:self.ImageURl),"thumbnail_data":Themes.sharedInstance.CheckNullvalue(Passed_value:base64str)]
                    
                    let metadict  = param
                    
                    if(Chat_type == "single"){
                        let Dict:Dictionary = ["from":Themes.sharedInstance.Getuser_id(),"to":to,"payload": EncryptionHandler.sharedInstance.encryptmessage(str: message.decoded,toid:to, chat_type: Chat_type)
                            ,"id":EncryptionHandler.sharedInstance.encryptmessage(str:timestamp,toid:to, chat_type: Chat_type),"type":"4","toDocId":EncryptionHandler.sharedInstance.encryptmessage(str:toDocId,toid:to, chat_type: Chat_type),"metaDetails":metadict] as [String : Any]
                        SocketIOManager.sharedInstance.EmitMessage(param: Dict)
                    }else{
                        let Dict:Dictionary = ["from":Themes.sharedInstance.Getuser_id(),"to":to,"payload": EncryptionHandler.sharedInstance.encryptmessage(str: message.decoded,toid:to, chat_type: Chat_type)
                            ,"id":EncryptionHandler.sharedInstance.encryptmessage(str:timestamp,toid:to, chat_type: Chat_type),"type":"4","toDocId":EncryptionHandler.sharedInstance.encryptmessage(str:toDocId,toid:to, chat_type: Chat_type),"metaDetails":metadict,"chat_type":self.Chat_type] as [String : Any]
                        SocketIOManager.sharedInstance.EmitMessage(param: Dict)
                    }
                    
                }
                
            }
            else  if(Chat_type == "group")
            {
                if(isFromUrl == false){
                    let Groupdic:[AnyHashable: Any] = ["from":Themes.sharedInstance.Getuser_id(),"to":to,"type":"0","payload":EncryptionHandler.sharedInstance.encryptmessage(str: message.decoded,toid:to, chat_type: Chat_type),"convId":to,"toDocId":EncryptionHandler.sharedInstance.encryptmessage(str:toDocId,toid:to, chat_type: Chat_type),"groupType":"9","userName":Themes.sharedInstance.CheckNullvalue(Passed_value: Group_name_Lbl.text),"id":EncryptionHandler.sharedInstance.encryptmessage(str:Themes.sharedInstance.CheckNullvalue(Passed_value: timestamp),toid:to, chat_type: Chat_type), "is_tag_applied" : is_tag]
                    SocketIOManager.sharedInstance.SendMessage_group(param: Groupdic as NSDictionary)
                }else{
                    var base64str:String = ""
                    SDWebImageManager.shared().imageDownloader?.downloadImage(with: URL(string:ImageURl), options: .highPriority, progress: nil, completed: { (image:UIImage?, data:Data?, erro:Error?, downloaded:Bool) in
                        if(image != nil)
                        {
                            let imageData:Data = image!.jpegData(compressionQuality: 1.0)!
                            base64str = Themes.sharedInstance.convertImageToBase64(imageData:imageData)
                        }
                    })
                    
                    let param:NSDictionary = ["title":Themes.sharedInstance.CheckNullvalue(Passed_value: self.Title_str),"host":"","url":Themes.sharedInstance.CheckNullvalue(Passed_value: self.Url_str),"description":Themes.sharedInstance.CheckNullvalue(Passed_value:self.Desc).decoded,"image":Themes.sharedInstance.CheckNullvalue(Passed_value:self.ImageURl),"thumbnail_data":Themes.sharedInstance.CheckNullvalue(Passed_value:base64str)]
                    
                    let metadict  = param
                    
                    let displayName = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Group_details, attrib_name: "id", fetchString: to, returnStr: "displayName")
                    let Dict:Dictionary = ["from":Themes.sharedInstance.Getuser_id(),"to":to,"payload": EncryptionHandler.sharedInstance.encryptmessage(str: message.decoded,toid:to, chat_type: Chat_type),"id":EncryptionHandler.sharedInstance.encryptmessage(str:timestamp,toid:to, chat_type: Chat_type),"type":"4","toDocId":EncryptionHandler.sharedInstance.encryptmessage(str:toDocId,toid:to, chat_type: Chat_type),"metaDetails":metadict,"groupType":"9","userName":displayName,"convId":to, "is_tag_applied" : is_tag] as [String : Any]
                    SocketIOManager.sharedInstance.Groupevent(param: Dict)
                    
                }
            }
            
            DispatchQueue.main.async {
                self.dealTheFunctionData(dic, fromOrdering: false)
            }
            self.TagIdArr.removeAll()
            self.TagPersonRange.removeAll()
            self.TagNameArr.removeAll()
            funcView.changeSendBtn(withPhoto: true)
        }
        self.link_str = ""
        self.Title_str = ""
        self.ImageURl = ""
        self.Desc = ""
        self.Url_str = ""
        self.link_view.title_Str = ""
        self.link_view.image_Url = ""
        self.link_view.desc_Str = ""
        self.link_str = ""
        self.isFromUrl = false
    }
    
    func uuInputFunctionView(_ funcView: UUInputFunctionView, sendPicture image: UIImage) {
        //    self.dealTheFunctionData(dic)
    }
    func SaveAudioFile(voice: Data,seconds:Int)->NSDictionary
    {
        let from = Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
        let to = Themes.sharedInstance.CheckNullvalue(Passed_value: opponent_id)
        var timestamp:String =  String(Date().ticks)
        var servertimeStr:String = Themes.sharedInstance.getServerTime()
        
        if(servertimeStr == "")
        {
            servertimeStr = "0"
        }
        let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
        timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
        var User_chat_id="";
        if(Chat_type == "secret"){
            User_chat_id = to + "-" + from
        }else{
            User_chat_id = from + "-" + to
        }
        
        var AssetName:String = "\(User_chat_id)-\(timestamp).mp3"
        
        if(Chat_type == "group")
        {
            AssetName = "\(User_chat_id)-g-\(timestamp).mp3"
        }
        let Path:String =  Filemanager.sharedinstance.SaveImageFile(imagePath: "\(Constant.sharedinstance.voicepath)/\(AssetName)",imagedata: voice)
        
        var splitcount:Int = voice.count / Constant.sharedinstance.SendbyteCount
        if(splitcount < 1)
        {
            splitcount = 1
        }
        let uploadDataCount:String = UploadHandler.Sharedinstance.getArrayOfBytesFromImage(voice, splitCount: splitcount)
        
        let imagecount:Int = voice.count
        let Dict:[String:Any] = ["failure_status":"0","total_byte_count":"\(imagecount)","upload_byte_count":"0","upload_count":"1","upload_data_id":AssetName,"upload_Path":Path,"upload_status":"0","user_common_id":User_chat_id,"serverpath":"","user_id":Themes.sharedInstance.Getuser_id(),"data_count":uploadDataCount,"compressed_data":"","to_id":to,"message_status":"0","timestamp":timestamp,"total_data_count":"\(Constant.sharedinstance.MultiFormDataSplitCount)","width":"0.0","height":"0.0","upload_type":"3","download_status":"2","strVoiceTime":"\(seconds)","is_uploaded":"1", "upload_paused":"0"]
        DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict as NSDictionary, Entityname: Constant.sharedinstance.Upload_Details);
        let param:NSDictionary = ["id":AssetName,"pathname":Path]
        return param
    }
    func uuInputFunctionView(_ funcView: UUInputFunctionView, sendVoice voice: Data, time second: Int) {
        guard !Themes.sharedInstance.checkBlock(id: opponent_id) else
        {
            Themes.sharedInstance.showBlockalert(id: opponent_id)
            return
        }
        var secret_msg_id:String = ""
        var user_common_id = opponent_id + "-" + Themes.sharedInstance.Getuser_id()
        let checkBool:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Secret_Chat, attribute: "user_common_id", FetchString: user_common_id)
        if(!checkBool && Chat_type == "secret")
        {
            self.time(time:"1 hour")
        }
        let from = Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
        let to = Themes.sharedInstance.CheckNullvalue(Passed_value: opponent_id)
        var timestamp:String =  String(Date().ticks)
        var servertimeStr:String = Themes.sharedInstance.getServerTime()
        
        user_common_id = ""
        if(Chat_type == "secret"){
            user_common_id = Themes.sharedInstance.CheckNullvalue(Passed_value: to + "-" + from)
            var checksecretmessagecount:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Secret_Chat, attribute: "user_common_id", FetchString: user_common_id, SortDescriptor: "timestamp") as! NSArray
            checksecretmessagecount = checksecretmessagecount.reversed() as NSArray
            
            if(checksecretmessagecount.count > 0)
            {
                
                secret_msg_id = Themes.sharedInstance.CheckNullvalue(Passed_value: (checksecretmessagecount[0] as! NSManagedObject).value(forKey: "doc_id"))
            }
        }else{
            user_common_id = Themes.sharedInstance.CheckNullvalue(Passed_value: from + "-" + to)
        }
        if(servertimeStr == "")
        {
            servertimeStr = "0"
        }
        let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
        timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
        let InfoDict:NSDictionary = self.SaveAudioFile(voice: voice,seconds: second)
        let PathName:String = InfoDict.object(forKey: "id") as! String
        let Name:String=Themes.sharedInstance.setNameTxt(Themes.sharedInstance.Getuser_id(), "")
        let Phonenumber:String=Themes.sharedInstance.setPhoneTxt(Themes.sharedInstance.Getuser_id())
        var toDocId:String="\(from)-\(to)-\(timestamp)"
        
        if(Chat_type == "group")
        {
            toDocId = "\(from)-\(to)-g-\(timestamp)"
        }
        let dic:[AnyHashable: Any] = ["type": "3","convId":"","doc_id":Themes.sharedInstance.CheckNullvalue(Passed_value:toDocId
            ),"filesize":"","from":Themes.sharedInstance.CheckNullvalue(Passed_value:from
            ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:to
            ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
            ),"message_status":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
            ),"id":timestamp,"name":Themes.sharedInstance.CheckNullvalue(Passed_value:Name
            ),"payload":"Audio","recordId":"","timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
            ),"thumbnail":"\(PathName)","width":"0.0","height":"0.0","msgId":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
            ),"contactmsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value:Phonenumber
            ),"user_common_id":user_common_id,"message_from":"1","chat_type":Chat_type,"info_type":"0","created_by":from,"is_reply":"0","secret_msg_id":secret_msg_id,"secret_timestamp":"", "date" : Themes.sharedInstance.getTimeStamp(), "while_blocked" : Themes.sharedInstance.isImBlocked(to) ? "1" : "0"]
        
        DatabaseHandler.sharedInstance.InserttoDatabase(Dict: dic as NSDictionary,Entityname: Constant.sharedinstance.Chat_one_one)

        if(Chat_type == "secret"){
            let chatarray:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: to + "-" + from)
            if(!chatarray)
            {
                let User_dict:[AnyHashable: Any] = ["user_common_id": to + "-" + from,"user_to_dp":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_type":Chat_type,"is_archived":"0","conv_id":"","timestamp":timestamp,"opponent_id":to,"is_read":"0","chat_count":"0"]
                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: User_dict as NSDictionary,Entityname: Constant.sharedinstance.Chat_intiated_details)
                
            }
            else
            {
                let User_dict:[AnyHashable: Any]=["timestamp":timestamp,"is_archived":"0","is_read":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_count":"0"]
                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: to + "-" + from , attribute: "user_common_id", UpdationElements: User_dict as NSDictionary?)
            }
        }else{
            let chatarray:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: from + "-" + to)
            if(!chatarray)
            {
                let User_dict:[AnyHashable: Any] = ["user_common_id": from + "-" + to,"user_to_dp":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_type":Chat_type,"is_archived":"0","conv_id":"","timestamp":timestamp,"opponent_id":to,"is_read":"0","chat_count":"0"]
                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: User_dict as NSDictionary,Entityname: Constant.sharedinstance.Chat_intiated_details)
                
            }
            else
            {
                let User_dict:[AnyHashable: Any]=["timestamp":timestamp,"is_archived":"0","is_read":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_count":"0"]
                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: from + "-" + to , attribute: "user_common_id", UpdationElements: User_dict as NSDictionary?)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            self.dealTheFunctionData(dic, fromOrdering: false)
            
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            UploadHandler.Sharedinstance.handleUpload()
        }
    }
    
    func dealTheFunctionData(_ dic: [AnyHashable: Any], fromOrdering : Bool) {
        
        if(chatModel.dataSource.count > 0)
        {
            if let messageFrame = self.chatModel.dataSource[chatModel.dataSource.count - 1] as? UUMessageFrame {
                let timestamp:String = Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message.timestamp)
                if(timestamp != "")
                {
                    let presenttimestamp:String =  Themes.sharedInstance.CheckNullvalue(Passed_value: dic["timestamp"])
                    let Prevdate:Date = Themes.sharedInstance.ConverttimeStamptodateentity(timestamp: timestamp) as Date
                    let Presentdate:Date = Themes.sharedInstance.ConverttimeStamptodateentity(timestamp: presenttimestamp) as Date
                    var components:Int! = Themes.sharedInstance.ReturnNumberofDays(fromdate:Prevdate , todate: Presentdate)
                    if(components == 0)
                    {
                        if(!Calendar.current.isDate(Prevdate, inSameDayAs: Presentdate))
                        {
                            components = 1
                        }
                    }
                    if components != 0 {
                        let dic:[AnyHashable: Any] = ["type": "0","convId":"","doc_id":"","filesize":"","from":""
                            ,"to":"","isStar":"","message_status":"","id":"","name":"","payload":"","recordId":"","timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:dic["timestamp"]),"thumbnail":"","width":"0.0","height":"0.0","msgId":""
                            ,"contactmsisdn":"","user_common_id":"","message_from":"","chat_type":"","info_type":"10","created_by":""]
                        self.chatModel.addSpecifiedItem(dic, isPagination: false)
                        if(!fromOrdering)
                        {
                            self.chatTableView.insertRows(at: [IndexPath(row: self.chatModel.dataSource.count-1, section: 0)], with: .fade)
                        }
                    }
                }
            }
            
        }
        else
        {
            let dic:[AnyHashable: Any] = ["type": "0","convId":"","doc_id":"","filesize":"","from":""
                ,"to":"","isStar":"","message_status":"","id":"","name":"","payload":"","recordId":"","timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:dic["timestamp"]),"thumbnail":"","width":"0.0","height":"0.0","msgId":""
                ,"contactmsisdn":"","user_common_id":"","message_from":"","chat_type":"","info_type":"10","created_by":""]
            self.chatModel.addSpecifiedItem(dic, isPagination: false)
            if(!fromOrdering)
            {
                self.chatTableView.insertRows(at: [IndexPath(row: self.chatModel.dataSource.count-1, section: 0)], with: .fade)
            }
        }
        self.chatModel.addSpecifiedItem(dic, isPagination: false)
        if(!fromOrdering)
        {
            self.chatTableView.insertRows(at: [IndexPath(row: self.chatModel.dataSource.count-1, section: 0)], with: .fade)
            if(self.chatTableView.numberOfRows(inSection: 0) > 0)
            {
                let indexPath = IndexPath(row: self.chatTableView.numberOfRows(inSection: 0)-1, section: 0)
                self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            }
        }
        
        //        DispatchQueue.main.asyncAfter(deadline: .now()+0.2, execute: {
        //            self.setTail()
        //        })
        self.setTail(isAtBottom: true)
    }
    
    func setTail(isAtBottom:Bool){
        guard self.chatModel.dataSource.count > 1 else{
            if chatModel.dataSource.count == 1, let newMessage = chatModel.dataSource.lastObject as? UUMessageFrame{
                newMessage.message.isLastMessage = true
            }
            return}
        if isAtBottom{
            guard let lastMessage = self.chatModel.dataSource.lastObject as? UUMessageFrame else{return}
            guard let previousMessage = self.chatModel.dataSource[self.chatModel.dataSource.count-2] as? UUMessageFrame else{return}
            
            lastMessage.message.isLastMessage = true
            previousMessage.message.isLastMessage = !(previousMessage.message.from == lastMessage.message.from)
            
            guard chatTableView.numberOfRows(inSection: 0) > 1 else{return}
            let lastCell = chatTableView.cellForRow(at: IndexPath(row: chatTableView.numberOfRows(inSection: 0)-1, section: 0))
            let previousCell = chatTableView.cellForRow(at: IndexPath(row: chatTableView.numberOfRows(inSection: 0)-2, section: 0))
            
            (lastCell as? CustomTableViewCell)?.bubleImage = (lastMessage.message.from == MessageFrom(rawValue: 1)) ? "inBubble" : "outBubble"
            
            (previousCell as? CustomTableViewCell)?.bubleImage = (previousMessage.message.from == MessageFrom(rawValue: 1)) ? "inBubble" : "outBubble"
        }else{
            guard let newMessage = self.chatModel.dataSource.firstObject as? UUMessageFrame else{return}
            guard let previousMessage = self.chatModel.dataSource[1] as? UUMessageFrame else{return}
            newMessage.message.isLastMessage = !(newMessage.message.from.rawValue == previousMessage.message.from.rawValue)
            
        }
        
        
    }
    
    func dealTheFunctionData1(_ dic: [AnyHashable: Any]) {
        if(chatModel.dataSource.count > 0)
        {
            if let messageFrame = self.chatModel.dataSource[chatModel.dataSource.count - 1] as? UUMessageFrame {
                let timestamp:String = Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message.timestamp)
                if(timestamp != "")
                {
                    let presenttimestamp:String =  Themes.sharedInstance.CheckNullvalue(Passed_value: dic["timestamp"])
                    let Prevdate:Date = Themes.sharedInstance.ConverttimeStamptodateentity(timestamp: timestamp) as Date
                    let Presentdate:Date = Themes.sharedInstance.ConverttimeStamptodateentity(timestamp: presenttimestamp) as Date
                    var components:Int! = Themes.sharedInstance.ReturnNumberofDays(fromdate:Prevdate , todate: Presentdate)
                    if(components == 0)
                    {
                        if(!Calendar.current.isDate(Prevdate, inSameDayAs: Presentdate))
                        {
                            components = 1
                        }
                    }
                    if components != 0 {
                        let dic:[AnyHashable: Any] = ["type": "0","convId":"","doc_id":"","filesize":"","from":""
                            ,"to":"","isStar":"","message_status":"","id":"","name":"","payload":"","recordId":"","timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:dic["timestamp"]),"thumbnail":"","width":"0.0","height":"0.0","msgId":""
                            ,"contactmsisdn":"","user_common_id":"","message_from":"","chat_type":"","info_type":"10","created_by":""]
                        self.chatModel.addSpecifiedItem(dic, isPagination: true)
                    }
                }
            }
            
        }
        else
        {
            let dic:[AnyHashable: Any] = ["type": "0","convId":"","doc_id":"","filesize":"","from":""
                ,"to":"","isStar":"","message_status":"","id":"","name":"","payload":"","recordId":"","timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:dic["timestamp"]),"thumbnail":"","width":"0.0","height":"0.0","msgId":""
                ,"contactmsisdn":"","user_common_id":"","message_from":"","chat_type":"","info_type":"10","created_by":""]
            self.chatModel.addSpecifiedItem(dic, isPagination: true)
        }
        self.chatModel.addSpecifiedItem(dic, isPagination: true)
        
        
        setTail(isAtBottom: false)
        
    }
    
    
    func playerTime(_ TotalDuration: Double, currentime CurrentTime: Double) {
        
        let indexpath = NSIndexPath.init(row: pause_row, section: 0)
        
        if let cellItem = chatTableView.cellForRow(at: indexpath as IndexPath) as? UUMessageCell {
            cellItem.total = TotalDuration
            //self.messageFrame.message.progress = "\(CurrentTime)"
            
            cellItem.btnContent.myProgressView.maximumValue = Float(TotalDuration)
            
            //&& !slidePlay
            if(!(cellItem.slideMove)){
                
                let min = CurrentTime/60;
                let sec = CurrentTime.truncatingRemainder(dividingBy: 60) ;
                cellItem.btnContent.second.text = String(format: "%02d:%02d", Int(min),Int(sec))
                //                cellItem?.audio.player.currentTime = CurrentTime
                cellItem.messageFrame.message.progress = "\(CurrentTime)"
                
                if(CurrentTime == 0.0){
                    let min = TotalDuration/60;
                    let sec = TotalDuration.truncatingRemainder(dividingBy: 60) ;
                    cellItem.btnContent.second.text = String(format: "%02d:%02d", Int(min),Int(sec))
                }
                
                cellItem.btnContent.myProgressView.value = Float(CurrentTime)
                
            }
        }
        
    }
    
    func uuavAudioPlayerBeiginPlay()
    {
        let indexpath = NSIndexPath.init(row: pause_row, section: 0)
        
        let cellItem:UUMessageCell? = chatTableView.cellForRow(at: indexpath as IndexPath) as? UUMessageCell
        if(cellItem != nil){
            UIDevice.current.isProximityMonitoringEnabled = true
            cellItem?.btnContent.didLoadVoice()
        }
        
    }
    
    func PausePlayingAudioIfAny()
    {
        UIDevice.current.isProximityMonitoringEnabled = false
        
        if(audioPlayBtn != nil)
        {
            audioPlayBtn?.isSelected = false
            guard let index = AudioManager.sharedInstence.currentIndex else{return}
            AudioManager.sharedInstence.StopPlayer()
            guard self.chatModel.dataSource.count > index.row else{return}
            DispatchQueue.main.async{
                self.chatTableView.reloadRows(at: [index], with: .none)
            }
        }
    }
    
    func PasReplyDetail(index:IndexPath,ReplyRecordID:String, isStatus: Bool)
    {
        if(isStatus)
        {
            self.navigateToStatus(index: index, recordId: ReplyRecordID)
        }
        else
        {
            
            let messageFrame = (chatModel.dataSource as! [UUMessageFrame]).filter({$0.message.recordId  == ReplyRecordID}).first
            if(messageFrame != nil)
            {
                let index = chatModel.dataSource.index(of: messageFrame!)
                let indexPath = IndexPath(row: index, section: 0)
                self.chatTableView.scrollToRow(at: indexPath, at: .top, animated: false)
            }
        }
    }
    
    func PasPersonDetail(id: String) {
        let singleInfoVC:SingleInfoViewController=self.storyboard?.instantiateViewController(withIdentifier: "SingleInfoViewController") as! SingleInfoViewController
        singleInfoVC.user_id = Themes.sharedInstance.CheckNullvalue(Passed_value: id)
        singleInfoVC.dataSource = self.chatModel.dataSource
        self.pushView(singleInfoVC, animated: true)
    }
    
    func navigateToStatus(index: IndexPath,recordId : String)
    {
        
        let P1:NSPredicate = NSPredicate(format: "recordId = %@", recordId)
        let fetch_predicate:NSCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [P1])
        var id = ""
        var ChatArr = DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Status_one_one, SortDescriptor: "timestamp", predicate:fetch_predicate, Limit: 0) as! [NSManagedObject]
        if(ChatArr.count > 0)
        {
            let descriptor: NSSortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
            ChatArr = (ChatArr as NSArray).sortedArray(using: [descriptor]) as! [NSManagedObject]
            _ = ChatArr.map {
                let ResponseDict = $0
                var dic = [AnyHashable: Any]()
                id = Themes.sharedInstance.CheckNullvalue(Passed_value:ResponseDict.value(forKey: "user_common_id"))
                dic  = ["type": Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "type")),"convId":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "convId")),"doc_id":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id")),"filesize":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "filesize")),"from":Themes.sharedInstance.CheckNullvalue(Passed_value:ResponseDict.value(forKey: "from")
                    ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:ResponseDict.value(forKey: "to")
                    ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "isStar")),"message_status":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "message_status")),"id":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "id")),"name":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "name")),"payload":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "payload"))
                    ,"recordId":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "recordId")),"thumbnail":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "thumbnail")),"width":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "width")),"height":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "height")),"msgId":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "msgId")),"contactmsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "contactmsisdn"))
                    ,"user_common_id":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "user_common_id"))
                    ,"timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "timestamp")),"message_from":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "message_from")),"info_type":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "info_type")),"chat_type":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "chat_type")), "is_deleted" : Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "is_deleted")), "is_viewed" : Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "is_viewed")),"theme_color":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "theme_color")),"theme_font":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "theme_font")), "duration" : Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "duration"))]
                
                
                
                let messageFrame = UUMessageFrame()
                let message = UUMessage()
                var dataDic = dic
                dataDic["strTime"] = Date().description
                message.setWithDict(dataDic)
                message.minuteOffSetStart(previousTime, end: dataDic["strTime"] as! String?)
                messageFrame.showTime = message.showDateLabel
                messageFrame.message = message
                if (messageFrame.message.type == MessageType(rawValue: 1)!) {
                    messageFrame.message.progress = "0"
                }
                else if (messageFrame.message.type == MessageType(rawValue: 2)!) {
                    messageFrame.message.progress = "0"
                }
                
                if(id == Themes.sharedInstance.Getuser_id())
                {
                    center = self.view.center
                    let vc = storyboard?.instantiateViewController(withIdentifier: "StatusPageViewController") as! StatusPageViewController
                    vc.isMyStatus = true
                    vc.idArr = [id]
                    vc.ChatRecorDict = [id : [messageFrame]]
                    vc.startIndex = 0
                    vc.customDelegate = self
                    self.presentView(vc, animated: true)
                }
                else
                {
                    center = self.view.center
                    let vc = storyboard?.instantiateViewController(withIdentifier: "StatusPageViewController") as! StatusPageViewController
                    vc.isMyStatus = false
                    vc.idArr = [id];
                    vc.ChatRecorDict = [id : [messageFrame]]
                    vc.currentStatusIndex = 0
                    self.presentView(vc, animated: true)
                }
            }
        }
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        transition.startingPoint = center
        transition.circleColor = .black
        
        return transition
    }
    
    
    func uuavAudioPlayerDidFinishPlay(_ Ispause: Bool) {
        UIDevice.current.isProximityMonitoringEnabled = false
        
        let indexpath = NSIndexPath.init(row: pause_row, section: 0)
        //        cellForRow(at: indexpath as IndexPath) as! UUMessageCell
        
        let cellItem:UUMessageCell? = chatTableView.cellForRow(at: indexpath as IndexPath) as? UUMessageCell
        if(cellItem != nil){
            cellItem?.is_paused = false
            
            if(!Ispause)
            {
                // finish playing
                cellItem?.contentVoiceIsPlaying = false
                cellItem?.btnContent.stopPlay()
                UUAVAudioPlayer.sharedInstance().stopSound()
                
            }
            else
            {
                
                cellItem?.is_paused = true
                cellItem?.contentVoiceIsPlaying = true
                cellItem?.btnContent.stopPlay()
                
            }
        }
    }
    func uuavAudioPlayerBeiginLoadVoice()
    {
        
        let indexpath = NSIndexPath.init(row: pause_row, section: 0)
        
        let cellItem:UUMessageCell? = chatTableView.cellForRow(at: indexpath as IndexPath) as? UUMessageCell
        if (cellItem != nil){
            cellItem?.btnContent.benginLoadVoice()
        }
        
        
    }
    
    fileprivate func presentPlayer(_ videoURL: URL?, _ cellItem: CustomTableViewCell) {
        let player = AVPlayer(url: videoURL! )
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        (cellItem.delegate as! UIViewController).presentView(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
    func forwordPressed(_ sender: UIButton) {
        guard !isBeginEditing else{return}
        let row:Int = (sender as AnyObject).tag
        guard self.chatModel.dataSource.count > row else{return }
        let indexpath = IndexPath(row: row, section: 0)
        moveToShareContactVC([indexpath])
        
    }
    
    func uploadControllerPressed(_ sender:UIButton){
    }
    
    func readMorePressed(sender: UIButton, count: String) {
        let row:Int = (sender as AnyObject).tag
        pause_row = row
        initial = 1
        guard self.chatModel.dataSource.count > row else{return}
        let messageFrame: UUMessageFrame = self.chatModel.dataSource[row] as! UUMessageFrame
        messageFrame.message.readmore_count = count
        let indexpath = IndexPath(row: row, section: 0)
        DispatchQueue.main.async{
            self.chatTableView.reloadRows(at: [indexpath], with: .none)
        }
    }
    
    func pauseGif()
    {
        let indexpath = NSIndexPath.init(row: pause_row, section: 0)
        if let cellItem:CustomTableViewCell = self.chatTableView.cellForRow(at: indexpath as IndexPath) as? CustomTableViewCell {
            if(cellItem.messageFrame.message.type == MessageType(rawValue: 1))
            {
                guard let imgCell = cellItem as? ImageTableViewCell else{return}
                let download_status:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: cellItem.messageFrame.message.thumbnail!, upload_detail: "download_status") as! String
                
                if(download_status == "2"){
                    let PhotoPath:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: cellItem.messageFrame.message.thumbnail!, upload_detail: "upload_Path") as! String
                    if FileManager.default.fileExists(atPath: PhotoPath) {
                        let url = URL(fileURLWithPath: PhotoPath)
                        if(url.pathExtension.lowercased() == "gif")
                        {
                            if(imgCell.gifImg.isAnimatingGif())
                            {
                                imgCell.gifImg.stopAnimatingGif()
                                imgCell.customButton.setImage(#imageLiteral(resourceName: "gifIcon"), for: .normal)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc func didClickCellButton(_ sender: UIButton){
        guard !isBeginEditing else{
            let row:Int = (sender as AnyObject).tag
            guard self.chatModel.dataSource.count > row else{return}
            let indexpath = NSIndexPath.init(row: row, section: 0)
            self.Firstindexpath = indexpath as IndexPath
            
            if let cell = chatTableView.cellForRow(at: self.Firstindexpath) {
                if cell.isSelected {
                    chatTableView.deselectRow(at: Firstindexpath, animated: false)
                    tableView(chatTableView, didDeselectRowAt: Firstindexpath)
                }else {
                    chatTableView.selectRow(at: Firstindexpath, animated: false, scrollPosition: .none)
                    tableView(chatTableView, didSelectRowAt: Firstindexpath)
                }
            }
            return
        }
        
        if(pause_row != sender.tag)
        {
            self.pauseGif()
        }
        let row:Int = sender.tag
        pause_row = row
        initial = 1
        guard self.chatModel.dataSource.count > row else{return}
        let messageFrame: UUMessageFrame = self.chatModel.dataSource[row] as! UUMessageFrame
        self.PausePlayingAudioIfAny()
        let indexpath = NSIndexPath.init(row: row, section: 0)
        
        if let cellItem:CustomTableViewCell = self.chatTableView.cellForRow(at: indexpath as IndexPath) as? CustomTableViewCell {
            switch cellItem.messageFrame.message.type{
            case MessageType(rawValue: 1):
                guard let imgCell = cellItem as? ImageTableViewCell else{return}
                
                let download_status:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "download_status") as! String
                
                if(download_status == "2"){
                    let PhotoPath:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "upload_Path") as! String
                    if FileManager.default.fileExists(atPath: PhotoPath) {
                        let url = URL(fileURLWithPath: PhotoPath)
                        if(url.pathExtension.lowercased() == "gif")
                        {
                            if(imgCell.gifImg.isAnimatingGif())
                            {
                                imgCell.gifImg.stopAnimatingGif()
                                imgCell.customButton.setImage(#imageLiteral(resourceName: "gifIcon"), for: .normal)
                                
                                let configuration = ImageViewerConfiguration { config in
                                    config.gifimageView = imgCell.gifImg
                                    config.imagePath = url
                                }
                                self.presentView(ImageViewerController(configuration: configuration), animated: true)
                                if (cellItem.delegate is UIViewController) {
                                    (cellItem.delegate as! UIViewController).view.endEditing(true)
                                }
                                
                            }
                            else
                            {
                                imgCell.gifImg.startAnimatingGif()
                                imgCell.customButton.setImage(nil, for: .normal)
                            }
                            return
                        }
                    }
                }
                
                let configuration = ImageViewerConfiguration { config in
                    config.imageView = imgCell.chatImg
                }
     
            var viewControle = ImageViewerController(configuration: configuration)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                 // Your code with navigate to another controller
                 self.presentView(viewControle, animated: true)
              }
                            
                if (cellItem.delegate is UIViewController) {
                    (cellItem.delegate as! UIViewController).view.endEditing(true)
                }
                break
            case MessageType(rawValue:2):
                let videoPath:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "upload_Path") as! String
                
                let download_status:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "download_status") as! String
                
                let serverpath:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "serverpath") as! String
                
                
                if(download_status == "2"),(videoPath != ""),FileManager.default.fileExists(atPath: videoPath)
                {
                    let videoURL = URL(fileURLWithPath: videoPath)
                    self.presentPlayer(videoURL, cellItem)
                    
                }
                else
                {
                    if download_status != "1"{
                        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Upload_Details, FetchString: messageFrame.message.thumbnail!, attribute: "upload_data_id", UpdationElements: ["download_status" : "0"])
                        DownloadHandler.sharedinstance.handleDownLoad(true)
                    }
                    
                    if(serverpath != "")
                    {
                        let videoURL = URL(string: Themes.sharedInstance.getDownloadURL(serverpath))
                        self.presentPlayer(videoURL, cellItem)
                    }
                }
                break
            case MessageType(rawValue: 4):
                guard var urlString = messageFrame.message.payload else{return}
                if !urlString.contains("https://") && !urlString.contains("http://")
                {
                    urlString = "https://\(urlString)"
                }
                urlString = urlString.removingWhitespaces()
                guard let url = URL(string: urlString) else {return}
                
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
                break
            case MessageType(rawValue:6):
                var id = cellItem.messageFrame.message.thumbnail!
                if(id == "")
                {
                    id = cellItem.messageFrame.message.doc_id!
                }
                let download_status:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: id, upload_detail: "download_status") as! String
                
                if((cellItem.messageFrame.message.from == MessageFrom(rawValue: 1)! || (download_status == "2" && cellItem.messageFrame.message.from == MessageFrom(rawValue: 0)!)))
                {
                    self.DidclickContentBtn(messagFrame: (cellItem.messageFrame))
                }
                break
            case MessageType(rawValue:7):
                let isFromStatus = (messageFrame.message.reply_type == "status") ? true : false
                let recordId:String = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Reply_detail, attrib_name: "doc_id", fetchString: messageFrame.message.doc_id, returnStr: "recordId")
                let index = IndexPath(row: row, section: 0)
                self.PasReplyDetail(index:index,ReplyRecordID:recordId, isStatus : isFromStatus)
                break
                
            case MessageType(rawValue:14):
                let s = self.storyboard?.instantiateViewController(withIdentifier:"OnCellClickViewController" ) as! OnCellClickViewController
                let Name:String=Themes.sharedInstance.setNameTxt(Themes.sharedInstance.Getuser_id(), "")
                
                s.latitude = cellItem.messageFrame.message.latitude
                s.longitude = cellItem.messageFrame.message.longitude
                if(cellItem.messageFrame.message.from == MessageFrom(rawValue: 1))
                {
                    s.on_title = "\(Name)(you)"
                }
                else
                {
                    s.on_title = Themes.sharedInstance.setNameTxt(Themes.sharedInstance.CheckNullvalue(Passed_value: cellItem.messageFrame.message.from), "single")
                }
                s.subtitle = cellItem.messageFrame.message.stitle_place
                s.place_name = cellItem.messageFrame.message.title_place
                self.pushView(s, animated: true)
                break
            default: break
            }
        }
        
    }
    
    func updateSlider(value:Float){
        guard let index = AudioManager.sharedInstence.currentIndex else{return}
        guard self.chatModel.dataSource.count > index.row else{return}
        guard let currentCell:CustomTableViewCell = chatTableView.cellForRow(at: index) as? CustomTableViewCell else{return}
        guard let currentAudioCell = currentCell as? AudioTableViewCell else{return}
        UIView.animate(withDuration: 0.3) {
            currentAudioCell.audioSlider.setValue(value, animated: true)
        }
    }
    
    func updateDuration(value: String, at indexPath: IndexPath) {
        guard let index = AudioManager.sharedInstence.currentIndex else{return}
        guard self.chatModel.dataSource.count > index.row else{return}
        guard let currentCell:CustomTableViewCell = chatTableView.cellForRow(at: index) as? CustomTableViewCell else{return}
        guard let currentAudioCell = currentCell as? AudioTableViewCell else{return}
        currentAudioCell.audioDuration.text = value
        
    }
    func playerCompleted(){
        guard let index = AudioManager.sharedInstence.currentIndex else{return}
        guard self.chatModel.dataSource.count > index.row else{return}
        guard let previousCell:CustomTableViewCell = chatTableView.cellForRow(at: index) as? CustomTableViewCell else{return}
        guard let preAudioCell = previousCell as? AudioTableViewCell else{return}
        preAudioCell.playPauseButton.isSelected = false
        preAudioCell.audioSlider.value = 0
    }
    
    
    
    func playPauseTapped(sender: UIButton) {
        self.pauseGif()
        audioPlayBtn = sender
        let row:Int = (sender as AnyObject).tag
        pause_row = row
        initial = 1
        guard self.chatModel.dataSource.count > row else{return}
        let indexpath = NSIndexPath.init(row: row, section: 0)
        
        if let cellItem:CustomTableViewCell = chatTableView.cellForRow(at: indexpath as IndexPath) as? CustomTableViewCell {
            AudioManager.sharedInstence.delegate = self
           
//                DispatchQueue.main.async{
//                    (cellItem as! AudioTableViewCell).micIcon.image = UIImage(named: "micIconBlue")
//                    self.chatTableView.reloadData()
//            }

            if cellItem.RowIndex == AudioManager.sharedInstence.currentIndex{
                if !sender.isSelected{
                 
                    AudioManager.sharedInstence.playSound()
                }
                else{
                    AudioManager.sharedInstence.pauseSound()
                }
                
            }else{
                playerCompleted()
                
                AudioManager.sharedInstence.setupAudioPlayer(with: cellItem.songData, at: indexpath as IndexPath)
            }
            sender.isSelected = !sender.isSelected
            
        }
        
    }
    
    func sliderChanged(_ slider: UISlider, event: UIControl.Event) {
        let row = slider.tag
        let indexpath = IndexPath(row: row, section: 0)
        guard let audioIndex = AudioManager.sharedInstence.currentIndex else{return}
        guard indexpath == audioIndex else{return}
        AudioManager.sharedInstence.playbackSliderValueChanged(slider, event: event)
        guard self.chatModel.dataSource.count > indexpath.row else{return}
        guard let previousCell:CustomTableViewCell = chatTableView.cellForRow(at: indexpath) as? CustomTableViewCell else{return}
        guard let audioCell = previousCell as? AudioTableViewCell else{return}
        audioCell.playPauseButton.isSelected = event == .editingDidEnd ? true : false
    }
    
    
    
    
    @IBAction func btnContentClick(_ sender: Any)
    {
        
        //check each cell with audio and whether it is playing , then stop
        
        let row: NSInteger = (sender as AnyObject).tag
        
        pause_row = row
        initial = 1
        self.PausePlayingAudioIfAny()
        
        let indexpath = NSIndexPath.init(row: row, section: 0)
        
        let cellItem:UUMessageCell? = chatTableView.cellForRow(at: indexpath as IndexPath) as? UUMessageCell
        
        if(cellItem != nil){
            if (cellItem?.messageFrame.message.type == MessageType(rawValue: 3)!) {
                
                let download_status:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: cellItem!.messageFrame.message.thumbnail!, upload_detail: "download_status") as! String
                
                if(cellItem?.messageFrame.message.from == MessageFrom(rawValue: 1)! || (download_status == "2" && cellItem?.messageFrame.message.from == MessageFrom(rawValue: 0)!))
                {
                    if (!(cellItem?.contentVoiceIsPlaying)!) {
                        
                        if(cellItem?.songData != nil)
                        {
                            
                            //messageFrame.message.progress = "0.0"
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.VoicePlayHasInterrupt), object: nil)
                            cellItem?.contentVoiceIsPlaying = true
                            cellItem?.audio = UUAVAudioPlayer.sharedInstance()
                            cellItem?.audio.delegate = self
                            //audio.player.prepareToPlay()
                            //slidePlay = false
                            
                            cellItem?.slideMove = false
                            
                            if(cellItem?.messageFrame.message.progress != "0.0")
                            {
                                cellItem?.btnContent.startPlay()
                                
                                cellItem?.audio.playSong(with: cellItem?.songData)
                                
                                cellItem?.audio.player.currentTime = TimeInterval(Float((cellItem?.btnContent.myProgressView.value)!))
                                
                                cellItem?.audio.player.currentTime = TimeInterval(Float((cellItem?.messageFrame.message.progress)!)!)
                                
                                
                            }
                            else
                            {
                                
                                cellItem?.audio.playSong(with: cellItem?.songData)
                            }
                            
                            
                        }
                        
                    }
                    else
                    {
                        
                        if(Double((cellItem?.messageFrame.message.progress)!) == Double((cellItem?.audio.player.duration)!))
                        {
                            
                            //self.btnContent.stopPlay()
                            self.uuavAudioPlayerDidFinishPlay(false)
                            
                        }
                        else
                        {
                            
                            //for pause
                            if(cellItem?.is_paused == false)
                            {
                                //slideMove = false
                                cellItem?.audio.player.pause()
                                cellItem?.audio.pause()
                                self.uuavAudioPlayerDidFinishPlay(true)
                                
                            }
                                
                                //play after initial
                                
                            else
                            {
                                
                                cellItem?.is_paused = false
                                cellItem?.btnContent.startPlay()
                                cellItem?.slideMove = false
                                //slidePlay = true
                                cellItem?.audio.playSong(with: cellItem?.songData)
                                cellItem?.audio.player.currentTime = TimeInterval(Float((cellItem?.messageFrame.message.progress)!)!)
                                
                            }
                        }
                    }
                }
                
            }else if(cellItem?.messageFrame.message.type == MessageType(rawValue: 14)){
                
                let s = storyboard?.instantiateViewController(withIdentifier:"OnCellClickViewController" ) as! OnCellClickViewController
                let Name:String=Themes.sharedInstance.setNameTxt(Themes.sharedInstance.Getuser_id(), "")
                
                s.latitude = cellItem?.messageFrame.message.latitude
                s.longitude = cellItem?.messageFrame.message.longitude
                if(cellItem?.messageFrame.message.from == MessageFrom(rawValue: 1))
                {
                    s.on_title = "\(Name)(you)"
                }
                else
                {
                    s.on_title = Themes.sharedInstance.setNameTxt(Themes.sharedInstance.CheckNullvalue(Passed_value: cellItem?.messageFrame.message.from), "single")
                }
                s.subtitle = cellItem?.messageFrame.message.stitle_place
                s.place_name = cellItem?.messageFrame.message.title_place
                self.pushView(s, animated: true)
                
            }
                
            else if cellItem?.messageFrame.message.type == MessageType(rawValue: 2)! {
                if cellItem?.messageFrame.message.from == MessageFrom(rawValue: 1)!
                    
                {
                    
                    let videoPath:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: cellItem!.messageFrame.message.thumbnail!, upload_detail: "upload_Path") as! String
                    
                    let download_status:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: cellItem!.messageFrame.message.thumbnail!, upload_detail: "download_status") as! String
                    
                    
                    if(videoPath != "")
                    {
                        if(download_status == "2")
                        {
                            if FileManager.default.fileExists(atPath: videoPath) {
                                let videoURL = URL(fileURLWithPath: videoPath)
                                let player = AVPlayer(url: videoURL )
                                let playerViewController = AVPlayerViewController()
                                playerViewController.player = player
                                
                                (cellItem?.delegate as! UIViewController).presentView(playerViewController, animated: true) {
                                    playerViewController.player!.play()
                                }
                            }
                        }
                        else
                        {
                            let serverpath:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: cellItem!.messageFrame.message.thumbnail!, upload_detail: "serverpath") as! String
                            
                            let param:NSDictionary = ["download_status":"0"]
                            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Upload_Details, FetchString: cellItem!.messageFrame.message.thumbnail!, attribute: "upload_data_id", UpdationElements: param)
                            
                            DownloadHandler.sharedinstance.handleDownLoad(true)
                            
                            let videoURL = URL(string: Themes.sharedInstance.getDownloadURL(serverpath))
                            let player = AVPlayer(url: videoURL! )
                            let playerViewController = AVPlayerViewController()
                            playerViewController.player = player
                            
                            (cellItem?.delegate as! UIViewController).presentView(playerViewController, animated: true) {
                                playerViewController.player!.play()
                            }
                        }
                    }
                }
                else
                {
                    let download_status:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: cellItem!.messageFrame.message.thumbnail!, upload_detail: "download_status") as! String
                    if(download_status == "2")
                    {
                        let videoPath:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: cellItem!.messageFrame.message.thumbnail!, upload_detail: "upload_Path") as! String
                        
                        if(videoPath != "")
                        {
                            if FileManager.default.fileExists(atPath: videoPath) {
                                let videoURL = URL(fileURLWithPath: videoPath)
                                let player = AVPlayer(url: videoURL )
                                let playerViewController = AVPlayerViewController()
                                playerViewController.player = player
                                
                                (cellItem?.delegate as! UIViewController).presentView(playerViewController, animated: true) {
                                    playerViewController.player!.play()
                                }
                            }
                            else
                            {
                                let serverpath:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: cellItem!.messageFrame.message.thumbnail!, upload_detail: "serverpath") as! String
                                
                                let param:NSDictionary = ["download_status":"0"]
                                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Upload_Details, FetchString: cellItem!.messageFrame.message.thumbnail!, attribute: "upload_data_id", UpdationElements: param)
                                
                                DownloadHandler.sharedinstance.handleDownLoad(true)
                                
                                let videoURL = URL(string: Themes.sharedInstance.getDownloadURL(serverpath))
                                let player = AVPlayer(url: videoURL! )
                                let playerViewController = AVPlayerViewController()
                                playerViewController.player = player
                                
                                (cellItem?.delegate as! UIViewController).presentView(playerViewController, animated: true) {
                                    playerViewController.player!.play()
                                }
                            }
                        }
                    }
                    else
                    {
                        let serverpath:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: cellItem!.messageFrame.message.thumbnail!, upload_detail: "serverpath") as! String
                        
                        let param:NSDictionary = ["download_status":"0"]
                        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Upload_Details, FetchString: cellItem!.messageFrame.message.thumbnail!, attribute: "upload_data_id", UpdationElements: param)
                        
                        DownloadHandler.sharedinstance.handleDownLoad(true)
                        
                        if(serverpath != "")
                        {
                            
                            let videoURL = URL(string: Themes.sharedInstance.getDownloadURL(serverpath))
                            let player = AVPlayer(url: videoURL! )
                            let playerViewController = AVPlayerViewController()
                            playerViewController.player = player
                            
                            (cellItem?.delegate as! UIViewController).presentView(playerViewController, animated: true) {
                                playerViewController.player!.play()
                            }
                        }
                    }
                }
            }
            else if cellItem?.messageFrame.message.type == MessageType(rawValue: 1)! {
                
                if (cellItem?.btnContent.backImageView != nil)
                {
                    let configuration = ImageViewerConfiguration { config in
                        config.imageView = cellItem?.btnContent.backImageView
                    }
                    self.presentView(ImageViewerController(configuration: configuration), animated: true)
                }
                if (cellItem?.delegate is UIViewController) {
                    
                    (cellItem?.delegate as! UIViewController).view.endEditing(true)
                    
                }
            }
                
            else if cellItem?.messageFrame.message.type == MessageType(rawValue: 0)! {
                
                //                let menu = UIMenuController.shared
                //                menu.setTargetRect((cellItem?.btnContent.frame)!, in: (cellItem?.btnContent.superview!)!)
                //                menu.setMenuVisible(true, animated: true)
                
            }
            
            if (cellItem?.messageFrame.message.type == MessageType(rawValue: 6)!)
            {
                let download_status:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: cellItem!.messageFrame.message.thumbnail!, upload_detail: "download_status") as! String
                
                if((cellItem?.messageFrame.message.from == MessageFrom(rawValue: 1)! || (download_status == "2" && cellItem?.messageFrame.message.from == MessageFrom(rawValue: 0)!)))
                {
                    cellItem?.delegate?.DidclickContentBtn(messagFrame: (cellItem?.messageFrame)!)
                }
                
            }
        }
        
    }
    
    func sliderValueChanged(slider:UISlider)
    {
        
        
        let row = slider.tag
        let indexpath = NSIndexPath.init(row: row, section: 0)
        
        let cellItem:UUMessageCell? = chatTableView.cellForRow(at: indexpath as IndexPath) as? UUMessageCell
        
        if(cellItem != nil){
            if(self.pause_row == row){
                
                
                if(cellItem?.total != nil)
                {
                    
                    cellItem?.messageFrame.message.progress = "\(slider.value)"
                    cellItem?.audio.player.currentTime = TimeInterval(slider.value)
                    
                    if(slider.value == 0.0){
                        
                        let upload_Path:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: cellItem!.messageFrame.message.thumbnail!, upload_detail: "upload_Path") as! String
                        
                        cellItem?.btnContent.second.text =  cellItem?.ReturnruntimeDuration(sourceMovieURL: URL(fileURLWithPath:upload_Path))
                        
                    }else{
                        
                        let min = slider.value/60;
                        let sec = slider.value.truncatingRemainder(dividingBy: 60) ;
                        cellItem?.btnContent.second.text = String(format: "%02d:%02d", Int(min),Int(sec))
                        
                    }
                    
                    cellItem?.audio.player.pause()
                    cellItem?.audio.pause()
                    self.uuavAudioPlayerDidFinishPlay(true)
                    
                }
                else
                {
                    
                    cellItem?.messageFrame.message.progress = "\(slider.value)"
                    
                    if(slider.value == 0.0){
                        
                        let upload_Path:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: cellItem!.messageFrame.message.thumbnail!, upload_detail: "upload_Path") as! String
                        
                        cellItem?.btnContent.second.text = cellItem?.ReturnruntimeDuration(sourceMovieURL:URL(fileURLWithPath:upload_Path))
                        
                    }else{
                        
                        let min = slider.value/60;
                        let sec = slider.value.truncatingRemainder(dividingBy: 60);
                        
                        cellItem?.btnContent.second.text = String(format: "%02d:%02d", Int(min),Int(sec))
                        
                    }
                    
                    
                }
            }else{
                
                let row = slider.tag
                
                let indexpath = NSIndexPath.init(row: row, section: 0)
                
                let cellItem:UUMessageCell? = chatTableView.cellForRow(at: indexpath as IndexPath) as? UUMessageCell
                
                if(cellItem != nil)
                {
                    
                    cellItem?.messageFrame.message.progress = "\(slider.value)"
                    //cellItem.audio.player.currentTime = TimeInterval(slider.value)
                    
                    if(slider.value == 0.0){
                        
                        let upload_Path:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: cellItem!.messageFrame.message.thumbnail!, upload_detail: "upload_Path") as! String
                        if(upload_Path != "")
                        {
                            cellItem?.btnContent.second.text =  cellItem?.ReturnruntimeDuration(sourceMovieURL: URL(fileURLWithPath:upload_Path))
                        }
                        
                    }else{
                        
                        let min = slider.value/60;
                        let sec = slider.value.truncatingRemainder(dividingBy: 60);
                        cellItem?.btnContent.second.text = String(format: "%02d:%02d", Int(min),Int(sec))
                        
                    }
                }
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10;
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10;
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if(!Themes.sharedInstance.contactExist_Fav(opponent_id) && Chat_type != "group")
        {
            return 2
        }
        else
        {
            return 1
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0)
        {
            return self.chatModel.dataSource.count
        }
        else
        {
            return 1
        }
    }
    
    func getContact_details(phone:String){
        
        contact_details = ""
        
        let checkContact:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Contact_add, attribute: "contact_mobilenum", FetchString:phone);
        
        if(checkContact)
        {
            
            let contactsArray=DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Contact_add, attribute: "contact_mobilenum", FetchString: phone, SortDescriptor: nil) as! [NSManagedObject]
            
            //let CheckFavcontactArr:NSMutableArray=NSMutableArray()
            _ = contactsArray.map {
                let constactObj = $0
                contact_details = constactObj.value(forKey: "contact_details")! as! String
            }
        }
    }
    
    @IBAction func saveTarget(sender:UIButton){
        if(ContactHandler.sharedInstance.CheckCheckPermission())
        {
            let row = sender.tag
            let indexpath = NSIndexPath.init(row: row, section: 0)
            let cellItem:CustomTableViewCell = (chatTableView.cellForRow(at: indexpath as IndexPath) as? CustomTableViewCell)!
            self.is_chatPage_contact = true
            var phone_num:[CNLabeledValue<CNPhoneNumber>] = []
            
            var email:[CNLabeledValue<NSString>] = []
            var address:[CNLabeledValue<CNPostalAddress>] = []
            
            let contact = CNMutableContact()
            contact.givenName = (cellItem.messageFrame.message.contact_name)!
            
            let data = (cellItem.messageFrame.message.contact_details)!.data(using:.utf8)
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                let contact_address = CNMutablePostalAddress()
                // Parse JSON data
                if let phone_number:NSArray = jsonResult.value(forKey: "phone_number") as? NSArray {
                    _ = phone_number.map {
                        let i = phone_number.index(of: $0)
                        let get_value:NSDictionary = phone_number[i] as! NSDictionary
                        let type = get_value.value(forKey:"type") as! String
                        let value_ph = get_value.value(forKey:"value") as! String
                        let values = CNLabeledValue(label:type , value:CNPhoneNumber(stringValue:value_ph))
                        phone_num.append(values)
                    }
                }
                
                if let email_arr:NSArray = jsonResult.value(forKey: "email") as? NSArray {
                    _ = email_arr.map {
                        let i = email_arr.index(of: $0)
                        let get_value:NSDictionary = email_arr[i] as! NSDictionary
                        let type = get_value.value(forKey:"type") as! String
                        let value_ph = get_value.value(forKey:"value") as! String
                        let values = CNLabeledValue(label:type , value:value_ph as NSString)
                        email.append(values)
                    }
                }
                
                if let address_arr:NSArray = jsonResult.value(forKey: "address") as? NSArray {
                    _ = address_arr.map {
                        let i = address_arr.index(of: $0)
                        
                        let get_value:NSDictionary = address_arr[i] as! NSDictionary
                        contact_address.street = get_value.value(forKey:"street") as! String
                        contact_address.city = get_value.value(forKey:"city") as! String
                        contact_address.state = get_value.value(forKey:"state") as! String
                        contact_address.postalCode = get_value.value(forKey:"postalCode") as! String
                        contact_address.country = get_value.value(forKey:"country") as! String
                        let values = CNLabeledValue<CNPostalAddress>(label:"home" , value:contact_address)
                        address.append(values)
                    }
                }
            } catch {
                
            }
            
            if(phone_num.count > 0){
                
                contact.phoneNumbers = phone_num
                contact.emailAddresses = email
                contact.postalAddresses = address
                
            }
            
            let controller = CNContactViewController(forNewContact: contact)
            controller.delegate = self
            
            let navigationController = UINavigationController(rootViewController: controller)
            self.presentView(navigationController, animated: true)
        }
        else
        {
            self.presentView(Themes.sharedInstance.showContactPermissionAlert, animated: true)
        }
        
    }
    
    func contactBtnTapped(sender:UIButton){
        self.pauseGif()
        let row = sender.tag
        let indexpath = NSIndexPath.init(row: row, section: 0)
        
        let cellItem:CustomTableViewCell? = chatTableView.cellForRow(at: indexpath as IndexPath) as? CustomTableViewCell
        SetData(user_id: (cellItem?.messageFrame.message.contact_id)!)
        if(sender.titleLabel?.text == contactTitle.msg.rawValue){
            
            if(isNotContact == true){
                let id = Themes.sharedInstance.CheckNullvalue(Passed_value: cellItem?.messageFrame.message.contact_id!)
                if(Themes.sharedInstance.isChatLocked(id: id, type: "single"))
                {
                    Themes.sharedInstance.enterTochat(id: id, type: "single") { (success) in
                        if(success)
                        {
                            let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                            ObjInitiateChatViewController.Chat_type="single"
                            ObjInitiateChatViewController.opponent_id = id
                            ObjInitiateChatViewController.goBack = true
                            self.isNotContact = false
                            self.pushView(ObjInitiateChatViewController, animated: true)
                        }
                    }
                }
                else
                {
                    let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                    ObjInitiateChatViewController.Chat_type="single"
                    ObjInitiateChatViewController.opponent_id = id
                    ObjInitiateChatViewController.goBack = true
                    isNotContact = false
                    self.pushView(ObjInitiateChatViewController, animated: true)
                }
                
            }else{
                 let id = Themes.sharedInstance.CheckNullvalue(Passed_value: userfavRecord.id)
                if(Themes.sharedInstance.isChatLocked(id: id, type: "single"))
                {
                    Themes.sharedInstance.enterTochat(id: id, type: "single") { (success) in
                        if(success)
                        {
                            let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                            ObjInitiateChatViewController.Chat_type="single"
                            ObjInitiateChatViewController.opponent_id = id
                            ObjInitiateChatViewController.goBack = true
                            self.pushView(ObjInitiateChatViewController, animated: true)
                        }
                    }
                }
                else
                {
                    let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                    ObjInitiateChatViewController.Chat_type="single"
                    ObjInitiateChatViewController.opponent_id = id
                    ObjInitiateChatViewController.goBack = true
                    self.pushView(ObjInitiateChatViewController, animated: true)
                }
            }
        }else{
            
            
            let sheet_action: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            var index:Int!
            
            let MailAction: UIAlertAction = UIAlertAction(title: "Mail", style: .default) { action -> Void in
                index = 0
                self.PresentSheet(index:index, id:(cellItem?.messageFrame.message.contact_id)!, phnNumber: "")
                
            }
            let MessageAction: UIAlertAction = UIAlertAction(title: "Message", style: .default) { action -> Void in
                index = 1
                
                self.PresentSheet(index:index, id:(cellItem?.messageFrame.message.contact_id)!, phnNumber: (cellItem?.messageFrame.message.contact_phone)!)
                
            }
            let TwitterAction: UIAlertAction = UIAlertAction(title: "Twitter", style: .default) { action -> Void in
                index = 2
                self.PresentSheet(index:index, id:(cellItem?.messageFrame.message.contact_id)!, phnNumber:"")
                
            }
            let FacebookAction: UIAlertAction = UIAlertAction(title: "Facebook", style: .default) { action -> Void in
                index = 3
                self.PresentSheet(index:index, id:(cellItem?.messageFrame.message.contact_id)!, phnNumber:"")
                
            }
            let CancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
                index = 0
                
            }
            sheet_action.addAction(MailAction)
            sheet_action.addAction(MessageAction)
            sheet_action.addAction(TwitterAction)
            sheet_action.addAction(FacebookAction)
            sheet_action.addAction(CancelAction)
            self.presentView(sheet_action, animated: true, completion: nil)
        }
        
    }
    
    
    @IBAction func messageContact(sender:UIButton){
        
        let row = sender.tag
        let indexpath = NSIndexPath.init(row: row, section: 0)
        
        let cellItem:UUMessageCell? = chatTableView.cellForRow(at: indexpath as IndexPath) as? UUMessageCell
        SetData(user_id: (cellItem?.messageFrame.message.contact_id)!)
        if(cellItem?.send_message == true){
            
            if(isNotContact == true){

                let id = Themes.sharedInstance.CheckNullvalue(Passed_value: cellItem?.messageFrame.message.contact_id!)
                if(Themes.sharedInstance.isChatLocked(id: id, type: "single"))
                {
                    Themes.sharedInstance.enterTochat(id: id, type: "single") { (success) in
                        if(success)
                        {
                            let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                            ObjInitiateChatViewController.Chat_type="single"
                            ObjInitiateChatViewController.opponent_id = id
                            ObjInitiateChatViewController.goBack = true
                            self.isNotContact = false
                            self.pushView(ObjInitiateChatViewController, animated: true)
                        }
                    }
                }
                else
                {
                    let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                    ObjInitiateChatViewController.Chat_type="single"
                    ObjInitiateChatViewController.opponent_id = id
                    ObjInitiateChatViewController.goBack = true
                    isNotContact = false
                    self.pushView(ObjInitiateChatViewController, animated: true)
                }
                
                
            }else{
                let id = Themes.sharedInstance.CheckNullvalue(Passed_value: userfavRecord.id)
                
                if(Themes.sharedInstance.isChatLocked(id: id, type: "single"))
                {
                    Themes.sharedInstance.enterTochat(id: id, type: "single") { (success) in
                        if(success)
                        {
                            let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                            ObjInitiateChatViewController.Chat_type="single"
                            ObjInitiateChatViewController.opponent_id = id
                            ObjInitiateChatViewController.goBack = true
                            self.pushView(ObjInitiateChatViewController, animated: true)
                        }
                    }
                }
                else
                {
                    let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                    ObjInitiateChatViewController.Chat_type="single"
                    ObjInitiateChatViewController.opponent_id = id
                    ObjInitiateChatViewController.goBack = true
                    self.pushView(ObjInitiateChatViewController, animated: true)
                }
            }
        }else{
            
            
            let sheet_action: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            var index:Int!
            
            let MailAction: UIAlertAction = UIAlertAction(title: "Mail", style: .default) { action -> Void in
                index = 0
                self.PresentSheet(index:index, id:(cellItem?.messageFrame.message.contact_id)!, phnNumber: "")
                
            }
            let MessageAction: UIAlertAction = UIAlertAction(title: "Message", style: .default) { action -> Void in
                index = 1
                
                self.PresentSheet(index:index, id:(cellItem?.messageFrame.message.contact_id)!, phnNumber: (cellItem?.messageFrame.message.contact_phone)!)
                
            }
            let TwitterAction: UIAlertAction = UIAlertAction(title: "Twitter", style: .default) { action -> Void in
                index = 2
                self.PresentSheet(index:index, id:(cellItem?.messageFrame.message.contact_id)!, phnNumber:"")
                
            }
            let FacebookAction: UIAlertAction = UIAlertAction(title: "Facebook", style: .default) { action -> Void in
                index = 3
                self.PresentSheet(index:index, id:(cellItem?.messageFrame.message.contact_id)!, phnNumber:"")
                
            }
            let CancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
                index = 0
                
            }
            sheet_action.addAction(MailAction)
            sheet_action.addAction(MessageAction)
            sheet_action.addAction(TwitterAction)
            sheet_action.addAction(FacebookAction)
            sheet_action.addAction(CancelAction)
            self.presentView(sheet_action, animated: true, completion: nil)
        }
        
    }
    
    
    func SetData(user_id:String)
    {
        
        let Checkuser:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "id", FetchString: user_id)
        if(Checkuser)
        {
            let GetUserDetails = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "id", FetchString:  user_id, SortDescriptor: nil) as! [NSManagedObject]
            if(GetUserDetails.count > 0)
            {
                _ = GetUserDetails.map{
                    let ResponseDict = $0
                    let favRecord:FavRecord=FavRecord()
                    favRecord.id=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "id"))
                    userfavRecord = favRecord
                }
            }
        }else{
            isNotContact = true
        }
    }
    
    func PresentSheet(index:Int,id:String, phnNumber: String)
        
    {
        SetData(user_id: id)
        if(index == 1)
        {
            
            if (MFMessageComposeViewController.canSendText()) {
                let controller = MFMessageComposeViewController()
                controller.body = Constant.sharedinstance.ShareText
                controller.recipients = [phnNumber]
                controller.messageComposeDelegate = self
                self.presentView(controller, animated: true)
            }
            else
            {
                self.view.makeToast(message: "Message service not available", duration: 3, position: HRToastActivityPositionDefault)
            }
        }
        if(index == 0)
        {
            if !MFMailComposeViewController.canSendMail() {
                self.view.makeToast(message: "Please login to a mail account to share", duration: 3, position: HRToastActivityPositionDefault)
                return
            }
            else
            {
                let composeVC = MFMailComposeViewController()
                composeVC.mailComposeDelegate = self
                // Configure the fields of the interface.
                composeVC.setSubject(Constant.sharedinstance.Subtext)
                composeVC.setMessageBody(Constant.sharedinstance.ShareText, isHTML: false)
                // Present the view controller modally.
                self.presentView(composeVC, animated: true)
            }
        }
        if(index == 2)
        {
            Themes.sharedInstance.shareOnTwitter()
        }
        if(index == 3)
        {
            Themes.sharedInstance.shareOnFacebook()
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismissView(animated: true, completion: nil)
        var message = ""
        switch result {
        case .cancelled:
            message = "Message cancelled"
            break
        case .sent:
            message = "Message sent"
            break
        case .failed:
            message = "Message failed"
            break
        default:
            break
        }
        self.view.makeToast(message: message, duration: 3, position: HRToastActivityPositionDefault)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        self.dismissView(animated: true, completion: nil)
        
        var message = ""
        
        if(error != nil) {
            message = "Error Occurred."
        }
        else
        {
            switch result {
            case .cancelled:
                message = "Mail cancelled."
                break
            case .failed:
                message = "Mail failed."
                break
            case .sent:
                message = "Mail sent."
                break
            case .saved:
                message = "Mail saved."
                break
            default:
                break
            }
        }
        self.view.makeToast(message: message, duration: 3, position: HRToastActivityPositionDefault)
    }
    
    
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        if contact != nil{
            if((contact?.givenName)! != "" && self.is_chatPage_contact == false)
            {
                let param = ["name" : (contact?.givenName)!]
                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Favourite_Contact, FetchString: opponent_id, attribute: "id", UpdationElements: param as NSDictionary)
                chatTableView.reloadData()
//                if(!ContactHandler.sharedInstance.StorecontactInProgress)
//                {
                    ContactHandler.sharedInstance.StoreContacts()
//                }
            }
        }
        viewController.dismissView(animated: true, completion: nil)
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let rows = tableView.numberOfRows(inSection: 0)
        guard rows - 1 < tableView.numberOfRows(inSection: 0) else {return}
        if indexPath.row == rows - 1 {
            DispatchQueue.main.async {
                if self.chatModel.dataSource.count > indexPath.row{
                    tableView.scrollToRow(at: IndexPath(row: indexPath.row, section: 0), at: .bottom, animated: true)
                }
            }
        }
    }
    
    private func checkLastMessage(for indexPath:IndexPath, with messageFrame: UUMessageFrame) -> Bool{
        if(indexPath.row == self.chatModel.dataSource.count-1)
        {
            return true
        }
        else
        {
            if(indexPath.row+1 <= self.chatModel.dataSource.count-1)
            {
                let CheckmessageFrame: UUMessageFrame = self.chatModel.dataSource[indexPath.row+1] as! UUMessageFrame
                if(messageFrame.message.from != CheckmessageFrame.message.from)
                {
                    return true
                }
                else
                {
                    return false
                }
            }
            else
            {
                return false
            }
        }
    }
    
    private func isSearchCell(_ messageFrame:UUMessageFrame) -> Bool{
        if(from_search_msg == true){
            if(from_search_msg_id == messageFrame.message.timestamp!){
                return true
            }
            else{
                return false
            }
            
        }
        else{
            return false
            
        }
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.section == 0)
        {
            let messageFrame: UUMessageFrame = self.chatModel.dataSource[indexPath.row] as! UUMessageFrame
            var cell_main : UITableViewCell = UITableViewCell()
            if(messageFrame.message.info_type == "0")
            {
                let cell1 = TableviewCellGenerator.sharedInstance.returnCell(for: tableView, messageFrame: messageFrame, indexPath: indexPath)
                cell1.delegate = self
                cell1.RowIndex = indexPath
                cell1.customButton.addTarget(self, action: #selector(self.didClickCellButton(_:)), for: .touchUpInside)
                cell1.backgroundColor = isSearchCell(messageFrame) ? .lightText : .clear
                
                let pan = UIPanGestureRecognizer(target: self, action: #selector(self.panGestureCellAction(_:)))
                pan.delegate = self
                cell1.contentView.tag = indexPath.row
                
                let long = UILongPressGestureRecognizer(target: self, action: #selector(self.longGestureCellAction(_:)))
                long.delegate = self
                
                cell1.contentView.addGestureRecognizer(pan)
                cell1.contentView.addGestureRecognizer(long)
                
                return cell1
                
            }
            else
            {
                
                let cell:ChatInfoCell = tableView.dequeueReusableCell(withIdentifier: "ChatInfoCell") as! ChatInfoCell
                cell.Info_Btn.tag = indexPath.row
                var infoStr : String = String()
                var dateStr : String = String()
                
                if(messageFrame.message.info_type == "21")
                {
                    cell.Info_Btn.isHidden = false
                    cell.date_lbl.isHidden = true
                    let call_type = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Call_detail, attrib_name: "doc_id", fetchString:messageFrame.message.doc_id , returnStr: "call_type")
                    if(call_type == "0")
                    {
                        infoStr = NSLocalizedString("☎︎ Missed Voice call at" , comment: "") + " " + Themes.sharedInstance.ReturnTimeForChat(timestamp: messageFrame.message.timestamp)
                        cell.Info_Btn.addTarget(self, action: #selector(self.DidclickAudio(_:)), for: .touchUpInside)
                    }
                    else if(call_type == "1")
                    {
                        infoStr = NSLocalizedString("☎︎ Missed Video call at" , comment: "") + " " +   Themes.sharedInstance.ReturnTimeForChat(timestamp: messageFrame.message.timestamp)
                        cell.Info_Btn.addTarget(self, action: #selector(self.DidclickVideo(_:)), for: .touchUpInside)
                    }
                }
                else if(messageFrame.message.info_type == "23"){
                    cell.Info_Btn.isHidden = false
                    cell.date_lbl.isHidden = true
                    if(messageFrame.message.user_from! == Themes.sharedInstance.Getuser_id())
                    {
                        infoStr = "Security code changed".localized()
                        
                    }else{
                        infoStr = "\(Themes.sharedInstance.setNameTxt(Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message.user_from), "single")) \("changed the security code".localized())"
                    }
                }
                    
                    
                else if(messageFrame.message.info_type == "13"){
                    cell.Info_Btn.isHidden = false
                    cell.date_lbl.isHidden = true
                    let time = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Secret_Chat, attrib_name: "doc_id", fetchString:messageFrame.message.doc_id! , returnStr: "incognito_timer")
                    if(time == "")
                    {
                        cell.Info_Btn.isHidden = true
                    }else{
                        if(messageFrame.message.user_from! == Themes.sharedInstance.Getuser_id())
                        {
                            infoStr = "You set expiration time to \(time)"
                        }else{
                            var name = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Favourite_Contact, attrib_name: "id", fetchString:messageFrame.message.user_from! , returnStr: "name")
                            if(name == ""){
                                name = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Favourite_Contact, attrib_name: "id", fetchString:messageFrame.message.user_from! , returnStr: "msisdn")
                            }
                            infoStr = "\(name) set expiration time to \(time)"
                        }
                    }
                }
                    
                else if(messageFrame.message.info_type == "71"){
                    cell.Info_Btn.isHidden = false
                    cell.date_lbl.isHidden = true
                    if(messageFrame.message.user_from! == Themes.sharedInstance.Getuser_id())
                    {
                        infoStr = "message can't be displayed"
                    }else{
                        var name = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Favourite_Contact, attrib_name: "id", fetchString:messageFrame.message.user_from! , returnStr: "name")
                        if(name == ""){
                            name = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Favourite_Contact, attrib_name: "id", fetchString:messageFrame.message.user_from! , returnStr: "msisdn")
                        }
                        infoStr = "\(name) taken screenshot"
                    }
                }
                else if(messageFrame.message.info_type == "72"){
                    
                    let encryptiocell:EncryptionTableViewCell = tableView.dequeueReusableCell(withIdentifier: "EncryptionTableViewCell") as! EncryptionTableViewCell
                    encryptiocell.msgLbl.layer.cornerRadius = 5.0
                    if(Chat_type == "group")
                    {
                        encryptiocell.msgLbl.text = NSLocalizedString("🔒 Messages to this groups are now secured with end-to-end encryption", comment:"dfd" )
                        
                    }
                    else
                    {
                        encryptiocell.msgLbl.text = NSLocalizedString("🔒 Messages to this chat and calls are now secured with end-to-end encryption", comment: "df" )
                    }
                    return encryptiocell
                }
                else if(messageFrame.message.info_type != "10")
                {
                    cell.Info_Btn.isHidden = false
                    cell.date_lbl.isHidden = true
                    if(messageFrame.message._id != nil)
                    {
                        
                        let checkOtherMessages:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Other_Group_message, attribute: "id", FetchString: messageFrame.message._id!)
                        if(checkOtherMessages)
                        {
                            let MessageInfoArr=DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Other_Group_message, attribute: "id", FetchString: messageFrame.message._id, SortDescriptor: nil) as! [NSManagedObject]
                            
                            if(MessageInfoArr.count > 0)
                            {
                                _ = MessageInfoArr.map{
                                    
                                    let messageDict=$0
                                    let GrounInfo=Themes.sharedInstance.CheckNullvalue(Passed_value: messageDict.value(forKey: "group_type"))
                                    let CreatedUserID = Themes.sharedInstance.CheckNullvalue(Passed_value: messageDict.value(forKey: "from"))
                                    
                                    infoStr = Themes.sharedInstance.returnOtherMessages(CreatedUserID, Themes.sharedInstance.CheckNullvalue(Passed_value: messageDict.value(forKey: "person_id")), GrounInfo)
                                    
                                    cell.Info_Btn.clipsToBounds=true
                                    cell.Info_Btn.layer.cornerRadius=5.0
                                }
                            }
                            
                        }
                        else
                        {
                            infoStr = "can't show this message"
                        }
                    }
                    else
                    {
                        infoStr = "can't show this message"
                    }
                }
                    
                else
                {
                    cell.Info_Btn.isHidden = true
                    cell.date_lbl.isHidden = false
                    dateStr = Themes.sharedInstance.ReturnDateTimeFormat(timestamp: messageFrame.message.timestamp)
                }
                
                var Info_Btnsize: CGSize = (infoStr as NSString).size(withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16.0)])
                Info_Btnsize.width = Info_Btnsize.width >= self.view.frame.size.width ? self.view.frame.size.width - 10 : Info_Btnsize.width
                
                cell.Info_Btn.frame = CGRect(x: ((cell.frame.size.width) - Info_Btnsize.width)/2  , y: ((cell.frame.size.height) - Info_Btnsize.height)/2 , width: Info_Btnsize.width, height: Info_Btnsize.height)

                cell.Info_Btn.setTitle(infoStr, for: .normal)

                var date_lblsize: CGSize = (dateStr as NSString).size(withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16.0)])
                date_lblsize.width = date_lblsize.width >= self.view.frame.size.width ? self.view.frame.size.width - 10 : date_lblsize.width

                cell.date_lbl.frame = CGRect(x: ((cell.frame.size.width) - date_lblsize.width + 5)/2  , y: ((cell.frame.size.height) - date_lblsize.height)/2 , width: date_lblsize.width + 5, height: date_lblsize.height)
                
                cell.date_lbl.setTitle(dateStr, for: .normal)
                
                cell_main = cell
                
            }
            cell_main.selectionStyle = .blue
            cell_main.backgroundColor = UIColor.clear
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.clear
            cell_main.selectedBackgroundView = backgroundView
            return cell_main
        }
        else
        {
            let cell:UnknownCell = tableView.dequeueReusableCell(withIdentifier: "UnknownCell") as! UnknownCell
            cell.delegate = self
            cell.user_id = opponent_id
            cell.updateUI()
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if(indexPath.section == 0)
        {
            let chat_Obj:UUMessageFrame = self.chatModel.dataSource[indexPath.row] as! UUMessageFrame
            if(chat_Obj.message.info_type == "0")
            {
                return true
            }
            return false
        }
        else
        {
            return false
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        var cell:ChatInfoCell? = tableView.dequeueReusableCell(withIdentifier: "ChatInfoCell") as! ChatInfoCell?
        let messageFrame: UUMessageFrame = self.chatModel.dataSource[indexPath.row] as! UUMessageFrame
        if cell == nil {
            cell = ChatInfoCell(style: .default, reuseIdentifier: "ChatInfoCell")
            //cell?.contentView.backgroundColor = UIColor.clear
        }
        
        
        if(from_search_msg == true){
            if(messageFrame.message.type == MessageType(rawValue: 0)! || messageFrame.message.type == MessageType(rawValue: 4)! || messageFrame.message.type == MessageType(rawValue: 1)!){
                if((from_search_msg_id == messageFrame.message.timestamp!) && (from_message == messageFrame.message.payload!)){
                    from_search_msg = false
                    DispatchQueue.main.async{
                        tableView.reloadRows(at: [indexPath], with: .none)
                    }
                    
                }else if(from_search_msg_id == messageFrame.message.timestamp!){
                    from_search_msg = false
                    DispatchQueue.main.async{
                        tableView.reloadRows(at: [indexPath], with: .none)
                    }
                }
                else{
                    from_search_msg = false
                    DispatchQueue.main.async{
                        tableView.reloadRows(at: [indexPath], with: .none)
                    }
                }
            }else if(messageFrame.message.type == MessageType(rawValue: 5)!){
                if((from_search_msg_id == messageFrame.message.timestamp!) && (from_message == messageFrame.message.contact_name!)){
                    from_search_msg = false
                    DispatchQueue.main.async{
                        tableView.reloadRows(at: [indexPath], with: .none)
                    }
                }else{
                    from_search_msg = false
                    DispatchQueue.main.async{
                        tableView.reloadRows(at: [indexPath], with: .none)
                    }
                }
            }else if(messageFrame.message.type == MessageType(rawValue: 3)!){
                if(from_search_msg_id == messageFrame.message.timestamp!){
                    from_search_msg = false
                    DispatchQueue.main.async{
                        tableView.reloadRows(at: [indexPath], with: .none)
                    }
                }
            }
        }
        
        if(isBeginEditing)
        {
            
            if(chatTableView.indexPathsForSelectedRows != nil)
            {
                let indexpath:[IndexPath] = chatTableView.indexPathsForSelectedRows!
                
                if(indexpath.count > 0)
                {
                    left_item.isEnabled = true
                    
                }
                else
                {
                    left_item.isEnabled = false
                    
                }
            }
            else
                
            {
                left_item.isEnabled = false
                
            }
        }
        
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        if(isBeginEditing)
        {
            if(chatTableView.indexPathsForSelectedRows != nil)
            {
                let indexpath:[IndexPath] = chatTableView.indexPathsForSelectedRows!
                
                if(indexpath.count > 0)
                {
                    left_item.isEnabled = true
                    
                }
                else
                {
                    left_item.isEnabled = false
                    
                }
            }
            else
                
            {
                left_item.isEnabled = false
                
            }
        }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if((gestureRecognizer as? UIPanGestureRecognizer) != nil)
        {
            let velocity: CGPoint = (gestureRecognizer as! UIPanGestureRecognizer).velocity(in: self.chatTableView)
            
            var messageFrame = UUMessageFrame()
            if(self.chatModel.dataSource.count > (gestureRecognizer.view?.tag)!)
            {
                messageFrame = (self.chatModel.dataSource as! [UUMessageFrame])[(gestureRecognizer.view?.tag)!]
            }
            if (velocity.x < 0 && messageFrame.message.from == MessageFrom(rawValue: 0)) {
                return false
            }
            else if(velocity.x > 0 && messageFrame.message.from == MessageFrom(rawValue: 0) && is_you_removed)
            {
                return false
            }
            else if(velocity.x > 0 && messageFrame.message.from == MessageFrom(rawValue: 1) && is_you_removed)
            {
                return false
            }
            return fabs(Float(velocity.x)) > fabs(Float(velocity.y))
        }
        else
        {
            return true
        }
        
    }
    
    @IBAction func panGestureCellAction(_ recognizer: UIPanGestureRecognizer) {
        let cell = self.chatTableView.cellForRow(at: IndexPath(row: (recognizer.view?.tag)!, section: 0)) as? CustomTableViewCell
        var messageFrame = UUMessageFrame()
        if(self.chatModel.dataSource.count > (recognizer.view?.tag)!)
        {
            messageFrame = (self.chatModel.dataSource as! [UUMessageFrame])[(recognizer.view?.tag)!]
        }
        let translation: CGPoint = recognizer.translation(in: view)
        
        
        if (recognizer.view?.frame.origin.x ?? 0.0) < 0.0 { //Swipe to Left
            if(messageFrame.message.from == MessageFrom(rawValue: 1))
            {
                recognizer.view?.center = CGPoint(x: (recognizer.view?.center.x ?? 0.0) + translation.x, y: recognizer.view?.center.y ?? 0.0)
                recognizer.setTranslation(CGPoint(x: 0, y: 0), in: view)
                UIView.animate(withDuration: 0.25) {
                    cell?.replyImg.alpha = 1.0
                }
                
                if (recognizer.view?.frame.origin.x ?? 0.0) < -(UIScreen.main.bounds.size.width * 0.9) {
                    UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                        recognizer.view?.frame = CGRect(x: 0, y: recognizer.view?.frame.origin.y ?? 0.0, width: recognizer.view?.frame.size.width ?? 0.0, height: recognizer.view?.frame.size.height ?? 0.0)
                    })
                }
                if recognizer.state == .ended {
                    let x = Int(recognizer.view?.frame.origin.x ?? 0)
                    UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                        recognizer.view?.frame = CGRect(x: 0, y: recognizer.view?.frame.origin.y ?? 0.0, width: recognizer.view?.frame.size.width ?? 0.0, height: recognizer.view?.frame.size.height ?? 0.0)
                    }) { finished in
                        if CGFloat(x) < -50 {
                            let messageinfoVC = self.storyboard?.instantiateViewController(withIdentifier:"MessageInfoViewControllerID" ) as! MessageInfoViewController
                            messageinfoVC.ChatType = self.Chat_type
                            messageinfoVC.messageinfo = messageFrame
                            self.pushView(messageinfoVC, animated: true)
                        }
                        cell?.replyImg.alpha = 0.0
                    }
                }
            }
        }
        else //Swipe to Right
        {
            UIView.animate(withDuration: 0.25) {
                cell?.replyImg.alpha = 1.0
            }
            recognizer.view?.center = CGPoint(x: (recognizer.view?.center.x ?? 0.0) + translation.x, y: recognizer.view?.center.y ?? 0.0)
            recognizer.setTranslation(CGPoint(x: 0, y: 0), in: view)
            
            if (recognizer.view?.frame.origin.x ?? 0.0) > UIScreen.main.bounds.size.width * 0.9 {
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                    recognizer.view?.frame = CGRect(x: 0, y: recognizer.view?.frame.origin.y ?? 0.0, width: recognizer.view?.frame.size.width ?? 0.0, height: recognizer.view?.frame.size.height ?? 0.0)
                })
            }
            if recognizer.state == .ended {
                let x = Int(recognizer.view?.frame.origin.x ?? 0)
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                    recognizer.view?.frame = CGRect(x: 0, y: recognizer.view?.frame.origin.y ?? 0.0, width: recognizer.view?.frame.size.width ?? 0.0, height: recognizer.view?.frame.size.height ?? 0.0)
                }) { finished in
                    if CGFloat(x) > 85 {
                        if(messageFrame.message.message_status != "0")
                        {
                            self.IFView.become_FirtResponder()
                            self.ShowReplyView(messageFrame)
                        }
                    }
                    cell?.replyImg.alpha = 0.0
                }
            }
        }
    }
    
    @IBAction func longGestureCellAction(_ recognizer: UILongPressGestureRecognizer)
    {
        if let point = recognizer.view?.convert(recognizer.location(in: recognizer.view), to: self.view) {
            
            if(popovershow == false)
            {
                popovershow = true
                
                let index = IndexPath(row: (recognizer.view?.tag)!, section: 0)
                
                let cell = self.chatTableView.cellForRow(at: index)
                var messageFrame = UUMessageFrame()
                if(self.chatModel.dataSource.count > (recognizer.view?.tag)!)
                {
                    messageFrame = (self.chatModel.dataSource as! [UUMessageFrame])[(recognizer.view?.tag)!]
                }
                
                let cellConfi = FTCellConfiguration()
                cellConfi.textColor = UIColor.black.withAlphaComponent(0.7)
                cellConfi.textFont = UIFont.systemFont(ofSize: 15.0)
                cellConfi.textAlignment = .left
                cellConfi.menuIconSize = 17.0
                cellConfi.ignoreImageOriginalColor = true
                
                let menuOptionNameArray = self.longGestureDataSource(messageFrame: messageFrame).0
                
                let menuOptionImageNameArray = self.longGestureDataSource(messageFrame: messageFrame).1
                
                let config = FTConfiguration.shared
                config.backgoundTintColor = UIColor(red: 213/255, green: 213/255, blue: 211/255, alpha: 1.0)
                config.borderColor = UIColor.clear
                config.menuWidth = 135
                config.menuSeparatorColor = UIColor.lightGray
                config.menuRowHeight = 44
                config.cornerRadius = 15
                config.globalShadow = true
                
                let rectOfCell = self.chatTableView.rectForRow(at: index)
                let rectOfCellInSuperview = self.chatTableView.convert(rectOfCell, to: AppDelegate.sharedInstance.window?.view)
                
                _ = config.selectedView.subviews.map {
                    $0.removeFromSuperview()
                }
                config.selectedView.frame = rectOfCellInSuperview
                config.selectedView.addSubview(self.copyView(viewforCopy: (cell?.contentView)!))
                
                FTPopOverMenu.showFromSenderFrame(senderFrame: CGRect(origin: point, size: CGSize.zero), with: menuOptionNameArray, menuImageArray: menuOptionImageNameArray, cellConfigurationArray: Array(repeating: cellConfi, count: menuOptionNameArray.count), done: { (selectedIndex) in
                    self.popovershow = false
                    self.view.endEditing(true)
                    let action = menuOptionNameArray[selectedIndex]
                    if(action == NSLocalizedString("Delete", comment:"Delete"))
                    {
                        self.isForwardAction = false
                        self.isBeginEditing = true
                        self.left_item.image = #imageLiteral(resourceName: "trash")
                        self.right_item.title = NSLocalizedString("Cancel", comment:"CancelClear")
                        self.center_item.title = ""
                        //self.center_item.title = NSLocalizedString("Clear Chat", comment:"Clear Chat")
                        self.Firstindexpath = index
                        self.perform(#selector(self.SelectIndexpath), with:self , afterDelay: 0.3)
                        self.ShowToolBar()
                    }
                    else if(action == NSLocalizedString("Info", comment:"Info"))
                    {
                        let messageinfoVC = self.storyboard?.instantiateViewController(withIdentifier:"MessageInfoViewControllerID" ) as! MessageInfoViewController
                        messageinfoVC.ChatType = self.Chat_type
                        messageinfoVC.messageinfo = messageFrame
                        self.pushView(messageinfoVC, animated: true)
                        
                    }
                    else if(action == NSLocalizedString("Reply", comment: "Reply"))
                    {
                        self.ShowReplyView(messageFrame)
                    }
                    else  if(action == NSLocalizedString("Forward", comment:"ForwardNext"))
                    {
                        self.isForwardAction = true
                        self.isBeginEditing = true
                        self.left_item.image = #imageLiteral(resourceName: "forward")
                        self.right_item.title = NSLocalizedString("Cancel", comment: "cancelChat")
                        self.center_item.title = ""
                       // self.center_item.title = NSLocalizedString("Forward", comment:"ForwardNext")
                        self.Firstindexpath = index
                        self.perform(#selector(self.SelectIndexpath), with:self , afterDelay: 0.3)
                        self.ShowToolBar()
                        
                    }
                    else  if(action == NSLocalizedString("Flag", comment: "Star"))
                    {
                        messageFrame.message.isStar = "1"
                        self.StarMessage(status: "1", DocId: messageFrame.message.doc_id,convId:messageFrame.message.conv_id,recordId:messageFrame.message.recordId)
                        DispatchQueue.main.async{
                            self.chatTableView.reloadRows(at: [index], with: .none)
                        }
                        
                    }
                    else  if(action == NSLocalizedString("Unflag", comment: "Unstar"))
                    {
                        messageFrame.message.isStar = "0"
                        self.StarMessage(status: "0", DocId: messageFrame.message.doc_id,convId:messageFrame.message.conv_id,recordId:messageFrame.message.recordId )
                        DispatchQueue.main.async{
                            self.chatTableView.reloadRows(at: [index], with: .none)
                        }
                        
                    }
                    else if(action == NSLocalizedString("Copy", comment:"Copy"))
                    {
                        //copy for map
                        if(messageFrame.message.message_type == "14"){
                            UIPasteboard.general.string = "https://maps.google.com/?g=\(messageFrame.message.latitude!),\(messageFrame.message.longitude!)"
                        }else{
                            UIPasteboard.general.string = messageFrame.message.payload
                        }
                    }
                    
                }) {
                    self.popovershow = false
                }
            }
        }
    }
    
    func copyView(viewforCopy: UIView) -> UIView {
        if let viewCopy = viewforCopy.snapshotView(afterScreenUpdates: true) {
            return viewCopy
        }
        return UIView()
    }
    
    func longGestureDataSource(messageFrame : UUMessageFrame) -> ([String], [String]){
        
        var menuOptionNameArray : [String] = []
        var menuOptionImageNameArray : [String] = []
        
        var StarString:String = ""
        if(messageFrame.message.isStar == "1")
        {
            StarString = NSLocalizedString("Unflag", comment: "Unstar")
        }
        else
        {
            StarString = NSLocalizedString("Flag", comment: "Star")
        }
        if(messageFrame.message.from == MessageFrom(rawValue: 1))
        {
            let customMenuItem = StarString
            let customMenuItem2 = NSLocalizedString("Reply", comment: "Reply")
            let customMenuItem3 = NSLocalizedString("Forward", comment:"ForwardNext")
            let customMenuItem4 = NSLocalizedString("Copy", comment:"Copy")
            let customMenuItem5 = NSLocalizedString("Info", comment:"Info")
            let customMenuItem6 = NSLocalizedString("Delete", comment:"Delete")
            if(messageFrame.message.message_status == "0")
            {
                if(messageFrame.message.is_deleted == "1")
                {
                    menuOptionNameArray = [customMenuItem6]
                    menuOptionImageNameArray = ["menu_delete"]
                    
                    
                }
                else
                {
                    menuOptionNameArray = [customMenuItem,customMenuItem3,customMenuItem4,customMenuItem5,customMenuItem6]
                    menuOptionImageNameArray = ["menu_star", "menu_forward", "menu_copy", "menu_info", "menu_delete"]
                }
                
            }
            else
            {
                if(messageFrame.message.is_deleted == "1")
                {
                    menuOptionNameArray = [customMenuItem6]
                    menuOptionImageNameArray = ["menu_delete"]
                }
                else
                {
                    menuOptionNameArray = [customMenuItem,customMenuItem2,customMenuItem3,customMenuItem4,customMenuItem5,customMenuItem6]
                    menuOptionImageNameArray = ["menu_star", "menu_reply", "menu_forward", "menu_copy", "menu_info", "menu_delete"]
                    
                }
                
            }
            if(is_you_removed)
            {
                if (menuOptionNameArray.contains(customMenuItem2))
                {
                    let index = (menuOptionNameArray.index(of: customMenuItem2))!
                    menuOptionNameArray.remove(at: index)
                    menuOptionImageNameArray.remove(at: index)
                }
            }
            
            if messageFrame.message.payload == "" && menuOptionNameArray.contains(customMenuItem4)
            {
                let index = (menuOptionNameArray.index(of: customMenuItem4))!
                menuOptionNameArray.remove(at: index)
                menuOptionImageNameArray.remove(at: index)
                
            }
            
        }
        else
        {
            let customMenuItem = StarString
            let customMenuItem2 = NSLocalizedString("Reply", comment: "Reply")
            let customMenuItem3 = NSLocalizedString("Forward", comment:"Forward")
            let customMenuItem4 = NSLocalizedString("Copy", comment:"Copy")
            let customMenuItem6 = NSLocalizedString("Delete", comment:"Delete")
            //
            if(messageFrame.message.message_status == "0")
            {
                if(messageFrame.message.is_deleted == "1")
                {
                    menuOptionNameArray = [customMenuItem6]
                    menuOptionImageNameArray = ["menu_delete"]
                }
                else
                {
                    menuOptionNameArray = [customMenuItem,customMenuItem3,customMenuItem4,customMenuItem6]
                    menuOptionImageNameArray = ["menu_star", "menu_forward", "menu_copy", "menu_delete"]
                }
            }
            else
            {
                if(messageFrame.message.is_deleted == "1")
                {
                    menuOptionNameArray = [customMenuItem6]
                    menuOptionImageNameArray = ["menu_delete"]
                }
                else
                {
                    menuOptionNameArray = [customMenuItem,customMenuItem2,customMenuItem3,customMenuItem4,customMenuItem6]
                    menuOptionImageNameArray = ["menu_star", "menu_reply", "menu_forward", "menu_copy", "menu_delete"]
                }
                
            }
            if(is_you_removed)
            {
                if (menuOptionNameArray.contains(customMenuItem2))
                {
                    let index = (menuOptionNameArray.index(of: customMenuItem2))!
                    menuOptionNameArray.remove(at: index)
                    menuOptionImageNameArray.remove(at: index)
                }
            }
            if messageFrame.message.payload == "" && menuOptionNameArray.contains(customMenuItem4)
            {
                let index = (menuOptionNameArray.index(of: customMenuItem4))!
                menuOptionNameArray.remove(at: index)
                menuOptionImageNameArray.remove(at: index)
            }
        }
        return (menuOptionNameArray, menuOptionImageNameArray)
    }
    
    func Add_To_Conacts()
    {
        
        var phone_num:[CNLabeledValue<CNPhoneNumber>] = []
        let phonenumber = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Favourite_Contact, attrib_name: "id", fetchString: opponent_id, returnStr: "msisdn")
        phone_num.append(CNLabeledValue(label:"Home" , value:CNPhoneNumber(stringValue: phonenumber)))
        
        let contact = CNMutableContact()
        
        if(phone_num.count > 0){
            
            contact.phoneNumbers = phone_num
        }
        
        let controller = CNContactViewController(forNewContact: contact)
        controller.delegate = self
        
        let navigationController = UINavigationController(rootViewController: controller)
        self.presentView(navigationController, animated: true)
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    func headImageDidClick(_ cell: UUMessageCell, userId: String)
    {        // headIamgeIcon is clicked
    }
    
    
    func updateDetail(name:String,phNo:String,Image:String){
    }
    
    func cellContentDidClick(_ cell: UUMessageCell, image contentImage: UIImage)
    {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func Didclick_Back(_ sender: Any) {
        if(fromForward || goBack)
        {
            self.popToRoot(animated: true)
        }
        else
        {
            var i = 0
            _ = navigationController?.viewControllers.map {
                if $0.isKind(of: InitiateChatViewController.self) {
                    i = i+1
                }
            }
            if(i >= 2)
            {
                self.popToRoot(animated: true)
            }
            else
            {
                self.pop(animated: true)
            }
            
        }
    }
    // MARK: - Document Scan Delegate
    @available(iOS 13.0, *)
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        self.scanedDocuments = [DKAsset]()
        self.scanedDocumentsCount = 0
        
        // convert images to pdf
        let pdfDocument = PDFDocument()
        let objRecord:DocumentRecord = DocumentRecord()
        for pageNumber in 0..<scan.pageCount {
            let image = scan.imageOfPage(at: pageNumber)
            
            // Create a PDF page instance from your image
            
            var pdfPage = PDFPage()
            if let data = image.jpegData(compressionQuality: 0.3) {
                if let dataIMg  = UIImage(data: data) {
                    pdfPage = PDFPage(image: dataIMg) ?? PDFPage()
                }
            }

            pdfDocument.insert(pdfPage, at: pageNumber)

        }
        let data = pdfDocument.dataRepresentation()
        
        //Get the local docs directory and append your local filename.
        var docURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last as? NSURL

        docURL = docURL?.appendingPathComponent("myFileName.pdf") as NSURL?
        //data?.write(to: docURL as! URL)
        //data?.writeT(docURL!, atomically: true)
        do {
            try data?.write(to: docURL! as URL)
        }
        catch{
        print("file write error")
        }
        
        //Lastly, write your file to the disk.
      //  data?.writeToURL(docURL!, atomically: true)
        
        let pageCount: size_t = pdfDocument.pageCount
                   objRecord.docPageCount = "\(pageCount)"
                   objRecord.docType = "1"
        objRecord.docImage = scan.imageOfPage(at: 0)
        objRecord.docPath = docURL as URL?
                   objRecord.path_extension = "pdf"
                   objRecord.docName = "PDF_File"
      // Get the raw data of your PDF document
        var filesize = Float()
        var Docdata = Data()
               if(objRecord.docType != "")
               {
                   do
                   {
                    Docdata = data!
                       filesize = Float(Docdata.count) / 1024.0 / 1024.0
                       if(filesize > Constant.sharedinstance.DocumentUploadSize)
                       {
                           _ = JSSAlertView().show(self,title: Themes.sharedInstance.GetAppname(),text: "Document size exceeded. Kindly choose below 30 MB size file.",buttonText: "OK",color: CustomColor.sharedInstance.alertColor)
                           return
                       }
                   }
                   catch
                   {
                       print(error.localizedDescription)
                   }
                   
                   SaveDoc(objRecord: objRecord) { Dict in
                       
                       var secret_msg_id:String = ""
                       if(Dict.count > 0)
                       {
                           let from = Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
                           let to = Themes.sharedInstance.CheckNullvalue(Passed_value: self.opponent_id)
                           var timestamp:String =  String(Date().ticks)
                           var servertimeStr:String = Themes.sharedInstance.getServerTime()
                           var user_common_id:String = ""
                           if(self.Chat_type == "secret"){
                               user_common_id = Themes.sharedInstance.CheckNullvalue(Passed_value: to + "-" + from)
                               var checksecretmessagecount:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Secret_Chat, attribute: "user_common_id", FetchString: user_common_id, SortDescriptor: "timestamp") as! NSArray
                               checksecretmessagecount = checksecretmessagecount.reversed() as NSArray
                               
                               if(checksecretmessagecount.count > 0)
                               {
                                   
                                   secret_msg_id = Themes.sharedInstance.CheckNullvalue(Passed_value: (checksecretmessagecount[0] as! NSManagedObject).value(forKey: "doc_id"))
                               }
                           }else{
                               user_common_id = Themes.sharedInstance.CheckNullvalue(Passed_value: from + "-" + to)
                           }
                           if(servertimeStr == "")
                           {
                               servertimeStr = "0"
                           }
                           let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
                           timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
                           if(self.Chat_type == "group")
                           {
                               timestamp = self.document_msg_id
                           }
                           let _:String = Dict.object(forKey: "id") as! String
                           let Name:String=Themes.sharedInstance.setNameTxt(Themes.sharedInstance.Getuser_id(), "")
                           let Phonenumber:String=Themes.sharedInstance.setPhoneTxt(Themes.sharedInstance.Getuser_id())
                           
                           let dic:[AnyHashable: Any] = ["type": "6","convId":"","doc_id":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(self.document_doc_id)"
                               ),"filesize":"","from":Themes.sharedInstance.CheckNullvalue(Passed_value:from
                               ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:to
                               ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
                               ),"message_status":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
                               ),"id":timestamp,"name":Themes.sharedInstance.CheckNullvalue(Passed_value:Name
                               ),"payload":"Document","recordId":"","timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
                               ),"thumbnail":self.pathname,"width":"0.0","height":"0.0","msgId":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
                               ),"contactmsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value:Phonenumber
                               ),"user_common_id":user_common_id,"message_from":"1","chat_type":self.Chat_type,"info_type":"0","created_by":from,"docType":objRecord.docType,"docName":objRecord.docName,"docPageCount":objRecord.docPageCount,"is_reply":"0","secret_msg_id":secret_msg_id,"secret_timestamp":"", "date" : Themes.sharedInstance.getTimeStamp(), "while_blocked" : Themes.sharedInstance.isImBlocked(to) ? "1" : "0"]
                           DatabaseHandler.sharedInstance.InserttoDatabase(Dict: dic as NSDictionary,Entityname: Constant.sharedinstance.Chat_one_one)

                           if(self.Chat_type == "secret"){
                               let chatarray:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: "\(to)-\(from)")
                               if(!chatarray)
                               {
                                   let User_dict:[AnyHashable: Any] = ["user_common_id": "\(to)-\(from)","user_to_dp":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_type":self.Chat_type,"is_archived":"0","conv_id":"","timestamp":timestamp,"opponent_id":to,"is_read":"0","chat_count":"0"]
                                   DatabaseHandler.sharedInstance.InserttoDatabase(Dict: User_dict as NSDictionary,Entityname: Constant.sharedinstance.Chat_intiated_details)
                                   
                               }
                               else
                               {
                                   let User_dict:[AnyHashable: Any]=["timestamp":timestamp,"is_archived":"0","is_read":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_count":"0"]
                                   DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: "\(to)-\(from)" , attribute: "user_common_id", UpdationElements: User_dict as NSDictionary?)
                               }
                           }else{
                               let chatarray:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: "\(from)-\(to)")
                               if(!chatarray)
                               {
                                   let User_dict:[AnyHashable: Any] = ["user_common_id": "\(from)-\(to)","user_to_dp":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_type":self.Chat_type,"is_archived":"0","conv_id":"","timestamp":timestamp,"opponent_id":to,"is_read":"0","chat_count":"0"]
                                   DatabaseHandler.sharedInstance.InserttoDatabase(Dict: User_dict as NSDictionary,Entityname: Constant.sharedinstance.Chat_intiated_details)
                                   
                               }
                               else
                               {
                                   let User_dict:[AnyHashable: Any]=["timestamp":timestamp,"is_archived":"0","is_read":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_count":"0"]
                                   DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: "\(from)-\(to)" , attribute: "user_common_id", UpdationElements: User_dict as NSDictionary?)
                               }
                           }
                           DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                               self.dealTheFunctionData(dic, fromOrdering: false)
                               
                           }
                           DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                               UploadHandler.Sharedinstance.handleUpload()
                           }
                       }
                   }
               }
               else
               {
                   Themes.sharedInstance.jssAlertView(viewController: self, title: Themes.sharedInstance.GetAppname(), text: "Unable to upload this file format", buttonTxt: "Ok", color: CustomColor.sharedInstance.alertColor)
               }
        // Process the scanned pages
//        for pageNumber in 0..<scan.pageCount {
//            let image = scan.imageOfPage(at: pageNumber)
//        var changeRequest: PHAssetChangeRequest?
//        var blockPlaceholder: PHObjectPlaceholder?
//
//        PHPhotoLibrary.shared().performChanges({
//            changeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
//            blockPlaceholder = changeRequest?.placeholderForCreatedAsset
//        }) { saved, error in
//                    if saved {
//                        guard let placeholder = blockPlaceholder else {
//                            return
//                        }
//                        let fetchOptions = PHFetchOptions()
//                        let fetchResult:PHFetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [placeholder.localIdentifier], options: fetchOptions)
//                        if let asset = fetchResult.firstObject {
//                            //here you have the PHAsset
//                            DispatchQueue.main.async {
//                                    Themes.sharedInstance.activityView(View: self.view)
//                            }
//                            let asset : DKAsset = DKAsset(originalAsset: asset)
//                            self.scanedDocuments.append(asset)
//                            self.scanedDocumentsCount = self.scanedDocumentsCount + 1
//                            if(self.scanedDocuments.count > 0 && self.scanedDocumentsCount == scan.pageCount)
//                            {
//                                self.selectedAssets = self.scanedDocuments
//
//                                if(self.Chat_type == "group")
//                                {
//                                    AssetHandler.sharedInstance.isgroup = true
//                                }
//                                else
//                                {
//                                    AssetHandler.sharedInstance.isgroup = false
//
//                                }
//                                AssetHandler.sharedInstance.ProcessAsset(assets: self.scanedDocuments,oppenentID: self.opponent_id,isFromStatus: false, completionHandler: { [weak self] (AssetArr, error) -> ()? in
//                                    if((AssetArr?.count)! > 0)
//                                    {     DispatchQueue.main.async {
//                                        Themes.sharedInstance.RemoveactivityView(View: (self?.view)!)
//                                        let EditVC = self?.storyboard?.instantiateViewController(withIdentifier: "EditViewControllerID") as! EditViewController
//                                        EditVC.AssetArr = AssetArr!
//                                        EditVC.isfromStatus = false
//                                        EditVC.Delegate = self
//                                        EditVC.selectedAssets = (self?.selectedAssets)!
//                                        EditVC.isgroup = AssetHandler.sharedInstance.isgroup
//                                        EditVC.to_id = (self?.opponent_id)!
//                                        self?.pushView(EditVC, animated: true)
//                                        }
//                                    }
//                                    return ()
//                                })
//                            }
//
//                        }
//                    }
//        }
//
//
//
//        }
            
        

        // You are responsible for dismissing the controller.
        controller.dismiss(animated: true)
        
    }
    
    @available(iOS 13.0, *)
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        // You are responsible for dismissing the controller.
        controller.dismiss(animated: true)
    }
    
    @available(iOS 13.0, *)
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        // You should handle errors appropriately in your app.
        print(error)

        // You are responsible for dismissing the controller.
        controller.dismiss(animated: true)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    @IBAction func DidClickInfo(_ sender: Any) {
        let from = Themes.sharedInstance.Getuser_id()
        let to = Themes.sharedInstance.CheckNullvalue(Passed_value: opponent_id)
        let User_common_id=from + "-" + to;
        if(Chat_type == "group")
        {
            let GroupInfoVC:GroupInfoViewController=self.storyboard?.instantiateViewController(withIdentifier: "GroupInfoVCID") as! GroupInfoViewController
            GroupInfoVC.common_id=User_common_id
            GroupInfoVC.group_convId = to
            GroupInfoVC.is_you_removed = is_you_removed
            self.pushView(GroupInfoVC, animated: true)
        }
        else
        {
            let singleInfoVC:SingleInfoViewController=self.storyboard?.instantiateViewController(withIdentifier: "SingleInfoViewController") as! SingleInfoViewController
            singleInfoVC.user_id = opponent_id
            singleInfoVC.delegate = self
            singleInfoVC.isfromsecretChat = is_fromSecret
            singleInfoVC.dataSource = self.chatModel.dataSource
            self.pushView(singleInfoVC, animated: true)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if(scrollView == chatTableView)
        {
            let tableviewoffPostion:CGFloat = chatTableView.contentSize.height-(chatTableView.frame.size.height)
            let Offsetpostion = tableviewoffPostion-scrollView.contentOffset.y
            if(Offsetpostion > self.view.frame.size.height)
            {
                bottomnavigateView.isHidden = false
            }
            else
            {
                bottomnavigateView.isHidden = true
            }
            
            let actualPosition = scrollView.contentOffset.y
            if(actualPosition <= 100)
            {
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.PerformPagination), object: nil)
                
                self.perform(#selector(self.PerformPagination), with: nil, afterDelay: 0.2)
                
                
                
            }
        }
    }
    
    func scrollToCell(at row:Int){
        if self.chatModel.dataSource.count == 0 ||  self.chatModel.dataSource.count == 1{
            return
        }
        guard chatModel.dataSource.count > row else{return}
        let indexPath = IndexPath(row: row, section: 0)
        self.chatTableView.scrollToRow(at: indexPath, at: .top, animated: false)
    }
    
    
    @objc func PerformPagination()
    {
        let previousCount = self.chatModel.dataSource.count
        if(previousCount > 0)
        {
            self.LoadNextRange(start: self.chatModel.dataSource.count-1, limit: 20, is_from_search: false)
            let latestCount = self.chatModel.dataSource.count
            if(previousCount != latestCount)
            {
                
                let messageFrame = (self.chatModel.dataSource as! [UUMessageFrame]).filter({$0.message.info_type  == "10"})
                if(messageFrame.count > 0)
                {
                    _ = messageFrame.map{
                        let i = self.chatModel.dataSource.index(of: $0)
                        self.chatModel.dataSource.removeObject(at: i)
                    }
                }
                
                var orderingArr = [UUMessageFrame]()
                _ = (self.chatModel.dataSource as! [UUMessageFrame]).map {
                    if(orderingArr.count > 0)
                    {
                        let messageFrame = orderingArr[orderingArr.count - 1]
                        let timestamp:String = Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message.timestamp)
                        if(timestamp != "")
                        {
                            let presenttimestamp:String =  Themes.sharedInstance.CheckNullvalue(Passed_value: $0.message.timestamp)
                            let Prevdate:Date = Themes.sharedInstance.ConverttimeStamptodateentity(timestamp: timestamp) as Date
                            let Presentdate:Date = Themes.sharedInstance.ConverttimeStamptodateentity(timestamp: presenttimestamp) as Date
                            var components:Int! = Themes.sharedInstance.ReturnNumberofDays(fromdate:Prevdate , todate: Presentdate)
                            if(components == 0)
                            {
                                if(!Calendar.current.isDate(Prevdate, inSameDayAs: Presentdate))
                                {
                                    components = 1
                                }
                            }
                            if components != 0 {
                                let dict:[String: String] = ["type": "0","convId":"","doc_id":"","filesize":"","from":""
                                    ,"to":"","isStar":"","message_status":"","id":"","name":"","payload":"","recordId":"","timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:$0.message.timestamp),"thumbnail":"","width":"0.0","height":"0.0","msgId":""
                                    ,"contactmsisdn":"","user_common_id":"","message_from":"","chat_type":"","info_type":"10","created_by":""]
                                orderingArr.append(self.returnMessageFrame(dict: dict, type: MessageType.UUMessageTypeText))
                            }
                        }
                        
                    }
                    else
                    {
                        let dict:[String: String] = ["type": "0","convId":"","doc_id":"","filesize":"","from":""
                            ,"to":"","isStar":"","message_status":"","id":"","name":"","payload":"","recordId":"","timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:$0.message.timestamp),"thumbnail":"","width":"0.0","height":"0.0","msgId":""
                            ,"contactmsisdn":"","user_common_id":"","message_from":"","chat_type":"","info_type":"10","created_by":""]
                        
                        orderingArr.append(self.returnMessageFrame(dict: dict, type: MessageType.UUMessageTypeText))
                    }
                    orderingArr.append($0)
                }
                
                self.chatModel.dataSource.removeAllObjects()
                self.chatModel.dataSource.addObjects(from: orderingArr)
                
                var j = 0
                var arr = [IndexPath]()
                for _ in self.chatTableView.numberOfRows(inSection: 0)-1..<self.chatModel.dataSource.count-1 {
                    arr.append(IndexPath(row: j, section: 0))
                    j += 1
                }
                
                self.chatTableView.reloadData()
                
                if self.chatModel.dataSource.count < 21{
                    self.tableViewScrollToBottom()
                }else{
                    self.scrollToCell(at: j + 1)
                }
                
                if(from_search_msg == true && self.chatTableView.isHidden == true)
                {
                    let messageFrame = (self.chatModel.dataSource as! [UUMessageFrame]).filter({$0.message.timestamp!  == self.from_search_msg_id}).first
                    if(messageFrame != nil)
                    {
                        let index = self.chatModel.dataSource.index(of: messageFrame!)
                        self.tableViewScrollToRow(row: index)
                    }
                    else
                    {
                        DispatchQueue.main.async {
                            self.PerformPagination()
                        }
                    }
                }
            }
        }
    }
    
    
    func returnMessageFrame(dict : [String : String], type : MessageType) -> UUMessageFrame
    {
        let newmessageFrame = UUMessageFrame()
        let message = UUMessage()
        message.type = type;
        message.strContent = dict["payload"];
        message.conv_id = dict["convId"];
        message.doc_id = dict["doc_id"];
        message.filesize = dict["filesize"];
        message.user_from = dict["from"];
        message.isStar = dict["isStar"];
        message.message_status = dict["message_status"];
        message.msgId = dict["msgId"];
        message.name = dict["name"];
        message.payload = dict["payload"];
        message.recordId = dict["recordId"];
        message.thumbnail = dict["thumbnail"];
        message.timestamp = dict["timestamp"];
        message.to = dict["to"];
        message.width = dict["width"];
        message.height = dict["height"];
        message.chat_type = dict["chat_type"];
        message.info_type = dict["info_type"];
        message._id = dict["id"];
        message.contactmsisdn = dict["contactmsisdn"];
        message.progress = "0.0";
        message.message_type = dict["type"];
        message.user_common_id = dict["user_common_id"];
        message.imagelink = "";
        message.latitude = "";
        message.longitude = "";
        message.title_place = "";
        message.stitle_place = "";
        message.is_deleted = dict["is_deleted"];
        message.reply_type = dict["reply_type"];
        newmessageFrame.message = message
        return newmessageFrame
    }
    
    
    func LoadNextRange(start: NSInteger, limit:NSInteger, is_from_search: Bool)
    {
        let from = Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
        let to = Themes.sharedInstance.CheckNullvalue(Passed_value: opponent_id)
        var User_chat_id:String = ""
        if(self.Chat_type == "secret"){
            User_chat_id=to + "-" + from
        }else{
            User_chat_id=from + "-" + to
        }
        
        
        let P1:NSPredicate = NSPredicate(format: "chat_type = %@", self.Chat_type)
        let P2:NSPredicate = NSPredicate(format: "user_common_id = %@", User_chat_id)
        let fetch_predicate:NSCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [P1,P2])
        
        let ChatArr = DatabaseHandler.sharedInstance.FetchFromDatabaseWithRange(Entityname: Constant.sharedinstance.Chat_one_one, SortDescriptor: "timestamp", predicate: fetch_predicate, Limit: limit, StartRange: start) as! [NSManagedObject]
        
        if(ChatArr.count > 0)
        {
//            let descriptor: NSSortDescriptor = NSSortDescriptor(key: "date", ascending: false)
//            ChatArr = (ChatArr as NSArray).sortedArray(using: [descriptor]) as! [NSManagedObject]
            _ = ChatArr.map{
                let ResponseDict = $0
                var dic = [AnyHashable: Any]()
                var docPageCount:String = ""
                var docName:String = ""
                var docType:String = ""
                
                var ChekLocation : Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Upload_Details, attribute: "upload_data_id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id")))
                if(ChekLocation)
                {
                    let DocumentArr = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Upload_Details, attribute: "upload_data_id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id")), SortDescriptor: nil) as! [Upload_Details]
                    _ = DocumentArr.map {
                        let ObjRecord = $0
                        docPageCount = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.doc_pagecount)
                        docName =  Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.doc_name)
                        docType = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.doc_type)
                    }
                }
                
                var Latitude:String = ""
                var longitude:String = ""
                var title_place:String = ""
                var Stitle_place:String = ""
                var image_link:String = ""
                
                ChekLocation = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Location_details, attribute: "doc_id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id")))
                if(ChekLocation)
                {
                    let LocationArr = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Location_details, attribute: "doc_id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id")), SortDescriptor: nil) as! [NSManagedObject]
                    _ = LocationArr.map {
                        let ObjRecord = $0
                        
                        Latitude = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "lat"))
                        longitude =  Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "long"))
                        title_place = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "title"))
                        Stitle_place = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "stitle"))
                        image_link = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "image_link"))
                        
                    }
                }
                
                var title:String = ""
                var image_url:String = ""
                var desc:String = ""
                var url_str:String = ""
                
                ChekLocation = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Link_details, attribute: "doc_id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id")))
                
                if(ChekLocation)
                {
                    let LocationArr = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Link_details, attribute: "doc_id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id")), SortDescriptor: nil) as! [NSManagedObject]
                    _ = LocationArr.map {
                        let ObjRecord = $0
                        title = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "title"))
                        image_url =  Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "image_url"))
                        desc = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "desc"))
                        url_str = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "url_str"))
                        
                    }
                }
                
                var contact_id:String = ""
                var contact_profile:String = ""
                var contact_name:String = ""
                var contact_phone:String = ""
                var contact_details:String = ""
                
                ChekLocation = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Contact_details, attribute: "doc_id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id")))
                
                if(ChekLocation)
                {
                    let ContactArr = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Contact_details, attribute: "doc_id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id")), SortDescriptor: nil) as! [NSManagedObject]
                    _ = ContactArr.map {
                        let ObjRecord = $0
                        contact_id = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "contact_id"))
                        contact_profile =  Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "contact_profile"))
                        contact_name = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "contact_name"))
                        contact_phone = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "contact_phone"))
                        contact_details = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "contact_details"))
                    }
                }
                
                dic  = ["type": Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "type")),"convId":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "convId")),"doc_id":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id")),"filesize":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "filesize")),"from":Themes.sharedInstance.CheckNullvalue(Passed_value:ResponseDict.value(forKey: "from")
                    ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:ResponseDict.value(forKey: "to")
                    ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "isStar")),"message_status":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "message_status")),"id":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "id")),"name":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "name")),"payload":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "payload"))
                    ,"recordId":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "recordId")),"thumbnail":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "thumbnail")),"width":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "width")),"height":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "height")),"msgId":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "msgId")),"contactmsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "contactmsisdn"))
                    ,"user_common_id":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "user_common_id"))
                    ,"timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "timestamp")),"message_from":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "message_from")),"info_type":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "info_type")),"chat_type":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "chat_type")), "is_deleted" :  Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "is_deleted")), "docType":docType,"docName":docName,"docPageCount":docPageCount,"latitude":Latitude ,"longitude":longitude,"title_place":title_place,"Stitle_place":Stitle_place,"imagelink":image_link,"title":title ,"image_url":image_url,"desc":desc,"url_str":url_str,"contact_id":contact_id ,"contact_profile":contact_profile,"contact_phone":contact_phone,"contact_name":contact_name,"contact_details":contact_details, "reply_type" : Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "reply_type")), "while_blocked" : Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "while_blocked"))]
                
                self.dealTheFunctionData1(dic)
            }
        }
        
    }
    
    
    
    func callActionSheet() {
        self.pauseGif()
        guard !Themes.sharedInstance.checkBlock(id: opponent_id) else{
            Themes.sharedInstance.showBlockalert(id: opponent_id)
            return
        }
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let CameraAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Camera", comment: "Camera" ) , style: .default) { action -> Void in
            self.actionSheetIndex(0)
        }
        let PhotoAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Photo & Video Library", comment: "Photo & Video Library" ) , style: .default)
        { action -> Void in
            self.actionSheetIndex(1)
        }
        let shareDocAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Share Document", comment:"Share Document") , style: .default) { action -> Void in
            self.actionSheetIndex(2)
        }
        
        let shareLocAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Share Location", comment:"Share Location"), style: .default) { action -> Void in
            self.actionSheetIndex(3)
        }
        let shareConAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Share Contact", comment:"Share Contact"), style: .default) { action -> Void in
            self.actionSheetIndex(4)
        }
        
        let scanDocAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Scan Document", comment:"Scan Document") , style: .default) { action -> Void in
                         self.actionSheetIndex(5)
                     }
        
        let cancelAction: UIAlertAction = UIAlertAction(title:NSLocalizedString("Cancel", comment:"Cancel") , style: .cancel) { action -> Void in
        }
        CameraAction.setValue(#imageLiteral(resourceName: "cameraaction"), forKey: "image")
        PhotoAction.setValue(#imageLiteral(resourceName: "galleryaction"), forKey: "image")
        shareDocAction.setValue(#imageLiteral(resourceName: "documentaction"), forKey: "image")
        scanDocAction.setValue(#imageLiteral(resourceName: "documentaction"), forKey: "image")
        shareLocAction.setValue(#imageLiteral(resourceName: "locationaction"), forKey: "image")
        shareConAction.setValue(#imageLiteral(resourceName: "contactaction"), forKey: "image")
        
        CameraAction.setValue(0, forKey: "titleTextAlignment")
        PhotoAction.setValue(0, forKey: "titleTextAlignment")
        shareDocAction.setValue(0, forKey: "titleTextAlignment")
        shareLocAction.setValue(0, forKey: "titleTextAlignment")
        shareConAction.setValue(0, forKey: "titleTextAlignment")
        scanDocAction.setValue(0, forKey: "titleTextAlignment")
        
        actionSheetController.addAction(CameraAction)
        actionSheetController.addAction(PhotoAction)
        actionSheetController.addAction(shareDocAction)
        actionSheetController.addAction(shareLocAction)
        actionSheetController.addAction(shareConAction)
        actionSheetController.addAction(scanDocAction)
        actionSheetController.addAction(cancelAction)
        
        actionSheetController.view.tintColor = CustomColor.sharedInstance.themeColor
        self.presentView(actionSheetController, animated: true, completion: nil)
    }
    
    func imageWithImage(_ image:UIImage)->UIImage{
        
        UIGraphicsBeginImageContext(CGSize(width: 30, height: 30))
        image.draw(in: CGRect(x: 0,y: 0,width: 30,height: 30))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!.withRenderingMode(.alwaysOriginal)
    }
    
    private func actionSheetIndex(_ index: Int) {
        if(index == 0)
        {
            let cameraMediaType = AVMediaType.video
            let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: cameraMediaType)
            if cameraAuthorizationStatus == .authorized {
                
                let pickerController = DKImagePickerController()
                pickerController.maxSelectableCount = 10
                pickerController.assetType = .allPhotos
                pickerController.sourceType = .camera
                pickerController.didSelectAssets = { (assets: [DKAsset]) in
                    if(assets.count > 0)
                    {
                        self.selectedAssets = assets
                        Themes.sharedInstance.activityView(View: self.view)
                        if(self.Chat_type == "group")
                        {
                            AssetHandler.sharedInstance.isgroup = true
                        }
                        else
                        {
                            AssetHandler.sharedInstance.isgroup = false
                            
                        }
                        AssetHandler.sharedInstance.ProcessAsset(assets: [assets[0]],oppenentID: self.opponent_id,isFromStatus: false, completionHandler: {[weak self]
                            (AssetArr, error) -> ()? in
                            if((AssetArr?.count)! > 0)
                            {
                                DispatchQueue.main.async {
                                    Themes.sharedInstance.RemoveactivityView(View: (self?.view)!)
                                    
                                    let EditVC = self?.storyboard?.instantiateViewController(withIdentifier: "EditViewControllerID") as! EditViewController
                                    EditVC.AssetArr = AssetArr!
                                    EditVC.isVideoData = false
                                    EditVC.isfromStatus = false
                                    EditVC.Delegate = self
                                    EditVC.selectedAssets = (self?.selectedAssets)!
                                    EditVC.isgroup = AssetHandler.sharedInstance.isgroup
                                    EditVC.to_id = (self?.opponent_id)!
                                    self?.pushView(EditVC, animated: true)
                                    
                                }
                            }
                            return ()
                        })
                    }
                    
                }
                self.presentView(pickerController, animated: true)
            }else{
                switch cameraAuthorizationStatus {
                case .denied:
                    let message = "\(Themes.sharedInstance.GetAppname()) \("does not have access to your camera. to enable access, tap Settings and turn on Camera".localized())"
                    
                    let alert = UIAlertController.init(title: nil, message: message, preferredStyle: .alert)
                    let action = UIAlertAction.init(title: "Cancel".localized(), style: .cancel, handler: nil)
                    let action2 = UIAlertAction.init(title: "Settings".localized(), style: .default) { _ in
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    }
                    alert.addAction(action)
                    alert.addAction(action2)
                    self.present(alert, animated: true)
                    break
                case .notDetermined:
                    break
                default:
                    break
                }
            }
        }
        else if(index == 1)
        {
            
            let pickerController = DKImagePickerController()
            pickerController.singleSelect = true
            pickerController.assetType = .allAssets
            pickerController.sourceType = .photo
            pickerController.isFromChat = true
            pickerController.didSelectAssets = { (assets: [DKAsset]) in
                if(assets.count > 0)
                {
                    self.selectedAssets = assets
                    Themes.sharedInstance.activityView(View: self.view)
                    if(self.Chat_type == "group")
                    {
                        AssetHandler.sharedInstance.isgroup = true
                    }
                    else
                    {
                        AssetHandler.sharedInstance.isgroup = false
                        
                    }
                    AssetHandler.sharedInstance.ProcessAsset(assets: assets,oppenentID: self.opponent_id,isFromStatus: false, completionHandler: { [weak self] (AssetArr, error) -> ()? in
                        if((AssetArr?.count)! > 0)
                        {     DispatchQueue.main.async {
                            Themes.sharedInstance.RemoveactivityView(View: (self?.view)!)
                            let EditVC = self?.storyboard?.instantiateViewController(withIdentifier: "EditViewControllerID") as! EditViewController
                            EditVC.AssetArr = AssetArr!
                            EditVC.isfromStatus = false
                            EditVC.Delegate = self
                            EditVC.selectedAssets = (self?.selectedAssets)!
                            EditVC.isgroup = AssetHandler.sharedInstance.isgroup
                            EditVC.to_id = (self?.opponent_id)!
                            self?.pushView(EditVC, animated: true)
                            }
                        }
                        return ()
                    })
                }
            }
            pickerController.didClickGif = {
                let picker = SwiftyGiphyViewController()
                picker.delegate = self
                let navigation = UINavigationController(rootViewController: picker)
                self.presentView(navigation, animated: true)
                
            }
            self.presentView(pickerController, animated: true)
        }
        else if(index == 2)
        {
            self.PresentDocumentPicker()
        }
        else if(index == 3)
        {
            
            let mapVC = self.storyboard?.instantiateViewController(withIdentifier: "MapViewViewController") as! MapViewViewController
            mapVC.delegate = self
            self.pushView(mapVC,animated: true)
        }else if(index == 4){
            let CheckFav:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "user_id", FetchString: Themes.sharedInstance.Getuser_id())
            
            if(CheckFav)
            {
                
                let contactVC = self.storyboard?.instantiateViewController(withIdentifier: "ContactsViewController") as! ContactsViewController
                if let exampleType = ExampleType(rawValue: "comparison") {
                    contactVC.example = exampleByType(exampleType)
                }
                if(self.Chat_type == "group"){
                    contactVC.is_from_group = true
                }
                contactVC.oppponent_id = opponent_id
                contactVC.delegate = self
                
                self.pushView(contactVC, animated: true)
                
            }
                
            else
                
            {
                Themes.sharedInstance.jssAlertView(viewController: self, title: Themes.sharedInstance.GetAppname(), text: "No Contact kindly invite friends", buttonTxt: "Ok", color: CustomColor.sharedInstance.alertColor)
            }
        } else if(index == 5){
            if #available(iOS 13.0, *) {
              
                var scannerViewController = VNDocumentCameraViewController()
                scannerViewController.delegate = self
                scannerViewControllerTemp = scannerViewController
               (scannerViewControllerTemp as! VNDocumentCameraViewController).delegate = self
                
                present(scannerViewController, animated: true)
                
            } else {
                // Fallback on earlier versions
                let alert = UIAlertController(title: "Warning", message:"scan document is only supported for ios 13 and more", preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
    }
    @objc func buttonAction(sender: UIButton!) {
        let btnsendtag: UIButton = sender
        if btnsendtag.tag == 1 {
            scannerViewControllerTemp.dismiss(animated: true)
        }
    }
    func updateContentSizealongWithTextview()
    {
        ReplyView.frame = CGRect(x: 0, y: IFView.frame.origin.y - ReplyView.frame.size.height , width: ReplyView.frame.size.width, height: ReplyView.frame.size.height)
        tagView.frame = CGRect(x: 0, y: IFView.frame.origin.y - tagView.frame.size.height, width: tagView.frame.size.width, height: tagView.frame.size.height)
        link_view.frame = CGRect(x: 0, y: IFView.frame.origin.y - 79 , width: link_view.frame.size.width, height: 79)
    }
    
    func uuInputFunctionView(_ funcView: UUInputFunctionView!, textViewDidchange Text: String!) {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            self.updateContentSizealongWithTextview()
        }
        
        if(Text.slice(from: "@@***", to: "@@***")?.removingWhitespaces() != nil && Text.slice(from: "@@***", to: "@@***")?.removingWhitespaces() != "")
        {
            let arr = Themes.sharedInstance.getID_Range_Payload_Name(message: self.IFView.textView.text!)
            TagIdArr = arr[0] as! [String]
            TagPersonRange = arr[1] as! [NSRange]
            _ = TagPersonRange.map{
                let index = TagPersonRange.index(of: $0)!
                var range = $0
                range.location = range.location - 1
                range.length = range.length + 1
                TagPersonRange[index] = range
            }
            TagNameArr = arr[3] as! [String]
            self.IFView.textView.text = Themes.sharedInstance.CheckNullvalue(Passed_value: arr[2])
            
            let attributed = NSMutableAttributedString(string: self.IFView.textView.text!)
            
            attributed.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15.0)], range: NSMakeRange(0, self.IFView.textView.text.length))
            
            TagPersonRange.forEach { range in
                attributed.addAttributes([NSAttributedString.Key.foregroundColor : CustomColor.sharedInstance.themeColor, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15.0)], range: NSMakeRange(range.location + 1, range.length - 1))
                
                attributed.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.lightGray, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15.0)], range: NSMakeRange(range.location, 1))
            }
            if(TagPersonRange.count > 0)
            {
                self.IFView.textView.internalTextView.attributedText = attributed
            }
            else
            {
                self.IFView.textView.internalTextView.textColor = UIColor.black
            }
            
        }
        
        if(conv_id != "")
        {
            let to = Themes.sharedInstance.CheckNullvalue(Passed_value: opponent_id)
            
            SocketIOManager.sharedInstance.emitTypingStatus(from: Themes.sharedInstance.Getuser_id(), to: to, convId: conv_id, type: Chat_type)
        }
        if(self.Chat_type == "group")
        {
            if(!tagView.isHidden)
            {
                let text = Text.components(separatedBy: "@").last
                
                
                
                let groupUsers = NSMutableArray(array: self.groupUsers)
                
                _ = groupUsers.map {
                    let index = groupUsers.index(of: $0)
                    var PersonDict = $0 as! [String : Any]
                    let checkId = Themes.sharedInstance.CheckNullvalue(Passed_value: PersonDict["id"])
                    var realName = ""
                    
                    let id = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Favourite_Contact, attrib_name: "id", fetchString: checkId, returnStr: "id")
                    
                    var name = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Favourite_Contact, attrib_name: "id", fetchString: checkId, returnStr: "name")
                    if(name == "")
                    {
                        name = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Favourite_Contact, attrib_name: "id", fetchString: checkId, returnStr: "msisdn")
                    }
                    
                    if(id == "")
                    {
                        
                        name = Themes.sharedInstance.CheckNullvalue(Passed_value: PersonDict["msisdn"])
                        realName = Themes.sharedInstance.CheckNullvalue(Passed_value: PersonDict["Name"])
                    }
                    PersonDict["searchName"] = name
                    PersonDict["searchRealName"] = realName
                    groupUsers.replaceObject(at: index, with: PersonDict)
                }
                
                let p1 = NSPredicate(format: "searchName contains[c] %@", text!)
                let p2 = NSPredicate(format: "id != %@", Themes.sharedInstance.Getuser_id())
                
                let p3 = NSPredicate(format: "searchRealName contains[c] %@", text!)
                let p4 = NSPredicate(format: "id != %@", Themes.sharedInstance.Getuser_id())
                
                let compoundpredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2])
                let compoundpredicate1 = NSCompoundPredicate(andPredicateWithSubpredicates: [p3, p4])
                
                let arr = groupUsers.filtered(using: NSCompoundPredicate(orPredicateWithSubpredicates: [compoundpredicate, compoundpredicate1]))
                
                
                var FilteredArr = [NSDictionary]()
                if(arr.count > 0)
                {
                    FilteredArr.append(contentsOf: arr as! [NSDictionary])
                }
                if(text == "" && Text.contains("@"))
                {
                    let Arr = groupUsers.filtered(using: NSCompoundPredicate(andPredicateWithSubpredicates: [p2]))
                    FilteredArr.append(contentsOf: Arr as! [NSDictionary])
                }
                if(FilteredArr.count > 0)
                {
                    let filter = FilteredArr.filter({Themes.sharedInstance.CheckNullvalue(Passed_value: $0.value(forKey: "id")) == Themes.sharedInstance.Getuser_id()}).first
                    
                    let height : CGFloat = (filter != nil) ? (50 * CGFloat(FilteredArr.count - 1)) : (50 * CGFloat(FilteredArr.count))
                    
                    if(height > 200)
                    {
                        tagView.frame = CGRect(x: 0.0, y: funcView.frame.origin.y - 200, width: self.view.frame.size.width, height: 200)
                    }
                    else
                    {
                        tagView.frame = CGRect(x: 0.0, y: funcView.frame.origin.y - height, width: self.view.frame.size.width, height: height)
                    }
                    tagView.searchString = text!
                    tagView.datasource = FilteredArr as NSArray
                    tagView.isHidden = false
                }
                else
                {
                    tagView.isHidden = true
                }
            }
        }
        //let text = Text
        let types: NSTextCheckingResult.CheckingType = .link
        var URLStrings = [NSURL]()
        let detector = try? NSDataDetector(types: types.rawValue)
        let matches = detector?.matches(in: Text!, options: .reportCompletion, range: NSMakeRange(0, (Text?.count)!))
        if matches?.count == 0 {
            link_view.isHidden = true
        }
        
        var i = 0
        for match in matches! {
            if i == 0 {
                
                URLStrings.append(match.url! as NSURL)
                var urlstr = match.url!.absoluteString
                
                if !urlstr.isEmpty  {
                    
                    let linkStr = urlstr
                    if(urlstr.lowercased().hasPrefix("www") && urlstr.lowercased().hasPrefix("http")){
                        urlstr="https:\(urlstr)"
                    }else if(!urlstr.lowercased().hasPrefix("www") && !urlstr.lowercased().hasPrefix("http")){
                        urlstr="https:www.\(urlstr)"
                    }
                    
                    linkUrl="\(urlstr)/favicon.ico"
                    if(Text.lowercased().hasPrefix("https://maps.google.com")){
                        isFromUrl = false
                        link_view.isHidden = true
                    }else{
                        if(Themes.sharedInstance.isValidUrl (urlString: urlstr.lowercased()))
                        {
                            
                            if(self.link_str.lowercased() != urlstr.lowercased())
                            {
                                self.Title_str = ""
                                self.ImageURl = ""
                                self.Desc = ""
                                self.Url_str = ""
                                self.link_view.title_Str = ""
                                self.link_view.image_Url = ""
                                self.link_view.desc_Str = ""
                                self.link_str = ""
                                self.link_view.loadURL(urlstr, completion: { (error) in
                                    
                                    if(error == nil && self.link_view.title_Str != "" && self.IFView.textView.text != "")
                                    {
                                        self.link_view.isHidden = false
                                        self.Title_str = String(describing:  self.link_view.title_Str)
                                        self.ImageURl = self.link_view.image_Url as String
                                        self.Desc = String(describing: self.link_view.desc_Str)
                                        self.Url_str =  urlstr
                                        self.link_str = linkStr
                                        self.isFromUrl = true
                                    }
                                    else
                                    {
                                        self.link_view.isHidden = true
                                        self.isFromUrl = false
                                    }
                                })
                            }
                            else
                            {
                                self.isFromUrl = true
                                
                            }
                            
                        }
                        else
                        {
                            link_view.isHidden = true
                            isFromUrl = false
                            
                            
                        }
                        
                        
                        
                    }
                    
                    
                }
                    
                else
                {
                    
                    link_view.isHidden = true
                    isFromUrl = false
                    
                }
                i = i+1;
                
            }
        }
    }
    
    func uuInputFunctionView(_ funcView: UUInputFunctionView!, shouldChangeTextIn range: NSRange, replacementText text: String!) {
        if(self.Chat_type == "group")
        {
            let Text = (funcView.textView.text as NSString).replacingCharacters(in: range, with: text)
            if(text! == "@" || Text == "@" || (Text.contains("@") && Text.components(separatedBy: "@").last == ""))
            {
                tagView.isHidden = false
            }
            if(Text != "")
            {
                TagPersonRange.forEach { ranges in
                    if(ranges.contains(range.location))
                    {
                        let Index = TagPersonRange.index(of: ranges)!
                        TagPersonRange.remove(at: Index)
                        TagIdArr.remove(at: Index)
                        TagNameArr.remove(at: Index)
                        var text = self.IFView.textView.text!
                        let subText = self.IFView.textView.text.substring(with: ranges)
                        if let range = text.range(of: subText, options: .backwards, range: nil, locale: nil) {
                            text = text.replacingCharacters(in: range, with: "")
                        }
                        self.IFView.textView.text = text
                        
                        for i in Index..<TagPersonRange.count {
                            let range = TagPersonRange[i]
                            let ranges1 = NSMakeRange(range.location - ranges.length, range.length)
                            TagPersonRange.remove(at: i)
                            TagPersonRange.insert(ranges1, at: i)
                            
                        }
                    }
                }
                
                let attributed = NSMutableAttributedString(string: self.IFView.textView.text!)
                
                attributed.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15.0)], range: NSMakeRange(0, self.IFView.textView.text.length))
                
                TagPersonRange.forEach { range in
                    attributed.addAttributes([NSAttributedString.Key.foregroundColor : CustomColor.sharedInstance.themeColor, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15.0)], range: NSMakeRange(range.location + 1, range.length-1))
                    
                    attributed.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.lightGray, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15.0)], range: NSMakeRange(range.location, 1))
                    
                }
                if(TagPersonRange.count > 0)
                {
                    self.IFView.textView.internalTextView.attributedText = attributed
                }
                else
                {
                    self.IFView.textView.internalTextView.textColor = UIColor.black
                }
            }
            else
            {
                TagPersonRange.removeAll()
                TagIdArr.removeAll()
                TagNameArr.removeAll()
                
            }
        }
    }
    
    
    func EdittedImage(AssetArr: NSMutableArray, Status: String) {
        if(Chat_type == "secret")
        {
            let user_common_id = opponent_id + "-" + Themes.sharedInstance.Getuser_id()
            let checkBool:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Secret_Chat, attribute: "user_common_id", FetchString: user_common_id)
            if(!checkBool)
            {
                self.time(time:"1 hour")
            }
        }
        if(AssetArr.count > 0)
        {
            var secret_msg_id:String = ""
            _ = AssetArr.map {
                let ObjMultiMedia:MultimediaRecord = $0 as! MultimediaRecord
                if(!ObjMultiMedia.isVideo)
                {
                    let from = Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
                    let to = Themes.sharedInstance.CheckNullvalue(Passed_value: opponent_id)
                    var user_common_id:String = ""
                    if(Chat_type == "secret"){
                        
                        user_common_id = Themes.sharedInstance.CheckNullvalue(Passed_value: to + "-" + from)
                        
                        var checksecretmessagecount:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Secret_Chat, attribute: "user_common_id", FetchString: user_common_id, SortDescriptor: "timestamp") as! NSArray
                        checksecretmessagecount = checksecretmessagecount.reversed() as NSArray
                        
                        if(checksecretmessagecount.count > 0)
                        {
                            
                            secret_msg_id = Themes.sharedInstance.CheckNullvalue(Passed_value: (checksecretmessagecount[0] as! NSManagedObject).value(forKey: "doc_id"))
                        }
                    }else{
                        user_common_id = Themes.sharedInstance.CheckNullvalue(Passed_value: from + "-" + to)
                    }
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
                    var toDocId:String="\(from)-\(to)-\(timestamp)"
                    var mesageID:String =  timestamp
                    if(Chat_type == "group")
                    {
                        toDocId = "\(from)-\(to)-g-\(ObjMultiMedia.timestamp)"
                        mesageID =  ObjMultiMedia.timestamp
                    }
                    let dic:[AnyHashable: Any] = ["type": "1","convId":"","doc_id":Themes.sharedInstance.CheckNullvalue(Passed_value:toDocId
                        ),"filesize":"","from":Themes.sharedInstance.CheckNullvalue(Passed_value:from
                        ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:to
                        ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
                        ),"message_status":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
                        ),"id":mesageID,"name":Themes.sharedInstance.CheckNullvalue(Passed_value:Name
                        ),"payload":payload,"recordId":"","timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
                        ),"thumbnail":ObjMultiMedia.PathId,"width":"0.0","height":"0.0","msgId":Themes.sharedInstance.CheckNullvalue(Passed_value:mesageID
                        ),"contactmsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value:Phonenumber
                        ),"user_common_id":user_common_id,"message_from":"1","chat_type":Chat_type,"info_type":"0","created_by":from,"is_reply":"0","secret_msg_id":secret_msg_id,"secret_timestamp":"", "date" : Themes.sharedInstance.getTimeStamp(), "while_blocked" : Themes.sharedInstance.isImBlocked(to) ? "1" : "0"]
                    
                    DatabaseHandler.sharedInstance.InserttoDatabase(Dict: dic as NSDictionary,Entityname: Constant.sharedinstance.Chat_one_one)

                    if(Chat_type == "secret"){
                        let chatarray:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: to + "-" + from)
                        if(!chatarray)
                        {
                            let User_dict:[AnyHashable: Any] = ["user_common_id": to + "-" + from,"user_to_dp":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_type":Chat_type,"is_archived":"0","conv_id":"","timestamp":timestamp,"opponent_id":to,"is_read":"0","chat_count":"0"]
                            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: User_dict as NSDictionary,Entityname: Constant.sharedinstance.Chat_intiated_details)
                            
                        }
                        else
                        {
                            let User_dict:[AnyHashable: Any]=["timestamp":timestamp,"is_archived":"0","is_read":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_count":"0"]
                            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: to + "-" + from , attribute: "user_common_id", UpdationElements: User_dict as NSDictionary?)
                        }
                    }else{
                        let chatarray:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: from + "-" + to)
                        if(!chatarray)
                        {
                            let User_dict:[AnyHashable: Any] = ["user_common_id": from + "-" + to,"user_to_dp":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_type":Chat_type,"is_archived":"0","conv_id":"","timestamp":timestamp,"opponent_id":to,"is_read":"0","chat_count":"0"]
                            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: User_dict as NSDictionary,Entityname: Constant.sharedinstance.Chat_intiated_details)
                            
                        }
                        else
                        {
                            let User_dict:[AnyHashable: Any]=["timestamp":timestamp,"is_archived":"0","is_read":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_count":"0"]
                            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: from + "-" + to , attribute: "user_common_id", UpdationElements: User_dict as NSDictionary?)
                        }
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                        self.dealTheFunctionData(dic, fromOrdering: false)
                        
                    }
                    
                    
                }
                    
                else
                {
                    
                    let from = Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
                    let to = Themes.sharedInstance.CheckNullvalue(Passed_value: opponent_id)
                    var user_common_id:String = ""
                    if(Chat_type == "secret"){
                        user_common_id = Themes.sharedInstance.CheckNullvalue(Passed_value: to + "-" + from)
                    }else{
                        user_common_id = Themes.sharedInstance.CheckNullvalue(Passed_value: from + "-" + to)
                    }
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
                    var toDocId:String="\(from)-\(to)-\(timestamp)"
                    if(Chat_type == "group")
                    {
                        toDocId = "\(from)-\(to)-g-\(ObjMultiMedia.timestamp)"
                    }
                    let dic:[AnyHashable: Any] = ["type": "2","convId":"","doc_id":Themes.sharedInstance.CheckNullvalue(Passed_value:toDocId
                        ),"filesize":"","from":Themes.sharedInstance.CheckNullvalue(Passed_value:from
                        ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:to
                        ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
                        ),"message_status":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
                        ),"id":ObjMultiMedia.timestamp,"name":Themes.sharedInstance.CheckNullvalue(Passed_value:Name
                        ),"payload":payload,"recordId":"","timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
                        ),"thumbnail":ObjMultiMedia.PathId,"width":"0.0","height":"0.0","msgId":Themes.sharedInstance.CheckNullvalue(Passed_value:ObjMultiMedia.timestamp
                        ),"contactmsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value:Phonenumber
                        ),"user_common_id":user_common_id,"message_from":"1","chat_type":Chat_type,"info_type":"0","created_by":from,"is_reply":"0","secret_msg_id":secret_msg_id,"secret_timestamp":"", "date" : Themes.sharedInstance.getTimeStamp(), "while_blocked" : Themes.sharedInstance.isImBlocked(to) ? "1" : "0"]
                    
                    DatabaseHandler.sharedInstance.InserttoDatabase(Dict: dic as NSDictionary,Entityname: Constant.sharedinstance.Chat_one_one)

                    if(Chat_type == "secret"){
                        let chatarray:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: to + "-" + from)
                        if(!chatarray)
                        {
                            let User_dict:[AnyHashable: Any] = ["user_common_id": to + "-" + from,"user_to_dp":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_type":Chat_type,"is_archived":"0","conv_id":"","timestamp":timestamp,"opponent_id":to,"is_read":"0","chat_count":"0"]
                            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: User_dict as NSDictionary,Entityname: Constant.sharedinstance.Chat_intiated_details)
                            
                        }
                        else
                        {
                            let User_dict:[AnyHashable: Any]=["timestamp":timestamp,"is_archived":"0","is_read":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_count":"0"]
                            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: to + "-" + from , attribute: "user_common_id", UpdationElements: User_dict as NSDictionary?)
                        }
                    }else{
                        let chatarray:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: from + "-" + to)
                        if(!chatarray)
                        {
                            let User_dict:[AnyHashable: Any] = ["user_common_id": from + "-" + to,"user_to_dp":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_type":Chat_type,"is_archived":"0","conv_id":"","timestamp":timestamp,"opponent_id":to,"is_read":"0","chat_count":"0"]
                            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: User_dict as NSDictionary,Entityname: Constant.sharedinstance.Chat_intiated_details)
                            
                        }
                        else
                        {
                            let User_dict:[AnyHashable: Any]=["timestamp":timestamp,"is_archived":"0","is_read":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_count":"0"]
                            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: from + "-" + to , attribute: "user_common_id", UpdationElements: User_dict as NSDictionary?)
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                        self.dealTheFunctionData(dic, fromOrdering: false)
                        
                    }
                    
                    
                }
                
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                UploadHandler.Sharedinstance.handleUpload()
            }
        }
        
    }
    
    func PresentDocumentPicker() {
        let importMenu = UIDocumentPickerViewController(documentTypes: ["public.text", "public.data","public.pdf", "public.doc"], in: .import)
        importMenu.delegate = self
        self.presentView(importMenu, animated: true)
    }
    
    func SaveDoc(objRecord:DocumentRecord, completion: @escaping (NSDictionary) -> ())
    {
        
        let from = Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
        let to = Themes.sharedInstance.CheckNullvalue(Passed_value: opponent_id)
        var timestamp:String =  String(Date().ticks)
        var servertimeStr:String = Themes.sharedInstance.getServerTime()
        var user_common_id:String = ""
        if(Chat_type == "secret"){
            user_common_id = Themes.sharedInstance.CheckNullvalue(Passed_value: to + "-" + from)
        }else{
            user_common_id = Themes.sharedInstance.CheckNullvalue(Passed_value: from + "-" + to)
        }
        if(servertimeStr == "")
        {
            servertimeStr = "0"
        }
        
        let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
        timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
        let AssetName:String = "\(user_common_id)-\(timestamp).\(objRecord.path_extension)"
        var CompressedImage:String = String()
        pathname = "\(from)-\(to)-\(timestamp).\(objRecord.path_extension.lowercased())"
        document_msg_id = timestamp
        self.document_doc_id = "\(from)-\(to)-\(timestamp)"
        
        if(Chat_type == "group")
        {
            pathname = "\(from)-\(to)-g-\(timestamp).\(objRecord.path_extension.lowercased())"
            self.document_doc_id = "\(from)-\(to)-g-\(timestamp)"
            
        }
        if(objRecord.docImage != nil)
        {
            let data:Data = objRecord.docImage.jpegData(compressionQuality: 0.08)!
//                UIImageJPEGRepresentation(objRecord.docImage, 0.08)!
            CompressedImage = Themes.sharedInstance.convertImageToBase64(imageData:data)
        }
        else
            
        {
            CompressedImage = ""
        }
        
        returnCompressedData(objRecord) { Docdata in
            let Path:String =  Filemanager.sharedinstance.SaveImageFile(imagePath: "\(Constant.sharedinstance.docpath)/\(AssetName)",imagedata: Docdata)
            var splitcount:Int = Docdata.count / Constant.sharedinstance.SendbyteCount
            if(splitcount < 1)
            {
                splitcount = 1
            }
            let uploadDataCount:String = UploadHandler.Sharedinstance.getArrayOfBytesFromImage(Docdata, splitCount: splitcount)
            let imagecount:Int = Docdata.count
            let Dict:[String:Any] = ["failure_status":"0","total_byte_count":"\(imagecount)","upload_byte_count":"0","upload_count":"1","upload_data_id":self.pathname,"upload_Path":Path,"upload_status":"0","user_common_id":user_common_id,"serverpath":"","user_id":Themes.sharedInstance.Getuser_id(),"data_count":uploadDataCount,"compressed_data":"\(CompressedImage)","to_id":to,"message_status":"0","timestamp":timestamp,"total_data_count":"\(splitcount)","width":"0.0","height":"0.0","upload_type":"6","download_status":"2","doc_name":objRecord.docName,"doc_type":objRecord.docType,"doc_pagecount":objRecord.docPageCount,"is_uploaded":"1", "upload_paused":"0"]
            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict as NSDictionary, Entityname: Constant.sharedinstance.Upload_Details);
            let param:NSDictionary = ["id":AssetName,"pathname":Path]
            completion(param)
        }
    }
    
    
    func returnCompressedData(_ objRecord : DocumentRecord, completion: @escaping (Data) -> ())
    {
        do
        {
            let Docdata = try Data(contentsOf: objRecord.docPath)
            
            //            if(objRecord.docPath.pathExtension.uppercased() == "PDF")
            //            {
            //                Themes.sharedInstance.showprogressAlert(controller: self)
            //                self.convertPDFPageToImage(objRecord, progress: { progress in
            //                    Themes.sharedInstance.setprogressinAlert(controller: self, progress: progress)
            //                }) { images, rect in
            //                    self.createPDF(images: images, size: rect.size) { data in
            //                        print("Compressed..." + ByteCountFormatter.string(fromByteCount: Int64(data.length) , countStyle: .file) + " from " + ByteCountFormatter.string(fromByteCount: Int64(Docdata.count) , countStyle: .file))
            //                        completion(data as Data)
            //                    }
            //                }
            //            }
            //            else
            //            {
            completion(Docdata)
            //            }
        }
        catch {
            print(error.localizedDescription)
        }
        
    }
    
    func convertPDFPageToImage(_ objRecord : DocumentRecord, progress: @escaping (Float) -> (), completion: @escaping ([UIImage], CGRect)->()) {
        DispatchQueue.global(qos: .background).async {
            var returnImgArr = [UIImage]()
            do {
                
                let pdfdata = try Data(contentsOf: objRecord.docPath)
                
                let pdfData = pdfdata as CFData
                let provider:CGDataProvider = CGDataProvider(data: pdfData)!
                let pdfDoc:CGPDFDocument = CGPDFDocument(provider)!
                
                for i in 1...pdfDoc.numberOfPages {
                    let pdfPage:CGPDFPage = pdfDoc.page(at: i)!
                    var pageRect:CGRect = pdfPage.getBoxRect(.mediaBox)
                    pageRect.size = CGSize(width:pageRect.size.width, height:pageRect.size.height)
                    
                    UIGraphicsBeginImageContext(pageRect.size)
                    let context:CGContext = UIGraphicsGetCurrentContext()!
                    context.saveGState()
                    context.translateBy(x: 0.0, y: pageRect.size.height)
                    context.scaleBy(x: 1.0, y: -1.0)
                    context.concatenate(pdfPage.getDrawingTransform(.mediaBox, rect: pageRect, rotate: 0, preserveAspectRatio: true))
                    context.drawPDFPage(pdfPage)
                    context.restoreGState()
                    let pdfImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
                    UIGraphicsEndImageContext()
                    
                    DispatchQueue.main.async {
                        let imageData = pdfImage.jpegData(compressionQuality: 0.3)
//                            UIImageJPEGRepresentation(pdfImage, 0.3)
                        let newImage = UIImage(data: imageData!)!
                        returnImgArr.append(newImage)
                        DispatchQueue.main.async {
                            progress(Float(Float(returnImgArr.count)/Float(pdfDoc.numberOfPages)))
                        }
                        if(pdfDoc.numberOfPages == returnImgArr.count)
                        {
                            completion(returnImgArr, pageRect)
                        }
                    }
                    
                }
            }
            catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func createPDF(images:[UIImage], size: CGSize, completion: @escaping (NSMutableData) -> ()) {
        
        DispatchQueue.global(qos: .background).async {
            
            let pdfData = NSMutableData()
            
            UIGraphicsBeginPDFContextToData(pdfData, CGRect(x: 0, y: 0, width: size.width, height: size.height), nil)
            
            let context = UIGraphicsGetCurrentContext()
            
            for image in images {
                UIGraphicsBeginPDFPage()
                UIGraphicsPushContext(context!)
                image.draw(at: CGPoint.zero)
                UIGraphicsPopContext()
            }
            UIGraphicsEndPDFContext();
            completion(pdfData)
        }
    }
    
    func SetMenuView()
    {
        //        let customMenuItem = UIMenuItem(title: "Delete", action:
        //            #selector(self.DeleteLine))
        //        UIMenuController.shared.menuItems = [customMenuItem]
        //        UIMenuController.shared.update()
    }
    func DeleteLine()
    {
        
    }
    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }
    

    func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?)
    {
        
        if action == #selector(CustomTableViewCell.CopyMessageActionTapped(sender:)) {
            let pasteboard = UIPasteboard.general
            pasteboard.string = "this is a test message for sample."
        }
        
    }
    
    func DidClickMenuAction(actioname: MenuAcion, index: IndexPath) {
        let chat_Obj:UUMessageFrame = self.chatModel.dataSource[index.row] as! UUMessageFrame
        self.view.endEditing(true)
        
        if(actioname == .delete)
        {
            isForwardAction = false
            isBeginEditing = true
            left_item.image = #imageLiteral(resourceName: "trash")
            right_item.tintColor = CustomColor.sharedInstance.themeColor
            right_item.title = "Cancel"
            Firstindexpath = index
            self.perform(#selector(self.SelectIndexpath), with:self , afterDelay: 0.3)
            self.ShowToolBar()
        }
        else if(actioname == .Info)
        {
            let messageinfoVC = storyboard?.instantiateViewController(withIdentifier:"MessageInfoViewControllerID" ) as! MessageInfoViewController
            messageinfoVC.ChatType = Chat_type
            messageinfoVC.messageinfo = chat_Obj
            self.pushView(messageinfoVC, animated: true)
            
        }
        else if(actioname == .Reply)
        {
            self.ShowReplyView(chat_Obj)
        }
        else  if(actioname == .Forward)
        {
            
            isForwardAction = true
            isBeginEditing = true
            left_item.image = #imageLiteral(resourceName: "forward")
            right_item.tintColor = CustomColor.sharedInstance.themeColor
            right_item.title = "Cancel"
            Firstindexpath = index
            self.perform(#selector(self.SelectIndexpath), with:self , afterDelay: 0.3)
            self.ShowToolBar()
            
        }
        else  if(actioname == .star)
        {
            if(chat_Obj.message.isStar == "1")
            {
                chat_Obj.message.isStar = "0"
                self.StarMessage(status: "0", DocId: chat_Obj.message.doc_id,convId:chat_Obj.message.conv_id,recordId:chat_Obj.message.recordId )
                
            }
            else
            {
                chat_Obj.message.isStar = "1"
                
                self.StarMessage(status: "1", DocId: chat_Obj.message.doc_id,convId:chat_Obj.message.conv_id,recordId:chat_Obj.message.recordId)
            }
            DispatchQueue.main.async{
                self.chatTableView.reloadRows(at: [index], with: .none)
            }
            
        }
        else if(actioname == .copy)
        {
            //copy for map
            if(chat_Obj.message.message_type == "14"){
                UIPasteboard.general.string = "https://maps.google.com/?g=\(chat_Obj.message.latitude!),\(chat_Obj.message.longitude!)"
            }else{
                UIPasteboard.general.string = chat_Obj.message.payload
            }
        }
    }
    
    func StarMessage(status:String,DocId:String,convId:String,recordId:String)
    {
        
        let checkmsg:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "doc_id", FetchString: DocId)
        if(checkmsg)
        {
            let param:NSDictionary = ["isStar":status]
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_one_one, FetchString: DocId, attribute: "doc_id", UpdationElements: param)
            let Emitparam:NSDictionary = ["from":Themes.sharedInstance.Getuser_id(),"status":status,"type":Chat_type,"doc_id":DocId,"convId":convId,"recordId":recordId]
            SocketIOManager.sharedInstance.EmitStarMessagedetails(Dict: Emitparam)
        }
        
    }
    @objc func SelectIndexpath()
    {
        chatTableView.setEditing(true, animated: false)
        chatTableView.selectRow(at: Firstindexpath, animated: false, scrollPosition: .none)
        tableView(chatTableView, didSelectRowAt: Firstindexpath)
        left_item.isEnabled = true
    }
    
    func ShowToolBar()
    {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
            self.selectiontoolbar.frame = CGRect(x: 0, y: self.IFView.frame.origin.y + 2, width: self.selectiontoolbar.frame.size.width, height: self.selectiontoolbar.frame.size.height )
            self.view.bringSubviewToFront(self.selectiontoolbar)
        }, completion: nil)
    }
    
    func HideToolBar()
    {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
            self.selectiontoolbar.frame = CGRect(x: 0, y: self.view.frame.size.height, width: self.selectiontoolbar.frame.size.width, height: self.selectiontoolbar.frame.size.height )
        }, completion:{ (istrue) in
            self.chatTableView.setEditing(false, animated: true)
            self.isForwardAction = false
            self.isBeginEditing = false
            
        } )
    }
    
    func update_memberView(_ isYou : Bool) {
        UIView.animate(withDuration: 0.0, delay: 0.0, options: .curveEaseIn, animations: {
            if(isYou) {
                self.not_member_view_bottom.frame = CGRect(x: 0, y: self.view.frame.size.height, width: self.not_member_view_bottom.frame.size.width, height: self.not_member_view_bottom.frame.size.height )
            }
            else
            {
                self.not_member_view_bottom.frame = CGRect(x: 0, y: self.IFView.frame.origin.y, width: self.not_member_view_bottom.frame.size.width, height: self.not_member_view_bottom.frame.size.height )
                self.view.bringSubviewToFront(self.not_member_view_bottom)
                self.is_you_removed = true
            }
        }, completion: { (istrue) in
            if(isYou) {
                self.isBeginEditing = false
                self.IFView.isHidden = false
                self.selectiontoolbar.isHidden = false
            }
        })
    }
    
    func buildThumbnailImage(document:CGPDFDocument) -> UIImage? {
        guard let page = document.page(at: 1) else { return nil }
        let pageRect = page.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        let img:UIImage? = renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(pageRect)
            ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height);
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0);
            ctx.cgContext.drawPDFPage(page);
        }
        if(img == nil)
        {
            return nil
        }
        return img
    }
    
    
    func isLocation(location:Bool)
    {
        locationR = location
        
    }
    func coordinate(latitude:CLLocationDegrees,longitude:CLLocationDegrees,title:String,display:String,subTitle:String)
    {
        if(Chat_type == "secret")
        {
            let user_common_id = opponent_id + "-" + Themes.sharedInstance.Getuser_id()
            let checkBool:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Secret_Chat, attribute: "user_common_id", FetchString: user_common_id)
            if(!checkBool)
            {
                self.time(time:"1 hour")
            }
        }
        
        latitudeR = latitude
        longitudeR = longitude
        address = title
        var secret_msg_id:String = ""
        
        let from = Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
        let to = Themes.sharedInstance.CheckNullvalue(Passed_value: opponent_id)
        var user_common_id:String = ""
        if(Chat_type == "secret"){
            user_common_id = Themes.sharedInstance.CheckNullvalue(Passed_value: to + "-" + from)
            var checksecretmessagecount:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Secret_Chat, attribute: "user_common_id", FetchString: user_common_id, SortDescriptor: "timestamp") as! NSArray
            checksecretmessagecount = checksecretmessagecount.reversed() as NSArray
            
            if(checksecretmessagecount.count > 0)
            {
                
                secret_msg_id = Themes.sharedInstance.CheckNullvalue(Passed_value: (checksecretmessagecount[0] as! NSManagedObject).value(forKey: "doc_id"))
            }
        }else{
            user_common_id = Themes.sharedInstance.CheckNullvalue(Passed_value: from + "-" + to)
        }
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
        
        var toDocId:String="\(from)-\(to)-\(timestamp)"
        if(Chat_type == "group")
        {
            toDocId = "\(from)-\(to)-g-\(timestamp)"
        }
        
        let imagelink:String = "https://maps.googleapis.com/maps/api/staticmap?center=\(latitudeR!),\(longitudeR!)&zoom=15&size=300x300&maptype=roadmap&key=\(Constant.sharedinstance.GoogleMapKey)&markers=color:red%7Clabel:N%7C\(latitudeR!),\(longitudeR!)"
        
        let DBDict:NSDictionary = ["type": "14","convId":"","doc_id":Themes.sharedInstance.CheckNullvalue(Passed_value:toDocId
            ),"filesize":"","from":Themes.sharedInstance.CheckNullvalue(Passed_value:from
            ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:to
            ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
            ),"message_status":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
            ),"id":timestamp,"name":Themes.sharedInstance.CheckNullvalue(Passed_value:Name
            ),"payload":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(address)"
            ),"recordId":"","timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
            ),"thumbnail":"","width":"0.0","height":"0.0","msgId":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
            ),"contactmsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value:Phonenumber
            ),"user_common_id":user_common_id,"message_from":"1","chat_type":Chat_type,"info_type":"0","created_by":from,"imagelink":imagelink,"latitude":"\(latitudeR!)","longitude":"\(longitudeR!)","thumbnail_data":"","title_place":Themes.sharedInstance.CheckNullvalue(Passed_value: display),"Stitle_place":Themes.sharedInstance.CheckNullvalue(Passed_value:subTitle),"secret_msg_id":secret_msg_id,"secret_timestamp":"", "date" : Themes.sharedInstance.getTimeStamp(), "while_blocked" : Themes.sharedInstance.isImBlocked(to) ? "1" : "0"]
        DatabaseHandler.sharedInstance.InserttoDatabase(Dict: DBDict as NSDictionary,Entityname: Constant.sharedinstance.Chat_one_one)

        if(Chat_type == "secret"){
            let chatarray:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: to + "-" + from)
            if(!chatarray)
            {
                let User_dict:[AnyHashable: Any] = ["user_common_id": to + "-" + from,"user_to_dp":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_type":Chat_type,"is_archived":"0","conv_id":"","timestamp":timestamp,"opponent_id":to,"is_read":"0","chat_count":"0"]
                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: User_dict as NSDictionary,Entityname: Constant.sharedinstance.Chat_intiated_details)
                
            }
            else
            {
                let User_dict:[AnyHashable: Any]=["timestamp":timestamp,"is_archived":"0","is_read":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_count":"0"]
                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: to + "-" + from , attribute: "user_common_id", UpdationElements: User_dict as NSDictionary?)
            }
        }else{
            let chatarray:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: from + "-" + to)
            if(!chatarray)
            {
                let User_dict:[AnyHashable: Any] = ["user_common_id": from + "-" + to,"user_to_dp":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_type":Chat_type,"is_archived":"0","conv_id":"","timestamp":timestamp,"opponent_id":to,"is_read":"0","chat_count":"0"]
                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: User_dict as NSDictionary,Entityname: Constant.sharedinstance.Chat_intiated_details)
                
            }
            else
            {
                let User_dict:[AnyHashable: Any]=["timestamp":timestamp,"is_archived":"0","is_read":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_count":"0"]
                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: from + "-" + to , attribute: "user_common_id", UpdationElements: User_dict as NSDictionary?)
            }
        }
        
        let RedirectLink:String = "https://maps.google.com/maps?q=\(latitudeR!),\(longitudeR!)&amp;z=15&amp;hl=en"
        let LocationDIct:NSDictionary = ["doc_id":toDocId,"image_link":imagelink,"lat":"\(latitudeR!)","long":"\(longitudeR!)","redirect_link":RedirectLink,"thumbnail_data":"","title":Themes.sharedInstance.CheckNullvalue(Passed_value: display),"stitle":Themes.sharedInstance.CheckNullvalue(Passed_value:subTitle)]
        DatabaseHandler.sharedInstance.InserttoDatabase(Dict: LocationDIct as NSDictionary,Entityname: Constant.sharedinstance.Location_details)
        
        SDWebImageManager.shared().imageDownloader?.downloadImage(with: URL(string:imagelink), options: .highPriority, progress: nil, completed: { (image:UIImage?, data:Data?, erro:Error?, downloaded:Bool) in
            if(image != nil)
            {
                let address = "\(Themes.sharedInstance.CheckNullvalue(Passed_value: display)), \(Themes.sharedInstance.CheckNullvalue(Passed_value:subTitle))"
                let MapimageData:Data = image!.jpegData(compressionQuality: 0.1)!
//                    UIImageJPEGRepresentation(image!, 0.1)! as Data
                let base64str:String = Themes.sharedInstance.convertImageToBase64(imageData:MapimageData)
                let param:NSDictionary = ["title":Themes.sharedInstance.CheckNullvalue(Passed_value: display),"url":RedirectLink,"description":Themes.sharedInstance.CheckNullvalue(Passed_value:subTitle),"image":imagelink,"thumbnail_data":base64str]
                
                let metadict  = param
                
                if(self.Chat_type == "single")
                {
                    let Dict:Dictionary = ["from":Themes.sharedInstance.Getuser_id(),"to":to,"payload":EncryptionHandler.sharedInstance.encryptmessage(str: address,toid:to, chat_type: self.Chat_type),"id":EncryptionHandler.sharedInstance.encryptmessage(str:timestamp,toid:to, chat_type: self.Chat_type),"type":"14","toDocId":EncryptionHandler.sharedInstance.encryptmessage(str:toDocId,toid:to, chat_type: self.Chat_type),"metaDetails":metadict] as [String : Any]
                    SocketIOManager.sharedInstance.EmitMessage(param: Dict)
                }else if(self.Chat_type == "secret"){
                    let Dict:Dictionary = ["from":Themes.sharedInstance.Getuser_id(),"to":to,"payload":EncryptionHandler.sharedInstance.encryptmessage(str: address,toid:to, chat_type: self.Chat_type),"id":EncryptionHandler.sharedInstance.encryptmessage(str:timestamp,toid:to, chat_type: self.Chat_type),"type":"14","toDocId":EncryptionHandler.sharedInstance.encryptmessage(str:toDocId,toid:to, chat_type: self.Chat_type),"metaDetails":metadict,"chat_type":"secret"] as [String : Any]
                    SocketIOManager.sharedInstance.EmitMessage(param: Dict)
                }
                else
                {
                    let displayName = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Group_details, attrib_name: "id", fetchString: to, returnStr: "displayName")
                    let Dict:Dictionary = ["from":Themes.sharedInstance.Getuser_id(),"to":to,"payload":EncryptionHandler.sharedInstance.encryptmessage(str: address,toid:to, chat_type: self.Chat_type), "id":EncryptionHandler.sharedInstance.encryptmessage(str:timestamp,toid:to, chat_type: self.Chat_type),"type":"14","toDocId":EncryptionHandler.sharedInstance.encryptmessage(str:toDocId, toid:to, chat_type: self.Chat_type),"metaDetails":metadict,"groupType":"9","userName":displayName,"convId":to] as [String : Any]
                    SocketIOManager.sharedInstance.Groupevent(param: Dict)
                }
            }
        })
        //addRefreshViews()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            self.dealTheFunctionData(DBDict as! [AnyHashable : Any], fromOrdering: false)
        }
        funcView.changeSendBtn(withPhoto: true)
    }
    
    func RemoveStatus(status:String,recordId:String)
    {
        let param:NSDictionary = ["from":Themes.sharedInstance.Getuser_id(),"status":status,"recordId":recordId]
        SocketIOManager.sharedInstance.EmitStatusDeletedetails(Dict: param)
    }
    
    func addNotificationListener() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.outgoingmessage), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else{ return }
            weak.sendMessage(notify)
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.Incomingmessage), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else{ return }
            weak.receiveMessage(notify)
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.userDidTakeScreenshotNotification, object: nil, queue: .main) { [weak self] notification in
            guard let weak = self else{ return }
            if((weak.isModal()  || AppDelegate.sharedInstance.isVideoViewPresented) && weak.Chat_type == "secret")
            {
                var timestamp:String =  String(Date().ticks)
                var servertimeStr:String = Themes.sharedInstance.getServerTime()
                
                let from = Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
                let to = Themes.sharedInstance.CheckNullvalue(Passed_value: weak.opponent_id)
                if(servertimeStr == "")
                {
                    servertimeStr = "0"
                }
                let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
                timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
                let toDocId:String="\(from)-\(to)-\(timestamp)"
                if(weak.Chat_type == "group") {
                    let Groupdic:[AnyHashable: Any] = ["from":Themes.sharedInstance.Getuser_id(),"to":to,"type":"71","payload":EncryptionHandler.sharedInstance.encryptmessage(str: "took a screenshot", toid:to, chat_type: weak.Chat_type),"convId":to,"toDocId":EncryptionHandler.sharedInstance.encryptmessage(str:toDocId,toid:to, chat_type: weak.Chat_type),"groupType":"9","userName":Themes.sharedInstance.CheckNullvalue(Passed_value: weak.Group_name_Lbl.text),"id":EncryptionHandler.sharedInstance.encryptmessage(str:Themes.sharedInstance.CheckNullvalue(Passed_value: timestamp),toid:to, chat_type: weak.Chat_type), "is_tag_applied" : ""]
                    SocketIOManager.sharedInstance.SendMessage_group(param: Groupdic as NSDictionary)
                }
                else
                {
                    SocketIOManager.sharedInstance.secretMessage(from: Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id()), to: to, payload: "took a screenshot", type: "71", timestamp: timestamp, DocID:toDocId,thumbnail: "",thumbnail_data: "",filesize: "",height: "0",width: "0",doc_name:"",numPages: "", duration: "",chat_type: weak.Chat_type)
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else{ return }
            weak.keyboardChangeShow(notify)
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else{ return }
            weak.keyboardChangeHide(notify)
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.reloadChats), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else{ return }
            weak.loadBaseViewsAndData()
            weak.LoadBaseView(limit: 0)
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.sc_typing), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else{ return }
            weak.TypingStatus(not: notify)
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.loaderdata), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else{ return }
            weak.ReloadLoaderView(notify)
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else{ return }
            if let hitLastSeen = notify.object as? [String : Any], Themes.sharedInstance.CheckNullvalue(Passed_value: hitLastSeen["hit"]) == "1" {
                SocketIOManager.sharedInstance.lastSeen(from: Themes.sharedInstance.Getuser_id(), to: weak.opponent_id)
            }
            weak.reloaddata()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.StarUpdate), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else{ return }
            weak.starMessageUpdate(notify)
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.loadChatView), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else{ return }
            if((notify.userInfo) != nil)
            {
                let recordId = notify.userInfo!["recordId"] as? String
                
                let messageFrame = (weak.chatModel.dataSource as! [UUMessageFrame]).filter({$0.message.recordId  == recordId}).first
                
                if(messageFrame != nil)
                {
                    let index = weak.chatModel.dataSource.index(of: messageFrame!)
                    let indexPath = IndexPath(row: index, section: 0)
                    weak.chatModel.dataSource.removeObject(at: index)
                    weak.chatTableView.deleteRows(at: [indexPath], with: .fade)
                    weak.chatTableView.reloadData()
                }
            }
            else
            {
                weak.loadBaseViewsAndData()
                weak.LoadBaseView(limit: 0)
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.updateCell), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else{ return }
            let recordId = Themes.sharedInstance.CheckNullvalue(Passed_value: (notify.object as! NSDictionary).value(forKey: "recordId"))
            
            weak.chatModel.dataSource.forEach({ chatObj in
                let chatObj = chatObj as! UUMessageFrame
                if(chatObj.message.recordId == recordId)
                {
                    let index = weak.chatModel.dataSource.index(of: chatObj)
                    chatObj.message.is_deleted = "1"
                    chatObj.message.type = MessageType(rawValue: 0)!
                    chatObj.message.message_type = "0"
                    
                    if(chatObj.message.from == MessageFrom(rawValue: 1))
                    {
                        chatObj.message.payload = "🚫 You deleted this message."
                    }
                    else
                    {
                        chatObj.message.payload = "🚫 This message was deleted."
                        
                    }
                    DispatchQueue.main.async{
                        weak.chatTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                    }
                }
            })
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.VoicePlayHasInterrupt), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else{ return }
            weak.uuavAudioPlayerDidFinishPlay(true)
        }
    }
    
    func removeNotificationListener() {
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        removeNotificationListener()
    }
    
 }
 
 
 extension InitiateChatViewController : PersonViewedStatusViewDelegate {
    
    func passSelectedPerson(data: NSDictionary) {
        
        let checkId = Themes.sharedInstance.CheckNullvalue(Passed_value: data.value(forKey: "id"))
        
        var id = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Favourite_Contact, attrib_name: "id", fetchString: checkId, returnStr: "id")
        
        var name = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Favourite_Contact, attrib_name: "id", fetchString: checkId, returnStr: "name")
        if(name == "")
        {
            name = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Favourite_Contact, attrib_name: "id", fetchString: checkId, returnStr: "msisdn")
        }
        
        if(id == "")
        {
            
            name = Themes.sharedInstance.CheckNullvalue(Passed_value: data.value(forKey: "Name"))
            
            if(name == "")
            {
                name = Themes.sharedInstance.CheckNullvalue(Passed_value: data.value(forKey: "msisdn"))
            }
            id = checkId
            
        }
        
        var Text = self.IFView.textView.text!
        let text = Text.components(separatedBy: "@").last!
        if(text != " ")
        {
            if let range = Text.range(of: "@" + text, options: .backwards, range: nil, locale: nil) {
                Text = Text.replacingCharacters(in: range, with: "")
            }
        }
        
        let range = NSMakeRange(Text.length, name.length + 1)
        TagPersonRange.append(range)
        TagNameArr.append("@"+name)
        
        TagIdArr.append(id)
        self.IFView.textView.text = Text + "@" + name + " "
        
        let attributed = NSMutableAttributedString(string: self.IFView.textView.text!)
        
        attributed.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15.0)], range: NSMakeRange(0, self.IFView.textView.text.length))
        
        TagPersonRange.forEach { range in
            attributed.addAttributes([NSAttributedString.Key.foregroundColor : CustomColor.sharedInstance.themeColor, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15.0)], range: NSMakeRange(range.location + 1, range.length-1))
            
            attributed.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.lightGray, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15.0)], range: NSMakeRange(range.location, 1))
            
        }
        
        if(TagPersonRange.count > 0)
        {
            self.IFView.textView.internalTextView.attributedText = attributed
        }
        else
        {
            self.IFView.textView.internalTextView.textColor = UIColor.black
        }
        
    }
    
    func closeContentSheed() {
        
    }
    
    func forward() {
        
    }
    
    func delete() {
        
    }
    
 }
 
 extension InitiateChatViewController : StatusPageViewControllerDelegate {
    
    func DidDismiss() {
        appear = true
    }
    
    
    func DidClickDelete(_ messageFrame: UUMessageFrame) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let alert = UIAlertController(title: nil, message: "Delete this status update? It will also be deleted for everyone who received it.", preferredStyle: .actionSheet)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action : UIAlertAction) in
                
                let chatobj = messageFrame
                self.RemoveStatus(status: "2", recordId: chatobj.message.recordId!)
                
                if(chatobj.message.message_type == "0" || chatobj.message.message_type == "4" || chatobj.message.message_type == "5" || chatobj.message.message_type == "14" || chatobj.message.message_type == "11")
                {
                    let p1 = NSPredicate(format: "id = %@", chatobj.message._id)
                    DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Status_one_one, Predicatefromat: p1, Deletestring: "id", AttributeName: "id")
                    
                }
                else
                    
                {
                    let p1 = NSPredicate(format: "id = %@", chatobj.message._id)
                    DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Status_one_one, Predicatefromat: p1, Deletestring: "id", AttributeName: "id")
                    
                    let predic = NSPredicate(format: "upload_data_id == %@",chatobj.message.thumbnail)
                    
                    let uploadDetailArr = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Status_Upload_Details, attribute: "upload_data_id", FetchString: chatobj.message.thumbnail, SortDescriptor: nil) as! [NSManagedObject]
                    if(uploadDetailArr.count > 0)
                    {
                        _ = uploadDetailArr.map {
                            let uploadDict = $0
                            let upload_Path:String = Themes.sharedInstance.CheckNullvalue(Passed_value: uploadDict.value(forKey: "upload_Path"))
                            Filemanager.sharedinstance.DeleteFile(foldername: upload_Path)
                        }
                        DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Status_Upload_Details, Predicatefromat: predic, Deletestring: "chatobj.message.thumbnail", AttributeName: "id")
                    }
                }
                
                let checkmessage = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Status_one_one, attribute: "from", FetchString: Themes.sharedInstance.Getuser_id())
                if(!checkmessage)
                {
                    let p1 = NSPredicate(format: "user_common_id = %@", Themes.sharedInstance.Getuser_id())
                    
                    DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Status_initiated_details, Predicatefromat: p1, Deletestring: "user_common_id", AttributeName: "from")
                }
            }
            let CancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action : UIAlertAction) in
            }
            alert.addAction(deleteAction)
            alert.addAction(CancelAction)
            self.presentView(alert, animated: true, completion: nil)
        }
    }
 }
 
 extension InitiateChatViewController:SecretmessageHandlerDelegate
 {
    func callBackDeletedmessgae(user_common_id: String, doc_idArr: [String], status: String) {
        if(status == "1")
        {
            let from = Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
            let to = Themes.sharedInstance.CheckNullvalue(Passed_value: opponent_id)
            
            let commonid:String = String(describing: to + "-" + from)
            if(user_common_id == commonid)
            {
                var indexpath:[IndexPath] = []
                let indexset = NSMutableIndexSet()
                
                _ = doc_idArr.map{
                    
                    let id:String = $0
                    let messageFrame = (chatModel.dataSource as! [UUMessageFrame]).filter({$0.message.doc_id  == id}).first
                    if(messageFrame != nil)
                    {
                        let index = chatModel.dataSource.index(of: messageFrame!)
                        indexpath.append(IndexPath(row: index, section: 0))
                        indexset.add(index)
                        
                    }
                }
                
                if(indexpath.count > 0)
                {
                    self.chatModel.dataSource.removeObjects(at: indexset as IndexSet)
                    self.chatTableView.deleteRows(at: indexpath, with: .fade)
                    self.chatTableView.reloadData()
                }
            }
            
        }
        
    }
 }
 
 
 extension InitiateChatViewController : SwiftyGiphyViewControllerDelegate {
    
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
                            
                            
                            let from = Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
                            let to = Themes.sharedInstance.CheckNullvalue(Passed_value: self.opponent_id)
                            
                            let User_chat_id = from + "-" + to;
                            
                            let url = Filemanager.sharedinstance.SaveImageFile(imagePath: "Temp/\(timestamp).gif", imagedata: data!)
                            
                            let ObjMultiRecord:MultimediaRecord = MultimediaRecord()
                            
                            let Pathextension:String = "GIF"
                            if(self.Chat_type == "group")
                            {
                                ObjMultiRecord.assetname = "\(User_chat_id)-g-\(timestamp).\(Pathextension.lowercased())"
                            }
                            else
                            {
                                ObjMultiRecord.assetname = "\(User_chat_id)-\(timestamp).\(Pathextension.lowercased())"
                            }
                            ObjMultiRecord.timestamp = timestamp
                            ObjMultiRecord.userCommonID = User_chat_id
                            ObjMultiRecord.assetpathname = url
                            ObjMultiRecord.toID = to
                            ObjMultiRecord.isVideo = false
                            ObjMultiRecord.StartTime = 0.0
                            ObjMultiRecord.Endtime = 0.0
                            ObjMultiRecord.Thumbnail = image
                            ObjMultiRecord.rawData = data
                            ObjMultiRecord.isGif = true
                            
                            ObjMultiRecord.CompresssedData = image!.jpegData(compressionQuality: 0.1)
                            ObjMultiRecord.Base64Str = Themes.sharedInstance.convertImageToBase64(imageData:ObjMultiRecord.CompresssedData)
                            
                            Filemanager.sharedinstance.DeleteFile(foldername: "Temp/\(timestamp).gif")
                            
                            let EditVC = self.storyboard?.instantiateViewController(withIdentifier: "EditViewControllerID") as! EditViewController
                            EditVC.AssetArr = NSMutableArray.init(array: [ObjMultiRecord])
                            EditVC.isfromStatus = false
                            EditVC.Delegate = self
                            EditVC.selectedAssets = []
                            EditVC.isgroup = (self.Chat_type == "group") ? true : false
                            EditVC.to_id = self.opponent_id
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
 
 extension InitiateChatViewController : UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard urls.count > 0 else {return}
        let url = urls[0]
        if(Chat_type == "secret")
        {
            let user_common_id = opponent_id + "-" + Themes.sharedInstance.Getuser_id()
            let checkBool:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Secret_Chat, attribute: "user_common_id", FetchString: user_common_id)
            if(!checkBool)
            {
                self.time(time:"1 hour")
            }
        }
        
        let cico = url
        let objRecord:DocumentRecord = DocumentRecord()
        let Pathextension:String = cico.pathExtension
        if(Pathextension.uppercased() == "PDF")
        {
            let document: CGPDFDocument? = CGPDFDocument(url as CFURL)
            let pageCount: size_t = document!.numberOfPages
            objRecord.docPageCount = "\(pageCount)"
            objRecord.docType = "1"
            objRecord.docImage =  self.buildThumbnailImage(document: document!)!
            objRecord.docPath = cico
            objRecord.path_extension = Pathextension.lowercased()
            objRecord.docName = cico.lastPathComponent.lowercased()
        }
        else if (Pathextension.uppercased() == "TXT" || Pathextension.uppercased() == "DOC" || Pathextension.uppercased() == "DATA" || Pathextension.uppercased() == "TEXT" || Pathextension.uppercased() == "DAT" || Pathextension.uppercased() == "DOCX" || Pathextension.uppercased() == "XLSX" || Pathextension.uppercased() == "NUMBERS")
        {
            objRecord.docPageCount = ""
            objRecord.docType = "2"
            objRecord.docImage =  #imageLiteral(resourceName: "docicon")
            objRecord.docPath = cico
            objRecord.path_extension = Pathextension.lowercased()
            objRecord.docName = cico.lastPathComponent.lowercased()
        }
        
        var filesize = Float()
        var Docdata = Data()
        if(objRecord.docType != "")
        {
            do
            {
                Docdata = try Data(contentsOf: objRecord.docPath)
                filesize = Float(Docdata.count) / 1024.0 / 1024.0
                if(filesize > Constant.sharedinstance.DocumentUploadSize)
                {
                    _ = JSSAlertView().show(self,title: Themes.sharedInstance.GetAppname(),text: "Document size exceeded. Kindly choose below 30 MB size file.",buttonText: "OK",color: CustomColor.sharedInstance.alertColor)
                    return
                }
            }
            catch
            {
                print(error.localizedDescription)
            }
            
            SaveDoc(objRecord: objRecord) { Dict in
                
                var secret_msg_id:String = ""
                if(Dict.count > 0)
                {
                    let from = Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
                    let to = Themes.sharedInstance.CheckNullvalue(Passed_value: self.opponent_id)
                    var timestamp:String =  String(Date().ticks)
                    var servertimeStr:String = Themes.sharedInstance.getServerTime()
                    var user_common_id:String = ""
                    if(self.Chat_type == "secret"){
                        user_common_id = Themes.sharedInstance.CheckNullvalue(Passed_value: to + "-" + from)
                        var checksecretmessagecount:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Secret_Chat, attribute: "user_common_id", FetchString: user_common_id, SortDescriptor: "timestamp") as! NSArray
                        checksecretmessagecount = checksecretmessagecount.reversed() as NSArray
                        
                        if(checksecretmessagecount.count > 0)
                        {
                            
                            secret_msg_id = Themes.sharedInstance.CheckNullvalue(Passed_value: (checksecretmessagecount[0] as! NSManagedObject).value(forKey: "doc_id"))
                        }
                    }else{
                        user_common_id = Themes.sharedInstance.CheckNullvalue(Passed_value: from + "-" + to)
                    }
                    if(servertimeStr == "")
                    {
                        servertimeStr = "0"
                    }
                    let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
                    timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
                    if(self.Chat_type == "group")
                    {
                        timestamp = self.document_msg_id
                    }
                    let _:String = Dict.object(forKey: "id") as! String
                    let Name:String=Themes.sharedInstance.setNameTxt(Themes.sharedInstance.Getuser_id(), "")
                    let Phonenumber:String=Themes.sharedInstance.setPhoneTxt(Themes.sharedInstance.Getuser_id())
                    
                    let dic:[AnyHashable: Any] = ["type": "6","convId":"","doc_id":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(self.document_doc_id)"
                        ),"filesize":"","from":Themes.sharedInstance.CheckNullvalue(Passed_value:from
                        ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:to
                        ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
                        ),"message_status":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
                        ),"id":timestamp,"name":Themes.sharedInstance.CheckNullvalue(Passed_value:Name
                        ),"payload":"Document","recordId":"","timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
                        ),"thumbnail":self.pathname,"width":"0.0","height":"0.0","msgId":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
                        ),"contactmsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value:Phonenumber
                        ),"user_common_id":user_common_id,"message_from":"1","chat_type":self.Chat_type,"info_type":"0","created_by":from,"docType":objRecord.docType,"docName":objRecord.docName,"docPageCount":objRecord.docPageCount,"is_reply":"0","secret_msg_id":secret_msg_id,"secret_timestamp":"", "date" : Themes.sharedInstance.getTimeStamp(), "while_blocked" : Themes.sharedInstance.isImBlocked(to) ? "1" : "0"]
                    DatabaseHandler.sharedInstance.InserttoDatabase(Dict: dic as NSDictionary,Entityname: Constant.sharedinstance.Chat_one_one)

                    if(self.Chat_type == "secret"){
                        let chatarray:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: "\(to)-\(from)")
                        if(!chatarray)
                        {
                            let User_dict:[AnyHashable: Any] = ["user_common_id": "\(to)-\(from)","user_to_dp":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_type":self.Chat_type,"is_archived":"0","conv_id":"","timestamp":timestamp,"opponent_id":to,"is_read":"0","chat_count":"0"]
                            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: User_dict as NSDictionary,Entityname: Constant.sharedinstance.Chat_intiated_details)
                            
                        }
                        else
                        {
                            let User_dict:[AnyHashable: Any]=["timestamp":timestamp,"is_archived":"0","is_read":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_count":"0"]
                            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: "\(to)-\(from)" , attribute: "user_common_id", UpdationElements: User_dict as NSDictionary?)
                        }
                    }else{
                        let chatarray:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: "\(from)-\(to)")
                        if(!chatarray)
                        {
                            let User_dict:[AnyHashable: Any] = ["user_common_id": "\(from)-\(to)","user_to_dp":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_type":self.Chat_type,"is_archived":"0","conv_id":"","timestamp":timestamp,"opponent_id":to,"is_read":"0","chat_count":"0"]
                            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: User_dict as NSDictionary,Entityname: Constant.sharedinstance.Chat_intiated_details)
                            
                        }
                        else
                        {
                            let User_dict:[AnyHashable: Any]=["timestamp":timestamp,"is_archived":"0","is_read":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_count":"0"]
                            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: "\(from)-\(to)" , attribute: "user_common_id", UpdationElements: User_dict as NSDictionary?)
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                        self.dealTheFunctionData(dic, fromOrdering: false)
                        
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                        UploadHandler.Sharedinstance.handleUpload()
                    }
                }
            }
        }
        else
        {
            Themes.sharedInstance.jssAlertView(viewController: self, title: Themes.sharedInstance.GetAppname(), text: "Unable to upload this file format", buttonTxt: "Ok", color: CustomColor.sharedInstance.alertColor)
        }
        
        
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        self.dismissView(animated: true, completion: nil)
    }
 }

