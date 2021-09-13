//
//  SingleInfoViewController.swift
//
//
//  Created by CASPERON on 08/02/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit
import JSSAlertView
import SDWebImage
import Contacts
import ContactsUI
import MessageUI
import JSSAlertView
import SimpleImageViewer


protocol UserDetlUpdationDelegate : class {
    func updateDetail(name:String,phNo:String,Image:String)
    // func
}
class SingleInfoViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,CNContactPickerDelegate,CNContactViewControllerDelegate,MFMessageComposeViewControllerDelegate {
    @IBOutlet weak var baseViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imageviewbottomlayout: NSLayoutConstraint!
    
    @IBOutlet weak var imgBottomContstraint: NSLayoutConstraint!
    @IBOutlet weak var editBtn:UIButton!
    @IBOutlet weak var headerLbl: CustomLblFont!
    @IBOutlet weak var userImg: UIButton!
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var userImg_View: UIImageView!
    
    
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var propertiesTableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    var user_id:String! = String()
    var propertyNameArray:NSArray = NSArray()
    var selectDescription:NSArray = NSArray()
    var cutomColor = CustomColor()
    var favArray:NSMutableArray = NSMutableArray()
    weak var delegate:UserDetlUpdationDelegate!
    weak var Delegate:ContactHandlerDelegate?
    var checkFav:String = String()
    var notExtUser_Arr:NSArray = NSArray()
    var phNoStr:String = String()
    var propertyLbl:UILabel = UILabel()
    var status_TxtView:UITextView = UITextView()
    var encrptImageView:UIImageView = UIImageView()
    var isFromContact:Bool = Bool()
    var GroupRecordArr:NSMutableArray = NSMutableArray()
    var isGroupAvaliable:Bool = Bool()
    var statusDes_TxtView:UILabel = UILabel()
    var fromGroupInfo:Bool = Bool()
    
    var section1Arr:[[String:Any]] = [[:]]
    var section2Arr:[[String:Any]] = [[:]]
    var section3Arr:[String] = []
    
    var isfromsecretChat:Bool = Bool()
    var isCalling:Bool = Bool()
    var dataSource:NSMutableArray = NSMutableArray()
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        addNotificationListener()
        checkFav = "Existing"
        
        
        propertiesTableView.tableFooterView = UIView()
                        

        isCalling = false
        scrollView.delegate = self
        // Do any additional setup after loading the view.
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.reloadChats), object: nil, userInfo: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        self.reloaddata()
    }

    func reloaddata() {
        Themes.sharedInstance.RemoveactivityView(View: self.propertiesTableView)
        self.userImg_View.setProfilePic(self.user_id, "single")
        LoadGroupDetails()
        
        let nibName = UINib(nibName: "GroupInfoTableViewCell", bundle: nil)
        propertiesTableView.register(nibName, forCellReuseIdentifier: "GroupInfoTableViewCell")
        
        let nibName2 = UINib(nibName: "DetailtableViewCell", bundle: nil)
        propertiesTableView.register(nibName2, forCellReuseIdentifier: "DetailtableViewCellID")
        let nibName3 = UINib(nibName: "SettingsTableViewCell", bundle: nil)
        propertiesTableView.register(nibName3, forCellReuseIdentifier: "SettingsTableViewCell")
        
//        if(!isfromsecretChat)
//        {
//            section3Arr = ["Start secret chat","Share Contact","Export Chat","Clear Chat","Block this Contact"]
//        }
//        else
//        {
//            section3Arr = ["Share Contact","Export Chat","Clear Chat","Block this Contact"]
//        }
        section3Arr = ["Share Contact","Export Chat","Clear Chat","Block this Contact"]

        if(GroupRecordArr.count == 0)
        {
            section2Arr = [[:]]
            section2Arr.removeAll()
        }
        else
        {
            section2Arr = [["name":"Groups In Common","image":#imageLiteral(resourceName: "group")]]
            isGroupAvaliable = true
        }
        
        let time = Themes.sharedInstance.muteOption(id: self.user_id, type: "single")
        
        let user_common_id = Themes.sharedInstance.Getuser_id() + "-" + self.user_id
        let saveToGallery = Themes.sharedInstance.saveToGallryOption(id: user_common_id)
        
        section1Arr = [["name":"Media,Links and Docs","image":#imageLiteral(resourceName: "media"),"desc":""],["name":"Starred Messages","image":#imageLiteral(resourceName: "star"),"desc" : GetStarmessageCount()],["name":"Mute","image":#imageLiteral(resourceName: "infomute"),"desc":time], ["name": "Save to Camera Roll","image":#imageLiteral(resourceName: "gallery_ic"),"desc":saveToGallery]]
        
        notExtUser_Arr = ["Invite To \(Themes.sharedInstance.GetAppname())","Share Contact","Variation"]
        propertiesTableView.reloadData()

    }
    
    func LoadGroupDetails()
    {
        let predicate1:NSPredicate = NSPredicate(format:"user_id == %@" , Themes.sharedInstance.Getuser_id())
        let predicate2:NSPredicate = NSPredicate(format:"chat_type == %@" , "group")
        let compPrediate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1,predicate2])
        let userChatConvArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Chat_intiated_details, SortDescriptor: nil, predicate: compPrediate, Limit: 0) as! NSArray
        GroupRecordArr = NSMutableArray()
        if(userChatConvArr.count > 0)
        {
            for i in 0..<userChatConvArr.count
            {
                let dict:NSManagedObject = userChatConvArr[i] as! NSManagedObject
                let user_common_id:String = Themes.sharedInstance.CheckNullvalue(Passed_value: dict.value(forKey: "user_common_id"))
                let grouppredicate:NSPredicate = NSPredicate(format:"user_common_id == %@" , user_common_id)
                
                let getgroupDetailArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Group_details, SortDescriptor: nil, predicate: grouppredicate, Limit: 0) as! NSArray
                
                if(getgroupDetailArr.count > 0)
                {
                    for i in 0..<getgroupDetailArr.count
                    {
                        let GroupDetailRec:GroupDetail=GroupDetail()
                        let dict:NSManagedObject = getgroupDetailArr[i] as! NSManagedObject
                        GroupDetailRec.id = Themes.sharedInstance.CheckNullvalue(Passed_value: dict.value(forKey: "id"))
                        GroupDetailRec.displayName = Themes.sharedInstance.CheckNullvalue(Passed_value: dict.value(forKey: "DisplayName"))
                        GroupDetailRec.displayavatar = Themes.sharedInstance.CheckNullvalue(Passed_value: dict.value(forKey: "displayavatar"))
                        let groupData:NSData?=dict.value(forKey: "groupUsers") as? NSData
                        let groupname:NSMutableArray = NSMutableArray()
                        if(groupData != nil)                                {
                            let groupDetail  =  NSKeyedUnarchiver.unarchiveObject(with: groupData! as Data) as! NSArray
                            var to_userPresent = false
                            var me = false
                            for k in 0..<groupDetail.count
                            {
                                
                                let resDict:NSDictionary = groupDetail[k] as! NSDictionary
                                print(resDict)
                                let user_id:String = Themes.sharedInstance.CheckNullvalue(Passed_value: resDict.object(forKey: "id"))
                                if(user_id == self.user_id)
                                {
                                    to_userPresent = true
                                }
                                if(user_id == Themes.sharedInstance.Getuser_id())
                                {
                                    me = true
                                }
                                let msisdn:String? = Themes.sharedInstance.CheckNullvalue(Passed_value: resDict.object(forKey: "msisdn") as? String)
                                if(msisdn != nil)
                                {
                                    let username:String = Themes.sharedInstance.ReturnFavName(opponentDetailsID: user_id, msginid: msisdn!)
                                    groupname.add(username)
                                }
                                
                            }
                            if(to_userPresent && me)
                            {
                                if(groupname.count > 0)
                                {
                                    GroupDetailRec.groupUsers = groupname
                                }
                                GroupRecordArr.add(GroupDetailRec)
                            }
                            
                        }
                        
                    }
                    
                }
            }
            
        }
    }
    
    func attach_media(){
        let picture_path:NSMutableArray = NSMutableArray()
        let contact_path:NSMutableArray = NSMutableArray()
        var save_msg:String = String()
        let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
        let to:String=user_id
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
            let name = Themes.sharedInstance.setNameTxt(Themes.sharedInstance.Getuser_id(), "")
            if(message_from == "1"){
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
    
    func attach_without_media(){
        var save_msg:String = String()
        let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
        let to:String=user_id
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
    
    func share(){
        let dir = CommondocumentDirectory()
        let objectsToShare = [dir.appendingPathComponent("chats.zip")]
        let activityController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        let excludedActivities = [UIActivity.ActivityType.postToFlickr, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.print, UIActivity.ActivityType.assignToContact, UIActivity.ActivityType.postToFlickr, UIActivity.ActivityType.postToVimeo, UIActivity.ActivityType.postToTencentWeibo]
        
        activityController.excludedActivityTypes = excludedActivities
        self.presentView(activityController, animated: true)
    }
    
    func GetStarmessageCount() -> String
    {
        let user_common_id = Themes.sharedInstance.Getuser_id() + "-" + user_id
        let predicate1:NSPredicate =  NSPredicate(format: "user_common_id == %@", user_common_id)
        let predicate2:NSPredicate =  NSPredicate(format: "isStar == 1")
        let compunPred = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1,predicate2])
        let fetchstarRecordArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Chat_one_one, SortDescriptor: nil, predicate: compunPred, Limit: 0) as! NSArray
        return "\(fetchstarRecordArr.count)"
    }
    
    func IschatAvailable() -> Bool
    {
        let user_common_id = Themes.sharedInstance.Getuser_id() + "-" + user_id
        
        return DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "user_common_id", FetchString: user_common_id)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if checkFav == "Not Existing"{
            return 3
        }
        if(section == 0)
        {
            return 0
        }
        else if(section == 1)
        {
            return section1Arr.count
            
        }
        else if(section == 2)
        {
            return section2Arr.count != 0 ? section2Arr.count : section3Arr.count
            
        }
        else if(section == 3)
        {
            return section3Arr.count
            
        }
        return 0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell:DetailtableViewCell = tableView.dequeueReusableCell(withIdentifier: "DetailtableViewCellID") as! DetailtableViewCell
        cell.groupName_TxtField.setNameTxt(user_id, "single")
        headerLbl.setNameTxt(user_id, "single")
        cell.phoneLbl.setPhoneTxt(user_id)
        cell.statusLbl.setStatusTxt(user_id)
        
        if(section == 0)
        {
            cell.audicallBtn.addTarget(self, action: #selector(self.DidclickAudio(_:)), for: .touchUpInside)
            cell.videocallBtn.addTarget(self, action: #selector(self.DidclickVideo(_:)), for: .touchUpInside)
            cell.msgBtn.addTarget(self, action: #selector(self.MovetoChatview(sender:)), for: .touchUpInside)
            cell.audicallBtn.layer.cornerRadius =  cell.audicallBtn.frame.size.width/2
            cell.audicallBtn.clipsToBounds = true
            
            cell.videocallBtn.layer.cornerRadius =  cell.videocallBtn.frame.size.width/2
            cell.videocallBtn.clipsToBounds = true
            cell.msgBtn.layer.cornerRadius =  cell.msgBtn.frame.size.width/2
            cell.msgBtn.clipsToBounds = true
            
            return cell
        }
        return nil
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if checkFav == "Not Existing"{
            return 1
        }
        if(section2Arr.count == 0)
        {
            return 3
            
        }
        return 4
        
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if(section == 0)
        {
            return 127
            
        }
        return 30
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func  tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var Cell:UITableViewCell = UITableViewCell()
        Cell.selectionStyle = .none
        if checkFav == "Not Existing"{
            let cell:GroupInfoTableViewCell = propertiesTableView.dequeueReusableCell(withIdentifier:"GroupInfoTableViewCell" ) as! GroupInfoTableViewCell
            
            cell.propertyTitle_Lbl.text = notExtUser_Arr[indexPath.row] as? String
            cell.subDesc_Lbl.isHidden = true
            cell.propertyTitle_Lbl.textColor = UIColor.blue
            Cell = cell
            return Cell
        }
        else{
            var index:Int = 0
            if(section2Arr.count == 0)
            {
                index = 2
            }
            else
            {
                index = 3
                
            }
            if(indexPath.section == 1)
            {
                let cell:SettingsTableViewCell = propertiesTableView.dequeueReusableCell(withIdentifier:"SettingsTableViewCell" ) as! SettingsTableViewCell
                cell.rightArrow_ImgView.isHidden = false
                cell.subDesc_Lbl.isHidden = false
                let dict:[String:Any] = section1Arr[indexPath.row]
                cell.setting_Lbl.text = Themes.sharedInstance.CheckNullvalue(Passed_value: dict["name"])
                cell.subDesc_Lbl.text = Themes.sharedInstance.CheckNullvalue(Passed_value: dict["desc"])
                cell.setting_Img.image = dict["image"] as? UIImage
                cell.setting_Img.layer.cornerRadius = 5.0
                cell.separator.isHidden = false
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
                if(indexPath.row == section1Arr.count-1)
                {
                    cell.separator.isHidden = true
                }
                Cell = cell
            }
            
            if(index == 3)
            {
                if(indexPath.section == 2)
                {
                    
                    let cell:SettingsTableViewCell = propertiesTableView.dequeueReusableCell(withIdentifier:"SettingsTableViewCell" ) as! SettingsTableViewCell
                    cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
                    
                    cell.rightArrow_ImgView.isHidden = false
                    cell.subDesc_Lbl.isHidden = false
                    let dict:[String:Any] = section2Arr[indexPath.row]
                    cell.setting_Lbl.text = Themes.sharedInstance.CheckNullvalue(Passed_value: dict["name"])
                    cell.subDesc_Lbl.text = Themes.sharedInstance.CheckNullvalue(Passed_value: dict["desc"])
                    cell.setting_Img.image = dict["image"] as? UIImage
                    cell.setting_Img.layer.cornerRadius = 5.0
                    cell.separator.isHidden = true
                    cell.subDesc_Lbl.text = String(describing:GroupRecordArr.count)
                    Cell = cell
                    
                }
            }
            if(indexPath.section == index)
            {
                let cell:GroupInfoTableViewCell = propertiesTableView.dequeueReusableCell(withIdentifier:"GroupInfoTableViewCell" ) as! GroupInfoTableViewCell
                
                cell.separatorInset = UIEdgeInsets(top: 0, left: cell.layoutMargins.left, bottom: 0, right: 0)
                
                if(!isfromsecretChat)
                {
                    if indexPath.row == 0{
                        
                        cell.propertyTitle_Lbl.text = section3Arr[indexPath.row]
                        cell.subDesc_Lbl.isHidden = true
                        cell.rightArrow_ImgView.isHidden = true
                        cell.propertyTitle_Lbl.textColor = cutomColor.lightBlueColor
                        
                    }
                    else if indexPath.row == 1{
                        
                        cell.propertyTitle_Lbl.text = section3Arr[indexPath.row]
                        cell.subDesc_Lbl.isHidden = true
                        cell.rightArrow_ImgView.isHidden = true
                        cell.propertyTitle_Lbl.textColor = cutomColor.lightBlueColor
                        
                    }
                }
                else
                {
                    if indexPath.row == 0{
                        
                        cell.propertyTitle_Lbl.text = section3Arr[indexPath.row]
                        cell.subDesc_Lbl.isHidden = true
                        cell.rightArrow_ImgView.isHidden = true
                        cell.propertyTitle_Lbl.textColor = cutomColor.lightBlueColor
                        
                    }
                }
                
                if indexPath.row == section3Arr.count-3{
                    
                    cell.propertyTitle_Lbl.text = section3Arr[indexPath.row]
                    cell.subDesc_Lbl.isHidden = true
                    cell.rightArrow_ImgView.isHidden = true
                    cell.propertyTitle_Lbl.textColor = IschatAvailable() ? UIColor.red : UIColor.lightGray
                }
                if indexPath.row == section3Arr.count-2{
                    cell.propertyTitle_Lbl.text = section3Arr[indexPath.row]
                    cell.subDesc_Lbl.isHidden = true
                    cell.rightArrow_ImgView.isHidden = true
                    cell.propertyTitle_Lbl.textColor = IschatAvailable() ? UIColor.red : UIColor.lightGray
                }
                if indexPath.row == section3Arr.count-1
                {
                    let TitleStr = Themes.sharedInstance.checkBlock(id: self.user_id) ? "Unblock Contact" : "Block Contact"
                    cell.propertyTitle_Lbl.text = TitleStr
                    cell.subDesc_Lbl.isHidden = true
                    cell.rightArrow_ImgView.isHidden = true
                    cell.propertyTitle_Lbl.textColor = UIColor.red
                    //cell.propertyTitle_Lbl.text = "Export Chat"
                }
                Cell = cell
                
            }
            
        }
        return Cell
    }
    
    
    @IBAction func DidclickVideo(_ sender: Any)
    {
        if(!Themes.sharedInstance.checkBlock(id: user_id))
        {
            if(!isCalling)
            {
                isCalling = true
                self.view.endEditing(true)
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
                    
                    
                    let docID = Themes.sharedInstance.Getuser_id() + "-" + user_id + "-" + timestamp
                    let param:NSDictionary = ["from":Themes.sharedInstance.Getuser_id(),"to":Themes.sharedInstance.CheckNullvalue(Passed_value: user_id),"type":1,"id":Int64(timestamp)!,"toDocId":docID, "roomid" : timestamp]
                    SocketIOManager.sharedInstance.emitCallDetail(Param: param as! [String : Any])
                    AppDelegate.sharedInstance.openCallPage(type: "1", roomid: timestamp, id: user_id)
                    
                }
                else
                {
                    self.view.makeToast(message: Constant.sharedinstance.ErrorMessage, duration: 3, position: HRToastActivityPositionDefault)
                    isCalling = false
                    
                }
                
                
                self.perform(#selector(self.updateCallbtn), with: nil, afterDelay: 3)
            }
        }
        else
        {
            Themes.sharedInstance.showBlockalert(id: user_id)
        }
        
    }
    
    
    @objc func updateCallbtn()
    {
        isCalling = false
    }
    
    @IBAction func DidclickAudio(_ sender: Any)
    {
        if(!Themes.sharedInstance.checkBlock(id: user_id))
        {
            if(!isCalling)
            {
                isCalling = true
                self.view.endEditing(true)
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
                    
                    
                    let docID = Themes.sharedInstance.Getuser_id() + "-" + user_id + "-" + timestamp
                    let param:NSDictionary = ["from":Themes.sharedInstance.Getuser_id(),"to":Themes.sharedInstance.CheckNullvalue(Passed_value: user_id),"type":0,"id":Int64(timestamp)!,"toDocId":docID, "roomid" : timestamp]
                    SocketIOManager.sharedInstance.emitCallDetail(Param: param as! [String : Any])
                    AppDelegate.sharedInstance.openCallPage(type: "0", roomid: timestamp, id: user_id)
                    
                }
                else
                {
                    self.view.makeToast(message: Constant.sharedinstance.ErrorMessage, duration: 3, position: HRToastActivityPositionDefault)
                    isCalling = false
                    
                }
                
                
                self.perform(#selector(self.updateCallbtn), with: nil, afterDelay: 3)
            }
        }
        else
        {
            Themes.sharedInstance.showBlockalert(id: user_id)
        }
    }
    
    func enterToChat(id:String,type:String){
        Themes.sharedInstance.enterTochat(id: id, type: type) { (success) in
            if(success)
            {
                let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                ObjInitiateChatViewController.Chat_type = type
                ObjInitiateChatViewController.opponent_id = id
                self.pushView(ObjInitiateChatViewController, animated: true)
            }
        }
    }
    
    @objc func MovetoChatview(sender:UIButton)
    {
        
        if(isFromContact)
        {
            
            if(self.isKind(of: InitiateChatViewController.self)){
                let chatLocked = Themes.sharedInstance.isChatLocked(id: user_id, type: "single")
                if(chatLocked == true){
                    self.enterToChat(id: user_id, type: "single")
                }else{
                    let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                    ObjInitiateChatViewController.Chat_type="single"
                    ObjInitiateChatViewController.opponent_id = user_id
                    self.pushView(ObjInitiateChatViewController, animated: true)
                }
            }else{
                let chatLocked = Themes.sharedInstance.isChatLocked(id: user_id, type: "single")
                if(chatLocked == true){
                    self.enterToChat(id: user_id, type: "single")
                }else{
                    let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                    ObjInitiateChatViewController.Chat_type="single"
                    ObjInitiateChatViewController.opponent_id = user_id
                    self.pushView(ObjInitiateChatViewController, animated: true)
                }
            }
            
            
            
        }else if(self.isKind(of: InitiateChatViewController.self)){
            self.pop(animated: true)
        }
        else
            
        {
            let chatLocked = Themes.sharedInstance.isChatLocked(id: user_id, type: "single")
            if(chatLocked == true){
                self.enterToChat(id: user_id, type: "single")
            }else{
                let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                ObjInitiateChatViewController.Chat_type="single"
                ObjInitiateChatViewController.opponent_id = user_id
                self.pushView(ObjInitiateChatViewController, animated: true)
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if   checkFav == "Not Existing"{
            if indexPath.row == 0{
                if (MFMessageComposeViewController.canSendText()) {
                    let controller = MFMessageComposeViewController()
                    controller.body = "Hi can  we chat on \(Themes.sharedInstance.GetAppname()),please install that app in your phone"
                    controller.recipients = [phNoStr]
                    controller.messageComposeDelegate = self
                    self.presentView(controller, animated: true)
                }
                
            }
        }
        else
        {
            if(indexPath.section == 1)
            {                
                if indexPath.row == 0{

                    let  groupVC = storyboard?.instantiateViewController(withIdentifier: "MediaViewController") as! MediaViewController
                    let user_common_id = Themes.sharedInstance.Getuser_id() + "-" + user_id
                    groupVC.user_common_id = user_common_id
                    self.pushView(groupVC, animated: true)
                }
                
                if indexPath.row == 1{
                    let  StarredDetailVC = storyboard?.instantiateViewController(withIdentifier: "StarredViewControllerID") as! StarredViewController
                    let user_common_id = Themes.sharedInstance.Getuser_id() + "-" + user_id
                    StarredDetailVC.chat_type = "single"
                    StarredDetailVC.opponent_id = user_id
                    StarredDetailVC.user_common_id = user_common_id
                    StarredDetailVC.isallStarredmessages = false
                    self.pushView(StarredDetailVC, animated: true)
                }

                if indexPath.row == 2{
                    let dict:[String:Any] = section1Arr[indexPath.row]
                    
                    if(Themes.sharedInstance.CheckNullvalue(Passed_value: dict["desc"]) != "No")
                    {
                        let optionMenu = UIAlertController(title: nil, message:  "Choose option", preferredStyle: .actionSheet)
                        
                        // 2
                        let unmuteAction = UIAlertAction(title:  "Unmute", style: .default, handler: {
                            (alert: UIAlertAction!) -> Void in
                            Themes.sharedInstance.Mute_unMutechats(id: self.user_id, type: "single")
                        })
                        let cancelAction = UIAlertAction(title:  "Cancel", style: .cancel, handler: nil)
                        optionMenu.addAction(unmuteAction)
                        optionMenu.addAction(cancelAction)
                        self.presentView(optionMenu, animated: true, completion: nil)
                    }
                    else
                    {
                        Themes.sharedInstance.Mute_unMutechats(id: self.user_id, type: "single")
                    }
                }
                if indexPath.row == 3{
                    let user_common_id = Themes.sharedInstance.Getuser_id() + "-" + self.user_id
                    Themes.sharedInstance.savetoCameraRollUpdate(user_common_id)
                }
            }
            var index:Int = 0
            if(section2Arr.count == 0)
            {
                index = 2
            }
            else
            {
                index = 3
                
            }
            
            if(index == 3)
            {
                if(indexPath.section == 2)
                {
                    let GroupincommonVC = storyboard?.instantiateViewController(withIdentifier:"GroupincommonVCID" ) as! GroupincommonVC
                    GroupincommonVC.GroupRecordArr = GroupRecordArr
                    self.pushView(GroupincommonVC, animated: true)
                }
            }
            
            if(indexPath.section == index)
            {
//                if(!isfromsecretChat)
//                {
//                    if indexPath.row == 0{
//                        self.movetosecretchat()
//                    }
//                    else if indexPath.row == 1{
//                        shareContact()
//                    }
//                }
//                else
//                {
//                    if indexPath.row == 0{
//                        shareContact()
//                    }
//                }
                
                if indexPath.row == 0{
                    shareContact()
                }
                
                if indexPath.row == section3Arr.count-3{
                    
                    self.exportChat()
                    
                }
                
                if indexPath.row == section3Arr.count-2{
                    self.clearchat()
                }
                
                if indexPath.row == section3Arr.count-1{
                    blockchat()
                }
            }
        }
    }
    func movetosecretchat()
    {
        let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
        ObjInitiateChatViewController.is_fromSecret = true
        ObjInitiateChatViewController.Chat_type="secret"
        ObjInitiateChatViewController.opponent_id = user_id
        self.pushView(ObjInitiateChatViewController, animated: true)
    }
    
    func blockchat()
    {
        Themes.sharedInstance.showBlockalert(id: self.user_id)
    }
    
    func clearchat()
    {
        guard IschatAvailable() else{return}
        
        if dataSource.count > 0 {
            let deleteActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let deleteForEveryOneAction = UIAlertAction(title: "Clear for Everyone", style: .destructive) { (delete) in
                
                let lastobject:UUMessageFrame = self.dataSource.lastObject as! UUMessageFrame
                print(lastobject.message.conv_id)
                print(lastobject.message.timestamp)
                
                var timestamp  = ""
                if lastobject.message.timestamp != "" {
                    timestamp = lastobject.message.timestamp
                }else{
                    timestamp = "0"
                }
                Themes.sharedInstance.showDeleteView(self.view, false)
                Themes.sharedInstance.ClearChat("1", "", true,timestamp)
            }
            let deleteForMe = UIAlertAction(title: "Clear for Me", style: .destructive) { [unowned self] (delete) in
                
                let lastobject:UUMessageFrame = self.dataSource.lastObject as! UUMessageFrame
                print(lastobject.message.conv_id)
                print(lastobject.message.timestamp)
                var timestamp  = ""
                if lastobject.message.timestamp != "" {
                    timestamp = lastobject.message.timestamp
                }else{
                    timestamp = "0"
                }
                Themes.sharedInstance.showDeleteView(self.view, false)
                Themes.sharedInstance.ClearChat("1", "", false,timestamp)
            }
            
            let Cancel = UIAlertAction(title: "Cancel", style: .cancel) { (cancel) in
            }
            deleteActionSheet.addAction(deleteForEveryOneAction)
            
            deleteActionSheet.addAction(deleteForMe)
            deleteActionSheet.addAction(Cancel)
            self.presentView(deleteActionSheet, animated: true, completion: nil)
        } else {
            self.view.makeToast(message: "There is no chat messages to delete", duration: 3, position: HRToastActivityPositionDefault)
        }
        
//        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
//
//        let deleteStarredAction = UIAlertAction(title: "Delete all except starred", style: .default, handler: {
//            (alert: UIAlertAction!) -> Void in
//            Themes.sharedInstance.executeClearChat("1", self.user_id, false)
//        })
//        let deleteMessageAction = UIAlertAction(title: "Delete all messages", style: .default, handler: {
//            (alert: UIAlertAction!) -> Void in
//            Themes.sharedInstance.executeClearChat("0", self.user_id, false)
//        })
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
//            (alert: UIAlertAction!) -> Void in
//        })
//        optionMenu.addAction(deleteStarredAction)
//        optionMenu.addAction(deleteMessageAction)
//        optionMenu.addAction(cancelAction)
//
//        self.presentView(optionMenu, animated: true, completion: nil)
    }
    
    func exportChat()
    {
        guard IschatAvailable() else{return}
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        
        // 2
        let attachMediaAction = UIAlertAction(title: "Attach Media", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("File Deleted")
            self.attach_media()
        })
        let withoutMediaAction = UIAlertAction(title: "Without Media", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("File Saved")
            self.attach_without_media()
        })
        
        //
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "comment"), style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        // 4
        optionMenu.addAction(attachMediaAction)
        optionMenu.addAction(withoutMediaAction)
        optionMenu.addAction(cancelAction)
        // 5
        self.presentView(optionMenu, animated: true, completion: nil)
    }
    
    func shareContact()
    {
        let favrecod = returnFavRecord(user_id)
        if(favrecod.contact_ID != "")
        {
            let selectShareVC = storyboard?.instantiateViewController(withIdentifier:"SelectShareContactViewController" ) as! SelectShareContactViewController
            selectShareVC.contactID =  favrecod.contact_ID
            selectShareVC.passingRecord = favrecod
            selectShareVC.contact_share = true
            self.pushView(selectShareVC, animated: true)
        }
        else
        {
            self.view.makeToast(message: "This contact not added in contacts", duration: 3, position: HRToastActivityPositionDefault)
        }
    }
    
    func executeArchiveChat(star_status:String)
    {
        
    }
    
    func returnHeight(Str:String)->CGFloat
    {
        
        let maxLabelWidth:CGFloat = propertiesTableView.frame.width - 20
        let label = UILabel()
        label.numberOfLines = 10
        let addressFont = [ NSAttributedString.Key.font:  UIFont.systemFont(ofSize: 16.0)]
        label.attributedText = NSMutableAttributedString(string: Str , attributes: addressFont )
        let neededSize:CGSize = label.sizeThatFits(CGSize(width:maxLabelWidth, height:CGFloat.greatestFiniteMagnitude))
        let labelHeight = neededSize.height
        return labelHeight
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        //        if indexPath.row == 6{
        //            return 74
        //        }
        
        return 50
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
    
    @IBAction func didClickuserimg(_ sender: UIButton) {
        let configuration = ImageViewerConfiguration { config in
            config.imageView = userImg_View
        }
        self.presentView(ImageViewerController(configuration: configuration), animated: true)
        
        //
    }
    
    @IBAction func editBtnAction(_ sender: UIButton) {
        if(ContactHandler.sharedInstance.CheckCheckPermission())
        {
            let favrecord = returnFavRecord(user_id)
            if(favrecord.contact_ID != "")
            {
                let contactStore = CNContactStore()
                let contactNo_ID:String = Themes.sharedInstance.removeUniqueContactID(ID: Themes.sharedInstance.CheckNullvalue(Passed_value: favrecord.contact_ID))
                
                let predicate = CNContact.predicateForContacts(withIdentifiers : [contactNo_ID])
                
                let keys = [CNContactFormatter.descriptorForRequiredKeys(for: CNContactFormatterStyle.fullName), CNContactEmailAddressesKey, CNContactBirthdayKey, CNContactImageDataKey,CNContactViewController.descriptorForRequiredKeys()] as [Any]
                var contacts = [CNContact]()
                do {
                    contacts = try contactStore.unifiedContacts(matching: predicate, keysToFetch: keys as! [CNKeyDescriptor])
                    
                    if contacts.count > 0 {
                        
                        do {
                            let contactsViewController = CNContactViewController(forNewContact: contacts[0])
                            contactsViewController.delegate = self
                            contactsViewController.title = ""
                            contactsViewController.allowsEditing = true
                            
                            self.navigationController?.isNavigationBarHidden = false
                            self.pushView(contactsViewController, animated: true)
                        }
                    }
                    else
                    {
                        self.view.makeToast(message: "This contact not added in contacts", duration: 3, position: HRToastActivityPositionDefault)
                    }
                }
                catch {
                    print(error.localizedDescription)
                    
                }
            }
            else
            {
                self.view.makeToast(message: "This contact not added in contacts", duration: 3, position: HRToastActivityPositionDefault)
            }
            
        }
        else
        {
            self.presentView(Themes.sharedInstance.showContactPermissionAlert, animated: true)
        }
    }
    
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?){
        print("Action Completed")
        if contact != nil{
            var ContactName:NSString = ""
            if(contact?.middleName == "")
            {
                ContactName = Themes.sharedInstance.CheckNullvalue(Passed_value: "\(String(describing: (contact?.givenName)!)) \(String(describing: (contact?.familyName)!))") as NSString
            }
            else
            {
                ContactName = Themes.sharedInstance.CheckNullvalue(Passed_value: "\(String(describing: (contact?.givenName)!)) \(String(describing: (contact?.middleName)!)) \(String(describing: (contact?.familyName)!))") as NSString
            }
            ContactName = ContactName.trimmingCharacters(in: NSCharacterSet.whitespaces) as NSString
            let param = ["name" : ContactName as String]
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Favourite_Contact, FetchString: self.user_id, attribute: "id", UpdationElements: param as NSDictionary)
            DispatchQueue.main.async {
                self.propertiesTableView.reloadData()
                
            }
        }
        self.pop(animated: true)
    }

    @IBAction func backBtnAction(_ sender: UIButton) {
        self.pop(animated: true)
    }
    
    override func viewWillLayoutSubviews() {
        propertiesTableView.layoutIfNeeded()
        propertiesTableView.reloadData()
        tableViewHeight.constant = propertiesTableView.contentSize.height
        imgBottomContstraint.constant = tableViewHeight.constant
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addNotificationListener() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            weak.reloaddata()
        }
    }
    
    func removeNotificationListener() {
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        removeNotificationListener()
    }

}

extension SingleInfoViewController:UIScrollViewDelegate
{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset.y)
        if(scrollView.contentOffset.y > 0)
        {
            imgBottomContstraint.constant = tableViewHeight.constant-(scrollView.contentOffset.y)
        }
    }
}

