  
  //  SocketIOManager.swift
  //  SocketChat
  //  http://192.168.1.251:3002/notify
  //
  //  Created by Gabriel Theodoropoulos on 1/31/16.
  //  Copyright © 2016 AppCoda. All rights reserved.
  //
  
  import UIKit
  import CoreData
  import Foundation
  import SocketIO
  import UserNotifications
  import JSSAlertView
  import SwiftKeychainWrapper
  import SwiftyRSA
  
  @available(iOS 10.0, *)
  @objc protocol SocketIOManagerDelegate : class {
    @objc optional  func callBackImageUploaded(UploadedStr:String)
    @objc optional  func ReloadGroupTable()
    @objc optional  func statusUpdated(_Updated: String)
    @objc optional  func changeButton(button: String)
    @objc optional  func HandleBufferData()
    @objc optional  func postUploadDone()
    @objc optional  func ReceivedResponse(responseDict:NSDictionary,errorstatus:String,type:String)
  }
  class SocketIOManager: NSObject {
    weak var Delegate:SocketIOManagerDelegate?
    var notificationmode : NSString = NSString()
    static let sharedInstance = SocketIOManager()
    var iSSocketDisconnected:Bool=Bool()
    var iSChatSocketDisconnected:Bool=Bool()
    var nick_name:NSString=NSString()
    var Appdel=UIApplication.shared.delegate as! AppDelegate
    let manager = SocketManager(socketURL: URL(string: SocketCreateRoomUrl as String)!, config: [.log(false), .compress, .forcePolling(true), .reconnects(true), .reconnectAttempts(-1), .secure(false), .forceWebsockets(true), .extraHeaders(["referer":SocketCreateRoomUrl])])
    
    let callmanager = SocketManager(socketURL: URL(string: SocketCreateRoomUrl as String)!, config: [.log(false), .compress, .forcePolling(true), .reconnects(true), .reconnectAttempts(-1), .secure(false), .forceWebsockets(true),.extraHeaders(["referer":SocketCreateRoomUrl])])

    var socket:SocketIOClient!
    var callsocket:SocketIOClient!
    var isConnectedFirstTime:Bool = Bool()
    var qrCode = String()
    var isFromLogin = Bool()
    
    let NonEncryptionEvents = [Constant.sharedinstance.remove_user,
                               Constant.sharedinstance.sc_uploadImage,
                               Constant.sharedinstance.getFilesizeInBytes,
                               Constant.sharedinstance.qrdata,
                               Constant.sharedinstance.create_user,
                               Constant.sharedinstance.sc_settings,
                               Constant.sharedinstance.sc_webrtc_turn_message,
                               Constant.sharedinstance.sc_webrtc_turn_message_from_caller]

    override init()
    {
        super.init()
        socket = manager.defaultSocket
        socket = manager.socket(forNamespace: "/user")
        callsocket = callmanager.socket(forNamespace: "/message")
        isConnectedFirstTime = true
    }
    
    func returnDataFromEncryption(_ data : [Any]) -> NSDictionary {
        guard let data:NSDictionary = EncryptionHandler.sharedInstance.decryptData(data: data[0]) as? NSDictionary else { return [:] }
        return data
    }
    
    func emitEvent(_ event : String, _ param : Any)
    {
        if NonEncryptionEvents.contains(event)
        {
            socket.emit(event, param as! NSDictionary)
        }
        else
        {
            if(Constant.sharedinstance.isEncryptionEnabled)
            {
                let dict = EncryptionHandler.sharedInstance.encryptData(data: param)
                socket.emit(event, dict as! String)
            }
            else
            {
                socket.emit(event, param as! NSDictionary)
            }
        }
    }
    
    func emitCallEvent(_ event : String, _ param : Any)
    {
        if NonEncryptionEvents.contains(event)
        {
            callsocket.emit(event, param as! NSDictionary)
        }
        else
        {
            if(Constant.sharedinstance.isEncryptionEnabled)
            {
                let dict = EncryptionHandler.sharedInstance.encryptData(data: param)
                callsocket.emit(event, dict as! String)
            }
            else
            {
                callsocket.emit(event, param as! NSDictionary)
            }
        }
    }
    
    func AddListeners()
    {
        let Nickname = Themes.sharedInstance.Getuser_id() as NSString
        ListenSocketStatusEvents(Nickname: Nickname)
        ListenSocketStatusEventsCalls()
        ListenSettings(Nickname: Nickname)
        ListenUniqueEvents()
        ListenUserAuthenticated(Nickname: Nickname)
        ListenUserCreated(Nickname: Nickname)
        Listentochat(Nickname: Nickname)

    }
    
    func establishConnection(Nickname:NSString,isLogin:Bool)
    {
        
        if(socket.status == .disconnected || socket.status == .notConnected)
        {
            socket.removeAllHandlers()
            AddListeners()
            socket.connect()
            callsocket.connect()
            Themes.sharedInstance.showWaitingNetwork(false, state: false)
        }
        else
        {
            self.iSSocketDisconnected=false;
            Themes.sharedInstance.showWaitingNetwork(false, state: true)
        }
    }
    
    func CreateRoom(Nickname:NSString)
    {
        if(!iSSocketDisconnected)
        {
            if (socket.status == .connected)
            {
                self.chatSettings(id: Nickname as String, mode: "phone", chat_type: "single")
            }
            else
            {
                self.establishConnection(Nickname: Nickname, isLogin: false);
            }
        }
    }
    
    func ListenSettings(Nickname: NSString) {
        socket.on(Constant.sharedinstance.sc_settings as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            let ErrorStr:String=Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            if(ErrorStr == "1")
            {
            }
            else
            {
                let ResponseDict:NSDictionary=data
                
                let timestamp = Int64(String(Date().ticks))!
                let server_time = Int64(Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "server_time")))!
                let client_time = Int64(Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "client_time")))!
                let server_time_diff = timestamp - (server_time + (timestamp - client_time)) ;
                Themes.sharedInstance.saveServerTime(serverDiff: "\(server_time_diff)", serverTime: "\(server_time)")

                let contact_us_email:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "contactus_email_address"))
                
                let dict = ["contact_us":contact_us_email]
                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail, FetchString: Themes.sharedInstance.Getuser_id(), attribute: "user_id", UpdationElements: dict as NSDictionary)
                
                Constant.sharedinstance.isEncryptionEnabled = (Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "is_encryption_available")) as NSString).boolValue
              
                let param = ["_id" : Nickname];
                self.Removeuser(param: param)

              

                if(Constant.sharedinstance.isEncryptionEnabled)
                {
                    let encparam = ["_id":Nickname,"chat_type":"single","mode":"phone","token":KeychainService.loadPassword(service: Themes.sharedInstance.Getuser_id())! as String] as [String : Any]
                    self.emitEvent(Constant.sharedinstance.create_user, encparam)
                }
                else
                {
                    let param = ["_id" : Nickname, "chat_type" : "single", "mode" : "phone"]
                    self.emitEvent(Constant.sharedinstance.create_user, param)
                }
            }
        }
    }
    
    func ListenUserCreated(Nickname: NSString) {
        socket.on(Constant.sharedinstance.usercreated as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            let ResponseDict = data;
            if(Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "_id")) == Themes.sharedInstance.Getuser_id())
            {
                if(Constant.sharedinstance.isEncryptionEnabled)
                {
                    self.ListenCheckAndgetKeys(ResponseDict)
                    
                    let secret_keys_param = ["userId":Nickname,"secretcode":Themes.sharedInstance.getsecurityToken()] as [String : Any];
                    
                    
                    let publickey:String = KeychainService.loadPassword(service:  "\(Themes.sharedInstance.Getuser_id())-public_key")! as String
                    
                    let privatekey:String = KeychainService.loadPassword(service:  "\(Themes.sharedInstance.Getuser_id())-private_key")! as String
                    
                    if(publickey == "" || privatekey == "")
                    {
                        self.emitEvent(Constant.sharedinstance.sc_get_secret_keys, secret_keys_param)
                    }
                    else
                    {
                        let otp = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.User_detail, attrib_name: "user_id", fetchString: Themes.sharedInstance.Getuser_id(), returnStr: "otp")
                        let checkStr = Themes.sharedInstance.Getuser_id() + "-" + otp
                        do
                        {
                            let _publicKey = try PublicKey(pemEncoded: publickey)
                            let clear = try ClearMessage(string: checkStr, using: .utf8)
                            let encrypted = try clear.encrypted(with: _publicKey, padding: .PKCS1)
                            let publickeyencryptedStr = encrypted.base64String
                            let dic = ["id" : Themes.sharedInstance.Getuser_id(), "encrypted_text" : publickeyencryptedStr]
                            self.emitEvent(Constant.sharedinstance.sc_check_secret_keys, dic)
                        }
                        catch
                        {
                            print(error.localizedDescription)
                        }
                    }
                }
                else
                {
                    self.continueAfterUserCreated(ResponseDict: ResponseDict, Nickname: Nickname)
                }
            }
        }
    }
    
    func ListenCheckAndgetKeys(_ createUserDict : NSDictionary)
    {
        socket.off(Constant.sharedinstance.sc_get_secret_keys as String)
        socket.off(Constant.sharedinstance.sc_check_secret_keys as String)
        
        socket.on(Constant.sharedinstance.sc_get_secret_keys as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            let ResponseDict : NSDictionary = data
            if(ResponseDict.count > 0)
            {
                let errVal = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "err"))
                
                if errVal == ""
                {
                    let public_key:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "public_key"))
                    
                    let private_key:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "private_key"))
                    
                    Themes.sharedInstance.savesPrivatekey(DeviceToken: private_key)
                    Themes.sharedInstance.savepublicKey(DeviceToken: public_key)
                    
                    KeychainService.savePassword(service: "\(Themes.sharedInstance.Getuser_id())-public_key", data: public_key)
                    KeychainService.savePassword(service: "\(Themes.sharedInstance.Getuser_id())-private_key", data: private_key)
                    
                    self.continueAfterUserCreated(ResponseDict: createUserDict, Nickname: Themes.sharedInstance.Getuser_id() as NSString)
                }
            }
        }
        
        socket.on(Constant.sharedinstance.sc_check_secret_keys as String) {data, ack in
            
            let data = self.returnDataFromEncryption(data)
            let ResponseDict : NSDictionary = data
            if(ResponseDict.count > 0)
            {
                let errVal = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "err"))
                
                if errVal == "1"
                {
                    if Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "msg")) != "" {
                        if(AppDelegate.sharedInstance.navigationController?.presentedViewController != nil)
                        {
                            
                            AppDelegate.sharedInstance.navigationController?.dismissView(animated: true, completion: {
                                let alertview = JSSAlertView().show(
                                    (AppDelegate.sharedInstance.navigationController?.topViewController)!,
                                    title: Themes.sharedInstance.GetAppname(),
                                    text: Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "msg")),
                                    buttonText: "Ok",
                                    cancelButtonText: nil
                                )
                                alertview.addAction(self.LogOut)
                            })
                        }
                        else
                        {
                            let alertview = JSSAlertView().show(
                                (AppDelegate.sharedInstance.navigationController?.topViewController)!,
                                title: Themes.sharedInstance.GetAppname(),
                                text: Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "msg")),
                                buttonText: "Ok",
                                cancelButtonText: nil
                            )
                            alertview.addAction(self.LogOut)
                        }
                        
                    }
                }
                else
                {
                    self.continueAfterUserCreated(ResponseDict: createUserDict, Nickname: Themes.sharedInstance.Getuser_id() as NSString)
                }
            }
        }
    }
    
    func continueAfterUserCreated(ResponseDict : NSDictionary, Nickname : NSString) {
        let state = UIApplication.shared.applicationState
        if(state == .active)
        {
            self.online(from: Themes.sharedInstance.Getuser_id(), status: "1")
        }
//        if(ContactHandler.sharedInstance.StorecontactInProgress)
//        {
            ContactHandler.sharedInstance.StorecontactInProgress = false
//        }
        self.UpdateRoom(ResponseDict: ResponseDict)
        self.EmitforGetOfflineDetails(Nickname: Nickname)
        
        let is_updated = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Login_details, attrib_name: "user_id", fetchString: Themes.sharedInstance.Getuser_id(), returnStr: "is_updated")
        if(is_updated == "0")
        {
            let device_id = Themes.sharedInstance.getDeviceToken()
            let login_key = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Login_details, attrib_name: "user_id", fetchString: Themes.sharedInstance.Getuser_id(), returnStr: "login_key")
            SocketIOManager.sharedInstance.updateMobilePushNotificationKey(from: Themes.sharedInstance.Getuser_id(), DeviceId: device_id, login_key: login_key)
            let param = ["is_updated" : "1"]
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Login_details, FetchString: Themes.sharedInstance.Getuser_id(), attribute: "user_id", UpdationElements: param as NSDictionary)
        }
        
        SocketIOManager.sharedInstance.checkMobileLoginKey(from: Themes.sharedInstance.Getuser_id())
        SocketIOManager.sharedInstance.checkUserDeactivated(from: Themes.sharedInstance.Getuser_id())
        AppDelegate.sharedInstance.SockedConnected(isConnected: true)
        
        UploadHandler.Sharedinstance.handleUpload()
        StatusUploadHandler.Sharedinstance.handleUpload()

        DownloadHandler.sharedinstance.handleDownLoad(false)
        StatusDownloadHandler.sharedinstance.handleDownLoad()
    }
    
    func EmitforGetOfflineDetails(Nickname : NSString)
    {
        let CheckLogin=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.User_detail, attribute: nil, FetchString: nil)
        
        if(CheckLogin && !isFromLogin)
        {
            if(ContactHandler.sharedInstance.CheckCheckPermission())
            {
                
                if(isConnectedFirstTime)
                {
                    isConnectedFirstTime = false
                    
                    if Themes.sharedInstance.getFirstTime() == "" {
                        Themes.sharedInstance.saveFirstTime(firsttime: "YES")
                        ContactHandler.sharedInstance.StoreContacts()
                    }
                    
//                    if(!ContactHandler.sharedInstance.StorecontactInProgress)
//                    {
                        //ContactHandler.sharedInstance.StoreContacts()
//                    }
                }
                SecretmessageHandler.sharedInstance.starttimer()
                let GetgroupParam = ["from":Nickname];
                let param = ["msg_to":Nickname];
                
                emitEvent(Constant.sharedinstance.appgetGroupList, GetgroupParam)
                emitEvent(Constant.sharedinstance.sc_get_offline_messages, param)
                emitEvent(Constant.sharedinstance.sc_get_offline_deleted_messages, param)
                emitEvent(Constant.sharedinstance.sc_get_offline_status, param)
                
                //Get offline group Messages
                let timestamp:String = String(Int(Date().timeIntervalSince1970))
                
                _=["client_time":timestamp]
                
                
                let GetgroupOfflinemessage = ["from":Nickname,"groupType":"13"];
                self.Groupevent(param: GetgroupOfflinemessage)
                let GetgroupOfflinedeletemessage = ["from":Nickname,"groupType":"20"];
                self.Groupevent(param: GetgroupOfflinedeletemessage)
                let Dict:NSDictionary = ["from":Nickname,
                                         "DeviceId":Themes.sharedInstance.getDeviceToken(),
                                         "callToken":Themes.sharedInstance.getCallToken()]
                self.EmitAppsetting(Dict: Dict)
            }
        }
    }
    
    func ListenUserAuthenticated(Nickname: NSString)
    {
        socket.on(Constant.sharedinstance.userauthenticated as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            let ErrorStr:String=Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            if(ErrorStr == "1")
            {
                if Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "msg")) != "" {
                    if(AppDelegate.sharedInstance.navigationController?.presentedViewController != nil)
                    {
                        
                        AppDelegate.sharedInstance.navigationController?.dismissView(animated: true, completion: {
                            let alertview = JSSAlertView().show(
                                (AppDelegate.sharedInstance.navigationController?.topViewController)!,
                                title: Themes.sharedInstance.GetAppname(),
                                text: Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "msg")),
                                buttonText: "Ok",
                                cancelButtonText: nil
                            )
                            alertview.addAction(self.LogOut)
                        })
                    }
                    else
                    {
                        let alertview = JSSAlertView().show(
                            (AppDelegate.sharedInstance.navigationController?.topViewController)!,
                            title: Themes.sharedInstance.GetAppname(),
                            text: Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "msg")),
                            buttonText: "Ok",
                            cancelButtonText: nil
                        )
                        alertview.addAction(self.LogOut)
                    }
                }
            }
        }
        
    }
    
    func UpdateRoom(ResponseDict:NSDictionary)
    {
        if(Constant.sharedinstance.isEncryptionEnabled)
        {
            let room_connection:[[String:Any]] = ResponseDict.object(forKey: "room_connection") as! [[String:Any]]
            if(room_connection.count > 0)
            {
                room_connection.forEach { (Dict) in
                    var opp_id:String  = ""
                    
                    let users:[String] = Dict["users"] as! [String]
                    users.forEach({ (oppid) in
                        if(oppid != Themes.sharedInstance.Getuser_id())
                        {
                            opp_id = oppid
                            return
                        }
                    })
                    
                    let DBdict:[String:String] = ["convId":Themes.sharedInstance.CheckNullvalue(Passed_value: Dict["convId"]),"security_code":Themes.sharedInstance.CheckNullvalue(Passed_value: Dict["security_code"]),"user_id":Themes.sharedInstance.Getuser_id(),"opp_id":opp_id]
                    let checkConvDetails:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Conv_detail, attribute: "opp_id", FetchString: opp_id)
                    if(!checkConvDetails)
                    {
                        DatabaseHandler.sharedInstance.InserttoDatabase(Dict: DBdict as NSDictionary, Entityname: Constant.sharedinstance.Conv_detail)
                    }
                    else
                    {
                        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Conv_detail, FetchString: opp_id, attribute: "opp_id", UpdationElements: DBdict as NSDictionary)
                    }
                    
                    let param = ["security_code":Themes.sharedInstance.CheckNullvalue(Passed_value: Dict["security_code"])]
                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Favourite_Contact, FetchString: opp_id, attribute: "id", UpdationElements: param as NSDictionary)
                }
            }
        }
    }
    
    func GetFavContact(Dict:NSDictionary)
    {
        emitEvent(Constant.sharedinstance.getAllContacts, Dict)
    }
    func Removeuser(param:[String:Any])
    {
        emitEvent(Constant.sharedinstance.remove_user, param)
    }
    func change_mail(from:String,email:String){
        let param = ["from":from,"email":email]
        emitEvent(Constant.sharedinstance.sc_change_mail, param)
    }
    
    func recovery_mail(from:String,recovery_email:String){
        let param = ["from":from,"recovery_email":recovery_email]
        emitEvent(Constant.sharedinstance.sc_change_recovery_email, param)
    }
    
    func recovery_phone(from:String,recovery_phone:String){
        let param = ["from":from,"recovery_phone":recovery_phone]
        emitEvent(Constant.sharedinstance.sc_change_recovery_phone, param)
    }
    
    func updateProfilepic(file:String,from:String,type:String)
    {
        if (socket.status == .notConnected)
        {
            if(self.Delegate?.callBackImageUploaded?(UploadedStr: "CHECK") != nil)
            {
                self.Delegate?.callBackImageUploaded!(UploadedStr: "")
            }
        }
        else
        {
            let param = ["from":from,"ImageName":file,"type":type];
            emitEvent(Constant.sharedinstance.sc_changeProfilePic, param)
        }
    }
    
    
    func uploadImage(from:String,imageName:String,uploadType:String,bufferAt:String,imageByte:NSData,file_end:String){
        if (socket.status == .notConnected)
        {
            if(self.Delegate?.statusUpdated?(_Updated: "CHECK") != nil)
            {
                self.Delegate?.statusUpdated!(_Updated: "notconnected")
            }
        }
        else
        {
            var res: Data? = imageByte as Data
            res = res?.deflate()
            let param = ["from":from,  "ImageName": imageName,   "uploadType":uploadType,"buffer":res ?? Data(),"bufferAt":bufferAt,"FileEnd":file_end,"buffer_type":"base64"] as [String : Any]
            emitEvent(Constant.sharedinstance.sc_uploadImage, param)
        }
    }
    
    func uploadMedia(from:String,imageName:String,uploadType:String,bufferAt:String,imageByte:NSData,file_end:String, speed: String){
        if (socket.status == .notConnected)
        {
            if(self.Delegate?.statusUpdated?(_Updated: "CHECK") != nil)
            {
                self.Delegate?.statusUpdated!(_Updated: "notconnected")
            }
        }
        else
        {
            var res: Data? = imageByte as Data
            res = res?.deflate()
            let param = ["from":from,  "ImageName": imageName,   "uploadType":uploadType,"buffer":res ?? Data(),"bufferAt":bufferAt,"FileEnd":file_end,"buffer_type":"base64", "speed" : speed] as [String : Any]
            emitEvent(Constant.sharedinstance.sc_uploadImage, param)
        }
    }
    
    func getFileInfoBytes(imageName:String,uploadType:String){
        if (socket.status == .notConnected)
        {
            
        }
        else
        {
            let param = ["ImageName": imageName, "uploadType":uploadType] as [String : Any]
            emitEvent(Constant.sharedinstance.getFilesizeInBytes, param)
        }
    }
    
    func uploadStatusImage(from:String,imageName:String,uploadType:String,bufferAt:String,imageByte:NSData,file_end:String, speed: String){
        if (socket.status == .notConnected)
        {
            if(self.Delegate?.statusUpdated?(_Updated: "CHECK") != nil)
            {
                self.Delegate?.statusUpdated!(_Updated: "notconnected")
            }
        }
        else
        {
            var res: Data? = imageByte as Data
            res = res?.deflate()
            let param = ["from":from,  "ImageName": imageName,   "uploadType":uploadType,"buffer":res ?? Data(),"bufferAt":bufferAt,"FileEnd":file_end,"buffer_type":"base64", "speed" : speed] as [String : Any]
            emitEvent(Constant.sharedinstance.sc_uploadImage, param)
        }
    }
    
    func privacySetting(from:String,status:String,privacy:String){
        
        let param = ["from":from,"status":status,"privacy":privacy];
        emitEvent(Constant.sharedinstance.sc_privacy_settings, param)
    }
    
    func StatusprivacySetting(from:String,statusToID:[String],privacy:String){
        
        let param = ["from":from,"statusToID":statusToID,"privacy":privacy] as [String : Any]
        emitEvent(Constant.sharedinstance.sc_media_status_privacy, param)
    }
    
    func muteChat(param:[String:Any]){
        emitEvent(Constant.sharedinstance.sc_mute_chat, param)
    }
    
    func muteStatus(param:[String:Any]){
        emitEvent(Constant.sharedinstance.sc_mute_status, param)
    }
    
    func changeName(name:String,from:String,email: String,showNumber:Bool? = false){
        if (socket.status == .notConnected)
        {
            
        }
        else
        {
            let param = ["name":name.decoded,"from":from,"email":email,"showNumber":showNumber!] as [String : Any];
            emitEvent(Constant.sharedinstance.sc_changeName, param)
        }
    }
    func changeGroupImage(toDocID:String,from:String,groupId:String,image:String){
        
        let param = ["toDocId":toDocID,"from":from,"groupId":groupId,"avatar":image,"groupType":"2"]
        emitEvent(Constant.sharedinstance.group, param)
    }
    
    func changeGroupName(groupType:String,from:String,groupId:String,groupNewName:String){
        if (socket.status == .notConnected)
        {
            
        }
        else{
            let param = ["groupType":groupType,"from":from,"groupId":groupId,"groupNewName":groupNewName]
            emitEvent(Constant.sharedinstance.group, param)
        }
    }
    
    func updateMobilePushNotificationKey(from:String,DeviceId:String,login_key:String){
        let param = ["from":from,"DeviceId":DeviceId,"login_key":login_key]
        emitEvent(Constant.sharedinstance.updateMobilePushNotificationKey, param)
    }
    
    func checkMobileLoginKey(from:String){
        let param = ["from":from]
        emitEvent(Constant.sharedinstance.checkMobileLoginKey, param)
    }
    
    
    func checkUserDeactivated(from:String){
        let param = ["id":from]
        emitEvent(Constant.sharedinstance.userDeactivated, param)
    }
    
    func changeStatus(status:String,from:String)
    {
        let param = ["status":status.decoded,"from":from];
        emitEvent(Constant.sharedinstance.sc_changeStatus, param)
    }
    
    func chatSettings(id:String,mode:String,chat_type:String){
        
        let param = ["_id":id,"mode":mode,"chat_type":chat_type, "client_time" : String(Date().ticks)];
        emitEvent(Constant.sharedinstance.sc_settings, param)
    }
    
    func lastSeen(from:String,to:String){
        let param = ["from":from,"to":to];
        emitEvent(Constant.sharedinstance.sc_online_status, param)
    }
    
    func chatLock(from:String,to: String, password:String,convId:String,type:String,confirm_password:String,mobile_password:String,mode:String,status:String){
        let param = ["from":from, "to" : to, "password":password,"convId":convId,"type":type,"confirm_password":confirm_password,"mobile_password":mobile_password,"mode":mode,"status":status]
        emitEvent(Constant.sharedinstance.sc_chat_lock, param)
    }
    
    func webChatLock(from:String,convId:String,type:String,mobile_password:String,mode:String){
        let param = ["from":from,"convId":convId,"type":type,"mobile_password":mobile_password,"mode":mode]
        emitEvent(Constant.sharedinstance.sc_set_mobile_password_chat_lock, param)
    }
    
    func changeExpirationTime(param:[String:Any]){
        emitEvent(Constant.sharedinstance.sc_change_timer, param)
    }
    
    func Do_ChangePic(ResponseDict : NSDictionary)
    {
        let err:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "err"))
        if(err == "0")
        {
            let groupId:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "groupId"))
            
            let groupType:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "groupType"))
            
            let removeId:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "removeId"))
            
            let id = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id"))
            
            let createdBy = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from"))
            
            let remove_msisdn = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "remove_msisdn"))
            
            let Msg = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "message"))
            
            let toDocId = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "toDocId"))
            
            let timeStamp = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id"))
            
            let to:String=groupId
            
            let param_ack=["groupType": 12, "from": Themes.sharedInstance.Getuser_id(), "groupId": groupId, "status":2, "msgId": Int(id)!]  as [String : Any]
            
            self.GroupmessageAcknowledgement(Param: param_ack)
            
            let checkbool:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "id", FetchString: id)
            let CheckOtherMessageDetail:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Other_Group_message, attribute: "id", FetchString: id)
            if(!CheckOtherMessageDetail)
            {
                let Group_messagePram=["admin_id":"","admin_msisid":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey:"from_msisdn")),"from":createdBy,"group_id":groupId,"group_type":groupType,"id":id,"left_id":"","left_msisid":"","new_pic":"","old_pic":"","pic_changed_msisid":"","person_id":removeId,"person_msisid":remove_msisdn]
                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Group_messagePram as NSDictionary, Entityname: Constant.sharedinstance.Other_Group_message)
                Themes.sharedInstance.makeGroupActionNotification(id: id)
            }
            let dic:[AnyHashable: Any]
            if(!checkbool)
            {
                //
                dic = ["type": "0","convId":groupId,"doc_id":toDocId
                    ,"filesize":"","from":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(createdBy)"
                    ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:to
                    ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
                    ),"message_status":Themes.sharedInstance.CheckNullvalue(Passed_value:"3"
                    ),"id":"\(id)","name":"","payload":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(Msg)"
                    ),"recordId":"","timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:timeStamp
                    ),"thumbnail":"","width":"0.0","height":"0.0","msgId":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(id)"
                    ),"contactmsisdn":""
                    ,"user_common_id":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(Themes.sharedInstance.Getuser_id())-\(to)"
                    ),"message_from":"1","chat_type":"group","info_type":groupType,"created_by":"\(createdBy)","is_reply":"0", "date" : Themes.sharedInstance.getTimeStamp()]
                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: dic as NSDictionary,Entityname: Constant.sharedinstance.Chat_one_one)
            }
            else{
                
                dic = ["payload": Themes.sharedInstance.CheckNullvalue(Passed_value:"\(Msg)")]
                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_one_one, FetchString: id, attribute: "id", UpdationElements: dic as NSDictionary?)
            }
            
            self.GetGroupDetails(GroupIDArr: [groupId])
            
            if(!CheckOtherMessageDetail)
            {
                let chat_type_dict:[String: String] = ["chat_type": "group"]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.Incomingmessage), object: dic , userInfo: chat_type_dict)
            }
            if(removeId == Themes.sharedInstance.Getuser_id()) {
                self.perform(#selector(self.GroupInfoUpdate(_:)), with:["data" : dic, "message" : "you removed"], afterDelay: 1.5)
            }
            else {
                self.perform(#selector(self.GroupInfoUpdate(_:)), with:["data" : dic, "message" : "removed"], afterDelay: 1.5)
            }
            
        }
    }
    
    func do_remove_member(ResponseDict : NSDictionary, _ is_offline : Bool) {
        let err:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "err"))
        if(err == "0")
        {
            let groupId:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "groupId"))
            
            let groupType:String = "4"
            
            var removeId:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "removeId"))
            if(is_offline) {
                removeId = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "createdTo"))
            }
            let id = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id"))
            
            let createdBy = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from"))
            
            var remove_msisdn = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "remove_msisdn"))
            if(is_offline) {
                remove_msisdn = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "createdTomsisdn"))
            }
            
            let Msg = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "message"))
            
            let toDocId = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "toDocId"))
            
            let timeStamp = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id"))
            
            let to:String=groupId
            
            let param_ack=["groupType": "12", "from": Themes.sharedInstance.Getuser_id(), "groupId": groupId, "status":2, "msgId": id] as [String : Any]
            
            self.GroupmessageAcknowledgement(Param: param_ack)
            
            let checkbool:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "id", FetchString: id)
            let CheckOtherMessageDetail:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Other_Group_message, attribute: "id", FetchString: id)
            if(!CheckOtherMessageDetail)
            {
                let Group_messagePram=["admin_id":"","admin_msisid":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey:"from_msisdn")),"from":createdBy,"group_id":groupId,"group_type":groupType,"id":id,"left_id":"","left_msisid":"","new_pic":"","old_pic":"","pic_changed_msisid":"","person_id":removeId,"person_msisid":remove_msisdn]
                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Group_messagePram as NSDictionary, Entityname: Constant.sharedinstance.Other_Group_message)
                Themes.sharedInstance.makeGroupActionNotification(id: id)
            }
            let dic:[AnyHashable: Any]
            if(!checkbool)
            {
                //
                dic = ["type": "0","convId":groupId,"doc_id":toDocId
                    ,"filesize":"","from":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(createdBy)"
                    ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:to
                    ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
                    ),"message_status":Themes.sharedInstance.CheckNullvalue(Passed_value:"3"
                    ),"id":"\(id)","name":"","payload":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(Msg)"
                    ),"recordId":"","timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:timeStamp
                    ),"thumbnail":"","width":"0.0","height":"0.0","msgId":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(id)"
                    ),"contactmsisdn":""
                    ,"user_common_id":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(Themes.sharedInstance.Getuser_id())-\(to)"
                    ),"message_from":"1","chat_type":"group","info_type":groupType,"created_by":"\(createdBy)","is_reply":"0", "date" : Themes.sharedInstance.getTimeStamp()]
                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: dic as NSDictionary,Entityname: Constant.sharedinstance.Chat_one_one)
            }
            else{
                
                dic = ["payload": Themes.sharedInstance.CheckNullvalue(Passed_value:"\(Msg)")]
                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_one_one, FetchString: id, attribute: "id", UpdationElements: dic as NSDictionary?)
            }
            
            self.GetGroupDetails(GroupIDArr: [groupId])
            
            if(!CheckOtherMessageDetail)
            {
                let chat_type_dict:[String: String] = ["chat_type": "group"]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.Incomingmessage), object: dic , userInfo: chat_type_dict)
            }
            if(removeId == Themes.sharedInstance.Getuser_id()) {
                self.perform(#selector(self.GroupInfoUpdate(_:)), with:["data" : dic, "message" : "you removed"], afterDelay: 1.5)
            }
            else {
                self.perform(#selector(self.GroupInfoUpdate(_:)), with:["data" : dic, "message" : "removed"], afterDelay: 1.5)
            }
            
        }
    }
    
    func do_add_member(ResponseDict : NSDictionary) {
        let err:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "err"))
        if(err == "0")
        {
            var newUser_Id = ""
            var newUser_msisdn = ""
            if let NewUserDict = ResponseDict.object(forKey: "newUser") as? NSDictionary {
                newUser_Id = Themes.sharedInstance.CheckNullvalue(Passed_value: NewUserDict.value(forKey: "_id"))
                newUser_msisdn = Themes.sharedInstance.CheckNullvalue(Passed_value: NewUserDict.value(forKey:"msisdn"))
                do_add(newUser_Id, newUser_msisdn, ResponseDict)
            }
            else if let NewUserArr = ResponseDict.object(forKey: "newUser") as? [NSDictionary] {
                _ = NewUserArr.map {
                    let NewUserDict = $0
                    newUser_Id = Themes.sharedInstance.CheckNullvalue(Passed_value: NewUserDict.value(forKey: "_id"))
                    newUser_msisdn = Themes.sharedInstance.CheckNullvalue(Passed_value: NewUserDict.value(forKey:"msisdn"))
                    do_add(newUser_Id, newUser_msisdn, ResponseDict)
                }
            }
        }
    }
    
    func do_add(_ newUser_Id: String,_ newUser_msisdn : String, _ ResponseDict : NSDictionary) {
        let groupId:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "groupId"))
        let groupType:String = "5"
        let id = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id"))
        var createdBy = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "createdBy"))
        if createdBy == "" {
            createdBy = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from"))
        }
        let Msg = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "message"))
        let timeStamp = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id"))
        
        let to:String=groupId
        let param_ack=["groupType": "12", "from": Themes.sharedInstance.Getuser_id(), "groupId": groupId, "status":2, "msgId": id] as [String : Any]
        let toDocId : String = "\(createdBy)-\(to)-\(timeStamp)"
        self.GroupmessageAcknowledgement(Param: param_ack)
        
        let checkbool:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "id", FetchString: id)
        let CheckOtherMessageDetail:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Other_Group_message, attribute: "id", FetchString: id)
        if(!CheckOtherMessageDetail)
        {
            let Group_messagePram=["person_id":newUser_Id,"person_msisid" : newUser_msisdn, "admin_id":"","admin_msisid":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey:"msisdn")),"from":createdBy,"group_id":groupId,"group_type":groupType,"id":id,"left_id":"","left_msisid":"","new_pic":"","old_pic":"","pic_changed_msisid":""]
            
            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Group_messagePram as NSDictionary, Entityname: Constant.sharedinstance.Other_Group_message)
            Themes.sharedInstance.makeGroupActionNotification(id: id)
        }
        let dic : [AnyHashable: Any]
        if(!checkbool)
        {
            dic = ["type": "0","convId":groupId,"doc_id":toDocId
                ,"filesize":"","from":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(createdBy)"
                ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:to
                ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
                ),"message_status":Themes.sharedInstance.CheckNullvalue(Passed_value:"3"
                ),"id":"\(id)","name":"","payload":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(Msg)"
                ),"recordId":"","timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:timeStamp
                ),"thumbnail":"","width":"0.0","height":"0.0","msgId":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(id)"
                ),"contactmsisdn":""
                ,"user_common_id":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(Themes.sharedInstance.Getuser_id())-\(to)"
                ),"message_from":"1","chat_type":"group","info_type":groupType,"created_by":"\(createdBy)","is_reply":"0", "date" : Themes.sharedInstance.getTimeStamp()]
            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: dic as NSDictionary,Entityname: Constant.sharedinstance.Chat_one_one)
        }
        else{
            
            dic = ["payload": Themes.sharedInstance.CheckNullvalue(Passed_value:"\(Msg)")]
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_one_one, FetchString: id, attribute: "id", UpdationElements: dic as NSDictionary?)
        }
        
        if(!CheckOtherMessageDetail)
        {
            let chat_type_dict:[String: String] = ["chat_type": "group"]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.Incomingmessage), object: dic , userInfo: chat_type_dict)
        }
        self.GetGroupDetails(GroupIDArr: [groupId])
        if(newUser_Id == Themes.sharedInstance.Getuser_id()) {
            self.perform(#selector(self.added_GroupInfoUpdate(_:)), with:["data" : dic, "message" : "you added"], afterDelay: 1.5)
            self.perform(#selector(self.GroupInfoUpdate(_:)), with:["data" : dic, "message" : "you added"], afterDelay: 1.6)
        }
        else {
            self.perform(#selector(self.added_GroupInfoUpdate(_:)), with:["data" : dic, "message" : "added"], afterDelay: 1.5)
            self.perform(#selector(self.GroupInfoUpdate(_:)), with:["data" : dic, "message" : "added"], afterDelay: 1.6)
        }
    }
    
    func do_change_securitycode(ResponseDict : NSDictionary) {
        
        let err:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "err"))
        if(err == "0")
        {
            let groupId:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "groupId"))
            
            let groupType:String = "23"

 
 
            let id = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id"))
            
            let createdBy = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from"))
            
 
            let Msg = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "mess"))
            
            let timeStamp = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id"))
            
            let toDocId = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "toDocId"))
            
            let to:String=groupId
            
           
                let param_ack=["groupType": 12, "from": Themes.sharedInstance.Getuser_id(), "groupId": groupId, "status":2, "msgId": (id as NSString).longLongValue] as [String : Any]
                
                 self.GroupmessageAcknowledgement(Param: param_ack)
                
                let checkbool:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "id", FetchString: id)
                 let dic : [AnyHashable: Any]
                if(!checkbool)
                {
                    
                    
                    //
                    dic = ["type": groupType,"convId":groupId,"doc_id":toDocId
                        ,"filesize":"","from":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(createdBy)"
                        ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:to
                        ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
                        ),"message_status":Themes.sharedInstance.CheckNullvalue(Passed_value:"3"
                        ),"id":"\(id)","name":"","payload":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(Msg)"
                        ),"recordId":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "recordId")),"timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:timeStamp
                        ),"thumbnail":"","width":"0.0","height":"0.0","msgId":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(id)"
                        ),"contactmsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "FromMsisdn"))
                        ,"user_common_id":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(Themes.sharedInstance.Getuser_id())-\(to)"
                        ),"message_from":"1","chat_type":"group","info_type":groupType,"created_by":"\(createdBy)","is_reply":"0", "date" : Themes.sharedInstance.getTimeStamp()]
                    DatabaseHandler.sharedInstance.InserttoDatabase(Dict: dic as NSDictionary,Entityname: Constant.sharedinstance.Chat_one_one)
                }
                else{
                    
                    dic = ["payload": Themes.sharedInstance.CheckNullvalue(Passed_value:"\(Msg)")]
                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_one_one, FetchString: id, attribute: "id", UpdationElements: dic as NSDictionary?)
                }
                
            
                    let chat_type_dict:[String: String] = ["chat_type": "group"]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.Incomingmessage), object: dic , userInfo: chat_type_dict)
          }
    }
    func do_make_an_admin(ResponseDict : NSDictionary) {
        
        let err:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "err"))
        if(err == "0")
        {
            let groupId:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "groupId"))
            
            let groupType:String="7"

            let admin_users : NSArray = ResponseDict.object(forKey: "admin") as! NSArray
            
            let adminuser:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "adminuser"))
            
            let id = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id"))
            
            let createdBy = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from"))
            
            let newadminmsisdn = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey:"newadminmsisdn"))
            
            let Msg = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "mess"))
            
            let timeStamp = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id"))
            
            let toDocId = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "toDocId"))
            
            let to:String=groupId
            
            if(admin_users.contains(Themes.sharedInstance.Getuser_id()))
            {
                let param_ack=["groupType": 12, "from": Themes.sharedInstance.Getuser_id(), "groupId": groupId, "status":2, "msgId": (id as NSString).longLongValue] as [String : Any]
                
                
                self.GroupmessageAcknowledgement(Param: param_ack)
                
                let checkbool:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "id", FetchString: id)
                let CheckOtherMessageDetail:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Other_Group_message, attribute: "id", FetchString: id)
                if(!CheckOtherMessageDetail)
                {
                    let Group_messagePram=["person_id":adminuser,"person_msisid" : newadminmsisdn, "admin_id":"","admin_msisid":"","from":createdBy,"group_id":groupId,"group_type":groupType,"id":id,"left_id":"","left_msisid":"","new_pic":"","old_pic":"","pic_changed_msisid":""]
                    
                    DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Group_messagePram as NSDictionary, Entityname: Constant.sharedinstance.Other_Group_message)
                    Themes.sharedInstance.makeGroupActionNotification(id: id)
                }
                let dic : [AnyHashable: Any]
                if(!checkbool)
                {
                    //
                    dic = ["type": "0","convId":groupId,"doc_id":toDocId
                        ,"filesize":"","from":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(createdBy)"
                        ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:to
                        ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
                        ),"message_status":Themes.sharedInstance.CheckNullvalue(Passed_value:"3"
                        ),"id":"\(id)","name":"","payload":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(Msg)"
                        ),"recordId":"","timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:timeStamp
                        ),"thumbnail":"","width":"0.0","height":"0.0","msgId":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(id)"
                        ),"contactmsisdn":""
                        ,"user_common_id":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(Themes.sharedInstance.Getuser_id())-\(to)"
                        ),"message_from":"1","chat_type":"group","info_type":groupType,"created_by":"\(createdBy)","is_reply":"0", "date" : Themes.sharedInstance.getTimeStamp()]
                    DatabaseHandler.sharedInstance.InserttoDatabase(Dict: dic as NSDictionary,Entityname: Constant.sharedinstance.Chat_one_one)
                }
                else{
                    
                    dic = ["payload": Themes.sharedInstance.CheckNullvalue(Passed_value:"\(Msg)")]
                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_one_one, FetchString: id, attribute: "id", UpdationElements: dic as NSDictionary?)
                }
                
                if(!CheckOtherMessageDetail)
                {
                    let chat_type_dict:[String: String] = ["chat_type": "group"]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.Incomingmessage), object: dic , userInfo: chat_type_dict)
                }
                
                self.GetGroupDetails(GroupIDArr: [groupId])
                
                self.perform(#selector(self.make_An_admin_update), with:dic, afterDelay: 1.0)
            }
        }
    }
    
    func do_exit_group(ResponseDict : NSDictionary) {
        
        let err:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "err"))
        if(err == "0")
        {
            let groupId:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "groupId"))
            
            let groupType:String="8"

            let left_id:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "from"))
            
            let left_msisid:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "FromMsisdn"))
            
            let id = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id"))
            
            let createdBy = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from"))
            
            let Msg = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "message"))
            
            let timeStamp = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id"))
            
            let toDocId = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "toDocId"))
            let to:String=groupId
            let param_ack=["groupType": "12", "from": Themes.sharedInstance.Getuser_id(), "groupId": groupId, "status":2, "msgId": id] as [String : Any]
            self.GroupmessageAcknowledgement(Param: param_ack)
            let checkbool:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "id", FetchString: id)
            let CheckOtherMessageDetail:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Other_Group_message, attribute: "id", FetchString: id)
            if(!CheckOtherMessageDetail)
            {
                let Group_messagePram=["person_id":"","person_msisid" : "", "admin_id":"","admin_msisid":"","from":createdBy,"group_id":groupId,"group_type":groupType,"id":id,"left_id":left_id,"left_msisid":left_msisid,"new_pic":"","old_pic":"","pic_changed_msisid":""]
                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Group_messagePram as NSDictionary, Entityname: Constant.sharedinstance.Other_Group_message)
                Themes.sharedInstance.makeGroupActionNotification(id: id)
            }
            let dic : [AnyHashable: Any]
            if(!checkbool)
            {
                dic = ["type": "0","convId":groupId,"doc_id":toDocId
                    ,"filesize":"","from":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(createdBy)"
                    ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:to
                    ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
                    ),"message_status":Themes.sharedInstance.CheckNullvalue(Passed_value:"3"
                    ),"id":"\(id)","name":"","payload":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(Msg)"
                    ),"recordId":"","timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:timeStamp
                    ),"thumbnail":"","width":"0.0","height":"0.0","msgId":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(id)"
                    ),"contactmsisdn":""
                    ,"user_common_id":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(Themes.sharedInstance.Getuser_id())-\(to)"
                    ),"message_from":"1","chat_type":"group","info_type":groupType,"created_by":"\(createdBy)","is_reply":"0", "date" : Themes.sharedInstance.getTimeStamp()]
                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: dic as NSDictionary,Entityname: Constant.sharedinstance.Chat_one_one)
            }
            else
            {
                
                dic = ["payload": Themes.sharedInstance.CheckNullvalue(Passed_value:"\(Msg)")]
                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_one_one, FetchString: id, attribute: "id", UpdationElements: dic as NSDictionary?)
            }
            if(!CheckOtherMessageDetail)
            {
                let chat_type_dict:[String: String] = ["chat_type": "group"]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.Incomingmessage), object: dic , userInfo: chat_type_dict)
            }
            self.GetGroupDetails(GroupIDArr: [groupId])
            if(left_id == Themes.sharedInstance.Getuser_id()) {
                self.perform(#selector(self.GroupInfoUpdate(_:)), with:["data" : dic, "message" : "you removed"], afterDelay: 1.5)
            }
            else {
                self.perform(#selector(self.GroupInfoUpdate(_:)), with:["data" : dic, "message" : "removed"], afterDelay: 1.5)
            }
        }
    }
    
    func ListenUniqueEvents()
    {
        socket.on(Constant.sharedinstance.sc_app_settings as String) {data, ack in
            
            let data = self.returnDataFromEncryption(data)
            
            let ErrorStr:String = Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            if(ErrorStr == "1")
            {
            }
            else
            {
                let ResponseDict : NSDictionary = data
                if(ResponseDict.count > 0)
                {
                    let email:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "email"))
                    let recovery_email:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "recovery_email"))
                    let recovery_phone = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "recovery_phone"))
                    
                    let privacy:NSDictionary = ResponseDict.object(forKey: "privacy") as! NSDictionary
                    let last_seen:String = Themes.sharedInstance.CheckNullvalue(Passed_value: privacy.object(forKey: "last_seen"))
                    let profile_photo:String = Themes.sharedInstance.CheckNullvalue(Passed_value: privacy.object(forKey: "profile_photo"))
                    let show_status:String = Themes.sharedInstance.CheckNullvalue(Passed_value: privacy.object(forKey: "status"))
                    
                    let BlockedArr = ResponseDict.object(forKey: "blockedChat") as! [NSDictionary]
                    let contactBlockedArr = ResponseDict.object(forKey: "contactblockedChat") as! [NSDictionary]
                    let chatLockArr = ResponseDict.object(forKey: "ChatLock") as! [NSDictionary]
                    let singlechatStatusArr = ResponseDict.object(forKey: "singlechatStatus") as! [NSDictionary]
                    let groupchatStatusArr = ResponseDict.object(forKey: "groupchatStatus") as! [NSDictionary]
                    let clearchatNotify = ResponseDict.object(forKey: "clearchatNotify") as! [NSDictionary]

                    let param=["email":email,"recovery_email":recovery_email,"recovery_phone":recovery_phone, "last_seen" : last_seen, "profile_photo" : profile_photo, "show_status" : show_status]
                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail, FetchString: Themes.sharedInstance.Getuser_id(), attribute: "user_id", UpdationElements: param as NSDictionary?)
                    
                    DatabaseHandler.sharedInstance.truncateDataForTable(Entityname: Constant.sharedinstance.Blocked_user)
                    _ = BlockedArr.map {
                        let Dict:NSDictionary = $0
                        let from:String = Themes.sharedInstance.CheckNullvalue(Passed_value: Dict.object(forKey: "toUserId"))
                        let status:String = Themes.sharedInstance.CheckNullvalue(Passed_value: Dict.object(forKey: "is_blocked"))
                        
                        let id = from
                        let db = Constant.sharedinstance.Blocked_user
                        
                        if(status == "1"){
                            let param=["id" : id]
                            let block = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: db, attribute: "id", FetchString: id)
                            if(!block)
                            {
                                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: param as NSDictionary, Entityname: db)
                            }
                        }
                    }
                    DatabaseHandler.sharedInstance.truncateDataForTable(Entityname: Constant.sharedinstance.Contact_Blocked_user)
                    _ = contactBlockedArr.map {
                        let Dict:NSDictionary = $0
                        let to:String = Themes.sharedInstance.CheckNullvalue(Passed_value: Dict.object(forKey: "toUserId"))
                        let status:String = Themes.sharedInstance.CheckNullvalue(Passed_value: Dict.object(forKey: "is_contact_blocked"))
                        
                        let id = to
                        let db = Constant.sharedinstance.Contact_Blocked_user
                        
                        if(status == "1"){
                            let param=["id" : id]
                            let block = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: db, attribute: "id", FetchString: id)
                            if(!block)
                            {
                                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: param as NSDictionary, Entityname: db)
                            }
                        }
                    }
                    DatabaseHandler.sharedInstance.truncateDataForTable(Entityname: Constant.sharedinstance.Lock_Details)
                    _ = chatLockArr.map {
                        let Dict:NSDictionary = $0
                        let is_locked = Themes.sharedInstance.CheckNullvalue(Passed_value: Dict.object(forKey: "is_locked"))
                        if(is_locked == "1")
                        {
                            let convId = Themes.sharedInstance.CheckNullvalue(Passed_value: Dict.object(forKey: "convId"))
                            let mobile_password = Themes.sharedInstance.CheckNullvalue(Passed_value: Dict.object(forKey: "password"))
                            let to = Themes.sharedInstance.CheckNullvalue(Passed_value: Dict.object(forKey: "toUserId"))
                            let type = Themes.sharedInstance.CheckNullvalue(Passed_value: Dict.object(forKey: "chat_type"))
                            
                            let attribute = (type == "single") ? "id" : "groupId"
                            let id = (type == "single") ? to : convId
                            
                            let param=[attribute : id, "password" : "", "encrypt_password" : mobile_password, "convId" : convId, "type" : type]
                            
                            let lock = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Lock_Details, attribute: attribute, FetchString: id)
                            if(!lock)
                            {
                                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: param as NSDictionary, Entityname: Constant.sharedinstance.Lock_Details)
                            }
                        }
                    }
                    _ = singlechatStatusArr.map {
                        let P1 = NSPredicate(format: "convId = %@", Themes.sharedInstance.CheckNullvalue(Passed_value: $0.value(forKey: "convId")))
                        let P2:NSPredicate = NSPredicate(format: "message_from == 1")
                        let P3:NSPredicate = NSPredicate(format: "message_status != 3")
                        let P4:NSPredicate = NSPredicate(format: "message_status != 0")
                        let P5:NSPredicate = NSPredicate(format: "while_blocked != 1")
                        let status_update:NSCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [P1,P2,P3,P4,P5])
                        let message_status = Themes.sharedInstance.CheckNullvalue(Passed_value: $0.value(forKey: "message_status"))

                        let messages = DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Chat_one_one, SortDescriptor: nil, predicate: status_update, Limit: 0) as! [Chat_one_one]
                        
                        let dict:NSDictionary = ["message_status" : message_status]
                        DatabaseHandler.sharedInstance.UpdateDataWithPredicate(Entityname: Constant.sharedinstance.Chat_one_one, predicate: status_update, UpdationElements: dict)
                        
                        _ = messages.map {
                            let doc_id = Themes.sharedInstance.CheckNullvalue(Passed_value: $0.doc_id)
                            let ComposedDict = ["doc_id":doc_id,"message_status":message_status]
                            let chat_type_dict:[String: String] = ["chat_type": "messagestatus"]
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.outgoingmessage), object: ComposedDict , userInfo: chat_type_dict)
                        }
                    }
                    _ = groupchatStatusArr.map {
                        let convId = Themes.sharedInstance.CheckNullvalue(Passed_value: $0.value(forKey: "convId"))
                        let to_user = $0.value(forKey: "to_user") as! [[String : Any]]
                        let groupId = Themes.sharedInstance.CheckNullvalue(Passed_value: $0.value(forKey: "convId"))
                        
                        let messages = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Group_message_ack, attribute: "convId", FetchString: convId, SortDescriptor: nil) as! [Group_message_ack]
                        _ = messages.map {
                            let msgId = Themes.sharedInstance.CheckNullvalue(Passed_value: $0.msgId)
                            let id = Themes.sharedInstance.CheckNullvalue(Passed_value: $0.msgId)
                            
                            var readArr = $0.read_arr is Data ? NSKeyedUnarchiver.unarchiveObject(with: $0.read_arr as! Data) as! [String] :  $0.read_arr as! [String]
                            var deliverArr = $0.deliver_arr is Data ? NSKeyedUnarchiver.unarchiveObject(with: $0.deliver_arr as! Data) as! [String] :  $0.deliver_arr as! [String]
                            _ = to_user.map {
                                let from = Themes.sharedInstance.CheckNullvalue(Passed_value: $0["id"])
                                let status = Themes.sharedInstance.CheckNullvalue(Passed_value: $0["status"])
                                if(status == "2" && readArr.contains(from)) {
                                    var index = (readArr as NSArray).index(of: from)
                                    readArr.remove(at: index)
                                    
                                    if(deliverArr.contains(from)) {
                                        index = (deliverArr as NSArray).index(of: from)
                                        deliverArr.remove(at: index)
                                    }
                                    
                                    let read = NSKeyedArchiver.archivedData(withRootObject: readArr)
                                    let deliver = NSKeyedArchiver.archivedData(withRootObject: deliverArr)
                                    let param = ["read_arr" : read, "deliver_arr" : deliver, "msgId" : msgId] as [String : Any]
                                    
                                    let checkMessage = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Group_message_ack, attribute: "msgId", FetchString: msgId)
                                    if(checkMessage) {
                                        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Group_message_ack, FetchString: msgId, attribute: "msgId", UpdationElements: param as NSDictionary)
                                    }
                                    if deliverArr.count == 0 {
                                        let dic = ["message_status" : "2"]
                                        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_one_one, FetchString: msgId, attribute: "msgId", UpdationElements: dic as NSDictionary)
                                        
                                        let msg_dic = ["message_status":"2","groupId":groupId,"message_id":id]
                                        let chat_type_dict:[String: String] = ["chat_type": "groupmessagestatus"]
                                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.outgoingmessage), object: msg_dic , userInfo: chat_type_dict)
                                        
                                    }
                                    if readArr.count == 0 {
                                        let dic = ["message_status" : "3"]
                                        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_one_one, FetchString: msgId, attribute: "msgId", UpdationElements: dic as NSDictionary)
                                        
                                        let msg_dic = ["message_status":"3","groupId":groupId,"message_id":id]
                                        let chat_type_dict:[String: String] = ["chat_type": "groupmessagestatus"]
                                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.outgoingmessage), object: msg_dic , userInfo: chat_type_dict)
                                    }
                                }
                                else if(status == "1" && deliverArr.contains(from)) {
                                    let index = (deliverArr as NSArray).index(of: from)
                                    deliverArr.remove(at: index)
                                    
                                    let deliver = NSKeyedArchiver.archivedData(withRootObject: deliverArr)
                                    let param = ["deliver_arr" : deliver, "msgId" : msgId] as [String : Any]
                                    let checkMessage = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Group_message_ack, attribute: "msgId", FetchString: msgId)
                                    if(checkMessage) {
                                        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Group_message_ack, FetchString: msgId, attribute: "msgId", UpdationElements: param as NSDictionary)
                                    }
                                    
                                    guard deliverArr.count == 0 else { return }
                                    let dic = ["message_status" : "2"]
                                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_one_one, FetchString: msgId, attribute: "msgId", UpdationElements: dic as NSDictionary)
                                    
                                    let msg_dic = ["message_status":"2","groupId":groupId,"message_id":id]
                                    let chat_type_dict:[String: String] = ["chat_type": "groupmessagestatus"]
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.outgoingmessage), object: msg_dic , userInfo: chat_type_dict)
                                }
                            }
                        }
                    }
                    _ = clearchatNotify.map {
                        let Dict:NSDictionary = $0
                        let convId:String = Themes.sharedInstance.CheckNullvalue(Passed_value: Dict.object(forKey: "convId"))
                        let lastId:String = Themes.sharedInstance.CheckNullvalue(Passed_value: Dict.object(forKey: "lastId"))
                        
                        _ = Themes.sharedInstance.CheckNullvalue(Passed_value: Dict.object(forKey: "_id"))
                        
                        let opponent:String = Themes.sharedInstance.CheckNullvalue(Passed_value: Dict.object(forKey: "opponent"))
                        
                        let star_status:String = Themes.sharedInstance.CheckNullvalue(Passed_value: Dict.object(forKey: "star_status"))
                        let notifyType:String = Themes.sharedInstance.CheckNullvalue(Passed_value: Dict.object(forKey: "notifyType"))
                        if(notifyType == "delete"){
                            Themes.sharedInstance.deleteOpponentChats(opponent, convId, is_delete: true, lastId)
                        }else if(notifyType == "clear"){
                            Themes.sharedInstance.executeClearOpponentChat(star_status, opponent, lastId)
                        }
                    }
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: nil , userInfo: nil)
            }
        }
        
        socket.on(Constant.sharedinstance.RemovedByAdmin as String) {data, ack in
            
            let data = self.returnDataFromEncryption(data)
            
            let ErrorStr:String = Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"))
            if(ErrorStr == "1")
            {
            }
            else
            {
                let ResponseDict : NSDictionary = data
                let id = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "_id"))
                if(id == Themes.sharedInstance.Getuser_id())
                {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.user_deleted), object:nil)
                }
                
            }
            
        }
    }
    
    func ListenSocketStatusEvents(Nickname: NSString) {
        socket.on(Constant.sharedinstance.Connect as String) {data, ack in
            Themes.sharedInstance.showWaitingNetwork(false, state: true)
            self.CreateRoom(Nickname: Nickname);
        }
        
        socket.on(Constant.sharedinstance.network_disconnect as String) {data, ack in
            print("..Check Socket dis Connection.....\(data).........")
            Themes.sharedInstance.showWaitingNetwork(false, state: false)
        }
        
        socket.on(Constant.sharedinstance.network_error as String) {data, ack in
            print("..Check ERROR.....\(data).........")
        }
    }
    
    func ListenSocketStatusEventsCalls() {
        callsocket.on(Constant.sharedinstance.Connect as String) {data, ack in
            print(data)
        }
        
        callsocket.on(Constant.sharedinstance.network_disconnect as String) {data, ack in
            print("..Check Socket dis Connection.....\(data).........")
        }
        
        callsocket.on(Constant.sharedinstance.network_error as String) {data, ack in
            print("..Check ERROR.....\(data).........")
        }
    }
    
    func Listentochat(Nickname:NSString)
    {
        socket.on(Constant.sharedinstance.sc_change_new_security_code as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            let ErrorStr:String=Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            if(ErrorStr != "1")
            {
                let security_code:String = Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "security_code"))
                
                let from:String = Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "from"))
                
                let dict:[String:String] = ["security_code":security_code]
                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Favourite_Contact, FetchString: from, attribute: "id", UpdationElements: dict as NSDictionary)
                
            }
            
        }
        socket.on(Constant.sharedinstance.qrdata as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            let ErrorStr:String=Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            if(ErrorStr != "1")
            {
            }
        }
        socket.on(Constant.sharedinstance.qrdataresponse as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            let ErrorStr:String=Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            let random:String=Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "random"));

            if(ErrorStr != "1")
            {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.qrResponse), object: ["success" : "1"] , userInfo: nil)
            }
            else
            {
                if(self.qrCode == random)
                {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.qrResponse), object: ["success" : "1"] , userInfo: nil)
                }
                else
                {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.qrResponse), object: ["success" : "0"] , userInfo: nil)
                }
            }
        }
        socket.on(Constant.sharedinstance.sc_get_server_time as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            let ErrorStr:String=Themes.sharedInstance.CheckNullvalue(Passed_value: (data ).object(forKey: "err"));
            if(ErrorStr == "1" || ErrorStr == "")
            {
            }
            else
            {
                let ResponseDict:NSDictionary=data;
                
                let timestamp = Int64(String(Date().ticks))!
                
                let server_time = Int64(Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "server_time")))!
                
                let client_time = Int64(Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "client_time")))!
                let server_time_diff = timestamp - (server_time + (timestamp - client_time)) ;
                Themes.sharedInstance.saveServerTime(serverDiff: "\(server_time_diff)", serverTime: "\(server_time)")
            }
        }
        
        socket.on(Constant.sharedinstance.sc_new_room_connection as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            let ErrorStr:String=Themes.sharedInstance.CheckNullvalue(Passed_value: (data  ).object(forKey: "err"));
            if(ErrorStr == "1")
            {
                
            }
            else
            {
                let useridArr:[String] = data.object(forKey: "users") as! [String]
                if(useridArr.count > 0)
                {
                    var oppid:String = ""
                    _ = useridArr.map{
                        if($0 != Themes.sharedInstance.Getuser_id())
                        {
                            oppid = $0
                        }
                    }
                    let dict:[String:String] = ["convId":Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "convId")),"security_code":Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "security_code") ),"user_id":Themes.sharedInstance.Getuser_id(),"opp_id":oppid]
                    let checkbook:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Conv_detail, attribute: "opp_id", FetchString: oppid)
                    if(!checkbook)
                    {
                        DatabaseHandler.sharedInstance.InserttoDatabase(Dict: dict as NSDictionary, Entityname: Constant.sharedinstance.Conv_detail)
                    }
                    else
                    {
                        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Conv_detail, FetchString: oppid, attribute: "opp_id", UpdationElements: dict as NSDictionary)
                    }
                    let param = ["security_code":Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "security_code"))]
                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Favourite_Contact, FetchString: oppid, attribute: "id", UpdationElements: param as NSDictionary)
                }
            }
            
        }
        
        
       
        
        socket.on(Constant.sharedinstance.sc_typing as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            let ErrorStr:String=Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            if(ErrorStr == "1")
            {
            }
            else
            {
                let ResponseDict:NSDictionary=data;
                if(ResponseDict.count > 0)
                {
                    let id:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "convId"))
                    
                    let type:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "type"))
                    
                    if(type == "group"){
                        if(self.checkGroupMember(id: id)){
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sc_typing), object: ResponseDict , userInfo: nil)
                        }
                    }else{
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.sc_typing), object: ResponseDict , userInfo: nil)
                    }
                    
                    
                }
                
            }
            
        }
        socket.on(Constant.sharedinstance.sc_mute_chat as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            
            
            let ErrorStr:String=Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            if(ErrorStr == "1")
            {
            }
            else
            {
                let ResponseDict:NSDictionary=data
                
                let option = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "option"))
                let to = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "to"))
                let type = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "type"))
                let status = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "status"))
                let convId = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "convId"))
                
                if(status == "1"){
                    
                    let attribute = (type == "group") ? "groupId" : "id"
                    
                    let param = [attribute : to, "convId" : convId, "type" : type, "option" : option, "timestamp":String(Date().ticks), "user_id" : Themes.sharedInstance.Getuser_id()]
                    
                    let mute = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Mute_chats, attribute: attribute, FetchString: to)
                    if(!mute)
                    {
                        DatabaseHandler.sharedInstance.InserttoDatabase(Dict: param as NSDictionary, Entityname: Constant.sharedinstance.Mute_chats)
                    }
                }
                else
                {
                    let attribute = (type == "group") ? "groupId" : "id"
                    let mute = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Mute_chats, attribute: attribute, FetchString: to)
                    if(mute)
                    {
                        let predicate:NSPredicate = NSPredicate(format: "\(attribute) == %@", to)
                        DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Mute_chats, Predicatefromat: predicate, Deletestring: to, AttributeName: attribute)
                    }
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: nil , userInfo: nil)
            }
        }

        socket.on(Constant.sharedinstance.getMessageInfo as String) {data, ack in
            
            let data = self.returnDataFromEncryption(data)
            let ErrorStr:String=Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            if(ErrorStr == "1")
            {
            }
            else
            {
                let ResponseDict:NSDictionary=data
                let type:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "chat_type"))
                if(type == "single"){
                    if let messageDetails = ResponseDict.value(forKey: "messageDetails") as? [String : Any] {
                        AppDelegate.sharedInstance.MessageInfo(["time_to_seen" : Themes.sharedInstance.CheckNullvalue(Passed_value: messageDetails["time_to_seen"]), "time_to_deliever" : Themes.sharedInstance.CheckNullvalue(Passed_value: messageDetails["time_to_deliever"]), "id" : Themes.sharedInstance.CheckNullvalue(Passed_value: messageDetails["to"])])
                    }
                }else{
                    if let to = ResponseDict.value(forKey: "to") as? [[String : Any]] {
                        var time_to_seen_arr = [[String : Any]]()
                        var time_to_deliever_arr = [[String : Any]]()

                        _ = to.map {
                            let to = Themes.sharedInstance.CheckNullvalue(Passed_value: ($0["userDetails"] as? [String : Any])?["_id"])
                            if Themes.sharedInstance.CheckNullvalue(Passed_value: $0["time_to_seen"]) != "0" {
                                time_to_seen_arr.append(["time_to_seen" : Themes.sharedInstance.CheckNullvalue(Passed_value: $0["time_to_seen"]), "id" : to])
                            }
                            else if Themes.sharedInstance.CheckNullvalue(Passed_value: $0["time_to_deliever"]) != "0" {
                                time_to_deliever_arr.append(["time_to_deliever" : Themes.sharedInstance.CheckNullvalue(Passed_value: $0["time_to_deliever"]), "id" : to])
                            }
                        }
                        AppDelegate.sharedInstance.MessageInfo(["time_to_seen" : time_to_seen_arr, "time_to_deliever" : time_to_deliever_arr])
                    }
                }
            }
        }
        socket.on(Constant.sharedinstance.group as String) {data, ack in
            
            let data = self.returnDataFromEncryption(data)
            
            let ResponseDict:NSDictionary=data;
            let ErrorStr:String=Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            if(ErrorStr == "1")
            {
                
            }
            else
            {
                if(ResponseDict.count > 0)
                {
                    self.GroupResponse(ResponseDict, false)
                }
            }
        }
        
        socket.on(Constant.sharedinstance.updateMobilePushNotificationKey as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            
            let ErrorStr:String = Themes.sharedInstance.CheckNullvalue(Passed_value: (data ).object(forKey: "err"))
            if(ErrorStr == "1")
            {
            }
            else
            {
                let ResponseDict:NSDictionary!=data
                let apiMobile:NSDictionary = ResponseDict.object(forKey: "apiMobileKeys") as! NSDictionary
                let login_key = Themes.sharedInstance.CheckNullvalue(Passed_value: apiMobile.object(forKey: "login_key"))
                let loginDetails = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Login_details, attribute: "user_id", FetchString:  Themes.sharedInstance.Getuser_id(), SortDescriptor: nil) as! [Login_details]
                if(loginDetails.count > 0)
                {
                    let ResponseDictionary = loginDetails[0]
                    let my_login_key = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDictionary.login_key)
                    if(Int(login_key) != nil && Int(my_login_key) != nil)
                    {
                        if(Int(login_key)! > Int(my_login_key)!)
                        {
                            let alertview = JSSAlertView().show(
                                (AppDelegate.sharedInstance.navigationController?.topViewController)!,
                                title: Themes.sharedInstance.GetAppname(),
                                text: "Your account has been logged in another device.",
                                buttonText: "Ok",
                                cancelButtonText: nil
                            )
                            alertview.addAction(self.LogOut)
                        }
                    }
                }
            }
        }
        socket.on(Constant.sharedinstance.userDeactivated) { data, ack in
            
            let data = self.returnDataFromEncryption(data)
            let message = data["msg"] as? String
            if let obj =  data.object(forKey: "obj") as? [String: Any], let isDeleted = obj["isDeleted"] as? String, isDeleted == "1"{
                self.LogOut()
            }
        }

        
        socket.on(Constant.sharedinstance.checkMobileLoginKey as String) {data, ack in
            
            let data = self.returnDataFromEncryption(data)
            
            let ErrorStr:String = Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"))
            if(ErrorStr == "1")
            {
            }
            else
            {
                
                let ResponseDict : NSDictionary = data
                let apiMobile:NSDictionary = ResponseDict.object(forKey: "apiMobileKeys") as! NSDictionary
                let login_key = Themes.sharedInstance.CheckNullvalue(Passed_value: apiMobile.object(forKey: "login_key"))
                let loginDetails = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Login_details, attribute: "user_id", FetchString:  Themes.sharedInstance.Getuser_id(), SortDescriptor: nil) as! [Login_details]
                if(loginDetails.count > 0)
                {
                    let ResponseDictionary = loginDetails[0]
                    let my_login_key = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDictionary.login_key)
                    if(Int(login_key) != nil && Int(my_login_key) != nil)
                    {
                        if(Int(login_key)! > Int(my_login_key)!)
                        {
                            self.LogOut()
                        }
                    }
                }
            }
        }
        
        socket.on(Constant.sharedinstance.sc_change_mail as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            let ErrorStr:String=Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            if(ErrorStr == "1")
            {
            }else{
                let ResponseDict : NSDictionary = data
                let email = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "email"))
                let param=["email":email]
                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail, FetchString: Themes.sharedInstance.Getuser_id(), attribute: "user_id", UpdationElements: param as NSDictionary?)
                let info = ["type":"email"]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: nil , userInfo: info)
                
            }
        }
        
        socket.on(Constant.sharedinstance.sc_chat_lock as String) {data, ack in
            
            let data = self.returnDataFromEncryption(data)
            let ErrorStr:String=Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            if(ErrorStr == "1")
            {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: nil , userInfo: nil)
            }
            else{
                let ResponseDict : NSDictionary = data
                let mode = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "mode"))
                let from = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from"))
                let to = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "to"))
                let password:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "password"))
                
                var mobile_password = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "mobile_password"))
                let status = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "status"))
                let type = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "type"))
                let convId = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "convId"))
                
                if(mode == "phone"){
                    if(status == "1"){
                        let attribute = (type == "single") ? "id" : "groupId"

                        let param=[attribute : to, "password" : password, "encrypt_password" : mobile_password, "convId" : convId, "type" : type]

                        let lock = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Lock_Details, attribute: attribute, FetchString: to)
                        if(!lock)
                        {
                            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: param as NSDictionary, Entityname: Constant.sharedinstance.Lock_Details)
                        }
                        let info = ["type":"password"]
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: nil , userInfo: info)
                    }
                    else
                    {
                        let attribute = (type == "single") ? "id" : "groupId"
                        let lock = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Lock_Details, attribute: attribute, FetchString: to)
                        if(lock)
                        {
                            let predicate:NSPredicate = NSPredicate(format: "\(attribute) == %@", to)
                            DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Lock_Details, Predicatefromat: predicate, Deletestring: to, AttributeName: attribute)
                        }
                        let info = ["type":"unlock"]
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: nil , userInfo: info)
                    }
                    
                    
                }else{
                    
                    if(status == "1"){
                        
                        let password:String = password
                        let str:NSData = password.data(using: String.Encoding.utf8)! as NSData
                        let key:NSData = convId.data(using: String.Encoding.utf8)! as NSData
                        let iv:NSData = (Themes.sharedInstance.GetAppname()).data(using: String.Encoding.utf8)! as NSData
                        do{
                            let encrypt:NSData = try CC.crypt(.encrypt, blockMode: .cbc, algorithm: .aes, padding: .pkcs7Padding, data: str as Data, key: key as Data, iv: iv as Data) as NSData
                            let encrypted:NSData = encrypt.base64EncodedData(options: NSData.Base64EncodingOptions(rawValue: 0)) as NSData
                            mobile_password = NSString(data: encrypted as Data, encoding: String.Encoding.utf8.rawValue)! as String
                            print(mobile_password)
                            
                            let attribute = (type == "single") ? "id" : "groupId"
                            
                            let param=[attribute : to, "password" : password, "encrypt_password" : mobile_password, "convId" : convId, "type" : type]
                            
                            let lock = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Lock_Details, attribute: attribute, FetchString: to)
                            if(!lock)
                            {
                                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: param as NSDictionary, Entityname: Constant.sharedinstance.Lock_Details)
                            }
                            self.webChatLock(from: from, convId: convId, type: type, mobile_password: mobile_password, mode: "phone")
                            
                            let info = ["type":"password"]
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: nil , userInfo: info)
                        }catch{
                            
                        }
                        
                    }
                    else
                    {
                        let attribute = (type == "single") ? "id" : "groupId"
                        let lock = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Lock_Details, attribute: attribute, FetchString: to)
                        if(lock)
                        {
                            let predicate:NSPredicate = NSPredicate(format: "\(attribute) == %@", to)
                            DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Lock_Details, Predicatefromat: predicate, Deletestring: to, AttributeName: attribute)
                        }
                        let info = ["type":"unlock"]
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: nil , userInfo: info)
                    }
                }
            }
        }
        
        socket.on(Constant.sharedinstance.sc_change_recovery_email as String) {data, ack in
            
            let data = self.returnDataFromEncryption(data)
            let ErrorStr:String=Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            if(ErrorStr == "1")
            {
                let info = ["type":"recovery email not same"]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: nil , userInfo: info)
                
            }else{
                let ResponseDict : NSDictionary = data
                let recovery_email = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "recovery_email"))
                let param=["recovery_email":recovery_email]
                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail, FetchString: Themes.sharedInstance.Getuser_id(), attribute: "user_id", UpdationElements: param as NSDictionary?)
                let info = ["type":"recovery_email"]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: nil , userInfo: info)
                
            }
        }
        
        socket.on(Constant.sharedinstance.sc_change_recovery_phone as String) {data, ack in
            
            let data = self.returnDataFromEncryption(data)
            let ErrorStr:String=Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            if(ErrorStr == "1")
            {
            }else{
                let ResponseDict : NSDictionary = data
                let recovery_phone = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "recovery_phone"))
                let param=["recovery_phone":recovery_phone]
                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail, FetchString: Themes.sharedInstance.Getuser_id(), attribute: "user_id", UpdationElements: param as NSDictionary?)
                let info = ["type":"recovery_phone"]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: nil , userInfo: info)
                
            }
        }
        
        socket.on(Constant.sharedinstance.sc_get_user_Details as String) {data, ack in
            
            let data = self.returnDataFromEncryption(data)
            let ErrorStr:String=Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            if(ErrorStr == "1")
            {
            }else{
                let ResponseDict : NSDictionary = data
                if(ResponseDict.count > 0){
                    let from:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id"))
                    let Checkfav:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "id", FetchString: from)
                    if(!Checkfav) {
                        ContactHandler.sharedInstance.savenonfavArr(ResponseDict: ResponseDict)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: nil , userInfo: nil)
                    }else{
                        let showNum = ResponseDict.object(forKey: "showNumber") as? Bool ?? false
                        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Favourite_Contact, FetchString: from, attribute: "id", UpdationElements: ["showNumber":showNum])
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.showNumberUpdated), object: nil , userInfo: nil)
                    }
                }
            }
        }
        
        socket.on(Constant.sharedinstance.sc_change_online_status as String) {data, ack in
            
            let data = self.returnDataFromEncryption(data)
            let ErrorStr:String=Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            if(ErrorStr == "1")
            {
            }else{
                let ResponseDict : NSDictionary = data
                if(ResponseDict.count > 0){
                    let from:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "_id"))
                    let status:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "Status"))
                    var timeStamp = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "DateTime"))
                    if(timeStamp == ""){
                        timeStamp = String(Date().ticks)
                    }
                    let Checkuser:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "id", FetchString: from)
                    
                    if(Checkuser)
                    {
                        
                        let dict:NSDictionary = ["is_online":status,"time_stamp":timeStamp]
                        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Favourite_Contact, FetchString: from, attribute: "id", UpdationElements: dict as NSDictionary?)
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: nil , userInfo:nil)
                    }
                    
                }
            }
        }
        
        socket.on(Constant.sharedinstance.sc_user_offline_in_call as String) {data, ack in
            
            let data = self.returnDataFromEncryption(data)
            let ErrorStr:String=Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            if(ErrorStr == "1")
            {
            }else{
                let ResponseDict : NSDictionary = data
                if(ResponseDict.count > 0){
                    let from:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "_id"))
                    let status:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "Status"))
                    var timeStamp = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "DateTime"))
                    if(timeStamp == ""){
                        timeStamp = String(Date().ticks)
                    }
                    let dict_p:[String:String] = ["is_online":status,"time_stamp":timeStamp, "id" : from]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.online_status_in_call), object: ResponseDict , userInfo:dict_p)
                }
            }
        }
        
        socket.on(Constant.sharedinstance.sc_online_status as String) {data, ack in
            
            let data = self.returnDataFromEncryption(data)
            let ErrorStr:String=Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            if(ErrorStr == "1")
            {
            }else{
                let ResponseDict : NSDictionary = data
                if(ResponseDict.count > 0){
                    let from:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "_id"))
                    let status:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "Status"))
                    var timeStamp = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "DateTime"))
                    if(timeStamp == ""){
                        timeStamp = String(Date().ticks)
                    }
                    let privacy:NSDictionary = ResponseDict.object(forKey: "Privacy") as! NSDictionary
                    let last_seen:String = Themes.sharedInstance.CheckNullvalue(Passed_value: privacy.object(forKey: "last_seen"))
                    let profile_photo:String = Themes.sharedInstance.CheckNullvalue(Passed_value: privacy.object(forKey: "profile_photo"))
                    let show_status:String = Themes.sharedInstance.CheckNullvalue(Passed_value: privacy.object(forKey: "status"))
                    let Checkuser:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "id", FetchString: from)
                    if(Checkuser)
                    {
                        let dict:NSDictionary = ["is_online":status,"time_stamp":timeStamp,"last_seen":last_seen,"profile_photo":profile_photo,"show_status":show_status]
                        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Favourite_Contact, FetchString: from, attribute: "id", UpdationElements: dict as NSDictionary?)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: ResponseDict , userInfo:dict as? [AnyHashable : Any])
                    }
                    
                }
                
                
            }
        }
        
        socket.on(Constant.sharedinstance.sc_marked_chat as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            
            let ErrorStr:String = Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            if(ErrorStr == "1")
            {
            }
            else
            {
                let ResponseDict : NSDictionary = data
                if(ResponseDict.count > 0)
                {
                    let convId:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "convId"))
                    let type:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "type"))
                    let status:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "status"))
                    
                    let chat_type_dict:[String: String] = ["chat_type":type]
                    let FetchoppID = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_intiated_details, attrib_name: "conv_id", fetchString: convId, returnStr: "opponent_id")
                    let user_common_id = "\(Themes.sharedInstance.Getuser_id())-\(FetchoppID)"
                    
                    if(FetchoppID != "")
                    {
                        self.ExecuteReadUnreadChat(user_common_id: user_common_id, status: status)
                    }
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.outgoingmessage), object: ResponseDict , userInfo: chat_type_dict)
                    if(status == "0") {
                        let arr = DatabaseHandler.sharedInstance.FetchFromDatabaseWithLimit(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "user_common_id", Predicatefromat: "==", FetchString: user_common_id, Limit: 1, SortDescriptor: "timestamp") as! [Chat_one_one]
                        if(arr.count > 0) {
                            let chat = arr[0]
                            if(type == "group"){
                                let param_ack=["groupType": 12, "from": Themes.sharedInstance.Getuser_id(), "groupId": Themes.sharedInstance.CheckNullvalue(Passed_value: chat.convId), "status":2, "msgId": (Themes.sharedInstance.CheckNullvalue(Passed_value: chat.msgId) as NSString).longLongValue] as [String : Any]
                                self.GroupmessageAcknowledgement(Param: param_ack)
                            }
                            else
                            {
                                self.AcknowledegmentHandler(from: Themes.sharedInstance.Getuser_id() as NSString, to: FetchoppID as NSString, status: "3", doc_id: Themes.sharedInstance.CheckNullvalue(Passed_value: chat.doc_id) as NSString, timestamp: Themes.sharedInstance.CheckNullvalue(Passed_value: chat.msgId) as NSString, isEmit_status: true, is_deleted_message_ack: false, chat_type: type, convId: Themes.sharedInstance.CheckNullvalue(Passed_value: chat.convId))
                            }
                        }
                    }
                }
                
            }
        }
        
        socket.on(Constant.sharedinstance.sc_report_spam_user as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            
            let ErrorStr:String = Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            if(ErrorStr == "1")
            {
            }
            else
            {
                let ResponseDict : NSDictionary = data
                
                if(ResponseDict.count > 0)
                {
                    
                }
            }
            
        }
        
        socket.on(Constant.sharedinstance.sc_block_user as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            
            let ErrorStr:String = Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            
            if(ErrorStr == "1")
            {
                
            }
            else
            {
                let ResponseDict : NSDictionary = data
                
                if(ResponseDict.count > 0)
                {
                    let from:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from"))
                    let to:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "to"))
                    let status:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "status"))
                    
                    let isMe = from == Themes.sharedInstance.Getuser_id()
                    let id = isMe ? to : from
                    let db = isMe ? Constant.sharedinstance.Blocked_user : Constant.sharedinstance.Contact_Blocked_user

                    if(status == "1"){
                        let param=["id" : id]
                        let block = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: db, attribute: "id", FetchString: id)
                        if(!block)
                        {
                            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: param as NSDictionary, Entityname: db)
                        }
                    }
                    else
                    {
                        let block = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: db, attribute: "id", FetchString: id)
                        if(block)
                        {
                            let predicate:NSPredicate = NSPredicate(format: "id == %@", id)
                            DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: db, Predicatefromat: predicate, Deletestring: id, AttributeName: "id")
                        }
                    }
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: nil , userInfo: nil)
                }
            }
        }
        
        socket.on(Constant.sharedinstance.sc_delete_chat as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            
            let ErrorStr:String = Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            if(ErrorStr == "1")
            {
            }
            else
            {
                let ResponseDict : NSDictionary = data
                if(ResponseDict.count > 0){
                    let convId:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "convId"))
                    let lastId:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "lastId"))
                    let FetchoppID = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_intiated_details, attrib_name: "conv_id", fetchString: convId, returnStr: "opponent_id")
                    Themes.sharedInstance.clearExceptStarChats("0", FetchoppID, is_delete: true,timeStamp: lastId)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.reloadChats), object: nil, userInfo: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.change_chat_count), object: nil , userInfo: nil)
                    
                }
            }
        }
        socket.on(Constant.sharedinstance.sc_to_delete_chat as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            
            let ErrorStr:String = Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            if(ErrorStr == "1")
            {
            }
            else
            {
                let ResponseDict : NSDictionary = data
                if(ResponseDict.count > 0)
                {
                    let convId:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "convId"))
                    let notifyType:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "notifyType"))
                    
                    let lastId:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "lastId"))
                    let star_status:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "star_status"))
                    
                    let FetchoppID = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_intiated_details, attrib_name: "conv_id", fetchString: convId, returnStr: "opponent_id")
                    if notifyType == "delete"{
                        Themes.sharedInstance.deleteOpponentChats(FetchoppID, convId, is_delete: true, lastId)
                    }else{
                        Themes.sharedInstance.executeClearOpponentChat(star_status, FetchoppID, lastId)
                    }
                }
            }
        }
        socket.on(Constant.sharedinstance.sc_to_conv_settings as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            
            let ErrorStr:String = Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            
            if(ErrorStr == "1")
            {
            }
            else
            {
                let ResponseDict : NSDictionary = data
                
                if(ResponseDict.count > 0)
                {
                    
                    let to:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "to"))
                    
                    
                    let checkFav:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "id", FetchString: to)
                    
                    if(checkFav)
                    {
                        let security_code:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "security_code"))
                        
                        if(security_code != "")
                        {
                            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Favourite_Contact, FetchString: to, attribute: "id", UpdationElements: ["security_code" : security_code] as NSDictionary)
                        }
                        let privacy:NSDictionary = ResponseDict.value(forKey: "privacy") as! NSDictionary
                        let last_seen:String = Themes.sharedInstance.CheckNullvalue(Passed_value: privacy.value(forKey: "last_seen"))
                        let profile_photo:String = Themes.sharedInstance.CheckNullvalue(Passed_value: privacy.value(forKey: "profile_photo"))
                        let status:String = Themes.sharedInstance.CheckNullvalue(Passed_value: privacy.value(forKey: "status"))
                        if(to == Themes.sharedInstance.Getuser_id()){
                            let param=["last_seen":last_seen,"profile_photo":profile_photo,"show_status":status]
                            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail, FetchString: Themes.sharedInstance.Getuser_id(), attribute: "user_id", UpdationElements: param as NSDictionary?)
                        }else{
                            let checkBool:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname:Constant.sharedinstance.Favourite_Contact , attribute: "id", FetchString: to)
                            if(checkBool)
                            {
                                let param=["last_seen":last_seen,"profile_photo":profile_photo,"show_status":status]
                                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Favourite_Contact, FetchString: to, attribute: "id", UpdationElements: param as NSDictionary?)
                            }
                        }
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: nil , userInfo: nil)
                    }
                    
                }
                
            }
            
        }
        
        socket.on(Constant.sharedinstance.StarMessage as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            
            let ErrorStr:String = Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            if(ErrorStr == "1")
            {
            }
            else
            {
                let ResponseDict : NSDictionary = data
                if(ResponseDict.count > 0)
                {
                    let doc_id:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "doc_id"))
                    //                    let type:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "type"))
                    let status:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "status"))
                    let checkmsg:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "doc_id", FetchString: doc_id)
                    if(checkmsg)
                    {
                        let param:NSDictionary = ["isStar":status]
                        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_one_one, FetchString: doc_id, attribute: "doc_id", UpdationElements: param)
                    }
                    
                    //                        let chat_type_dict:[String: String] = ["chat_type": "starredstatus"]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.StarUpdate), object: ResponseDict , userInfo: nil)
                }
            }
        }
        
        socket.on(Constant.sharedinstance.sc_call as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            
            let ErrorStr:String = Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            if(ErrorStr == "1")
            {
                let msg:String = Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "msg"));
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.updateCallRecord), object: ["error" : msg], userInfo: nil)
            }
            else
            {
                let ResponseDict : NSDictionary = data
                let from  = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "from"))
                let Check_Fav:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "id", FetchString: from)
                if(!Check_Fav)
                {
                    if(from != Themes.sharedInstance.Getuser_id())
                    {
                        let param_userDetails:[String:Any]=["userId":from]
                        self.EmituserDetails(Param: param_userDetails)
                    }
                }
                print("sc_call ResponseDict =>\(ResponseDict)")
                Callhandler.sharedInstance.CallIncomingAcknowledgement(responseDict: ResponseDict)
            }
        }
        
        socket.on(Constant.sharedinstance.sc_call_ack as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            
            let ErrorStr:String = Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            if(ErrorStr == "1")
            {
                
            }
            else
            {
            }
        }
        
        socket.on(Constant.sharedinstance.sc_call_status as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            
            let ErrorStr:String = Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            if(ErrorStr == "1")
            {
                
                
            }
            else
            {
                let ResponseDict : NSDictionary = data
                Callhandler.sharedInstance.CallStatus(responseDict: ResponseDict)
                
            }
        }
        
        socket.on(Constant.sharedinstance.sc_call_response as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            
            let ErrorStr:String = Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            if(ErrorStr == "1")
            {
                
            }
            else
            {
                let ResponseDict:NSDictionary = data.object(forKey: "data") as! NSDictionary
                Callhandler.sharedInstance.CallOutgoingAcknowledgement(responseDict: ResponseDict)
            }
        }
        
        socket.on(Constant.sharedinstance.sc_call_retry as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            
            let ErrorStr:String = Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            if(ErrorStr == "1")
            {
                AppDelegate.sharedInstance.RemoveCallRetry()
            }
            else
            {
                AppDelegate.sharedInstance.RemoveCallRetry()
            }
        }
        
        socket.on(Constant.sharedinstance.sc_get_call_status as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            
            let ErrorStr:String = Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            if(ErrorStr == "1")
            {
            }
            else
            {
                let ResponseDict = data
                let call_status = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "call_status"))
                
                AppDelegate.sharedInstance.CallStatus(call_status: call_status)
            }
        }
        
        socket.on(Constant.sharedinstance.sc_call_status_response as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            
            
            let ErrorStr:String = Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            if(ErrorStr == "1")
            {
            }
            else
            {
            }
        }
        
        socket.on(Constant.sharedinstance.RemoveMessage as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            
            let ErrorStr:String = Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            if(ErrorStr == "1")
            {
            }
            else
            {
                let ResponseDict : NSDictionary = data
                if(ResponseDict.count > 0)
                {
                    let convId:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "convId"))
                    let type:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "type"))
                    let recordId:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "recordId"))
                    let chat_type_dict:[String: String] = ["chat_type": type]
                    _ = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_intiated_details, attrib_name: "conv_id", fetchString: convId, returnStr: "opponent_id")
                    let chat_type:String! = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_one_one, attrib_name: "recordId", fetchString: recordId, returnStr: "type")
                    let thumbnail:String! = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_one_one, attrib_name: "recordId", fetchString: recordId, returnStr: "thumbnail")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.outgoingmessage), object: ResponseDict , userInfo: chat_type_dict)
                    if(chat_type != "13")
                    {
                        if (AppDelegate.sharedInstance.navigationController?.topViewController is InitiateChatViewController || AppDelegate.sharedInstance.isVideoViewPresented){
                            // viewController is visible
                            if(chat_type != nil && chat_type != "")
                            {
                                if(chat_type == "0" || chat_type == "4" || chat_type == "5" || chat_type == "14" || chat_type == "11")
                                {
                                    let p1 = NSPredicate(format: "recordId = %@", recordId)
                                    DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Chat_one_one, Predicatefromat: p1, Deletestring: "id", AttributeName: "id")
                                    
                                }
                                else
                                {
                                    let p1 = NSPredicate(format: "recordId = %@", recordId)
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
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.loadChatView), object: nil , userInfo: ["recordId" : recordId])
                        }
                    }
                    
                }
                
            }
            
        }
        
        socket.on(Constant.sharedinstance.sc_remove_message_everyone as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            
            let ErrorStr:String = Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            if(ErrorStr == "1")
            {
            }
            else
            {
                let ResponseDict : NSDictionary = data
                if(ResponseDict.count > 0)
                {
                    let from:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from"))
                    let recordId:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "recordId"))
                    let doc_id:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "doc_id"))
                    
                    let convId:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "convId"))
                    
                    let chat_type:String! = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_one_one, attrib_name: "recordId", fetchString: recordId, returnStr: "type")
                    
                    let chat_type1:String! = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_one_one, attrib_name: "recordId", fetchString: recordId, returnStr: "chat_type")
                    
                    let thumbnail:String! = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_one_one, attrib_name: "recordId", fetchString: recordId, returnStr: "thumbnail")
                    let msgId:String! = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_one_one, attrib_name: "recordId", fetchString: recordId, returnStr: "msgId")
                    
                    if (AppDelegate.sharedInstance.navigationController?.topViewController is InitiateChatViewController || AppDelegate.sharedInstance.isVideoViewPresented){
                        // viewController is visible
                        if(chat_type != nil && chat_type != "")
                        {
                            if(chat_type == "0" || chat_type == "4" || chat_type == "5" || chat_type == "14" || chat_type == "11")
                            {
                                let p1 = NSPredicate(format: "recordId = %@", recordId)
                                var param = NSDictionary()
                                if(from == Themes.sharedInstance.Getuser_id())
                                {
                                    param = ["is_deleted" : "1", "type" : "0", "payload" : "🚫 You deleted this message."] as NSDictionary
                                    
                                }
                                else
                                {
                                    param = ["is_deleted" : "1", "type" : "0", "payload" : "🚫 This message was deleted."] as NSDictionary
                                }
                                
                                DatabaseHandler.sharedInstance.UpdateDataWithPredicate(Entityname: Constant.sharedinstance.Chat_one_one, predicate: p1, UpdationElements: param)
                                
                            }
                            else
                            {
                                let p1 = NSPredicate(format: "recordId = %@", recordId)
                                
                                var param = NSDictionary()
                                if(from == Themes.sharedInstance.Getuser_id())
                                {
                                    param = ["is_deleted" : "1", "type" : "0", "payload" : "🚫 You deleted this message."] as NSDictionary
                                    
                                }
                                else
                                {
                                    param = ["is_deleted" : "1", "type" : "0", "payload" : "🚫 This message was deleted."] as NSDictionary
                                }
                                
                                DatabaseHandler.sharedInstance.UpdateDataWithPredicate(Entityname: Constant.sharedinstance.Chat_one_one, predicate: p1, UpdationElements: param)
                                
                                
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
                        if(from != Themes.sharedInstance.Getuser_id())
                        {
                            self.AcknowledegmentHandler(from: Themes.sharedInstance.Getuser_id() as NSString, to: from! as NSString, status: "2", doc_id: doc_id! as NSString, timestamp: msgId! as NSString, isEmit_status: true, is_deleted_message_ack: true, chat_type: chat_type1, convId: convId)
                        }
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.updateCell), object: ResponseDict , userInfo: nil)
                    }
                    
                    
                }
                
            }
            
        }
        
        socket.on(Constant.sharedinstance.sc_remove_media_status as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            
            let ErrorStr:String = Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            if(ErrorStr == "1")
            {
            }
            else
            {
                let ResponseDict : NSDictionary = data
                if(ResponseDict.count > 0)
                {
                    let from:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from"))
                    if(from != Themes.sharedInstance.Getuser_id())
                    {
                        let recordId:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "recordId"))
                        let doc_id:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "doc_id"))
                        
                        
                        let chat_type = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Status_one_one, attrib_name: "recordId", fetchString: recordId, returnStr: "type")
                        
                        
                        
                        
                        if(chat_type == "0" || chat_type == "4" || chat_type == "5" || chat_type == "14" || chat_type == "11")
                        {
                            let p1 = NSPredicate(format: "recordId = %@", recordId)
                            DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Status_one_one, Predicatefromat: p1, Deletestring: "recordId", AttributeName: "recordId")
                            
                        }
                        else
                            
                        {
                            let p1 = NSPredicate(format: "recordId = %@", recordId)
                            DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Status_one_one, Predicatefromat: p1, Deletestring: "recordId", AttributeName: "recordId")
                            
                            let predic = NSPredicate(format: "upload_data_id == %@",doc_id)
                            
                            let uploadDetailArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Status_Upload_Details, attribute: "upload_data_id", FetchString: doc_id, SortDescriptor: nil) as! NSArray
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
                        }
                        
                        let checkmessage = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Status_one_one, attribute: "from", FetchString: from)
                        if(!checkmessage)
                        {
                            let p1 = NSPredicate(format: "user_common_id = %@", from)
                            
                            DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Status_initiated_details, Predicatefromat: p1, Deletestring: "user_common_id", AttributeName: "from")
                        }
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.incomingstatus), object: nil , userInfo: nil)
                        
                    }
                }
                
            }
            
        }
        
        socket.on(Constant.sharedinstance.sc_archived_chat as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            
            let ErrorStr:String = Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            if(ErrorStr == "1")
            {
            }
            else
            {
                let ResponseDict : NSDictionary = data
                if(ResponseDict.count > 0)
                {
                    let convId:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "convId"))
                    let type:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "type"))
                    let chat_type_dict:[String: String] = ["chat_type": type]
                    let FetchoppID = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_intiated_details, attrib_name: "conv_id", fetchString: convId, returnStr: "opponent_id")
                    let user_common_id = "\(Themes.sharedInstance.Getuser_id())-\(FetchoppID)"
                    let status:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "status"))
                    
                    if(FetchoppID != "")
                    {
                        self.ExecuteArchiveChat(user_common_id: user_common_id,status:status)
                    }
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.outgoingmessage), object: ResponseDict , userInfo: chat_type_dict)
                    if(type == "group")
                    {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: nil , userInfo: nil)
                    }
                }
                
            }
            
        }
        
        socket.on(Constant.sharedinstance.sc_clear_chat as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            
            let ErrorStr:String = Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            if(ErrorStr == "1")
            {
            }
            else
            {
                let ResponseDict : NSDictionary = data
                if(ResponseDict.count > 0)
                {
                    let convId:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "convId"))
                    let lastId:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "lastId"))
                    let star_status:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "star_status"))
                    let FetchoppID = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_intiated_details, attrib_name: "conv_id", fetchString: convId, returnStr: "opponent_id")
                    Themes.sharedInstance.clearExceptStarChats(star_status, FetchoppID, is_delete: false, timeStamp: lastId)
                }
            }
        }
        
        socket.on(Constant.sharedinstance.sc_recev_ImagePath as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            let ErrorStr:String=Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            if(ErrorStr == "1")
            {
                
            }
            else
            {
                let ResponseDict : NSDictionary = data
                if(ResponseDict.count > 0)
                {
                    let from:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from"))
                    let ImageName:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "ImageName"))
                    let uploadType:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "uploadType"))
                    
                    if(Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "uploadType")) == "group")
                    {
                        let filename:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "filename"))
                        AppDelegate.sharedInstance.ReceivedBufferImage(Status: "Updated", imagename: filename, uploadType: uploadType)
                    }
                    else if(Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "uploadType")) == "single"){
                        if(Themes.sharedInstance.Getuser_id() == from)
                        {
                            AppDelegate.sharedInstance.ReceivedBufferImage(Status: "Updated", imagename: ImageName, uploadType: uploadType)
                        }
                    }
                    else if(Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "uploadType")) == "single_chat")
                    {
                        AppDelegate.sharedInstance.ReceivedBufferImage_chat(Status: "Updated", imagename: ImageName, responseDict: ResponseDict, uploadType: uploadType)
                    }
                    else if(Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "uploadType")) == "status")
                    {
                        AppDelegate.sharedInstance.ReceivedBufferImage_chat(Status: "Updated", imagename: ImageName, responseDict: ResponseDict, uploadType: uploadType)
                    }
                    else  if(Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "uploadType")) == "celebrity"){
                        AppDelegate.sharedInstance.ReceivedBufferImage_chat(Status: "Updated", imagename: ImageName, responseDict: ResponseDict, uploadType: uploadType)
                    }
                }
                else
                {
                    
                }
            }
        }
        
        socket.on(Constant.sharedinstance.getFilesizeInBytes as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            let ErrorStr:String=Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            if(ErrorStr == "1")
            {
                let uploadType = Themes.sharedInstance.CheckNullvalue(Passed_value: data.value(forKey: "uploadType"))
                if(uploadType == "status")
                {
                    StatusUploadHandler.Sharedinstance.uploadFile(data_name: Themes.sharedInstance.CheckNullvalue(Passed_value: data.value(forKey: "ImageName")), file_name: Themes.sharedInstance.CheckNullvalue(Passed_value: data.value(forKey: "filename")))
                }
                else
                {
                    UploadHandler.Sharedinstance.uploadFile(data_name: Themes.sharedInstance.CheckNullvalue(Passed_value: data.value(forKey: "ImageName")), file_name: Themes.sharedInstance.CheckNullvalue(Passed_value: data.value(forKey: "filename")))
                }
            }
            else
            {
                let uploadType = Themes.sharedInstance.CheckNullvalue(Passed_value: data.value(forKey: "uploadType"))
                if(uploadType == "status")
                {
                    var total = Themes.sharedInstance.CheckNullvalue(Passed_value: StatusUploadHandler.Sharedinstance.ReturnuploadDetails(pathid: Themes.sharedInstance.CheckNullvalue(Passed_value: data.value(forKey: "ImageName")), upload_detail: "total_byte_count"))
                    total = total == "" ? "0" : total
                    let uploaded = Themes.sharedInstance.CheckNullvalue(Passed_value: data.value(forKey: "fileSizeInBytes"))
                    if(Int(uploaded)! <= Int(total)!)
                    {
                        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Status_Upload_Details, FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: data.value(forKey: "ImageName")), attribute: "upload_data_id", UpdationElements: ["upload_byte_count" : Themes.sharedInstance.CheckNullvalue(Passed_value: data.value(forKey: "fileSizeInBytes"))])
                        StatusUploadHandler.Sharedinstance.uploadFile(data_name: Themes.sharedInstance.CheckNullvalue(Passed_value: data.value(forKey: "ImageName")), file_name: Themes.sharedInstance.CheckNullvalue(Passed_value: data.value(forKey: "filename")))
                    }
                }
                else
                {
                    var total = Themes.sharedInstance.CheckNullvalue(Passed_value: UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: Themes.sharedInstance.CheckNullvalue(Passed_value: data.value(forKey: "ImageName")), upload_detail: "total_byte_count"))
                    total = total == "" ? "0" : total
                    let uploaded = Themes.sharedInstance.CheckNullvalue(Passed_value: data.value(forKey: "fileSizeInBytes"))
                    if(Int(uploaded)! <= Int(total)!)
                    {
                        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Upload_Details, FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: data.value(forKey: "ImageName")), attribute: "upload_data_id", UpdationElements: ["upload_byte_count" : Themes.sharedInstance.CheckNullvalue(Passed_value: data.value(forKey: "fileSizeInBytes"))])
                        UploadHandler.Sharedinstance.uploadFile(data_name: Themes.sharedInstance.CheckNullvalue(Passed_value: data.value(forKey: "ImageName")), file_name: Themes.sharedInstance.CheckNullvalue(Passed_value: data.value(forKey: "filename")))
                    }
                }
               
            }
        }
        socket.on(Constant.sharedinstance.sc_changeProfilePic as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            let ErrorStr:String=Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            if(ErrorStr == "1")
            {
                
            }
            else
            {
                let ResponseDict : NSDictionary = data
                if(ResponseDict.count > 0)
                {
                    if(Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "type")) == "single")
                    {
                        let user_ID = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from"))
                        if(user_ID == Themes.sharedInstance.Getuser_id())
                        {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.RemoveActivity), object: nil)
                            
                            var image_Url = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "file"))
                            if(image_Url.substring(to: 1) == ".")
                            {
                                image_Url.remove(at: image_Url.startIndex)
                            }
                            let imageUrl:String = ("\(ImgUrl)\(image_Url)")
                            
                            let CheckUser:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.User_detail, attribute: "user_id", FetchString:user_ID as String?)
                            if (!CheckUser){
                            }
                            else{
                                let UpdateDict:[String:Any]=["profilepic": imageUrl]
                                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail , FetchString: user_ID, attribute:"user_id" , UpdationElements: UpdateDict as NSDictionary?)
                            }
                            
                            if(self.Delegate?.statusUpdated?(_Updated: "CHECK") != nil)
                            {
                                self.Delegate?.statusUpdated!(_Updated: "Updated")
                            }
                        }
                        else
                        {
                            let checkBool:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname:Constant.sharedinstance.Favourite_Contact , attribute: "id", FetchString: user_ID)
                            if(checkBool)
                            {
                                var image_Url = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "file"))
                                if(image_Url.length > 0)
                                {
                                    if(image_Url.substring(to: 1) == ".")
                                    {
                                        image_Url.remove(at: image_Url.startIndex)
                                    }
                                    let imageUrl:String = ("\(ImgUrl)\(image_Url)")
                                    let param=["profilepic":imageUrl]
                                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Favourite_Contact, FetchString: user_ID, attribute: "id", UpdationElements: param as NSDictionary?)
                                }
                                else
                                {
                                    let param=["profilepic":""]
                                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Favourite_Contact, FetchString: user_ID, attribute: "id", UpdationElements: param as NSDictionary?)
                                }
                            }
                        }
                    }
                    else if (Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "type")) == "Group")
                    {
                    }
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: nil , userInfo: nil)
                }
                else
                {
                    
                }
            }
            
        }
        socket.on(Constant.sharedinstance.sc_get_offline_messages as String) {data, ack in
            
            let data = self.returnDataFromEncryption(data)
            
            let ResponseDict : NSDictionary = data;
            if(ResponseDict.count > 0)
            {
                let ErrorStr:String=Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
                if(ErrorStr != "1")
                {
                    if let result = data.value(forKey: "result"), let resultArr = result as? [Any] {
                        _ = resultArr.map {
                            if let dict = $0 as? NSDictionary {
                                self.StoreIncomingMessage(ResponseDict: dict,isFromoffline:true)
                            }
                        }
                    }
                }
            }
            else
            {
                
            }
        }
        
        socket.on(Constant.sharedinstance.sc_group_offline_message as String) {data, ack in
            
            let data = self.returnDataFromEncryption(data)
            
            let ResponseDict : NSDictionary = data;
            if(ResponseDict.count > 0)
            {
                let ErrorStr:String=Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
                if(ErrorStr != "1")
                {
                    if let result = data.value(forKey: "result"), let resultArr = result as? [Any] {
                        _ = resultArr.map {
                            if let dict = $0 as? NSDictionary {
                                if(dict.count > 0)
                                {
                                    self.GroupResponse(dict, true)
                                }
                            }
                        }
                    }
                }
            }
            else
            {
                
            }
        }
        
        socket.on(Constant.sharedinstance.sc_get_offline_status as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            
            let ResponseDict : NSDictionary = data;
            if(ResponseDict.count > 0)
            {
                let ErrorStr:String=Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
                if(ErrorStr != "1")
                {
                    if let result = data.value(forKey: "result"), let resultArr = result as? [Any] {
                        _ = resultArr.map {
                            if let ResponseDict = $0 as? NSDictionary {
                                let timestamp = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "id"))
                                if(Themes.sharedInstance.checkTimeStampMorethan24Hours(timestamp: timestamp))
                                {
                                    self.StoreIncomingStatusMessage(ResponseDict: ResponseDict,isFromoffline:true)
                                }
                                
                            }
                        }
                    }
                }
            }
            else
            {
                
            }
        }
        socket.on(Constant.sharedinstance.sc_get_offline_deleted_messages as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            
            let ResponseDict : NSDictionary = data;
            if(ResponseDict.count > 0)
            {
                let ErrorStr:String=Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
                if(ErrorStr != "1")
                {
                    if let result = data.value(forKey: "result"), let resultArr = result as? [Any] {
                        _ = resultArr.map {
                            if let ResponseDict = $0 as? NSDictionary {
                                let recordId:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "recordId"))
                                
                                let checkMessage = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "recordId", FetchString: recordId)
                                if(checkMessage)
                                {
                                    let from:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from"))
                                    let doc_id:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "docId"))
                                    let convId:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "convId"))
                                    
                                    let chat_type:String! = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_one_one, attrib_name: "recordId", fetchString: recordId, returnStr: "type")
                                    
                                    let chat_type1:String! = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_one_one, attrib_name: "recordId", fetchString: recordId, returnStr: "chat_type")
                                    
                                    let thumbnail:String! = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_one_one, attrib_name: "recordId", fetchString: recordId, returnStr: "thumbnail")
                                    let msgId:String! = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_one_one, attrib_name: "recordId", fetchString: recordId, returnStr: "msgId")
                                    
                                    if (AppDelegate.sharedInstance.navigationController?.topViewController is InitiateChatViewController || AppDelegate.sharedInstance.isVideoViewPresented){
                                        // viewController is visible
                                        if(chat_type != nil && chat_type != "")
                                        {
                                            if(chat_type == "0" || chat_type == "4" || chat_type == "5" || chat_type == "14" || chat_type == "11")
                                            {
                                                let p1 = NSPredicate(format: "recordId = %@", recordId)
                                                var param = NSDictionary()
                                                if(from == Themes.sharedInstance.Getuser_id())
                                                {
                                                    param = ["is_deleted" : "1", "type" : "0", "payload" : "🚫 You deleted this message."] as NSDictionary
                                                    
                                                }
                                                else
                                                {
                                                    param = ["is_deleted" : "1", "type" : "0", "payload" : "🚫 This message was deleted."] as NSDictionary
                                                }
                                                
                                                DatabaseHandler.sharedInstance.UpdateDataWithPredicate(Entityname: Constant.sharedinstance.Chat_one_one, predicate: p1, UpdationElements: param)
                                                
                                            }
                                            else
                                            {
                                                let p1 = NSPredicate(format: "recordId = %@", recordId)
                                                
                                                var param = NSDictionary()
                                                if(from == Themes.sharedInstance.Getuser_id())
                                                {
                                                    param = ["is_deleted" : "1", "type" : "0", "payload" : "🚫 You deleted this message."] as NSDictionary
                                                    
                                                }
                                                else
                                                {
                                                    param = ["is_deleted" : "1", "type" : "0", "payload" : "🚫 This message was deleted."] as NSDictionary
                                                }
                                                
                                                DatabaseHandler.sharedInstance.UpdateDataWithPredicate(Entityname: Constant.sharedinstance.Chat_one_one, predicate: p1, UpdationElements: param)
                                                
                                                
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
                                        if(from != Themes.sharedInstance.Getuser_id())
                                        {
                                            self.AcknowledegmentHandler(from: Themes.sharedInstance.Getuser_id() as NSString, to: from! as NSString, status: "2", doc_id: doc_id! as NSString, timestamp: msgId! as NSString, isEmit_status: true, is_deleted_message_ack: true, chat_type: chat_type1, convId: convId)
                                        }
                                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.updateCell), object: ResponseDict , userInfo: nil)
                                    }
                                    
                                }
                                else
                                {
                                    self.StoreIncomingMessage(ResponseDict: ResponseDict,isFromoffline:true)
                                }
                            }
                        }
                    }
                }
            }
            else
            {
                
            }
        }
        
        socket.on(Constant.sharedinstance.sc_group_offline_deleted_message as String) {data, ack in
            
            let data = self.returnDataFromEncryption(data)
            
            let ResponseDict : NSDictionary = data;
            if(ResponseDict.count > 0)
            {
                let ErrorStr:String=Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
                if(ErrorStr != "1")
                {
                    if let result = data.value(forKey: "result"), let resultArr = result as? [Any] {
                        _ = resultArr.map {
                            if let ResponseDict = $0 as? NSDictionary {
                                if(ResponseDict.count > 0)
                                {
                                    let recordId:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "recordId"))
                                    
                                    let checkMessage = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "recordId", FetchString: recordId)
                                    if(checkMessage)
                                    {
                                        let from:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from"))
                                        
                                        let chat_type:String! = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_one_one, attrib_name: "recordId", fetchString: recordId, returnStr: "type")
                                        
                                        
                                        let thumbnail:String! = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_one_one, attrib_name: "recordId", fetchString: recordId, returnStr: "thumbnail")
                                        
                                        let convId:String! = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_one_one, attrib_name: "recordId", fetchString: recordId, returnStr: "convId")
                                        
                                        let msgId:String! = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_one_one, attrib_name: "recordId", fetchString: recordId, returnStr: "msgId")
                                        
                                        
                                        if (AppDelegate.sharedInstance.navigationController?.topViewController is InitiateChatViewController || AppDelegate.sharedInstance.isVideoViewPresented){
                                            // viewController is visible
                                            if(chat_type != nil && chat_type != "")
                                            {
                                                if(chat_type == "0" || chat_type == "4" || chat_type == "5" || chat_type == "14" || chat_type == "11")
                                                {
                                                    let p1 = NSPredicate(format: "recordId = %@", recordId)
                                                    var param = NSDictionary()
                                                    if(from == Themes.sharedInstance.Getuser_id())
                                                    {
                                                        param = ["is_deleted" : "1", "type" : "0", "payload" : "🚫 You deleted this message."] as NSDictionary
                                                        
                                                    }
                                                    else
                                                    {
                                                        param = ["is_deleted" : "1", "type" : "0", "payload" : "🚫 This message was deleted."] as NSDictionary
                                                    }
                                                    
                                                    DatabaseHandler.sharedInstance.UpdateDataWithPredicate(Entityname: Constant.sharedinstance.Chat_one_one, predicate: p1, UpdationElements: param)
                                                    
                                                }
                                                else
                                                {
                                                    let p1 = NSPredicate(format: "recordId = %@", recordId)
                                                    
                                                    var param = NSDictionary()
                                                    if(from == Themes.sharedInstance.Getuser_id())
                                                    {
                                                        param = ["is_deleted" : "1", "type" : "0", "payload" : "🚫 You deleted this message."] as NSDictionary
                                                        
                                                    }
                                                    else
                                                    {
                                                        param = ["is_deleted" : "1", "type" : "0", "payload" : "🚫 This message was deleted."] as NSDictionary
                                                    }
                                                    
                                                    DatabaseHandler.sharedInstance.UpdateDataWithPredicate(Entityname: Constant.sharedinstance.Chat_one_one, predicate: p1, UpdationElements: param)
                                                    
                                                    
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
                                            if(from != Themes.sharedInstance.Getuser_id())
                                            {
                                                let param_ack=["groupType": 21, "from": Themes.sharedInstance.Getuser_id(), "groupId": convId, "status":2, "msgId":(msgId as NSString).longLongValue] as [String : Any]
                                                SocketIOManager.sharedInstance.GroupmessageAcknowledgement(Param: param_ack)
                                            }
                                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.updateCell), object: ResponseDict , userInfo: nil)
                                        }
                                        
                                    }
                                }
                            }
                        }
                    }
                }
            }
            else
            {
                
            }
        }
        socket.on(Constant.sharedinstance.getAllContacts as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            let ResponseDict:NSDictionary! = data;
            if(ResponseDict.count > 0)
            {
                let ErrorStr:String = Themes.sharedInstance.CheckNullvalue(Passed_value: (data).object(forKey: "err"));
                if(ErrorStr == "1") {
                    
                } else{
                    let ResponseDictArr:NSArray = ResponseDict.value(forKey: "usersData") as! NSArray
                    ContactHandler.sharedInstance.SaveFavContactFromServer(ResponseArr: ResponseDictArr, Index: 0)
                }
            }
        }
        socket.on(Constant.sharedinstance.sc_message_response as String) {data, ack in
            
            let data = self.returnDataFromEncryption(data)

            let ErrorStr:String=Themes.sharedInstance.CheckNullvalue(Passed_value: (data).object(forKey: "err"));
            if(ErrorStr == "0")
            {
                let ResponseDict:NSDictionary = data.object(forKey: "data") as! NSDictionary
                if(ResponseDict.count > 0)
                {
                    self.LoadResponseMessages(ResponseDict: ResponseDict)
                }
            }
            else
            {
            }
        }
        
        socket.on(Constant.sharedinstance.sc_media_status_response as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            let ErrorStr:String=Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            if(ErrorStr == "0")
            {
                let ResponseDict : NSDictionary = data.object(forKey: "data") as! NSDictionary
                if(ResponseDict.count > 0)
                {
                    self.LoadStatusResponseMessages(ResponseDict: ResponseDict)
                }
            }
            else
            {
                
            }
        }
        socket.on(Constant.sharedinstance.sc_message_status_update as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: {
                let ResponseDict : NSDictionary = data;
                if(ResponseDict.count > 0)
                {
                    let Doc_id:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "doc_id"));
                    let status:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "status"));
                    let to:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from"));
                    var ComposedDict:NSDictionary = NSDictionary()
                    var Dict:NSDictionary = NSDictionary()
                    let secret_type:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "secret_type"));                    
                    if(status == "2"){
                        ComposedDict = ["doc_id":Doc_id,"message_status":status,"to":to, "secret_type":secret_type]
                        Dict = ["message_status":status]
                    }else if(status == "3"){
                        ComposedDict = ["doc_id":Doc_id,"message_status":status,"to":to, "secret_type":secret_type]
                        Dict = ["message_status":status]
                    }

                    let chat_type_dict:[String: String] = ["chat_type": "messagestatus"]
                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_one_one, FetchString: Doc_id, attribute: "doc_id", UpdationElements: Dict)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.outgoingmessage), object: ComposedDict , userInfo: chat_type_dict)
                }
                else
                {
                    
                }
            })
        }
        socket.on(Constant.sharedinstance.sc_privacy_settings as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            
            let ResponseDict : NSDictionary = data;
            let ErrorStr:String=Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            if(ErrorStr == "1")
            {
            }else{
                if(ResponseDict.count > 0)
                {
                    let user_ID = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from"))
                  
                    let last_seen = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "last_seen"))
                    let profile_photo = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "profile_photo"))
                    let status = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "status"))

                    if(user_ID == Themes.sharedInstance.Getuser_id()){
                        let param=["last_seen":last_seen,"profile_photo":profile_photo,"show_status":status]
                        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail, FetchString: Themes.sharedInstance.Getuser_id(), attribute: "user_id", UpdationElements: param as NSDictionary?)
                        
                    }else{
                        let contactUserList : NSData = NSKeyedArchiver.archivedData(withRootObject: ResponseDict.value(forKey: "contactUserList") as! [String]) as NSData

                        let checkBool:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname:Constant.sharedinstance.Favourite_Contact , attribute: "id", FetchString: user_ID)
                        if(checkBool)
                        {
                            let param=["last_seen":last_seen,"profile_photo":profile_photo,"show_status":status, "contactUserList": contactUserList] as [String : Any]
                            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Favourite_Contact, FetchString: user_ID, attribute: "id", UpdationElements: param as NSDictionary?)
                        }
                    }
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: nil , userInfo: nil)
                
            }
        }
        socket.on(Constant.sharedinstance.sc_media_status_privacy as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            
            let ResponseDict : NSDictionary = data;
            let ErrorStr:String=Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            if(ErrorStr == "1")
            {
            }else{
                if(ResponseDict.count > 0)
                {
                    
                }
            }
        }
        
        socket.on(Constant.sharedinstance.sc_message_ack as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            
            let ResponseDict : NSDictionary = data;
            if(ResponseDict.count > 0)
            {
            }
        }
        
        socket.on(Constant.sharedinstance.sc_media_status_ack as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            
            let ResponseDict : NSDictionary = data;
            if(ResponseDict.count > 0)
            {
                let Doc_id:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "doc_id"));
                let convId:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "convId"));
                let Dict:NSDictionary = ["convId":convId]
                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Status_one_one, FetchString: Doc_id, attribute: "doc_id", UpdationElements: Dict)
            }
            else
            {
                
                
            }
        }
        
        socket.on(Constant.sharedinstance.sc_media_message_status_update as String){data, ack in
            let data = self.returnDataFromEncryption(data)
            
            let ResponseDict : NSDictionary = data;
            if(ResponseDict.count > 0)
            {
                let Doc_id:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "doc_id"));
                let current_time:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "currenttime"));
                let to:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from"));
                let status:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "status"));
                var ComposedDict:NSDictionary = NSDictionary()
                if(status == "3"){
                    ComposedDict = ["doc_id":Doc_id,"message_status":status,"to":to,"delivered_msg_time":current_time]
                    let messageIDArr:NSArray? = ResponseDict.value(forKey: "msgIds") as? NSArray
                    if(messageIDArr != nil)
                    {
                        
                        if((messageIDArr?.count)! > 0)
                        {
                            let msgID:String = Themes.sharedInstance.CheckNullvalue(Passed_value: messageIDArr![0])
                            
                            let FetchMessageArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Status_one_one, attribute: "msgId", FetchString: msgID, SortDescriptor: nil) as! NSArray
                            if(FetchMessageArr.count > 0)
                            {
                                for i in 0..<FetchMessageArr.count
                                {
                                    let messageObj:NSManagedObject = FetchMessageArr[i] as! NSManagedObject
                                    let from:String = Themes.sharedInstance.CheckNullvalue(Passed_value: messageObj.value(forKey: "from"));
                                    if(from == Themes.sharedInstance.Getuser_id())
                                    {
                                        
                                        let Doc_id:String = Themes.sharedInstance.CheckNullvalue(Passed_value: messageObj.value(forKey: "doc_id"));
                                        let data = messageObj.value(forKey: "viewed_by") as? Data
                                        var viewedArray =   NSKeyedUnarchiver.unarchiveObject(with: data ?? Data()) as? NSMutableArray
                                        
                                        if(viewedArray != nil)
                                        {
                                            var isContains = false
                                            (viewedArray as! NSMutableArray).forEach({ data in
                                                let dict : NSDictionary = data as! NSDictionary
                                                if(dict.value(forKey: "to") as! String == to)
                                                {
                                                    isContains = true
                                                }
                                            })
                                            if(!isContains)
                                            {
                                                (viewedArray as! NSMutableArray).add(ComposedDict)
                                                let vieweddataUpdate : NSData = NSKeyedArchiver.archivedData(withRootObject: viewedArray!) as NSData
                                                let param = ["viewed_by" : vieweddataUpdate]
                                                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Status_one_one, FetchString: Doc_id, attribute: "doc_id", UpdationElements: param as NSDictionary)
                                            }
                                        }
                                        else
                                        {
                                            viewedArray = NSMutableArray()
                                            (viewedArray as! NSMutableArray).add(ComposedDict)
                                            let vieweddataUpdate : NSData = NSKeyedArchiver.archivedData(withRootObject: viewedArray!) as NSData
                                            let param = ["viewed_by" : vieweddataUpdate]
                                            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Status_one_one, FetchString: Doc_id, attribute: "doc_id", UpdationElements: param as NSDictionary)
                                        }
                                    }
                                }
                                
                                let Check_Fav:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "id", FetchString: to)
                                if(!Check_Fav)
                                {
                                    if(to != Themes.sharedInstance.Getuser_id())
                                    {
                                        let param_userDetails:[String:Any]=["userId":to]
                                        self.EmituserDetails(Param: param_userDetails)
                                    }
                                }
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.updateViewCount), object:nil , userInfo: nil)
                            }
                        }
                    }
                    
                }
                
            }
            
        }
        
        socket.on(Constant.sharedinstance.sc_message as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            
            let ResponseDict : NSDictionary = data;
            if(ResponseDict.count > 0)
            {
                let ErrorStr:String=Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
                if(ErrorStr != "1")
                {
                    self.StoreIncomingMessage(ResponseDict: ResponseDict,isFromoffline:false)
                }
            }
            else
            {
                
            }
        }
        
        socket.on(Constant.sharedinstance.sc_media_status as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            let ResponseDict : NSDictionary = data;
            if(ResponseDict.count > 0)
            {
                let ErrorStr:String=Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
                if(ErrorStr != "1")
                {
                    self.StoreIncomingStatusMessage(ResponseDict: ResponseDict,isFromoffline:false)
                }
            }
            else
            {
                
            }
        }
        socket.on(Constant.sharedinstance.appgetGroupList as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            let ErrorStr:String=Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            if(ErrorStr == "0")
            {
                let ResponseDict:NSDictionary=data;
                if(ResponseDict.count > 0)
                {
                    let GroupDetails:NSArray = ResponseDict.object(forKey: "GroupDetails") as! NSArray
                    let GroupidArr:NSMutableArray=NSMutableArray()
                    if(GroupDetails.count > 0)
                    {
                        let CheckGroupList = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Group_details, attribute: nil, FetchString: nil)
                        
                        for i in 0..<GroupDetails.count
                        {
                            let Dict:NSDictionary=GroupDetails[i] as! NSDictionary
                            GroupidArr.add(Themes.sharedInstance.CheckNullvalue(Passed_value: Dict.object(forKey: "groupId")))
                            self.CreateGroup(GroupIDStr: Themes.sharedInstance.CheckNullvalue(Passed_value: Dict.object(forKey: "groupId")))
                            if(!CheckGroupList)
                            {
                                self.EmitgroupDetails(GroupIDStr: GroupidArr[i] as! String)
                            }
                        }
                    }
                }
            }
        }
        
        socket.on(Constant.sharedinstance.getGroupDetails as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            let ErrorStr:String=Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"));
            if(ErrorStr == "0")
            {
                let ResponseDict:NSDictionary=data;
                if(ResponseDict.count > 0)
                {
                    self.SaveGroupDetails(ResponseDict: ResponseDict)
                }
            }
            else
            {
            }
        }
        socket.on(Constant.sharedinstance.sc_changeName as String) {data, ack in
            
            let data = self.returnDataFromEncryption(data)
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.RemoveActivity), object: nil)
            let ResponseDict : NSDictionary = data
            
            if(ResponseDict.count > 0)
            {
                let errVal = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "err"))
                
                if errVal == "0"{
                    let user_ID = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from"))
                    if(user_ID == Themes.sharedInstance.Getuser_id())
                    {
                        let name = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "name"))
                        let isShowNumber = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "showNumber"))
                        let CheckUser:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.User_detail, attribute: "user_id", FetchString:user_ID as String?)
                        if (CheckUser){
                            let UpdateDic:[String:Any]=["name": name,"showNumber": isShowNumber]
                            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail , FetchString:user_ID, attribute:"user_id", UpdationElements: UpdateDic as NSDictionary?)
                        }
                        if(self.Delegate?.statusUpdated?(_Updated: "CHECK") != nil)
                        {
                            self.Delegate?.statusUpdated!(_Updated: "Updated Name")
                        }
                    }
                }
                else{
                    if(self.Delegate?.statusUpdated?(_Updated: "CHECK") != nil)
                    {
                        self.Delegate?.statusUpdated!(_Updated: "Not Updated")
                    }
                }
            }
            else
            {
                
            }
        }
        
        
        socket.on(Constant.sharedinstance.GetMobileSettings as String) {data, ack in
            
            let data = self.returnDataFromEncryption(data)
            
            let ResponseDict : NSDictionary = data
            if(ResponseDict.count > 0)
            {
                let send = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "send"))
                if(send == "0")
                {
                    self.send_mobilsettingMsg(ResponseDict: ResponseDict as Dictionary)
                }
            }
        }
        socket.on(Constant.sharedinstance.sc_changeStatus as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            let ResponseDict : NSDictionary = data
            if(ResponseDict.count > 0)
            {
                
                let errVal = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "err"))
                
                if errVal == "0"{
                    
                    let user_ID = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from"))
                    if(user_ID == Themes.sharedInstance.Getuser_id())
                    {
                        var status = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "status"))
                        status = Themes.sharedInstance.base64ToString(status)
                        let CheckUser:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.User_detail, attribute: "user_id", FetchString:user_ID as String?)
                        if (CheckUser){
                            let UpdateDic:[String:Any]=["status": status]
                            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail , FetchString:user_ID, attribute:"user_id", UpdationElements: UpdateDic as NSDictionary?)
                        }
                        
                        let checkStatus = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.status_List, attribute: "status_title", FetchString: status)
                        if(!checkStatus) {
                            let count = DatabaseHandler.sharedInstance.fetchTableAllData(Entityname: Constant.sharedinstance.status_List).count
                            let Dict:NSMutableDictionary=["status_id":"\(count - 1)","status_title":status]
                            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict, Entityname:Constant.sharedinstance.status_List)
                        }
                        if(self.Delegate?.statusUpdated?(_Updated: "CHECK") != nil)
                        {
                            self.Delegate?.statusUpdated!(_Updated: "Updated")
                        }
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: nil , userInfo: nil)
                    }
                    else
                    {
                        let checkBool:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname:Constant.sharedinstance.Favourite_Contact , attribute: "id", FetchString: user_ID)
                        if(checkBool)
                        {
                            var status = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "status"))
                            status = Themes.sharedInstance.base64ToString(status)
                            let param=["status":status]
                            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Favourite_Contact, FetchString: user_ID, attribute: "id", UpdationElements: param as NSDictionary?)
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: nil , userInfo: nil)
                        }
                    }
                    
                }
                else{
                    if(self.Delegate?.statusUpdated?(_Updated: "CHECK") != nil)
                    {
                        self.Delegate?.statusUpdated!(_Updated: "Not Updated")
                    }
                }
            }
            else
            {
                
            }
            
            
        }
        
        socket.on(Constant.sharedinstance.sc_clear_user_db as String) {data, ack in
            
            let data = self.returnDataFromEncryption(data)
            
            let ErrorStr:String = Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"))
            if(ErrorStr == "1")
            {
            }
            else
            {
                let ResponseDict : NSDictionary = data
                let id = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "_id"))
                if(id == Themes.sharedInstance.Getuser_id())
                {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.user_cleared), object:nil)
                }
            }
        }
        
        socket.on(Constant.sharedinstance.sc_clear_single_user_chat as String) {data, ack in
            
            let data = self.returnDataFromEncryption(data)
            
            let ErrorStr:String = Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"))
            if(ErrorStr == "1")
            {
            }
            else
            {
                let ResponseDict : NSDictionary = data
                let id = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "_id"))
                if(id == Themes.sharedInstance.Getuser_id())
                {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.user_cleared), object:nil)
                }
            }
        }
        socket.on(Constant.sharedinstance.sc_file_upload_notify as String) {data, ack in
            
            let data = self.returnDataFromEncryption(data)
            
            let ErrorStr:String = Themes.sharedInstance.CheckNullvalue(Passed_value: data.object(forKey: "err"))
            if(ErrorStr == "1")
            {
            }
            else
            {
                let ResponseDict : NSDictionary = data
                let id = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "from"))
                if(id == Themes.sharedInstance.Getuser_id())
                {
                    UploadHandler.Sharedinstance.handleUpload()
                }
            }
        }
        
        self.socket.on(Constant.sharedinstance.sc_webrtc_turn_message as String) {data, ack in
            
            let data = self.returnDataFromEncryption(data)
            
            let ErrorStr:String = Themes.sharedInstance.CheckNullvalue(Passed_value: (data).object(forKey: "err"))
            if(ErrorStr == "1")
            {
            }
            else
            {
                let ResponseDict:NSDictionary = data
                let to = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "to"))
                if to == Themes.sharedInstance.Getuser_id() {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.receivedTurnMessage), object: nil , userInfo: ResponseDict as! [String : Any])
                }
            }
        }
        
        self.socket.on(Constant.sharedinstance.sc_call_reconnect_hold as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            let ErrorStr:String = Themes.sharedInstance.CheckNullvalue(Passed_value: (data).object(forKey: "err"))
            if(ErrorStr == "1") {
                
            } else {
                let responseDict: NSDictionary = data
                print("responseDict =>\(responseDict)")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.reconnect), object: nil, userInfo: nil)
            }
        }
        
        self.socket.on(Constant.sharedinstance.sc_call_reconnect_intimate as String) {data, ack in
            let data = self.returnDataFromEncryption(data)
            let ErrorStr:String = Themes.sharedInstance.CheckNullvalue(Passed_value: (data).object(forKey: "err"))
            if(ErrorStr == "1") {
                
            } else {
                let responseDict: NSDictionary = data
                print("responseDict =>\(responseDict)")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.reconnectIntimate), object: nil, userInfo: nil)
            }
        }

    }
    
    func GroupResponse(_ ResponseDict : NSDictionary, _ offline : Bool)
    {
        let ErrorStr:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "err"));
        if(ErrorStr == "1")
        {
            
        }
        else
        {
            if(ResponseDict.count > 0)
            {
                let grouptype:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "groupType"))
                let groupId:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "groupId"))
                
                if(grouptype == "1")
                {
                    CreateGroupAck(ResponseDict: ResponseDict)
                }
                else if(grouptype == "4")
                {
                    do_remove_member(ResponseDict: ResponseDict, offline)
                }
                else if(grouptype == "5")
                {
                    do_add_member(ResponseDict: ResponseDict)
                }
                else if(grouptype == "7")
                {
                    do_make_an_admin(ResponseDict: ResponseDict)
                }
                else if(grouptype == "23")
                {
                    do_change_securitycode(ResponseDict: ResponseDict)
                }
                else if(grouptype == "8")
                {
                    do_exit_group(ResponseDict: ResponseDict)
                }
                else if(grouptype == "10")
                {
                    if(groupLeft(id: groupId) == false){
                        JoinGroup(ResponseDict: ResponseDict)
                    }
                }
                else  if(grouptype == "12")
                {
                    ReceiveGroupAck(ResponseDict: ResponseDict)
                }
                else if(grouptype == "9")
                {
                    let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from"))
                    let type:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "type"))
                    
                    if(type == "0" || type == "14" || type == "20" || type == "3" || type == "2" || type == "1" || type == "5" || type == "4")
                    {
                        if(from == Themes.sharedInstance.CheckNullvalue(Passed_value:Themes.sharedInstance.Getuser_id()))
                        {
                            LoadGroupResponses(ResponseDict: ResponseDict)
                        }
                        else
                        {
                            StoreIncomingGroupMessage(ResponseDict: ResponseDict, isFromoffline: offline)
                        }
                    }
                    else if(type == "6")
                    {
                        CreateGroupAck(ResponseDict: ResponseDict)
                    }
                    else if(type == "7")
                    {
                        do_add_member(ResponseDict: ResponseDict)
                    }
                    else if(type == "8")
                    {
                        ChangeprofilePic(ResponseDict: ResponseDict)
                    }
                    else if(type == "9")
                    {
                        do_remove_member(ResponseDict: ResponseDict, offline)
                    }
                    else if(type == "10") {
                        if(checkGroupMember(id: groupId)){
                            groupChangeName(ResponseDict: ResponseDict)
                        }
                    }
                    else if(type == "11")
                    {
                        do_make_an_admin(ResponseDict: ResponseDict)
                    }
                    else if(type == "12")
                    {
                        do_exit_group(ResponseDict: ResponseDict)
                    }
                    else if(type == "23")
                    {
                        do_change_securitycode(ResponseDict: ResponseDict)
                    }
                }
                else  if(grouptype == "2")
                {
                    ChangeprofilePic(ResponseDict: ResponseDict)
                }
                else if(grouptype == "6")
                {
                    if(checkGroupMember(id: groupId)){
                        groupChangeName(ResponseDict: ResponseDict)
                    }
                }
                else if(grouptype == "19")
                {
                    
                    let from:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from"))
                    let recordId:String!=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "recordId"))
                    
                    let chat_type:String! = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_one_one, attrib_name: "recordId", fetchString: recordId, returnStr: "type")
                    let thumbnail:String! = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_one_one, attrib_name: "recordId", fetchString: recordId, returnStr: "thumbnail")
                    
                    let convId:String! = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_one_one, attrib_name: "recordId", fetchString: recordId, returnStr: "convId")
                    
                    let msgId:String! = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_one_one, attrib_name: "recordId", fetchString: recordId, returnStr: "msgId")
                    
                    
                    if (AppDelegate.sharedInstance.navigationController?.topViewController is InitiateChatViewController || AppDelegate.sharedInstance.isVideoViewPresented){
                        // viewController is visible
                        if(chat_type != nil && chat_type != "")
                        {
                            if(chat_type == "0" || chat_type == "4" || chat_type == "5" || chat_type == "14" || chat_type == "11")
                            {
                                let p1 = NSPredicate(format: "recordId = %@", recordId)
                                var param = NSDictionary()
                                if(from == Themes.sharedInstance.Getuser_id())
                                {
                                    param = ["is_deleted" : "1", "type" : "0", "payload" : "🚫 You deleted this message."] as NSDictionary
                                    
                                }
                                else
                                {
                                    param = ["is_deleted" : "1", "type" : "0", "payload" : "🚫 This message was deleted."] as NSDictionary
                                }
                                
                                DatabaseHandler.sharedInstance.UpdateDataWithPredicate(Entityname: Constant.sharedinstance.Chat_one_one, predicate: p1, UpdationElements: param)
                                
                            }
                            else
                            {
                                let p1 = NSPredicate(format: "recordId = %@", recordId)
                                
                                var param = NSDictionary()
                                if(from == Themes.sharedInstance.Getuser_id())
                                {
                                    param = ["is_deleted" : "1", "type" : "0", "payload" : "🚫 You deleted this message."] as NSDictionary
                                    
                                }
                                else
                                {
                                    param = ["is_deleted" : "1", "type" : "0", "payload" : "🚫 This message was deleted."] as NSDictionary
                                }
                                
                                DatabaseHandler.sharedInstance.UpdateDataWithPredicate(Entityname: Constant.sharedinstance.Chat_one_one, predicate: p1, UpdationElements: param)
                                
                                
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
                        if(from != Themes.sharedInstance.Getuser_id())
                        {
                            let param_ack=["groupType": 21, "from": Themes.sharedInstance.Getuser_id(), "groupId": convId, "status":2, "msgId":(msgId as NSString).longLongValue] as [String : Any]
                            SocketIOManager.sharedInstance.GroupmessageAcknowledgement(Param: param_ack)
                        }
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.updateCell), object: ResponseDict , userInfo: nil)
                    }
                    
                }
                else if(grouptype == "20")
                {
                }
            }
        }
    }
    
    func LogOut()
    {
        AppDelegate.sharedInstance.Logout()
    }
    
    @objc func GroupInfoUpdate(_ dic : NSDictionary)
    {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: dic)
        
    }
    @objc func make_An_admin_update()
    {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: nil)
    }
    @objc func added_GroupInfoUpdate(_ dic : NSDictionary)
    {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.updateGroupInfo_add), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: dic)
    }
    
    func EmitCallStatus(ResponseDict:NSDictionary)
    {
        emitEvent(Constant.sharedinstance.sc_call_status, ResponseDict)
    }
    
    func CreateGroupAck(ResponseDict:NSDictionary)
    {
        let groupId:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "groupId"))
        let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
        let to:String=groupId
        
        let createdBy:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "createdBy"))
        if(createdBy == Themes.sharedInstance.Getuser_id())
        {
            let timestamp = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id"))
            
            let id:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "msgId"))
            let Name:String=Themes.sharedInstance.setNameTxt(Themes.sharedInstance.Getuser_id(), "")
            let Phonenumber:String=Themes.sharedInstance.setPhoneTxt(Themes.sharedInstance.Getuser_id())
            let toDocId:String="\(from)-\(to)-\(timestamp)"
            let Msg:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "message"))
            
            let checkbool:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "id", FetchString: id)
            
            let CheckOtherMessageDetail:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Other_Group_message, attribute: "id", FetchString: id)
            if(!CheckOtherMessageDetail)
            {
                
                let Group_messagePram=["admin_id":"","admin_msisid":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "msisdn")),"from":createdBy,"group_id":groupId,"group_type":"1","id":id,"left_id":"","left_msisid":"","new_pic":"","old_pic":"","pic_changed_msisid":"","person_id":"","person_msisid":""]
                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Group_messagePram as NSDictionary, Entityname: Constant.sharedinstance.Other_Group_message)
                Themes.sharedInstance.makeGroupActionNotification(id: id)
            }
            if(!checkbool)
            {
                let dic:[AnyHashable: Any] = ["type": "0","convId":groupId,"doc_id":Themes.sharedInstance.CheckNullvalue(Passed_value:toDocId
                    ),"filesize":"","from":Themes.sharedInstance.CheckNullvalue(Passed_value:from
                    ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:to
                    ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
                    ),"message_status":Themes.sharedInstance.CheckNullvalue(Passed_value:"3"
                    ),"id":"\(id)","name":Themes.sharedInstance.CheckNullvalue(Passed_value:Name
                    ),"payload":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(Msg)"
                    ),"recordId":"","timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
                    ),"thumbnail":"","width":"0.0","height":"0.0","msgId":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
                    ),"contactmsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value:Phonenumber
                    ),"user_common_id":Themes.sharedInstance.CheckNullvalue(Passed_value:from + "-" + to
                    ),"message_from":"1","chat_type":"group","info_type":"2","created_by":"\(createdBy)","is_reply":"0", "date" : Themes.sharedInstance.getTimeStamp()]
                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: dic as NSDictionary,Entityname: Constant.sharedinstance.Chat_one_one)
            }
            else
            {
                let dic:[AnyHashable: Any] = ["payload": Themes.sharedInstance.CheckNullvalue(Passed_value:"\(Msg)")]
                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_one_one, FetchString: id, attribute: "id", UpdationElements: dic as NSDictionary?)
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:Constant.sharedinstance.reloadData), object: nil)
            self.EmitgroupDetails(GroupIDStr: to)
            if(self.Delegate?.callBackImageUploaded?(UploadedStr: "CHECK") != nil)
            {
                self.Delegate?.callBackImageUploaded!(UploadedStr: "group")
            }
        }
    }
    func emitTypingStatus(from:String,to:String,convId:String,type:String)
    {
        let param:[String:Any] = ["from":from,"to":to,"convId":convId,"type":type]
        emitEvent(Constant.sharedinstance.sc_typing, param)
    }
    
    func ReceiveGroupAck(ResponseDict:NSDictionary)
    {
        let from = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from"))
        let msgId = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "msgId"))
        let id = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "msgId"))
        let status = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "status"))
        let groupId = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "groupId"))

        let message = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Group_message_ack, attribute: "msgId", FetchString: msgId, SortDescriptor: nil) as! [Group_message_ack]
        if(message.count > 0)
        {
            _ = message.map {
                var readArr = $0.read_arr is Data ? NSKeyedUnarchiver.unarchiveObject(with: $0.read_arr as! Data) as! [String] :  $0.read_arr as! [String]
                var deliverArr = $0.deliver_arr is Data ? NSKeyedUnarchiver.unarchiveObject(with: $0.deliver_arr as! Data) as! [String] :  $0.deliver_arr as! [String]
                if(status == "2" && readArr.contains(from)) {
                    var index = (readArr as NSArray).index(of: from)
                    readArr.remove(at: index)
                    
                    if(deliverArr.contains(from)) {
                        index = (deliverArr as NSArray).index(of: from)
                        deliverArr.remove(at: index)
                    }
                    
                    let read = NSKeyedArchiver.archivedData(withRootObject: readArr)
                    let deliver = NSKeyedArchiver.archivedData(withRootObject: deliverArr)
                    let param = ["read_arr" : read, "deliver_arr" : deliver, "msgId" : msgId] as [String : Any]

                    let checkMessage = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Group_message_ack, attribute: "msgId", FetchString: msgId)
                    if(checkMessage) {
                        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Group_message_ack, FetchString: msgId, attribute: "msgId", UpdationElements: param as NSDictionary)
                    }
                    
                    if deliverArr.count == 0 {
                        let dic = ["message_status" : "2"]
                        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_one_one, FetchString: msgId, attribute: "msgId", UpdationElements: dic as NSDictionary)
                       
                        let msg_dic = ["message_status":"2","groupId":groupId,"message_id":id]
                        let chat_type_dict:[String: String] = ["chat_type": "groupmessagestatus"]
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.outgoingmessage), object: msg_dic , userInfo: chat_type_dict)

                    }
                    if readArr.count == 0 {
                        let dic = ["message_status" : "3"]
                        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_one_one, FetchString: msgId, attribute: "msgId", UpdationElements: dic as NSDictionary)
                       
                        let msg_dic = ["message_status":"3","groupId":groupId,"message_id":id]
                        let chat_type_dict:[String: String] = ["chat_type": "groupmessagestatus"]
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.outgoingmessage), object: msg_dic , userInfo: chat_type_dict)
                    }
                }
                else if(status == "1" && deliverArr.contains(from)) {
                    let index = (deliverArr as NSArray).index(of: from)
                    deliverArr.remove(at: index)
                    
                    let deliver = NSKeyedArchiver.archivedData(withRootObject: deliverArr)
                    let param = ["deliver_arr" : deliver, "msgId" : msgId] as [String : Any]
                    let checkMessage = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Group_message_ack, attribute: "msgId", FetchString: msgId)
                    if(checkMessage) {
                        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Group_message_ack, FetchString: msgId, attribute: "msgId", UpdationElements: param as NSDictionary)
                    }
                    
                    guard deliverArr.count == 0 else { return }
                    let dic = ["message_status" : "2"]
                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_one_one, FetchString: msgId, attribute: "msgId", UpdationElements: dic as NSDictionary)
                    
                    let msg_dic = ["message_status":"2","groupId":groupId,"message_id":id]
                    let chat_type_dict:[String: String] = ["chat_type": "groupmessagestatus"]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.outgoingmessage), object: msg_dic , userInfo: chat_type_dict)
                }
            }
        }
    }
    func ExecuteReadUnreadChat(user_common_id:String,status:String)
    {
        let CheckinitiatedDetails:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: user_common_id)
        if(CheckinitiatedDetails)
        {
            let UpdateDict:NSDictionary =  ["is_read":"\(status)"]
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: user_common_id, attribute: "user_common_id", UpdationElements: UpdateDict)
        }
        
    }
    func ExecuteArchiveChat(user_common_id:String,status:String)
    {
        
        let CheckinitiatedDetails:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: user_common_id)
        if(CheckinitiatedDetails)
        {
            let UpdateDict:NSDictionary =  ["is_archived":"\(status)"]
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: user_common_id, attribute: "user_common_id", UpdationElements: UpdateDict)
        }
        
    }
    
    func send_mobilsettingMsg(ResponseDict:Dictionary<AnyHashable, Any>)
    {
        var ResponseDict:Dictionary<AnyHashable, Any> = ResponseDict
        let send = 1
        ResponseDict["send"] = send
        let current_call_status = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.User_detail, attrib_name: "user_id", fetchString: Themes.sharedInstance.Getuser_id(), returnStr: "current_call_status")
        ResponseDict["call_connect"] = current_call_status
        self.EmitMobileSetting(Param: ResponseDict as! [String : Any])
        
    }
    
    func ChangeprofilePic(ResponseDict:NSDictionary)
    {
        
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.RemoveActivity), object: nil)
        let errVal = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "err"))
        
        if errVal == "0"{
            let getGroupID = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "groupId"))
            let groupId:String=Themes.sharedInstance.CheckNullvalue(Passed_value: getGroupID)
            
            let id = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id"))
            _ = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "groupType"))
            
            let createdBy = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from"))
            let timestamp = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id"))
            
            let Msg = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "message"))
            _ = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "type"))
            let toDocId = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "toDocId"))
            var avatar = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "avatar"))
            let param_ack=["groupType": 12, "from": Themes.sharedInstance.Getuser_id(), "groupId": getGroupID, "status":2, "msgId": Int(id)!] as [String : Any]
            self.GroupmessageAcknowledgement(Param: param_ack)
            
            
            var msidn:String = ""
            if(createdBy != Themes.sharedInstance.Getuser_id())
            {
                if let msisdn = Msg.slice(from: "@", to: "*") {
                    msidn = msisdn
                }
                else
                {
                    msidn = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "msisdn"))
                }
            }
            else
            {
                msidn = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "msisdn"))
            }
            // let id:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id"))
            let to:String=groupId
            self.CreateGroup(GroupIDStr: groupId);
            self.EmitgroupDetails(GroupIDStr: to)
            let checkbool:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "id", FetchString: id)
            let CheckOtherMessageDetail:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Other_Group_message, attribute: "id", FetchString: id)
            if(!CheckOtherMessageDetail)
            {
                let Group_messagePram=["admin_id":"","admin_msisid":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "msisdn")),"from":createdBy,"group_id":groupId,"group_type":"2","id":id,"left_id":"","left_msisid":"","new_pic":avatar,"old_pic":"","pic_changed_msisid":"\(msidn)","person_id":"","person_msisid":""]
                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Group_messagePram as NSDictionary, Entityname: Constant.sharedinstance.Other_Group_message)
                Themes.sharedInstance.makeGroupActionNotification(id: id)
            }
            var dic:[AnyHashable: Any] = [:]
            if(!checkbool)
            {
                //
                dic = ["groupId":to,"type": "0","convId":groupId,"doc_id":toDocId
                    ,"filesize":"","from":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(createdBy)"
                    ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:to
                    ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
                    ),"message_status":Themes.sharedInstance.CheckNullvalue(Passed_value:"3"
                    ),"id":"\(id)","name":"","payload":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(Msg)"
                    ),"recordId":"","timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
                    ),"thumbnail":"","width":"0.0","height":"0.0","msgId":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(id)"
                    ),"contactmsisdn":""
                    ,"user_common_id":"\(Themes.sharedInstance.Getuser_id())-\(to)"
                    ,"message_from":"1","chat_type":"group","info_type":"1","created_by":"\(createdBy)","is_reply":"0", "date" : Themes.sharedInstance.getTimeStamp()]
                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: dic as NSDictionary,Entityname: Constant.sharedinstance.Chat_one_one)
            }
            else{
                let dic:[AnyHashable: Any] = ["payload": Themes.sharedInstance.CheckNullvalue(Passed_value:"\(Msg)")]
                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_one_one, FetchString: id, attribute: "id", UpdationElements: dic as NSDictionary?)
            }
            
            if(avatar != "")
            {
                if(avatar.substring(to: 1) == ".")
                {
                    avatar.remove(at: avatar.startIndex)
                }
            }
            
            let imageURL="\(ImgUrl)\(avatar)"
            
            let Dict:[String:Any]=["displayavatar":imageURL]
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Group_details, FetchString: getGroupID, attribute: "id", UpdationElements: Dict as NSDictionary?)
            if(createdBy != Themes.sharedInstance.Getuser_id())
            {
                let from_user = Themes.sharedInstance.setNameTxt(createdBy, "single")
                
                dic = ["groupId":to,"type": "0","convId":groupId,"doc_id":toDocId
                    ,"filesize":"","from":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(createdBy)"
                    ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:to
                    ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
                    ),"message_status":Themes.sharedInstance.CheckNullvalue(Passed_value:"3"
                    ),"id":"\(id)","name":"","payload":"\(from_user) changed the group icon","recordId":"","timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
                    ),"thumbnail":"","width":"0.0","height":"0.0","msgId":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(id)"
                    ),"contactmsisdn":""
                    ,"user_common_id":"\(Themes.sharedInstance.Getuser_id())-\(to)"
                    ,"message_from":"1","chat_type":"group","info_type":"1","created_by":"\(createdBy)","is_reply":"0"]
                let chat_type_dict:[String: String] = ["chat_type": "group"]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.Incomingmessage), object: dic , userInfo: chat_type_dict)
            }
        }
        
    }
    
    func EmitSkipMessages(Param:[String:Any])
    {
        emitEvent(Constant.sharedinstance.sc_skipbackup_messages, Param)
    }
    
    func EmituserDetails(Param:[String:Any])
    {
        emitEvent(Constant.sharedinstance.sc_get_user_Details, Param)
    }
    
    func groupChangeName(ResponseDict:NSDictionary){
        
        let errVal = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "err"))
        
        if errVal == "0"{
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.RemoveActivity), object: nil)
            if(self.Delegate?.statusUpdated?(_Updated: "CHECK") != nil)
            {
                self.Delegate?.statusUpdated!(_Updated: "Updated")
            }
            
            let getGroupID = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "groupId"))
            let groupId:String=Themes.sharedInstance.CheckNullvalue(Passed_value: getGroupID)
            let id = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id"))
            _ = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "groupType"))
            let createdBy = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from"))
            
            let timestamp = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id"))
            
            let Msg = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "message"))
            let param_ack=["groupType": 12, "from": Themes.sharedInstance.Getuser_id(), "groupId": getGroupID, "status":2, "msgId": (id as NSString).longLongValue] as [String : Any]
            
            self.GroupmessageAcknowledgement(Param: param_ack)
            var Createdmsidn:String = ""
            
            if(Themes.sharedInstance.Getuser_id() != createdBy)
            {
                if let msisdn = Msg.slice(from: "@", to: "*") {
                    Createdmsidn = msisdn
                }
                else
                {
                    Createdmsidn = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "msisdn"))
                }
            }
            else
            {
                Createdmsidn = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "msisdn"))
            }
            // let id:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id"))
            let to:String=groupId
            
            self.CreateGroup(GroupIDStr: groupId);
            self.EmitgroupDetails(GroupIDStr: to)
            
            let checkbool:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "id", FetchString: id)
            //
            let CheckOtherMessageDetail:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Other_Group_message, attribute: "id", FetchString: id)
            //
            if(!CheckOtherMessageDetail)
            {
                
                let Group_messagePram=["admin_id":"","admin_msisid":Createdmsidn,"from":createdBy,"group_id":groupId,"group_type":"6","id":id,"left_id":"","left_msisid":"","new_pic":"","old_pic":"","pic_changed_msisid":"","person_id":"","person_msisid":""]
                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Group_messagePram as NSDictionary, Entityname: Constant.sharedinstance.Other_Group_message)
                Themes.sharedInstance.makeGroupActionNotification(id: id)
            }
            var dic:[AnyHashable: Any] = [:]
            
            if(!checkbool)
            {
                //
                dic = ["groupId":to,"type": "0","convId":groupId,"doc_id":""
                    ,"filesize":"","from":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(createdBy)"
                    ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:to
                    ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
                    ),"message_status":Themes.sharedInstance.CheckNullvalue(Passed_value:"3"
                    ),"id":"\(id)","name":"","payload":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(Msg)"
                    ),"recordId":"","timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
                    ),"thumbnail":"","width":"0.0","height":"0.0","msgId":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
                    ),"contactmsisdn":""
                    ,"user_common_id":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(Themes.sharedInstance.Getuser_id())-\(to)"
                    ),"message_from":"1","chat_type":"group","info_type":"1","created_by":"\(createdBy)","is_reply":"0", "date" : Themes.sharedInstance.getTimeStamp()]
                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: dic as NSDictionary,Entityname: Constant.sharedinstance.Chat_one_one)
            }
            else{
                
                let dic:[AnyHashable: Any] = ["payload": Themes.sharedInstance.CheckNullvalue(Passed_value:"\(Msg)")]
                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_one_one, FetchString: id, attribute: "id", UpdationElements: dic as NSDictionary?)
            }
            
            if(createdBy != Themes.sharedInstance.Getuser_id())
            {
                let from_user = Themes.sharedInstance.setNameTxt(createdBy, "single")

                dic = ["groupId":to,"type": "0","convId":groupId,"doc_id":""
                    ,"filesize":"","from":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(createdBy)"
                    ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:to
                    ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
                    ),"message_status":Themes.sharedInstance.CheckNullvalue(Passed_value:"3"
                    ),"id":"\(id)","name":"","payload": "\(from_user) changed the subject","recordId":"","timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
                    ),"thumbnail":"","width":"0.0","height":"0.0","msgId":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
                    ),"contactmsisdn":""
                    ,"user_common_id":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(Themes.sharedInstance.Getuser_id())-\(to)"
                    ),"message_from":"1","chat_type":"group","info_type":"1","created_by":"\(createdBy)","is_reply":"0"]
                let chat_type_dict:[String: String] = ["chat_type": "group"]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.Incomingmessage), object: dic , userInfo: chat_type_dict)
            }
            
        }
        
    }
    
    func JoinGroup(ResponseDict:NSDictionary)
    {
        let id:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id"))
        if(id.length > 0)
        {
            let groupId:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "groupId"))
            let convId:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "convId"))
            let id:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id"))
            let groupName:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "msgId"))
            
            let timestamp = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id"))
            
            let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
            let to:String=groupId
            let createdBy:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "createdBy"))
            let Name:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "Name"))
            let Phonenumber:String=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "msisdn"))
            let toDocId:String="\(from)-\(to)-\(timestamp)"
            let Msg:String="created the group"
            //Emit event to join group
            let param = ["from":Themes.sharedInstance.Getuser_id(),"groupType":"10","groupName":Themes.sharedInstance.CheckNullvalue(Passed_value: groupName),"groupId":groupId,"timeStamp":timestamp,"createdBy":createdBy] as [String : Any];
            let CheckOtherMessageDetail:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Other_Group_message, attribute: "id", FetchString: id)
            if(!CheckOtherMessageDetail)
            {
                let Group_messagePram=["admin_id":"","admin_msisid":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "msisdn")),"from":createdBy,"group_id":groupId,"group_type":"1","id":id,"left_id":"","left_msisid":"","new_pic":"","old_pic":"","pic_changed_msisid":"","person_id":"","person_msisid":""]
                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Group_messagePram as NSDictionary, Entityname: Constant.sharedinstance.Other_Group_message)
                Themes.sharedInstance.makeGroupActionNotification(id: id)
            }
            let getGroupID = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "groupId"))
            if(id != "")
            {
                
                let param_ack=["groupType": 12, "from": Themes.sharedInstance.Getuser_id(), "groupId": getGroupID, "status":2, "msgId": (id as NSString).longLongValue] as [String : Any]
                
                self.GroupmessageAcknowledgement(Param: param_ack)
                self.Groupevent(param: param)
                self.EmitgroupDetails(GroupIDStr: to)
                self.CreateGroup(GroupIDStr: groupId);
                
                //message delivered acknowledgement
                //Save Group Details
                let checkbool:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "id", FetchString: id)
                if(!checkbool)
                    
                {
                    let dic:[AnyHashable: Any] = ["type": "0","convId":convId,"doc_id":Themes.sharedInstance.CheckNullvalue(Passed_value:toDocId
                        ),"filesize":"","from":Themes.sharedInstance.CheckNullvalue(Passed_value:from
                        ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:to
                        ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
                        ),"message_status":Themes.sharedInstance.CheckNullvalue(Passed_value:"3"
                        ),"id":id,"name":Themes.sharedInstance.CheckNullvalue(Passed_value:Name
                        ),"payload":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(Msg)"
                        ),"recordId":"","timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
                        ),"thumbnail":"","width":"0.0","height":"0.0","msgId":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
                        ),"contactmsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value:Phonenumber
                        ),"user_common_id":Themes.sharedInstance.CheckNullvalue(Passed_value:from + "-" + to
                        ),"message_from":"1","chat_type":"group","info_type":"1","created_by":"\(createdBy)","is_reply":"0", "date" : Themes.sharedInstance.getTimeStamp()]
                    DatabaseHandler.sharedInstance.InserttoDatabase(Dict: dic as NSDictionary,Entityname: Constant.sharedinstance.Chat_one_one)
                }
                else
                {
                    let dic:[AnyHashable: Any] = ["payload": Themes.sharedInstance.CheckNullvalue(Passed_value:"\(Msg)")]
                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_one_one, FetchString: id, attribute: "id", UpdationElements: dic as NSDictionary?)
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue:Constant.sharedinstance.reloadData), object: nil)
            }
            
        }
    }
    
    func EmitMobileSetting(Param:[String:Any])
    {
        emitEvent(Constant.sharedinstance.GetMobileSettings, Param)
    }
    
    func emitReconnectCallEvent(Param: [String:Any]) {
        emitEvent(Constant.sharedinstance.sc_call_reconnect_hold, Param)
    }
    
    func emitReconnectIntimateCallEvent(Param: [String:Any]) {
        emitEvent(Constant.sharedinstance.sc_call_reconnect_intimate, Param)
    }
    
    func emitCallDetail(Param:[String:Any])
    {
        guard !AppDelegate.sharedInstance.isVideoViewPresented else{
            AppDelegate.sharedInstance.window?.view.makeToast(message: "Call in progress", duration: 3, position: HRToastActivityPositionDefault)
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.emitEvent(Constant.sharedinstance.sc_call, Param)
        }
    }
    
    func mobileToWebLogout(Param:[String:Any])
    {
        emitEvent(Constant.sharedinstance.mobileToWebLogout, Param)
    }
    
    func emitCallAck(Param:[String:Any])
    {
        emitEvent(Constant.sharedinstance.sc_call_ack, Param)
    }
    
    func EmitQRdata(Param:[String:Any])
    {
        emitEvent(Constant.sharedinstance.qrdata, Param)
    }
    
    func deleteChat(Param:[String:Any])
    {
        emitEvent(Constant.sharedinstance.sc_delete_chat, Param)
    }

    func GroupmessageAcknowledgement(Param:[String:Any])
    {
        emitEvent(Constant.sharedinstance.group, Param)
        AppDelegate.sharedInstance.setBadgeCount()
    }
    
    func SaveGroupDetails(ResponseDict:NSDictionary)
    {
        if(ResponseDict.count > 0)
        {
            let timestamp = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "id"))
            
            var image_Url = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "GroupIcon"))
            if(image_Url != "")
            {
                if(image_Url.substring(to: 1) == ".")
                {
                    image_Url.remove(at: image_Url.startIndex)
                }
                image_Url = ("\(ImgUrl)\(image_Url)")
                
            }
            let groupuser:NSArray = ResponseDict.value(forKey: "GroupUsers") as! NSArray
            let userdata:NSData=NSKeyedArchiver.archivedData(withRootObject: groupuser) as NSData
            let id:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "_id"))

            if(groupuser.count > 0)
            {
                for i in 0..<groupuser.count
                {
                    let dict:NSDictionary = groupuser[i] as! NSDictionary
                         let DBdict:[String:String] = ["convId":"\(id)","security_code":Themes.sharedInstance.CheckNullvalue(Passed_value: dict.object(forKey: "security_code")),"user_id":Themes.sharedInstance.Getuser_id(),"opp_id":Themes.sharedInstance.CheckNullvalue(Passed_value: dict.object(forKey: "id"))]
                        let checkbook:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Conv_detail, attribute: "opp_id", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: dict.object(forKey: "id")))
                        if(!checkbook)
                        {
                            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: DBdict as NSDictionary, Entityname: Constant.sharedinstance.Conv_detail)
                        }
                        else
                        {
                            let checksecurityCode:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Conv_detail, attribute: "security_code", FetchString:Themes.sharedInstance.CheckNullvalue(Passed_value: dict.object(forKey: "security_code")))
                            
                            if(!checksecurityCode)
                            {

                            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Conv_detail, FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: dict.object(forKey: "id")), attribute:"opp_id" , UpdationElements: DBdict as NSDictionary)
                            }
                        }
                    let param = ["security_code":Themes.sharedInstance.CheckNullvalue(Passed_value: dict.object(forKey: "security_code"))]
                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Favourite_Contact, FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: dict.object(forKey: "id")), attribute: "id", UpdationElements: param as NSDictionary)
                }
            }
 
            

            let from:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "from"))
            let user_common_id:String="\(Themes.sharedInstance.Getuser_id())-\(id)"
            let displayname:String = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "DisplayName"))
            let param:NSDictionary=["alias":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "alias")),"displayavatar":image_Url,"displayName":displayname.encoded,"from":from,"groupUsers":userdata,"id":id,"is_archived":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "is_archived")),"is_deleted":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "is_deleted")),"is_marked":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "is_marked")),"is_muted":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "is_muted")),"isAdmin":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "isAdmin")),"msg":"","user_common_id":user_common_id,"timestamp":timestamp,"group_created_time":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "GroupcreatedAt")),"createdByMsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "createdByMsisdn")),"createdBy":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "createdBy"))]
            
            let Check_Fav:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "id", FetchString: from)
            if(!Check_Fav)
            {
                if(from != Themes.sharedInstance.Getuser_id())
                {
                    let param_userDetails:[String:Any]=["userId":from]
                    self.EmituserDetails(Param: param_userDetails)
                }
            }
            let CheckGroup:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Group_details, attribute: "id", FetchString: id)
            
            let CheckUser:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: user_common_id)
            if(!CheckUser)
            {
                var Chattype:String=""
                Chattype="group"
                let User_dict:[AnyHashable: Any] = ["user_common_id": user_common_id,"user_to_dp":"0" ,"user_id":Themes.sharedInstance.Getuser_id(),"chat_type":Chattype,"is_archived":"0","conv_id":Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "_id")),"timestamp":timestamp,"opponent_id":"\(id)","chat_count":"0","is_read":"0","isSavetocamera": "0"]
                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: User_dict as NSDictionary,Entityname: Constant.sharedinstance.Chat_intiated_details)
            }
            else
                
            {
                let User_dict:[AnyHashable: Any]=["timestamp":timestamp,"is_read":"0"]
                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: user_common_id , attribute: "user_common_id", UpdationElements: User_dict as NSDictionary?)
            }
            
            if(CheckGroup)
            {
                let predic2 = NSPredicate(format: "id == %@",id)
                
                DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Group_details, Predicatefromat: predic2, Deletestring: id,AttributeName: "id")
                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: param as NSDictionary, Entityname: Constant.sharedinstance.Group_details)
            }
            else
            {
                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: param as NSDictionary, Entityname: Constant.sharedinstance.Group_details)
            }
            if(Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "is_muted")) == "1"){
                
                let type = "group"
                let attribute = (type == "group") ? "groupId" : "id"
                
                let param = [attribute : id, "convId" : id, "type" : type, "option" : "1 Year", "timestamp":String(Date().ticks), "user_id" : Themes.sharedInstance.Getuser_id()]
                
                let mute = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Mute_chats, attribute: attribute, FetchString: id)
                
                if(!mute)
                {
                    DatabaseHandler.sharedInstance.InserttoDatabase(Dict: param as NSDictionary, Entityname: Constant.sharedinstance.Mute_chats)
                }
            }
        }
        if(self.Delegate?.ReloadGroupTable?() != nil)
        {
            self.Delegate?.ReloadGroupTable!()
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.reloadChats), object: nil, userInfo: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: nil)
    }
    func GetGroupDetails(GroupIDArr:NSMutableArray)
    {
        if(GroupIDArr.count > 0)
        {
            for i in 0..<GroupIDArr.count
            {
                self.CreateGroup(GroupIDStr: GroupIDArr[i] as! String)
                
                self.EmitgroupDetails(GroupIDStr: GroupIDArr[i] as! String)
            }
        }
    }
    
    func EmitRemovePhoto(Dict:NSDictionary)
    {
        emitEvent(Constant.sharedinstance.sc_changeProfilePic, Dict)
    }
    
    func EmitAppsetting(Dict:NSDictionary)
    {
        emitEvent(Constant.sharedinstance.sc_app_settings, Dict)
    }
    
    func EmitGetServerTime(Dict:NSDictionary)
    {
        emitEvent(Constant.sharedinstance.sc_get_server_time, Dict)
    }
    
    func EmitConvSetting(Dict:NSDictionary)
    {
        emitEvent(Constant.sharedinstance.sc_to_conv_settings, Dict)
    }
    
    func CreateGroup(GroupIDStr:String)
    {
        let param = ["_id":GroupIDStr];
        emitEvent(Constant.sharedinstance.create_user, param)
    }
    
    func EmitDeletedetails(Dict:NSDictionary)
    {
        emitEvent(Constant.sharedinstance.RemoveMessage, Dict)
    }
    
    func EmitStatusDeletedetails(Dict:NSDictionary)
    {
        emitEvent(Constant.sharedinstance.sc_remove_media_status, Dict)
    }
    
    func EmitDeletedetailsForEveryone(Dict:NSDictionary)
    {
        emitEvent(Constant.sharedinstance.sc_remove_message_everyone, Dict)
    }
    
    func EmitStarMessagedetails(Dict:NSDictionary)
    {
        emitEvent(Constant.sharedinstance.StarMessage, Dict)
    }
    
    func EmitArchivedetails(Dict:NSDictionary)
    {
        emitEvent(Constant.sharedinstance.sc_archived_chat, Dict)
    }
    
    func EmitReportUsers(Dict:NSDictionary)
    {
        emitEvent(Constant.sharedinstance.sc_report_spam_user, Dict)
    }
    
    func EmitBlockUsers(Dict:NSDictionary)
    {
        emitEvent(Constant.sharedinstance.sc_block_user, Dict)
    }
    
    func EmitmarkedDetails(Dict:NSDictionary)
    {
        emitEvent(Constant.sharedinstance.sc_marked_chat, Dict)
    }
    
    func ClearChatDetails(Dict:NSDictionary)
    {
        emitEvent(Constant.sharedinstance.sc_clear_chat, Dict)
    }
    func clearChat(Param:[String:Any])
    {
        emitEvent(Constant.sharedinstance.sc_clear_chat_opponenet, Param)
    }
    func deleteHistory(Param:[String:Any])
    {
        emitEvent(Constant.sharedinstance.sc_delete_chat_opponenet, Param)
    }
    func EmitgroupDetails(GroupIDStr:String)
    {
        let GetgroupParam = ["from":Themes.sharedInstance.Getuser_id(),"convId":GroupIDStr] as [String : Any];
        emitEvent(Constant.sharedinstance.getGroupDetails, GetgroupParam)
    }
    
    func AcknowledegmentHandler(from:NSString, to:NSString,status:NSString,doc_id:NSString,timestamp:NSString,isEmit_status:Bool, is_deleted_message_ack : Bool, chat_type : String, convId: String)
    {
        if(status == "3") {
            guard AppDelegate.sharedInstance.navigationController?.topViewController is InitiateChatViewController else {return}
        }

        var to = to
        var from = from
        
        if(isEmit_status)
        {
            //let timestampArr:NSArray=[Int(timestamp as String)!]
            
            let timestampArr:NSArray=[timestamp.longLongValue]
            if(from as String != Themes.sharedInstance.Getuser_id())
            {
                to=from as NSString
            }
            from=Themes.sharedInstance.Getuser_id() as NSString
            var Dict = [String : Any]()
            if(chat_type == "single")
            {
                Dict = [ "from": from, "to": to, "msgIds": timestampArr, "status": Int(status as String)!,"doc_id":doc_id, "secret_type" : "no", "convId": convId]
            }
            else if(chat_type == "secret")
            {
                Dict = [ "from": from, "to": to, "msgIds": timestampArr, "status": Int(status as String)!,"doc_id":doc_id, "secret_type" : "yes", "convId": convId]
            }
            if(is_deleted_message_ack)
            {
                emitEvent(Constant.sharedinstance.sc_deleted_message_ack, Dict)
            }
            else
            {
                emitEvent(Constant.sharedinstance.sc_message_ack, Dict)
            }
        }
        else
        {
        }
        AppDelegate.sharedInstance.setBadgeCount()
    }
    
    func StatusAcknowledegmentHandler(from:NSString, to:NSString,status:NSString,doc_id:NSString,timestamp:NSString,isEmit_status:Bool, chat_type : String)
    {
        var to = to
        var from = from
        
        if(isEmit_status)
        {
            //let timestampArr:NSArray=[Int(timestamp as String)!]
            
            let timestampArr:NSArray=[timestamp.longLongValue]
            if(from as String != Themes.sharedInstance.Getuser_id())
            {
                to=from as NSString
            }
            from=Themes.sharedInstance.Getuser_id() as NSString
            let Dict = [ "from": from, "to": to, "msgIds": timestampArr, "status": Int(status as String)!,"doc_id":doc_id, "secret_type" : "no"] as [String : Any]
            
            emitEvent(Constant.sharedinstance.sc_media_status_ack, Dict)
        }
        
        AppDelegate.sharedInstance.setBadgeCount()
    }
    
    func SendMessage(from:String,to:String,payload:String,type:String,timestamp:String,DocID:String,thumbnail:String,thumbnail_data:String,filesize:String,height:String,width:String,doc_name:String,numPages:String, duration:String,is_secret_chat:String)
    {
        
        var secrettoken:String = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Favourite_Contact, attrib_name: "id", fetchString: to, returnStr: "security_code")
        
        if (secrettoken.length == 0)
        {
            secrettoken = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Conv_detail, attrib_name: "opp_id", fetchString: to, returnStr: "security_code")
            if(secrettoken.length == 0)
            {
                secrettoken = Themes.sharedInstance.getToken()
            }
        }
        
        if (socket.status == .notConnected)
        {
            
        }
        else
        {
            if(type == "6" || type == "20")
            {
                let param = ["from":from,"to":to,"payload":EncryptionHandler.sharedInstance.encryptmessage(str: payload.decoded,toid:to, chat_type: "single"),"type":type,"id":EncryptionHandler.sharedInstance.encryptmessage(str:"\((timestamp as NSString).longLongValue)",toid:to, chat_type: "single"),"toDocId":EncryptionHandler.sharedInstance.encryptmessage(str:DocID,toid:to, chat_type: "single"),"thumbnail":EncryptionHandler.sharedInstance.encryptmessage(str:"\(thumbnail)",toid:to, chat_type: "single"),"thumbnail_data":"\(thumbnail_data)","filesize":filesize,"width":width,"height":height,"original_filename":EncryptionHandler.sharedInstance.encryptmessage(str: doc_name,toid:to, chat_type: "single"),"numPages": numPages,"is_secret_chat":is_secret_chat] as [String : Any];
                emitEvent(Constant.sharedinstance.sc_message, param)
            }
            else
            {
                let param = ["from":from,"to":to,"payload":EncryptionHandler.sharedInstance.encryptmessage(str: payload.decoded,toid:to, chat_type: "single"),"type":type,"id":EncryptionHandler.sharedInstance.encryptmessage(str:"\((timestamp as NSString).longLongValue)",toid:to, chat_type: "single"),"toDocId":EncryptionHandler.sharedInstance.encryptmessage(str:DocID,toid:to, chat_type: "single"),"thumbnail":EncryptionHandler.sharedInstance.encryptmessage(str:"\(thumbnail)",toid:to, chat_type: "single"),"thumbnail_data":"\(thumbnail_data)","filesize":filesize,"width":width,"height":height,"original_filename":EncryptionHandler.sharedInstance.encryptmessage(str: doc_name,toid:to, chat_type: "single"), "duration" : duration, "audio_type" : "1","is_secret_chat":is_secret_chat,"secrettoken":secrettoken] as [String : Any];
                emitEvent(Constant.sharedinstance.sc_message, param)
            }
        }
    }
    
    func SendForwardMessage(from:String,to:String, msgType:String, id: String, toDocId:String, recordId: String)
    {
        if (socket.status == .notConnected)
        {
            
        }
        else
        {
            let param = ["from":from,"to":to,"msgType":msgType,"id":(id as NSString).longLongValue,"toDocId":toDocId, "recordId" : recordId] as [String : Any];
            emitEvent(Constant.sharedinstance.ForwardMessage, param)
        }
    }
    
    func SendStatusMessage(from:String,to:String,payload:String,type:String,timestamp:String,DocID:String,thumbnail:String,thumbnail_data:String,filesize:String,height:String,width:String,doc_name:String,numPages:String, duration:String, themeColor:String, theme_font:String)
    {
        
        if (socket.status == .notConnected)
        {
            
        }
        else
        {
            let param = ["from":from,"to":to,"payload": payload.decoded,"type":type,"id":(timestamp as NSString).longLongValue,"toDocId":DocID,"thumbnail":"\(thumbnail)","thumbnail_data":"\(thumbnail_data)","filesize":filesize,"width":width,"height":height,"original_filename":doc_name, "duration" : duration, "audio_type" : "1", "theme_color":themeColor, "theme_font": theme_font] as [String : Any];
            
            emitEvent(Constant.sharedinstance.sc_media_status, param)
        }
    }
    
    func secretMessage(from:String,to:String,payload:String,type:String,timestamp:String,DocID:String,thumbnail:String,thumbnail_data:String,filesize:String,height:String,width:String,doc_name:String,numPages:String, duration:String,chat_type:String)
    {
        
        if (socket.status == .notConnected)
        {
            
        }
        else
        {
            if(type == "6" || type == "20")
            {
                let param = ["from":from,"to":to,"payload":EncryptionHandler.sharedInstance.encryptmessage(str: payload.decoded,toid:to, chat_type: "secret"),"type":type,"id":EncryptionHandler.sharedInstance.encryptmessage(str:"\((timestamp as NSString).longLongValue)",toid:to , chat_type: "secret"),"toDocId":EncryptionHandler.sharedInstance.encryptmessage(str:DocID,toid:to,  chat_type: "secret"),"thumbnail":EncryptionHandler.sharedInstance.encryptmessage(str:"\(thumbnail)",toid:to,  chat_type: "secret"),"thumbnail_data":"\(thumbnail_data)","filesize":filesize,"width":width,"height":height,"original_filename":EncryptionHandler.sharedInstance.encryptmessage(str: doc_name,toid:to, chat_type: "secret"),"numPages": numPages,"chat_type":chat_type] as [String : Any];
                emitEvent(Constant.sharedinstance.sc_message, param)
            }
            else
            {
                let param = ["from":from,"to":to,"payload":EncryptionHandler.sharedInstance.encryptmessage(str: payload.decoded,toid:to, chat_type: "secret"),"type":type,"id":EncryptionHandler.sharedInstance.encryptmessage(str:"\((timestamp as NSString).longLongValue)",toid:to, chat_type: "secret"),"toDocId":EncryptionHandler.sharedInstance.encryptmessage(str:DocID,toid:to, chat_type: "secret"),"thumbnail":EncryptionHandler.sharedInstance.encryptmessage(str:"\(thumbnail)",toid:to, chat_type: "secret"),"thumbnail_data":"\(thumbnail_data)","filesize":filesize,"width":width,"height":height,"original_filename":EncryptionHandler.sharedInstance.encryptmessage(str: doc_name,toid:to, chat_type: "secret"),"chat_type":chat_type] as [String : Any];
                emitEvent(Constant.sharedinstance.sc_message, param)
            }
        }
    }
    
    func getSingleMessageInfo(from:String,type:String,recordId:String){
        let param = ["from":from,"type":type,"recordId":recordId] as [String : Any]
        emitEvent(Constant.sharedinstance.getMessageInfo, param)
    }
    
    func EmitReplyMessage(param:NSDictionary)
    {
        emitEvent(Constant.sharedinstance.ReplyMessage, param)
    }
    
    
    func EmitGroupReplyMessage(param:NSDictionary)
    {
        emitEvent(Constant.sharedinstance.group, param)
    }
    
    func SendMessage_group(param:NSDictionary)
    {
        if (socket.status == .notConnected)
        {
        }
        else
        {
            emitEvent(Constant.sharedinstance.group, param)
        }
    }
    
    func EmitMessage(param:[String:Any])
    {
        emitEvent(Constant.sharedinstance.sc_message, param)
    }
    
    func EmitCallRetry(param:[String:Any])
    {
        emitEvent(Constant.sharedinstance.sc_call_retry, param)
    }
    
    func EmitGetCallStatus(param:[String : Any])
    {
        emitEvent(Constant.sharedinstance.sc_get_call_status, param)
    }
    
    func deleteAccount(from:String,msisdn:String,reason:String,messagetext:String)
    {
        let param = ["from":from,"msisdn":msisdn,"reason":reason,"messagetext":messagetext]
        emitEvent(Constant.sharedinstance.sc_delete_account, param)
    }
    
    func Groupevent(param:[String:Any])
    {
        emitEvent(Constant.sharedinstance.group, param)
    }
    
    func online(from:String,status:String){
        let param = ["from":from,"status":status]
        emitEvent(Constant.sharedinstance.sc_change_status, param)
    }
    
    func user_offline_in_call(from:String,status:String){
        let param = ["from":from,"status":status]
        emitEvent(Constant.sharedinstance.sc_user_offline_in_call, param)
    }

    func RemoveRoom(providerid : String)
    {
        let param = ["_id":providerid];
        self.Removeuser(param: param)
        self.online(from: providerid, status: "0")
    }
    
    func LeaveRoom(providerid : String)
    {
        let param = ["_id":providerid];
        if(Appdel.IsInternetconnected && socket.status == .connected)
        {
            self.online(from: providerid, status: "0")
            self.Removeuser(param: param)
        }
        print("***************SOCKET DISCONNECTED******************")
    }
    
    
    //Message handler event incoming and outgoing messages from group
    func groupLeft(id:String) -> Bool{
        var isGroupMember:Bool = false
        let User_chat_id="\(Themes.sharedInstance.Getuser_id())-\(id)"
        let GroupDetailArr =  DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Group_details, attribute: "user_common_id", FetchString: User_chat_id, SortDescriptor: "timestamp") as! NSArray
        if(GroupDetailArr.count > 0){
            isGroupMember = true
        }
        return isGroupMember
    }
    
    func checkGroupMember(id:String) -> Bool{
        let groupIdArr:NSMutableArray = NSMutableArray()
        let chatprerecord:GroupDetail=GroupDetail()
        var isGroupMember:Bool = false
        let User_chat_id="\(Themes.sharedInstance.Getuser_id())-\(id)"
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
        if(chatprerecord.groupUsers.count > 0)
        {
            for j in 0..<chatprerecord.groupUsers.count
            {
                let Dict:NSDictionary=chatprerecord.groupUsers[j] as! NSDictionary
                let Grouppeoplerecord:Group_people_record=Group_people_record()
                Grouppeoplerecord.id=Themes.sharedInstance.CheckNullvalue(Passed_value: Dict.object(forKey: "id") as! String) as NSString
                
                groupIdArr.add("\(Grouppeoplerecord.id)")
                
            }
        }
        for i in 0..<groupIdArr.count{
            if(groupIdArr[i] as! String == Themes.sharedInstance.Getuser_id())
            {
                isGroupMember = true
                break
            }
        }
        return isGroupMember
    }
    
    func emitTURNMessage(_ param : [String : Any]) {
        print(param)
        emitEvent(Constant.sharedinstance.sc_webrtc_turn_message, param)
    }
    
    func emitTURNMessageFromCaller(_ param : [String : Any]) {
        print(param)
        emitCallEvent(Constant.sharedinstance.sc_webrtc_turn_message_from_caller, param)
    }
    
    // MARK: - Message Handling
    
    
    func StoreIncomingGroupMessage(ResponseDict:NSDictionary,isFromoffline:Bool)
    {
        MessageHandler.sharedInstance.StoreIncomingGroupMessage(ResponseDict: ResponseDict, isFromoffline: isFromoffline)
    }
    func LoadGroupResponses(ResponseDict:NSDictionary)
    {
        MessageHandler.sharedInstance.LoadGroupResponses(ResponseDict: ResponseDict)
    }
    func StoreIncomingMessage(ResponseDict:NSDictionary,isFromoffline:Bool)
    {
        MessageHandler.sharedInstance.StoreIncomingMessage(ResponseDict:ResponseDict,isFromoffline:isFromoffline)
    }
    func LoadStatusResponseMessages(ResponseDict:NSDictionary)
    {
        MessageHandler.sharedInstance.LoadStatusResponseMessages(ResponseDict:ResponseDict)
    }
    
    func StoreIncomingStatusMessage(ResponseDict:NSDictionary,isFromoffline:Bool)
    {
        MessageHandler.sharedInstance.StoreIncomingStatusMessage(ResponseDict:ResponseDict,isFromoffline:isFromoffline)
    }
    
    func LoadResponseMessages(ResponseDict:NSDictionary)
    {
        MessageHandler.sharedInstance.LoadResponseMessages(ResponseDict: ResponseDict)
    }
}
