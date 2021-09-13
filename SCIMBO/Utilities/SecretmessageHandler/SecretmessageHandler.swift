//
//  SecretmessageHandler.swift

//
//  Created by CasperoniOS on 23/05/18.
//  Copyright © 2018 CASPERON. All rights reserved.
//

import UIKit
@objc protocol SecretmessageHandlerDelegate : class {
    @objc optional  func callBackDeletedmessgae(user_common_id:String,doc_idArr:[String],status:String)
    
}
class SecretmessageHandler: NSObject
 {
    static let sharedInstance = SecretmessageHandler()
    var Updatetimer:Timer?
    weak var delegate:SecretmessageHandlerDelegate?
    var docidArr:[String] = []
    var isDeleteinprogress:Bool = Bool()
    var user_common_id = String()
    func starttimer()
    {
        Updatetimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.updateDeletedmessages), userInfo: nil, repeats: true)
    }
    func stoptimer()
    {
        Updatetimer?.invalidate()
        Updatetimer = nil
    }
    @objc func updateDeletedmessages()
    {
        
        if(!isDeleteinprogress)
        {
        isDeleteinprogress = true
        let CheckLogin:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.User_detail, attribute: "user_id", FetchString: Themes.sharedInstance.Getuser_id())
        
        if(CheckLogin)
        {
        if(delegate != nil)
        {
            let predicate1 = NSPredicate(format: "user_id == %@", Themes.sharedInstance.Getuser_id())
            let predicate2 = NSPredicate(format: "chat_type == %@", "secret")
            
            let getchatinititedArr:[NSManagedObject] = DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Chat_intiated_details, SortDescriptor: nil, predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1,predicate2]), Limit: 0) as! [NSManagedObject]
            if(getchatinititedArr.count > 0)
            {
                getchatinititedArr.forEach { (obj) in
                    user_common_id = obj.value(forKey: "user_common_id") as! String
                    self.DeleteTimeMessage(user_common_id: user_common_id, completionHandler: {
                        if(self.docidArr.count > 0)
                        {
                            self.delegate?.callBackDeletedmessgae!(user_common_id: self.user_common_id, doc_idArr: self.docidArr, status: "1")
                        }
                        self.docidArr.removeAll()
                      })
                   
                    
              }
                
                
            }
        }
        }
        else
        {
            
        }
        }
        isDeleteinprogress = false
    }
    func Deletemessages(user_common_id:String)
    {
        
    }
    
    func DeleteTimeMessage(user_common_id:String, completionHandler :@escaping () -> Void)
    {
        
        let predicate1 = NSPredicate(format: "user_common_id == %@", user_common_id)
        let predicate2 = NSPredicate(format: "secret_timestamp != %@", "")
        let predicate3 = NSPredicate(format: "secret_timestamp < %@", "\(Int64(Date().ticks))")
        
        let fetchmessages:[NSManagedObject] = DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Chat_one_one, SortDescriptor: "timestamp", predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1,predicate2,predicate3]), Limit: 0) as! [NSManagedObject]
         if(fetchmessages.count > 0)
        {
            fetchmessages.forEach { (obj) in
                
                let messagetype:String = Themes.sharedInstance.CheckNullvalue(Passed_value: obj.value(forKey: "type"))
                let doc_id:String = Themes.sharedInstance.CheckNullvalue(Passed_value: obj.value(forKey: "doc_id"))
                let recordId:String = Themes.sharedInstance.CheckNullvalue(Passed_value: obj.value(forKey: "recordId"))
                let convId:String = Themes.sharedInstance.CheckNullvalue(Passed_value: obj.value(forKey: "convId"))
                
                let id:String = Themes.sharedInstance.CheckNullvalue(Passed_value: obj.value(forKey: "id"))


                let docidPredicate = NSPredicate(format: "doc_id == %@", doc_id)

                if(messagetype == "13")
                {
                    
                    var fetchListArr:[NSManagedObject] = DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Secret_Chat, SortDescriptor: "timestamp", predicate: predicate1, Limit: 0) as! [NSManagedObject]
                    
                    fetchListArr.forEach({ (obj) in
                        print("<<<<< \(String(describing: obj.value(forKey: "incognito_timer")))")
                    })
                     if(fetchListArr.count != 0)
                    {
                     fetchListArr.remove(at: 0)
                    }
                    fetchListArr.forEach({ (obj) in
                        print("<<<<< \(String(describing: obj.value(forKey: "incognito_timer")))")
                    })
                     if(fetchListArr.count > 0)
                    {
                        _ = fetchListArr.map{
                            let secretdoc_id = Themes.sharedInstance.CheckNullvalue(Passed_value: $0.value(forKey: "doc_id"))
                             let checkmessaged:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "secret_msg_id", FetchString: secretdoc_id)
                            
                            if(!checkmessaged)
                            {
                                docidArr.append(secretdoc_id)
                                DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Secret_Chat, Predicatefromat: docidPredicate, Deletestring: secretdoc_id, AttributeName: "doc_id")
                                DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Chat_one_one, Predicatefromat: docidPredicate, Deletestring: secretdoc_id, AttributeName: "doc_id")
                                
                                self.Removechat(type: messagetype, convId: convId, status: "1", recordId: recordId, last_msg: "1")
                            }
                        }
                       


                    }

                }
                else
                {
                    docidArr.append(doc_id)

                    if(messagetype == "0" || messagetype == "4" || messagetype == "5" || messagetype == "14" || messagetype == "11")
                    {
                        DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Chat_one_one, Predicatefromat: docidPredicate, Deletestring: doc_id, AttributeName: "doc_id")

                    }
                    
                    else
                        
                    {
                        let thumbnail:String = Themes.sharedInstance.CheckNullvalue(Passed_value: obj.value(forKey: "thumbnail"))

                        self.Removechat(type: messagetype, convId: convId, status: "1", recordId: recordId, last_msg: "1")

                        let p1 = NSPredicate(format: "id = %@", id)
                        DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Chat_one_one, Predicatefromat: p1, Deletestring: "id", AttributeName: "id")
                        
                        let predic = NSPredicate(format: "upload_data_id == %@",thumbnail)
                        
                        let uploadDetailArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Upload_Details, attribute: "upload_data_id", FetchString: thumbnail, SortDescriptor: nil) as! NSArray
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
                    }
                    

                }
                let checkmessageCount = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: user_common_id)
                if(!checkmessageCount)
                {
                    DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Chat_intiated_details, Predicatefromat: NSPredicate(format: "user_common_id == %@", user_common_id), Deletestring: user_common_id, AttributeName: "user_common_id")
                }
            }
        }

        completionHandler()
        
     }
    
    func Removechat(type:String,convId:String,status:String,recordId:String,last_msg:String)
    {
        var _type = type
        if(_type == "13")
        {
            _type = "0"
        }
        let param:NSDictionary = ["from":Themes.sharedInstance.Getuser_id(),"convId":convId,"status":status,"recordId":recordId,"last_msg":"0", "type" : type]
        SocketIOManager.sharedInstance.EmitDeletedetails(Dict: param)
    }

 }
