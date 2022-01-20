//
//  StarredViewController.swift
//
//
//  Created by MV Anand Casp iOS on 18/08/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

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

class StarredViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UUMessageCellDelegate,UUAVAudioPlayerDelegate, CustomTableViewCellDelegate, AudioManagerDelegate, MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate,CNContactViewControllerDelegate
{
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismissView(animated: true, completion: nil)
        var message = ""
        switch result {
        case .cancelled:
            message = "Message cancelled."
            break
        case .sent:
            message = "Message sent."
            break
        case .failed:
            message = "Message failed."
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
    
//    optional public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)

    
    
    
    @IBOutlet weak var chattableview: UITableView!
    @IBOutlet weak var no_doc_Lbl: UILabel!
    @IBOutlet weak var no_doc_View: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    var user_common_id:String = String()
    var isallStarredmessages:Bool = Bool()
    var chatModel:ChatModel=ChatModel()
    var chat_type:String = String()
    var opponent_id = String()
    var pause_row:NSInteger = NSInteger()
    var isNotContact:Bool = Bool()
    var initial = 0
    var is_chatPage_contact:Bool = false
    var isBeginEditing:Bool = Bool()
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    var audioPlayBtn : UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        no_doc_Lbl.text = "There are no tasks".localized()
        titleLbl.text = "Tasks".localized()
        addNotificationListener()
        no_doc_View.isHidden = true
        chattableview.tableFooterView = UIView()
        loadDatasource(isallStarredmessages: isallStarredmessages)
        chattableview.delegate = self
        chattableview.dataSource = self
        chattableview.rowHeight = UITableView.automaticDimension
        chattableview.estimatedRowHeight = 10
        chattableview.registerCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        PausePlayingAudioIfAny()
    }
    
    func loadDatasource(isallStarredmessages:Bool)
    {
        var predicate:NSCompoundPredicate!
        if(isallStarredmessages)
        {
            let p1 = NSPredicate(format: "user_id = %@", Themes.sharedInstance.Getuser_id())
            let p2 = NSPredicate(format: "chat_type = %@", "single")
            let p3 = NSPredicate(format: "chat_type = %@", "group")
            let compoundPredictae:NSCompoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [p2,p3])
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, compoundPredictae])
            var chatintiatedDetailArr=DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Chat_intiated_details, SortDescriptor: "timestamp", predicate: predicate,Limit:0) as! NSArray
            if(chatintiatedDetailArr.count > 0)
            {
                let descriptor: NSSortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
                chatintiatedDetailArr = chatintiatedDetailArr.sortedArray(using: [descriptor]) as NSArray
                for i in 0..<chatintiatedDetailArr.count
                {
                    let Reponse_Dict:NSManagedObject = chatintiatedDetailArr[i] as! NSManagedObject
                    
                    let user_common_id = Themes.sharedInstance.CheckNullvalue(Passed_value: Reponse_Dict.value(forKey: "user_common_id"))
                    let p4 = NSPredicate(format: "user_common_id == %@", user_common_id)
                    let p6 = NSPredicate(format: "isStar == 1")
                    let compoundpredicate2:NSCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p4,p6])
                    var ChatArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Chat_one_one, SortDescriptor: "timestamp", predicate: compoundpredicate2, Limit: 0) as! NSArray
                    if(ChatArr.count > 0)
                    {
                        let descriptor: NSSortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
                        ChatArr = ChatArr.sortedArray(using: [descriptor]) as NSArray
                        for i in 0 ..< ChatArr.count {
                            let ResponseDict = ChatArr[i] as! NSManagedObject
                            var dic:[AnyHashable: Any]!
                            let doc_id:String = ResponseDict.value(forKey: "doc_id") as! String
                            
                            var docPageCount:String = ""
                            var docName:String = ""
                            var docType:String = ""
                            
                            var Latitude:String = ""
                            var longitude:String = ""
                            var title_place:String = ""
                            var Stitle_place:String = ""
                            var image_link:String = ""
                            
                            var contact_id:String = ""
                            var contact_profile:String = ""
                            var contact_name:String = ""
                            var contact_phone:String = ""
                            var contact_details:String = ""
                            
                            var title:String = ""
                            var image_url:String = ""
                            var desc:String = ""
                            var url_str:String = ""
                            
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
                            
                            ChekLocation = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Location_details, attribute: "doc_id", FetchString: doc_id)
                            if(ChekLocation)
                            {
                                let LocationArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Location_details, attribute: "doc_id", FetchString: doc_id, SortDescriptor: nil) as! NSArray
                                for i in 0..<LocationArr.count
                                {
                                    let ObjRecord:NSManagedObject = LocationArr[i] as! NSManagedObject
                                    Latitude = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "lat"))
                                    longitude =  Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "long"))
                                    title_place = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "title"))
                                    Stitle_place = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "stitle"))
                                    image_link = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "image_link"))
                                    
                                }
                            }
                            
                            ChekLocation = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Contact_details, attribute: "doc_id", FetchString: doc_id)
                            
                            if(ChekLocation)
                            {
                                let ContactArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Contact_details, attribute: "doc_id", FetchString: doc_id, SortDescriptor: nil) as! NSArray
                                for i in 0..<ContactArr.count
                                {
                                    let ObjRecord:NSManagedObject = ContactArr[i] as! NSManagedObject
                                    contact_id = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "contact_id"))
                                    contact_profile =  Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "contact_profile"))
                                    contact_name = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "contact_name"))
                                    contact_phone = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "contact_phone"))
                                    contact_details = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "contact_details"))
                                }
                            }
                            
                            ChekLocation = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Link_details, attribute: "doc_id", FetchString: doc_id)
                            
                            if(ChekLocation)
                            {
                                let LocationArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Link_details, attribute: "doc_id", FetchString: doc_id, SortDescriptor: nil) as! NSArray
                                for i in 0..<LocationArr.count
                                {
                                    let ObjRecord:NSManagedObject = LocationArr[i] as! NSManagedObject
                                    title = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "title"))
                                    image_url =  Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "image_url"))
                                    desc = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "desc"))
                                    url_str = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "url_str"))
                                    
                                }
                            }
                            
                            dic  = ["type": Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "type")),"convId":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "convId")),"doc_id":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id")),"filesize":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "filesize")),"from":Themes.sharedInstance.CheckNullvalue(Passed_value:ResponseDict.value(forKey: "to")
                                ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:ResponseDict.value(forKey: "to")
                                ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "isStar")),"message_status":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "message_status")),"id":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "id")),"name":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "name")),"payload":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "payload"))
                                ,"recordId":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "recordId")),"thumbnail":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "thumbnail")),"width":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "width")),"height":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "height")),"msgId":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "msgId")),"contactmsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "contactmsisdn"))
                                ,"user_common_id":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "user_common_id"))
                                ,"timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "timestamp")),"message_from":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "message_from")),"info_type":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "info_type")),"chat_type":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "chat_type")), "docType":docType,"docName":docName,"docPageCount":docPageCount, "latitude":Latitude ,"longitude":longitude,"title_place":title_place,"Stitle_place":Stitle_place,"imagelink":image_link, "contact_id":contact_id,"contact_name":contact_name,"contact_phone":contact_phone,"contact_profile":contact_profile,"contact_details":contact_details, "title":title ,"image_url":image_url,"desc":desc,"url_str":url_str, "reply_type":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "reply_type"))]
                            
                            print(dic)
                            
                            self.dealTheFunctionData(dic)
                        }
                    }
                }
                if self.chatModel.dataSource.count > 0{
                chattableview.isHidden = false
                no_doc_View.isHidden = true
                }else {
                    chattableview.isHidden = true
                    no_doc_View.isHidden = false
                }
            }
            else
            {
                chattableview.isHidden = true
                no_doc_View.isHidden = false
            }
        }
        else
        {
            let p1:NSPredicate = NSPredicate(format: "user_common_id == %@", user_common_id)
            let p2:NSPredicate = NSPredicate(format: "isStar == %@", "1")
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1,p2])
            var ChatArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Chat_one_one, SortDescriptor: "timestamp", predicate: predicate, Limit: 0) as! NSArray
            if(ChatArr.count > 0)
            {
                let descriptor: NSSortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
                ChatArr = ChatArr.sortedArray(using: [descriptor]) as NSArray
                for i in 0 ..< ChatArr.count {
                    let ResponseDict = ChatArr[i] as! NSManagedObject
                    var dic:[AnyHashable: Any]
                    let doc_id:String = ResponseDict.value(forKey: "doc_id") as! String
                    
                    var docPageCount:String = ""
                    var docName:String = ""
                    var docType:String = ""
                    
                    var contact_id:String = ""
                    var contact_profile:String = ""
                    var contact_name:String = ""
                    var contact_phone:String = ""
                    var contact_details:String = ""
                    
                    var Latitude:String = ""
                    var longitude:String = ""
                    var title_place:String = ""
                    var Stitle_place:String = ""
                    var image_link:String = ""
                    
                    var title:String = ""
                    var image_url:String = ""
                    var desc:String = ""
                    var url_str:String = ""
                    
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
                    
                    ChekLocation = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Contact_details, attribute: "doc_id", FetchString: doc_id)
                    
                    if(ChekLocation)
                    {
                        let ContactArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Contact_details, attribute: "doc_id", FetchString: doc_id, SortDescriptor: nil) as! NSArray
                        for i in 0..<ContactArr.count
                        {
                            let ObjRecord:NSManagedObject = ContactArr[i] as! NSManagedObject
                            contact_id = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "contact_id"))
                            contact_profile =  Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "contact_profile"))
                            contact_name = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "contact_name"))
                            contact_phone = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "contact_phone"))
                            contact_details = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "contact_details"))
                        }
                    }
                    
                    ChekLocation = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Location_details, attribute: "doc_id", FetchString: doc_id)
                    if(ChekLocation)
                    {
                        let LocationArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Location_details, attribute: "doc_id", FetchString: doc_id, SortDescriptor: nil) as! NSArray
                        for i in 0..<LocationArr.count
                        {
                            let ObjRecord:NSManagedObject = LocationArr[i] as! NSManagedObject
                            Latitude = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "lat"))
                            longitude =  Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "long"))
                            title_place = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "title"))
                            Stitle_place = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "stitle"))
                            image_link = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "image_link"))
                            
                        }
                    }
                    
                    ChekLocation = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Link_details, attribute: "doc_id", FetchString: doc_id)
                    
                    if(ChekLocation)
                    {
                        let LocationArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Link_details, attribute: "doc_id", FetchString: doc_id, SortDescriptor: nil) as! NSArray
                        for i in 0..<LocationArr.count
                        {
                            let ObjRecord:NSManagedObject = LocationArr[i] as! NSManagedObject
                            title = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "title"))
                            image_url =  Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "image_url"))
                            desc = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "desc"))
                            url_str = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "url_str"))
                            
                        }
                    }
                    
                    dic  = ["type": Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "type")),"convId":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "convId")),"doc_id":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id")),"filesize":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "filesize")),"from":Themes.sharedInstance.CheckNullvalue(Passed_value:ResponseDict.value(forKey: "to")
                        ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:ResponseDict.value(forKey: "to")
                        ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "isStar")),"message_status":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "message_status")),"id":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "id")),"name":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "name")),"payload":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "payload"))
                        ,"recordId":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "recordId")),"thumbnail":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "thumbnail")),"width":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "width")),"height":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "height")),"msgId":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "msgId")),"contactmsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "contactmsisdn"))
                        ,"user_common_id":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "user_common_id"))
                        ,"timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "timestamp")),"message_from":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "message_from")),"info_type":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "info_type")),"chat_type":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "chat_type")), "docType":docType,"docName":docName,"docPageCount":docPageCount, "contact_id":contact_id,"contact_name":contact_name,"contact_phone":contact_phone,"contact_profile":contact_profile,"contact_details":contact_details,"latitude":Latitude ,"longitude":longitude,"title_place":title_place,"Stitle_place":Stitle_place,"imagelink":image_link,"title":title ,"image_url":image_url,"desc":desc,"url_str":url_str, "reply_type":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "reply_type"))]
                    
                    self.dealTheFunctionData(dic)
                }
                chattableview.isHidden = false
                no_doc_View.isHidden = true
            }
            else
            {
                chattableview.isHidden = true
                no_doc_View.isHidden = false
                
            }
            
            
            
            //            let checkMessages
        }
    }
    func PasReplyDetail(index:IndexPath,ReplyRecordID:String, isStatus: Bool)
    {
        
    }
    
    func PasPersonDetail(id: String) {
        let singleInfoVC:SingleInfoViewController=self.storyboard?.instantiateViewController(withIdentifier: "SingleInfoViewController") as! SingleInfoViewController
        singleInfoVC.user_id = Themes.sharedInstance.CheckNullvalue(Passed_value: id)
        self.pushView(singleInfoVC, animated: true)
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
    func dealTheFunctionData(_ dic: [AnyHashable: Any]) {
        self.chatModel.addSpecifiedItem(dic, isPagination: false)
        self.chattableview.reloadData()
    }
    @IBAction func DidclickBack(_ sender: Any) {
        self.pop(animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- cell and audio delegate
    
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
    
    func contactBtnTapped(sender: UIButton) {
        
        let row = sender.tag
        let indexpath = NSIndexPath.init(row: 0, section: row)
        
        let cellItem:CustomTableViewCell? = chattableview.cellForRow(at: indexpath as IndexPath) as? CustomTableViewCell
        guard let userId = (cellItem?.messageFrame.message.contact_id) else{return}
        SetData(user_id: userId)
        if(sender.titleLabel?.text == contactTitle.msg.rawValue){
            
            if(isNotContact == true){
                if(Themes.sharedInstance.isChatLocked(id: userId, type: "single"))
                {
                    Themes.sharedInstance.enterTochat(id: userId, type: "single") { (success) in
                        if(success)
                        {
                            let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                            ObjInitiateChatViewController.Chat_type="single"
                            ObjInitiateChatViewController.opponent_id = userId
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
                    ObjInitiateChatViewController.opponent_id = userId
                    ObjInitiateChatViewController.goBack = true
                    isNotContact = false
                    self.pushView(ObjInitiateChatViewController, animated: true)
                }
            }else{
                let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                ObjInitiateChatViewController.Chat_type="single"
                ObjInitiateChatViewController.opponent_id = userId
                ObjInitiateChatViewController.goBack = true
                self.pushView(ObjInitiateChatViewController, animated: true)
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
            let CancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "comment"), style: .cancel) { action -> Void in
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
    
    func saveTarget(sender: UIButton) {
        let row = sender.tag
        let indexpath = NSIndexPath.init(row: 0, section: row)
        let cellItem:CustomTableViewCell = (chattableview.cellForRow(at: indexpath as IndexPath) as? CustomTableViewCell)!
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
            let phone_number:NSArray = jsonResult.value(forKey: "phone_number") as! NSArray
            _ = phone_number.map {
                let i = phone_number.index(of: $0)
                let get_value:NSDictionary = phone_number[i] as! NSDictionary
                let type = get_value.value(forKey:"type") as! String
                let value_ph = get_value.value(forKey:"value") as! String
                let values = CNLabeledValue(label:type , value:CNPhoneNumber(stringValue:value_ph))
                phone_num.append(values)
            }
            let email_arr:NSArray = jsonResult.value(forKey: "email") as! NSArray
            _ = email_arr.map {
                let i = email_arr.index(of: $0)
                let get_value:NSDictionary = email_arr[i] as! NSDictionary
                let type = get_value.value(forKey:"type") as! String
                let value_ph = get_value.value(forKey:"value") as! String
                let values = CNLabeledValue(label:type , value:value_ph as NSString)
                email.append(values)
            }
            let address_arr:NSArray = jsonResult.value(forKey: "address") as! NSArray
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
    
    func SetData(user_id:String)
    {
        
        let Checkuser:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "id", FetchString: user_id)
        if(!Checkuser)
        {
            isNotContact = true
        }
    }
    
    func playPauseTapped(sender: UIButton) {
        audioPlayBtn = sender
        let row:Int = sender.tag
        pause_row = row
        initial = 1
        guard self.chatModel.dataSource.count > row else{return}
        self.PausePlayingAudioIfAny()
        let indexpath = NSIndexPath.init(row: 0, section: row)
        
        if let cellItem:CustomTableViewCell = chattableview.cellForRow(at: indexpath as IndexPath) as? CustomTableViewCell {
            AudioManager.sharedInstence.delegate = self
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
        let indexpath = IndexPath(row: 0, section: row)
        guard let audioIndex = AudioManager.sharedInstence.currentIndex else{return}
        guard indexpath == audioIndex else{return}
        AudioManager.sharedInstence.playbackSliderValueChanged(slider, event: event)
        guard self.chatModel.dataSource.count > indexpath.row else{return}
        guard let previousCell:CustomTableViewCell = chattableview.cellForRow(at: indexpath) as? CustomTableViewCell else{return}
        guard let audioCell = previousCell as? AudioTableViewCell else{return}
        audioCell.playPauseButton.isSelected = event == .editingDidEnd ? true : false
    }
    
    func readMorePressed(sender: UIButton, count: String) {
        let row:Int = (sender as AnyObject).tag
        pause_row = row
        initial = 1
        guard self.chatModel.dataSource.count > row else{return}
        let messageFrame: UUMessageFrame = self.chatModel.dataSource[row] as! UUMessageFrame
        messageFrame.message.readmore_count = count
        let indexpath = IndexPath(row: 0, section: row)
        self.chattableview.reloadRows(at: [indexpath], with: .none)
    }
    
    func forwordPressed(_ sender: UIButton) {
        guard !isBeginEditing else{return}
        let row:Int = (sender as AnyObject).tag
        guard self.chatModel.dataSource.count > row else{return }
        let indexpath = IndexPath(row: 0, section: row)
        moveToShareContactVC([indexpath])
        
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
    
    func updateSlider(value: Float) {
        print("slider duration \(value)")
        guard let index = AudioManager.sharedInstence.currentIndex else{return}
        guard self.chatModel.dataSource.count > index.row else{return}
        guard let currentCell:CustomTableViewCell = chattableview.cellForRow(at: index) as? CustomTableViewCell else{return}
        guard let currentAudioCell = currentCell as? AudioTableViewCell else{return}
        UIView.animate(withDuration: 0.3) {
            currentAudioCell.audioSlider.setValue(value, animated: true)
        }
    }
    
    func updateDuration(value: String, at indexPath: IndexPath) {
        guard let index = AudioManager.sharedInstence.currentIndex else{return}
        guard self.chatModel.dataSource.count > index.row else{return}
        guard let currentCell:CustomTableViewCell = chattableview.cellForRow(at: index) as? CustomTableViewCell else{return}
        guard let currentAudioCell = currentCell as? AudioTableViewCell else{return}
        currentAudioCell.audioDuration.text = value
        
    }
    
    func playerCompleted() {
        guard let index = AudioManager.sharedInstence.currentIndex else{return}
        guard self.chatModel.dataSource.count > index.row else{return}
        guard let previousCell:CustomTableViewCell = chattableview.cellForRow(at: index) as? CustomTableViewCell else{return}
        guard let preAudioCell = previousCell as? AudioTableViewCell else{return}
        preAudioCell.playPauseButton.isSelected = false
        preAudioCell.audioSlider.value = 0
        print("Completed")
    }
    
    @IBAction func messageContact(sender:UIButton){
        
        let row = sender.tag
        let indexpath = NSIndexPath.init(row: 0, section: row)
        
        let cellItem:UUMessageCell? = chattableview.cellForRow(at: indexpath as IndexPath) as? UUMessageCell
        guard let userId = (cellItem?.messageFrame.message.contact_id) else{return}
        SetData(user_id: userId)
        if(cellItem?.send_message == true){
            if(isNotContact == true){
                if(Themes.sharedInstance.isChatLocked(id: userId, type: "single"))
                {
                    Themes.sharedInstance.enterTochat(id: userId, type: "single") { (success) in
                        if(success)
                        {
                            let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                            ObjInitiateChatViewController.Chat_type="single"
                            ObjInitiateChatViewController.opponent_id = userId
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
                    ObjInitiateChatViewController.opponent_id = userId
                    ObjInitiateChatViewController.goBack = true
                    isNotContact = false
                    self.pushView(ObjInitiateChatViewController, animated: true)
                }
            }else{
                if(Themes.sharedInstance.isChatLocked(id: userId, type: "single"))
                {
                    Themes.sharedInstance.enterTochat(id: userId, type: "single") { (success) in
                        if(success)
                        {
                            let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                            ObjInitiateChatViewController.Chat_type="single"
                            ObjInitiateChatViewController.opponent_id = userId
                            ObjInitiateChatViewController.goBack = true
                            self.pushView(ObjInitiateChatViewController, animated: true)
                        }
                    }
                }
                else{
                    let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                    ObjInitiateChatViewController.Chat_type="single"
                    ObjInitiateChatViewController.opponent_id = userId
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
            let CancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "comment"), style: .cancel) { action -> Void in
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = Bundle.main.loadNibNamed("MessageDetailHeaderView", owner: self, options: nil)?[0] as? MessageDetailHeaderView
        let messageFrame: UUMessageFrame = self.chatModel.dataSource[section] as! UUMessageFrame
        view?.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40)
        view?.clipsToBounds = true
        let opponent:FavRecord=FavRecord()
        opponent.id = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_one_one, attrib_name: "id", fetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message._id), returnStr: "from")

        view?.name_lbl.setNameTxt(opponent.id, "single")
        if(Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message.chat_type) == "group")
        {
            let groupName = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Group_details, attrib_name: "id", fetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message.conv_id), returnStr: "displayName")
            view?.name_lbl.text = Themes.sharedInstance.CheckNullvalue(Passed_value: view?.name_lbl.text) + " • " + groupName
        }
        view?.profile_img.setProfilePic(opponent.id, "single")
        view?.date_lbl.text = Themes.sharedInstance.ReturnDateTimeFormat(timestamp: messageFrame.message.timestamp)
        view?.profile_img.layer.cornerRadius =  (view?.profile_img.frame.size.width)!/2
        view?.profile_img.clipsToBounds = true
        return view
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40;
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5;
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let View:UIView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 5))
        let label:UILabel = UILabel(frame: CGRect(x: 40, y: 0, width: tableView.frame.size.width-40, height: 1))
        label.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        View.addSubview(label)
        return View
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.chatModel.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    fileprivate func presentPlayer(_ videoURL: URL?, _ cellItem: CustomTableViewCell) {
        let player = AVPlayer(url: videoURL! )
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        (cellItem.delegate as! UIViewController).presentView(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
    func pauseGif()
    {
        let indexpath = NSIndexPath.init(row: 0, section: pause_row)
        if let cellItem:CustomTableViewCell = chattableview.cellForRow(at: indexpath as IndexPath) as? CustomTableViewCell {
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
        guard !isBeginEditing else{return}
        if(pause_row != sender.tag)
        {
            self.pauseGif()
        }
        let row : Int = sender.tag
        pause_row = row
        initial = 1
        guard self.chatModel.dataSource.count > row else{return}
        let messageFrame: UUMessageFrame = self.chatModel.dataSource[row] as! UUMessageFrame
        self.PausePlayingAudioIfAny()
        let indexpath = NSIndexPath.init(row: 0, section: row)
        
        if let cellItem:CustomTableViewCell = chattableview.cellForRow(at: indexpath as IndexPath) as? CustomTableViewCell {
            print(cellItem.messageFrame.message.type)
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
                self.presentView(ImageViewerController(configuration: configuration), animated: true)
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
                    presentPlayer(videoURL, cellItem)
                    
                }
                else
                {
                    if download_status == "0"{
                        DownloadHandler.sharedinstance.handleDownLoad(true)
                    }
                    
                    if(serverpath != "")
                    {
                        let videoURL = URL(string: Themes.sharedInstance.getDownloadURL(serverpath))
                        presentPlayer(videoURL, cellItem)
                    }
                }
                break
            case MessageType(rawValue: 4):
                guard var urlString = messageFrame.message.payload else{return}
                if !(urlString.contains("https://")){
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
                let index = IndexPath(row: 0, section: row)
                PasReplyDetail(index:index,ReplyRecordID:recordId, isStatus : isFromStatus)
                break
                
            case MessageType(rawValue:14):
                let s = storyboard?.instantiateViewController(withIdentifier:"OnCellClickViewController" ) as! OnCellClickViewController
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
    
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell_main : UITableViewCell = UITableViewCell()
        if(tableView == chattableview)
        {
            let messageFrame: UUMessageFrame = self.chatModel.dataSource[indexPath.section] as! UUMessageFrame
            if(messageFrame.message.info_type == "0")
            {
                
                let cell1 = TableviewCellGenerator.sharedInstance.returnCell(for: tableView, messageFrame: messageFrame, indexPath: indexPath)
                cell1.tble = tableView
                cell1.indexPath = indexPath
                cell1.delegate = self
                cell1.RowIndex = IndexPath(row: indexPath.section, section: 0)
                cell1.customButton.addTarget(self, action: #selector(self.didClickCellButton(_:)), for: .touchUpInside)
                cell_main = cell1
            }
        }
        return cell_main
    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if(tableView == chattableview)
//        {
//            
//            let messageFrame: UUMessageFrame = self.chatModel.dataSource[indexPath.section] as! UUMessageFrame
//            print("the type is \(messageFrame.message.info_type)...\(messageFrame.message.payload)")
//            var messageheight:CGFloat=CGFloat()
//            if(messageFrame.message.info_type == "0")
//            {
//                if(messageFrame.message.type == MessageType(rawValue: 0) || messageFrame.message.type == MessageType(rawValue: 7) || messageFrame.message.type == MessageType(rawValue: 14))
//                {
//                    if(indexPath.section+1 <= self.chatModel.dataSource.count-1)
//                    {
//                        let CheckmessageFrame: UUMessageFrame = self.chatModel.dataSource[indexPath.section+1] as! UUMessageFrame
//                        if(messageFrame.message.from != CheckmessageFrame.message.from)
//                        {
//                            messageheight = messageFrame.message.messageheight+4
//                        }
//                        else
//                        {
//                            messageheight = messageFrame.message.messageheight-4
//                        }
//                    }
//                    else
//                    {
//                        messageheight = messageFrame.message.messageheight-4
//                    }
//                    return messageheight+18
//                }
//                    
//                else if(messageFrame.message.type == MessageType(rawValue: 1))
//                {
//                    messageheight = 200-4
//                    return messageheight+18
//                }
//                    
//                else if(messageFrame.message.type == MessageType(rawValue: 2))
//                {
//                    messageheight = 200-4
//                    return messageheight+18
//                }else if(messageFrame.message.type == MessageType(rawValue: 4))
//                {
//                    messageheight = messageFrame.message.messageheight
//                    
//                    return messageheight
//                }
//                    
//                    
//                else if(messageFrame.message.type == MessageType(rawValue: 3))
//                {
//                    messageheight = 100-4
//                    return messageheight+30
//                }else if(messageFrame.message.type == MessageType(rawValue: 5)){
//                    let mob_no:String = Themes.sharedInstance.GetMyPhonenumber()
//                    let user_mob:String = mob_no.substring(from: mob_no.index(mob_no.endIndex, offsetBy: -10))
//                    if(messageFrame.message.contact_phone == user_mob){
//                        messageheight = 90-4
//                    }else{
//                        messageheight = 120-4
//                    }
//                    return messageheight+30
//                }
//                    
//                else if(messageFrame.message.type == MessageType(rawValue: 6))
//                {
//                    return messageFrame.message.messageheight+35
//                }
//            }
//            return 32
//            
//        }
//        else
//        {
//            return 50
//            
//        }
//    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        let messageFrame: UUMessageFrame = self.chatModel.dataSource[indexPath.section] as! UUMessageFrame
        if(Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message.chat_type) == "single"){
            
            let opponent:FavRecord=FavRecord()
            
            opponent.id = opponent_id
            
            if(opponent.id == ""){
                opponent.id = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_one_one, attrib_name: "id", fetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message._id), returnStr: "from")
                if(opponent.id == Themes.sharedInstance.Getuser_id()) {
                    opponent.id = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_one_one, attrib_name: "id", fetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message._id), returnStr: "to")
                }
            }
            if(Themes.sharedInstance.isChatLocked(id: opponent.id, type: "single"))
            {
                Themes.sharedInstance.enterTochat(id: opponent.id, type: "single") { (success) in
                    if(success)
                    {
                        let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                        ObjInitiateChatViewController.Chat_type="single"
                        ObjInitiateChatViewController.opponent_id = opponent.id
                        ObjInitiateChatViewController.from_search_msg = true
                        ObjInitiateChatViewController.from_search_msg_id = messageFrame.message.timestamp
                        self.pushView(ObjInitiateChatViewController, animated: true)
                    }
                }
            }
            else
            {
                let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                ObjInitiateChatViewController.Chat_type="single"
                ObjInitiateChatViewController.opponent_id = opponent.id
                ObjInitiateChatViewController.from_search_msg = true
                ObjInitiateChatViewController.from_search_msg_id = messageFrame.message.timestamp
                self.pushView(ObjInitiateChatViewController, animated: true)
            }
            
        }else{
            let opponent:FavRecord=FavRecord()
            opponent.id = opponent_id
            
            if(opponent.id == ""){
                opponent.id = messageFrame.message.conv_id
            }
            if(Themes.sharedInstance.isChatLocked(id: opponent.id, type: "group"))
            {
                Themes.sharedInstance.enterTochat(id: opponent.id, type: "group") { (success) in
                    if(success)
                    {
                        let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                        ObjInitiateChatViewController.Chat_type="group"
                        ObjInitiateChatViewController.from_search_msg = true
                        ObjInitiateChatViewController.from_search_msg_id = messageFrame.message.timestamp
                        ObjInitiateChatViewController.opponent_id = opponent.id
                        self.pushView(ObjInitiateChatViewController, animated: true)
                    }
                }
            }
            else
            {
                let ObjInitiateChatViewController:InitiateChatViewController=self.storyboard?.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                ObjInitiateChatViewController.Chat_type="group"
                ObjInitiateChatViewController.from_search_msg = true
                ObjInitiateChatViewController.from_search_msg_id = messageFrame.message.timestamp
                ObjInitiateChatViewController.opponent_id = opponent.id
                self.pushView(ObjInitiateChatViewController, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        
        
        
        
    }
    
    func headImageDidClick(_ cell: UUMessageCell, userId: String)
    {
        
    }
    
    func cellContentDidClick(_ cell: UUMessageCell, image contentImage: UIImage)
    {
        
    }
    
    func playerTime(_ TotalDuration: Double, currentime CurrentTime: Double) {
        
        let indexpath = NSIndexPath.init(row:0 , section: pause_row)
        
        let cellItem:UUMessageCell? = chattableview.cellForRow(at: indexpath as IndexPath) as? UUMessageCell
        if(cellItem != nil)
        {
            cellItem?.total = TotalDuration
            //self.messageFrame.message.progress = "\(CurrentTime)"
            
            cellItem?.btnContent.myProgressView.maximumValue = Float(TotalDuration)
            
            let precentage:CGFloat = CGFloat(((100.0*Double(CurrentTime))/Double(TotalDuration))/100.0);
            
            print("jjjjj","\(precentage):\(CurrentTime):\(TotalDuration)")
            //&& !slidePlay
            if(!(cellItem?.slideMove)!){
                
                let min = CurrentTime/60;
                let sec = CurrentTime.truncatingRemainder(dividingBy: 60) ;
                cellItem?.btnContent.second.text = String(format: "%02d:%02d", Int(min),Int(sec))
                //                print("current",cellItem?.audio.player.currentTime)
                cellItem?.audio.player.currentTime = CurrentTime
                cellItem?.messageFrame.message.progress = "\(CurrentTime)"
                
                if(CurrentTime == 0.0){
                    
                    let min = TotalDuration/60;
                    let sec = TotalDuration.truncatingRemainder(dividingBy: 60) ;
                    cellItem?.btnContent.second.text = String(format: "%02d:%02d", Int(min),Int(sec))
                    
                }
                
                cellItem?.btnContent.myProgressView.value = Float(CurrentTime)
                
            }
            
            //print("sss",cellItem?.messageFrame.message.progress!!)
        }
        
    }
    
    func uuavAudioPlayerBeiginPlay()
    {
        let indexpath = NSIndexPath.init(row:0 , section: pause_row)
        
        let cellItem:UUMessageCell? = chattableview.cellForRow(at: indexpath as IndexPath) as? UUMessageCell
        if(cellItem != nil){
            UIDevice.current.isProximityMonitoringEnabled = true
            print("\(UUAVAudioPlayer.sharedInstance().player.currentTime)")
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
            self.chattableview.reloadRows(at: [index], with: .none)
        }
    }
    
    
    func uuavAudioPlayerDidFinishPlay(_ Ispause: Bool) {
        let indexpath = NSIndexPath.init(row:0 , section: pause_row)
        //        cellForRow(at: indexpath as IndexPath) as! UUMessageCell
        let cellItem:UUMessageCell? = chattableview.cellForRow(at: indexpath as IndexPath) as? UUMessageCell
        if(cellItem != nil){
            cellItem?.is_paused = false
            if(!Ispause)
            {
                // finish playing
                UIDevice.current.isProximityMonitoringEnabled = false
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
        
        let indexpath = NSIndexPath.init(row:0 , section: pause_row)
        
        let cellItem:UUMessageCell? = chattableview.cellForRow(at: indexpath as IndexPath) as? UUMessageCell
        if (cellItem != nil){
            cellItem?.btnContent.benginLoadVoice()
        }
        
        
    }
    @IBAction func btnContentClick(_ sender: Any)
    {
        //check each cell with audio and whether it is playing , then stop
        
        let row: NSInteger = (sender as AnyObject).tag
        
        pause_row = row
        initial = 1
        self.PausePlayingAudioIfAny()
        
        let indexpath = NSIndexPath.init(row: 0, section: row)
        
        let cellItem:UUMessageCell? = chattableview.cellForRow(at: indexpath as IndexPath) as? UUMessageCell
        
        if(cellItem != nil){
            if (cellItem?.messageFrame.message.type == MessageType(rawValue: 3)!) {
                
                //                print("jbhhhh",cellItem?.messageFrame.message.progress)
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
                                print("the time is \(String(describing: cellItem?.messageFrame.message.progress))")
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
                            
                            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Upload_Details, FetchString: cellItem!.messageFrame.message.thumbnail!, attribute: "upload_data_id", UpdationElements: ["download_status" : "0"])
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
                }
            }
            else if cellItem?.messageFrame.message.type == MessageType(rawValue: 1)! {
                
                if (cellItem?.btnContent.backImageView != nil)
                {
                    let configuration = ImageViewerConfiguration { config in
                        config.imageView = cellItem?.btnContent.backImageView
                    }
                    self.presentView(ImageViewerController(configuration: configuration), animated: true)
                    
                    //                    UUImageAvatarBrowser.showImage(cellItem?.btnContent.backImageView,orgimage: nil)
                }
                
                if (cellItem?.delegate is UIViewController) {
                    
                    (cellItem?.delegate as! UIViewController).view.endEditing(true)
                    
                }
            }
                
            else if cellItem?.messageFrame.message.type == MessageType(rawValue: 0)! {
                
                cellItem?.btnContent.becomeFirstResponder()
                let menu = UIMenuController.shared
                menu.setTargetRect((cellItem?.btnContent.frame)!, in: (cellItem?.btnContent.superview!)!)
                menu.setMenuVisible(true, animated: true)
                
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
    
    func DidclickContentBtn(messagFrame: UUMessageFrame) {
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
    
    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        let chat_Obj:UUMessageFrame = self.chatModel.dataSource[indexPath.section] as! UUMessageFrame
        if(chat_Obj.message.info_type == "1")
        {
            return false
        }
        else
        {
            var StarString:String = ""
            if(chat_Obj.message.isStar == "1")
            {
                StarString = "★"
            }
            else
            {
                StarString = "☆"
            }
            if(chat_Obj.message.from == MessageFrom(rawValue: 1))
            {
                let customMenuItem = UIMenuItem(title: StarString, action:
                    #selector(UUMessageCell.StarActionTapped(sender:)))
                let customMenuItem3 = UIMenuItem(title: "Forward", action:
                    #selector(UUMessageCell.ForwardActionTapped(sender:)))
                let customMenuItem4 = UIMenuItem(title: "Copy", action:
                    #selector(UUMessageCell.CopyMessageActionTapped(sender:)))
                let customMenuItem6 = UIMenuItem(title: "Delete", action:
                    #selector(UUMessageCell.deleteMessageActionTapped(sender:)))
                UIMenuController.shared.menuItems = [customMenuItem,customMenuItem3,customMenuItem4,customMenuItem6]
                if(chat_Obj.message.payload != "")
                {
                    return action == #selector(UUMessageCell.StarActionTapped(sender:)) ||  action == #selector(UUMessageCell.deleteMessageActionTapped(sender:)) || action == #selector(UUMessageCell.CopyMessageActionTapped(sender:)) || action == #selector(UUMessageCell.ForwardActionTapped(sender:)) || action == #selector(UUMessageCell.ReplyActionTapped(sender:)) || action == #selector(UUMessageCell.InfoActionTapped(sender:))
                }
                else
                {
                    return action == #selector(UUMessageCell.StarActionTapped(sender:)) ||  action == #selector(UUMessageCell.deleteMessageActionTapped(sender:)) || action == #selector(UUMessageCell.ForwardActionTapped(sender:)) || action == #selector(UUMessageCell.ReplyActionTapped(sender:)) || action == #selector(UUMessageCell.InfoActionTapped(sender:))
                    
                }
                
            }
            else
            {
                let customMenuItem = UIMenuItem(title: StarString, action:
                    #selector(UUMessageCell.StarActionTapped(sender:)))
                let customMenuItem3 = UIMenuItem(title: "Forward", action:
                    #selector(UUMessageCell.ForwardActionTapped(sender:)))
                let customMenuItem4 = UIMenuItem(title: "Copy", action:
                    #selector(UUMessageCell.CopyMessageActionTapped(sender:)))
                let customMenuItem6 = UIMenuItem(title: "Delete", action:
                    #selector(UUMessageCell.deleteMessageActionTapped(sender:)))
                UIMenuController.shared.menuItems = [customMenuItem,customMenuItem3,customMenuItem4,customMenuItem6]
                if(chat_Obj.message.payload != "")
                {
                    return action == #selector(UUMessageCell.StarActionTapped(sender:)) ||  action == #selector(UUMessageCell.deleteMessageActionTapped(sender:)) || action == #selector(UUMessageCell.CopyMessageActionTapped(sender:)) || action == #selector(UUMessageCell.ForwardActionTapped(sender:)) || action == #selector(UUMessageCell.ReplyActionTapped(sender:))
                    
                }
                else
                {
                    return action == #selector(UUMessageCell.StarActionTapped(sender:)) ||  action == #selector(UUMessageCell.deleteMessageActionTapped(sender:)) || action == #selector(UUMessageCell.ForwardActionTapped(sender:)) || action == #selector(UUMessageCell.ReplyActionTapped(sender:))
                }
                
            }
        }
        //        return true
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?)
    {
        
        
        
    }
    
    func Removechat(type:String,convId:String,status:String,recordId:String,last_msg:String)
    {
        let param:NSDictionary = ["from":Themes.sharedInstance.Getuser_id(),"convId":convId,"status":status,"recordId":recordId,"last_msg":last_msg, "type" : type]
        SocketIOManager.sharedInstance.EmitDeletedetails(Dict: param)
    }
    func DidClickMenuAction(actioname: MenuAcion, index: IndexPath)
    {
        let index:IndexPath = IndexPath(row: 0, section: index.row)
        self.view.endEditing(true)
        let chat_Obj:UUMessageFrame = self.chatModel.dataSource[index.section] as! UUMessageFrame
        
        if(actioname == .delete)
        {
            let DeleteMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
            let DeleteAct = UIAlertAction(title: "Delete Chat", style: .destructive, handler: {
                (alert: UIAlertAction!) -> Void in
                self.DeleteChat(chat_Obj: chat_Obj, index: index)
            })
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "comment"), style: .cancel, handler: {
                (alert: UIAlertAction!) -> Void in
                print("Cancelled")
            })
            
            DeleteMenu.addAction(DeleteAct)
            DeleteMenu.addAction(cancelAction)
            self.presentView(DeleteMenu, animated: true, completion: nil)
        }
        else if(actioname == .Reply)
        {
            
        }
        else  if(actioname == .Forward)
        {
            let Chat_arr:NSMutableArray = NSMutableArray()
            Chat_arr.add(chat_Obj)
            let selectShareVC = storyboard?.instantiateViewController(withIdentifier:"SelectShareContactViewController" ) as! SelectShareContactViewController
            selectShareVC.messageDatasourceArr =  Chat_arr
            selectShareVC.isFromForward = true
            self.pushView(selectShareVC, animated: true)
        }
        else  if(actioname == .star)
        {
            if(chat_Obj.message.isStar == "1")
            {
                chat_Obj.message.isStar = "0"
                self.StarMessage(status: "0", DocId: chat_Obj.message.doc_id,convId:chat_Obj.message.conv_id,recordId:chat_Obj.message.recordId,chat_type:chat_Obj.message.chat_type  )
            }
            else
            {
                chat_Obj.message.isStar = "1"
                self.StarMessage(status: "1", DocId: chat_Obj.message.doc_id,convId:chat_Obj.message.conv_id,recordId:chat_Obj.message.recordId,chat_type:chat_Obj.message.chat_type )
            }
            self.chatModel.dataSource.removeObject(at: index.section)
            let indexSet = NSMutableIndexSet()
            indexSet.add(index.section)
            chattableview.deleteSections(indexSet as IndexSet, with: .fade)
        }
        else if(actioname == .copy)
        {
            UIPasteboard.general.string = chat_Obj.message.payload
        }
    }
    func DeleteChat(chat_Obj:UUMessageFrame,index:IndexPath)
    {
        let chatobj:UUMessageFrame = chat_Obj
        self.Removechat(type: chat_Obj.message.chat_type, convId: chatobj.message.conv_id, status: "1", recordId: chatobj.message.recordId, last_msg: "1")
        
        if(chatobj.message.message_type == "0" || chatobj.message.message_type == "4" || chatobj.message.message_type == "5" || chatobj.message.message_type == "14" || chatobj.message.message_type == "11")
        {
            let p1 = NSPredicate(format: "id = %@", chatobj.message._id)
            DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Chat_one_one, Predicatefromat: p1, Deletestring: "id", AttributeName: "id")
            self.chatModel.dataSource.removeObject(at: index.section)
        }
        else
        {
            let p1 = NSPredicate(format: "id = %@", chatobj.message._id)
            DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Chat_one_one, Predicatefromat: p1, Deletestring: "id", AttributeName: "id")
            let predic = NSPredicate(format: "upload_data_id == %@",chatobj.message.thumbnail)
            
            let uploadDetailArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Upload_Details, attribute: "upload_data_id", FetchString: chatobj.message.thumbnail, SortDescriptor: nil) as! NSArray
            if(uploadDetailArr.count > 0)
            {
                for i in 0..<uploadDetailArr.count
                {
                    let uploadDict:NSManagedObject = uploadDetailArr[i] as! NSManagedObject
                    
                    let upload_Path:String = Themes.sharedInstance.CheckNullvalue(Passed_value: uploadDict.value(forKey: "upload_Path"))
                    Filemanager.sharedinstance.DeleteFile(foldername: upload_Path)
                }
                DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Upload_Details, Predicatefromat: predic, Deletestring: "chatobj.message.thumbnail", AttributeName: "id")
            }
            self.chatModel.dataSource.removeObject(at: index.section)
        }
        let indexSet = NSMutableIndexSet()
        indexSet.add(index.section)
        chattableview.deleteSections(indexSet as IndexSet, with: .fade)
        chattableview.reloadData()
    }
    
    func StarMessage(status:String,DocId:String,convId:String,recordId:String,chat_type:String)
    {
        let checkmsg:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "doc_id", FetchString: DocId)
        if(checkmsg)
        {
            let param:NSDictionary = ["isStar":status]
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_one_one, FetchString: DocId, attribute: "doc_id", UpdationElements: param)
            let Emitparam:NSDictionary = ["from":Themes.sharedInstance.Getuser_id(),"status":status,"type":chat_type,"doc_id":DocId,"convId":convId,"recordId":recordId]
            SocketIOManager.sharedInstance.EmitStarMessagedetails(Dict: Emitparam)
        }
    }
    func sliderValueChanged(slider:UISlider)
    {
        print(slider.value)
        let row = slider.tag
        let indexpath = NSIndexPath.init(row:0 , section: row)
        let cellItem:UUMessageCell? = chattableview.cellForRow(at: indexpath as IndexPath) as? UUMessageCell
        if(cellItem != nil){
            if(self.pause_row == row){
                print(row)
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
                    //print("self.total at else ", self.total)
                    
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
                
                let indexpath = NSIndexPath.init(row:0 , section: row)
                
                let cellItem:UUMessageCell? = chattableview.cellForRow(at: indexpath as IndexPath) as? UUMessageCell
                
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
    
    func addNotificationListener() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            weak.chattableview.reloadData()
        }
    }
    
    func removeNotificationListener() {
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        removeNotificationListener()
    }

}
