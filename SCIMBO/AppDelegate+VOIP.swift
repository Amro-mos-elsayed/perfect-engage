//
//  AppDelegate+VOIP.swift
//  Raad
//
//  Created by Ahmed Labeeb on 8/16/21.
//  Copyright © 2021 CASPERON. All rights reserved.
//

import Foundation
import PushKit
import CallKit

extension AppDelegate: PKPushRegistryDelegate {
    
    func pushRegistrySetup() {
        let pushRegistry = PKPushRegistry(queue: DispatchQueue.main)
        pushRegistry.delegate = self
        pushRegistry.desiredPushTypes = [.voIP]
    }
    
    // MARK: - PKPushRegistryDelegate
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
        
        let token = credentials.token.reduce("", {$0 + String(format: "%02X", $1)})
        print("callToken: \(token)")
        Themes.sharedInstance.saveCallToken(DeviceToken: token)
    }
    
    
    func fakeCall() {
        let config = CXProviderConfiguration(localizedName: "My App")
        config.iconTemplateImageData = #imageLiteral(resourceName: "gallery_ic").pngData()
        config.ringtoneSound = "tone.mp3"
        config.includesCallsInRecents = false;
        config.supportsVideo = true;
        let provider = CXProvider(configuration: config)
        provider.setDelegate(self.providerDelegate, queue: nil)
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: "Unknown Number")
        update.hasVideo = false
        provider.reportNewIncomingCall(with: UUID(), update: update, completion: { error in })
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        #if DEBUG
        //fakeCall()
        #endif
        print(payload.dictionaryPayload)
        let strany = payload.dictionaryPayload as! [String: Any]
        guard let payloadObject = parsedPayloadObject(payload: strany) else {
            return
        }
        configProviderDelegate(payloadObject: payloadObject)
        // -----------------
        let uuid = UUID()
        let provider = providerDelegate.provider
        provider.setDelegate(self.providerDelegate, queue: nil)
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .phoneNumber, value: payloadObject.sendername ?? "unknown number")
        update.hasVideo = false
        let remoteName = payloadObject.sendername ?? "unknown number".localized()
        providerDelegate.reportIncomingCall(uuid: uuid, handle: remoteName) { error in
            
        }
        //return if its not of type .voIP
        guard type == .voIP   else { return }
        responseDict = payload.dictionaryPayload as NSDictionary
        print("Voic",responseDict)
        let NType:String = Themes.sharedInstance.CheckNullvalue(Passed_value: responseDict.object(forKey: "notification_type"))
        if(NType == "1")
        {
            if(SocketIOManager.sharedInstance.socket.status == .disconnected || SocketIOManager.sharedInstance.socket.status == .notConnected){
                IntitialiseSocket()
            }
        }
        else
        {
            if(SocketIOManager.sharedInstance.socket.status == .disconnected || SocketIOManager.sharedInstance.socket.status == .notConnected){
                IntitialiseSocket()
            }
            else
            {
                SocketIOManager.sharedInstance.EmitGetCallStatus(param: responseDict as! [String : Any])
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            completion()
        }
    }
    
    func videoCall(roomid: String, from: String, callRecord: Call_record){
        let state = UIApplication.shared.applicationState
        if state == .background {
            iterationCount = 0
            VideoCallWaitTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector:  #selector(self.MakeNotificaiton), userInfo: nil, repeats: true)
        }else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let objVC:VideoViewController = storyboard.instantiateViewController(withIdentifier: "VideoViewControllerID") as! VideoViewController
            objVC.isCalling = false
            objVC.roomName = roomid
            objVC.opponent_id = from
            objVC.objcallrecord = callRecord
            objVC.view.tag = 1
            presentView(objVC.view)
        }
        
    }
    
    func configProviderDelegate(payloadObject: PayloadForNotification) {
        let callRecord = Call_record.init()
        
        callRecord.msgId = "\(payloadObject.msgID ?? 0)"
        callRecord.ContactMsisdn = payloadObject.contactMsisdn ?? ""
        callRecord.From_avatar = payloadObject.fromAvatar ?? ""
        callRecord.To_avatar = payloadObject.toAvatar ?? ""
        callRecord.To_msisdn = payloadObject.toMsisdn ?? ""
        callRecord.call_status = payloadObject.callStatus ?? ""
        callRecord.doc_id = payloadObject.docID ?? ""
        callRecord.from = payloadObject.from ?? ""
        callRecord.id = "\(payloadObject.id ?? 0)"
        callRecord.recordId = payloadObject.recordID ?? ""
        callRecord.type = payloadObject.type ?? ""
        callRecord.to = payloadObject.to ?? ""
        callRecord.timestamp = "\(payloadObject.timestamp ?? 0)"
        callRecord.from_device_type = payloadObject.fromDeviceType ?? ""
        callRecord.to_device_type = payloadObject.toDeviceType ?? ""
        //callRecord.user_busy = payloadObject.user ?? ""
        callRecord.roomid = payloadObject.roomid ?? ""
        callRecord.reconnecting = payloadObject.reconnecting ? "1" : "0"
        
        providerDelegate.objcallrecord = callRecord
    }
    
    func parsedPayloadObject(payload: [String : Any]) -> PayloadForNotification? {
        let data = try! JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted)
        
        let decoder = JSONDecoder()
        do {
            let customer = try decoder.decode(PayloadForNotification.self, from: data)
            return customer
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}

class PayloadForNotification: Codable {
    var roomid, type: String?
    var id, msgID: Int?
    var from, docID, filesize: String?
    var timestamp: Int?
    var sendername, messageType, callStatus, status: String?
    var to, recordID, contactMsisdn, duration: String?
    var fromAvatar, toAvatar: String?
    var toMsisdn, toDeviceType: String?
    var phoneConnected: Int?
    var fromDeviceType: String?
    var reconnecting: Bool
    var notificationType, message, action: String?
    
    func initFrom(dic: NSDictionary) {
        roomid = dic["roomid"] as? String
        sendername = dic["sendername"] as? String
        id = dic["id"] as? Int
        from = dic["from"] as? String
        
        
    }

    enum CodingKeys: String, CodingKey {
        case roomid, type, id
        case msgID = "msgId"
        case from
        case docID = "doc_id"
        case filesize, timestamp, sendername
        case messageType = "message_type"
        case callStatus = "call_status"
        case status, to
        case recordID = "recordId"
        case contactMsisdn = "ContactMsisdn"
        case duration
        case fromAvatar = "From_avatar"
        case toAvatar = "To_avatar"
        case toMsisdn = "To_msisdn"
        case toDeviceType = "to_device_type"
        case phoneConnected
        case fromDeviceType = "from_device_type"
        case reconnecting
        case notificationType = "notification_type"
        case message, action
    }
}

// ------------------

extension Dictionary {
    
    /// Convert Dictionary to JSON string
    /// - Throws: exception if dictionary cannot be converted to JSON data or when data cannot be converted to UTF8 string
    /// - Returns: JSON string
    func toJson() throws -> String {
        let data = try JSONSerialization.data(withJSONObject: self)
        if let string = String(data: data, encoding: .utf8) {
            return string
        }
        throw NSError(domain: "Dictionary", code: 1, userInfo: ["message": "Data cannot be converted to .utf8 string"])
    }
}
