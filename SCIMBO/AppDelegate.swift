//
//  AppDelegate.swift
//
//
//  Created by CASPERON on 19/12/16.
//  Copyright © 2016 CASPERON. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import PushKit
import JSSAlertView
import Contacts
import Messages
import MessageUI
import SDWebImage
import Intents
import SwiftyGiphy
import GLNotificationBar
//import Dynatrace
//import DynatraceSessionReplay


var languageHandler = Languagehandler()
var newGroup  = NewGroup()
var statusRec = Array<StatusRec>()
var filter_ContactRec = NSMutableArray()
var contactRec = NSMutableArray()
var Device_Token:NSString=NSString()
var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid


@available(iOS 10.0, *)
@objc protocol AppDelegateDelegates  : class {
    @objc optional  func ReceivedBuffer(Status : String, imagename : String)
    @objc optional  func ReceivedBuffer(Status: String, imagename: String, responseDict: NSDictionary)
    @objc optional  func passTurnMessage(payload : String)
    @objc optional  func receiveMessageInfo(response : [String : Any])
}
@available(iOS 10.0, *)

@available(iOS 10.0, *)
@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate
{
    static let sharedInstance = UIApplication.shared.delegate as! AppDelegate
    var window: UIWindow?
    let reachability = Reachability()!
    var IsInternetconnected:Bool=Bool()
    var ConnectionTimer : Timer = Timer()
    var byreachable : String = String()
    var isVideoViewPresented:Bool = Bool()
    var providerDelegate: ProviderDelegate!
    let callManager = CallManager()
    var responseDict : NSDictionary = NSDictionary()
    var VideoCallWaitTimer : Timer?
    var active:Bool = Bool()
    var CallDetailresponseDict : NSDictionary = NSDictionary()
    var call_record:Call_record = Call_record()
    var iterationCount:Int = 0
    var notification_dict:NSDictionary = NSDictionary()
    var chat_type:String = String()
    //var orientationLock = UIInterfaceOrientationMask.all
    var navigationController : RootNavController?
    var player : AVAudioPlayer?
    var callactivity : NSUserActivity?
    
    var currentRoomName : String = String()
    var currentOpponentId : String = String()

   weak var CallRetryTimer:Timer?
    var callRetryDict : NSDictionary = NSDictionary()
    
    weak var Delegate : AppDelegateDelegates?
    weak var callDelegate : AppDelegateDelegates?
    var notificationBar = GLNotificationBar()
    var IsKeyboardVisible = false
    var socketConnected:Bool=false
    var KeyboardFrame = CGRect.zero

    override init() {
        super.init()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        application.setMinimumBackgroundFetchInterval(3600)
        
        // to make launch screen still for 2 sec
        sleep(2)
//        let privacyConfig = Dynatrace.userPrivacyOptions()
//        privacyConfig.dataCollectionLevel = .userBehavior
//        privacyConfig.crashReportingOptedIn = true
//        Dynatrace.applyUserPrivacyOptions(privacyConfig) { (Bool) in
//            // callback after privacy changed
//        }
        
        // change tint color of navigation bar items        
        UINavigationBar.appearance().tintColor = CustomColor.sharedInstance.themeColor/* Change tint color using Xcode default vales */
        UIBarButtonItem.appearance().tintColor = CustomColor.sharedInstance.themeColor
        UIToolbar.appearance().tintColor = CustomColor.sharedInstance.themeColor
        UITabBar.appearance().tintColor = CustomColor.sharedInstance.themeColor
        UITextField.appearance().tintColor = CustomColor.sharedInstance.themeColor
        UITextView.appearance().tintColor = CustomColor.sharedInstance.themeColor
        Themes.sharedInstance.showWaitingNetwork(true, state: false)
        self.addNotificationListener()
        self.ReachabilityListener()
        
        
        self.MovetoRooVC()
       // moveTO_SWCC_Login()
        
        Themes.sharedInstance.getCurrentLocationCountryCode()
        self.pushRegistrySetup()
        self.pushnotificationSetup()
//        Fabric.with([Crashlytics.self])
//        Fabric.sharedSDK().debug = true
        
        SwiftyGiphyAPI.shared.apiKey = SwiftyGiphyAPI.publicBetaKey

        providerDelegate = ProviderDelegate(callManager: callManager)
        self.logUser()
        // dynatrace tool
        
        
        if(launchOptions != nil)
        {
            if let activityOptions = launchOptions?[UIApplication.LaunchOptionsKey.userActivityDictionary] as? [String: AnyObject],
                let activity = activityOptions["UIApplicationLaunchOptionsUserActivityKey"] as? NSUserActivity {
                callactivity = activity
            }
            else if let activityOptions = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? NSDictionary {
                self.openChatPage(activityOptions)
            }
        }
        return true
    }
    
    func addNotificationListener() {
        addcontactChangeobserver()

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.incomingcall), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            weak.incomingCall(notify)
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.outgoingcall), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            weak.outgoing_Call(notify)
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.receivedTurnMessage), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            let payload = Themes.sharedInstance.CheckNullvalue(Passed_value: notify.userInfo?["message"])
            if let delegate = weak.callDelegate {
                if let theMethod = delegate.passTurnMessage(payload: )
                {
                    let messageData = payload.data(using: .utf8)
                    var jsonObject = [String : Any]()
                    do {
                        if let messageData = messageData {
                            jsonObject = try JSONSerialization.jsonObject(with: messageData, options: []) as! [String : Any]
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                    let wssMessage = jsonObject
                    if let error = wssMessage["error"] as? String, error.count > 0 {
                        print(error)
                        return
                    }
                    if let payload = wssMessage["msg"] as? String {
                        theMethod(payload)
                    }
                }
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.userDeleted), name: NSNotification.Name(rawValue: Constant.sharedinstance.user_deleted), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.userCleared), name: NSNotification.Name(rawValue: Constant.sharedinstance.user_cleared), object: nil)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.pushView), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            weak.makeChatNotification(notify)
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.Incomingmessage), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            DispatchQueue.main.async {
                weak.makeCustomNotification(notify: notify)
            }
        }

        NotificationCenter.default.addObserver(self, selector: #selector(self.timeChangedNotification), name: .NSSystemClockDidChange, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.timeChangedNotification), name: .NSSystemTimeZoneDidChange, object: nil)
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            weak.IsKeyboardVisible = true
            var userInfo = notify.userInfo!
            weak.KeyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            weak.IsKeyboardVisible = false
            weak.KeyboardFrame = CGRect.zero
        }
    }
    
    func openChatPage(_ userInfo: NSDictionary) {
        guard Themes.sharedInstance.CheckNullvalue(Passed_value: userInfo.value(forKey: "to")) == Themes.sharedInstance.Getuser_id() else { return }
        var chat_type = Themes.sharedInstance.CheckNullvalue(Passed_value: userInfo.value(forKey: "chat_type"))
        if(chat_type == "") {
            chat_type = self.chat_type
        }
        let id = Themes.sharedInstance.CheckNullvalue(Passed_value: userInfo.value(forKey: "from"))
        if(chat_type == "single"){
            if(Themes.sharedInstance.isChatLocked(id: id, type: "single"))
            {
                Themes.sharedInstance.enterTochat(id: id, type: "single") { (success) in
                    if(success)
                    {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let ObjInitiateChatViewController:InitiateChatViewController=storyboard.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                        ObjInitiateChatViewController.Chat_type="single"
                        ObjInitiateChatViewController.opponent_id = id
                        self.navigationController?.pushView(ObjInitiateChatViewController, animated: true)
                    }
                }
            }
            else
            {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let ObjInitiateChatViewController:InitiateChatViewController=storyboard.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                ObjInitiateChatViewController.Chat_type="single"
                ObjInitiateChatViewController.opponent_id = id
                self.navigationController?.pushView(ObjInitiateChatViewController, animated: true)
            }
        }
        else if(chat_type == "secret")
        {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let ObjInitiateChatViewController:InitiateChatViewController=storyboard.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
            ObjInitiateChatViewController.Chat_type="secret"
            ObjInitiateChatViewController.opponent_id = id
            ObjInitiateChatViewController.is_fromSecret = true
            self.navigationController?.pushView(ObjInitiateChatViewController, animated: true)
        }
        else if(chat_type == "group"){
            let to = Themes.sharedInstance.CheckNullvalue(Passed_value: userInfo.value(forKey: "groupId"))
            if(Themes.sharedInstance.isChatLocked(id: to, type: "group"))
            {
                Themes.sharedInstance.enterTochat(id: to, type: "group") { (success) in
                    if(success)
                    {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let ObjInitiateChatViewController:InitiateChatViewController=storyboard.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                        ObjInitiateChatViewController.opponent_id = to
                        ObjInitiateChatViewController.Chat_type="group"
                        self.navigationController?.pushView(ObjInitiateChatViewController, animated: true)
                    }
                }
            }
            else
            {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let ObjInitiateChatViewController:InitiateChatViewController=storyboard.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                ObjInitiateChatViewController.opponent_id = to
                ObjInitiateChatViewController.Chat_type="group"
                self.navigationController?.pushView(ObjInitiateChatViewController, animated: true)
            }
        }
    }
    
    @objc func timeChangedNotification(){
        print("Device time has been changed...")
        SocketIOManager.sharedInstance.EmitGetServerTime(Dict: ["client_time" : String(Date().ticks)])
    }
    
    func addcontactChangeobserver()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateContact(_:)), name: .CNContactStoreDidChange, object: nil)
    }
    
    
    @objc func updateContact(_ notify: Notification)
    {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
            self.addcontactChangeobserver()
        }
        //        DispatchQueue.global(qos: .background).async {
//        if(!ContactHandler.sharedInstance.StorecontactInProgress)
//        {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.StoreContacts), object: nil)
            self.perform(#selector(self.StoreContacts), with: nil, afterDelay: 0.0)
            NotificationCenter.default.removeObserver(self, name: .CNContactStoreDidChange, object: nil)
//        }
    }
    
    @objc func StoreContacts()
    {
        var CheckLogin = false
        if(Themes.sharedInstance.Getuser_id() != "")
        {
            CheckLogin = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.User_detail, attribute: "user_id", FetchString: Themes.sharedInstance.Getuser_id())
        }
        if(CheckLogin)
        {
            ContactHandler.sharedInstance.StoreContacts()
        }
    }
    
    func logUser() {
        if(Themes.sharedInstance.Getuser_id() != "")
        {
//            Crashlytics.sharedInstance().setUserIdentifier(Themes.sharedInstance.Getuser_id())
//            Crashlytics.sharedInstance().setUserName(Themes.sharedInstance.setNameTxt(Themes.sharedInstance.Getuser_id(), ""))
//            Crashlytics.sharedInstance().setUserEmail(Themes.sharedInstance.GetMyPhonenumber())
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        return true
    }
    
    func makeChatNotification(_ notify: Notification){
        
        let content = UNMutableNotificationContent()
        let ResponseDict:NSDictionary = notify.object  as! NSDictionary
        self.notification_dict = ResponseDict
        let state = UIApplication.shared.applicationState
        if state == .background
        {
            let type = Themes.sharedInstance.CheckNullvalue(Passed_value: notify.userInfo?["chat_type"])
            if(Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Notification_Setting, attrib_name: "user_id", fetchString: Themes.sharedInstance.Getuser_id(), returnStr: "is_show_notification_" + type) == "0")
            {
                return
            }
            self.chat_type = type
            var payload:String = ""
            if(ResponseDict.object(forKey: "payload") != nil)
            {
                payload  = EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "payload")), toid: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "from")), chat_type: type) as! String
                
            }
            else if(ResponseDict.object(forKey: "message") != nil)
            {
                payload  = EncryptionHandler.sharedInstance.Decryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "message")), toid: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "from")), chat_type: type) as! String
                
            }
            if(type == "single" || type == "secret"){
                var msisdn = ""
                if(Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "ContactMsisdn")) == "")
                {
                    msisdn = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Favourite_Contact, attrib_name: "id", fetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "from")), returnStr: "msisdn")
                }
                else
                {
                    msisdn = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "ContactMsisdn"))
                }
                let Name = Themes.sharedInstance.ReturnFavName(opponentDetailsID: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "from")), msginid: msisdn)
                content.title = Name
                if(type == "secret")
                {
                    content.title = Name + " : Secret Chat"
                }
                
            }else if(type == "group"){
                if(Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "groupType")) == "10")
                {
                    var Name = Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.ReturnFavName(opponentDetailsID: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "from")), msginid: Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Favourite_Contact, attrib_name: "id", fetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "from")), returnStr: "msisdn")))
                    
                    Name = (Name == "") ? Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "msisdn")) : Name
                    content.title = "\(Name) @ \(Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "groupName")))"
                }
                else
                {
                    var msisdn = ""
                    if(Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "ContactMsisdn")) == "")
                    {
                        msisdn = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "msisdn")).parseNumber
                    }
                    else
                    {
                        msisdn = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "ContactMsisdn")).parseNumber
                    }
                    let Name = Themes.sharedInstance.ReturnFavName(opponentDetailsID: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "from")), msginid: msisdn)
                    content.title = "\(Name) @ \(Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "groupName")))"
                }
                
            }
            
            if(Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "type")) == "0" || Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "type")) == "7"){
                
                content.body = Themes.sharedInstance.getID_Range_Payload_Name(message: payload)[2] as! String
                
            }
            else if(Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "groupType")) == "10"){
                
                var Name = Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.ReturnFavName(opponentDetailsID: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "from")), msginid: Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Favourite_Contact, attrib_name: "id", fetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "from")), returnStr: "msisdn")))
                
                Name = (Name == "") ? Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "msisdn")) : Name
                
                let payload = "\(Name) invited you in \(Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "groupName"))) group"
                
                content.body = Themes.sharedInstance.getID_Range_Payload_Name(message: payload)[2] as! String
                
                
            }else if(Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "type")) == "5"){
                content.body = "📝 \(Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "contact_name")))"
            }else if(Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "type")) == "3"){
                content.body = "🎵 Audio"
            }else if(Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "type")) == "6" || Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "type")) == "20"){
                content.body = "📄 Document"
            }else if(Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "type")) == "2"){
                content.body = "📹 Video"
            }else if(Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "type")) == "1"){
                content.body = "📷 Photo"
            }else if(Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "type")) == "14"){
                content.body = "📍 Location"
            }
            else if(Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "type")) == "21")
            {
                content.body = "☎︎  Missed Call from \(String(describing: content.title.replacingOccurrences(of: " : Secret Chat", with: "")))"
                
            }
            else if(Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "type")) == "4"){
                content.body = "🔗 Link"
            }
            else if(Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "type")) == "23") {
                content.body = "\(String(describing: content.title.replacingOccurrences(of: " : Secret Chat", with: ""))) Security code changed"
            }

            //content.sound = UNNotificationSound.default()
            //To Present image in notification
            if let path = Bundle.main.path(forResource: "monkey", ofType: "png") {
                let url = URL(fileURLWithPath: path)
                
                do {
                    let attachment = try UNNotificationAttachment(identifier: "sampleImage", url: url, options: nil)
                    content.attachments = [attachment]
                } catch {
                    print("attachment not found.")
                }
            }
            
            let getsound = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Notification_Setting, attrib_name: "user_id", fetchString: Themes.sharedInstance.Getuser_id(), returnStr: (chat_type == "group") ? "group_sound" : "single_sound")
            
            if(getsound == "Default") {
                
                let isSound = (Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Notification_Setting, attrib_name: "user_id", fetchString: Themes.sharedInstance.Getuser_id(), returnStr: "is_sound") as NSString).boolValue
                let isVibrate = (Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Notification_Setting, attrib_name: "user_id", fetchString: Themes.sharedInstance.Getuser_id(), returnStr: "is_vibrate") as NSString).boolValue
                if(isSound) {
                    content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "notification.caf"))
                }
                if(isVibrate) {
                    playNotificationSound(vibrate: isVibrate, systemSound: 0)
                }
            }
            else
            {
                setNotificationSound()
            }
            
            let request = UNNotificationRequest(identifier:"chat_request" + "-" + Themes.sharedInstance.fourUniqueDigits, content: content, trigger: nil)
            
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().add(request){(error) in
                if (error != nil){
                }
            }
            self.setBadgeCount()
            
        }
    }
    
    func makeCustomNotification(notify: Notification) {
        
        let ResponseDict:NSDictionary = notify.object  as! NSDictionary
        
        let id = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "from"))
        let convId = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "convId"))
        let chat_type:String = Themes.sharedInstance.CheckNullvalue(Passed_value: notify.userInfo?["chat_type"])
        let is_mute = Themes.sharedInstance.CheckMuteChats(id: (chat_type == "group") ? convId : id , type: chat_type)
        if(is_mute && !(self.navigationController?.topViewController is InitiateChatViewController))
        {
            return
        }
        
        if(!(self.navigationController?.topViewController is InitiateChatViewController))
        {
            var offline = "false"
            if((notify.userInfo?["offline"]) != nil)
            {
                offline = notify.userInfo?["offline"] as! String
            }
            if((notify.userInfo?["user_common_id"]) != nil)
            {
                if(offline == "false"){
                    if(ResponseDict.count > 0)
                    {
                        print(ResponseDict)
                        let chat_type:String! = Themes.sharedInstance.CheckNullvalue(Passed_value: notify.userInfo?["chat_type"])
                        var SenderName:String?
                        if(Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Notification_Setting, attrib_name: "user_id", fetchString: Themes.sharedInstance.Getuser_id(), returnStr: "is_show_notification_" + chat_type) == "0")
                        {
                            return
                        }
                        if(chat_type == "single")
                        {
                            
                            SenderName=Themes.sharedInstance.ReturnFavName(opponentDetailsID: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "from") as! String), msginid: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "contactmsisdn") as! String))
                        }else if(chat_type == "secret"){
                            
                            SenderName="\(Themes.sharedInstance.ReturnFavName(opponentDetailsID: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "from") as! String), msginid: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "contactmsisdn") as! String))) : Secret Chat"
                            
                        }
                        else
                        {
                            let GroupName = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Group_details, attrib_name: "user_common_id", fetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "user_common_id")), returnStr: "displayName")
                            
                            SenderName = "\(Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.ReturnFavName(opponentDetailsID: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "from")), msginid: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "contactmsisdn"))))) @ \(GroupName)"
                            
                        }
                        
                        if(SenderName == nil)
                        {
                            SenderName = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "contactmsisdn"))
                        }
                        if(SenderName == "")
                        {
                            SenderName = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Favourite_Contact, attrib_name: "id", fetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.object(forKey: "from")), returnStr: "name")
                        }
                        var Message = ""
                        
                        
                        if(Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "type")) == "0" || Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "type")) == "7"){
                            
                            let payload = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "payload"))
                            
                            Message = Themes.sharedInstance.getID_Range_Payload_Name(message: payload)[2] as! String
                            
                            
                        }else if(Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "type")) == "1"){
                            Message = "📷 Photo"
                        }else if(Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "type")) == "2"){
                            Message = "📹 Video"
                        }else if(Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "type")) == "3"){
                            Message = "🎵 Audio"
                        }else if(Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "type")) == "4"){
                            Message = "🔗 Link"
                        }else if(Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "type")) == "5"){
                            Message = "📝 Contact"
                        }else if(Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "type")) == "6" || Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "type")) == "20"){
                            Message = "📄 Document"
                        }else if(Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "type")) == "14"){
                            Message = "📍 Location"
                        }
                        
                        let info_type = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "info_type") as! String)
                        if(info_type == "21")
                        {
                            Message = "☎︎ Missed Call from \(String(describing: SenderName!))"
                        }
                        else if(info_type == "23") {
                            Message = "\(String(describing: SenderName!)) Security code changed"
                        }
                        
                        if(notificationBar.CheckNotificationbarisHidden())
                        {
                            
                            var style:GLNotificationStyle!
                            style = .detailedBanner
                            notificationBar = GLNotificationBar(title: SenderName!, message:Message , preferredStyle:style) { (bool) in
                                
                                if self.navigationController?.topViewController is InitiateChatViewController {
                                    return
                                }
                                
                                
                                if(chat_type == "single") {
                                    let chatLocked = Themes.sharedInstance.isChatLocked(id: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "from")), type: chat_type)
                                    if(chatLocked == true){
                                        self.entertoChat(id: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "from")), type: "single")
                                    }else{
                                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                        let ObjInitiateChatViewController:InitiateChatViewController=storyboard.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                                        ObjInitiateChatViewController.Chat_type = chat_type
                                        ObjInitiateChatViewController.opponent_id = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "from"))
                                        ObjInitiateChatViewController.Chat_type=Themes.sharedInstance.CheckNullvalue(Passed_value: chat_type as String)
                                        self.navigationController?.pushView(ObjInitiateChatViewController, animated: true)
                                    }
                                }
                                else if(chat_type == "secret") {
                                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                    let ObjInitiateChatViewController:InitiateChatViewController = storyboard.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                                    ObjInitiateChatViewController.Chat_type = chat_type
                                    ObjInitiateChatViewController.opponent_id = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "from"))
                                    ObjInitiateChatViewController.is_fromSecret = true
                                    self.navigationController?.pushView(ObjInitiateChatViewController, animated: true)
                                }
                                else if(chat_type == "group")
                                {
                                    let chatLocked = Themes.sharedInstance.isChatLocked(id: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "convId") as! String), type: chat_type)
                                    if(chatLocked == true){
                                        self.entertoChat(id: Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "convId")), type: "group")
                                    }else{
                                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                        let ObjInitiateChatViewController:InitiateChatViewController=storyboard.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                                        ObjInitiateChatViewController.Chat_type = "group"
                                        ObjInitiateChatViewController.opponent_id = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "convId"))
                                        self.navigationController?.pushView(ObjInitiateChatViewController, animated: true)
                                    }
                                    
                                }
                                
                            }
                            
                            notificationBar.addAction(GLNotifyAction(title: NSLocalizedString("Cancel", comment: "comment"), style: .destructive, handler: { (result) in
                            }))
                            
                            notificationBar.addAction(GLNotifyAction(title: "REPLY", style: .default, handler: { (result) in
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let ObjInitiateChatViewController:InitiateChatViewController = storyboard.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                                ObjInitiateChatViewController.Chat_type = Themes.sharedInstance.CheckNullvalue(Passed_value: chat_type)
                                if(chat_type == "secret"){
                                    ObjInitiateChatViewController.is_fromSecret = true
                                }
                                ObjInitiateChatViewController.opponent_id = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "from"))
                                self.navigationController?.pushView(ObjInitiateChatViewController, animated: true)
                            }))
                            notificationBar.showTime(2.0)
                            
                            let state = UIApplication.shared.applicationState
                            if(state == .active) {
                                let getsound = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Notification_Setting, attrib_name: "user_id", fetchString: Themes.sharedInstance.Getuser_id(), returnStr: (chat_type == "group") ? "group_sound" : "single_sound")
                                
                                if(getsound == "Default") {
                                    
                                    let isSound = (Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Notification_Setting, attrib_name: "user_id", fetchString: Themes.sharedInstance.Getuser_id(), returnStr: "is_sound") as NSString).boolValue
                                    
                                    let isVibrate = (Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Notification_Setting, attrib_name: "user_id", fetchString: Themes.sharedInstance.Getuser_id(), returnStr: "is_vibrate") as NSString).boolValue
                                    
                                    if(isSound)
                                    {
                                        self.PlayAudio(tone: "notification", type: "caf", isrepeat: false)
                                    }
                                    
                                    if isVibrate {
                                        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
                                    }
                                    
                                    
                                }
                                else
                                {
                                    let CheckSettings:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Notification_Setting, attribute: "user_id", FetchString: Themes.sharedInstance.Getuser_id())
                                    if(CheckSettings)
                                    {
                                        let NotificationArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Notification_Setting, attribute: "user_id", FetchString: Themes.sharedInstance.Getuser_id(), SortDescriptor: nil) as! NSArray
                                        for i in 0..<NotificationArr.count
                                        {
                                            let objRecord:NSManagedObject = NotificationArr[i] as! NSManagedObject
                                            let group_sound:String = objRecord.value(forKey: "group_sound") as! String
                                            let  is_sound = objRecord.value(forKey: "is_sound")  as! Bool
                                            
                                            let is_vibrate = objRecord.value(forKey: "is_vibrate")  as! Bool
                                            let single_sound = objRecord.value(forKey: "single_sound") as! String
                                            let iShowSingleNotification = objRecord.value(forKey: "is_show_notification_single") as! Bool
                                            let iShowgroupNotification = objRecord.value(forKey: "is_show_notification_group")  as! Bool
                                            if(is_sound)
                                            {
                                                if(chat_type == "single" || chat_type == "secret")
                                                {
                                                    if(iShowSingleNotification)
                                                        
                                                    {
                                                        let GetSoundID:UInt32 = UInt32(single_sound)!
                                                        notificationBar.notificationSound("iphone", ofType: "mp3", vibrate: is_vibrate, systemSound: UInt(GetSoundID))
                                                    }
                                                    
                                                }
                                                else  if(chat_type == "group")
                                                {
                                                    if(iShowgroupNotification)
                                                    {
                                                        let GetSoundID:UInt32 = UInt32(group_sound)!
                                                        notificationBar.notificationSound("iphone", ofType: "mp3", vibrate: is_vibrate, systemSound: UInt(GetSoundID))
                                                    }
                                                }
                                            }
                                            else if(is_vibrate)
                                            {
                                                notificationBar.notificationSound("iphone", ofType: "mp3", vibrate: is_vibrate, systemSound: 0)
                                                
                                            }
                                            else
                                            {
                                                notificationBar.notificationSound("iphone", ofType: "mp3", vibrate: is_vibrate, systemSound: 0)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        let state = UIApplication.shared.applicationState
        if(state == .background)
        {
            let count = Themes.sharedInstance.getUnreadChatCount(true)
            UIApplication.shared.applicationIconBadgeNumber = count
            let defaults = UserDefaults(suiteName: "group.com.2p.Engage")
            defaults?.set(count, forKey: "BadgeCount")
        }
    }
    func waitingForNetwork(_ isNetwork:Bool , state:Bool){
        
        if((self.navigationController?.topViewController?.isKind(of: LoginVC.self))! || (self.navigationController?.topViewController?.isKind(of: SecondLoginVC.self))! || (self.navigationController?.topViewController?.isKind(of: ProfileInfoViewController.self))!){
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
                    for view in (AppDelegate.sharedInstance.window?.subviews)! where view.tag == 12 {
                        view.removeFromSuperview()
                    }
                }) { success in
                }
            }
        }else
        {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
                    for view in (AppDelegate.sharedInstance.window?.subviews)! where view.tag == 12 {
                        view.removeFromSuperview()
                    }
                }) { success in
                }
            }
            var height:CGFloat = 0
            if UIDevice.isIphoneX {
                height = Constant.sharedinstance.NavigationBarHeight_iPhoneX
            } else {
                height = Constant.sharedinstance.NavigationBarHeight
            }
            if isNetwork {
                if !state {
                    DispatchQueue.main.async {
                        let nibView = Bundle.main.loadNibNamed("ConnectingView", owner: self, options: nil)![0] as! ConnectingView
                        nibView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height)
                        nibView.hint_lbl.text = "Waiting for network.."
                        nibView.activity_view.startAnimating()
                        nibView.alpha = 0.0
                        nibView.tag = 12
                        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
                            nibView.alpha = 1.0
                            AppDelegate.sharedInstance.window?.addSubview(nibView)
                        }) { success in
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
                            for view in (AppDelegate.sharedInstance.window?.subviews)! where view.tag == 12 {
                                view.removeFromSuperview()
                            }
                        }) { success in
                        }
                    }
                }
            }else{
                if !state {
                    DispatchQueue.main.async {
                        let nibView = Bundle.main.loadNibNamed("ConnectingView", owner: self, options: nil)![0] as! ConnectingView
                        nibView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height)
                        nibView.hint_lbl.text = "Connecting.."
                        nibView.activity_view.startAnimating()
                        nibView.alpha = 0.0
                        nibView.tag = 12
                        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
                            nibView.alpha = 1.0
                            AppDelegate.sharedInstance.window?.addSubview(nibView)
                        }) { success in
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
                            for view in (AppDelegate.sharedInstance.window?.subviews)! where view.tag == 12 {
                                view.removeFromSuperview()
                            }
                        }) { success in
                        }
                    }
                }
            }
        }
    }
    func entertoChat(id:String,type:String){
        Themes.sharedInstance.enterTochat(id: id, type: type) { (success) in
            if(success)
            {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let ObjInitiateChatViewController:InitiateChatViewController = storyboard.instantiateViewController(withIdentifier: "InitiateChatViewControllerID") as! InitiateChatViewController
                ObjInitiateChatViewController.Chat_type = type
                ObjInitiateChatViewController.opponent_id = id
                self.navigationController?.pushView(ObjInitiateChatViewController, animated: true)
            }
        }
    }
    
    func setNotificationSound()
    {
        let CheckSettings:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Notification_Setting, attribute: "user_id", FetchString: Themes.sharedInstance.Getuser_id())
        if(CheckSettings)
        {
            let NotificationArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Notification_Setting, attribute: "user_id", FetchString: Themes.sharedInstance.Getuser_id(), SortDescriptor: nil) as! NSArray
            for i in 0..<NotificationArr.count
            {
                let objRecord:NSManagedObject = NotificationArr[i] as! NSManagedObject
                let group_sound:String = objRecord.value(forKey: "group_sound") as! String
                let  is_sound = objRecord.value(forKey: "is_sound")  as! Bool
                
                let is_vibrate = objRecord.value(forKey: "is_vibrate")  as! Bool
                let single_sound = objRecord.value(forKey: "single_sound") as! String
                let iShowSingleNotification = objRecord.value(forKey: "is_show_notification_single") as! Bool
                let iShowgroupNotification = objRecord.value(forKey: "is_show_notification_group")  as! Bool
                if(is_sound)
                {
                    if(chat_type == "single" || chat_type == "secret")
                    {
                        if(iShowSingleNotification)
                        {
                            let GetSoundID:UInt32 = UInt32(single_sound)!
                            playNotificationSound(vibrate: is_vibrate, systemSound: UInt(GetSoundID))
                        }
                    }
                    else  if(chat_type == "group")
                    {
                        if(iShowgroupNotification)
                        {
                            let GetSoundID:UInt32 = UInt32(group_sound)!
                            playNotificationSound(vibrate: is_vibrate, systemSound: UInt(GetSoundID))
                        }
                    }
                }
                else if(is_vibrate)
                {
                    playNotificationSound(vibrate: is_vibrate, systemSound: 0)
                }
                else
                {
                    playNotificationSound(vibrate: is_vibrate, systemSound: 0)
                }
                
            }
        }
    }
    
    func playNotificationSound(vibrate : Bool, systemSound:UInt)
    {
        if vibrate {
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        }
        if(systemSound == 0)
        {
            
        }
        else
        {
            AudioServicesPlaySystemSound(SystemSoundID(systemSound));
            
        }
    }
    
    
    @objc func userDeleted(){
        let alertview = JSSAlertView().show(
            (self.navigationController?.topViewController)!,
            title: Themes.sharedInstance.GetAppname(),
            text: "Your account has been deleted by admin.",
            buttonText: "Ok",
            cancelButtonText: nil
        )
        alertview.addAction(self.Logout)
    }
    
    @objc func userCleared(){
        let alertview = JSSAlertView().show(
            (self.navigationController?.topViewController)!,
            title: Themes.sharedInstance.GetAppname(),
            text: "Your have been logged out by admin.",
            buttonText: "Ok",
            cancelButtonText: nil
        )
        alertview.addAction(self.Logout)
    }
    
    func Logout()
    {
        KeychainService.removePassword()
        Themes.sharedInstance.savepublicKey(DeviceToken: "")
        Themes.sharedInstance.savesPrivatekey(DeviceToken: "")
        Themes.sharedInstance.savesecurityToken(DeviceToken: "")
        
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()

        let Dict:NSDictionary = ["from":Themes.sharedInstance.Getuser_id()]
        SocketIOManager.sharedInstance.mobileToWebLogout(Param: Dict as! [String : Any])
        
        SocketIOManager.sharedInstance.LeaveRoom(providerid: Themes.sharedInstance.Getuser_id())
        
        SocketIOManager.sharedInstance.socket.removeAllHandlers()
        SocketIOManager.sharedInstance.socket.disconnect()
        SecretmessageHandler.sharedInstance.stoptimer()

        DispatchQueue.main.async {
            let entities = [Constant.sharedinstance.Chat_one_one,
                            Constant.sharedinstance.Chat_intiated_details,
                            Constant.sharedinstance.Mute_chats,
                            Constant.sharedinstance.Contact_add,
                            Constant.sharedinstance.User_detail,
                            Constant.sharedinstance.Favourite_Contact,
                            Constant.sharedinstance.Link_details,
                            Constant.sharedinstance.Contact_details,
                            Constant.sharedinstance.Group_details,
                            Constant.sharedinstance.Other_Group_message,
                            Constant.sharedinstance.status_List,
                            Constant.sharedinstance.Upload_Details,
                            Constant.sharedinstance.Location_details,
                            Constant.sharedinstance.Reply_detail,
                            Constant.sharedinstance.Notification_Setting,
                            Constant.sharedinstance.Blocked_user,
                            Constant.sharedinstance.Contact_Blocked_user,
                            Constant.sharedinstance.Group_message_ack,
                            Constant.sharedinstance.Data_Usage_Settings,
                            Constant.sharedinstance.Chat_Backup_Settings,
                            Constant.sharedinstance.Call_detail,
                            Constant.sharedinstance.Login_details,
                            Constant.sharedinstance.Secret_Chat,
                            Constant.sharedinstance.Conv_detail,
                            Constant.sharedinstance.Status_Upload_Details,
                            Constant.sharedinstance.Status_one_one,
                            Constant.sharedinstance.Status_initiated_details,
                            Constant.sharedinstance.Lock_Details,
                            Constant.sharedinstance.BaseURL]
            
            DatabaseHandler.sharedInstance.truncateDataForTables(entities)
            
            Filemanager.sharedinstance.DeleteFile(foldername: Constant.sharedinstance.photopath)
            Filemanager.sharedinstance.DeleteFile(foldername: Constant.sharedinstance.videopathpath)
            Filemanager.sharedinstance.DeleteFile(foldername: Constant.sharedinstance.docpath)
            Filemanager.sharedinstance.DeleteFile(foldername: Constant.sharedinstance.voicepath)
            Filemanager.sharedinstance.DeleteFile(foldername: Constant.sharedinstance.wallpaperpath)
            Filemanager.sharedinstance.DeleteFile(foldername: Constant.sharedinstance.statuspath)

            let count = Themes.sharedInstance.getUnreadChatCount(true)
            UIApplication.shared.applicationIconBadgeNumber = count
            let defaults = UserDefaults(suiteName: "group.com.2p.Engage")
            defaults?.set(count, forKey: "BadgeCount")
            self.MovetoRooVC()
            self.pushRegistrySetup()
            self.pushnotificationSetup()
        }
    }
    
    // MARK: - IMAGE UPLOAD HANDLING
    
    func ReceivedBufferImage(Status: String, imagename: String, uploadType : String) {
        if uploadType == "single"
        {
            if let delegate = self.Delegate {
                if let theMethod = delegate.ReceivedBuffer(Status:  imagename: )
                {
                    theMethod("Updated", imagename)
                }
            }
        }
        if uploadType == "group"
        {
            if let delegate = self.Delegate {
                if let theMethod = delegate.ReceivedBuffer(Status:  imagename: )
                {
                    theMethod("Updated", imagename)
                }
            }
        }
    }
    
    func MessageInfo(_ Response : [String : Any]) {
        if let delegate = self.Delegate {
            if let theMethod = delegate.receiveMessageInfo(response:)
            {
                theMethod(Response)
            }
        }
    }
    
    func ReceivedBufferImage_chat(Status: String, imagename: String, responseDict: NSDictionary, uploadType: String) {
        if uploadType == "status"
        {
            DispatchQueue.global(qos: .utility).async {
                StatusUploadHandler.Sharedinstance.Received(Status: Status, imagename: imagename, responseDict: responseDict)
            }
        }
        else if uploadType == "single_chat"
        {
            DispatchQueue.global(qos: .background).async {
                UploadHandler.Sharedinstance.Received(Status: Status, imagename: imagename, responseDict: responseDict)
            }
        }
        else if uploadType == "celebrity"
        {
            if let delegate = self.Delegate {
                if let theMethod = delegate.ReceivedBuffer(Status:  imagename: responseDict:)
                {
                    theMethod("Updated", imagename, responseDict)
                }
            }
        }
    }
    
    
    
    func SockedConnected(isConnected: Bool)
    {
        var status = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.User_detail, attrib_name: "user_id", fetchString: Themes.sharedInstance.Getuser_id(), returnStr: "status")
        if(status != "")
        {
            status = Themes.sharedInstance.base64ToString(status)
        }
        SocketIOManager.sharedInstance.changeStatus(status: status, from:Themes.sharedInstance.Getuser_id())
        
        if(responseDict.allKeys.count > 0)
        {
            SocketIOManager.sharedInstance.EmitGetCallStatus(param: responseDict as! [String : Any])
        }
        
        if(callactivity != nil)
        {
            self.launchActivity(callactivity!)
            callactivity = nil
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: ["hit" : "1"] , userInfo: nil)
    }
    
    
    func CallStatus(call_status : String)
    {
        if(Int(call_status)! == Constant.sharedinstance.call_status_CALLING)
        {
            if(!self.isVideoViewPresented)
            {
                let CallType:String = Themes.sharedInstance.CheckNullvalue(Passed_value: responseDict.object(forKey: "type"))
                
                if(CallType == "0")
                {
                    let state = UIApplication.shared.applicationState
                    if state == .background || state == .inactive
                    {
                        self.isVideoViewPresented = true
                        providerDelegate.responseDict = responseDict
                        providerDelegate.objcallrecord = nil
                        let handle = Themes.sharedInstance.CheckNullvalue(Passed_value: responseDict.object(forKey: "ContactMsisdn"))
                        providerDelegate.reportIncomingCall(uuid: UUID(), handle: handle, hasVideo: false, completion: nil)
                        if(SocketIOManager.sharedInstance.socket.status == .disconnected || SocketIOManager.sharedInstance.socket.status == .notConnected){
                            IntitialiseSocket()
                        }
                        else
                        {
                            updateCallStatus(responseDict: responseDict)
                        }
                    }
                    
                }
                else
                {
                    CallDetailresponseDict = responseDict
                    if(SocketIOManager.sharedInstance.socket.status == .disconnected || SocketIOManager.sharedInstance.socket.status == .notConnected){
                        IntitialiseSocket()
                    }
                    else
                    {
                        Callhandler.sharedInstance.CallIncomingAcknowledgement(responseDict: responseDict)
                    }
                    iterationCount = 0
                    VideoCallWaitTimer?.invalidate()
                    VideoCallWaitTimer = nil
                    //VideoCallWaitTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector:  #selector(self.MakeNotificaiton), userInfo: nil, repeats: true)
                    
                }
            }
        }
        
        //        Callhandler.sharedInstance.CallIncomingAcknowledgement(responseDict: CallDetailresponseDict)
    }
    
    @objc func MakeNotificaiton() {
        let content = UNMutableNotificationContent()
        
        if(!isVideoViewPresented)
        {
            let state = UIApplication.shared.applicationState
            if state == .background || state == .inactive
            {
                if(iterationCount == 0)
                {
                    self.PlayAudio(tone: "tone", type: "mp3")
                }
                iterationCount += 1
                if(iterationCount < 10)
                {
                    
                    print(CallDetailresponseDict)
                    let objcallrecord:Call_record = Callhandler.sharedInstance.ReturnCallRecord(responseDict: CallDetailresponseDict)!
                    content.title = Themes.sharedInstance.ReturnFavName(opponentDetailsID: objcallrecord.from, msginid: objcallrecord.ContactMsisdn)
                    content.body = "📹 Incoming Video Call"

                    // Deliver the notification in five seconds.
                    let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1.0, repeats: false)
                    let request = UNNotificationRequest(identifier:"VideoCallRequest", content: content, trigger: trigger)
                    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
                    UNUserNotificationCenter.current().delegate = self
                    UNUserNotificationCenter.current().add(request){(error) in
                        if (error != nil){
                        }
                    }
                }
                else
                {
                    player?.stop()
                    iterationCount = 0
                    VideoCallWaitTimer?.invalidate()
                    VideoCallWaitTimer = nil
                }
            }
            else if state == .active
            {
                player?.stop()
                iterationCount = 0
                VideoCallWaitTimer?.invalidate()
                VideoCallWaitTimer = nil
                let center = UNUserNotificationCenter.current()
                center.removeAllPendingNotificationRequests()
                center.removeAllDeliveredNotifications()
                let objcallrecord:Call_record = Callhandler.sharedInstance.ReturnCallRecord(responseDict: CallDetailresponseDict)!
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.incomingcall), object: objcallrecord , userInfo: nil)
            }
            
        }
        else
        {
            player?.stop()
            iterationCount = 0
            VideoCallWaitTimer?.invalidate()
            VideoCallWaitTimer = nil
            
        }
        
    }
    
    func PlayAudio(tone: String, type: String, isrepeat : Bool = true)
    {
        let session = AVAudioSession.sharedInstance()

        if(!isVideoViewPresented) {
            try? session.setCategory(AVAudioSession.Category.playAndRecord)
            
            try? session.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            
            try? session.setActive(true)
        }
        
        let path = Bundle.main.path(forResource: tone, ofType:type)!
        let url = URL(fileURLWithPath: path)
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = isrepeat ? -1 : 0
            player?.prepareToPlay()
            player?.volume = 10.0
            player?.play()
        } catch
        {
            print("error loading file")
            // couldn't load file :(
        }
        
    }
    
    
    func updateCallStatus(responseDict : NSDictionary)
    {
        if(responseDict.count > 0)
        {
            let from:String = Themes.sharedInstance.CheckNullvalue(Passed_value: responseDict.object(forKey: "from"))
            if(from == Themes.sharedInstance.Getuser_id())
            {
                
            }
            else
            {
                let objcallrecord = Callhandler.sharedInstance.ReturnCallRecord(responseDict: responseDict)!
                let param:[String:Any] = ["from":Themes.sharedInstance.Getuser_id(),"to":objcallrecord.from,"msgIds":(objcallrecord.msgId as NSString).longLongValue,"doc_id":objcallrecord.doc_id,"status":"1"]
                
                if(objcallrecord.type == "0")
                {
                    var timestamp:String =  String(Date().ticks)
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
                        let DBDict:NSDictionary = ["from":objcallrecord.from,"to":Themes.sharedInstance.Getuser_id(),"call_status":Constant.sharedinstance.call_status_ARRIVED,"user_id":Themes.sharedInstance.Getuser_id(),"doc_id":objcallrecord.doc_id,"id":objcallrecord.msgId,"timestamp":timestamp,"call_type":objcallrecord.type,"call_duration":"00:00", "recordId" : objcallrecord.recordId]
                        DatabaseHandler.sharedInstance.InserttoDatabase(Dict: DBDict, Entityname: Constant.sharedinstance.Call_detail)
                        
                    }
                    else
                    {
                        let DBDict:NSDictionary = ["from":objcallrecord.from,"to":Themes.sharedInstance.Getuser_id(),"call_status":Constant.sharedinstance.call_status_ARRIVED,"user_id":Themes.sharedInstance.Getuser_id(),"id":objcallrecord.msgId,"timestamp":timestamp,"call_type":objcallrecord.type, "recordId" : objcallrecord.recordId]
                        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Call_detail, FetchString: objcallrecord.doc_id, attribute: "doc_id", UpdationElements: DBDict)
                    }
                    let user_dict:NSDictionary = ["current_call_status":Constant.sharedinstance.call_in_ringing,"call_id":objcallrecord.doc_id]
                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail, FetchString: Themes.sharedInstance.Getuser_id(), attribute: "user_id", UpdationElements: user_dict)
                    let CallStatusDict:NSDictionary = ["from":objcallrecord.from,"to":Themes.sharedInstance.Getuser_id(),"call_status":Constant.sharedinstance.call_status_ARRIVED,"toDocId":objcallrecord.doc_id,"id":objcallrecord.msgId,"recordId":objcallrecord.recordId]
                    SocketIOManager.sharedInstance.EmitCallStatus(ResponseDict: CallStatusDict)
                    SocketIOManager.sharedInstance.emitCallAck(Param: param)
                }
            }
        }
    }
    
    func outgoing_Call(_ notify: Notification)
    {
        if(self.isVideoViewPresented == true)
        {
            let objcallrecord:Call_record = notify.object as! Call_record
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.updateCallRecord), object: objcallrecord , userInfo: nil)
        }
    }
    
    func openCallPage(type : String, roomid : String, id : String)
    {
        guard !isVideoViewPresented else{ return }
        
        if(type == "1")
        {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let objVC:VideoViewController = storyboard.instantiateViewController(withIdentifier: "VideoViewControllerID") as! VideoViewController
            objVC.isCalling = true
            objVC.roomName = roomid
            objVC.opponent_id = id
            objVC.view.tag = 1
            presentView(objVC.view)
        }
        else
        {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let objVC:AudioCallVC = storyboard.instantiateViewController(withIdentifier: "AudioCallVCID") as! AudioCallVC
            objVC.isCalling = true
            objVC.roomName = roomid
            objVC.opponent_id = id
            objVC.view.tag = 0
            presentView(objVC.view)
        }
    }
    
    func incomingCall(_ notify: Notification)
    {
        let CallRecord:Call_record = notify.object as! Call_record
        if CallRecord.reconnecting == "1" {
            self.isVideoViewPresented = false
        }

        if(!self.isVideoViewPresented)
        {
            call_record = CallRecord
            if(CallRecord.type == "1")
            {
                let state = UIApplication.shared.applicationState
                if state == .background {
                    iterationCount = 0
                    VideoCallWaitTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector:  #selector(self.MakeNotificaiton), userInfo: nil, repeats: true)
                }else{
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let objVC:VideoViewController = storyboard.instantiateViewController(withIdentifier: "VideoViewControllerID") as! VideoViewController
                    objVC.isCalling = false
                    objVC.roomName = CallRecord.roomid
                    objVC.opponent_id = CallRecord.from
                    objVC.objcallrecord = CallRecord
                    objVC.view.tag = 1
                    presentView(objVC.view)
                }
                
            }
            else if(CallRecord.type == "0")
            {
                self.isVideoViewPresented = true
                providerDelegate.objcallrecord = CallRecord
                providerDelegate.responseDict = nil
                let handle = Themes.sharedInstance.CheckNullvalue(Passed_value: CallRecord.ContactMsisdn)
                if CallRecord.reconnecting == "1" {
                    if providerDelegate.objVC != nil {
                        self.dismissView(providerDelegate?.objVC?.view ?? UIView())
                    }
                }
                providerDelegate.reportIncomingCall(uuid: UUID(), handle: handle, hasVideo: false, completion: nil)
                if CallRecord.reconnecting == "1" {
                    providerDelegate.callreconnect()
                }
            }
        }
    }
    
    func startCallRetry()
    {
        if(CallRetryTimer == nil)
        {
        CallRetryTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector:  #selector(self.CallRetryEmit), userInfo: nil, repeats: true)
        }
     }
    
    func RemoveCallRetry()
    {
        CallRetryTimer?.invalidate()
        CallRetryTimer = nil
    }
    
    @objc func CallRetryEmit()
    {
        SocketIOManager.sharedInstance.EmitCallRetry(param: callRetryDict as! [String : Any])
    }
    
    func moveTO_SWCC_Login() {
        
        let vc = LoginViewController.init()
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        navigationController = mainStoryBoard.instantiateViewController(withIdentifier: "RootNavControllerID") as? RootNavController
        navigationController?.navigationBar.isHidden = true
        navigationController?.viewControllers = [vc]
        var CheckLogin = false
        self.window?.rootViewController = navigationController
    }
    
    func MovetoRooVC()
    {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        navigationController = mainStoryBoard.instantiateViewController(withIdentifier: "RootNavControllerID") as? RootNavController
        navigationController?.navigationBar.isHidden = true
        var CheckLogin = false
        if(Themes.sharedInstance.Getuser_id() != "")
        {
            CheckLogin = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.User_detail, attribute: "user_id", FetchString: Themes.sharedInstance.Getuser_id())
        }
        if(CheckLogin)
        {
            let updateChecker : ATAppUpdater =  ATAppUpdater.sharedUpdater() as! ATAppUpdater
            updateChecker.delegate = self
            updateChecker.showUpdateWithForce()

            let name:String=Themes.sharedInstance.setNameTxt(Themes.sharedInstance.Getuser_id(), "")

            Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.photopath);
            Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.videopathpath);
            Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.docpath);
            Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.voicepath);
            Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.wallpaperpath)
            Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.statuspath);

            let user_dict:NSDictionary = ["current_call_status":Constant.sharedinstance.call_free,"call_id":""]
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail, FetchString: Themes.sharedInstance.Getuser_id(), attribute: "user_id", UpdationElements: user_dict)

            SDWebImageDownloader.shared().setValue(Themes.sharedInstance.getToken(), forHTTPHeaderField: "authorization")
            SDWebImageDownloader.shared().setValue(Themes.sharedInstance.Getuser_id(), forHTTPHeaderField: "userid")
            SDWebImageDownloader.shared().setValue("site", forHTTPHeaderField: "requesttype")
            SDWebImageDownloader.shared().setValue(ImgUrl, forHTTPHeaderField: "referer")

            if(name != "")
            {
                let signinVC = mainStoryBoard.instantiateViewController(withIdentifier: "HomeBaseViewController") as! HomeBaseViewController
                navigationController?.viewControllers = [signinVC]
                self.window!.rootViewController = navigationController
            }
            else
            {
                let signinVC = mainStoryBoard.instantiateViewController(withIdentifier: "ProfileInfoID") as! ProfileInfoViewController
                navigationController?.viewControllers = [signinVC]
                self.window!.rootViewController = navigationController
            }
        }
        else
        {
            //let signinVC = mainStoryBoard.instantiateViewController(withIdentifier: "LoginVCID") as! LoginVC
            let signinVC = LoginViewController.init()
            navigationController?.viewControllers = [signinVC]
            self.window!.rootViewController = navigationController
        }
    }
    
    func pushRegistrySetup() {
        let pushRegistry = PKPushRegistry(queue: DispatchQueue.main)
        pushRegistry.delegate = self
        pushRegistry.desiredPushTypes = [.voIP]
    }
    
    func pushnotificationSetup()
    {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
            // Enable or disable features based on authorization.
        }
        UIApplication.shared.registerForRemoteNotifications()
        setBadgeCount()
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        self.launchActivity(userActivity)
        return true
    }
    
    func launchActivity(_ userActivity : NSUserActivity)
    {
        let interaction: INInteraction? = userActivity.interaction
        if let startAudioCallIntent = interaction?.intent as? INStartAudioCallIntent {
            if((startAudioCallIntent.contacts?.count)! > 0)
            {
                let contact = startAudioCallIntent.contacts![0]
                let personHandle: INPersonHandle? = contact.personHandle
                let phoneNumber = Themes.sharedInstance.CheckNullvalue(Passed_value: personHandle?.value)
                print(phoneNumber)
                let id = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Favourite_Contact, attrib_name: "msisdn", fetchString: phoneNumber, returnStr: "id")
                if(id != "")
                {
                    if(!Themes.sharedInstance.checkBlock(id: id))
                    {
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
                            let docID = "\(Themes.sharedInstance.Getuser_id())-\(id)-\(timestamp)"
                            let param:NSDictionary = ["from":Themes.sharedInstance.Getuser_id(),"to":Themes.sharedInstance.CheckNullvalue(Passed_value: id),"type":0,"id":Int64(timestamp)!,"toDocId":docID, "roomid" : timestamp]
                            print("normal call sathishDict---->>>", param)
                            SocketIOManager.sharedInstance.emitCallDetail(Param: param as! [String : Any])
                            self.openCallPage(type: "0", roomid: timestamp, id: id)
                        }
                    }
                    else
                    {
                        Themes.sharedInstance.showBlockalert(id: id)
                    }
                }
                
                
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("PUshNotificationToken: \(token)")
        Themes.sharedInstance.saveDeviceToken(DeviceToken: token)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        print("i am not available in simulator \(error)")
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        self.openChatPage(userInfo as NSDictionary)
    }
    
    func setBadgeCount()
    {
        let count = Themes.sharedInstance.getUnreadChatCount(true)
        UIApplication.shared.applicationIconBadgeNumber = count
        let defaults = UserDefaults(suiteName: "group.com.2p.Engage")
        defaults?.set(count, forKey: "BadgeCount")
    }
    
    func ReachabilityListener()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged),name: ReachabilityChangedNotification, object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
        
    }
    @objc func reachabilityChanged(note: NSNotification) {
        
        let reachability = note.object as! Reachability
        if reachability.isReachable {
            IsInternetconnected=true
            Themes.sharedInstance.showWaitingNetwork(true, state: true)
            if reachability.isReachableViaWiFi {
                print("Reachable via WiFi")
                byreachable = "1"
            } else {
                print("Reachable via Cellular")
                byreachable = "2"
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.reconnectInternet), object: nil , userInfo: nil)
        } else {
            IsInternetconnected=false
            Themes.sharedInstance.showWaitingNetwork(true, state: false)
            print("Network not reachable")
            byreachable = ""
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: nil , userInfo: nil)
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game
        active = false
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        backgroundTask = UIApplication.shared.beginBackgroundTask(expirationHandler:{
            UIApplication.shared.setMinimumBackgroundFetchInterval(1800)
        })
        
        assert(backgroundTask != UIBackgroundTaskIdentifier.invalid)
        if Themes.sharedInstance.Getuser_id() != "" {
            SocketIOManager.sharedInstance.online(from: Themes.sharedInstance.Getuser_id(), status: "0")
        }
        self.setBadgeCount()
    }
    
    func endBackgroundTask() {
        print("Background task ended.")
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskIdentifier.invalid
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        // To remove all pending notifications which are not delivered yet but scheduled.
        center.removeAllDeliveredNotifications()
        self.endBackgroundTask()
        self.setBadgeCount()
        // To remove all delivered notifications
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        player?.stop()
        let state = UIApplication.shared.applicationState
        if(state == .active)
        {
            if Themes.sharedInstance.Getuser_id() != "" {
                SocketIOManager.sharedInstance.online(from: Themes.sharedInstance.Getuser_id(), status: "1")
            }
        }
        let CheckLogin:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.User_detail, attribute: "user_id", FetchString: nil)
        if(CheckLogin)
        {
            active = true

            let CheckLogin:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.User_detail, attribute: "user_id", FetchString: nil)
            if(CheckLogin)
            {
                let updateChecker : ATAppUpdater =  ATAppUpdater.sharedUpdater() as! ATAppUpdater
                updateChecker.delegate = self
                updateChecker.showUpdateWithForce()
                
                self.perform(#selector(self.IntitialiseSocket), with: self, afterDelay: 1.0)
                ChatBackUpHandler.sharedInstance.AutoBackUp()
                if(VideoCallWaitTimer != nil)
                {
                    let ObjCallRecord = call_record
                    VideoCallWaitTimer?.invalidate()
                    VideoCallWaitTimer = nil
                    iterationCount = 0
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.incomingcall), object: ObjCallRecord, userInfo: nil)
                }
            }
            else
            {
                SocketIOManager.sharedInstance.socket.removeAllHandlers()
                SocketIOManager.sharedInstance.socket.disconnect()
                SecretmessageHandler.sharedInstance.stoptimer()
            }
        }
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests() // To remove all pending notifications which are not delivered yet but scheduled.
        center.removeAllDeliveredNotifications() // To remove all delivered notifications
        
    }
    
    @objc func IntitialiseSocket()
    {
       
        if(SocketIOManager.sharedInstance.socket.status == .disconnected || SocketIOManager.sharedInstance.socket.status == .notConnected)
        {
            if(IsInternetconnected)
            {
                SocketIOManager.sharedInstance.establishConnection(Nickname: Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id()) as NSString, isLogin: true)
                
            }
        }
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        DispatchQueue.global(qos: .background).async {
            if(self.isVideoViewPresented == true) {
                SocketIOManager.sharedInstance.online(from: Themes.sharedInstance.Getuser_id(), status: "0")
                SocketIOManager.sharedInstance.user_offline_in_call(from: Themes.sharedInstance.Getuser_id(), status: "0")
            }
            SocketIOManager.sharedInstance.RemoveRoom(providerid: Themes.sharedInstance.Getuser_id())
        }
    }
    
    func displayIncomingCall(uuid: UUID, handle: String, hasVideo: Bool = false, completion: ((NSError?) -> Void)?) {
        providerDelegate.reportIncomingCall(uuid: uuid, handle: handle, hasVideo: hasVideo, completion: completion)
    }
    
    func dismissView(_ view : UIView) {
        self.window?.endEditing(true)
        isVideoViewPresented = false
        view.alpha = 1.0
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut, animations: {
            view.alpha = 0.0
            view.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
        }) { success in
            view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            view.removeFromSuperview()
        }
    }
    
    func presentView(_ view : UIView) {
        self.window?.endEditing(true)
        isVideoViewPresented = true
        view.frame = UIScreen.main.bounds
        if reconnecting == true {
            self.window?.addSubview(view)
        } else {
            view.alpha = 0.0
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
                view.alpha = 1.0
                self.window?.addSubview(view)
            }) { success in
            }
        }
    }
    
}

extension AppDelegate{
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.notification.request.identifier == "VideoCallRequest"{
            player?.stop()
            print(CallDetailresponseDict)
            if(CallDetailresponseDict.count > 0)
            {
                let ObjCallRecord = Callhandler.sharedInstance.ReturnCallRecord(responseDict: CallDetailresponseDict)
                call_record = ObjCallRecord!
            }
            VideoCallWaitTimer?.invalidate()
            VideoCallWaitTimer = nil
            iterationCount = 0
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.incomingcall), object: self.call_record, userInfo: nil)
        }else if response.notification.request.identifier.contains("chat_request") {
            self.openChatPage(self.notification_dict)
        }
        print("Tapped in notification")
    }
    
    //This is key callback to present notification while the app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Notification being triggered")
        //You can either present alert ,sound or increase badge while the app is in foreground too with ios 10
        //to distinguish between notifications
        if notification.request.identifier == "VideoCallRequest"{
            
            completionHandler( [.alert,.sound,.badge])
            
        }
    }
}

extension AppDelegate : ATAppUpdaterDelegate
{
    func appUpdaterDidShowUpdateDialog()
    {
        
    }
    func appUpdaterUserDidLaunchAppStore()
    {
        
    }
    func appUpdaterUserDidCancel()
    {
        
    }
}



