//
//  ShareViewController.swift
//
//
//  Created by Nirmal's Mac Mini on 13/02/19.
//  Copyright © 2019 CASPERON. All rights reserved.
//

import UIKit
import Social
import SDWebImage
import CoreData
import CoreServices
import Photos
import JSSAlertView
import Alamofire

class ShareViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate,UITableViewDataSource {
    
    
    //    override func isContentValid() -> Bool {
    //        // Do validation of contentText and/or NSExtensionContext attachments here
    //        return true
    //    }
    //
    //    override func didSelectPost() {
    //        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    //
    //        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
    //        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    //    }
    //
    //    override func configurationItems() -> [Any]! {
    //        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    //        return []
    //    }
    
    @IBOutlet weak var addNameLbl: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var shareBtn: UIButton!
    
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
    var Share : NSMutableArray=NSMutableArray()
    var type:NSMutableArray=NSMutableArray()
    var userNames:NSMutableArray=NSMutableArray()
    
    var messageDatasourceArr:NSMutableArray = NSMutableArray()
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    var isFromForward:Bool = Bool()
    var isfirst = true
    
    var AssetArr = [URL]()
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        
        print(contactID)
        let nibName = UINib(nibName:"ShareSelectContactTableViewCell", bundle: nil)
        shareContact_TableView.register(nibName, forCellReuseIdentifier: "ShareSelectContactTableViewCell")
        shareContact_TableView.tableFooterView = UIView()
        let bottomBorder = CALayer()
        let bottomWidth = CGFloat(2.0)
        bottomBorder.borderColor = UIColor.blue.cgColor
        bottomBorder.frame = CGRect(x: 0, y:  bottomView.frame.minY+4, width:  shareContact_TableView.frame.size.width, height: 1)
        // shareContact_TableView.estimatedRowHeight = 20
        bottomBorder.borderWidth = bottomWidth
        bottomView.layer.addSublayer(bottomBorder)
        bottomView.layer.masksToBounds = true
        
        headerTitle = ["FREQUENTLY CONTACTED","RECENT CONTACTS"]
        searchBar.delegate  = self
        
        //        searchController.delegate=self
        //        searchController.searchResultsUpdater = self
        
        bottomAnimation()
        getRecentChat()
        GetFavContact()
        shareBtn.setTitle("Share", for: .normal)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(isfirst)
        {
            isfirst = false
            view.transform = CGAffineTransform(translationX: 0, y: view.frame.size.height)
            UIView.animate(withDuration: 0.25, animations: {
                self.view.transform = CGAffineTransform.identity
            })
        }
    }
    
    func dismiss() {
        UIView.animate(withDuration: 0.20, animations: {
            self.view.transform = CGAffineTransform(translationX: 0, y: self.view.frame.size.height)
        }) { finished in
            self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
        }
    }
    
    func fetchFiles(completion : @escaping(_ success : Bool, _ urls : [[String : Any]]) -> ()){
        var AssetURLs = [[String : Any]]()
        _ = self.extensionContext?.inputItems.map {
            let content = $0 as! NSExtensionItem
            let contentType = kUTTypeImage as String
            let contentTypeMovie = kUTTypeMovie as String
            let contentTypeFile = kUTTypeFileURL as String
            let contentTypeAudio = kUTTypeMP3 as String
            let contentTypeText = kUTTypeText as String
            let contentTypeUrl = kUTTypeURL as String
            for attachment in content.attachments as! [NSItemProvider] {
                var index = 0
                if let array = content.attachments as NSArray? {
                    index = array.index(of: attachment)
                }
                if attachment.hasItemConformingToTypeIdentifier(contentType) {
                    attachment.loadItem(forTypeIdentifier: contentType, options: nil) { data, error in
                        if error == nil {
                            if let url = data as? URL {
                                let dict = ["url" : url, "type" : "1"] as [String : Any]
                                AssetURLs.append(dict)
                                if(index == (content.attachments?.count)! - 1) {
                                    completion(true, AssetURLs)
                                }
                            }
                            else if let image = data as? UIImage {
                                let dict = ["url" : image, "type" : "1"] as [String : Any]
                                AssetURLs.append(dict)
                                if(index == (content.attachments?.count)! - 1) {
                                    completion(true, AssetURLs)
                                }
                            }
                        }
                    }
                }
                else if attachment.hasItemConformingToTypeIdentifier(contentTypeMovie) {
                    attachment.loadItem(forTypeIdentifier: contentTypeMovie, options: nil) { data, error in
                        if error == nil {
                            if let url = data as? URL {
                                let dict = ["url" : url, "type" : "2"] as [String : Any]
                                AssetURLs.append(dict)
                                if(index == (content.attachments?.count)! - 1) {
                                    completion(true, AssetURLs)
                                }
                            }
                        }
                    }
                }
                else if attachment.hasItemConformingToTypeIdentifier(contentTypeAudio) {
                    attachment.loadItem(forTypeIdentifier: contentTypeFile, options: nil) { data, error in
                        if error == nil {
                            if let url = data as? URL {
                                let dict = ["url" : url, "type" : "3"] as [String : Any]
                                AssetURLs.append(dict)
                                if(index == (content.attachments?.count)! - 1) {
                                    completion(true, AssetURLs)
                                }
                            }
                        }
                    }
                }
                else if attachment.hasItemConformingToTypeIdentifier(contentTypeFile) {
                    attachment.loadItem(forTypeIdentifier: contentTypeFile, options: nil) { data, error in
                        if error == nil {
                            if let url = data as? URL {
                                let Pathextension = url.pathExtension
                                if(Pathextension.uppercased() == "TXT" || Pathextension.uppercased() == "DOC" || Pathextension.uppercased() == "DATA" || Pathextension.uppercased() == "TEXT" || Pathextension.uppercased() == "DAT" || Pathextension.uppercased() == "DOCX" || Pathextension.uppercased() == "PDF") {
                                    let dict = ["url" : url, "type" : "4"] as [String : Any]
                                    AssetURLs.append(dict)
                                    if(index == (content.attachments?.count)! - 1) {
                                        completion(true, AssetURLs)
                                    }
                                }
                                else
                                {
                                    self.inValid()
                                    completion(false, [])
                                }
                            }
                        }
                    }
                }
                else if attachment.hasItemConformingToTypeIdentifier(contentTypeText) || attachment.hasItemConformingToTypeIdentifier(contentTypeUrl) {
                    var ct = String()
                    if attachment.hasItemConformingToTypeIdentifier(contentTypeText) {
                        ct = contentTypeText
                    }
                    else {
                        ct = contentTypeUrl
                    }
                    attachment.loadItem(forTypeIdentifier: ct, options: nil) { data, error in
                        if error == nil {
                            if let url = data as? URL {
                                let dict = ["url" : url, "type" : "0"] as [String : Any]
                                AssetURLs.append(dict)
                                if(index == (content.attachments?.count)! - 1) {
                                    completion(true, AssetURLs)
                                }
                            }
                            else if let url = data {
                                let dict = ["url" : url, "type" : "0"] as [String : Any]
                                AssetURLs.append(dict)
                                if(index == (content.attachments?.count)! - 1) {
                                    completion(true, AssetURLs)
                                }
                            }
                        }
                    }
                }
                else {
                    self.inValid()
                    completion(false, [])
                }
            }
        }
    }
    
    func inValid(){
        let alertview = JSSAlertView().show(
            self,
            title: Themes.sharedInstance.GetAppname(),
            text: "Unable to share this file format",
            buttonText: "Ok",
            cancelButtonText: nil
        )
        alertview.addAction(self.dismiss)
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
                                    
                                    if(chatprerecord.opponentname == "" || chatprerecord.opponentname == nil)
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
                                            userNames.add("You")
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
                            
                            if(userNames.contains("You")){
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
                    
                    ChatPrerecordArr = NSMutableArray(array: ChatPrerecordArr.filter{($0 as? Chatpreloadrecord != nil)}.sorted{(($0 as! Chatpreloadrecord).opponentlastmessageDate > ($1 as! Chatpreloadrecord).opponentlastmessageDate)})
                    countSortArr = NSMutableArray(array: ChatPrerecordArr.filter{($0 as? Chatpreloadrecord != nil)}.sorted{(($0 as! Chatpreloadrecord).messageCount > ($1 as! Chatpreloadrecord).messageCount)})
//                    var SortArray:NSArray=NSArray(array: ChatPrerecordArr)
//                    let descriptor: NSSortDescriptor = NSSortDescriptor(key: "opponentlastmessageDate", ascending: false)
//                    SortArray = SortArray.sortedArray(using: [descriptor]) as NSArray
//
//                    ChatPrerecordArr=NSMutableArray(array: SortArray)
//                    var sortCountArr:NSArray=NSArray(array: ChatPrerecordArr)
//                    let descriptr: NSSortDescriptor = NSSortDescriptor(key: "messageCount", ascending: false)
//                    sortCountArr = sortCountArr.sortedArray(using: [descriptr]) as NSArray
//                    countSortArr=NSMutableArray(array: sortCountArr)
                    
                    
                    for  _ in 0..<ChatPrerecordArr.count/2{
                        countSortArr.removeObject(at: countSortArr.count-1)
                    }
                    
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
                if(favRecord.name == ""){
                    SortedArr.add(favRecord)
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
                        userNames.add("You")
                    }
                }
                
                favRecord.phnumber = userNames.componentsJoined(by: ", ")
                
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
                label.text = "FREQUENTLY CONTACTED:"
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
                label.text = "RECENT CONTACTS:"
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
        let shareCell:ShareSelectContactTableViewCell = shareContact_TableView.dequeueReusableCell(withIdentifier: "ShareSelectContactTableViewCell") as! ShareSelectContactTableViewCell
        
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
                        shareCell.subDecLbl.text = freqntRec.oppopnentnumber.parseNumber
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
                        
                        shareCell.subDecLbl.text = chatprerecord.oppopnentnumber.parseNumber
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
//                let array = (ChatPrerecordArr as NSArray).filtered(using: namesBeginningWithLetterPredicate.withSubstitutionVariables(["letter": searchString]))
//                let msgCountArray = (countSortArr as NSArray).filtered(using: namesBeginningWithLetterPredicate.withSubstitutionVariables(["letter": searchString]))
                let msgCountArray = (countSortArr as NSArray).filter{(($0 as? Chatpreloadrecord)?.opponentname.lowercased().hasPrefix(searchString.lowercased()) ?? false)}
                
//                namesBeginningWithLetterPredicate = NSPredicate(format: "(name BEGINSWITH[cd] $letter)")
                
//                let contactsArray = (FavList as NSArray).filtered(using: namesBeginningWithLetterPredicate.withSubstitutionVariables(["letter": searchString]))
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
        
        self.navigationController?.pop(animated: true)
    }
    @IBAction func backAction(_ sender: UIButton) {
        self.searchBar.resignFirstResponder()
        
        self.navigationController?.pop(animated: true)
    }
    
    @IBAction func back(_ sender : Any) {
        dismiss()
    }
    
    @IBAction func shareAction(_ sender: UIButton) {
        
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
        
        if(personsArray.count > 0)
        {
            fetchFiles{ success, assets in
                if(success)
                {
                    if assets.count > 0 {
                        let type = Themes.sharedInstance.CheckNullvalue(Passed_value: assets[0]["type"])
                        if(type == "0")
                        {
                            DispatchQueue.main.async {
                                Themes.sharedInstance.showprogressAlert(controller: self)
                                Themes.sharedInstance.setprogressinAlert(controller: self, progress: 0.0)
                                self.sendTextMessage(assets, personsArray as! [[String : Any]])
                            }
                        }
                        else if(type == "3")
                        {
                            DispatchQueue.main.async {
                                Themes.sharedInstance.showprogressAlert(controller: self)
                                Themes.sharedInstance.setprogressinAlert(controller: self, progress: 0.0)
                                self.uploadAudio(assets, personsArray as! [[String : Any]])
                            }
                        }
                        else if(type == "4")
                        {
                            DispatchQueue.main.async {
                                Themes.sharedInstance.showprogressAlert(controller: self)
                                Themes.sharedInstance.setprogressinAlert(controller: self, progress: 0.0)
                                self.documentPicker(assets, personsArray as! [[String : Any]])
                            }
                        }
                        else
                        {
                            AssetHandler.sharedInstance.ProcessAsset(assets: assets, Persons: personsArray as! [[String : Any]], completionHandler: { (assets, showassets, error) -> () in
                                let EditVC = self.storyboard?.instantiateViewController(withIdentifier: "ShareEditViewControllerID") as! ShareEditViewController
                                EditVC.AssetArr = assets
                                EditVC.showAssetArr = showassets
                                EditVC.Delegate = self
                                self.navigationController?.pushViewController(EditVC, animated: true)
                            })
                        }
                    }
                }
            }
        }
        else
        {
            
        }
    }
    
    func uploadAudio(_ assets: [[String : Any]], _ Persons: [[String : Any]]) {
        
        if(assets.count > 0)
        {
            _ = assets.map {
                let asset = $0
                let url = asset["url"] as! URL
                _ = Persons.map {
                    let index = (Persons as NSArray).index(of: $0)
                    let personID = Themes.sharedInstance.CheckNullvalue(Passed_value: $0["id"])
                    let chat_type = Themes.sharedInstance.CheckNullvalue(Passed_value: $0["type"])
                    let seconds = duration(for: url)
                    let from:String = Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
                    let to:String=Themes.sharedInstance.CheckNullvalue(Passed_value: personID)
                    var timestamp:String =  String(Date().ticks)
                    var servertimeStr:String = Themes.sharedInstance.getServerTime()
                    
                    let user_common_id:String = Themes.sharedInstance.CheckNullvalue(Passed_value: from + "-" + to)
                    
                    if(servertimeStr == "")
                    {
                        servertimeStr = "0"
                    }
                    let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
                    timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
                    self.getdataFromURL(url, completion: { data in
                        if let voice = data {
                            self.SaveAudioFile(voice: voice, seconds: seconds, toID: personID, type: chat_type, completion: { InfoDict in
                                let PathName:String = InfoDict.object(forKey: "id") as! String
                                let Name:String=Themes.sharedInstance.setNameTxt(Themes.sharedInstance.Getuser_id(), "")
                                let Phonenumber:String=Themes.sharedInstance.setPhoneTxt(Themes.sharedInstance.Getuser_id())
                                var toDocId:String="\(from)-\(to)-\(timestamp)"
                                
                                if(chat_type == "group")
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
                                    ),"user_common_id":user_common_id,"message_from":"1","chat_type":chat_type,"info_type":"0","created_by":from,"is_reply":"0","secret_msg_id":"","secret_timestamp":"", "date" : Themes.sharedInstance.getTimeStamp()]
                                
                                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: dic as NSDictionary,Entityname: Constant.sharedinstance.Chat_one_one)

                                let chatarray:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: "\(from)-\(to)")
                                if(!chatarray)
                                {
                                    let User_dict:[AnyHashable: Any] = ["user_common_id": "\(from)-\(to)","user_to_dp":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_type":chat_type,"is_archived":"0","conv_id":"","timestamp":timestamp,"opponent_id":to,"is_read":"0","chat_count":"0"]
                                    DatabaseHandler.sharedInstance.InserttoDatabase(Dict: User_dict as NSDictionary,Entityname: Constant.sharedinstance.Chat_intiated_details)
                                    
                                }
                                else
                                {
                                    let User_dict:[AnyHashable: Any]=["timestamp":timestamp,"is_archived":"0","is_read":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_count":"0"]
                                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: "\(from)-\(to)" , attribute: "user_common_id", UpdationElements: User_dict as NSDictionary?)
                                }
                                
                                DispatchQueue.main.async {
                                    Themes.sharedInstance.setprogressinAlert(controller: self, progress: Float(index + 1) / Float(Persons.count))
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                                    self.notifyServer()
                                })
                                
                            })
                        }
                    })
                }
                
            }
        }
    }
    
    func sendTextMessage(_ assets: [[String : Any]], _ Persons: [[String : Any]]) {
        
        if(assets.count > 0)
        {
            _ = assets.map {
                let asset = $0
                _ = Persons.map {
                    let index = (Persons as NSArray).index(of: $0)
                    let personID = Themes.sharedInstance.CheckNullvalue(Passed_value: $0["id"])
                    let chat_type = Themes.sharedInstance.CheckNullvalue(Passed_value: $0["type"])
                    DispatchQueue.main.async {
                        let from:String = Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
                        let to:String=Themes.sharedInstance.CheckNullvalue(Passed_value: personID)
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
                        if(chat_type == "group")
                        {
                            toDocId = "\(from)-\(to)-g-\(timestamp)"
                        }
                        let dic:[AnyHashable: Any] = ["type": "0",
                                                      "convId":"",
                                                      "doc_id":Themes.sharedInstance.CheckNullvalue(Passed_value:toDocId),
                                                      "filesize":"",
                                                      "from":Themes.sharedInstance.CheckNullvalue(Passed_value:from),
                                                      "to":Themes.sharedInstance.CheckNullvalue(Passed_value:to),
                                                      "isStar":"0",
                                                      "message_status":"0",
                                                      "id":timestamp,
                                                      "name":Name,
                                                      "payload":Themes.sharedInstance.CheckNullvalue(Passed_value: asset["url"]),
                                                      "recordId":"",
                                                      "timestamp":timestamp,
                                                      "thumbnail":toDocId,
                                                      "width":"0.0",
                                                      "height":"0.0",
                                                      "msgId":timestamp,
                                                      "contactmsisdn":Phonenumber,
                                                      "user_common_id":from + "-" + to,
                                                      "message_from":"1",
                                                      "chat_type":chat_type,
                                                      "info_type":"0",
                                                      "created_by":from,
                                                      "docType": "",
                                                      "docName":"",
                                                      "docPageCount":"",
                                                      "title":"",
                                                      "image_url":"",
                                                      "desc":"",
                                                      "url_str":"",
                                                      "contact_profile": "",
                                                      "contact_phone":"",
                                                      "contact_id":"",
                                                      "contact_name":"",
                                                      "contact_details":"",
                                                      "is_reply":"0", "date" : Themes.sharedInstance.getTimeStamp()]
                        
                        DatabaseHandler.sharedInstance.InserttoDatabase(Dict: dic as NSDictionary,Entityname: Constant.sharedinstance.Chat_one_one)

                        let chatarray:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: from + "-" + to)
                        if(!chatarray)
                        {
                            let User_dict:[AnyHashable: Any] = ["user_common_id": from + "-" + to,"user_to_dp":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_type":"single","is_archived":"0","conv_id":"","timestamp":timestamp,"opponent_id":"\(to)","chat_count":"0"]
                            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: User_dict as NSDictionary,Entityname: Constant.sharedinstance.Chat_intiated_details)
                        }
                        else
                        {
                            let User_dict:[AnyHashable: Any]=["timestamp":"\(timestamp)","is_archived":"0","is_read":"0","chat_count":"0"]
                            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: from + "-" + to , attribute: "user_common_id", UpdationElements: User_dict as NSDictionary?)
                        }
                        
                        DispatchQueue.main.async {
                            Themes.sharedInstance.setprogressinAlert(controller: self, progress: Float(index + 1) / Float(Persons.count))
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                            self.notifyServer()
                        })
                        
                    }
                }
            }
        }
    }
    
    func notifyServer()
    {
        makeCall(url: Constant.sharedinstance.startFileuploadNotification, param: ["from" : Themes.sharedInstance.Getuser_id()]) { (dict, error) -> () in
            self.dismiss()
        }
    }
    
    func makeCall(url: String,param:NSDictionary, completionHandler: @escaping (_ responseObject: NSDictionary?,_ error:NSError?  ) -> ()?)
    {
        let HeaderDict:NSDictionary=NSDictionary()
        Alamofire.request("\(url)", method: .post, parameters: param as? Parameters, encoding: JSONEncoding.default, headers: HeaderDict as? HTTPHeaders).validate()
            .responseJSON { response in
                if(response.result.error == nil)
                {
                    do {
                        
                        let Dictionary = try JSONSerialization.jsonObject(
                            with: response.data!,
                            options: JSONSerialization.ReadingOptions.mutableContainers
                            ) as? NSDictionary
                        completionHandler(Dictionary as NSDictionary?, response.result.error as NSError? )
                    }
                    catch let error as NSError {
                        completionHandler(nil, error )
                    }
                }
                else
                {
                    
                    
                    completionHandler(nil, response.result.error as NSError? )
                    
                    
                }
        }
        
    }
    
    func SaveAudioFile(voice: Data, seconds : Int, toID: String, type : String, completion: @escaping(_ InfoDict : NSDictionary) -> ())
    {
        DispatchQueue.main.async {
            let from:String = Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
            let to:String = Themes.sharedInstance.CheckNullvalue(Passed_value: toID)
            var timestamp:String =  String(Date().ticks)
            var servertimeStr:String = Themes.sharedInstance.getServerTime()
            
            if(servertimeStr == "")
            {
                servertimeStr = "0"
            }
            let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
            timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
            let User_chat_id = "\(from)-\(to)"
            
            var AssetName:String = "\(User_chat_id)-\(timestamp).mp3"
            
            if(type == "group")
            {
                AssetName = "\(User_chat_id)-g-\(timestamp).mp3"
            }
            let Path:String =  Filemanager.sharedinstance.SaveImageFile(imagePath: "\(Constant.sharedinstance.voicepath)/\(AssetName)",imagedata: voice)
            
            var splitcount:Int = voice.count / Constant.sharedinstance.SendbyteCount
            if(splitcount < 1)
            {
                splitcount = 1
            }
            let uploadDataCount:String = self.getArrayOfBytesFromImage(voice, splitCount: splitcount)
            
            let imagecount:Int = voice.count
            let Dict:[String:Any] = ["failure_status":"0","total_byte_count":"\(imagecount)","upload_byte_count":"0","upload_count":"1","upload_data_id":AssetName,"upload_Path":Path,"upload_status":"0","user_common_id":User_chat_id,"serverpath":"","user_id":Themes.sharedInstance.Getuser_id(),"data_count":uploadDataCount,"compressed_data":"","to_id":to,"message_status":"0","timestamp":timestamp,"total_data_count":"\(Constant.sharedinstance.MultiFormDataSplitCount)","width":"0.0","height":"0.0","upload_type":"3","download_status":"2","strVoiceTime":"\(seconds)","is_uploaded":"1", "upload_paused":"0"]
            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict as NSDictionary, Entityname: Constant.sharedinstance.Upload_Details);
            let param:NSDictionary = ["id":AssetName,"pathname":Path]
            completion(param)
        }
    }
    
    func duration(for resource: URL) -> Int {
        let asset = AVURLAsset(url: resource)
        return Int(CMTimeGetSeconds(asset.duration))
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func documentPicker(_ assets: [[String : Any]], _ Persons: [[String : Any]]) {
        
        if(assets.count > 0)
        {
            _ = assets.map {
                let asset = $0
                let url = asset["url"] as! URL
                
                let cico = url as URL
                print("The Url is : \(cico)")
                _ = Persons.map {
                    let index = (Persons as NSArray).index(of: $0)
                    let personID = Themes.sharedInstance.CheckNullvalue(Passed_value: $0["id"])
                    let chat_type = Themes.sharedInstance.CheckNullvalue(Passed_value: $0["type"])
                    
                    let objRecord:DocumentRecord = DocumentRecord()
                    objRecord.type = chat_type
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
                    else if (Pathextension.uppercased() == "TXT" || Pathextension.uppercased() == "DOC" || Pathextension.uppercased() == "DATA" || Pathextension.uppercased() == "TEXT" || Pathextension.uppercased() == "DAT" || Pathextension.uppercased() == "DOCX")
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
                        SaveDoc(objRecord: objRecord, toID: personID) { Dict, document_msg_id, document_doc_id, pathname in
                            
                            if(Dict.count > 0)
                            {
                                let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
                                let to:String=Themes.sharedInstance.CheckNullvalue(Passed_value: personID)
                                var timestamp:String =  String(Date().ticks)
                                var servertimeStr:String = Themes.sharedInstance.getServerTime()
                                let user_common_id = Themes.sharedInstance.CheckNullvalue(Passed_value: from + "-" + to)
                                
                                if(servertimeStr == "")
                                {
                                    servertimeStr = "0"
                                }
                                let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
                                timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
                                if(chat_type == "group")
                                {
                                    timestamp = document_msg_id
                                }
                                let Name:String=Themes.sharedInstance.setNameTxt(Themes.sharedInstance.Getuser_id(), "")
                                let Phonenumber:String=Themes.sharedInstance.setPhoneTxt(Themes.sharedInstance.Getuser_id())
                                
                                let dic:[AnyHashable: Any] = ["type": "6","convId":"","doc_id":Themes.sharedInstance.CheckNullvalue(Passed_value: document_doc_id),"filesize":"","from":Themes.sharedInstance.CheckNullvalue(Passed_value:from
                                    ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:to
                                    ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
                                    ),"message_status":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
                                    ),"id":timestamp,"name":Themes.sharedInstance.CheckNullvalue(Passed_value:Name
                                    ),"payload":"Document","recordId":"","timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
                                    ),"thumbnail":pathname,"width":"0.0","height":"0.0","msgId":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
                                    ),"contactmsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value:Phonenumber
                                    ),"user_common_id":user_common_id,"message_from":"1","chat_type":chat_type,"info_type":"0","created_by":from,"docType":objRecord.docType,"docName":objRecord.docName,"docPageCount":objRecord.docPageCount,"is_reply":"0","secret_msg_id":"","secret_timestamp":"", "date" : Themes.sharedInstance.getTimeStamp()]
                                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: dic as NSDictionary,Entityname: Constant.sharedinstance.Chat_one_one)

                                let chatarray:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: "\(from)-\(to)")
                                if(!chatarray)
                                {
                                    let User_dict:[AnyHashable: Any] = ["user_common_id": "\(from)-\(to)","user_to_dp":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_type":chat_type,"is_archived":"0","conv_id":"","timestamp":timestamp,"opponent_id":to,"is_read":"0","chat_count":"0"]
                                    DatabaseHandler.sharedInstance.InserttoDatabase(Dict: User_dict as NSDictionary,Entityname: Constant.sharedinstance.Chat_intiated_details)
                                    
                                }
                                else
                                {
                                    let User_dict:[AnyHashable: Any]=["timestamp":timestamp,"is_archived":"0","is_read":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_count":"0"]
                                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: "\(from)-\(to)" , attribute: "user_common_id", UpdationElements: User_dict as NSDictionary?)
                                }
                            }
                            
                            DispatchQueue.main.async {
                                Themes.sharedInstance.setprogressinAlert(controller: self, progress: Float(index + 1) / Float(Persons.count))
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                                self.notifyServer()
                            })
                        }
                    }
                    else
                    {
                        inValid()
                    }
                }
            }
        }
    }
    
    func SaveDoc(objRecord:DocumentRecord,
                 toID: String,
                 completion: @escaping (_ Dict : NSDictionary, _ document_msg_id : String, _ document_doc_id : String, _ pathname : String) -> ())
    {
        
        let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
        let to:String=Themes.sharedInstance.CheckNullvalue(Passed_value: toID)
        var timestamp:String =  String(Date().ticks)
        var servertimeStr:String = Themes.sharedInstance.getServerTime()
        let user_common_id = Themes.sharedInstance.CheckNullvalue(Passed_value: from + "-" + to)
        
        if(servertimeStr == "")
        {
            servertimeStr = "0"
        }
        
        let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
        timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
        let AssetName:String = "\(user_common_id)-\(timestamp).\(objRecord.path_extension)"
        var CompressedImage:String = String()
        var pathname = "\(from)-\(to)-\(timestamp).\(objRecord.path_extension.lowercased())"
        let document_msg_id = timestamp
        var document_doc_id = "\(from)-\(to)-\(timestamp)"
        
        if(objRecord.type == "group")
        {
            pathname = "\(from)-\(to)-g-\(timestamp).\(objRecord.path_extension.lowercased())"
            document_doc_id = "\(from)-\(to)-g-\(timestamp)"
            
        }
        if(objRecord.docImage != nil)
        {
            let data:Data = objRecord.docImage.jpegData(compressionQuality: 0.08)!
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
            let uploadDataCount:String = self.getArrayOfBytesFromImage(Docdata, splitCount: splitcount)
            let imagecount:Int = Docdata.count
            let Dict:[String:Any] = ["failure_status":"0","total_byte_count":"\(imagecount)","upload_byte_count":"0","upload_count":"1","upload_data_id":pathname,"upload_Path":Path,"upload_status":"0","user_common_id":user_common_id,"serverpath":"","user_id":Themes.sharedInstance.Getuser_id(),"data_count":uploadDataCount,"compressed_data":"\(CompressedImage)","to_id":to,"message_status":"0","timestamp":timestamp,"total_data_count":"\(splitcount)","width":"0.0","height":"0.0","upload_type":"6","download_status":"2","doc_name":objRecord.docName,"doc_type":objRecord.docType,"doc_pagecount":objRecord.docPageCount,"is_uploaded":"1", "upload_paused":"0"]
            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict as NSDictionary, Entityname: Constant.sharedinstance.Upload_Details);
            let param:NSDictionary = ["id":AssetName,"pathname":Path]
            completion(param, document_msg_id, document_doc_id, pathname)
        }
    }
    
    
    func returnCompressedData(_ objRecord : DocumentRecord, completion: @escaping (Data) -> ())
    {
        do
        {
            let Docdata = try Data(contentsOf: objRecord.docPath)
            
            //            if(objRecord.docPath.pathExtension.uppercased() == "PDF" && Docdata.count > Constant.sharedinstance.documentCompressionCount)
            //            {
            //                Themes.sharedInstance.setprogressinAlert(controller: self, progress: 1.0)
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
        DispatchQueue.main.async {
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
                    
                    print("\(pageRect.width) by \(pageRect.height)")
                    
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
        
        DispatchQueue.main.async {
            
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
    
    func getArrayOfBytesFromImage(_ imageData:Data,splitCount:Int)->String
    {
        var ConstantTotalByteCount:Int!
        let count = imageData.count / MemoryLayout<UInt8>.size
        ConstantTotalByteCount = count/splitCount
        return String(ConstantTotalByteCount)
    }
    
    func getdataFromURL(_ url : URL, completion: @escaping(_ data : Data?) -> ()) {
        DispatchQueue.main.async {
            do {
                let data = try Data(contentsOf: url)
                completion(data)
            }
            catch {
                print(error.localizedDescription)
                completion(nil)
            }
        }
    }
    
}

extension ShareViewController : ShareEditViewControllerDelegate {
    func EdittedImage(AssetArr: [MultimediaRecord], Status: String) {
        
        Themes.sharedInstance.showprogressAlert(controller: self)
        Themes.sharedInstance.setprogressinAlert(controller: self, progress: 0.0)
        _ = AssetArr.map {
            let index = (AssetArr as NSArray).index(of: $0)
            let ObjMultiMedia = $0
            let Chat_type = ObjMultiMedia.type
            if(!ObjMultiMedia.isVideo)
            {
                let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
                let to:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ObjMultiMedia.toID)
                let user_common_id = Themes.sharedInstance.CheckNullvalue(Passed_value: from + "-" + to)
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
                    ),"user_common_id":user_common_id,"message_from":"1","chat_type":Chat_type,"info_type":"0","created_by":from,"is_reply":"0","secret_msg_id":"","secret_timestamp":"", "date" : Themes.sharedInstance.getTimeStamp()]
                
                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: dic as NSDictionary,Entityname: Constant.sharedinstance.Chat_one_one)

                let chatarray:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: "\(from)-\(to)")
                if(!chatarray)
                {
                    let User_dict:[AnyHashable: Any] = ["user_common_id": "\(from)-\(to)","user_to_dp":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_type":Chat_type,"is_archived":"0","conv_id":"","timestamp":timestamp,"opponent_id":to,"is_read":"0","chat_count":"0"]
                    DatabaseHandler.sharedInstance.InserttoDatabase(Dict: User_dict as NSDictionary,Entityname: Constant.sharedinstance.Chat_intiated_details)
                    
                }
                else
                {
                    let User_dict:[AnyHashable: Any]=["timestamp":timestamp,"is_archived":"0","is_read":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_count":"0"]
                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: "\(from)-\(to)" , attribute: "user_common_id", UpdationElements: User_dict as NSDictionary?)
                }
                
            }
            else
            {
                
                let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
                let to:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ObjMultiMedia.toID)
                let user_common_id = Themes.sharedInstance.CheckNullvalue(Passed_value: from + "-" + to)
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
                    ),"user_common_id":user_common_id,"message_from":"1","chat_type":Chat_type,"info_type":"0","created_by":from,"is_reply":"0","secret_msg_id":"","secret_timestamp":"", "date" : Themes.sharedInstance.getTimeStamp()]
                
                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: dic as NSDictionary,Entityname: Constant.sharedinstance.Chat_one_one)

                let chatarray:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: "\(from)-\(to)")
                if(!chatarray)
                {
                    let User_dict:[AnyHashable: Any] = ["user_common_id": "\(from)-\(to)","user_to_dp":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_type":Chat_type,"is_archived":"0","conv_id":"","timestamp":timestamp,"opponent_id":to,"is_read":"0","chat_count":"0"]
                    DatabaseHandler.sharedInstance.InserttoDatabase(Dict: User_dict as NSDictionary,Entityname: Constant.sharedinstance.Chat_intiated_details)
                    
                }
                else
                {
                    let User_dict:[AnyHashable: Any]=["timestamp":timestamp,"is_archived":"0","is_read":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_count":"0"]
                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: "\(from)-\(to)" , attribute: "user_common_id", UpdationElements: User_dict as NSDictionary?)
                }
            }
            DispatchQueue.main.async {
                Themes.sharedInstance.setprogressinAlert(controller: self, progress: Float(index + 1) / Float(AssetArr.count))
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                self.notifyServer()
            })
        }
    }
}




