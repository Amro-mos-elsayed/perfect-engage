//
//  VideoViewController.swift
//
//
//  Created by MV Anand Casp iOS on 27/09/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit
//import WebRTC

class VideoViewController: UIViewController,ARDAppClientDelegate, RTCEAGLVideoViewDelegate {
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topcontainerconstrain: NSLayoutConstraint!
    @IBOutlet weak var btmcontainercontain: NSLayoutConstraint!
    var player : AVAudioPlayer?
    var timer:Timer?
    @IBOutlet weak var user_image: UIImageView!
    @IBOutlet weak var accept_view: UIView!
    @IBOutlet weak var hangupButton: UIButton!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var audioButton: UIButton!
    @IBOutlet weak var buttonContainerView: UIView!
    @IBOutlet weak var localView: RTCEAGLVideoView!
    @IBOutlet weak var remoteView: RTCEAGLVideoView!
    @IBOutlet weak var user_Lbl: UILabel!
    @IBOutlet weak var call_status: UILabel!
    @IBOutlet weak var backButton: UIButton!

    var isCalling:Bool = Bool()
    var ActualLocalFrame:CGRect!
    var seconds:Double = Double()
    var opponent_id:String = String()
    var roomUrl = ""
    var roomName = "bzzhj21sad"
    var client: ARDAppClient?
    var localVideoTrack: RTCVideoTrack?
    var remoteVideoTrack: RTCVideoTrack?
    var localVideoSize = CGSize.zero
    var remoteVideoSize = CGSize.zero
    var isZoom = false
    var isAudioMute = false
    var isVideoMute = false
    var Doc_id:String = String()
    var objcallrecord:Call_record = Call_record()
    var captureController:ARDCaptureController = ARDCaptureController()
    var isAttenCall:Bool = Bool()
    var CallWaitTimer:Timer?
    var isDeclinedByMe:Bool = Bool()
    
    var ConnectWaitTimer:Timer?
    
    var isCallConnected:Bool = Bool()
    var ishideBottomView:Bool = false
    
    var actualBottomViewy:CGFloat = CGFloat()
    
    var touchStart: CGPoint = CGPoint.zero
    var isDragging = false
    var viewSizebeforeMinimize = CGRect.zero
    
    var tapGesture : UITapGestureRecognizer?
    var panGesture = UIPanGestureRecognizer()
    
    //used for double tap remote view
    override func viewDidLoad()
    {
        super.viewDidLoad()
        AppDelegate.sharedInstance.isVideoViewPresented = true
        AppDelegate.sharedInstance.callDelegate = self
        addNotificationListener()
        isAttenCall = false
        self.backButton.isEnabled = false
        isZoom = false
        isAudioMute = false
        isVideoMute = false
        remoteView.delegate = self
        localView.delegate = self
        print(CGFloat.pi/2)
        localView.transform = CGAffineTransform(scaleX: -1, y: 1)
        remoteView.transform = CGAffineTransform(scaleX: 1, y: 1)
        ActualLocalFrame = localView.frame
        localView.frame = self.view.bounds
        localView.layer.masksToBounds = true
        localView.layer.cornerRadius = 0;
        remoteView.isHidden = true
        CallWaitTimer = Timer.scheduledTimer(timeInterval: TimeInterval(Constant.sharedinstance.CallWaitTime), target: self, selector:  #selector(self.CheckCallStatus), userInfo: nil, repeats: false)
        if(isCalling)
        {
            self.videoButton.isEnabled = false
        }
        
        
        
       
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewDidTapped(_:)))
        tapGesture?.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapGesture!)
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedView(_:)))
        localView.isUserInteractionEnabled = true
        localView.addGestureRecognizer(panGesture)
    }
    
    @objc func draggedView(_ recognizer:UIPanGestureRecognizer){
        if true {
            self.view.bringSubviewToFront(localView)
            let translation = recognizer.translation(in: self.view)
            let newPos = CGPoint(x:recognizer.view!.center.x + translation.x, y:recognizer.view!.center.y + translation.y)
            
            if insideDraggableArea(point: newPos) {
                localView.center =  newPos
                recognizer.setTranslation(CGPoint.zero, in: self.view)
            }
        }
    }
    
    func insideDraggableArea(point : CGPoint) -> Bool {
        return point.x > 60 && point.x < (self.view.frame.size.width - 60) &&
            point.y > 60 && point.y < (self.view.frame.size.height - 60)
    }
    
    @objc func viewDidTapped(_ sender: UIGestureRecognizer) {
        if(isCallConnected)
        {
            if(!ishideBottomView)
            {
                
                UIView.animate(withDuration: 0.4, delay: 0.0, options: [], animations: {
                    self.topcontainerconstrain.constant  = -self.topView.frame.height
                    self.btmcontainercontain.constant  = -self.buttonContainerView.frame.height
                    self.view.layoutIfNeeded()
                }, completion: nil)
                
            }
            else
            {
                
                UIView.animate(withDuration: 0.4, delay: 0.0, options: [], animations: {
                    self.topcontainerconstrain.constant  = 0
                    self.btmcontainercontain.constant = 0
                    self.view.layoutIfNeeded()
                }, completion: nil)
                
            }
            
            ishideBottomView = !ishideBottomView
        }
        
        
    }
    
    func hideViewswhileMinimize() {
        if(!ishideBottomView)
        {
            
            UIView.animate(withDuration: 0.4, delay: 0.0, options: [], animations: {
                self.topcontainerconstrain.constant  = -self.topView.frame.height
                self.btmcontainercontain.constant  = -self.buttonContainerView.frame.height
                self.view.layoutIfNeeded()
            }, completion: nil)
            
        }
        else
        {
            
            UIView.animate(withDuration: 0.4, delay: 0.0, options: [], animations: {
                self.topcontainerconstrain.constant  = 0
                self.btmcontainercontain.constant = 0
                self.view.layoutIfNeeded()
            }, completion: nil)
            
        }
        
        ishideBottomView = !ishideBottomView
    }
    
    override func viewDidLayoutSubviews() {
    }
    
    func GetCallStatus(_ notify:Notification)
    {
        let Dict:NSDictionary = notify.object as! NSDictionary
        if(Dict.count > 0)
        {
            let recordId:String = Themes.sharedInstance.CheckNullvalue(Passed_value: Dict.object(forKey: "recordId"))
            let callstatus:String = Themes.sharedInstance.CheckNullvalue(Passed_value: Dict.object(forKey: "call_status"))
            print("callstatus =>\(callstatus)")
            if(recordId == objcallrecord.recordId)
            {
                if(callstatus == "\(Constant.sharedinstance.call_status_END)")
                {
                    self.disconnect()
                    call_status.text = "Call Ended"
                    timer?.invalidate()
                    timer = nil
                    DispatchQueue.main.asyncAfter(deadline: .now()+2.0) {
                        AppDelegate.sharedInstance.dismissView(self.view)
                    }
                }
                else if( callstatus == "\(Constant.sharedinstance.call_status_MISSED)")
                {
                    self.disconnect()
                    call_status.text = "Call Missed"
                    timer?.invalidate()
                    timer = nil
                    DispatchQueue.main.asyncAfter(deadline: .now()+2.0) {
                        AppDelegate.sharedInstance.dismissView(self.view)
                    }
                }
                else if( callstatus == "\(Constant.sharedinstance.call_status_REJECTED)")
                {
                    self.disconnect()
                    call_status.text = "Call Rejected"
                    timer?.invalidate()
                    timer = nil
                    DispatchQueue.main.asyncAfter(deadline: .now()+2.0) {
                        AppDelegate.sharedInstance.dismissView(self.view)
                    }
                }
                else if( callstatus == "\(Constant.sharedinstance.call_status_RECEIVED)")
                {
                    self.disconnect()
                    call_status.text = "Call Declined"
                    timer?.invalidate()
                    timer = nil
                    DispatchQueue.main.asyncAfter(deadline: .now()+2.0) {
                        AppDelegate.sharedInstance.dismissView(self.view)
                    }
                }
                
            }
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
            if(Int(_call_status)! < 3)
            {
                if(isCalling)
                {
                    let CallStatusDict:NSDictionary = ["from":Themes.sharedInstance.Getuser_id(),"to":to_userID,"call_status":Constant.sharedinstance.call_status_MISSED,"toDocId":objcallrecord.doc_id,"id":objcallrecord.msgId,"recordId":objcallrecord.recordId]
                    SocketIOManager.sharedInstance.EmitCallStatus(ResponseDict: CallStatusDict)
                    let DBDict:NSDictionary = ["call_status":Constant.sharedinstance.call_status_MISSED, "recordId" : objcallrecord.recordId, "duration" : "\(seconds)"]
                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Call_detail, FetchString: objcallrecord.doc_id, attribute: "doc_id", UpdationElements: DBDict)
                }
                call_status.text = "Call Ended"
                self.disconnect()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    AppDelegate.sharedInstance.dismissView(self.view)
                })
            }
        }
        else
        {
            self.disconnect()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                AppDelegate.sharedInstance.dismissView(self.view)
            })
        }
    }
    @objc func updateTimerLabel()
    {
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
            
//            print(finalstr)
            self.call_status.text = finalstr
        }
        seconds += 1
    }
    
    func PlayAudio(tone: String, type: String)
    {
        let session = AVAudioSession.sharedInstance()
        
        try? session.setCategory(AVAudioSession.Category.playAndRecord, mode: isCalling ? AVAudioSession.Mode.voiceChat : AVAudioSession.Mode.videoChat, options: .duckOthers)
        try? session.setCategory(AVAudioSession.Category.playAndRecord)
        if(isCalling)
        {
            try? session.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
        }
        else{
            try? session.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        }
        try? session.setActive(true)
        
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
            if(isAttenCall)
            {
                let CallStatusDict:NSDictionary = ["from":Themes.sharedInstance.Getuser_id(),"to":to_userID,"call_status":Constant.sharedinstance.call_status_END,"toDocId":objcallrecord.doc_id,"id":objcallrecord.msgId,"recordId":objcallrecord.recordId,"call_duration":call_status.text!]
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
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
        isCallConnected = false
        if(isCalling)
        {
            makeOutgoingCall(roomName: self.roomName)
        }
        else
        {
            call_status.text = "Incoming Call..."
            AppDelegate.sharedInstance.PlayAudio(tone: "tone", type: "mp3")
            buttonContainerView.isHidden = true
            accept_view.isHidden = false
            user_Lbl.setNameTxt(opponent_id, "single")
            let user_dict:NSDictionary = ["current_call_status":Constant.sharedinstance.call_in_waiting,"call_id":""]
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail, FetchString: Themes.sharedInstance.Getuser_id(), attribute: "user_id", UpdationElements: user_dict)
            user_image.isHidden = false
            user_image.setProfilePic(opponent_id, "single")
            remoteView.isHidden = true
            localView.isHidden = true
            
        }
        
    }
    
    func makeOutgoingCall(roomName : String)
    {
        client = ARDAppClient(delegate: self)
        client?.delegate = self
        let settingsModel = ARDSettingsModel()
        client?.toggleVideoMute()
        client!.connectToRoom(withId: roomName as String?, settings: settingsModel, isLoopback: false, isAudioOnly: false, shouldMakeAecDump: false, shouldUseLevelControl: false)
        
        buttonContainerView.isHidden = false
        accept_view.isHidden = true
        call_status.text = "calling..."
        user_Lbl.setNameTxt(opponent_id, "single")
        user_image.isHidden = true
    }
    @objc func CheckCallConnect()
    {
        print("isCallConnected =>\(isCallConnected)")
        ConnectWaitTimer?.invalidate()
        ConnectWaitTimer = nil
        if(!isCallConnected)
        {
            isDeclinedByMe = true
            RejectIncomingCall(false)
        }
    }
    
    func AcceptIncomingCall(roomName : String)
    {
        self.player?.stop()
        AppDelegate.sharedInstance.player?.stop()
        CallWaitTimer?.invalidate()
        CallWaitTimer = nil
        call_status.text = "Connecting..."
        ConnectWaitTimer = Timer.scheduledTimer(timeInterval: TimeInterval(Constant.sharedinstance.ConnectCallWaitTime), target: self, selector:  #selector(self.CheckCallConnect), userInfo: nil, repeats: false)
        client = ARDAppClient(delegate: self)
        client?.delegate = self
        client?.toggleVideoMute()
        let settingsModel = ARDSettingsModel()
        client!.connectToRoom(withId: roomName as String?, settings: settingsModel, isLoopback: false, isAudioOnly: false, shouldMakeAecDump: false, shouldUseLevelControl: false)
        var to_userID:String = String()
        if(Themes.sharedInstance.Getuser_id() != objcallrecord.from)
        {
            to_userID = objcallrecord.from
        }
        else
        {
            to_userID = objcallrecord.to
            
        }
        let CallStatusDict:NSDictionary = ["from":Themes.sharedInstance.Getuser_id(),"to":to_userID,"call_status":Constant.sharedinstance.call_status_ANSWERED,"toDocId":objcallrecord.doc_id,"id":objcallrecord.msgId,"recordId":objcallrecord.recordId,"call_duration":call_status.text!]
        SocketIOManager.sharedInstance.EmitCallStatus(ResponseDict: CallStatusDict)
        let DBDict:NSDictionary = ["call_status":Constant.sharedinstance.call_status_ANSWERED, "recordId" : objcallrecord.recordId, "duration" : "\(seconds)"]
        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Call_detail, FetchString: objcallrecord.doc_id, attribute: "doc_id", UpdationElements: DBDict)
        buttonContainerView.isHidden = false
        accept_view.isHidden = true
        isAttenCall = true
    }
    
    func RejectIncomingCall(_ ifUserBusy : Bool)
    {
        AppDelegate.sharedInstance.RemoveCallRetry()
        DeclineVideoCallstaus()
        if(!ifUserBusy) {
            disconnect()
        }
        self.player?.stop()
        AppDelegate.sharedInstance.player?.stop()
        AppDelegate.sharedInstance.dismissView(self.view)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        UIApplication.shared.isIdleTimerDisabled = false
        isCallConnected = false
        AppDelegate.sharedInstance.isVideoViewPresented = false
        let user_dict:NSDictionary = ["current_call_status":Constant.sharedinstance.call_free,"call_id":roomUrl]
        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.User_detail, FetchString: Themes.sharedInstance.Getuser_id(), attribute: "user_id", UpdationElements: user_dict)
        player?.stop()
        AppDelegate.sharedInstance.player?.stop()
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
        DispatchQueue.main.async { [self] in
            
            
            self.player?.stop()
            AppDelegate.sharedInstance.player?.stop()
            if (client != nil) {
                if (localVideoTrack != nil) {
                    localVideoTrack?.remove(localView)
                }
                if (remoteVideoTrack != nil) {
                    remoteVideoTrack?.remove(remoteView)
                }
                localVideoTrack = nil
                remoteView.renderFrame(nil)
                localView.renderFrame(nil)
                remoteVideoTrack = nil
                client?.disconnect()
            }
        }
    }
    func remoteDisconnected() {
        DispatchQueue.main.async { [self] in
            if (remoteVideoTrack != nil) {
                remoteVideoTrack?.remove(remoteView)
            }
            remoteVideoTrack = nil
            remoteView.setSize(CGSize(width: 10, height: 10))
            remoteView.renderFrame(nil)
            //    videoView(localView, didChangeVideoSize: localVideoSize)
        }
    }
    
    func zoomRemote() {
        //Toggle Aspect Fill or Fit
        isZoom = !isZoom
    }
    
    public  func appClient(_ client: ARDAppClient!, didChange state: RTCIceConnectionState) {
        
        switch (state) {
        case .checking:
            print("checking")
            break;
        case .connected:
            print("connected")
            DispatchQueue.main.async { [self] in
                
                AppDelegate.sharedInstance.RemoveCallRetry()
                if(isCalling)
                {
                    isAttenCall = true
                }
                isCallConnected = true
                CallWaitTimer?.invalidate()
                CallWaitTimer = nil
                ConnectWaitTimer?.invalidate()
                ConnectWaitTimer = nil
                user_image.isHidden = true
                call_status.text = "Connected"
                timer?.invalidate()
                timer = nil
                timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:  #selector(self.updateTimerLabel), userInfo: nil, repeats: true)
                seconds = 0
                self.player?.stop()
                AppDelegate.sharedInstance.player?.stop()
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
                    self.call_status.text = "00:00"
                })
                remoteView.isHidden = false
                localView.isHidden = false
                buttonContainerView.isHidden = false
                accept_view.isHidden = true
                UIView.animate(withDuration: 0.4, animations: { () -> Void in
                    if self.view.frame.size.width == 120 && self.view.frame.size.height == 160 {
                        self.remoteView.frame = self.view.bounds
                        self.localView.frame = CGRect(x: self.view.frame.size.width - 50, y: self.view.frame.size.height - 60, width: 40, height: 50)
                        self.localView.layer.cornerRadius = 6
                    }
                    else
                    {
                        self.localView.frame = self.ActualLocalFrame
                        self.localView.layer.masksToBounds = true
                        self.localView.layer.cornerRadius = 15;
                        self.remoteView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                    }
                })
            }
        case .completed:
            print("completed")
            break;
        case .disconnected:
            print("disconnected")
            timer?.invalidate()
            timer = nil
            call_status.text = "Call Ended"
            self.isDeclinedByMe = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                self.RejectIncomingCall(false)
            })
            break;
        case .closed:
            print("closed")
            break;
        case .failed:
            print("failed")
            break;
        case .new:
            print("new")
            break;
        case .count:
            print("count")
            break;
        }
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
        let videoButton = sender as? UIButton
        if isVideoMute {
            videoButton?.setImage(UIImage(named: "videoOn"), for: .normal)
            isVideoMute = false
        }
        else {
            
            videoButton?.setImage(UIImage(named: "videoOff"), for: .normal)
            
            isVideoMute = true
        }
        
        self.client?.toggleVideoMute()
        
    }
    @IBAction func DidclickCallaccept(_ sender: Any) {
        
        AcceptIncomingCall(roomName: self.roomName)
    }
    
    @IBAction func DidclickCut(_ sender: Any!) {
        isDeclinedByMe = true
        RejectIncomingCall(false)
    }
    
    @IBAction func DidclickBackBtn(_ sender: Any) {
        AppDelegate.sharedInstance.window?.endEditing(true)
        self.viewSizebeforeMinimize = self.remoteView.isHidden ? self.localView.frame : self.remoteView.frame
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut, animations: {
            let viewRect = UIScreen.main.bounds
            self.view.frame = CGRect(x: viewRect.size.width - 140, y: viewRect.size.height - 210, width: 120, height: 160)
            self.view.layer.masksToBounds = true
            self.view.layer.cornerRadius = 12
            self.tapGesture?.isEnabled = false
            self.hideViewswhileMinimize()
            if(self.remoteView.isHidden) {
                self.localView.frame = self.view.bounds
            }
            else
            {
                self.remoteView.frame = self.view.bounds
                self.localView.frame = CGRect(x: self.view.frame.size.width - 50, y: self.view.frame.size.height - 60, width: 40, height: 50)
                self.localView.layer.cornerRadius = 6
            }
        }, completion: nil)
    }
    
    @IBAction func DidclickFlip(_ sender: Any) {
        
        captureController.switchCamera()
        let transition = CATransition()
        transition.duration = 0.6
        transition.type = CATransitionType(rawValue: "flip")
        transition.subtype = CATransitionSubtype.fromRight
        DispatchQueue.main.async {
            self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if(self.captureController.isFrontCamera){
                self.localView.transform = CGAffineTransform(scaleX: -1, y: 1)
            }else{
                self.localView.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        }
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
        if (self.localVideoTrack != nil) {
            DispatchQueue.main.async{
                self.localVideoTrack?.remove(self.localView)
                self.localVideoTrack = nil
                self.localView.renderFrame(nil)
            }
        }
        
        self.localVideoTrack = localVideoTrack
        
        DispatchQueue.main.async{
            self.localVideoTrack?.add(self.localView)
            self.backButton.isEnabled = true
        }
    }
    
    func appclient(_ client: ARDAppClient!, didRotateWithLocal localVideoTrack: RTCVideoTrack!, remoteVideoTrack: RTCVideoTrack!) {
    }
    
    public func appClient(_ client: ARDAppClient!, didGetStats stats: [Any]!) {
        
    }
    
    
    func appClient(_ client: ARDAppClient, didReceiveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack) {
        DispatchQueue.main.async {
            
            
            self.remoteVideoTrack = remoteVideoTrack
            self.remoteVideoTrack?.add(self.remoteView)
        }
    }
    
    func appClient(_ client: ARDAppClient!, didError error: Error!) {
        
        //        let alertView = UIAlertView(title: "", message: "\(error)", delegate: nil, cancelButtonTitle: "OK", otherButtonTitles: "")
        //        alertView.show()
        DeclineVideoCallstaus()
        DispatchQueue.main.async {
            self.call_status.text = "Call Failed"
        }
        timer?.invalidate()
        timer = nil
        self.disconnect()
        DispatchQueue.main.asyncAfter(deadline: .now()+2.0) {
            AppDelegate.sharedInstance.dismissView(self.view)
        }
        
    }
    
    func appClient(_ client: ARDAppClient, didChange state: ARDAppClientState) {
        switch state {
        case .connected:
            print("Client connected.")
            if(isCalling)
            {
                self.PlayAudio(tone: "outgoing_tone", type: "mp3")
            }
            break
        case .connecting:
            print("Client connecting.")
            break
        case .disconnected:
            print("Client disconnected.")
            remoteDisconnected()
            //            call_status.text = "Disconnected"
            break
        }
    }
    
    func videoView(_ videoView: RTCEAGLVideoView, didChangeVideoSize size: CGSize)
    {
        DispatchQueue.main.async {
            let VideoSize = size
            var bounds = CGRect.zero
            
            var VideoView = RTCEAGLVideoView()
            if (videoView == self.remoteView) {
                VideoView = self.remoteView
                bounds = self.view.bounds
            }
            else if(videoView == self.localView)
            {
                VideoView = self.localView
                bounds = self.view.bounds
                if(VideoView.frame != self.view.bounds)
                {
                    bounds = VideoView.frame
                }
            }
            if (VideoSize.width > 0 && VideoSize.height > 0 && VideoSize.width != VideoSize.height) {
                // Aspect fill remote video into bounds.
                var remoteVideoFrame = AVMakeRect(aspectRatio: VideoSize, insideRect: bounds)
                let scale : CGFloat = bounds.size.height / remoteVideoFrame.size.height;
                remoteVideoFrame.size.height *= scale;
                remoteVideoFrame.size.width *= scale;
                VideoView.frame = remoteVideoFrame;
                VideoView.center = CGPoint(x: bounds.midX, y: bounds.midY)
            } else {
                if(VideoSize.width != VideoSize.height)
                {
                    VideoView.frame = bounds;
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDragging = false
        touchStart = touches.first!.location(in: self.view)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDragging = true
        if self.view.frame.size.width == 120 && self.view.frame.size.height == 160 {
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
        if self.view.frame.size.width == 120 && self.view.frame.size.height == 160 {
            DispatchQueue.main.async {
                if !self.isDragging {
                    AppDelegate.sharedInstance.window?.endEditing(true)
                    UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut, animations: {
                        self.view.frame = UIScreen.main.bounds
                        self.view.layer.cornerRadius = 0
                        self.tapGesture?.isEnabled = true
                        self.hideViewswhileMinimize()
                        if(self.remoteView.isHidden) {
                            self.localView.frame = self.viewSizebeforeMinimize
                        }
                        else
                        {
                            self.remoteView.frame = self.viewSizebeforeMinimize
                            self.localView.frame = self.ActualLocalFrame
                            self.localView.layer.cornerRadius = 15
                        }
                    }, completion: nil)
                }
            }
        }
        if(AppDelegate.sharedInstance.IsKeyboardVisible && self.view.frame.origin.y +  self.view.frame.size.height >= AppDelegate.sharedInstance.KeyboardFrame.y) {
            UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut, animations: {
                self.view.frame.y = AppDelegate.sharedInstance.KeyboardFrame.y - 210
            }, completion: nil)
        }
    }
    
    func addNotificationListener() {
        
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: OperationQueue.main) { (notify: Notification) in
            
            print("didBecomeActiveNotification")
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: OperationQueue.main) { (notify: Notification) in
            
            var userInfo = notify.userInfo!
            let keyboardEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            if(AppDelegate.sharedInstance.isVideoViewPresented == true)
            {
                if self.view.frame.size.width == 120 && self.view.frame.size.height == 160 {
                    UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut, animations: {
                        self.view.frame.y = keyboardEndFrame.y - 210
                    }, completion: nil)
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: OperationQueue.main) { (notify: Notification) in
            
            if(AppDelegate.sharedInstance.isVideoViewPresented == true)
            {
                if self.view.frame.size.width == 120 && self.view.frame.size.height == 160 {
                    UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut, animations: {
                        let viewRect = UIScreen.main.bounds
                        self.view.frame.y = viewRect.size.height - 210
                    }, completion: nil)
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.callStatus), object: nil, queue: OperationQueue.main) { (notify: Notification) in
            self.GetCallStatus(notify)
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.updateCallRecord), object: nil, queue: OperationQueue.main) { (notify: Notification) in
            
            if(!self.videoButton.isEnabled)
            {
                if(notify.object as? Call_record != nil)
                {
                    self.objcallrecord = notify.object as! Call_record
                    self.videoButton.isEnabled = true
                    self.call_status.text = "ringing..."
                    if(self.objcallrecord.user_busy != "0" && self.objcallrecord.user_busy != "999")
                    {
                        self.call_status.text = "User busy"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                            self.isDeclinedByMe = true
                            self.RejectIncomingCall(true)
                        })
                    }
                }
                else
                {
                    self.videoButton.isEnabled = true
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.online_status_in_call), object: nil, queue: OperationQueue.main) { (notify: Notification) in
            
            if(AppDelegate.sharedInstance.isVideoViewPresented == true)
            {
                if((notify.userInfo!["id"] as! String) != Themes.sharedInstance.Getuser_id() && ((notify.userInfo!["id"] as! String) == self.objcallrecord.from || (notify.userInfo!["id"] as! String) == self.objcallrecord.to) && (notify.userInfo!["is_online"] as! String) == "0")
                {
                    self.timer?.invalidate()
                    self.timer = nil
                    self.call_status.text = "User in Offline"
                    self.isDeclinedByMe = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                        self.RejectIncomingCall(false)
                    })
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: AVAudioSession.routeChangeNotification, object: nil, queue: OperationQueue.main) { (notify: Notification) in
            if(AppDelegate.sharedInstance.isVideoViewPresented)
            {
                guard let view = AppDelegate.sharedInstance.window?.subviews.last, view.tag == 1 else { return }
                var isEarPhone = false
                let currentRoute = AVAudioSession.sharedInstance().currentRoute
                if currentRoute.outputs.count != 0 {
                    for description in currentRoute.outputs {
                        if description.portType == AVAudioSession.Port.headphones {
                            isEarPhone = true
                        }
                    }
                }
                do {
                    try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, mode: isEarPhone ? AVAudioSession.Mode.voiceChat : AVAudioSession.Mode.videoChat, options: .duckOthers)
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
        SocketIOManager.sharedInstance.emitTURNMessage(["from" : Themes.sharedInstance.Getuser_id(), "to" : to_userID, "message" : message])
    }
    
    func appClient(_ client: ARDAppClient!, sendTurnMessagefromCaller message: String, roomId: String, clientId: String) {
        SocketIOManager.sharedInstance.emitTURNMessageFromCaller(["roomId" : roomId, "clientId" : clientId, "message" : message])
    }
    
}

extension VideoViewController : AppDelegateDelegates {
    func passTurnMessage(payload: String) {
        self.client?.receivedTurnMessage(payload)
    }
}
