/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import CallKit
import AVFoundation

@available(iOS 10.0, *)

class ProviderDelegate: NSObject, SocketIOManagerDelegate {
    
    let callManager: CallManager
    let provider: CXProvider
    var Incoming: Bool = false
    var responseDict : NSDictionary?
    var objcallrecord : Call_record?
    var objVC : AudioCallVC? = nil
    var CallerName : String?
    var uuid = UUID()
    
    init(callManager: CallManager) {
        self.callManager = callManager
        provider = CXProvider(configuration: type(of: self).providerConfiguration)
        
        super.init()
        addNotificationListener()
        SocketIOManager.sharedInstance.Delegate = self
        
        provider.setDelegate(self, queue: nil)
    }
    
    static var providerConfiguration: CXProviderConfiguration {
        let localizedName = NSLocalizedString(Themes.sharedInstance.GetAppname(), comment: "Name of application")
        let providerConfiguration = CXProviderConfiguration(localizedName: localizedName)
        
        providerConfiguration.supportsVideo = false
        
        providerConfiguration.maximumCallsPerCallGroup = 1
        
        providerConfiguration.supportedHandleTypes = [.phoneNumber]
        
        providerConfiguration.iconTemplateImageData = #imageLiteral(resourceName: "logo").pngData()
        
        providerConfiguration.ringtoneSound = "tone.mp3"
        
        return providerConfiguration
    }
    
    func reportIncomingCall(uuid: UUID, handle: String, hasVideo: Bool = false, completion: ((NSError?) -> Void)?) {
        if objcallrecord?.reconnecting == "0" {
            let update = CXCallUpdate()
            CallerName = handle
            update.remoteHandle = CXHandle.init(type: .generic, value: handle)
            update.hasVideo = objcallrecord?.type != "0"
            
            provider.reportNewIncomingCall(with: uuid, update: update) { error in
                if error == nil {
                    self.uuid = uuid
                    let call = Call(uuid: uuid, handle: handle)
                    //self.callManager.removeAllCalls()
                    self.callManager.add(call: call)
                }
                
                completion?(error as NSError?)
            }
        }
    }
    
    func addNotificationListener() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.online_status_in_call), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            if(AppDelegate.sharedInstance.callManager.calls.count > 0)
            {
                if((notify.userInfo!["id"] as! String) != Themes.sharedInstance.Getuser_id() && ((notify.userInfo!["id"] as! String) == weak.objcallrecord?.from || (notify.userInfo!["id"] as! String) == weak.objcallrecord?.to) && (notify.userInfo!["is_online"] as! String) == "0")
                {
                    weak.EndCall(true)
                }
            }
        }
    }
    
    func removeNotificationListener() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func callreconnect() {
        configureAudioSession()
        answerCall()
        guard let call = callManager.callWithUUID(uuid: self.uuid) else {
            return
        }
        call.answer()
    }
    
    deinit {
        removeNotificationListener()
    }
}


// MARK: - CXProviderDelegate

extension ProviderDelegate: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        stopAudio()
        
        for call in callManager.calls {
            call.end()
        }
        
        callManager.removeAllCalls()
    }
    
    func  audioAccessPermission() -> Bool
    {
        switch AVAudioSession.sharedInstance().recordPermission
        {
        case .granted:
            return false;
        case .denied:
            return true;
        case .undetermined:
            return false;
        }
    }
    
    func needsAudioPermission() -> Bool {
        
        if audioAccessPermission() {
            var rootViewController = UIApplication.shared.delegate?.window??.rootViewController
            
            if let rootvc = rootViewController as? UINavigationController {
                rootViewController = rootvc.viewControllers.first
            }
            if let rootvc = rootViewController as? UITabBarController {
                rootViewController = rootvc.selectedViewController
            }
            
            let alert = Themes.sharedInstance.showAudioPermissionAlert
            rootViewController?.present(alert, animated: true)
            return true
        }
        return false
    }
    
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        
        if needsAudioPermission(){
            return
        }
        
        configureAudioSession()
        
        answerCall()
        let isOpencall: [String:Bool] = ["isOpencall": true]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.isOpenCall), object: objcallrecord , userInfo: isOpencall)
        guard let call = callManager.callWithUUID(uuid: action.callUUID) else {
            action.fail()
            return
        }
        
        call.answer()
        action.fulfill()
    }
    
    func answerCall()
    {
        if(objcallrecord == nil && responseDict != nil && responseDict?.count != 0)
        {
            objcallrecord = Call_record()
            objcallrecord?.ContactMsisdn = Themes.sharedInstance.CheckNullvalue(Passed_value: (responseDict?.object(forKey: "ContactMsisdn"))!)
            objcallrecord?.From_avatar = Themes.sharedInstance.CheckNullvalue(Passed_value: (responseDict?.object(forKey: "From_avatar"))!)
            objcallrecord?.To_avatar = Themes.sharedInstance.CheckNullvalue(Passed_value: (responseDict?.object(forKey: "To_avatar"))!)
            objcallrecord?.To_msisdn = Themes.sharedInstance.CheckNullvalue(Passed_value: (responseDict?.object(forKey: "To_msisdn"))!)
            objcallrecord?.call_status = Themes.sharedInstance.CheckNullvalue(Passed_value: (responseDict?.object(forKey: "call_status"))!)
            objcallrecord?.doc_id = Themes.sharedInstance.CheckNullvalue(Passed_value: (responseDict?.object(forKey: "doc_id"))!)
            objcallrecord?.from = Themes.sharedInstance.CheckNullvalue(Passed_value: (responseDict?.object(forKey: "from"))!)
            objcallrecord?.id = Themes.sharedInstance.CheckNullvalue(Passed_value: (responseDict?.object(forKey: "id"))!)
            objcallrecord?.msgId = Themes.sharedInstance.CheckNullvalue(Passed_value: (responseDict?.object(forKey: "msgId"))!)
            objcallrecord?.recordId = Themes.sharedInstance.CheckNullvalue(Passed_value: (responseDict?.object(forKey: "recordId"))!)
            objcallrecord?.type = Themes.sharedInstance.CheckNullvalue(Passed_value: (responseDict?.object(forKey: "type"))!)
            objcallrecord?.roomid = Themes.sharedInstance.CheckNullvalue(Passed_value: (responseDict?.object(forKey: "roomid"))!)
        }
        if(objcallrecord != nil)
        {
            if objcallrecord?.type == "0"{
                let vc = AppDelegate.sharedInstance.window?.rootViewController
                objVC = vc?.storyboard?.instantiateViewController(withIdentifier: "AudioCallVCID") as? AudioCallVC
                objVC?.isCalling = false
                objVC?.roomName = (objcallrecord?.roomid)!
                objVC?.isAttendedIncoming = true
                objVC?.objcallrecord = objcallrecord!
                objVC?.opponent_id = (objcallrecord?.from)!
                objVC?.view.tag = 0
                AppDelegate.sharedInstance.presentView((objVC?.view)!)
            }else {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.videoCall(roomid: (objcallrecord?.roomid)!, from: (objcallrecord?.from)!, callRecord: objcallrecord!)
            }
            
        }
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        EndCall(false)
        
        guard let call = callManager.callWithUUID(uuid: action.callUUID) else {
            action.fail()
            return
        }
        
        stopAudio()
        call.end()
        action.fulfill()
        callManager.remove(call: call)
    }
    
    func EndCall(_ from_user_online : Bool)
    {
        if(AppDelegate.sharedInstance.isVideoViewPresented)
        {
            if(objcallrecord == nil && responseDict != nil && responseDict?.count != 0)
            {
                objcallrecord = Call_record()
                objcallrecord?.ContactMsisdn = Themes.sharedInstance.CheckNullvalue(Passed_value: (responseDict?.object(forKey: "ContactMsisdn"))!)
                objcallrecord?.From_avatar = Themes.sharedInstance.CheckNullvalue(Passed_value: (responseDict?.object(forKey: "From_avatar"))!)
                objcallrecord?.To_avatar = Themes.sharedInstance.CheckNullvalue(Passed_value: (responseDict?.object(forKey: "To_avatar"))!)
                objcallrecord?.To_msisdn = Themes.sharedInstance.CheckNullvalue(Passed_value: (responseDict?.object(forKey: "To_msisdn"))!)
                objcallrecord?.call_status = Themes.sharedInstance.CheckNullvalue(Passed_value: (responseDict?.object(forKey: "call_status"))!)
                objcallrecord?.doc_id = Themes.sharedInstance.CheckNullvalue(Passed_value: (responseDict?.object(forKey: "doc_id"))!)
                objcallrecord?.from = Themes.sharedInstance.CheckNullvalue(Passed_value: (responseDict?.object(forKey: "from"))!)
                objcallrecord?.id = Themes.sharedInstance.CheckNullvalue(Passed_value: (responseDict?.object(forKey: "id"))!)
                objcallrecord?.msgId = Themes.sharedInstance.CheckNullvalue(Passed_value: (responseDict?.object(forKey: "msgId"))!)
                objcallrecord?.recordId = Themes.sharedInstance.CheckNullvalue(Passed_value: (responseDict?.object(forKey: "recordId"))!)
                objcallrecord?.type = Themes.sharedInstance.CheckNullvalue(Passed_value: (responseDict?.object(forKey: "type"))!)
            }
            if(objcallrecord != nil)
            {
                if(objVC == nil)
                {
                    let vc = AppDelegate.sharedInstance.window?.rootViewController
                    objVC = vc?.storyboard?.instantiateViewController(withIdentifier: "AudioCallVCID") as? AudioCallVC
                }
                objVC?.objcallrecord = objcallrecord!
                if(from_user_online) {
                    objVC?.call_status.text = "User in Offline"
                }
                objVC?.isDeclinedByMe = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                    self.objVC?.RejectIncomingCall(false)
                })
                AppDelegate.sharedInstance.isVideoViewPresented = false
            }
        }
    }
    
    
    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        guard let call = callManager.callWithUUID(uuid: action.callUUID) else {
            action.fail()
            return
        }
        
        call.state = action.isOnHold ? .held : .active
        
        if call.state == .held {
            stopAudio()
        } else {
            startAudio()
        }
        
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        let call = Call(uuid: action.callUUID, outgoing: true, handle: action.handle.value)
        
        call.connectedStateChanged = { [weak self] in
            guard let strongSelf = self else { return }
            
            if case .pending = call.connectedState {
                strongSelf.provider.reportOutgoingCall(with: call.uuid, startedConnectingAt: nil)
            } else if case .complete = call.connectedState {
                strongSelf.provider.reportOutgoingCall(with: call.uuid, connectedAt: nil)
            }
        }
        
        call.start { [weak self] success in
            guard let strongSelf = self else { return }
            
            if success {
                action.fulfill()
                strongSelf.callManager.add(call: call)
            } else {
                action.fail()
            }
        }
    }
    
    
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        startAudio()
    }
}
