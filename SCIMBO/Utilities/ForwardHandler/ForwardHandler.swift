//
//  ForwardHandler.swift

//
//  Created by Casperon iOS on 04/09/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

typealias CompletionCallback = (_ success: Bool, _ sentcount: Int, _ personcount: Int) -> ()
class ForwardHandler : NSObject
{
    var index:Int = Int()
    var personindex:Int = Int()
    static let sharedInstance = ForwardHandler()
    var DoneCallback: CompletionCallback?;
    func forward(messageArr : [AnyObject], toPersons : [AnyObject], completion: CompletionCallback!)
    {
        DoneCallback = completion
        for i in 0..<toPersons.count
        {
            personindex = i + 1;
            for j in 0..<messageArr.count
            {
                index = j + 1
                let messageDetail : UUMessageFrame  = messageArr[j] as! UUMessageFrame
                let user : NSDictionary = toPersons[i] as! NSDictionary
                self.forward(message: messageDetail, person: user, type: user.value(forKey: "type") as! String)
            }
        }
    }
    
    func forward(message: UUMessageFrame, person: NSDictionary, type: String) {
        
        let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
        let to:String=Themes.sharedInstance.CheckNullvalue(Passed_value: person["id"])
        var timestamp:String = String(Date().ticks)
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
        if(type == "group")
        {
            toDocId = "\(from)-\(to)-g-\(timestamp)"
        }
        let message_type = Themes.sharedInstance.CheckNullvalue(Passed_value: message.message.message_type) == "7" ? "0" : Themes.sharedInstance.CheckNullvalue(Passed_value: message.message.message_type)
        let dic:[AnyHashable: Any] = ["type": message_type,
                                      "convId":"",
                                      "doc_id":Themes.sharedInstance.CheckNullvalue(Passed_value:toDocId),
                                      "filesize":"",
                                      "from":Themes.sharedInstance.CheckNullvalue(Passed_value:from),
                                      "to":Themes.sharedInstance.CheckNullvalue(Passed_value:to),
                                      "isStar":"0",
                                      "message_status":"0",
                                      "id":timestamp,
                                      "name":Name,
                                      "payload":Themes.sharedInstance.CheckNullvalue(Passed_value: message.message.payload),
                                      "recordId":"",
                                      "timestamp":timestamp,
                                      "thumbnail":toDocId,
                                      "width":"0.0",
                                      "height":"0.0",
                                      "msgId":timestamp,
                                      "contactmsisdn":Phonenumber,
                                      "user_common_id":from + "-" + to,
                                      "message_from":"1",
                                      "chat_type":type,
                                      "info_type":"0",
                                      "created_by":from,
                                      "docType": Themes.sharedInstance.CheckNullvalue(Passed_value: message.message.docType),
                                      "docName":Themes.sharedInstance.CheckNullvalue(Passed_value: message.message.docName),
                                      "docPageCount":Themes.sharedInstance.CheckNullvalue(Passed_value: message.message.docPageCount),
                                      "title":Themes.sharedInstance.CheckNullvalue(Passed_value: message.message.title_str),
                                      "image_url":Themes.sharedInstance.CheckNullvalue(Passed_value: message.message.imageURl),
                                      "desc":Themes.sharedInstance.CheckNullvalue(Passed_value: message.message.desc),
                                      "url_str":Themes.sharedInstance.CheckNullvalue(Passed_value: message.message.url_str),
                                      "contact_profile": Themes.sharedInstance.CheckNullvalue(Passed_value: message.message.contact_profile),
                                      "contact_phone":Themes.sharedInstance.CheckNullvalue(Passed_value: message.message.contact_phone),
                                      "contact_id":Themes.sharedInstance.CheckNullvalue(Passed_value: message.message.contact_id),
                                      "contact_name":Themes.sharedInstance.CheckNullvalue(Passed_value: message.message.contact_name),
                                      "contact_details":Themes.sharedInstance.CheckNullvalue(Passed_value: message.message.contact_details),
                                      "is_reply":"0",
                                      "is_forward" : "1",
                                      "msgType" : Themes.sharedInstance.CheckNullvalue(Passed_value: message.message.chat_type),
                                      "msgrecordId" : Themes.sharedInstance.CheckNullvalue(Passed_value: message.message.recordId), "date" : Themes.sharedInstance.getTimeStamp()]
        
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
        let ImageDetailArr =  DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Upload_Details, attribute: "upload_data_id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: message.message.doc_id), SortDescriptor: nil) as! [Upload_Details]
        if ImageDetailArr.count > 0 {
            let ImageDetailDict = ImageDetailArr[0]
            let Dict:[String:Any] = ["failure_status": Themes.sharedInstance.CheckNullvalue(Passed_value: ImageDetailDict.failure_status),
                                     "total_byte_count": Themes.sharedInstance.CheckNullvalue(Passed_value: ImageDetailDict.total_byte_count),
                                     "upload_byte_count": Themes.sharedInstance.CheckNullvalue(Passed_value: ImageDetailDict.upload_byte_count),
                                     "upload_count": Themes.sharedInstance.CheckNullvalue(Passed_value: ImageDetailDict.upload_count),
                                     "upload_data_id":toDocId,
                                     "upload_Path": Themes.sharedInstance.CheckNullvalue(Passed_value: ImageDetailDict.upload_Path),
                                     "upload_status":"1",
                                     "user_common_id":from + "-" + to,
                                     "serverpath":"",
                                     "user_id":Themes.sharedInstance.Getuser_id(),
                                     "data_count": Themes.sharedInstance.CheckNullvalue(Passed_value: ImageDetailDict.data_count),
                                     "compressed_data": Themes.sharedInstance.CheckNullvalue(Passed_value: ImageDetailDict.compressed_data),
                                     "to_id":to,
                                     "message_status":"0",
                                     "timestamp":timestamp,
                                     "total_data_count": Themes.sharedInstance.CheckNullvalue(Passed_value: ImageDetailDict.total_data_count),
                                     "width": Themes.sharedInstance.CheckNullvalue(Passed_value: ImageDetailDict.width),
                                     "height": Themes.sharedInstance.CheckNullvalue(Passed_value: ImageDetailDict.height),
                                     "upload_type":Themes.sharedInstance.CheckNullvalue(Passed_value: message.message.message_type),
                                     "doc_name": Themes.sharedInstance.CheckNullvalue(Passed_value: ImageDetailDict.doc_name),
                                     "doc_type":Themes.sharedInstance.CheckNullvalue(Passed_value: ImageDetailDict.doc_type),
                                     "doc_pagecount": Themes.sharedInstance.CheckNullvalue(Passed_value: ImageDetailDict.doc_pagecount),
                                     "download_status":"2",
                                     "is_uploaded":"1",
                                     "upload_paused":"0"]
            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict as NSDictionary, Entityname: Constant.sharedinstance.Upload_Details);
        }
        let LinkDetailArr =  DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Link_details, attribute: "doc_id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: message.message.doc_id), SortDescriptor: nil) as! [Link_details]
        if LinkDetailArr.count > 0 {
            let LinkDetailDict = LinkDetailArr[0]
            let link_dic:[AnyHashable: Any] = ["doc_id":toDocId,
                                               "title":Themes.sharedInstance.CheckNullvalue(Passed_value: LinkDetailDict.title),
                                               "thumbnail_data":Themes.sharedInstance.CheckNullvalue(Passed_value: LinkDetailDict.image_url),
                                               "image_url":Themes.sharedInstance.CheckNullvalue(Passed_value: LinkDetailDict.image_url),
                                               "desc":Themes.sharedInstance.CheckNullvalue(Passed_value: LinkDetailDict.desc),
                                               "url_str":Themes.sharedInstance.CheckNullvalue(Passed_value: LinkDetailDict.url_str)]
            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: link_dic as NSDictionary,Entityname: "\(Constant.sharedinstance.Link_details)")
        }
        let ContactDetailArr =  DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Contact_details, attribute: "doc_id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: message.message.doc_id), SortDescriptor: nil) as! [Contact_details]
        if ContactDetailArr.count > 0 {
            let ContactDetailDict = ContactDetailArr[0]
            let contact_dic:[AnyHashable: Any] = ["doc_id":toDocId,
                                                  "contact_profile":Themes.sharedInstance.CheckNullvalue(Passed_value: ContactDetailDict.contact_profile),
                                                  "contact_phone":Themes.sharedInstance.CheckNullvalue(Passed_value: ContactDetailDict.contact_phone),
                                                  "contact_id":Themes.sharedInstance.CheckNullvalue(Passed_value: ContactDetailDict.contact_id),
                                                  "contact_name":Themes.sharedInstance.CheckNullvalue(Passed_value: ContactDetailDict.contact_name),
                                                  "contact_details":Themes.sharedInstance.CheckNullvalue(Passed_value: ContactDetailDict.contact_details)]
            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: contact_dic as NSDictionary,Entityname: Constant.sharedinstance.Contact_details)
        }
        
        let LocationDetailArr =  DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Location_details, attribute: "doc_id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: message.message.doc_id), SortDescriptor: nil) as! [Location_details]
        if LocationDetailArr.count > 0 {
            let LocationDetailDict = LocationDetailArr[0]
            let location_dic:[AnyHashable: Any] = ["doc_id":toDocId,
                                                   "image_link":Themes.sharedInstance.CheckNullvalue(Passed_value: LocationDetailDict.image_link),
                                                   "lat":Themes.sharedInstance.CheckNullvalue(Passed_value: LocationDetailDict.lat),
                                                   "long":Themes.sharedInstance.CheckNullvalue(Passed_value: LocationDetailDict.long),
                                                   "redirect_link":Themes.sharedInstance.CheckNullvalue(Passed_value: LocationDetailDict.redirect_link),
                                                   "thumbnail_data":"",
                                                   "title":Themes.sharedInstance.CheckNullvalue(Passed_value: LocationDetailDict.title),
                                                   "stitle":Themes.sharedInstance.CheckNullvalue(Passed_value: LocationDetailDict.stitle)]
            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: location_dic as NSDictionary,Entityname: Constant.sharedinstance.Location_details)

        }

        if(type == "single")
        {
            SocketIOManager.sharedInstance.SendForwardMessage(from: Themes.sharedInstance.Getuser_id(), to: to, msgType: Themes.sharedInstance.CheckNullvalue(Passed_value: message.message.chat_type), id: timestamp, toDocId: toDocId, recordId: Themes.sharedInstance.CheckNullvalue(Passed_value: message.message.recordId))
        }
        else  if(type == "group")
        {
            let Groupdic:[AnyHashable: Any] = ["from":Themes.sharedInstance.Getuser_id(),"to":to, "msgType" : Themes.sharedInstance.CheckNullvalue(Passed_value: message.message.chat_type), "id" : (timestamp as NSString).longLongValue, "toDocId":toDocId, "recordId" : Themes.sharedInstance.CheckNullvalue(Passed_value: message.message.recordId), "groupType":"17"]
            SocketIOManager.sharedInstance.SendMessage_group(param: Groupdic as NSDictionary)
        }
        DoneCallback!(true, index, personindex)
    }
}

