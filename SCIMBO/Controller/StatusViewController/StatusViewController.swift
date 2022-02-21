//
//  ViewController.swift
//  SegmentedProgressBar
//
//  Created by Dylan Marriott on 04.03.17.
//  Copyright © 2017 Dylan Marriott. All rights reserved.
//

import UIKit
import AVKit
import ContentSheet
import Photos
import ACPDownload
import MMMaterialDesignSpinner

protocol StatusViewControllerDelegate : class {
    func currentStatusEnded()
    func backButtonTapped()
    func DidClickDelete(_ messageFrame : UUMessageFrame)
    func DidClickForward(_ messageFrame : UUMessageFrame)
    func DidClickReplyMessage(_ messageFrame: UUMessageFrame,_ message: String,_ toId: String)
}


class StatusViewController: UIViewController, SegmentedProgressBarDelegate, ContentSheetDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var textStatusLabel: UILabel!
    @IBOutlet weak var statusReplayColourView: UIView!
    @IBOutlet weak var statusMessageLabel: UILabel!
    @IBOutlet weak var statusOwnerLabel: UILabel!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var statusReplayView: UIView!
    @IBOutlet weak var blureView: UIView!
    @IBOutlet weak var ReplyImg: UIImageView!
    @IBOutlet weak var CaptionLbl: UILabel!
    @IBOutlet weak var CaptionView: UIView!
    @IBOutlet weak var CaptionViewline: UIView!
    
    @IBOutlet weak var bottomViewbottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var currentUserName: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var swipeUpbutton: UIButton!
    @IBOutlet weak var blurImageView: UIImageView!
    
    @IBOutlet weak var replyLbl: UILabel!
    
    
    fileprivate var progressBar: SegmentedProgressBar!
    private let viewImgs = UIView()
    private let statusImgView = UIImageView()
    private let statusGifView = UIImageView()
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var timeObserver : Any?
    var statusArray = NSMutableArray()
    private var playerIteam: AVPlayerItem?
    private var isAppInForeground = true
    private var isViewDisplayed = false
    private var isDisplayedForFirstTime = true
    var isMyStatus = false
    private var fromBottomView = false
    private lazy var panGestureRecognizer: UIPanGestureRecognizer = { [unowned self] in
        let gesture = UIPanGestureRecognizer()
        gesture.addTarget(self, action: #selector(panGestureRecognizerHandler(_:)))
        
        return gesture
        }()
    
    
    private var initialFrame: CGRect?
    private var initialTouchPoint: CGPoint?
    weak var delegate: StatusViewControllerDelegate?
    var startIndex : Int = Int()
    var isFromView : Bool = Bool()
    var userId : String = String()
    
    var spinnerView:MMMaterialDesignSpinner=MMMaterialDesignSpinner()
    var spinner:UIView=UIView()

    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = 100
        } else {
            topViewHeightConstraint.constant = 75
        }
        addNotificationListener()
        self.view.backgroundColor = UIColor.black
        
        viewImgs.frame = view.bounds
        viewImgs.backgroundColor = UIColor.clear

        statusImgView.frame = view.bounds
        statusImgView.contentMode = .scaleAspectFit
        viewImgs.addSubview(statusImgView)
        
        statusGifView.frame = view.bounds
        statusGifView.contentMode = .scaleAspectFit
        statusGifView.isHidden = true
        
        viewImgs.addSubview(statusGifView)
        
        view.addSubview(viewImgs)
        
        spinner.frame = CGRect(x: statusImgView.center.x - 30, y: statusImgView.center.y - 30, width: 60, height: 60)
        spinner.backgroundColor = UIColor(red: 242/255, green: 241/255, blue: 237/255, alpha: 1.0);
        
        spinner.layer.masksToBounds = true
        spinner.layer.cornerRadius = spinner.frame.width / 2
        
        spinnerView.frame=CGRect(x: 2.5, y: 2.5, width: 55, height: 55)
        spinnerView.lineWidth = 2.5;
        spinnerView.tintColor = UIColor(red: 90/255, green: 88/255, blue: 85/255, alpha: 1.0);
        
        spinnerView.startAnimating()
        
        spinner.addSubview(spinnerView)
        viewImgs.addSubview(spinner)
        spinner.isHidden = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewDidTapped(_:)))
        tapGesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapGesture)
        
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(viewDidPressed(_:)))
        self.view.addGestureRecognizer(longGesture)
        
        var durationArr = [TimeInterval]()
        self.statusArray.forEach { message in
            let messageFrame : UUMessageFrame = message as! UUMessageFrame
            if(messageFrame.message.type == MessageType(rawValue: 0)){
                durationArr.append(TimeInterval(5))
            }
            else if(messageFrame.message.type == MessageType(rawValue: 1))
            {
                durationArr.append(TimeInterval(5))
            }
            else
            {
                if(messageFrame.message.duration != nil)
                {
                    var durationTime = Double(Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message.duration))
                    durationTime = round(Double(durationTime!)/1000)
                    
                    if(durationTime == 0)
                    {
                        durationArr.append(TimeInterval(Float(Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message.duration))!))
                    }
                    else
                    {
                        durationArr.append(TimeInterval(Float(durationTime!)))
                    }

                }
                else
                {
                    durationArr.append(TimeInterval(5))
                }
            }
        }
        
        progressBar = SegmentedProgressBar(numberOfSegments: statusArray.count, duration: durationArr)
        if UIDevice.isIphoneX {
            progressBar.frame = CGRect(x: 15, y: 40, width: view.frame.width - 30, height: 4)
        } else {
            progressBar.frame = CGRect(x: 15, y: 15, width: view.frame.width - 30, height: 4)
        }
        progressBar.delegate = self
        progressBar.topColor = UIColor.white
        progressBar.bottomColor = UIColor.white.withAlphaComponent(0.25)
        progressBar.padding = 2
        view.addSubview(progressBar)
        
        let blureTapGesture = UITapGestureRecognizer(target: self, action: #selector(blurGestureTapped(_:)))
        blureTapGesture.numberOfTapsRequired = 1
        blureView.addGestureRecognizer(blureTapGesture)
        
        bottomView.addGestureRecognizer(panGestureRecognizer)
        
        setupView()
        
        if(isFromView)
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.replayViewShower()
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !fromBottomView{
            viewIsDisplayed()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !fromBottomView{
            initialFrame = bottomView.frame
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if !fromBottomView{
            viewIsHiding()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
        blureView.isHidden = true
        self.messageTextField.text = ""
        messageTextField.resignFirstResponder()
    }
    
    @objc func panGestureRecognizerHandler(_ gesture: UIPanGestureRecognizer) {
        let _ = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        let locationinView = gesture.location(in: view)
        guard let initFrame = initialFrame else{return}
        
        if locationinView.y >  (initFrame.origin.y) - self.view.bounds.height*0.2 {
            gesture.state == .began ? panGestureDidStart(locationinView) : panGestureDidChange(locationinView)
        }
        else{
            print("greater")
            bottomView.alpha = 0
        }
        
        if gesture.state == .ended {
            panGestureDidEnd(locationinView, velocity: velocity)
        }
    }
    
    func panGestureDidStart(_ location: CGPoint){
        initialTouchPoint = location
    }
    
    func panGestureDidChange(_ translation: CGPoint) {
        guard initialFrame != nil else { return }
        guard let initialPoint = initialTouchPoint else { return }
        
        let bottomHeight = (initialPoint.y - translation.y)
        
        bottomViewbottomConstraint.constant = -bottomHeight
    }
    
    func panGestureDidEnd(_ translation: CGPoint, velocity: CGPoint) {
        if bottomView.alpha == 0{
            replayViewShower()
        }
        
        bottomViewbottomConstraint.constant = 0
        bottomView.alpha = 1
    }
    
    func viewIsDisplayed(){
        if isDisplayedForFirstTime{
            //            progressBar.rewind()
            progressBar.startAnimation()
            isDisplayedForFirstTime = false
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2, execute: {
                self.progressBar.rewind()
            })
        }
        else{
            progressBar.isPaused = false
        }
        
        isViewDisplayed = true
        
        if player != nil{
            player?.play()
        }
        
    }
    
    func viewIsHiding(){
        isViewDisplayed = false
        if player != nil{
            player?.pause()
        }
        progressBar.isPaused = true
    }
    
    
    
    
    func setupView(){
        
        view.bringSubviewToFront(topView)
        view.bringSubviewToFront(bottomView)
        view.bringSubviewToFront(progressBar)
        view.bringSubviewToFront(CaptionView)
    }
    
    
    func replayViewSetter(){
        
        let messageFrame = self.statusArray.object(at: self.progressBar.currentAnimationIndex) as! UUMessageFrame
        statusOwnerLabel.setNameTxt(Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message.user_from), "single")
        if(messageFrame.message.type == MessageType(rawValue: 0))
        {
            statusMessageLabel.text = messageFrame.message.payload
        }
        else if(messageFrame.message.type == MessageType(rawValue: 1))
        {
            statusMessageLabel.text = "📷 Photo"
        }
        else if(messageFrame.message.type == MessageType(rawValue: 2))
        {
            var durationTime = Double(Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message.duration))
            durationTime = round(Double(durationTime!)/1000)
            
            Themes.sharedInstance.hmsFrom(seconds: Int(durationTime!)) { hours, minutes, seconds in
                
                let hours = Themes.sharedInstance.getStringFrom(seconds: hours)
                let minutes = Themes.sharedInstance.getStringFrom(seconds: minutes)
                let seconds = Themes.sharedInstance.getStringFrom(seconds: seconds)
                
                print("\(hours):\(minutes):\(seconds)")
                self.statusMessageLabel.text = "📹 Video \(minutes):\(seconds)"
            }
        }
        statusOwnerLabel.text = "\(Themes.sharedInstance.setNameTxt(Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message.user_from), "single")) • Status"
        ReplyImg.layer.masksToBounds = true
        ReplyImg.layer.cornerRadius = 6.0
        StatusUploadHandler.Sharedinstance.loadFriendsImage(messageFrame: messageFrame, imageView: ReplyImg, isLoaderShow: true, isGif: false, completion: nil)
        
    }
    
    func segmentedProgressBarChangedIndex(index: Int) {
        print("Now showing index: \(index)")
        if(self.startIndex > index)
        {
            self.progressBar.skip()
        }
        else
        {
            updateImage(index: index)
        }
    }
    
    
    @objc func playerEnd(){
        progressBar.skip()
    }
    
    
    
    @objc func viewDidTapped(_ sender: UIGestureRecognizer) {
        let point = sender.location(in: self.view)
        progressBar.isPaused = !progressBar.isPaused
        if (point.x) < self.view.bounds.width/2{
            print(self.progressBar.currentAnimationIndex)
            if(self.startIndex == self.progressBar.currentAnimationIndex)
            {
                self.startIndex = self.startIndex - 1
            }
            progressBar.rewind()
        }
        else{
            if(self.startIndex == self.progressBar.currentAnimationIndex)
            {
                self.startIndex = self.startIndex + 1
            }
            progressBar.skip()
        }
    }
    
    @objc func viewDidPressed(_ sender: UIGestureRecognizer) {
        if sender.state == .ended {
            if player != nil{
                player?.play()
            }
            progressBar.isPaused = false
            topView.isHidden = false
            bottomView.isHidden = false
            statusGifView.startAnimatingGif()
        }
        else if sender.state == .began {
            progressBar.isPaused = true
            if player != nil{
                player?.pause()
            }
            
            topView.isHidden = true
            bottomView.isHidden = true
            statusGifView.stopAnimatingGif()
        }
    }
    
    @objc func viewSwipedDown(){
        self.pop(animated: true)
    }
    
    @objc func appEnterBackGround(){
        
        if isViewDisplayed && isAppInForeground{
            isAppInForeground = false
            if player != nil{
                player?.pause()
            }
            progressBar.isPaused = true
        }
        
    }
    
    @objc func appEnterForeground(){
        
        if isViewDisplayed && !isAppInForeground{
            isAppInForeground = true
            if player != nil{
                player?.play()
            }
            progressBar.isPaused = false
        }
    }
    
    
    //    @objc func keyboardWillShow(notification: NSNotification) {
    //
    //        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
    //            print("KeyHeight \(keyboardSize.height) || bottomCon \(self.replayViewBottomConstraint.constant)")
    //            self.replayViewBottomConstraint.constant = keyboardSize.height
    //        }
    //
    //    }
    //
    //    @objc func keyboardWillHide(notification: NSNotification) {
    //
    //        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
    //            self.replayViewBottomConstraint.constant = 0
    //        }
    //    }
    //
    
    @objc @IBAction func blurGestureTapped(_ sender : UITapGestureRecognizer)
    {
        if(sender.location(in: statusReplayView.superview).y < statusReplayView.frame.origin.y) {
            blureViewTapped()
        }
    }
    
    @objc func blureViewTapped(){
        if player != nil{
            player?.playImmediately(atRate: 1.0)
        }
        progressBar.isPaused = false
        
        blureView.isHidden = true
        self.messageTextField.text = ""
        messageButton.isEnabled = false
        messageTextField.resignFirstResponder()
    }
    
    func segmentedProgressBarFinished() {
        print("Finished!")
        player?.pause()
        self.deallocPlayer()
        delegate?.currentStatusEnded()
    }
    
    func playVideo(videoURL : URL){
        
        progressBar.isPaused = true
        
        //        let videoURL = URL(string: url)
        playerIteam = AVPlayerItem(url: videoURL)
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerIteam)
        
        playerIteam?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
        playerIteam?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
        playerIteam?.addObserver(self, forKeyPath: "playbackBufferFull", options: .new, context: nil)
        
        playerIteam?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
        
        player = AVPlayer(playerItem: playerIteam)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = self.view.bounds
        playerLayer?.isHidden = true
        self.view.layer.insertSublayer(playerLayer!, below: self.topView.layer)
        if isViewDisplayed{
            player?.play()
        }
        
        timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { (timer) in
            var playerCurrentTime = 0.0
            if(self.playerIteam != nil)
            {
                playerCurrentTime = Double((self.playerIteam?.currentTime().seconds)!)
                print((self.playerIteam?.currentTime().seconds)!)
            }
            
            if playerCurrentTime > 0 {
                if self.player?.timeControlStatus == .playing , self.progressBar.isPaused == true
                {
                    self.progressBar.isPaused = false
                }
                self.viewImgs.isHidden = true
                self.playerLayer?.isHidden = false
                self.spinner.isHidden = true
            }
        }
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object is AVPlayerItem {
            switch keyPath {
            case "playbackBufferEmpty"?:
                print("buffer")
                break
                // Show loader
                
            case "playbackLikelyToKeepUp"?:
                print("buffer hide")
                break
                // Hide loader
                
            case "playbackBufferFull"?:
                print("buffer hide")
                break
            // Hide loader
            default :
                print("\(String(describing: player?.status))")
                break
            }
        }
        
        if keyPath == "status" {
            print("\(String(describing: player?.status))")
        }
    }
    
    @IBAction func menuButtonDidTapped(_ sender: UIButton) {
        if player != nil{
            player?.pause()
        }
        progressBar.isPaused = true
        let messageFrame  = self.statusArray.object(at: self.progressBar.currentAnimationIndex) as! UUMessageFrame
        if(isMyStatus)
        {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let SaveAction = UIAlertAction(title: "Save".localized(), style: .default) { (alert: UIAlertAction) in
                let PhotoPath:String = StatusUploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "upload_Path") as! String
                
                let photos = PHPhotoLibrary.authorizationStatus()
                if photos == .notDetermined {
                    PHPhotoLibrary.requestAuthorization({status in
                        if status == .authorized{
                        }
                        else {
                            
                            
                        }
                    })
                }
                if(messageFrame.message.type == MessageType(rawValue: 1))
                {
                    
                   // UIImageWriteToSavedPhotosAlbum(UIImage(contentsOfFile: PhotoPath)!, nil, nil, nil)
                    CreateCustomeAlbum.sharedInstance.save(image: UIImage(contentsOfFile: PhotoPath)!)
                }
                if(messageFrame.message.type == MessageType(rawValue: 2))
                {
//                    PHPhotoLibrary.shared().performChanges({
//                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: PhotoPath))
//                    }) { saved, error in
//                        if saved {
//                            print("Video saved")
//
//                        }
//                        else
//                        {
//                            print((error?.localizedDescription)!)
//                        }
//                    }
                    //
                     CreateCustomeAlbum.sharedInstance.saveVideo(fileURL: URL(fileURLWithPath: PhotoPath))
                }
                if !self.fromBottomView{
                    self.viewIsDisplayed()
                }
            }
            let ForwardAction = UIAlertAction(title: "Forward".localized(), style: .default) { (alert: UIAlertAction) in
                if(self.progressBar.currentAnimationIndex < self.statusArray.count)
                {
                    self.delegate?.backButtonTapped()
                    self.delegate?.DidClickForward(self.statusArray.object(at: self.progressBar.currentAnimationIndex) as! UUMessageFrame)
                    self.delegate = nil
                }
            }
            let DeleteAction = UIAlertAction(title: "Delete".localized(), style: .destructive) { (alert: UIAlertAction) in
                if(self.progressBar.currentAnimationIndex < self.statusArray.count)
                {
                    self.delegate?.backButtonTapped()
                    self.delegate?.DidClickDelete(self.statusArray.object(at: self.progressBar.currentAnimationIndex) as! UUMessageFrame)
                    self.delegate = nil
                }
            }
            let CancelAction = UIAlertAction(title: NSLocalizedString("Cancel".localized(), comment: "comment"), style: .cancel) { (alert: UIAlertAction) in
                if !self.fromBottomView{
                    self.viewIsDisplayed()
                }
            }
            if(messageFrame.message.type != MessageType(rawValue: 0))
            {
                alertController.addAction(SaveAction)
            }
            alertController.addAction(ForwardAction)
            alertController.addAction(DeleteAction)
            alertController.addAction(CancelAction)
            self.presentView(alertController, animated: true, completion: nil)
        }
        else
        {
            let checkMute = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Status_initiated_details, attrib_name: "user_common_id", fetchString: self.userId, returnStr: "is_mute")
            var title = ""
            if(checkMute == "1")
            {
                title = "\("Unmute".localized()) \(Themes.sharedInstance.setNameTxt(Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message.user_from), "single"))\("'s story updates? New status updates from".localized()) \(Themes.sharedInstance.setNameTxt(Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message.user_from), "single")) \("will appear at the top of the stories list.".localized())"
            }
            else
            {
                title = "\("Mute".localized()) \(Themes.sharedInstance.setNameTxt(Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message.user_from), "single"))\("'s story updates? New status updates from".localized()) \(Themes.sharedInstance.setNameTxt(Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message.user_from), "single")) \("won't appear at the top of the stories list anymore.".localized())"
                
            }
            let alertController = UIAlertController(title: nil, message: title, preferredStyle: .actionSheet)
            
            let muteAction = UIAlertAction(title: "Mute".localized(), style: .default, handler: { (alert: UIAlertAction) in
                
                let convId = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Status_one_one, attrib_name: "doc_id", fetchString: messageFrame.message.doc_id!, returnStr: "convId")
                let dic:[AnyHashable: Any] = ["from":Themes.sharedInstance.Getuser_id(),"to":self.userId,"status":"1","convId":convId]
                SocketIOManager.sharedInstance.muteStatus(param: dic as! [String : Any])
                let checkInitiated = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Status_initiated_details, attribute: "user_common_id", FetchString: self.userId)
                if(checkInitiated)
                {
                    let param = ["is_mute" : "1"]
                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Status_initiated_details, FetchString: self.userId, attribute: "user_common_id", UpdationElements: param as NSDictionary)
                }
                if !self.fromBottomView{
                    self.viewIsDisplayed()
                }
            })
            let unMuteAction = UIAlertAction(title: "Unmute".localized(), style: .default, handler: { (alert: UIAlertAction) in
                
                let convId = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Status_one_one, attrib_name: "doc_id", fetchString: messageFrame.message.doc_id!, returnStr: "convId")
                let dic:[AnyHashable: Any] = ["from":Themes.sharedInstance.Getuser_id(),"to":self.userId,"status":"0","convId":convId]
                SocketIOManager.sharedInstance.muteStatus(param: dic as! [String : Any])
                let checkInitiated = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Status_initiated_details, attribute: "user_common_id", FetchString: self.userId)
                if(checkInitiated)
                {
                    let param = ["is_mute" : ""]
                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Status_initiated_details, FetchString: self.userId, attribute: "user_common_id", UpdationElements: param as NSDictionary)
                }
                if !self.fromBottomView{
                    self.viewIsDisplayed()
                }
            })
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel".localized(), comment: "comment"), style: .cancel, handler: { (alert: UIAlertAction) in
                if !self.fromBottomView{
                    self.viewIsDisplayed()
                }
            })
            
            if(checkMute == "1")
            {
                alertController.addAction(unMuteAction)
            }
            else
            {
                alertController.addAction(muteAction)
            }
            alertController.addAction(cancelAction)
            self.presentView(alertController, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func messageButtonDidTapped(_ sender: Any) {
        let messageFrame = self.statusArray.object(at: self.progressBar.currentAnimationIndex) as! UUMessageFrame
        delegate?.DidClickReplyMessage(messageFrame,self.messageTextField.text!, self.userId)
        self.blureViewTapped()
    }
    
    @IBAction func cameraButtonDidTapped(_ sender: UIButton) {
    }
    @IBAction func backButtonDidTapped(_ sender: UIButton) {
        delegate?.backButtonTapped()
    }
    
    
    
    fileprivate func replayViewShower() {
        if player != nil{
            player?.pause()
        }
        progressBar.isPaused = true
        if isMyStatus{
            let content: ContentSheetContentProtocol
            let view = Bundle.main.loadNibNamed("PersonViewedStatusView", owner: self, options: nil)?.first as! PersonViewedStatusView
            view.isFromTag = false
            view.delegate = self
            view.backgroundColor = UIColor.clear
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            let path = UIBezierPath(roundedRect:self.view.bounds,
                                    byRoundingCorners:[.topRight, .topLeft],
                                    cornerRadii: CGSize(width: 20, height:  20))
            
            let maskLayer = CAShapeLayer()
            
            maskLayer.path = path.cgPath
            view.layer.mask = maskLayer
            let messageFrame : UUMessageFrame = self.statusArray.object(at: self.progressBar.currentAnimationIndex) as! UUMessageFrame
            let FetchMessageArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Status_one_one, attribute: "msgId", FetchString: messageFrame.message.msgId!, SortDescriptor: nil) as! NSArray
            var ratio = 0.0
            if(FetchMessageArr.count > 0)
            {
                let messageObj : NSManagedObject = FetchMessageArr[0] as! NSManagedObject
                let data = messageObj.value(forKey: "viewed_by") as? Data
                let viewedArray =   NSKeyedUnarchiver.unarchiveObject(with: data ?? Data()) as? NSArray
                if let _ = viewedArray
                {
                    view.datasource = viewedArray!
                    let height = (55 * Double(view.datasource.count)) + 75
                    ratio = height/Double(self.view.frame.size.height)
                }
                else
                {
                    ratio = 75 / Double(self.view.frame.size.height)
                }
            }
            else
            {
                ratio = 75 / Double(self.view.frame.size.height)
            }
            content = view
            
            let contentSheet = ContentSheet(content: content)
            contentSheet.delegate = self
            contentSheet.blurBackground = false
            contentSheet.showDefaultHeader = false
            fromBottomView = true
//            if(ratio > 0.90)
//            {
//                contentSheet.CollapsedHeightRatio = 0.90
//            }
//            else
//            {
//                contentSheet.CollapsedHeightRatio = CGFloat(ratio)
//            }
            let vc = UIViewController.init()
            vc.view = content as? UIView
            self.presentView(vc, animated: true)
            
        }else{
            replayViewSetter()
            blureView.isHidden = false
            self.view.bringSubviewToFront(blureView)
            messageTextField.becomeFirstResponder()
        }
    }
    
    func contentSheetDidDisappear(_ sheet: ContentSheet) {
        fromBottomView = false
        blureViewTapped()
        progressBar.skip()
    }
    
    
    @objc fileprivate func swipeUpButtonTapped() {
        replayViewShower()
    }
    
    @IBAction func swipUpButtonDidTapped(_ sender: UIButton) {
        swipeUpButtonTapped()
        
    }
    
    private func deallocPlayer() {
        if (self.timeObserver != nil) {
            //            if player?.rate == 1.0 { // it is required as you have to check if player is playing
            player?.removeTimeObserver(timeObserver!)
            //            }
        }
        player?.pause()
        self.playerIteam?.removeObserver(self, forKeyPath: "playbackBufferEmpty", context: nil)
        self.playerIteam?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp", context: nil)
        self.playerIteam?.removeObserver(self, forKeyPath: "playbackBufferFull", context: nil)
        self.playerIteam?.removeObserver(self, forKeyPath: "status", context: nil)
        
        playerLayer?.isHidden = true
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        player = nil
        timeObserver = nil
        self.playerIteam = nil
    }
    
    private func updateImage(index: Int) {
        print("Next!")
        deallocPlayer()
        spinner.isHidden = true
        messageTextField.text = ""
        self.statusImgView.isHidden = false
        _ = self.statusImgView.subviews.map {
            if $0.tag == 100 {
                $0.removeFromSuperview()
            }
        }
        if(index < self.statusArray.count)
        {
            let messageFrame = self.statusArray.object(at: index) as! UUMessageFrame
            textStatusLabel.isHidden = true
            self.view.bringSubviewToFront(textStatusLabel)
            textStatusLabel.text = messageFrame.message.payload!
            self.view.backgroundColor = UIColor.black
            if (messageFrame.message.type == MessageType(rawValue: 0)){
                self.viewImgs.isHidden = false
                textStatusLabel.isHidden = false
                statusImgView.image = nil
                textStatusLabel.text = messageFrame.message.payload!
                textStatusLabel.font = UIFont(name: messageFrame.message.theme_font, size: 25)
                blurImageView.image = nil
                statusImgView.backgroundColor = UIColor(named: messageFrame.message.theme_color)
                if(self.isMyStatus)
                {
                    self.currentUserName.text = "Me"
                    
                    if(messageFrame.message.message_status == "0")
                    {
                        self.currentTimeLabel.text = "🕘 Sending..."
                    }
                    else
                    {
                        self.currentTimeLabel.text = Themes.sharedInstance.returnStatusTime(from: messageFrame.message.timestamp!)
                    }
                    let FetchMessageArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Status_one_one, attribute: "msgId", FetchString: messageFrame.message.msgId!, SortDescriptor: nil) as! NSArray
                    if(FetchMessageArr.count > 0)
                    {
                        let messageObj : NSManagedObject = FetchMessageArr[0] as! NSManagedObject
                        let data = messageObj.value(forKey: "viewed_by") as? Data
                        let viewedArray =   NSKeyedUnarchiver.unarchiveObject(with: data ?? Data()) as? NSArray
                        if(viewedArray != nil)
                        {
                            self.replyLbl.text = "👁 \(((viewedArray) ?? NSArray.init()).count)"
                            
                        }
                        else
                        {
                            self.replyLbl.text = "👁 0"
                        }
                    }
                    else
                    {
                        self.replyLbl.text = "👁 0"
                    }
                    
                }
                else
                {
                    self.currentUserName.setNameTxt(Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message.user_from), "single")
                    
                    if(messageFrame.message.message_status == "0")
                    {
                        self.currentTimeLabel.text = "🕘 Sending..."
                    }
                    else
                    {
                        self.currentTimeLabel.text = Themes.sharedInstance.returnStatusTime(from: messageFrame.message.timestamp!)
                    }
                    let param = ["is_viewed" : "1"]
                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Status_one_one, FetchString: messageFrame.message.msgId!, attribute: "msgId", UpdationElements: param as NSDictionary)
                    
                    let timestamp_offlinemessages:String=Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message.msgId!);
                    SocketIOManager.sharedInstance.StatusAcknowledegmentHandler(from: Themes.sharedInstance.Getuser_id() as NSString, to: userId as NSString, status: "3", doc_id: messageFrame.message.doc_id! as NSString, timestamp: timestamp_offlinemessages as NSString,isEmit_status: true, chat_type: "single")
                    
                }
            }
            else if(messageFrame.message.type == MessageType(rawValue: 1))
            {
                self.viewImgs.isHidden = false
                statusImgView.backgroundColor = UIColor.clear
                if(self.isMyStatus)
                {
                    self.progressBar.isPaused = true

                    let PhotoPath:String = Themes.sharedInstance.CheckNullvalue(Passed_value: StatusUploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "upload_Path"))

                    if(URL(fileURLWithPath: PhotoPath).pathExtension.lowercased() == "gif")
                    {
                        statusImgView.isHidden = true
                        statusGifView.isHidden = false
                        
                        StatusUploadHandler.Sharedinstance.loadMyImage(messageFrame: messageFrame, imageView: statusGifView, isLoaderShow: true, isGif: true) {
                            self.progressBar.isPaused = false
                        }
                    }
                    else
                    {
                        statusImgView.isHidden = false
                        statusGifView.isHidden = true
                        StatusUploadHandler.Sharedinstance.loadMyImage(messageFrame: messageFrame, imageView: statusImgView, isLoaderShow: true, isGif: false) {
                            self.progressBar.isPaused = false
                        }
                    }

                    self.currentUserName.text = "Me"
                    
                    if(messageFrame.message.message_status == "0")
                    {
                        self.currentTimeLabel.text = "🕘 Sending..."
                    }
                    else
                    {
                        self.currentTimeLabel.text = Themes.sharedInstance.returnStatusTime(from: messageFrame.message.timestamp!)
                    }


                    let FetchMessageArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Status_one_one, attribute: "msgId", FetchString: messageFrame.message.msgId!, SortDescriptor: nil) as! NSArray
                    if(FetchMessageArr.count > 0)
                    {
                        let messageObj : NSManagedObject = FetchMessageArr[0] as! NSManagedObject
                        let data = messageObj.value(forKey: "viewed_by") as? Data
                        let viewedArray =   NSKeyedUnarchiver.unarchiveObject(with: data ?? Data()) as? NSArray
                        if(viewedArray != nil)
                        {
                            self.replyLbl.text = "👁 \(((viewedArray)?.count) ?? 0)"
                            
                        }
                        else
                        {
                            self.replyLbl.text = "👁 0"
                        }
                    }
                    else
                    {
                        self.replyLbl.text = "👁 0"
                    }
                    
                }
                else
                {
                    self.progressBar.isPaused = true
                    
                    let serverpath:String = Themes.sharedInstance.CheckNullvalue(Passed_value: StatusUploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "serverpath"))
                    
                    if((URL(string: serverpath))?.pathExtension.lowercased() == "gif")
                    {
                        statusImgView.isHidden = true
                        statusGifView.isHidden = false
                        
                        StatusUploadHandler.Sharedinstance.loadFriendsImage(messageFrame: messageFrame, imageView: statusGifView, isLoaderShow: true, isGif: true){
                            self.progressBar.isPaused = false
                        }
                    }
                    else
                    {
                        statusImgView.isHidden = false
                        statusGifView.isHidden = true
                        
                        StatusUploadHandler.Sharedinstance.loadFriendsImage(messageFrame: messageFrame, imageView: statusImgView, isLoaderShow: true, isGif: false){
                            self.progressBar.isPaused = false
                        }
                    }

                    
                   
                    self.currentUserName.setNameTxt(Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message.user_from), "single")
                    
                    if(messageFrame.message.message_status == "0")
                    {
                        self.currentTimeLabel.text = "🕘 Sending..."
                    }
                    else
                    {
                        self.currentTimeLabel.text = Themes.sharedInstance.returnStatusTime(from: messageFrame.message.timestamp!)
                    }
                    let param = ["is_viewed" : "1"]
                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Status_one_one, FetchString: messageFrame.message.msgId!, attribute: "msgId", UpdationElements: param as NSDictionary)
                    
                    let timestamp_offlinemessages:String=Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message.msgId!);
                    SocketIOManager.sharedInstance.StatusAcknowledegmentHandler(from: Themes.sharedInstance.Getuser_id() as NSString, to: userId as NSString, status: "3", doc_id: messageFrame.message.doc_id! as NSString, timestamp: timestamp_offlinemessages as NSString,isEmit_status: true, chat_type: "single")
                    
                }
            }
            else
            {
                statusImgView.isHidden = false
                statusGifView.isHidden = true
                
                if(self.isMyStatus)
                {
                    StatusUploadHandler.Sharedinstance.loadVideoThumbnailOfMe(messageFrame: messageFrame, ImageView: statusImgView)
                    
                    self.currentUserName.text = "Me"
                                        
                    if(messageFrame.message.message_status == "0")
                    {
                        self.currentTimeLabel.text = "🕘 Sending..."
                    }
                    else
                    {
                        self.currentTimeLabel.text = Themes.sharedInstance.returnStatusTime(from: messageFrame.message.timestamp!)
                    }
                    let FetchMessageArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Status_one_one, attribute: "msgId", FetchString: messageFrame.message.msgId!, SortDescriptor: nil) as! NSArray
                    if(FetchMessageArr.count > 0)
                    {
                        let messageObj : NSManagedObject = FetchMessageArr[0] as! NSManagedObject
                        let data = messageObj.value(forKey: "viewed_by") as? Data
                        let viewedArray =   NSKeyedUnarchiver.unarchiveObject(with: data ?? Data()) as? NSArray
                        if(viewedArray != nil)
                        {
                            self.replyLbl.text = "👁 \(((viewedArray) ?? NSArray.init()).count)"
                            
                        }
                        else
                        {
                            self.replyLbl.text = "👁 0"
                        }
                    }
                    else
                    {
                        self.replyLbl.text = "👁 0"
                    }
                    
                }
                else
                {
                    StatusUploadHandler.Sharedinstance.loadVideoThumbnailOfOthers(messageFrame: messageFrame, ImageView: statusImgView)
                    self.currentUserName.setNameTxt(Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message.user_from), "single")
                                        
                    if(messageFrame.message.message_status == "0")
                    {
                        self.currentTimeLabel.text = "🕘 Sending..."
                    }
                    else
                    {
                        self.currentTimeLabel.text = Themes.sharedInstance.returnStatusTime(from: messageFrame.message.timestamp!)
                    }
                    let param = ["is_viewed" : "1"]
                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Status_one_one, FetchString: messageFrame.message.msgId!, attribute: "msgId", UpdationElements: param as NSDictionary)
                    
                    let timestamp_offlinemessages:String=Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message.msgId!);
                    SocketIOManager.sharedInstance.StatusAcknowledegmentHandler(from: Themes.sharedInstance.Getuser_id() as NSString, to: userId as NSString, status: "3", doc_id: messageFrame.message.doc_id! as NSString, timestamp: timestamp_offlinemessages as NSString,isEmit_status: true, chat_type: "single")
                    
                }
                DispatchQueue.main.async {
                    self.spinner.isHidden = false
                    self.playVideo(videoURL: self.VideoURL(messageFrame: messageFrame))
                }
                
            }
            
            if(messageFrame.message.payload.trimmingCharacters(in: .whitespacesAndNewlines) == "" || messageFrame.message.type == MessageType(rawValue: 0))
            {
                self.CaptionView.isHidden = true
                self.CaptionViewline.isHidden = true
                self.CaptionLbl.text = ""
            }
            else
            {
                self.CaptionView.isHidden = false
                self.CaptionViewline.isHidden = false
                self.CaptionLbl.text = messageFrame.message.payload!
                Themes.sharedInstance.setShadowonLabel(self.CaptionLbl, UIColor.black)
            }
            Themes.sharedInstance.setShadowonLabel(self.currentUserName, UIColor.black)
            Themes.sharedInstance.setShadowonLabel(self.currentTimeLabel, UIColor.black)
            
            if(Platform.isSimulator)
            {
                self.blurImageView.image = nil
            }
            else
            {
                self.blurImageView.image = Themes.sharedInstance.blurredImage(with: self.statusImgView.image)
                self.blurImageView.alpha = 0.5
            }
        }
    }
    
    func VideoURL(messageFrame : UUMessageFrame) -> URL
    {
        if self.isMyStatus
        {
            
            let videoPath:String = StatusUploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "upload_Path") as! String
            
            let download_status:String = StatusUploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "download_status") as! String
            
            
            if(videoPath != "")
            {
                if(download_status == "2")
                {
                    if FileManager.default.fileExists(atPath: videoPath) {
                        let videoURL = URL(fileURLWithPath: videoPath)
                        return videoURL
                    }
                    else
                    {
                        let serverpath:String = StatusUploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "serverpath") as! String
                        
                        if(serverpath != "")
                        {
                            let param:NSDictionary = ["download_status":"0"]
                            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Status_Upload_Details, FetchString: messageFrame.message.thumbnail!, attribute: "upload_data_id", UpdationElements: param)
                            StatusDownloadHandler.sharedinstance.handleDownLoad()
                        }
                        let videoURL = URL(string: serverpath)
                        return videoURL!
                    }
                }
                else
                {
                    let serverpath:String = StatusUploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "serverpath") as! String
                    
                    if(serverpath != "")
                    {
                        let param:NSDictionary = ["download_status":"0"]
                        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Status_Upload_Details, FetchString: messageFrame.message.thumbnail!, attribute: "upload_data_id", UpdationElements: param)
                        StatusDownloadHandler.sharedinstance.handleDownLoad()
                    }
                    
                    
                    
                    let videoURL = URL(string: serverpath)
                    return videoURL!
                }
            }
        }
        else
        {
            let download_status:String = StatusUploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "download_status") as! String
            if(download_status == "2")
            {
                let videoPath:String = StatusUploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "upload_Path") as! String
                
                if(videoPath != "")
                {
                    if FileManager.default.fileExists(atPath: videoPath) {
                        let videoURL = URL(fileURLWithPath: videoPath)
                        return videoURL
                    }
                    else
                    {
                        let serverpath:String = StatusUploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "serverpath") as! String

                        if(serverpath != "")
                        {
                            let param:NSDictionary = ["download_status":"0"]
                            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Status_Upload_Details, FetchString: messageFrame.message.thumbnail!, attribute: "upload_data_id", UpdationElements: param)
                            StatusDownloadHandler.sharedinstance.handleDownLoad()
                        }

                        let videoURL = URL(string: serverpath)
                        return videoURL!
                    }
                }
                else
                {
                    let serverpath:String = StatusUploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "serverpath") as! String
                    
                    if(serverpath != "")
                    {
                        let param:NSDictionary = ["download_status":"0"]
                        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Status_Upload_Details, FetchString: messageFrame.message.thumbnail!, attribute: "upload_data_id", UpdationElements: param)
                        StatusDownloadHandler.sharedinstance.handleDownLoad()
                    }
                    
                    let videoURL = URL(string: serverpath)
                    return videoURL!
                }
            }
            else
            {
                let serverpath:String = StatusUploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "serverpath") as! String
                
                if(serverpath != "")
                {
                    let param:NSDictionary = ["download_status":"0"]
                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Status_Upload_Details, FetchString: messageFrame.message.thumbnail!, attribute: "upload_data_id", UpdationElements: param)
                    StatusDownloadHandler.sharedinstance.handleDownLoad()
                }

                let videoURL = URL(string: serverpath)
                return videoURL!
            }
        }
        return URL(string: "")!
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        print("aaaaaaaaa......\(scrollView.panGestureRecognizer.translation(in: scrollView.superview).y)")
        if (scrollView.panGestureRecognizer.translation(in: scrollView.superview).y >= 0) {
            self.blureViewTapped()
        } else {
            // handle dragging to the left
        }
    }
    
    func addNotificationListener() {
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.updateViewCount), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            if(weak.progressBar.currentAnimationIndex < weak.statusArray.count)
            {
                let messageFrame : UUMessageFrame = weak.statusArray.object(at: weak.progressBar.currentAnimationIndex) as! UUMessageFrame
                let FetchMessageArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Status_one_one, attribute: "msgId", FetchString: messageFrame.message.msgId!, SortDescriptor: nil) as! NSArray
                if(FetchMessageArr.count > 0)
                {
                    let messageObj : NSManagedObject = FetchMessageArr[0] as! NSManagedObject
                    let data = messageObj.value(forKey: "viewed_by") as? Data
                    let viewedArray =   NSKeyedUnarchiver.unarchiveObject(with: data ?? Data()) as? NSArray
                    if(viewedArray != nil)
                    {
                        weak.replyLbl.text = "👁 \(((viewedArray) ?? NSArray.init()).count)"
                        
                    }
                    else
                    {
                        weak.replyLbl.text = "👁 0"
                    }
                }
                else
                {
                    weak.replyLbl.text = "👁 0"
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            weak.appEnterBackGround()
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            weak.appEnterBackGround()
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            weak.appEnterForeground()
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            weak.appEnterForeground()
        }
    }
    
    func removeNotificationListener() {
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        if player != nil{
            self.deallocPlayer()
        }
        progressBar.isPaused = true
        removeNotificationListener()
    }

}

extension StatusViewController : PersonViewedStatusViewDelegate {
    
    func delete() {
        if(self.progressBar.currentAnimationIndex < self.statusArray.count)
        {
            self.delegate?.backButtonTapped()
            self.delegate?.backButtonTapped()
            self.delegate?.DidClickDelete(self.statusArray.object(at: self.progressBar.currentAnimationIndex) as! UUMessageFrame)
            self.delegate = nil
        }
    }
    
    func forward() {
        if(self.progressBar.currentAnimationIndex < self.statusArray.count)
        {
            self.delegate?.backButtonTapped()
            self.delegate?.backButtonTapped()
            self.delegate?.DidClickForward(self.statusArray.object(at: self.progressBar.currentAnimationIndex) as! UUMessageFrame)
            self.delegate = nil
        }
    }
    
    func passSelectedPerson(data: NSDictionary) {
        
    }
    
    func closeContentSheed() {
        
    }
}

extension StatusViewController : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let text = textField.text {
            messageButton.isEnabled = text != ""
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            
            messageButton.isEnabled = updatedText != ""
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.blureViewTapped()
        return true
    }
}
