//
//  Callhandler.swift
//
//
//  Created by MV Anand Casp iOS on 28/09/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit
import UserNotifications

class Callhandler: NSObject {
    
    var timer:Timer!
    static let sharedInstance = Callhandler()
    
    let socket = SocketIOManager.sharedInstance.socket
    func DidreceivecallNotification()
    {
        
        
    }
    func CallIncomingAcknowledgement(responseDict:NSDictionary)
    {
        
        if(responseDict.count > 0)
        {
            let from:String = Themes.sharedInstance.CheckNullvalue(Passed_value: responseDict.object(forKey: "from"))
            if(from == Themes.sharedInstance.Getuser_id())
            {
                
            }
            else
            {
                let objcallrecord = self.ReturnCallRecord(responseDict: responseDict)!
                let profileArray:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "id", FetchString: "from", SortDescriptor: nil) as! NSArray
                if(profileArray.count > 0){
                    let dic:NSManagedObject = profileArray[0] as! NSManagedObject
                    objcallrecord.To_avatar = Themes.sharedInstance.CheckNullvalue(Passed_value: dic.value(forKey: "profilepic"))
                }
                
                let param:[String:Any] = ["from":Themes.sharedInstance.Getuser_id(),"to":objcallrecord.from,"msgIds":(objcallrecord.msgId as NSString).longLongValue,"doc_id":objcallrecord.doc_id,"status":"1"]
                
                var timestamp:String = String(Date().ticks)
                var servertimeStr:String = Themes.sharedInstance.getServerTime()
                
                if(servertimeStr == "")
                {
                    servertimeStr = "0"
                }
                let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
                timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
                
                let ismessagePresent:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Call_detail, attribute: "doc_id", FetchString: objcallrecord.doc_id)
                if(!ismessagePresent)
                {
                    let DBDict:NSDictionary = ["from":objcallrecord.from,"to":Themes.sharedInstance.Getuser_id(),"call_status":Constant.sharedinstance.call_status_ARRIVED,"user_id":Themes.sharedInstance.Getuser_id(),"doc_id":objcallrecord.doc_id,"id":objcallrecord.msgId,"timestamp":timestamp,"call_type":objcallrecord.type,"msidn":objcallrecord.ContactMsisdn,"call_duration":"00:00", "recordId" : objcallrecord.recordId]
                    DatabaseHandler.sharedInstance.InserttoDatabase(Dict: DBDict, Entityname: Constant.sharedinstance.Call_detail)
                    
                }
                else
                {
                    let DBDict:NSDictionary = ["from":objcallrecord.from,"to":Themes.sharedInstance.Getuser_id(),"call_status":Constant.sharedinstance.call_status_ARRIVED,"user_id":Themes.sharedInstance.Getuser_id(),"id":objcallrecord.msgId,"timestamp":timestamp,"call_type":objcallrecord.type,"msidn":objcallrecord.ContactMsisdn, "recordId" : objcallrecord.recordId]
                    
                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Call_detail, FetchString: objcallrecord.doc_id, attribute: "doc_id", UpdationElements: DBDict)
                }
                let user_dict:NSDictionary = ["current_call_status":Constant.sharedinstance.call_in_ringing,"call_id":objcallrecord.doc_id]
                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail, FetchString: Themes.sharedInstance.Getuser_id(), attribute: "user_id", UpdationElements: user_dict)
                let CallStatusDict:NSDictionary = ["from":objcallrecord.from,"to":Themes.sharedInstance.Getuser_id(),"call_status":Constant.sharedinstance.call_status_ARRIVED,"toDocId":objcallrecord.doc_id,"id":objcallrecord.msgId,"recordId":objcallrecord.recordId]
                SocketIOManager.sharedInstance.EmitCallStatus(ResponseDict: CallStatusDict)
                SocketIOManager.sharedInstance.emitCallAck(Param: param)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.incomingcall), object: objcallrecord , userInfo: nil)
                
            }
            
        }
    }
    
    func ReturnCallRecord(responseDict:NSDictionary)->Call_record?
    {
        let objcallrecord:Call_record = Call_record()
        if(responseDict.count > 0)
        {
            objcallrecord.sendername = Themes.sharedInstance.CheckNullvalue(Passed_value: responseDict.object(forKey: "sendername"))
            objcallrecord.ContactMsisdn = Themes.sharedInstance.CheckNullvalue(Passed_value: responseDict.object(forKey: "ContactMsisdn"))
            objcallrecord.From_avatar = Themes.sharedInstance.CheckNullvalue(Passed_value: responseDict.object(forKey: "From_avatar"))
            objcallrecord.To_avatar = Themes.sharedInstance.CheckNullvalue(Passed_value: responseDict.object(forKey: "To_avatar"))
            objcallrecord.To_msisdn = Themes.sharedInstance.CheckNullvalue(Passed_value: responseDict.object(forKey: "To_msisdn"))
            objcallrecord.call_status = Themes.sharedInstance.CheckNullvalue(Passed_value: responseDict.object(forKey: "call_status"))
            objcallrecord.doc_id = Themes.sharedInstance.CheckNullvalue(Passed_value: responseDict.object(forKey: "doc_id"))
            objcallrecord.from = Themes.sharedInstance.CheckNullvalue(Passed_value: responseDict.object(forKey: "from"))
            objcallrecord.id = Themes.sharedInstance.CheckNullvalue(Passed_value: responseDict.object(forKey: "id"))
            objcallrecord.msgId = Themes.sharedInstance.CheckNullvalue(Passed_value: responseDict.object(forKey: "msgId"))
            objcallrecord.recordId = Themes.sharedInstance.CheckNullvalue(Passed_value: responseDict.object(forKey: "recordId"))
            objcallrecord.type = Themes.sharedInstance.CheckNullvalue(Passed_value: responseDict.object(forKey: "type"))
            objcallrecord.timestamp = Themes.sharedInstance.CheckNullvalue(Passed_value: responseDict.object(forKey: "timestamp"))
            objcallrecord.to = Themes.sharedInstance.CheckNullvalue(Passed_value: responseDict.object(forKey: "to"))
            objcallrecord.from_device_type = Themes.sharedInstance.CheckNullvalue(Passed_value: responseDict.object(forKey: "from_device_type"))
            objcallrecord.to_device_type = Themes.sharedInstance.CheckNullvalue(Passed_value: responseDict.object(forKey: "to_device_type"))
            objcallrecord.user_busy = Themes.sharedInstance.CheckNullvalue(Passed_value: responseDict.object(forKey: "call_connect"))
            objcallrecord.roomid = Themes.sharedInstance.CheckNullvalue(Passed_value: responseDict.object(forKey: "roomid"))
            objcallrecord.reconnecting = Themes.sharedInstance.CheckNullvalue(Passed_value: responseDict.object(forKey: "reconnecting"))
        }
        return  objcallrecord
        
    }
    
    
    func CallStatus(responseDict:NSDictionary)
    {
        
        if(responseDict.count > 0)
        {
            let toDocId:String = Themes.sharedInstance.CheckNullvalue(Passed_value: responseDict.object(forKey: "toDocId"))
            var call_status:String = Themes.sharedInstance.CheckNullvalue(Passed_value: responseDict.object(forKey: "call_status"))
            let call_duration:String = Themes.sharedInstance.CheckNullvalue(Passed_value: responseDict.object(forKey: "call_duration"))
            if(responseDict["from"] as! String != Themes.sharedInstance.Getuser_id() && call_status == "\(Constant.sharedinstance.call_status_REJECTED)" && call_duration.contains("ringing"))
            {
                call_status = Themes.sharedInstance.CheckNullvalue(Passed_value: Constant.sharedinstance.call_status_MISSED)
            }
            let Dict:NSDictionary = ["call_status":call_status, "recordId" : Themes.sharedInstance.CheckNullvalue(Passed_value: responseDict.object(forKey: "recordId"))]
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Call_detail, FetchString: toDocId, attribute: "doc_id", UpdationElements: Dict)
            let call_type = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Call_detail, attrib_name: "doc_id", fetchString: toDocId, returnStr: "call_type")
            
            if((call_status == "\(Constant.sharedinstance.call_status_END)" && call_duration.contains("ringing")) || call_status == "\(Constant.sharedinstance.call_status_MISSED)" || (call_status == "\(Constant.sharedinstance.call_status_REJECTED)" && call_duration == ""))
            {
                if(call_type == "0")
                {
                    if(AppDelegate.sharedInstance.providerDelegate.objcallrecord != nil)
                    {
                        let vc = AppDelegate.sharedInstance.window?.rootViewController
                        let objVC = vc?.storyboard?.instantiateViewController(withIdentifier: "AudioCallVCID") as? AudioCallVC
                        objVC?.objcallrecord = AppDelegate.sharedInstance.providerDelegate.objcallrecord!
                        objVC?.isCalling = false
                        objVC?.roomName = (AppDelegate.sharedInstance.providerDelegate.objcallrecord?.roomid)!
                        objVC?.isAttendedIncoming = false
                        objVC?.objcallrecord = AppDelegate.sharedInstance.providerDelegate.objcallrecord!
                        objVC?.opponent_id = (AppDelegate.sharedInstance.providerDelegate.objcallrecord?.from)!
                        objVC?.view.tag = 0
                        AppDelegate.sharedInstance.presentView((objVC?.view)!)
                    }
                    else
                    {
                        AppDelegate.sharedInstance.providerDelegate.EndCall(false)
                    }
                }
                else
                {
                    AppDelegate.sharedInstance.VideoCallWaitTimer?.invalidate()
                    AppDelegate.sharedInstance.VideoCallWaitTimer = nil
                    AppDelegate.sharedInstance.player?.stop()
                    let center = UNUserNotificationCenter.current()
                    center.removeAllPendingNotificationRequests()
                    center.removeAllDeliveredNotifications()
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let objVC:VideoViewController = storyboard.instantiateViewController(withIdentifier: "VideoViewControllerID") as! VideoViewController
                    
//                    objVC.isOpenCall = false
//                    print("isOpenCall objVC.isOpenCall: \(objVC.isOpenCall)")
                }
                
            }
            print("CALL INNER")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.callStatus), object: responseDict , userInfo: nil)
            
        }
        else
        {
            print("CALL OUTER")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.callStatus), object: responseDict , userInfo: nil)
        }
    }
    
    
    func CallOutgoingAcknowledgement(responseDict:NSDictionary)
    {
        
        if(responseDict.count > 0)
        {
            let from:String = Themes.sharedInstance.CheckNullvalue(Passed_value: responseDict.object(forKey: "from"))
            if(from == Themes.sharedInstance.Getuser_id())
            {
                let objcallrecord = self.ReturnCallRecord(responseDict: responseDict)!
                
                let profileArray:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: responseDict.object(forKey: "to")), SortDescriptor: nil) as! NSArray
                if(profileArray.count > 0){
                    let dic:NSManagedObject = profileArray[0] as! NSManagedObject
                    objcallrecord.To_avatar = Themes.sharedInstance.CheckNullvalue(Passed_value: dic.value(forKey: "profilepic"))
                }
                let ismessagePresent:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Call_detail, attribute: "doc_id", FetchString: objcallrecord.doc_id)
                
                objcallrecord.timestamp = objcallrecord.id
                if(!ismessagePresent)
                    
                {
                    let DBDict:NSDictionary = ["from":objcallrecord.from,"to":objcallrecord.to,"call_status":objcallrecord.call_status,"user_id":Themes.sharedInstance.Getuser_id(),"doc_id":objcallrecord.doc_id,"id":objcallrecord.id,"timestamp":objcallrecord.timestamp,"call_type":objcallrecord.type,"msidn":objcallrecord.To_msisdn,"call_duration":"00:00", "recordId" : objcallrecord.recordId]
                    DatabaseHandler.sharedInstance.InserttoDatabase(Dict: DBDict, Entityname: Constant.sharedinstance.Call_detail)
                }
                else
                    
                {
                    let DBDict:NSDictionary = ["from":objcallrecord.from,"to":objcallrecord.to,"call_status":objcallrecord.call_status,"user_id":Themes.sharedInstance.Getuser_id(),"id":objcallrecord.id,"timestamp":objcallrecord.timestamp,"call_type":objcallrecord.type,"msidn":objcallrecord.To_msisdn, "recordId" : objcallrecord.recordId]
                    
                    
                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Call_detail, FetchString: objcallrecord.doc_id, attribute: "doc_id", UpdationElements: DBDict)
                    
                }
                
                let user_dict:NSDictionary = ["current_call_status":Constant.sharedinstance.call_in_ringing,"call_id":objcallrecord.doc_id]
                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail, FetchString: Themes.sharedInstance.Getuser_id(), attribute: "user_id", UpdationElements: user_dict)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.outgoingcall), object: objcallrecord , userInfo: nil)
                
                let phoneConnected:String = Themes.sharedInstance.CheckNullvalue(Passed_value: responseDict.object(forKey: "phoneConnected"))
                let call_connect:String = Themes.sharedInstance.CheckNullvalue(Passed_value: responseDict.object(forKey: "call_connect"))
                
                if(phoneConnected == "0" && call_connect == "999")
                {
                    AppDelegate.sharedInstance.callRetryDict = responseDict
                    AppDelegate.sharedInstance.startCallRetry()
                }
                
            }
            else
            {
                
            }
            
        }
    }
    
}
