//
//  AudioCallVC.swift
//
//
//  Created by MV Anand Casp iOS on 27/09/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit
import WebRTC
import CallKit

class AudioCallVC: UIViewController, ARDAppClientDelegate, RTCEAGLVideoViewDelegate {
    var player : AVAudioPlayer?
    var isMinimize : Bool = Bool()
    weak var timer:Timer?
    weak var reconnecttimer:Timer?

    @IBOutlet weak var user_image: UIImageView!
    @IBOutlet weak var accept_view: UIView!
    @IBOutlet weak var hangupButton: UIButton!
    @IBOutlet weak var audioButton: UIButton!
    @IBOutlet weak var buttonContainerView: UIView!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var minimizeView: UIView!
    @IBOutlet weak var user_image1: UIImageView!

    @IBOutlet weak var user_Lbl: UILabel!
    
    @IBOutlet weak var call_status: UILabel!
    
    var callManager: CallManager!
    var loud_speaker:Bool = false
    var isCalling:Bool = Bool()
//    var reconnecting: Bool = false

    var isAttendedIncoming : Bool = Bool()
    var ConnectWaitTimer:Timer?
    
    
    @IBOutlet weak var loudspeaker: UIButton!
//    var seconds:Double = Double()
    
    var opponent_id:String = String()    
    var roomUrl = ""
    var roomName = "bzzhj21sad"
    var client: ARDAppClient?
    
    var isZoom = false
    var isAudioMute = false
    var isVideoMute = false
    var Doc_id:String = String()
    var from_avatar : String = String()
    var to_avatar : String = String()
    var objcallrecord:Call_record = Call_record()
    var captureController:ARDCaptureController = ARDCaptureController()
    var isAttenCall:Bool = Bool()
    var isDeclinedByMe:Bool = Bool()
    var CallWaitTimer:Timer?
    var isCallConnected:Bool = Bool()
    
    var touchStart: CGPoint = CGPoint.zero
    var isDragging = false

    //used for double tap remote view
    override func viewDidLoad()
    {
        super.viewDidLoad()
        AppDelegate.sharedInstance.isVideoViewPresented = true
        AppDelegate.sharedInstance.callDelegate = self
        addNotificationListener()
        isMinimize = false
        isAttenCall = false
        isZoom = false
        isAudioMute = false
        isVideoMute = false
        loud_speaker = false
        loudspeaker.setImage(UIImage(named: "noloudspeaker"), for: .normal)
        DispatchQueue.main.async {
            self.client?.configureAVAudioSession(true)
        }
        user_image.setProfilePic(opponent_id, "single")
        user_image1.setProfilePic(opponent_id, "single")
        if(isCalling)
        {
            //self.hangupButton.isEnabled = false
        }
        if CallWaitTimer != nil {
            CallWaitTimer?.invalidate()
            CallWaitTimer = nil
        }
        CallWaitTimer = Timer.scheduledTimer(timeInterval: TimeInterval(Constant.sharedinstance.CallWaitTime), target: self, selector:  #selector(self.CheckCallStatus), userInfo: nil, repeats: false)
        if reconnecting == true {
//            self.hangupButton.isEnabled = true
            call_status.text = "Reconnecting..."
        }
    }
        
    func GetCallStatus(_ notify:NSDictionary)
    {
        let Dict:NSDictionary = notify
        if(Dict.count > 0)
        {
            let recordId:String = Themes.sharedInstance.CheckNullvalue(Passed_value: Dict.object(forKey: "recordId"))
            let callstatus:String = Themes.sharedInstance.CheckNullvalue(Passed_value: Dict.object(forKey: "call_status"))
            if(recordId == objcallrecord.recordId)
            {
                if(callstatus == "\(Constant.sharedinstance.call_status_END)")
                {
                    print("call_status_END")
                    self.disconnect()
                    if reconnecting == false {
                        call_status.text = "Call Ended"
                    }
                    clearCalls()
                    timer?.invalidate()
                    timer = nil
                    DispatchQueue.main.asyncAfter(deadline: .now()+2.0) {
                        if reconnecting == false {
                            AppDelegate.sharedInstance.dismissView(self.view)
                        }
                    }
                }
                else if( callstatus == "\(Constant.sharedinstance.call_status_MISSED)")
                {
                    self.disconnect()
                    call_status.text = "Call Missed"
                    clearCalls()
                    timer?.invalidate()
                    timer = nil
                    DispatchQueue.main.asyncAfter(deadline: .now()+2.0) {
                        if reconnecting == false {
                            AppDelegate.sharedInstance.dismissView(self.view)
                        }
                    }
                }
                else if( callstatus == "\(Constant.sharedinstance.call_status_REJECTED)")
                {
                    self.disconnect()
                    call_status.text = "Call Rejected"
                    clearCalls()
                    timer?.invalidate()
                    timer = nil
                    DispatchQueue.main.asyncAfter(deadline: .now()+2.0) {
                        if reconnecting == false {
                            AppDelegate.sharedInstance.dismissView(self.view)
                        }
                    }
                }
                else if( callstatus == "\(Constant.sharedinstance.call_status_RECEIVED)")
                {
                    self.disconnect()
                    call_status.text = "Call Declined"
                    clearCalls()
                    timer?.invalidate()
                    timer = nil
                    DispatchQueue.main.asyncAfter(deadline: .now()+2.0) {
                        if reconnecting == false {
                            AppDelegate.sharedInstance.dismissView(self.view)
                        }
                    }
                }
                
            }
        }
        
    }
    
    @objc func updateTimerLabel()
    {
        if(AppDelegate.sharedInstance.IsInternetconnected && SocketIOManager.sharedInstance.socket.status == .connected && reconnecting == false) {
            Themes.sharedInstance.hmsFrom(seconds: Int(seconds)) { hours, minutes, seconds in
                
                let hours = Themes.sharedInstance.getStringFrom(seconds: hours)
                let minutes = Themes.sharedInstance.getStringFrom(seconds: minutes)
                let seconds = Themes.sharedInstance.getStringFrom(seconds: seconds)
                
                var finalstr = ""
                if(hours != "00") {
                    finalstr.append("\(hours):")
                }
                finalstr.append("\(minutes):")
                finalstr.append("\(seconds)")
                
                print(finalstr)
                self.call_status.text = finalstr
            }
            seconds += 1
        } else {
            call_status.text = "Reconnecting..."
        }
    }
    
    @IBAction func did_click_loudspeaker(_ sender: UIButton) {
        if(loud_speaker == false){
            loudspeaker.setImage(UIImage(named: "loudspeaker"), for: .normal)
            //            DispatchQueue.main.async {
            self.client?.configureAVAudioSession(false)
            //            }
            loud_speaker = true
        }else{
            loudspeaker.setImage(UIImage(named: "noloudspeaker"), for: .normal)
            //            DispatchQueue.main.async {
            self.client?.configureAVAudioSession(true)
            //            }
            loud_speaker = false
        }
    }
    
    func PlayAudio(tone: String, type: String)
    {
        let session = AVAudioSession.sharedInstance()
         try? session.setActive(true)
        try? session.setCategory(AVAudioSession.Category.playAndRecord, mode: isCalling ? AVAudioSession.Mode.voiceChat : AVAudioSession.Mode.videoChat, options: .duckOthers)
        try? session.setCategory(AVAudioSession.Category.playAndRecord)
        if(isCalling)
        {
            try? session.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
        }
        else{
            try? session.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        }
       
        
        let path = Bundle.main.path(forResource: tone, ofType:type)!
        let url = URL(fileURLWithPath: path)
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1
            player?.prepareToPlay()
            player?.volume = 10.0
            player?.play()
        } catch
        {
            print("error loading file")
            // couldn't load file :(
        }
        
    }
    
    @objc func CheckCallStatus()
    {
        
        CallWaitTimer?.invalidate()
        CallWaitTimer = nil
        
        let CheckCall_Detail = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Call_detail, attribute: "doc_id", FetchString: objcallrecord.doc_id)
        if(CheckCall_Detail)
        {
            let _call_status = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Call_detail, attrib_name: "doc_id", fetchString: objcallrecord.doc_id, returnStr: "call_status")
            var to_userID:String = String()
            if(Themes.sharedInstance.Getuser_id() != objcallrecord.from)
            {
                to_userID = objcallrecord.from
            }
            else
            {
                to_userID = objcallrecord.to
            }
            if to_userID == "" {
                to_userID = opponent_id
            }
            if(Int(_call_status)! < 3)
            {
                if(isCalling)
                {
                    let CallStatusDict:NSDictionary = ["from":Themes.sharedInstance.Getuser_id(),"to":to_userID,"call_status":Constant.sharedinstance.call_status_MISSED,"toDocId":objcallrecord.doc_id,"id":objcallrecord.msgId,"recordId":objcallrecord.recordId]
                    SocketIOManager.sharedInstance.EmitCallStatus(ResponseDict: CallStatusDict)
                    let DBDict:NSDictionary = ["call_status":Constant.sharedinstance.call_status_MISSED, "recordId" : objcallrecord.recordId, "duration" : "\(seconds)"]
                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Call_detail, FetchString: objcallrecord.doc_id, attribute: "doc_id", UpdationElements: DBDict)
                }
                if reconnecting == false {
                    call_status.text = "Call Ended"
                }
                self.disconnect()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    if reconnecting == false {
                        AppDelegate.sharedInstance.dismissView(self.view)
                    }
                })
            }
        }
        else
        {
            self.disconnect()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                if reconnecting == false {
                    AppDelegate.sharedInstance.dismissView(self.view)
                }
            })
        }
    }
    
    func AcceptCallStatus()
    {
        var to_userID:String = String()
        
        if(Themes.sharedInstance.Getuser_id() != objcallrecord.from)
        {
            to_userID = objcallrecord.from
        }
        else
        {
            to_userID = objcallrecord.to
        }
        if to_userID == "" {
            to_userID = opponent_id
        }
        if(!isCalling)
        {
            
            let CallStatusDict:NSDictionary = ["from":Themes.sharedInstance.Getuser_id(),"to":to_userID,"call_status":Constant.sharedinstance.call_status_ANSWERED,"toDocId":objcallrecord.doc_id,"id":objcallrecord.msgId,"recordId":objcallrecord.recordId]
            SocketIOManager.sharedInstance.EmitCallStatus(ResponseDict: CallStatusDict)
            let DBDict:NSDictionary = ["call_status":Constant.sharedinstance.call_status_ANSWERED, "recordId" : objcallrecord.recordId, "duration" : "\(seconds)"]
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Call_detail, FetchString: objcallrecord.doc_id, attribute: "doc_id", UpdationElements: DBDict)
            
        }
        
    }
    
    func DeclineVideoCallstaus()
    {
        if(isDeclinedByMe)
        {
            var to_userID:String = String()
            if(Themes.sharedInstance.Getuser_id() != objcallrecord.from)
            {
                to_userID = objcallrecord.from
            }
            else
            {
                to_userID = objcallrecord.to
            }
            if to_userID == "" {
                to_userID = opponent_id
            }
            print("currentId =>\(Themes.sharedInstance.Getuser_id())")
            print("to_userID =>\(to_userID)")
            print("opponent_id =>\(opponent_id)")
            if(isAttenCall)
            {
                print("ATTEND INNER")
                let CallStatusDict:NSDictionary = ["from":Themes.sharedInstance.Getuser_id(),"to":to_userID,"call_status":Constant.sharedinstance.call_status_END,"toDocId":objcallrecord.doc_id,"id":objcallrecord.msgId,"recordId":objcallrecord.recordId,"call_duration":call_status.text!]
                print("CallStatusDict =>\(CallStatusDict)")
                SocketIOManager.sharedInstance.EmitCallStatus(ResponseDict: CallStatusDict)
                let DBDict:NSDictionary = ["call_status":Constant.sharedinstance.call_status_END, "recordId" : objcallrecord.recordId, "duration" : "\(seconds)"]
                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Call_detail, FetchString: objcallrecord.doc_id, attribute: "doc_id", UpdationElements: DBDict)
            }
            else
            {
                if(isCalling)
                {
                    let CallStatusDict:NSDictionary = ["from":Themes.sharedInstance.Getuser_id(),"to":to_userID,"call_status":Constant.sharedinstance.call_status_REJECTED,"toDocId":objcallrecord.doc_id,"id":objcallrecord.msgId,"recordId":objcallrecord.recordId,"call_duration":call_status.text!]
                    SocketIOManager.sharedInstance.EmitCallStatus(ResponseDict: CallStatusDict)
                    let DBDict:NSDictionary = ["call_status":Constant.sharedinstance.call_status_REJECTED, "recordId" : objcallrecord.recordId, "duration" : "\(seconds)"]
                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Call_detail, FetchString: objcallrecord.doc_id, attribute: "doc_id", UpdationElements: DBDict)
                }
                else
                {
                    let CallStatusDict:NSDictionary = ["from":Themes.sharedInstance.Getuser_id(),"to":to_userID,"call_status":Constant.sharedinstance.call_status_RECEIVED,"toDocId":objcallrecord.doc_id,"id":objcallrecord.msgId,"recordId":objcallrecord.recordId,"call_duration":"00:00"]
                    SocketIOManager.sharedInstance.EmitCallStatus(ResponseDict: CallStatusDict)
                    let DBDict:NSDictionary = ["call_status":Constant.sharedinstance.call_status_REJECTED, "recordId" : objcallrecord.recordId, "duration" : "\(seconds)"]
                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Call_detail, FetchString: objcallrecord.doc_id, attribute: "doc_id", UpdationElements: DBDict)
                    
                }
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        UIDevice.current.isProximityMonitoringEnabled = true
        isCallConnected = false
        if(isCalling)
        {
            makeOutgoingCall(roomName: self.roomName)
        }
        else
        {
            call_status.text = "Incoming Call..."
            buttonContainerView.isHidden = true
            accept_view.isHidden = false
            user_Lbl.setNameTxt(opponent_id, "single")
            let user_dict:NSDictionary = ["current_call_status":Constant.sharedinstance.call_in_waiting,"call_id":""]
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail, FetchString: Themes.sharedInstance.Getuser_id(), attribute: "user_id", UpdationElements: user_dict)
            if(self.isAttendedIncoming)
            {
                self.AcceptIncomingCall(roomName: self.roomName)
            }
            else
            {
                self.RejectIncomingCall(false)
            }
        }
    }
    
    func makeOutgoingCall(roomName : String)
    {
        client = ARDAppClient(delegate: self)
        client?.delegate = self
        let settingsModel = ARDSettingsModel()
        //        client?.toggleVideoMute()
        client!.connectToRoom(withId: roomName as String?, settings: settingsModel, isLoopback: false, isAudioOnly: true, shouldMakeAecDump: false, shouldUseLevelControl: false)
        
        buttonContainerView.isHidden = false
        accept_view.isHidden = true
        if reconnecting == false {
            call_status.text = "calling..."
        }
        user_Lbl.setNameTxt(opponent_id, "single")
    }
    @objc func CheckCallConnect()
    {
        ConnectWaitTimer?.invalidate()
        ConnectWaitTimer = nil
        print("CheckCallConnect =>\(isCallConnected)")
        if(!isCallConnected)
        {
            isDeclinedByMe = true
            RejectIncomingCall(false)
        }
        
    }
    func AcceptIncomingCall(roomName : String)
    {
        self.player?.stop()
        CallWaitTimer?.invalidate()
        CallWaitTimer = nil
        if reconnecting == false {
            call_status.text = "Connecting..."
        } else {
            call_status.text = "Reconnecting..."
        }
        ConnectWaitTimer = Timer.scheduledTimer(timeInterval: TimeInterval(Constant.sharedinstance.ConnectCallWaitTime), target: self, selector:  #selector(self.CheckCallConnect), userInfo: nil, repeats: false)
        
        if(client != nil) {
            client = nil
        }
        client = ARDAppClient(delegate: self)
        client?.delegate = self
        //        client?.toggleVideoMute()
        let settingsModel = ARDSettingsModel()
        client!.connectToRoom(withId: roomName as String?, settings: settingsModel, isLoopback: false, isAudioOnly: true, shouldMakeAecDump: false, shouldUseLevelControl: false)
        buttonContainerView.isHidden = false
        accept_view.isHidden = true
        isAttenCall = true
        var to_userID:String = String()
        if(Themes.sharedInstance.Getuser_id() != objcallrecord.from)
        {
            to_userID = objcallrecord.from
        }
        else
        {
            to_userID = objcallrecord.to
        }
        if to_userID == "" {
            to_userID = opponent_id
        }
        let CallStatusDict:NSDictionary = ["from":Themes.sharedInstance.Getuser_id(),"to":to_userID,"call_status":Constant.sharedinstance.call_status_ANSWERED,"toDocId":objcallrecord.doc_id,"id":objcallrecord.msgId,"recordId":objcallrecord.recordId,"call_duration":call_status.text!]
        SocketIOManager.sharedInstance.EmitCallStatus(ResponseDict: CallStatusDict)
        let DBDict:NSDictionary = ["call_status":Constant.sharedinstance.call_status_ANSWERED, "recordId" : objcallrecord.recordId, "duration" : "\(seconds)"]
        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Call_detail, FetchString: objcallrecord.doc_id, attribute: "doc_id", UpdationElements: DBDict)
    }
    
    func RejectIncomingCall(_ ifUserBusy : Bool)
    {
        AppDelegate.sharedInstance.RemoveCallRetry()
        let user_dict:NSDictionary = ["current_call_status":Constant.sharedinstance.call_free,"call_id":roomUrl]
        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail, FetchString: Themes.sharedInstance.Getuser_id(), attribute: "user_id", UpdationElements: user_dict)
        DeclineVideoCallstaus()
        clearCalls()
        if(!ifUserBusy) {
            disconnect()
        }
        self.player?.stop()
        if reconnecting == false {
            AppDelegate.sharedInstance.dismissView(self.view)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        UIDevice.current.isProximityMonitoringEnabled = false
        isCallConnected = false
        
        AppDelegate.sharedInstance.isVideoViewPresented = false
        
        let user_dict:NSDictionary = ["current_call_status":Constant.sharedinstance.call_free,"call_id":roomUrl]
        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail, FetchString: Themes.sharedInstance.Getuser_id(), attribute: "user_id", UpdationElements: user_dict)
        player?.stop()
        player = nil
        timer?.invalidate()
        timer = nil
        CallWaitTimer?.invalidate()
        CallWaitTimer = nil
        ConnectWaitTimer?.invalidate()
        ConnectWaitTimer = nil
    }

    func disconnect()
    {
        self.player?.stop()
        if(client != nil)
        {
            client?.disconnect()
        }
        
    }
    func remoteDisconnected() {
        timer?.invalidate()
        timer = nil
        isDeclinedByMe = true
        RejectIncomingCall(false)
    }
    
    func zoomRemote() {
    }
    
    public  func appClient(_ client: ARDAppClient!, didChange state: RTCIceConnectionState) {
        
        switch (state) {
        case .checking:
            print("checking")
            break;
        case .connected:
            print("connected")
            AppDelegate.sharedInstance.RemoveCallRetry()
            if(isCalling)
            {
                isAttenCall = true
            }
            isCallConnected = true
            call_status.text = "Connected"
            CallWaitTimer?.invalidate()
            CallWaitTimer = nil
            ConnectWaitTimer?.invalidate()
            ConnectWaitTimer = nil
            timer?.invalidate()
            timer = nil
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:  #selector(self.updateTimerLabel), userInfo: nil, repeats: true)
            if reconnecting == false {
                seconds = 0
            }
            self.player?.stop()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.call_status.text = "00:00"
            })
            reconnecting = false
            buttonContainerView.isHidden = false
            accept_view.isHidden = true
            break;
        case .completed:
            print("completed")
            break;
        case .disconnected:
            print("disconnected")
            print("isDeclinedByMe =>\(isDeclinedByMe)")
            print("reconnecting =>\(reconnecting)")
            print("Internet Check =>\(AppDelegate.sharedInstance.IsInternetconnected)")
            if(AppDelegate.sharedInstance.IsInternetconnected && SocketIOManager.sharedInstance.socket.status == .connected && isDeclinedByMe == true && reconnecting == false) {
                timer?.invalidate()
                timer = nil
                call_status.text = "Call Ended"
                self.isDeclinedByMe = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                    self.RejectIncomingCall(false)
                })
            } else {
                reconnecting = true
                call_status.text = "Reconnecting..."
            }
            break;
        case .closed:
            print("closed")
            break;
        case .failed:
            reconnecting = true
            call_status.text = "Reconnecting..."
            print("failed")
            break;
        case .new:
            print("new")
            break;
        case .count:
            print("count")
            break;
        }
        print(state)
        
    }
    
    @IBAction func audioButtonPressed(_ sender: Any) {
        let audioButton = sender as? UIButton
        if isAudioMute {
            self.view.makeToast(message: "Your microphone is unmuted", duration: 1.5, position: HRToastPositionCenter)
            audioButton?.setImage(UIImage(named: "audioOff"), for: .normal)
            isAudioMute = false
        }
        else {
            self.view.makeToast(message: "Your microphone is muted", duration: 1.5, position: HRToastPositionCenter)
            audioButton?.setImage(UIImage(named: "audioOn"), for: .normal)
            isAudioMute = true
        }
        DispatchQueue.main.async {
            self.client?.toggleAudioMute()
        }
        
    }
    
    
    @IBAction func videoButtonPressed(_ sender: Any) {
    }
    @IBAction func DidclickCallaccept(_ sender: Any) {
        AcceptIncomingCall(roomName: self.roomName)
    }
    
    @IBAction func DidclickCut(_ sender: Any) {
        reconnecting = false
        isDeclinedByMe = true
        RejectIncomingCall(false)
    }
    
    @IBAction func DidclickBackBtn(_ sender: Any) {
        AppDelegate.sharedInstance.window?.endEditing(true)
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut, animations: {
            self.minimizeView.isHidden = false
            let viewRect = UIScreen.main.bounds
            self.view.frame = CGRect(x: viewRect.size.width - 120, y: viewRect.size.height - 150, width: 100, height: 100)
            self.view.layer.masksToBounds = true
            self.view.layer.cornerRadius = 50
            self.user_image1.layer.masksToBounds = true
            self.user_image1.layer.cornerRadius = 50
        }, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    public func appClient(_ client: ARDAppClient!, didCreateLocalCapturer localCapturer: RTCCameraVideoCapturer!) {
        let settingsModel = ARDSettingsModel()
        captureController = ARDCaptureController(capturer: localCapturer, settings: settingsModel)
        captureController.startCapture()
        
    }
    
    func appClient(_ client: ARDAppClient, didReceiveLocalVideoTrack localVideoTrack: RTCVideoTrack) {
    }
    
    
    func appclient(_ client: ARDAppClient!, didRotateWithLocal localVideoTrack: RTCVideoTrack!, remoteVideoTrack: RTCVideoTrack!) {
    }
    
    public func appClient(_ client: ARDAppClient!, didGetStats stats: [Any]!) {
        
    }
    
    
    func appClient(_ client: ARDAppClient, didReceiveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack) {
    }
    
    func appClient(_ client: ARDAppClient!, didError error: Error!) {
        DeclineVideoCallstaus()
        DispatchQueue.main.async {
            self.call_status.text = "Call Failed"
        }
        timer?.invalidate()
        timer = nil
        self.disconnect()
        DispatchQueue.main.asyncAfter(deadline: .now()+2.0) {
            if reconnecting == false {
                AppDelegate.sharedInstance.dismissView(self.view)
            }
        }
    }
    
    func appClient(_ client: ARDAppClient, didChange state: ARDAppClientState) {
        switch state {
        case .connected:
            print("Client connected.")
            if(isCalling && reconnecting == false)
            {
                self.PlayAudio(tone: "outgoing_tone", type: "mp3")
            }
            break
        case .connecting:
            print("Client connecting.")
            break
        case .disconnected:
            print("Client disconnected.")
            if reconnecting == false {
                remoteDisconnected()
                //            call_status.text = "Disconnected"
                self.clearCalls()
            }
            break
        }
    }
    
    func clearCalls() {
        self.callManager = AppDelegate.sharedInstance.callManager
        for call in self.callManager.calls
        {
            let endaction =  CXEndCallAction(call: call.uuid)
            self.callManager.callController.request(CXTransaction(actions: [endaction]), completion:{ (error : Error?) in
                if((error) == nil)
                {
                    self.timer?.invalidate()
                    self.timer = nil
                    DispatchQueue.main.asyncAfter(deadline: .now()+2.0) {
                        if reconnecting == false {
                            AppDelegate.sharedInstance.dismissView(self.view)
                        }
                    }
                }
            })
        }
    }
    
    func videoView(_ videoView: RTCEAGLVideoView, didChangeVideoSize size: CGSize)
    {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDragging = false
        touchStart = touches.first!.location(in: self.view)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDragging = true
        if self.view.frame.size.width == 100 && self.view.frame.size.height == 100 {
            let touchPoint = touches.first!.location(in: self.view)
            let newCenter = CGPoint(x: self.view.center.x + touchPoint.x - touchStart.x,
                                    y: self.view.center.y + touchPoint.y - touchStart.y)
            
            if (newCenter.x + self.view.bounds.midX <= self.view.superview!.bounds.maxX && newCenter.x - self.view.bounds.midX >= self.view.superview!.bounds.minX && newCenter.y + self.view.bounds.midY <= self.view.superview!.bounds.maxY && newCenter.y - self.view.bounds.midY >= self.view.superview!.bounds.minY)
            {
                self.view.center = newCenter
            }
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let endPoint = touches.first!.location(in: self.view)
        if(touchStart == endPoint) {
            isDragging = false
        }
        if self.view.frame.size.width == 100 && self.view.frame.size.height == 100 {
            DispatchQueue.main.async {
                if !self.isDragging {
                    AppDelegate.sharedInstance.window?.endEditing(true)
                    UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut, animations: {
                        self.minimizeView.isHidden = true
                        self.view.frame = UIScreen.main.bounds
                        self.view.layer.cornerRadius = 0
                        self.user_image1.layer.cornerRadius = 0
                    }, completion: nil)
                }
            }
        }
        if(AppDelegate.sharedInstance.IsKeyboardVisible && self.view.frame.origin.y +  self.view.frame.size.height >= AppDelegate.sharedInstance.KeyboardFrame.y) {
            UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut, animations: {
                self.view.frame.y = AppDelegate.sharedInstance.KeyboardFrame.y - 150
            }, completion: nil)
        }
    }
    
    func addNotificationListener() {
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            var userInfo = notify.userInfo!
            let keyboardEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            if(AppDelegate.sharedInstance.isVideoViewPresented == true)
            {
                if weak.view.frame.size.width == 100 && weak.view.frame.size.height == 100 {
                    UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut, animations: {
                        weak.view.frame.y = keyboardEndFrame.y - 150
                    }, completion: nil)
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            if(AppDelegate.sharedInstance.isVideoViewPresented == true)
            {
                if weak.view.frame.size.width == 100 && weak.view.frame.size.height == 100 {
                    UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut, animations: {
                        let viewRect = UIScreen.main.bounds
                        weak.view.frame.y = viewRect.size.height - 150
                    }, completion: nil)
                }
                
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.callStatus), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            weak.GetCallStatus(notify.object as! NSDictionary)
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.reconnectIntimate), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            print("reconnectIntimate")
            reconnecting = true
            weak.call_status.text = "Reconnecting..."
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.reconnect), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            
             if weak.isCalling {
                
                weak.timer?.invalidate()
                weak.timer = nil
                weak.isDeclinedByMe = true
                weak.RejectIncomingCall(false)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                    let currentOpponentId = weak.opponent_id
                    var timestamp:String =  String(Date().ticks)
                    var servertimeStr:String = Themes.sharedInstance.getServerTime()
                    
                    if(servertimeStr == "")
                    {
                        servertimeStr = "0"
                    }
                    let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
                    timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
                    let docID = Themes.sharedInstance.Getuser_id() + "-" + currentOpponentId + "-" + timestamp
                    let param:NSDictionary = ["from":Themes.sharedInstance.Getuser_id(),"to":Themes.sharedInstance.CheckNullvalue(Passed_value: currentOpponentId),"type":0,"id":Int64(timestamp)!,"toDocId":docID, "roomid" : timestamp, "reconnecting": "true"]
                    AppDelegate.sharedInstance.isVideoViewPresented = false
                    SocketIOManager.sharedInstance.emitCallDetail(Param: param as! [String : Any])
                    AppDelegate.sharedInstance.dismissView(weak.view)
                    AppDelegate.sharedInstance.openCallPage(type: "0", roomid: timestamp, id: currentOpponentId)
                })
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.reconnectInternet), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            
            if weak.isAttenCall && weak.isCallConnected {
                reconnecting = true
                if weak.reconnecttimer != nil {
                    weak.reconnecttimer?.invalidate()
                    weak.reconnecttimer = nil
                }
                weak.reconnecttimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                    if AppDelegate.sharedInstance.IsInternetconnected && SocketIOManager.sharedInstance.socket.status == .connected {
                        if weak.reconnecttimer != nil {
                            weak.reconnecttimer?.invalidate()
                            weak.reconnecttimer = nil
                        }
                        
                        AppDelegate.sharedInstance.currentRoomName = weak.roomName
                        AppDelegate.sharedInstance.currentOpponentId = weak.opponent_id
                        
                        let param: NSDictionary = ["to": Themes.sharedInstance.CheckNullvalue(Passed_value: weak.opponent_id), "from": Themes.sharedInstance.Getuser_id()]
                        SocketIOManager.sharedInstance.emitReconnectIntimateCallEvent(Param: param as! [String : Any])
                        
                        if weak.isCalling {
                            
                            weak.timer?.invalidate()
                            weak.timer = nil
                            weak.isDeclinedByMe = true
                            weak.RejectIncomingCall(false)
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                                let currentOpponentId = AppDelegate.sharedInstance.currentOpponentId
                                var timestamp:String =  String(Date().ticks)
                                var servertimeStr:String = Themes.sharedInstance.getServerTime()
                                
                                if(servertimeStr == "")
                                {
                                    servertimeStr = "0"
                                }
                                let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
                                timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
                                let docID = Themes.sharedInstance.Getuser_id() + "-" + currentOpponentId + "-" + timestamp
                                let param:NSDictionary = ["from":Themes.sharedInstance.Getuser_id(),"to":Themes.sharedInstance.CheckNullvalue(Passed_value: currentOpponentId),"type":0,"id":Int64(timestamp)!,"toDocId":docID, "roomid" : timestamp, "reconnecting": "true"]
                                AppDelegate.sharedInstance.isVideoViewPresented = false
                                SocketIOManager.sharedInstance.emitCallDetail(Param: param as! [String : Any])
                                AppDelegate.sharedInstance.dismissView(weak.view)
                                AppDelegate.sharedInstance.openCallPage(type: "0", roomid: timestamp, id: currentOpponentId)
                            })
                        } else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                                let param: NSDictionary = ["to": Themes.sharedInstance.CheckNullvalue(Passed_value: weak.opponent_id), "from": Themes.sharedInstance.Getuser_id()]
                                SocketIOManager.sharedInstance.emitReconnectCallEvent(Param: param as! [String : Any])
                            })
                        }
                    }
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.updateCallRecord), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
//            if(!weak.hangupButton.isEnabled)
//            {
                if(notify.object as? Call_record != nil)
                {
                    weak.objcallrecord = notify.object as! Call_record
//                    weak.hangupButton.isEnabled = true
                    if reconnecting == false {
                        weak.call_status.text = "ringing..."
                    }
                    
                    if(weak.objcallrecord.user_busy != "0" && weak.objcallrecord.user_busy != "999")
                    {
                        if reconnecting == false {
                            weak.call_status.text = "User busy"
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                                weak.isDeclinedByMe = true
                                weak.RejectIncomingCall(true)
                            })
                        }
                    }
                }
//                else
//                {
//                    weak.hangupButton.isEnabled = true
//                }
            //}
        }
        
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.online_status_in_call), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            if(AppDelegate.sharedInstance.isVideoViewPresented == true)
            {
                if((notify.userInfo!["id"] as! String) != Themes.sharedInstance.Getuser_id() && ((notify.userInfo!["id"] as! String) == weak.objcallrecord.from || (notify.userInfo!["id"] as! String) == weak.objcallrecord.to) && (notify.userInfo!["is_online"] as! String) == "0")
                {
                    weak.timer?.invalidate()
                    weak.timer = nil
                    weak.call_status.text = "User in Offline"
                    weak.isDeclinedByMe = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                        weak.RejectIncomingCall(false)
                    })
                }
            }
        }
    }
    
    func removeNotificationListener() {
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        removeNotificationListener()
    }

    func appClient(_ client: ARDAppClient!, sendTurnMessage message: String) {
        var to_userID = ""
        if(Themes.sharedInstance.Getuser_id() != objcallrecord.from)
        {
            to_userID = objcallrecord.from
        }
        else
        {
            to_userID = objcallrecord.to
        }
        if to_userID == "" {
            to_userID = opponent_id
        }
        SocketIOManager.sharedInstance.emitTURNMessage(["from" : Themes.sharedInstance.Getuser_id(), "to" : to_userID, "message" : message])
    }
    
    func appClient(_ client: ARDAppClient!, sendTurnMessagefromCaller message: String, roomId: String, clientId: String) {
        SocketIOManager.sharedInstance.emitTURNMessageFromCaller(["roomId" : roomId, "clientId" : clientId, "message" : message])
    }
}

extension AudioCallVC : AppDelegateDelegates {
    func passTurnMessage(payload: String) {
        DispatchQueue.main.async {
            self.client?.receivedTurnMessage(payload)
        }
    }
}

