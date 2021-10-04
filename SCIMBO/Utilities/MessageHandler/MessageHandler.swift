//
//  MessageHandler.swift
//
//
//  Created by CasperoniOS on 06/06/18.
//  Copyright © 2018 CASPERON. All rights reserved.
//

import UIKit

class MessageHandler: NSObject {
    static let sharedInstance = MessageHandler()
    
    func LoadStatusResponseMessages(ResponseDict:NSDictionary)
    {
        DispatchQueue.main.async {
            
            let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from"));
            var message_from:String=""
            let doc_id:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "doc_id"));
            let type:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "type"));
            let Message_type:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "type"))
            let timestamp:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "timestamp"));
            let info_type:String = "0"
            var Chattype:String = ""
            Chattype="single"
            var user_common_id:String = ""
            
            if(from == Themes.sharedInstance.Getuser_id())
            {
                message_from="1";
            }
            else
            {
                message_from="0";
            }
            
            
            user_common_id = Themes.sharedInstance.CheckNullvalue(Passed_value:Themes.sharedInstance.Getuser_id())
            
            let CheckMessage:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Status_one_one, attribute: "doc_id", FetchString: doc_id)
            //            let message:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "message"))
            
            let CheckUser:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: "\(Constant.sharedinstance.Status_initiated_details)", attribute: "user_common_id", FetchString: from)
            if(!CheckUser)
            {
                let User_dict:[AnyHashable: Any] = ["user_common_id": from, "user_to_dp":"0" ,"user_id":Themes.sharedInstance.Getuser_id(),"chat_type":"single","is_archived":"0","conv_id":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "convId")),"opponent_id":"","chat_count":"1","is_read":"0"]
                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: User_dict as NSDictionary,Entityname: "\(Constant.sharedinstance.Status_initiated_details)")
            }else{
                let User_dict:[AnyHashable: Any] = ["conv_id":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "convId")),"is_read":"0","user_id":Themes.sharedInstance.Getuser_id()]
                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Status_initiated_details, FetchString: from , attribute: "user_common_id", UpdationElements: User_dict as NSDictionary?)
            }
            
            if(CheckMessage)
            {
                var dic:[AnyHashable: Any] = [:];
                
                
                var ThumbnailID:String = String()
                
                if(type == "1" || type == "2")
                {
                    ThumbnailID = doc_id
                    let Dict:NSDictionary = ["message_status":"1"]
                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Status_Upload_Details, FetchString:doc_id , attribute: "upload_data_id", UpdationElements: Dict)
                }
                let status:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "message_status"))
                let message:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "message"))

                dic  = ["type":Message_type ,"convId":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "convId")),"doc_id":doc_id,"filesize":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "filesize")),"from":Themes.sharedInstance.CheckNullvalue(Passed_value:from
                    ),"to":"","isStar":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "isStar")),"message_status":status,"id":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id")),"name":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "contact_name")),"payload":message.decoded
                    ,"recordId":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "recordId")),"thumbnail":ThumbnailID,"width":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "width")),"height":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "height")),"msgId":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "msgId")),"contactmsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "ContactMsisdn"))
                    ,"user_common_id":user_common_id,"message_from":message_from,"chat_type":Chattype,"info_type":info_type,"created_by":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from")),"is_reply":"0", "timestamp" : timestamp]
                
                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Status_one_one,FetchString: doc_id, attribute:"doc_id", UpdationElements: dic as NSDictionary)
                
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.incomingstatus), object: ResponseDict , userInfo: nil)
            }
        }
    }
    
    func LoadResponseMessages(ResponseDict:NSDictionary)
    {
        DispatchQueue.main.async {
            
            var ChatInterlinkID:String=String()
            let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from"));
            let to:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "to"));
            var message_from:String=""
            let doc_id:String = EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "doc_id")), toid: to, chat_type: "single") as! String
            let timestamp:String = EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id")), toid: to, chat_type: "single") as! String
            let type:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "type"));
            var Message_type:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "type"))
            
            guard Message_type != "71" else {return}
            
            let secret_type:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "secret_type"));
            
            var replyDetails:NSDictionary?
            if ResponseDict.object(forKey: "replyDetails") != nil {
                replyDetails =  EncryptionHandler.sharedInstance.decryptData(data: ResponseDict.object(forKey: "replyDetails")!) as? NSDictionary
            }
            
            if(Message_type == "20" || type == "20")
            {
                Message_type = "6"
            }
            
            var ServerPath:String = ""
            var info_type:String = "0"
            var Chattype:String = ""
            //secret message
            var secret_msg_id:String = ""
            var expire_timestamp:String = ""
            Chattype="single"
            if(secret_type == "yes"){
                Chattype="secret"
            }
            var user_common_id:String = ""
            if(replyDetails != nil)
            {
                if(replyDetails!.count > 0)
                {
                    
                    
                    Message_type = "7"
                    let Fromidn:String = Themes.sharedInstance.CheckNullvalue(Passed_value: replyDetails?.object(forKey: "From_msisdn"))
                    let _id:String = Themes.sharedInstance.CheckNullvalue(Passed_value: replyDetails?.object(forKey: "_id"))
                    let message:String = Themes.sharedInstance.CheckNullvalue(Passed_value: replyDetails?.object(forKey: "message"))
                    let from:String = Themes.sharedInstance.CheckNullvalue(Passed_value: replyDetails?.object(forKey: "from"))
                    let Reply_Message_type:String = Themes.sharedInstance.CheckNullvalue(Passed_value: replyDetails?.object(forKey: "type"))
                    
                    let thumbnail_data:String = Themes.sharedInstance.CheckNullvalue(Passed_value: replyDetails?.object(forKey: "thumbnail_data"))
                    let CheckReplyMessage:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Reply_detail, attribute: "recordId", FetchString: _id)
                    if(!CheckReplyMessage)
                    {
                        let Dict:NSDictionary = ["compressed_data":thumbnail_data,"from_id":from,"recordId":_id,"message_type":Reply_Message_type,"payload":message.encoded,"contactmsisdn":Fromidn,"doc_id":doc_id]
                        DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict, Entityname: Constant.sharedinstance.Reply_detail)
                    }
                }
            }
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
            let incognito_timer_mode =  Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "incognito_timer_mode"))
            if(incognito_timer_mode.length != 0){
                if(secret_type == "yes"){
                    user_common_id = Themes.sharedInstance.CheckNullvalue(Passed_value:"\(ChatInterlinkID)-\(Themes.sharedInstance.Getuser_id())")
                }
                else
                {
                    user_common_id = Themes.sharedInstance.CheckNullvalue(Passed_value:"\(Themes.sharedInstance.Getuser_id())-\(ChatInterlinkID)")
                    
                }
                
                var checksecretmessagecount:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Secret_Chat, attribute: "user_common_id", FetchString: user_common_id, SortDescriptor: "timestamp") as! NSArray
                checksecretmessagecount = checksecretmessagecount.reversed() as NSArray
                
                expire_timestamp = "\(Int64(String(Date().ticks))!)"
                
                if(checksecretmessagecount.count > 0)
                {
                    if(type != "13")
                    {
                        secret_msg_id = Themes.sharedInstance.CheckNullvalue(Passed_value: (checksecretmessagecount[0] as! NSManagedObject).value(forKey: "doc_id"))
                    }
                    else
                    {
                        
                    }
                    var incognito_timer_mode =  Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "incognito_timer_mode"))
                    
                    if(incognito_timer_mode == "")
                    {
                        incognito_timer_mode =  Themes.sharedInstance.CheckNullvalue(Passed_value: (checksecretmessagecount[0] as! NSManagedObject).value(forKey: "incognito_timer"))
                    }
                }
                
                let getUpdatedtimestamp:String = Themes.sharedInstance.returnupdatedSecrettimestamp(incognito_timer_mode: incognito_timer_mode)
                expire_timestamp =  getUpdatedtimestamp
                
                
            }
            else{
                user_common_id = Themes.sharedInstance.CheckNullvalue(Passed_value:"\(Themes.sharedInstance.Getuser_id())-\(ChatInterlinkID)")
            }
            if(Chattype == "secret"){
                let CheckUser:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: "\(ChatInterlinkID)-\(Themes.sharedInstance.Getuser_id())")
                if(!CheckUser)
                {
                    let User_dict:[AnyHashable: Any] = ["user_common_id": "\(ChatInterlinkID)-\(Themes.sharedInstance.Getuser_id())","user_to_dp":"0" ,"user_id":Themes.sharedInstance.Getuser_id(),"chat_type":Chattype,"is_archived":"0","conv_id":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "convId")),"opponent_id":"\(ChatInterlinkID)","chat_count":"1","is_read":"0","isSavetocamera":"0"]
                    DatabaseHandler.sharedInstance.InserttoDatabase(Dict: User_dict as NSDictionary,Entityname: Constant.sharedinstance.Chat_intiated_details)
                }else{
                    
                    let User_dict:[AnyHashable: Any] = ["conv_id":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "convId")),"is_read":"0","user_id":Themes.sharedInstance.Getuser_id()]
                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: "\(ChatInterlinkID)-\(Themes.sharedInstance.Getuser_id())" , attribute: "user_common_id", UpdationElements: User_dict as NSDictionary?)
                }
            }
            else{
                let CheckUser:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: "\(Themes.sharedInstance.Getuser_id())-\(ChatInterlinkID)")
                if(!CheckUser)
                {
                    let User_dict:[AnyHashable: Any] = ["user_common_id": "\(Themes.sharedInstance.Getuser_id())-\(ChatInterlinkID)","user_to_dp":"0" ,"user_id":Themes.sharedInstance.Getuser_id(),"chat_type":Chattype,"is_archived":"0","conv_id":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "convId")),"opponent_id":"\(ChatInterlinkID)","chat_count":"1","is_read":"0","isSavetocamera":"0"]
                    DatabaseHandler.sharedInstance.InserttoDatabase(Dict: User_dict as NSDictionary,Entityname: Constant.sharedinstance.Chat_intiated_details)
                }else{
                    let User_dict:[AnyHashable: Any] = ["conv_id":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "convId")),"is_read":"0","user_id":Themes.sharedInstance.Getuser_id()]
                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: "\(Themes.sharedInstance.Getuser_id())-\(ChatInterlinkID)" , attribute: "user_common_id", UpdationElements: User_dict as NSDictionary?)
                }
            }
            
            let CheckMessage:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "doc_id", FetchString: doc_id)
            if(type == "71")
            {
                info_type = type
            }
            if(CheckMessage)
            {
                var dic:[AnyHashable: Any] = [:];
                
                
                var ThumbnailID:String = String()
                
                if(type == "0")
                {
                    ThumbnailID = EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "thumbnail")), toid: to, chat_type: "single") as! String
                }
                    //Update it
                else if(type == "1" || type == "2" || type == "3" || type == "6")
                {
                    ThumbnailID = doc_id
                    let Dict:NSDictionary = ["message_status":"1"]
                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Upload_Details, FetchString:doc_id , attribute: "upload_data_id", UpdationElements: Dict)
                }
                else if(type == "13"){
                    info_type = "13"
                    let incognito_timer_mode:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "incognito_timer_mode"))
                    var date_component = DateComponents()
                    var seconds:String = "0"
                    if(incognito_timer_mode == "5 seconds"){
                        date_component.second = 5
                        seconds = "5"
                    }else if(incognito_timer_mode == "10 seconds"){
                        date_component.second = 10
                        seconds = "10"
                        
                    }else if(incognito_timer_mode == "30 seconds"){
                        date_component.second = 30
                        seconds = "30"
                        
                    }else if(incognito_timer_mode == "1 minute"){
                        date_component.minute = 1
                        seconds = "60"
                        
                    }else if(incognito_timer_mode == "1 hour"){
                        date_component.hour = 1
                        seconds = "3600"
                        
                    }else if(incognito_timer_mode == "1 day"){
                        date_component.day = 1
                        let calcseconds:Int64 = Int64(24 * 3600)
                        seconds = "\(calcseconds)"
                    }else if(incognito_timer_mode == "1 week"){
                        date_component.day = 7
                        let calcseconds:Int64 = Int64(24 * 7 *  3600)
                        seconds = "\(calcseconds)"
                    }
                    else
                    {
                        seconds = "0"
                    }
                    
                    if(incognito_timer_mode.lowercased() == "off")
                    {
                        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Favourite_Contact, FetchString: to, attribute: "id", UpdationElements: ["secret_timer":""])
                    }
                    else
                    {
                        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Favourite_Contact, FetchString: to, attribute: "id", UpdationElements: ["secret_timer":incognito_timer_mode])
                        
                    }
                    
                    let id:String = EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id")), toid: to, chat_type: "single") as! String
                    
                    let dic = ["user_id":to,"incognito_timer":incognito_timer_mode,"timestamp":id,"doc_id":doc_id,"expiration_time":incognito_timer_mode,"user_common_id": "\(ChatInterlinkID)-\(Themes.sharedInstance.Getuser_id())","expire_time_seconds":seconds] as [String : Any]
                    let checkBool:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Secret_Chat, attribute: "doc_id", FetchString: doc_id)
                    if(checkBool){
                        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Secret_Chat, FetchString: doc_id, attribute: "doc_id", UpdationElements: dic as NSDictionary)
                    }else{
                        DatabaseHandler.sharedInstance.InserttoDatabase(Dict: dic as NSDictionary, Entityname: Constant.sharedinstance.Secret_Chat)
                    }
                }
                
                
                var status:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "message_status"))
                if(type == "13"){
                    status = "3"
                }
                let message:String = EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "message")), toid: to, chat_type: "single") as! String
                
                dic  = ["type":Message_type ,"convId":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "convId")),"doc_id":doc_id,"filesize":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "filesize")),"from":Themes.sharedInstance.CheckNullvalue(Passed_value:from
                    ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:to
                    ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "isStar")),"message_status":status,"id":EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id")), toid: to, chat_type: "single"),"name":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "contact_name")),"payload":message.encoded
                    ,"recordId":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "recordId")),"thumbnail":ThumbnailID,"width":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "width")),"height":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "height")),"msgId":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "msgId")),"contactmsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "ContactMsisdn"))
                    ,"user_common_id":user_common_id,"message_from":message_from,"chat_type":Chattype,"info_type":info_type,"created_by":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from")),"is_reply":"0","secret_msg_id":secret_msg_id,"secret_timestamp":expire_timestamp]
                
                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_one_one,FetchString: doc_id, attribute:"doc_id", UpdationElements: dic as NSDictionary?)
                
                let chat_type_dict:[String: String] = ["chat_type": "messagestatus"]
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.outgoingmessage), object: ResponseDict , userInfo: chat_type_dict)
            }
            else
            {
                var dic:[AnyHashable: Any] = [:];
                var ThumbnailID:String = String()
                if(type == "0")
                {
                    ThumbnailID = EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "thumbnail")), toid: to, chat_type: "single") as! String
                    
                }
                else if(type == "1" || type == "2" || type == "3")
                {
                    ThumbnailID = doc_id
                    let CheckCount:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Upload_Details, attribute: "upload_data_id", FetchString: doc_id)
                    if(CheckCount)
                    {
                        let Dict:NSDictionary = ["message_status":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "message_status"))]
                        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Upload_Details, FetchString:doc_id , attribute: "upload_data_id", UpdationElements: Dict)
                    }
                    else
                    {
                        ServerPath = EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "thumbnail")), toid: to, chat_type: "single") as! String
                        if(ServerPath.substring(to: 1) == ".")
                        {
                            ServerPath.remove(at: ServerPath.startIndex)
                            ServerPath = ("\(ImgUrl)\(ServerPath)")
                            
                        }
                        
                        ThumbnailID = doc_id
                        let thumbnail_data:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "thumbnail_data"))
                        let Dict:[String:Any] = ["failure_status":"0","total_byte_count":"0","upload_byte_count":"0","upload_count":"1","upload_data_id":ThumbnailID,"upload_Path":"","upload_status":"1","serverpath":ServerPath,"data_count":"0","compressed_data":thumbnail_data,"to_id":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "to")),"message_status":"1","user_common_id":user_common_id,"user_id":Themes.sharedInstance.Getuser_id(),"download_status":"0","upload_type":"\(Message_type)","is_uploaded":"0", "upload_paused":"0"]
                        DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict as NSDictionary, Entityname: Constant.sharedinstance.Upload_Details);
                    }
                }else if(type == "4"){
                    var metaDetails:NSDictionary?
                    if let linkdetails = ResponseDict.object(forKey: "link_details") {
                        metaDetails =  EncryptionHandler.sharedInstance.Decryptmessage(str: linkdetails, toid: to, chat_type: "single") as? NSDictionary
                    }
                    if(metaDetails != nil)
                    {
                        if((metaDetails?.count)! > 0)
                        {
                            
                            let Link_details:NSDictionary = ["doc_id":doc_id,"image_url":Themes.sharedInstance.CheckNullvalue(Passed_value: metaDetails?.object(forKey: "image")),"title":Themes.sharedInstance.CheckNullvalue(Passed_value: metaDetails?.object(forKey: "title")),"desc":Themes.sharedInstance.CheckNullvalue(Passed_value: metaDetails?.object(forKey: "description")).encoded,"url_str":Themes.sharedInstance.CheckNullvalue(Passed_value: metaDetails?.object(forKey: "url")),"thumbnail_data":Themes.sharedInstance.CheckNullvalue(Passed_value: metaDetails?.object(forKey: "thumbnail_data"))]
                            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Link_details as NSDictionary,Entityname: Constant.sharedinstance.Link_details)
                        }
                        
                    }
                }
                else if (type == "5"){
                    var profile = ""
                    var id = ""
                    var contents = ""
                    var contact_phone = ""
                    
                    let d = EncryptionHandler.sharedInstance.Decryptmessage(str: ResponseDict.object(forKey: "contact_details") as Any, toid: to, chat_type: Chattype)
                    
                    if let d = d as? [String : Any] {
                        
                        if let json = try?JSONSerialization.data(withJSONObject: d, options: []) {
                            if let content = String(data: json, encoding: String.Encoding.utf8) {
                                contents = content
                            }
                            
                        }
                        let data = (contents).data(using:.utf8)
                        
                        do {
                            
                            let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                            let phone_number:NSArray = jsonResult.value(forKey: "phone_number") as! NSArray
                            if(phone_number.count > 0){
                                contact_phone = Themes.sharedInstance.CheckNullvalue(Passed_value: (phone_number[0] as! NSDictionary).value(forKey: "value"))
                            }
                        }catch{
                            
                        }
                        
                        
                        id = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "contact_id"))
                        if(id != ""){
                            profile = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "contact_profile"))
                            profile = profile.replacingOccurrences(of: "/./", with: "/")
                            profile = profile == "" ? "photo" : profile
                        }
                        
                        let Contact_details:NSDictionary = ["doc_id":doc_id,"contact_profile":Themes.sharedInstance.CheckNullvalue(Passed_value:profile),"contact_id":Themes.sharedInstance.CheckNullvalue(Passed_value:id),"contact_name":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "contact_name")),"contact_phone":contact_phone,"contact_details":Themes.sharedInstance.CheckNullvalue(Passed_value: contents)]
                        
                        DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Contact_details   as NSDictionary,Entityname: Constant.sharedinstance.Contact_details)
                    }
                }
                else if (type == "14")
                {
                    var metaDetails:NSDictionary?
                    if let linkdetails = ResponseDict.object(forKey: "link_details") {
                        metaDetails = EncryptionHandler.sharedInstance.Decryptmessage(str: linkdetails, toid: to, chat_type: "single") as? NSDictionary
                    }
                    if(metaDetails != nil)
                    {
                        if((metaDetails?.count)! > 0)
                        {
                            let locationDetail = Themes.sharedInstance.CheckNullvalue(Passed_value: metaDetails?.object(forKey: "image"))
                            var CoordinateArr = [String]()
                            if(locationDetail.slice(from: "color:red|", to: "&zoom=") != nil)
                            {
                                CoordinateArr = locationDetail.slice(from: "color:red|", to: "&zoom=")!.components(separatedBy: ",")
                            }
                            else
                            {
                                CoordinateArr = locationDetail.slice(from: "center=", to: "&zoom=")!.components(separatedBy: ",")
                            }
                            var lat:String = String()
                            var lng:String = String()
                            
                            if(CoordinateArr.count > 0)
                            {
                                lat = CoordinateArr[0]
                                lng = CoordinateArr[1]
                                
                            }
                            
                            let RedirectLink:String = Themes.sharedInstance.CheckNullvalue(Passed_value: metaDetails?.object(forKey: "url"))
                            
                            let LocationDIct:NSDictionary = ["doc_id":doc_id,"image_link":Themes.sharedInstance.CheckNullvalue(Passed_value: metaDetails?.object(forKey: "image")),"lat":"\(lat)","long":"\(lng)","redirect_link":RedirectLink,"thumbnail_data":Themes.sharedInstance.CheckNullvalue(Passed_value: metaDetails?.object(forKey: "thumbnail_data")),"title":Themes.sharedInstance.CheckNullvalue(Passed_value: metaDetails?.object(forKey: "title")),"stitle":Themes.sharedInstance.CheckNullvalue(Passed_value: metaDetails?.object(forKey: "description"))]
                            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: LocationDIct as NSDictionary,Entityname: Constant.sharedinstance.Location_details)
                            
                        }
                        
                    }
                    
                }
                else if(type == "6")
                {
                    let CheckCount:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Upload_Details, attribute: "upload_data_id", FetchString: doc_id)
                    if(CheckCount)
                    {
                        
                        let Dict:NSDictionary = ["message_status":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "message_status"))]
                        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Upload_Details, FetchString:doc_id , attribute: "upload_data_id", UpdationElements: Dict)
                    }
                    else
                    {
                        
                        let original_filename = EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "original_filename")), toid: to, chat_type: "single") as! String
                        let type:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "type"));
                        ThumbnailID = doc_id
                        let thumbnail_data = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "thumbnail_data"))
                        let numPages = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "numPages"))
                        var document_type:String = String()
                        var ServerPath_path:String = EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "thumbnail")), toid: to, chat_type: "single") as! String
                        if(ServerPath_path.substring(to: 1) == ".")
                        {
                            ServerPath_path.remove(at: ServerPath_path.startIndex)
                            ServerPath_path = ("\(ImgUrl)\(ServerPath_path)")
                        }
                        
                        if((ServerPath_path as NSString).pathExtension.uppercased() == "PDF")
                        {
                            document_type = "1"
                        }
                        else
                        {
                            document_type = "2"
                        }
                        ServerPath = EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "thumbnail")), toid: to, chat_type: "single") as! String
                        if(ServerPath.substring(to: 1) == ".")
                        {
                            ServerPath.remove(at: ServerPath.startIndex)
                            ServerPath = ("\(ImgUrl)\(ServerPath)")
                            
                        }
                        
                        let Dict:[String:Any] = ["failure_status":"0","total_byte_count":"0","upload_byte_count":"0","upload_count":"1","upload_data_id":ThumbnailID,"upload_Path":"","upload_status":"1","serverpath":ServerPath,"data_count":"0","compressed_data":thumbnail_data,"to_id":"\(ChatInterlinkID)","message_status":"1","user_common_id":user_common_id,"user_id":Themes.sharedInstance.Getuser_id(),"download_status":"0","upload_type":"\(type)","doc_name":original_filename,"doc_type":document_type,"doc_pagecount":numPages,"is_uploaded":"0", "upload_paused":"0"]
                        DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict as NSDictionary, Entityname: Constant.sharedinstance.Upload_Details);
                        DownloadHandler.sharedinstance.handleDownLoad(false)
                    }
                }else if(type == "13"){
                    info_type = "13"
                    let incognito_timer_mode:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "incognito_timer_mode"))
                    var date_component = DateComponents()
                    var seconds:String = "0"
                    
                    if(incognito_timer_mode == "5 seconds"){
                        date_component.second = 5
                        seconds = "5"
                    }else if(incognito_timer_mode == "10 seconds"){
                        date_component.second = 10
                        seconds = "10"
                        
                    }else if(incognito_timer_mode == "30 seconds"){
                        date_component.second = 30
                        seconds = "30"
                        
                    }else if(incognito_timer_mode == "1 minute"){
                        date_component.minute = 1
                        seconds = "60"
                        
                    }else if(incognito_timer_mode == "1 hour"){
                        date_component.hour = 1
                        seconds = "3600"
                        
                    }else if(incognito_timer_mode == "1 day"){
                        date_component.day = 1
                        let calcseconds:Int64 = Int64(24 * 3600)
                        seconds = "\(calcseconds)"
                    }else if(incognito_timer_mode == "1 week"){
                        date_component.day = 7
                        let calcseconds:Int64 = Int64(24 * 7 * 3600)
                        seconds = "\(calcseconds)"
                    }
                    if(seconds != "0")
                    {
                        let id:String = EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id")), toid: to, chat_type: "single") as! String
                        let dic = ["user_id":to,"incognito_timer":incognito_timer_mode,"timestamp":id,"doc_id":doc_id,"expiration_time":incognito_timer_mode,"user_common_id":"\(ChatInterlinkID)-\(Themes.sharedInstance.Getuser_id())","expire_time_seconds":seconds] as [String : Any]
                        let checkBool:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Secret_Chat, attribute: "doc_id", FetchString: doc_id)
                        if(checkBool){
                            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Secret_Chat, FetchString: to, attribute: "user_id", UpdationElements: dic as NSDictionary)
                        }else{
                            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: dic as NSDictionary, Entityname: Constant.sharedinstance.Secret_Chat)
                        }
                    }
                }
                else
                {
                    ThumbnailID = EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "thumbnail")), toid: to, chat_type: "single") as! String
                    
                }
                let message:String = EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "message")), toid: to, chat_type: "single") as! String
                
                dic = ["type": Message_type,"convId":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "convId")),"doc_id":doc_id,"filesize":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "filesize")),"from":Themes.sharedInstance.CheckNullvalue(Passed_value:from
                    ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:to
                    ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "isStar")),"message_status":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "message_status")),"id":EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id")), toid: to, chat_type: "single"),"name":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "contact_name")),"payload":message.encoded
                    ,"recordId":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "recordId")),"thumbnail":ThumbnailID
                    ,"width":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "width")),"height":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "height")),"msgId":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "msgId")),"contactmsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "ContactMsisdn"))
                    ,"user_common_id":user_common_id,"message_from":message_from,"chat_type":Chattype,"info_type":info_type,"created_by":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from")),"timestamp":timestamp,"is_reply":"0","secret_msg_id":secret_msg_id,"secret_timestamp":expire_timestamp, "date" : Themes.sharedInstance.getTimeStamp()]
                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: dic as NSDictionary, Entityname: Constant.sharedinstance.Chat_one_one)
                let chat_type_dict:[String: String] = ["chat_type": Chattype]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.outgoingmessage), object: dic , userInfo: chat_type_dict)
                
            }
            
        }
    }
    func LoadGroupResponses(ResponseDict:NSDictionary)
    {
        DispatchQueue.main.async {
            
            let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from"));
            let to:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "to"));
            var message_from:String=""
            let doc_id:String=EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "toDocId")), toid: to, chat_type: "group") as! String;
            let timestamp:String=EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id")), toid: to, chat_type: "group") as! String;
            let groupId:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "groupId"));
            let id:String = EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id")), toid: to, chat_type: "group") as! String
            if(from == Themes.sharedInstance.Getuser_id())
            {
                message_from="1";
            }
            else
            {
                message_from="0";
            }
            let chatarray:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id() + "-" + groupId))
            if(!chatarray)
            {
                var Chattype:String=""
                Chattype="group"
                let User_dict:[AnyHashable: Any] = ["user_common_id":  Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id() + "-" + groupId),"user_to_dp":"0" ,"user_id":Themes.sharedInstance.Getuser_id(),"chat_type":Chattype,"is_archived":"0","conv_id":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "groupId")),"timestamp":timestamp,"opponent_id":groupId,"chat_count":"0","is_read":"0","isSavetocamera":"0"]
                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: User_dict as NSDictionary,Entityname: "\(Constant.sharedinstance.Chat_intiated_details) ")
            }
            else
            {
                let User_dict:[AnyHashable: Any] = ["conv_id":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "groupId")),"is_read":"0"]
                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id() + "-" + groupId), attribute: "user_common_id", UpdationElements: User_dict as NSDictionary?)
            }
            
            let recordId:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "recordId"));
            let CheckMessage:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "doc_id", FetchString: doc_id)
            let message:String = EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "payload")), toid: to, chat_type: "group") as! String
            var Message_type:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "type"))
            guard Message_type != "71" else {return}
            
            var ThumbnailID:String = String()
            if(Message_type == "20")
            {
                Message_type = "6"
            }
            if(Message_type == "0")
            {
                ThumbnailID = EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "thumbnail")), toid: to, chat_type: "group") as! String
            }
            else if(Message_type == "6"){
                ThumbnailID = doc_id
            }
            if(Message_type == "1" || Message_type == "2" || Message_type == "3")
            {
                ThumbnailID = doc_id
                let CheckCount:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Upload_Details, attribute: "upload_data_id", FetchString: doc_id)
                if(CheckCount)
                {
                    
                    let Dict:NSDictionary = ["message_status":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "message_status"))]
                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Upload_Details, FetchString:doc_id , attribute: "upload_data_id", UpdationElements: Dict)
                }
                else
                {
                    var ServerPath:String = EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "thumbnail")), toid: to, chat_type: "group") as! String
                    if(ServerPath.substring(to: 1) == ".")
                    {
                        ServerPath.remove(at: ServerPath.startIndex)
                        ServerPath = ("\(ImgUrl)\(ServerPath)")
                        
                    }
                    
                    ThumbnailID = doc_id
                    let thumbnail_data:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "thumbnail_data"))
                    let Dict:[String:Any] = ["failure_status":"0","total_byte_count":"0","upload_byte_count":"0","upload_count":"1","upload_data_id":ThumbnailID,"upload_Path":"","upload_status":"1","serverpath":ServerPath,"data_count":"0","compressed_data":thumbnail_data,"to_id":groupId,"message_status":"1","user_common_id":"\(Themes.sharedInstance.Getuser_id())-\(groupId)","user_id":Themes.sharedInstance.Getuser_id(),"download_status":"0","upload_type":"\(Message_type)","is_uploaded":"0", "upload_paused":"0"]
                    DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict as NSDictionary, Entityname: Constant.sharedinstance.Upload_Details);
                }
            }
            else if(Message_type == "4"){
                var metaDetails:NSDictionary?
                if let linkdetails = ResponseDict.object(forKey: "link_details") {
                    metaDetails =  EncryptionHandler.sharedInstance.Decryptmessage(str: linkdetails, toid: to, chat_type: "group") as? NSDictionary
                }
                if(metaDetails != nil)
                {
                    if((metaDetails?.count)! > 0)
                    {
                        let Link_details:NSDictionary = ["doc_id":doc_id,"image_url":Themes.sharedInstance.CheckNullvalue(Passed_value: metaDetails?.object(forKey: "image")),"title":Themes.sharedInstance.CheckNullvalue(Passed_value: metaDetails?.object(forKey: "title")),"desc":Themes.sharedInstance.CheckNullvalue(Passed_value: metaDetails?.object(forKey: "description")).encoded,"url_str":Themes.sharedInstance.CheckNullvalue(Passed_value: metaDetails?.object(forKey: "url")),"thumbnail_data":Themes.sharedInstance.CheckNullvalue(Passed_value: metaDetails?.object(forKey: "thumbnail_data"))]
                        
                        
                        DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Link_details as NSDictionary,Entityname: Constant.sharedinstance.Link_details)
                        
                        
                        
                    }
                    
                }
                
                
            }
            else if (Message_type == "5"){
                var profile = ""
                var id = ""
                var contents = ""
                var contact_phone = ""
                let d = EncryptionHandler.sharedInstance.Decryptmessage(str: ResponseDict.object(forKey: "contact_details") as Any, toid: to, chat_type: "group")
                if let d = d as? [String : Any] {
                    if let json = try?JSONSerialization.data(withJSONObject: d, options: []) {
                        if let content = String(data: json, encoding: String.Encoding.utf8) {
                            contents = content
                        }
                        
                    }
                    
                    let data = (contents).data(using:.utf8)
                    
                    do {
                        
                        let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                        let phone_number:NSArray = jsonResult.value(forKey: "phone_number") as! NSArray
                        if(phone_number.count > 0){
                            contact_phone = Themes.sharedInstance.CheckNullvalue(Passed_value: (phone_number[0] as! NSDictionary).value(forKey: "value"))
                        }
                    }catch{
                        
                    }
                    
                    id = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "contact_id"))
                    if(id != ""){
                        profile = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "contact_profile"))
                        profile = profile.replacingOccurrences(of: "/./", with: "/")
                        profile = profile == "" ? "photo" : profile
                    }
                    
                    let Contact_details:NSMutableDictionary = ["doc_id":doc_id,"contact_profile":Themes.sharedInstance.CheckNullvalue(Passed_value:profile),"contact_id":Themes.sharedInstance.CheckNullvalue(Passed_value:id),"contact_name":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "contact_name")),"contact_phone":Themes.sharedInstance.CheckNullvalue(Passed_value:contact_phone),"contact_details":Themes.sharedInstance.CheckNullvalue(Passed_value: contents)]
                    
                    if(Themes.sharedInstance.CheckNullvalue(Passed_value: Contact_details.value(forKey: "contact_phone")) == "")
                    {
                        Contact_details.setValue(contact_phone, forKey: "contact_phone")
                    }
                    
                    DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Contact_details   as NSDictionary,Entityname: Constant.sharedinstance.Contact_details)
                }
                
            }
            else if(Message_type == "6")
            {
                let CheckCount:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Upload_Details, attribute: "upload_data_id", FetchString: doc_id)
                if(CheckCount)
                {
                    
                    let Dict:NSDictionary = ["message_status":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "message_status"))]
                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Upload_Details, FetchString:doc_id , attribute: "upload_data_id", UpdationElements: Dict)
                }
                else
                {
                    
                    let original_filename:String! = EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "original_filename")), toid: to, chat_type: "group") as? String
                    let type:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "type"));
                    ThumbnailID = doc_id
                    var ServerPath_path:String = EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "thumbnail")), toid: to, chat_type: "group") as! String
                    if(ServerPath_path.substring(to: 1) == ".")
                    {
                        ServerPath_path.remove(at: ServerPath_path.startIndex)
                        ServerPath_path = ("\(ImgUrl)\(ServerPath_path)")
                    }
                    let thumbnail_data = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "thumbnail_data"))
                    let numPages = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "numPages"))
                    var document_type:String = String()
                    if((ServerPath_path as NSString).pathExtension.uppercased() == "PDF")
                    {
                        document_type = "1"
                    }
                    else
                    {
                        document_type = "2"
                    }
                    let Dict:[String:Any] = ["failure_status":"0","total_byte_count":"0","upload_byte_count":"0","upload_count":"1","upload_data_id":ThumbnailID,"upload_Path":"","upload_status":"1","serverpath":ServerPath_path,"data_count":"0","compressed_data":thumbnail_data,"to_id":groupId,"message_status":"1","user_common_id":"\(Themes.sharedInstance.Getuser_id())-\(groupId)","user_id":Themes.sharedInstance.Getuser_id(),"download_status":"0","upload_type":"\(type)","doc_name":original_filename,"doc_type":document_type,"doc_pagecount":numPages,"is_uploaded":"0", "upload_paused":"0"]
                    DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict as NSDictionary, Entityname: Constant.sharedinstance.Upload_Details);
                    DownloadHandler.sharedinstance.handleDownLoad(false)
                }
            }
            else
            {
                ThumbnailID = EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "thumbnail")), toid: to, chat_type: "group") as! String
                
            }
            
            var replyDetails:NSDictionary?
            if ResponseDict.object(forKey: "replyDetails") != nil {
                replyDetails =  EncryptionHandler.sharedInstance.decryptData(data: ResponseDict.object(forKey: "replyDetails")!) as? NSDictionary
            }
            
            if(replyDetails != nil)
            {
                if(replyDetails!.count > 0)
                {
                    Message_type = "7"
                    
                    let Fromidn:String = Themes.sharedInstance.CheckNullvalue(Passed_value: replyDetails?.object(forKey: "From_msisdn"))
                    
                    
                    let _id:String = Themes.sharedInstance.CheckNullvalue(Passed_value: replyDetails?.object(forKey: "_id"))
                    
                    let message:String = Themes.sharedInstance.CheckNullvalue(Passed_value: replyDetails?.object(forKey: "payload"))
                    //            let server_load:String = Themes.sharedInstance.CheckNullvalue(Passed_value: replyDetails?.object(forKey: "server_load"))
                    let from:String = Themes.sharedInstance.CheckNullvalue(Passed_value: replyDetails?.object(forKey: "from"))
                    let Reply_Message_type:String = Themes.sharedInstance.CheckNullvalue(Passed_value: replyDetails?.object(forKey: "type"))
                    
                    let thumbnail_data:String = Themes.sharedInstance.CheckNullvalue(Passed_value: replyDetails?.object(forKey: "thumbnail_data"))
                    let CheckReplyMessage:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Reply_detail, attribute: "recordId", FetchString: _id)
                    if(!CheckReplyMessage)
                    {
                        let Dict:NSDictionary = ["compressed_data":thumbnail_data,"from_id":from,"recordId":_id,"message_type":Reply_Message_type,"payload":message.encoded,"contactmsisdn":Fromidn,"doc_id":doc_id]
                        DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict, Entityname: Constant.sharedinstance.Reply_detail)
                    }
                }
            }
            
            if(CheckMessage)
            {
                var messagestatus:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "read_status"))
                if(messagestatus == "")
                {
                    messagestatus = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "deliver"))
                }
                let dic:[AnyHashable: Any] = ["type": Message_type,"convId":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "groupId")),"doc_id":doc_id,"filesize":EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "original_filename")), toid: to, chat_type: "group"),"from":Themes.sharedInstance.CheckNullvalue(Passed_value:from
                    ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:to
                    ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "isStar")),"message_status":messagestatus,"id":EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id")), toid: to, chat_type: "group"),"name":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "contact_name")),"payload":message.encoded
                    ,"recordId":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "recordId")),"thumbnail":ThumbnailID,"width":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "width")),"height":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "height")),"msgId":EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id")), toid: to, chat_type: "group"),"contactmsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "ContactMsisdn"))
                    ,"user_common_id":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id()))-\(groupId)"
                    ),"message_from":message_from,"chat_type":"group","info_type":"0","created_by":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from")),"is_reply":"0"]
                
                
                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_one_one, FetchString: doc_id, attribute:"doc_id", UpdationElements: dic as NSDictionary)
            }
            else
            {
                var messagestatus:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "read_status"))
                if(messagestatus == "")
                {
                    messagestatus = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "deliver"))
                }
                let message:String = EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "message")), toid: to, chat_type: "group") as! String
                
                let dic:[AnyHashable: Any] = ["type": Message_type,"convId":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "convId")),"doc_id":doc_id,"filesize":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "filesize")),"from":Themes.sharedInstance.CheckNullvalue(Passed_value:from
                    ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:to
                    ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "isStar")),"message_status":messagestatus,"id":EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id")), toid: to, chat_type: "group"),"name":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "contact_name")),"payload": message.encoded
                    ,"recordId":recordId,"thumbnail":ThumbnailID,"width":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "width")),"height":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "height")),"msgId":EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id")), toid: to, chat_type: "group"),"contactmsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "ContactMsisdn"))
                    ,"user_common_id":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(Themes.sharedInstance.Getuser_id())-\(groupId)"
                    ),"message_from":message_from,"timestamp":timestamp,"chat_type":"group","info_type":"0","created_by":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from")),"is_reply":"0", "date" : Themes.sharedInstance.getTimeStamp()]
                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: dic as NSDictionary,Entityname: Constant.sharedinstance.Chat_one_one)
                
                let chat_type_dict:[String: String] = ["chat_type": "group"]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.outgoingmessage), object: dic , userInfo: chat_type_dict)
            }
            let chat_type_dict:[String: String] = ["chat_type": "groupmessagestatus"]
            var messagestatus:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "read_status"))
            if(messagestatus == "")
            {
                messagestatus = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "deliver"))
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.outgoingmessage), object: ["message_status":messagestatus,"groupId":groupId,"message_id":id] , userInfo: chat_type_dict)
            Themes.sharedInstance.insertMessageStatus(id, groupId)
        }
        
    }
    
    func StoreIncomingMessage(ResponseDict:NSDictionary,isFromoffline:Bool)
    {
        DispatchQueue.main.async {
            
            let recordId:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "recordId"));
            let CheckMessage:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "recordId", FetchString: recordId)
            
            if(!CheckMessage)
            {
                var secret_msg_id:String = ""
                var expire_timestamp:String = ""
                
                //String(Int(Date().timeIntervalSince1970))
                var ChatInterlinkID:String=String()
                let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from"));
                let to:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "to"));
                let type:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "type"));
                let status:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "status"));
                let secret_type:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "secret_type"));
                let is_deleted = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "is_deleted_everyone"))
                let reply_type = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "reply_type"))
                let replyId = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "replyId"))
                let convId:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "convId"))
                
                var is_secret_chat:String = ""
                if(ResponseDict.object(forKey: "is_secret_chat") != nil)
                    
                {
                    is_secret_chat = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "is_secret_chat"));
                }
                
                var Doc_id:String = ""
                var Chattype:String=""
                Chattype="single"
                var user_common_id:String = ""
                var info_type:String = "0"
                if(type == "71")
                {
                    info_type = type
                }
                
                if(type == "23")
                {
                    info_type = type
                }
                if(secret_type == "yes"){
                    Chattype="secret"
                }
                
                let timestamp:String = EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id")), toid: from, chat_type: Chattype) as! String

                if(isFromoffline)
                {
                    
                    Doc_id=EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "docId")), toid: from, chat_type: Chattype) as! String
                }
                else
                {
                    Doc_id=EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "doc_id")), toid: from, chat_type: Chattype) as! String
                }
                let message_status:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "message_status"));
                var message_from:String=""
                if(from != Themes.sharedInstance.Getuser_id())
                {
                    
                    ChatInterlinkID=from;
                    message_from="0";
                }
                else
                {
                    message_from="1";
                }
                if(to != Themes.sharedInstance.Getuser_id())
                {
                    ChatInterlinkID=to;
                }
                let incognito_timer_mode =  Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "incognito_timer_mode"))
                if(incognito_timer_mode.length != 0){
                    
                    if(secret_type == "yes"){
                        user_common_id = Themes.sharedInstance.CheckNullvalue(Passed_value:"\(ChatInterlinkID)-\(Themes.sharedInstance.Getuser_id())")
                    }
                    else
                    {
                        user_common_id = Themes.sharedInstance.CheckNullvalue(Passed_value:"\(Themes.sharedInstance.Getuser_id())-\(ChatInterlinkID)")
                        
                    }
                    
                    var checksecretmessagecount:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Secret_Chat, attribute: "user_common_id", FetchString: user_common_id, SortDescriptor: "timestamp") as! NSArray
                    checksecretmessagecount = checksecretmessagecount.reversed() as NSArray
                    if(checksecretmessagecount.count > 0)
                    {
                        if(type != "13")
                        {
                            secret_msg_id = Themes.sharedInstance.CheckNullvalue(Passed_value: (checksecretmessagecount[0] as! NSManagedObject).value(forKey: "doc_id"))
                        }
                    }
                    else
                    {
                        let id_ = "\((timestamp as NSString).longLongValue - 10)"
                        let docid:String = "\(from)-\(to)-\(id_)"
                        let incognito_timer_mode:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "incognito_timer_mode"))
                        if(incognito_timer_mode != "")
                        {
                            let secretdic = ["user_id":from,"incognito_timer":incognito_timer_mode,"timestamp":id_,"doc_id":docid,"expiration_time":incognito_timer_mode,"user_common_id":user_common_id,"expire_time_seconds":"0"] as [String : Any]
                            let checkBool:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Secret_Chat, attribute: "doc_id", FetchString: docid)
                            if(checkBool)
                            {
                                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Secret_Chat, FetchString: docid, attribute: "doc_id", UpdationElements: secretdic as NSDictionary)
                            }
                            else
                            {
                                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: secretdic as NSDictionary, Entityname: Constant.sharedinstance.Secret_Chat)
                            }
                            secret_msg_id =  docid
                            
                            
                            
                            let DBdic:[AnyHashable: Any] = ["type": "13","convId":"","doc_id":docid,"filesize":"","from":Themes.sharedInstance.CheckNullvalue(Passed_value:from
                                ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:to
                                ),"isStar":"0","message_status":status,"id":"2","name":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "contact_name")),"payload":incognito_timer_mode
                                ,"recordId":"","thumbnail":"","width":"","height":"","msgId":id_,"contactmsisdn":""
                                ,"user_common_id":user_common_id,"timestamp":"\(id_)","message_from":message_from,"chat_type":"secret","info_type":"13","created_by":"","is_reply":"0", "reply_type" : "0","secret_msg_id":secret_msg_id,"secret_timestamp":"", "date" : Themes.sharedInstance.getTimeStamp()]
                            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: DBdic as NSDictionary,Entityname: Constant.sharedinstance.Chat_one_one)
                            let chat_type_dict:[String: String] = ["chat_type": Chattype,"user_common_id":from,"offline":"\(isFromoffline)"]
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.Incomingmessage), object: DBdic , userInfo: chat_type_dict)
                            
                        }
                        else
                        {
                            secret_msg_id = Doc_id
                        }
                        
                        
                    }
                    expire_timestamp = ""
                    
                }
                else
                {
                    user_common_id = Themes.sharedInstance.CheckNullvalue(Passed_value:"\(Themes.sharedInstance.Getuser_id())-\(ChatInterlinkID)")
                }
                
                if(message_status == "0" || message_status == "1" || status == "1")
                {
                    let timestamp_offlinemessages:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "msgId"));
                    SocketIOManager.sharedInstance.AcknowledegmentHandler(from: Themes.sharedInstance.Getuser_id() as NSString, to: ChatInterlinkID as NSString, status: "2", doc_id: Doc_id as NSString, timestamp: timestamp_offlinemessages as NSString,isEmit_status: true, is_deleted_message_ack: false, chat_type: Chattype, convId: convId)
                }
                let Check_Fav:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "id", FetchString: from)
                if(!Check_Fav)
                {
                    if(from != Themes.sharedInstance.Getuser_id())
                    {
                        let param_userDetails:[String:Any]=["userId":from]
                        SocketIOManager.sharedInstance.EmituserDetails(Param: param_userDetails)
                    }
                }
                if(from != to)
                {
                    if(Chattype == "secret"){
                        let CheckUser:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: "\(ChatInterlinkID)-\(Themes.sharedInstance.Getuser_id())")
                        
                        if(!CheckUser)
                        {
                            let User_dict:[AnyHashable: Any] = ["user_common_id": "\(ChatInterlinkID)-\(Themes.sharedInstance.Getuser_id())","user_to_dp":"0" ,"user_id":Themes.sharedInstance.Getuser_id(),"chat_type":Chattype,"is_archived":"0","conv_id":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "convId")),"opponent_id":"\(ChatInterlinkID)","chat_count":"1","is_read":"0","isSavetocamera":"0"]
                            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: User_dict as NSDictionary,Entityname: Constant.sharedinstance.Chat_intiated_details)
                        }else{
                            let FetchCount:String = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_intiated_details, attrib_name: "user_common_id", fetchString: "\(ChatInterlinkID)-\(Themes.sharedInstance.Getuser_id())", returnStr: "chat_count")
                            let count:Int = Int(FetchCount)!+1
                            let User_dict:[AnyHashable: Any]=["timestamp":timestamp,"chat_count":"\(count)","is_read":"0","user_id":Themes.sharedInstance.Getuser_id(), "chat_type":Chattype, "is_archived" : "0"]
                            
                            let checkMessage = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "msgId", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "msgId")))
                            if(!checkMessage)
                            {
                                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: "\(ChatInterlinkID)-\(Themes.sharedInstance.Getuser_id())" , attribute: "user_common_id", UpdationElements: User_dict as NSDictionary?)
                            }
                        }
                    }else{
                        let CheckUser:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: "\(Themes.sharedInstance.Getuser_id())-\(ChatInterlinkID)")
                        if(!CheckUser)
                        {
                            let User_dict:[AnyHashable: Any] = ["user_common_id": "\(Themes.sharedInstance.Getuser_id())-\(ChatInterlinkID)","user_to_dp":"0" ,"user_id":Themes.sharedInstance.Getuser_id(),"chat_type":Chattype,"is_archived":"0","conv_id":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "convId")),"opponent_id":"\(ChatInterlinkID)","chat_count":"1","is_read":"0","isSavetocamera":"0"]
                            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: User_dict as NSDictionary,Entityname: Constant.sharedinstance.Chat_intiated_details)
                        }else{
                            let FetchCount:String = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_intiated_details, attrib_name: "user_common_id", fetchString: "\(Themes.sharedInstance.Getuser_id())-\(ChatInterlinkID)", returnStr: "chat_count")
                            let count:Int = Int(FetchCount)!+1
                            let User_dict:[AnyHashable: Any]=["timestamp":timestamp,"chat_count":"\(count)","is_read":"0","user_id":Themes.sharedInstance.Getuser_id(), "is_archived" : "0"]
                            
                            let checkMessage = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "msgId", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "msgId")))
                            if(!checkMessage)
                            {
                                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: "\(Themes.sharedInstance.Getuser_id())-\(ChatInterlinkID)" , attribute: "user_common_id", UpdationElements: User_dict as NSDictionary?)
                            }
                        }
                    }
                }
                AppDelegate.sharedInstance.setBadgeCount()
                let original_filename:String! = EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "original_filename")), toid: from, chat_type: Chattype) as? String
                var document_type:String = ""
                var Message_type:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "type"))
                
                if(replyId != "")
                {
                    Message_type = "7"
                    var Dict:NSDictionary = NSDictionary()
                    if(reply_type == "status")
                    {
                        if(isFromoffline)
                        {
                            var replyDetails:NSDictionary?
                            if ResponseDict.object(forKey: "replyDetails") != nil {
                                replyDetails =  EncryptionHandler.sharedInstance.decryptData(data: ResponseDict.object(forKey: "replyDetails")!) as? NSDictionary
                            }
                            let Fromidn:String = Themes.sharedInstance.GetMyPhonenumber()
                            let _id:String = Themes.sharedInstance.CheckNullvalue(Passed_value: replyDetails?.object(forKey: "_id"))
                            
                            let message:String = Themes.sharedInstance.CheckNullvalue(Passed_value: replyDetails?.object(forKey: "message"))
                            let from:String = Themes.sharedInstance.CheckNullvalue(Passed_value: replyDetails?.object(forKey: "from"))
                            let Reply_Message_type = Themes.sharedInstance.CheckNullvalue(Passed_value: replyDetails?.object(forKey: "reply_type"))
                            
                            let thumbnail_data:String = Themes.sharedInstance.CheckNullvalue(Passed_value: replyDetails?.object(forKey: "thumbnail_data"))
                            
                            Dict = ["compressed_data":thumbnail_data,"from_id":from,"recordId":_id,"message_type":Reply_Message_type,"payload":message.encoded,"contactmsisdn":Fromidn,"doc_id":Doc_id]
                        }
                        else
                        {
                            var replyDetails:NSDictionary?
                            if ResponseDict.object(forKey: "replyDetails") != nil {
                                replyDetails =  EncryptionHandler.sharedInstance.decryptData(data: ResponseDict.object(forKey: "replyDetails")!) as? NSDictionary
                            }
                            let Fromidn:String = Themes.sharedInstance.CheckNullvalue(Passed_value: replyDetails?.object(forKey: "From_msisdn"))
                            let _id:String = Themes.sharedInstance.CheckNullvalue(Passed_value: replyDetails?.object(forKey: "_id"))
                            
                            let message:String = Themes.sharedInstance.CheckNullvalue(Passed_value: replyDetails?.object(forKey: "message"))
                            let from:String = Themes.sharedInstance.CheckNullvalue(Passed_value: replyDetails?.object(forKey: "from"))
                            let Reply_Message_type = Themes.sharedInstance.CheckNullvalue(Passed_value: replyDetails?.object(forKey: "type"))
                            
                            let thumbnail_data:String = Themes.sharedInstance.CheckNullvalue(Passed_value: replyDetails?.object(forKey: "thumbnail_data"))
                            
                            Dict = ["compressed_data":thumbnail_data,"from_id":from,"recordId":_id,"message_type":Reply_Message_type,"payload":message.encoded,"contactmsisdn":Fromidn,"doc_id":Doc_id]
                        }
                    }
                    else
                    {
                        if(isFromoffline)
                        {
                            let checkReplyMessageArr = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "recordId", FetchString: replyId, SortDescriptor: nil) as! NSArray
                            if(checkReplyMessageArr.count > 0)
                            {
                                let ReplyMessageDict : NSManagedObject = checkReplyMessageArr[0] as! NSManagedObject
                                let Fromidn:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ReplyMessageDict.value(forKey: "contactmsisdn"))
                                let _id:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ReplyMessageDict.value(forKey: "recordId"))
                                
                                let message:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ReplyMessageDict.value(forKey: "payload"))
                                let from:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ReplyMessageDict.value(forKey: "from"))
                                let Reply_Message_type = Themes.sharedInstance.CheckNullvalue(Passed_value: ReplyMessageDict.value(forKey: "type"))
                                
                                let thumbnail:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ReplyMessageDict.value(forKey: "thumbnail"))
                                let thumbnail_data:String = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Upload_Details, attrib_name: "upload_data_id", fetchString: thumbnail, returnStr: "compressed_data")
                                Dict = ["compressed_data":thumbnail_data,"from_id":from,"recordId":_id,"message_type":Reply_Message_type,"payload":message.encoded,"contactmsisdn":Fromidn,"doc_id":Doc_id]
                            }
                            else
                            {
                                Message_type = "0"
                            }
                        }
                        else
                        {
                            var replyDetails:NSDictionary?
                            if ResponseDict.object(forKey: "replyDetails") != nil {
                                replyDetails =  EncryptionHandler.sharedInstance.decryptData(data: ResponseDict.object(forKey: "replyDetails")!) as? NSDictionary
                            }
                            let Fromidn:String = Themes.sharedInstance.CheckNullvalue(Passed_value: replyDetails?.object(forKey: "From_msisdn"))
                            let _id:String = Themes.sharedInstance.CheckNullvalue(Passed_value: replyDetails?.object(forKey: "_id"))
                            
                            let message:String = Themes.sharedInstance.CheckNullvalue(Passed_value: replyDetails?.object(forKey: "message"))
                            let from:String = Themes.sharedInstance.CheckNullvalue(Passed_value: replyDetails?.object(forKey: "from"))
                            let Reply_Message_type = Themes.sharedInstance.CheckNullvalue(Passed_value: replyDetails?.object(forKey: "type"))
                            
                            let thumbnail_data:String = Themes.sharedInstance.CheckNullvalue(Passed_value: replyDetails?.object(forKey: "thumbnail_data"))
                            
                            Dict = ["compressed_data":thumbnail_data,"from_id":from,"recordId":_id,"message_type":Reply_Message_type,"payload":message.encoded,"contactmsisdn":Fromidn,"doc_id":Doc_id]
                        }
                    }
                    if(Message_type == "7")
                    {
                        let CheckReplyMessage:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Reply_detail, attribute: "doc_id", FetchString: Doc_id)
                        if(!CheckReplyMessage)
                        {
                            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict, Entityname: Constant.sharedinstance.Reply_detail)
                        }
                    }
                }
                
                if(!CheckMessage)
                {
                    
                    var ThumbnailID:String = String()
                    
                    if(type == "0")
                    {
                        ThumbnailID = EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "thumbnail")), toid: from, chat_type: Chattype) as! String
                    }
                        
                    else if(type == "1" || type == "2" || type == "3")
                    {
                        ThumbnailID = Doc_id
                        var ServerPath_path:String = EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "thumbnail")), toid: from, chat_type: Chattype) as! String
                        if(ServerPath_path.substring(to: 1) == ".")
                        {
                            ServerPath_path.remove(at: ServerPath_path.startIndex)
                            ServerPath_path = ("\(ImgUrl)\(ServerPath_path)")
                        }
                        let thumbnail_data = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "thumbnail_data"))
                        let Dict:[String:Any] = ["failure_status":"0","total_byte_count":"0","upload_byte_count":"0","upload_count":"1","upload_data_id":ThumbnailID,"upload_Path":"","upload_status":"1","serverpath":ServerPath_path,"data_count":"0","compressed_data":thumbnail_data,"to_id":"\(ChatInterlinkID)","message_status":"1","user_common_id":user_common_id,"user_id":Themes.sharedInstance.Getuser_id(),"download_status":"0","upload_type":"\(type)","is_uploaded":"0", "upload_paused":"0","isSavetocamera":"0"]
                        DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict as NSDictionary, Entityname: Constant.sharedinstance.Upload_Details);
                        DownloadHandler.sharedinstance.handleDownLoad(false)
                        
                    }
                    else if (type == "6" || type == "20")
                    {
                        
                        let type:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "type"));
                        ThumbnailID = Doc_id
                        let thumbnail_data = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "thumbnail_data"))
                        let numPages = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "numPages"))
                        var ServerPath_path:String = EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "thumbnail")), toid: from, chat_type: Chattype) as! String
                        if(ServerPath_path.substring(to: 1) == ".")
                        {
                            ServerPath_path.remove(at: ServerPath_path.startIndex)
                            ServerPath_path = ("\(ImgUrl)\(ServerPath_path)")
                        }
                        
                        if((ServerPath_path as NSString).pathExtension.uppercased() == "PDF")
                        {
                            document_type = "1"
                        }
                        else
                        {
                            document_type = "2"
                        }
                        let Dict:[String:Any] = ["failure_status":"0","total_byte_count":"0","upload_byte_count":"0","upload_count":"1","upload_data_id":ThumbnailID,"upload_Path":"","upload_status":"1","serverpath":ServerPath_path,"data_count":"0","compressed_data":thumbnail_data,"to_id":"\(ChatInterlinkID)","message_status":"1","user_common_id":user_common_id,"user_id":Themes.sharedInstance.Getuser_id(),"download_status":"0","upload_type":"\(type)","doc_name":original_filename,"doc_type":document_type,"doc_pagecount":numPages,"is_uploaded":"0", "upload_paused":"0"]
                        DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict as NSDictionary, Entityname: Constant.sharedinstance.Upload_Details);
                        DownloadHandler.sharedinstance.handleDownLoad(false)
                    }
                    else if (type == "14")
                    {
                        var metaDetails:NSDictionary?
                        if let linkdetails = ResponseDict.object(forKey: "link_details") {
                            metaDetails = EncryptionHandler.sharedInstance.Decryptmessage(str: linkdetails, toid: from, chat_type: "single") as? NSDictionary
                        }
                        if(metaDetails != nil)
                        {
                            if((metaDetails?.count)! > 0)
                            {
                                let locationDetail = Themes.sharedInstance.CheckNullvalue(Passed_value: metaDetails?.object(forKey: "image"))
                                var CoordinateArr = [String]()
                                if(locationDetail.slice(from: "color:red|", to: "&zoom=") != nil)
                                {
                                    CoordinateArr = locationDetail.slice(from: "color:red|", to: "&zoom=")!.components(separatedBy: ",")
                                }
                                else
                                {
                                    CoordinateArr = locationDetail.slice(from: "center=", to: "&zoom=")!.components(separatedBy: ",")
                                }
                                var lat:String = String()
                                var lng:String = String()
                                
                                if(CoordinateArr.count > 0)
                                {
                                    lat = CoordinateArr[0]
                                    lng = CoordinateArr[1]
                                    
                                }
                                
                                let RedirectLink:String = Themes.sharedInstance.CheckNullvalue(Passed_value: metaDetails?.object(forKey: "url"))
                                
                                let LocationDIct:NSDictionary = ["doc_id":Doc_id,"image_link":Themes.sharedInstance.CheckNullvalue(Passed_value: metaDetails?.object(forKey: "image")),"lat":"\(lat)","long":"\(lng)","redirect_link":RedirectLink,"thumbnail_data":Themes.sharedInstance.CheckNullvalue(Passed_value: metaDetails?.object(forKey: "thumbnail_data")),"title":Themes.sharedInstance.CheckNullvalue(Passed_value: metaDetails?.object(forKey: "title")),"stitle":Themes.sharedInstance.CheckNullvalue(Passed_value: metaDetails?.object(forKey: "description"))]
                                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: LocationDIct as NSDictionary,Entityname: Constant.sharedinstance.Location_details)
                                
                            }
                            
                        }
                        
                    }
                    else if(type == "4"){
                        
                        var metaDetails:NSDictionary?
                        if let linkdetails = ResponseDict.object(forKey: "link_details") {
                            metaDetails =  EncryptionHandler.sharedInstance.Decryptmessage(str: linkdetails, toid: from, chat_type: "single") as? NSDictionary
                        }
                        
                        if(metaDetails != nil)
                        {
                            if((metaDetails?.count)! > 0)
                            {
                                let Link_details:NSDictionary = ["doc_id":Doc_id,"image_url":Themes.sharedInstance.CheckNullvalue(Passed_value: metaDetails?.object(forKey: "image")),"title":Themes.sharedInstance.CheckNullvalue(Passed_value: metaDetails?.object(forKey: "title")),"desc":Themes.sharedInstance.CheckNullvalue(Passed_value: metaDetails?.object(forKey: "description")).encoded,"url_str":Themes.sharedInstance.CheckNullvalue(Passed_value: metaDetails?.object(forKey: "url")),"thumbnail_data":Themes.sharedInstance.CheckNullvalue(Passed_value: metaDetails?.object(forKey: "thumbnail_data"))]
                                
                                
                                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Link_details as NSDictionary,Entityname: Constant.sharedinstance.Link_details)
                                
                                
                                
                            }
                            
                        }
                        
                        
                    }
                    else if (type == "5"){
                        var profile = ""
                        var id = ""
                        var contents = ""
                        var contact_phone = ""
                        
                        let d = EncryptionHandler.sharedInstance.Decryptmessage(str: ResponseDict.object(forKey: "contact_details") as Any, toid: from, chat_type: Chattype)
                        
                        if let d = d as? [String : Any] {
                            
                            if let json = try?JSONSerialization.data(withJSONObject: d, options: []) {
                                if let content = String(data: json, encoding: String.Encoding.utf8) {
                                    contents = content
                                }
                                
                            }
                            let data = (contents).data(using:.utf8)
                            
                            do {
                                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                                let phone_number:NSArray = jsonResult.value(forKey: "phone_number") as! NSArray
                                if(phone_number.count > 0){
                                    contact_phone = Themes.sharedInstance.CheckNullvalue(Passed_value: (phone_number[0] as! NSDictionary).value(forKey: "value"))
                                }
                            }catch{
                                
                            }
                            
                            id = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "contact_id"))
                            if(id != ""){
                                profile = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "contact_profile"))
                                profile = profile.replacingOccurrences(of: "/./", with: "/")
                                profile = profile == "" ? "photo" : profile
                            }
                            
                            let Contact_details:NSDictionary = ["doc_id":Doc_id,"contact_profile":Themes.sharedInstance.CheckNullvalue(Passed_value:profile),"contact_id":Themes.sharedInstance.CheckNullvalue(Passed_value:id),"contact_name":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "contact_name")),"contact_phone":contact_phone,"contact_details":Themes.sharedInstance.CheckNullvalue(Passed_value: contents)]
                            
                            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Contact_details   as NSDictionary,Entityname: Constant.sharedinstance.Contact_details)
                        }
                        
                    }else if(type == "13"){
                        info_type = "13"
                        let incognito_timer_mode:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "incognito_timer_mode"))
                        var date_component = DateComponents()
                        var seconds:String = "0"
                        
                        if(incognito_timer_mode == "5 seconds"){
                            date_component.second = 5
                            seconds = "5"
                        }else if(incognito_timer_mode == "10 seconds"){
                            date_component.second = 10
                            seconds = "10"
                            
                        }else if(incognito_timer_mode == "30 seconds"){
                            date_component.second = 30
                            seconds = "30"
                            
                        }else if(incognito_timer_mode == "1 minute"){
                            date_component.minute = 1
                            seconds = "60"
                            
                        }else if(incognito_timer_mode == "1 hour"){
                            date_component.hour = 1
                            seconds = "3600"
                            
                        }else if(incognito_timer_mode == "1 day"){
                            date_component.day = 1
                            let calcseconds:Int64 = Int64(24 * 3600)
                            seconds = "\(calcseconds)"
                        }else if(incognito_timer_mode == "1 week"){
                            date_component.day = 7
                            let calcseconds:Int64 = Int64(24 * 7 * 3600)
                            seconds = "\(calcseconds)"
                        }
                        else
                        {
                            seconds = "0"
                        }
                        if(incognito_timer_mode == "off")
                        {
                            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Favourite_Contact, FetchString: from, attribute: "id", UpdationElements: ["secret_timer":""])
                        }
                        else
                        {
                            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Favourite_Contact, FetchString: from, attribute: "id", UpdationElements: ["secret_timer":incognito_timer_mode])
                            
                        }
                        
                        let id:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id"))
                        let dic = ["user_id":from,"incognito_timer":incognito_timer_mode,"timestamp":id,"doc_id":Doc_id,"expiration_time":incognito_timer_mode,"user_common_id":user_common_id,"expire_time_seconds":seconds] as [String : Any]
                        let checkBool:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Secret_Chat, attribute: "doc_id", FetchString: Doc_id)
                        if(checkBool){
                            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Secret_Chat, FetchString: Doc_id, attribute: "doc_id", UpdationElements: dic as NSDictionary)
                        }else{
                            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: dic as NSDictionary, Entityname: Constant.sharedinstance.Secret_Chat)
                        }
                    }
                    let isCallDetailPresent : Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "doc_id", FetchString: Doc_id)
                    
                    if (type == "21"){
                        info_type = "21"
                        let ismessagePresent:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Call_detail, attribute: "doc_id", FetchString: Doc_id)
                        
                        let call_status = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "call_status"))
                        let call_type = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "call_type"))
                        
                        if(!ismessagePresent)
                        {
                            
                            let DBDict:NSDictionary = ["from":Themes.sharedInstance.CheckNullvalue(Passed_value:from),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:to),"call_status":call_status,"user_id":Themes.sharedInstance.Getuser_id(),"doc_id":Doc_id,"id":EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id")), toid: from, chat_type: Chattype),"timestamp":timestamp,"call_type":call_type,"msidn":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "ContactMsisdn")),"call_duration":"00:00", "recordId" : Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "recordId"))]
                            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: DBDict, Entityname: Constant.sharedinstance.Call_detail)
                        }
                        else
                            
                        {
                            let DBDict:NSDictionary = ["from":Themes.sharedInstance.CheckNullvalue(Passed_value:from),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:to),"call_status":call_status,"user_id":Themes.sharedInstance.Getuser_id(),"id":EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id")), toid: from, chat_type: Chattype),"timestamp":timestamp,"call_type":call_type, "recordId" : Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "recordId"))]
                            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Call_detail, FetchString: Doc_id, attribute: "doc_id", UpdationElements: DBDict)
                            
                        }
                    }
                    let status:String = "2"
                    //            if(type == "13"){
                    //                status = "3"
                    //
                    //            }
                    
                    var message:String = ""
                    if(ResponseDict.object(forKey: "payload") != nil)
                    {
                        message  = EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "payload")), toid: from, chat_type: Chattype) as! String
                    }
                    else if(ResponseDict.object(forKey: "message") != nil)
                    {
                        message  = EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "message")), toid: from, chat_type: Chattype) as! String
                    }
                    
                    if(Message_type == "23")
                    {
                        info_type = Message_type
                    }
                    var dic:[AnyHashable: Any] = ["type": Message_type,"convId":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "convId")),"doc_id":Doc_id,"filesize":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "filesize")),"from":Themes.sharedInstance.CheckNullvalue(Passed_value:from
                        ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:to
                        ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "isStar")),"message_status":status,"id":EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id")), toid: from, chat_type: Chattype),"name":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "contact_name")),"payload":message.encoded
                        ,"recordId":recordId,"thumbnail":ThumbnailID,"width":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "width")),"height":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "height")),"msgId":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "msgId")),"contactmsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "ContactMsisdn"))
                        ,"user_common_id":user_common_id,"timestamp":timestamp,"message_from":message_from,"chat_type":Chattype,"info_type":info_type,"created_by":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from")),"is_reply":"0", "reply_type" : reply_type,"secret_msg_id":secret_msg_id,"secret_timestamp":expire_timestamp,"is_secret_chat":is_secret_chat, "date" : Themes.sharedInstance.getTimeStamp()]
                    if(is_deleted == "1")
                    {
                        dic["payload"] = "🚫 This message was deleted."
                        dic["type"] = "0"
                        dic["is_deleted"] = "1"
                    }
                    if(!isCallDetailPresent)
                    {
                        DatabaseHandler.sharedInstance.InserttoDatabase(Dict: dic as NSDictionary,Entityname: Constant.sharedinstance.Chat_one_one)
                    }
                    
                    let chat_type_dict:[String: String] = ["chat_type": Chattype,"user_common_id":from,"offline":"\(isFromoffline)"]
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.Incomingmessage), object: dic , userInfo: chat_type_dict)
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.change_chat_count), object: dic , userInfo: chat_type_dict)
                    let is_mute = Themes.sharedInstance.CheckMuteChats(id: from, type: "single")
                    
                    if(!is_mute && !isFromoffline){

                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.pushView), object: ResponseDict , userInfo: chat_type_dict)
                        
                    }
                }
                else
                {
                    
                }
                
                DispatchQueue.main.async {
                    if(from != Themes.sharedInstance.Getuser_id() && is_deleted == "1")
                    {
                        let timestamp_offlinemessages:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "msgId"));
                        SocketIOManager.sharedInstance.AcknowledegmentHandler(from: Themes.sharedInstance.Getuser_id() as NSString, to: ChatInterlinkID as NSString, status: "2", doc_id: Doc_id as NSString, timestamp: timestamp_offlinemessages as NSString,isEmit_status: true, is_deleted_message_ack: true, chat_type: Chattype, convId: convId)
                        
                    }
                }
            }
        }
        
    }
    
    func StoreIncomingGroupMessage(ResponseDict:NSDictionary,isFromoffline:Bool)
    {
        DispatchQueue.main.async {
            let recordId:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "recordId"));
            let CheckMessage:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "recordId", FetchString: recordId)
            
            if(!CheckMessage)
            {
                //String(Int(Date().timeIntervalSince1970))
                let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from"));
                let to:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "groupId"));
                
                let is_deleted = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "is_deleted_everyone"))
                
                let id:String=EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id")), toid: from, chat_type: "group") as! String;
                
                let timestamp:String=EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id")), toid: from, chat_type: "group") as! String;

                let groupId:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "groupId"));
                
                if(SocketIOManager.sharedInstance.checkGroupMember(id: to) == true){
                    
                    
                    let Doc_id:String=EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "toDocId")), toid: from, chat_type: "group") as! String;
                    //        let message_status:String="1"
                    var message_from:String = ""
                    if(from != Themes.sharedInstance.Getuser_id())
                    {
                        message_from = "0";
                    }
                    else
                    {
                        message_from = "1";
                    }
                    if(to != Themes.sharedInstance.Getuser_id())
                    {
                    }
                    //            if(isFromoffline)
                    //            {
                    let param_ack=["groupType": 12, "from": Themes.sharedInstance.Getuser_id(), "groupId": groupId, "status":1, "msgId":(id as NSString).longLongValue] as [String : Any]
                    SocketIOManager.sharedInstance.GroupmessageAcknowledgement(Param: param_ack)
                    //            }
                    let Check_Fav:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "id", FetchString: from)
                    if(!Check_Fav)
                    {
                        if(from != Themes.sharedInstance.Getuser_id())
                        {
                            let param_userDetails:[String:Any]=["userId":from]
                            SocketIOManager.sharedInstance.EmituserDetails(Param: param_userDetails)
                        }
                    }
                    
                    let CheckUser:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: "\(Themes.sharedInstance.Getuser_id())-\(groupId)")
                    if(!CheckUser)
                    {
                        var Chattype:String=""
                        Chattype="group"
                        let User_dict:[AnyHashable: Any] = ["user_common_id": "\(Themes.sharedInstance.Getuser_id())-\(groupId)","user_to_dp":"0" ,"user_id":Themes.sharedInstance.Getuser_id(),"chat_type":Chattype,"is_archived":"0","conv_id":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "groupId")),"timestamp":timestamp,"opponent_id":groupId,"chat_count":"1","is_read":"0","isSavetocamera":"0"]
                        DatabaseHandler.sharedInstance.InserttoDatabase(Dict: User_dict as NSDictionary,Entityname: Constant.sharedinstance.Chat_intiated_details)
                    }
                    else
                    {
                        let FetchCount:String = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_intiated_details, attrib_name: "user_common_id", fetchString: "\(Themes.sharedInstance.Getuser_id())-\(to)", returnStr: "chat_count")
                        let count:Int = Int(FetchCount)!+1
                        let User_dict:[AnyHashable: Any]=["timestamp":timestamp,"chat_count":"\(count)","is_read":"0","is_archived":"0"]
                        
                        let checkMessage = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "id", FetchString: EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id")), toid: from, chat_type: "group") as? String)
                        if(!checkMessage)
                        {
                            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: "\(Themes.sharedInstance.Getuser_id())-\(groupId)" , attribute: "user_common_id", UpdationElements: User_dict as NSDictionary?)
                        }
                    }
                    
                    AppDelegate.sharedInstance.setBadgeCount()
                    let recordId:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "recordId"));
                    let CheckMessage:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "recordId", FetchString: recordId)
                    var Message_type:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "type"))
                    let info_type = (Message_type == "23") ? "23" : "0"
                    var replyDetails:NSDictionary?
                    if ResponseDict.object(forKey: "replyDetails") != nil {
                        replyDetails =  EncryptionHandler.sharedInstance.decryptData(data: ResponseDict.object(forKey: "replyDetails")!) as? NSDictionary
                    }
                    if(Message_type == "20")
                    {
                        Message_type = "6"
                    }
                    
                    if(replyDetails != nil)
                    {
                        if(replyDetails!.count > 0)
                        {
                            Message_type = "7"
                            
                            let Fromidn:String = Themes.sharedInstance.CheckNullvalue(Passed_value: replyDetails?.object(forKey: "From_msisdn"))
                            let message:String = Themes.sharedInstance.CheckNullvalue(Passed_value: replyDetails?.object(forKey: "message"))
                            //            let server_load:String = Themes.sharedInstance.CheckNullvalue(Passed_value: replyDetails?.object(forKey: "server_load"))
                            let from:String = Themes.sharedInstance.CheckNullvalue(Passed_value: replyDetails?.object(forKey: "from"))
                            let Reply_Message_type:String = Themes.sharedInstance.CheckNullvalue(Passed_value: replyDetails?.object(forKey: "type"))
                            
                            let thumbnail_data:String = Themes.sharedInstance.CheckNullvalue(Passed_value: replyDetails?.object(forKey: "thumbnail_data"))
                            let CheckReplyMessage:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Reply_detail, attribute: "recordId", FetchString: recordId)
                            if(!CheckReplyMessage)
                            {
                                let Dict:NSDictionary = ["compressed_data":thumbnail_data,"from_id":from,"recordId":recordId,"message_type":Reply_Message_type,"payload":message.encoded,"contactmsisdn":Fromidn,"doc_id":Doc_id]
                                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict, Entityname: Constant.sharedinstance.Reply_detail)
                            }
                        }
                    }
                    if(CheckMessage)
                    {
                        var ThumbnailID:String = String()
                        
                        ThumbnailID = ""
                        
                        if(Message_type == "0" || Message_type == "7")
                        {
                            ThumbnailID = EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "original_filename")), toid: from, chat_type: "group") as! String
                        }
                        
                        if(Message_type == "1" || Message_type == "2" || Message_type == "3")
                        {
                            ThumbnailID =   Doc_id
                        }
                        else if (Message_type == "6")
                        {
                            ThumbnailID =   Doc_id
                            
                        }
                            
                        else if (Message_type == "14")
                        {
                            ThumbnailID =   Doc_id
                            
                        }else if(Message_type == "5"){
                            ThumbnailID =   Doc_id
                        }
                        let message:String = EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "payload")), toid: from, chat_type: "group") as! String
                        
                        var dic:[AnyHashable: Any] = ["type": Message_type,"convId":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "groupId")),"doc_id":Doc_id,"filesize":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "filesize")),"from":Themes.sharedInstance.CheckNullvalue(Passed_value:from
                            ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:to
                            ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "isStar")),"message_status":"2","id":id,"name":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "contact_name")),"payload":message.encoded
                            ,"recordId":recordId,"thumbnail":ThumbnailID,"width":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "width")),"height":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "height")),"msgId":id,"contactmsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "msisdn"))
                            ,"user_common_id":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(Themes.sharedInstance.Getuser_id())-\(groupId)"
                            ),"message_from":message_from,"chat_type":"group","info_type":info_type,"created_by":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from")),"is_reply":"0"]
                        
                        if(is_deleted == "1")
                        {
                            dic["payload"] = "🚫 This message was deleted."
                            dic["type"] = "0"
                            dic["is_deleted"] = "1"
                        }
                        
                        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_one_one,FetchString: recordId, attribute:"recordId", UpdationElements: dic as NSDictionary?)
                    }
                    else
                    {
                        var ThumbnailID:String = String()
                        
                        ThumbnailID = ""
                        
                        if(Message_type == "0" || Message_type == "7")
                        {
                            ThumbnailID = EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "original_filename")), toid: from, chat_type: "group") as! String
                        }
                        
                        if(Message_type == "1" || Message_type == "2" || Message_type == "3")
                        {
                            ThumbnailID = Doc_id
                            var ServerPath_path:String = EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "thumbnail")), toid: from, chat_type: "group") as! String
                            if(ServerPath_path.substring(to: 1) == ".")
                            {
                                ServerPath_path.remove(at: ServerPath_path.startIndex)
                                ServerPath_path = ("\(ImgUrl)\(ServerPath_path)")
                            }
                            let thumbnail_data = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "thumbnail_data"))
                            let Dict:[String:Any] = ["failure_status":"0","total_byte_count":"0","upload_byte_count":"0","upload_count":"1","upload_data_id":ThumbnailID,"upload_Path":"","upload_status":"1","serverpath":ServerPath_path,"data_count":"0","compressed_data":thumbnail_data,"to_id":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "groupId")),"message_status":"1","user_common_id":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(Themes.sharedInstance.Getuser_id())-\(Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "groupId")))"),"user_id":Themes.sharedInstance.Getuser_id(),"download_status":"0","upload_type":"\(Message_type)","is_uploaded":"0", "upload_paused":"0"]
                            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict as NSDictionary, Entityname: Constant.sharedinstance.Upload_Details);
                            DownloadHandler.sharedinstance.handleDownLoad(false)
                        }
                        else if (Message_type == "6")
                        {
                            ThumbnailID = Doc_id
                            
                            var document_type:String = ""
                            
                            ThumbnailID = Doc_id
                            let thumbnail_data = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "thumbnail_data"))
                            let numPages = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "numPages"))
                            var ServerPath_path:String = EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "thumbnail")), toid: from, chat_type: "group") as! String
                            if(ServerPath_path.substring(to: 1) == ".")
                            {
                                ServerPath_path.remove(at: ServerPath_path.startIndex)
                                ServerPath_path = ("\(ImgUrl)\(ServerPath_path)")
                            }
                            
                            if((ServerPath_path as NSString).pathExtension.uppercased() == "PDF")
                            {
                                document_type = "1"
                            }
                            else
                            {
                                document_type = "2"
                            }
                            
                            let original_filename:String! = EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "original_filename")), toid: from, chat_type: "group") as? String

                            let Dict:[String:Any] = ["failure_status":"0","total_byte_count":"0","upload_byte_count":"0","upload_count":"1","upload_data_id":ThumbnailID,"upload_Path":"","upload_status":"1","serverpath":ServerPath_path,"data_count":"0","compressed_data":thumbnail_data,"to_id":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "groupId")),"message_status":"1","user_common_id":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(Themes.sharedInstance.Getuser_id())-\(Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "groupId")))"),"user_id":Themes.sharedInstance.Getuser_id(),"download_status":"0","upload_type":"\(Message_type)","doc_name":original_filename,"doc_type":document_type,"doc_pagecount":numPages,"is_uploaded":"0", "upload_paused":"0"]
                            
                            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict as NSDictionary, Entityname: Constant.sharedinstance.Upload_Details);
                            DownloadHandler.sharedinstance.handleDownLoad(false)
                        }
                            
                        else if (Message_type == "14")
                        {
                            ThumbnailID = Doc_id
                            var metaDetails:NSDictionary?
                            if ResponseDict.object(forKey: "link_details") != nil {
                                metaDetails =  EncryptionHandler.sharedInstance.Decryptmessage(str: ResponseDict.object(forKey: "link_details") as Any, toid: from, chat_type: "group") as? NSDictionary
                            }
                            if(metaDetails != nil)
                            {
                                if((metaDetails?.count)! > 0)
                                {
                                    let locationDetail = Themes.sharedInstance.CheckNullvalue(Passed_value: metaDetails?.object(forKey: "image"))
                                    var CoordinateArr = [String]()
                                    if(locationDetail.slice(from: "color:red|", to: "&zoom=") != nil)
                                    {
                                        CoordinateArr = locationDetail.slice(from: "color:red|", to: "&zoom=")!.components(separatedBy: ",")
                                    }
                                    else
                                    {
                                        CoordinateArr = locationDetail.slice(from: "center=", to: "&zoom=")!.components(separatedBy: ",")
                                    }
                                    var lat:String = String()
                                    var lng:String = String()
                                    
                                    if(CoordinateArr.count > 0)
                                    {
                                        lat = CoordinateArr[0]
                                        lng = CoordinateArr[1]
                                    }
                                    
                                    let RedirectLink:String = Themes.sharedInstance.CheckNullvalue(Passed_value: metaDetails?.object(forKey: "url"))
                                    let LocationDIct:NSDictionary = ["doc_id":Doc_id,"image_link":Themes.sharedInstance.CheckNullvalue(Passed_value: metaDetails?.object(forKey: "image")),"lat":"\(lat)","long":"\(lng)","redirect_link":RedirectLink,"thumbnail_data":Themes.sharedInstance.CheckNullvalue(Passed_value: metaDetails?.object(forKey: "thumbnail_data")),"title":Themes.sharedInstance.CheckNullvalue(Passed_value: metaDetails?.object(forKey: "title")),"stitle":Themes.sharedInstance.CheckNullvalue(Passed_value: metaDetails?.object(forKey: "description"))]
                                    DatabaseHandler.sharedInstance.InserttoDatabase(Dict: LocationDIct as NSDictionary,Entityname: Constant.sharedinstance.Location_details)
                                    
                                    
                                }
                                
                            }
                        }
                        else if(Message_type == "4"){
                            var metaDetails:NSDictionary?
                            if ResponseDict.object(forKey: "link_details") != nil {
                                metaDetails =  EncryptionHandler.sharedInstance.Decryptmessage(str: ResponseDict.object(forKey: "link_details") as Any, toid: from, chat_type: "group") as? NSDictionary
                            }
                            if(metaDetails != nil)
                            {
                                if((metaDetails?.count)! > 0)
                                {
                                    let Link_details:NSDictionary = ["doc_id":Doc_id,"image_url":Themes.sharedInstance.CheckNullvalue(Passed_value: metaDetails?.object(forKey: "image")),"title":Themes.sharedInstance.CheckNullvalue(Passed_value: metaDetails?.object(forKey: "title")),"desc":Themes.sharedInstance.CheckNullvalue(Passed_value: metaDetails?.object(forKey: "description")).encoded,"url_str":Themes.sharedInstance.CheckNullvalue(Passed_value: metaDetails?.object(forKey: "url")),"thumbnail_data":Themes.sharedInstance.CheckNullvalue(Passed_value: metaDetails?.object(forKey: "thumbnail_data"))]
                                    
                                    
                                    DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Link_details as NSDictionary,Entityname: Constant.sharedinstance.Link_details)
                                    
                                    
                                    
                                }
                                
                            }
                            
                            
                        }
                        else if (Message_type == "5"){
                            var profile = ""
                            var id = ""
                            var contents = ""
                            var contact_phone = ""
                            let d = EncryptionHandler.sharedInstance.Decryptmessage(str: ResponseDict.object(forKey: "contact_details") as Any, toid: from, chat_type: "group")
                            if let d = d as? [String : Any] {
                                if let json = try?JSONSerialization.data(withJSONObject: d, options: []) {
                                    if let content = String(data: json, encoding: String.Encoding.utf8) {
                                        contents = content
                                    }
                                    
                                }
                                
                                let data = (contents).data(using:.utf8)
                                
                                do {
                                    
                                    let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                                    let phone_number:NSArray = jsonResult.value(forKey: "phone_number") as! NSArray
                                    if(phone_number.count > 0){
                                        contact_phone = Themes.sharedInstance.CheckNullvalue(Passed_value: (phone_number[0] as! NSDictionary).value(forKey: "value"))
                                    }
                                }catch{
                                    
                                }
                                
                                id = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "contact_id"))
                                if(id != ""){
                                    profile = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "contact_profile"))
                                    profile = profile.replacingOccurrences(of: "/./", with: "/")
                                    profile = profile == "" ? "photo" : profile
                                }
                                
                                
                                let Contact_details:NSMutableDictionary = ["doc_id":Doc_id,"contact_profile":Themes.sharedInstance.CheckNullvalue(Passed_value:profile),"contact_id":Themes.sharedInstance.CheckNullvalue(Passed_value:id),"contact_name":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "contact_name")),"contact_phone":Themes.sharedInstance.CheckNullvalue(Passed_value: contact_phone),"contact_details":Themes.sharedInstance.CheckNullvalue(Passed_value: contents)]
                                
                                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Contact_details   as NSDictionary,Entityname: Constant.sharedinstance.Contact_details)
                            }
                            
                        }
                        let message:String = EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "payload")), toid: from, chat_type: "group") as! String
                        
                        var dic:[AnyHashable: Any] = ["type": Message_type,"convId":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "groupId")),"doc_id":Doc_id,"filesize":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "filesize")),"from":Themes.sharedInstance.CheckNullvalue(Passed_value:from
                            ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:to
                            ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "isStar")),"message_status":"2","id":id,"name":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "contact_name")),"payload":message.encoded
                            ,"recordId":recordId,"thumbnail":ThumbnailID,"width":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "width")),"height":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "height")),"msgId":id,"contactmsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "msisdn"))
                            ,"user_common_id":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(Themes.sharedInstance.Getuser_id())-\(groupId)"
                            ),"message_from":message_from,"timestamp":timestamp,"chat_type":"group","info_type":info_type,"created_by":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from")),"is_reply":"0", "date" : Themes.sharedInstance.getTimeStamp()]
                        
                        if(is_deleted == "1")
                        {
                            dic["payload"] = "🚫 This message was deleted."
                            dic["type"] = "0"
                            dic["is_deleted"] = "1"
                        }
                        
                        DatabaseHandler.sharedInstance.InserttoDatabase(Dict: dic as NSDictionary,Entityname: Constant.sharedinstance.Chat_one_one)
                        
                        let chat_type_dict:[String: String] = ["chat_type": "group","user_common_id":to,"offline":"\(isFromoffline)"]
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.Incomingmessage), object: dic , userInfo: chat_type_dict)
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.change_chat_count), object: dic , userInfo: chat_type_dict)
                        
                        let is_mute = Themes.sharedInstance.CheckMuteChats(id: groupId, type: "group")
                        
                        if(!is_mute && !isFromoffline){

                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.pushView), object: ResponseDict , userInfo: chat_type_dict)
                        }
                    }
                    DispatchQueue.main.async {
                        if(from != Themes.sharedInstance.Getuser_id() && is_deleted == "1")
                        {
                            let param_ack=["groupType": 21, "from": Themes.sharedInstance.Getuser_id(), "groupId": groupId, "status":2, "msgId":(id as NSString).longLongValue] as [String : Any]
                            SocketIOManager.sharedInstance.GroupmessageAcknowledgement(Param: param_ack)
                        }
                    }
                }
            }
        }
    }
    
    
    func StoreIncomingStatusMessage(ResponseDict:NSDictionary,isFromoffline:Bool)
    {
        DispatchQueue.main.async {
            
            let timestamp:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id"));
            let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from"));
            let type:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "type"));
            let status:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "status"));
            var Doc_id:String = ""
            var msisdn:String = ""
            var Chattype:String=""
            Chattype="single"
            var user_common_id:String = ""
            let info_type:String = "0"
            if(isFromoffline)
            {
                Doc_id=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "docId"));
                msisdn = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "ContactMsisdn"))
            }
            else
            {
                Doc_id=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "doc_id"));
                msisdn = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "From_msisdn"))
            }
            let message_status:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "message_status"));
            
            var message_from:String=""
            if(from != Themes.sharedInstance.Getuser_id())
            {
                
                message_from="0";
            }
            else
            {
                message_from="1";
            }
            
            user_common_id = Themes.sharedInstance.CheckNullvalue(Passed_value:from)
            
            if(type != "13"){
                if(message_status == "0" || message_status == "1" || status == "1")
                {
                    if(from != Themes.sharedInstance.Getuser_id())
                    {
                        let timestamp_offlinemessages:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "msgId"));
                        SocketIOManager.sharedInstance.StatusAcknowledegmentHandler(from: Themes.sharedInstance.Getuser_id() as NSString, to: from as NSString, status: "2", doc_id: Doc_id as NSString, timestamp: timestamp_offlinemessages as NSString,isEmit_status: true, chat_type: Chattype)
                    }
                }
            }
            
            let Check_Fav:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "id", FetchString: from)
            if(!Check_Fav)
            {
                if(from != Themes.sharedInstance.Getuser_id())
                {
                    let param_userDetails:[String:Any]=["userId":from]
                    SocketIOManager.sharedInstance.EmituserDetails(Param: param_userDetails)
                }
            }
            let CheckUser:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: "\(Constant.sharedinstance.Status_initiated_details)", attribute: "user_common_id", FetchString: from)
            if(!CheckUser)
            {
                let User_dict:[AnyHashable: Any] = ["user_common_id": from, "user_to_dp":"0" ,"user_id":Themes.sharedInstance.Getuser_id(),"chat_type":Chattype,"is_archived":"0","conv_id":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "convId")),"opponent_id": "","chat_count":"1","is_read":"0"]
                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: User_dict as NSDictionary,Entityname: "\(Constant.sharedinstance.Status_initiated_details)")
            }else{
                let FetchCount:String = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Status_initiated_details, attrib_name: "user_common_id", fetchString: from, returnStr: "chat_count")
                let count:Int = Int(FetchCount)!+1
                let User_dict:[AnyHashable: Any]=["timestamp":timestamp,"chat_count":"\(count)","is_read":"0","user_id":Themes.sharedInstance.Getuser_id(), "is_archived" : "0"]
                let checkMessage = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Status_one_one, attribute: "msgId", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "msgId")))
                if(!checkMessage)
                {
                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Status_initiated_details, FetchString: from , attribute: "user_common_id", UpdationElements: User_dict as NSDictionary?)
                }
            }
            let recordId:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "recordId"));
            
            let CheckMessage : Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Status_one_one, attribute: "doc_id", FetchString: Doc_id)
            
            let Message_type:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "type"))
            if(!CheckMessage)
            {
                var ThumbnailID:String = String()
                if(type == "1" || type == "2")
                {
                    ThumbnailID = Doc_id
                    var ServerPath_path:String =  Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "thumbnail"))
                    if(ServerPath_path.substring(to: 1) == ".")
                    {
                        ServerPath_path.remove(at: ServerPath_path.startIndex)
                        ServerPath_path = ("\(ImgUrl)\(ServerPath_path)")
                    }
                    let thumbnail_data = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "thumbnail_data"))
                    let Dict:[String:Any] = ["failure_status":"0","total_byte_count":"0","upload_byte_count":"0","upload_count":"1","upload_data_id":ThumbnailID,"upload_Path":"","upload_status":"1","serverpath":ServerPath_path,"data_count":"0","compressed_data":thumbnail_data,"to_id":"","message_status":"1","user_common_id":user_common_id,"user_id":Themes.sharedInstance.Getuser_id(),"download_status":"0","upload_type":"\(type)","is_uploaded":"0", "upload_paused" : "0"]
                    DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict as NSDictionary, Entityname: Constant.sharedinstance.Status_Upload_Details);
                    
                }
                
                let isCallDetailPresent : Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Status_one_one, attribute: "doc_id", FetchString: Doc_id)
                
                let status:String = "2"
                let message:String =  Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "payload"))
                let dic:[AnyHashable: Any] = ["type": Message_type,"convId":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "convId")),"doc_id":Doc_id,"filesize":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "filesize")),"from":Themes.sharedInstance.CheckNullvalue(Passed_value:from
                    ),"to":"", "isStar":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "isStar")),"message_status":status,"id":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id")),"name":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "contact_name")),"payload":message.encoded
                    ,"recordId":recordId,"thumbnail":ThumbnailID,"width":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "width")),"height":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "height")),"msgId":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "msgId")),"contactmsisdn":msisdn
                    ,"user_common_id":user_common_id,"timestamp":timestamp,"message_from":message_from,"chat_type":Chattype,"info_type":info_type,"created_by":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from")),"is_reply":"0", "duration" : Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "duration")), "theme_color" : Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "theme_color")), "theme_font" : Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "theme_font")), "date" : Themes.sharedInstance.getTimeStamp()]
                if(!isCallDetailPresent)
                {
                    DatabaseHandler.sharedInstance.InserttoDatabase(Dict: dic as NSDictionary,Entityname: Constant.sharedinstance.Status_one_one)
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.incomingstatus), object: nil , userInfo: nil)
                
            }
        }
    }
    
    
    
    
}


