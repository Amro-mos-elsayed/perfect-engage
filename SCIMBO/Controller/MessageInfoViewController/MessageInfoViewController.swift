//
//  MessageInfoViewController.swift
//
//
//  Created by MV Anand Casp iOS on 16/08/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit
import AVKit

import SimpleImageViewer

class MessageInfoViewController: UIViewController,UUMessageCellDelegate,UITableViewDelegate,UITableViewDataSource,UUAVAudioPlayerDelegate{
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topTblViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var wrapper_view: UIView!
    var chatModel:ChatModel=ChatModel()
    
    @IBOutlet weak var bottom_tableView: UITableView!
    @IBOutlet weak var chat_tableview: UITableView!
    @IBOutlet weak var chat_background: UIImageView!
    var pause_row:NSInteger = NSInteger()
    var initial = 0
    
    var ChatType:String = String()
    var messageinfo:UUMessageFrame? = UUMessageFrame()
    
    var Response = [String : Any]() {
        didSet {
            self.bottom_tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        AppDelegate.sharedInstance.Delegate = self
        addNotificationListener()
        
        chat_tableview.register(UINib(nibName: "ChatInfoCell", bundle: nil), forCellReuseIdentifier: "ChatInfoCell")
        if(messageinfo != nil)
        {
            let dic:[AnyHashable: Any] = ["type": "0","convId":"","doc_id":"","filesize":"","from":""
                ,"to":"","isStar":"","message_status":"","id":"","name":"","payload":"","recordId":"","timestamp":(messageinfo?.message.timestamp!)! as String,"thumbnail":"","width":"0.0","height":"0.0","msgId":""
                ,"contactmsisdn":"","user_common_id":"","message_from":"","chat_type":"","info_type":"10","created_by":""]
            chatModel.addSpecifiedItem(dic, isPagination: false)
            chatModel.dataSource.add(messageinfo!)
            chat_tableview.delegate = self
            chat_tableview.dataSource = self
            chat_tableview.reloadData()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.topTblViewHeightConstraint.constant =  self.chat_tableview.contentSize.height
            }
        }
        chat_tableview.tableFooterView = UIView()
        chat_tableview.separatorColor = UIColor.clear
        
        let nibName = UINib(nibName: "MessageInfoCell", bundle: nil)
        self.bottom_tableView.register(nibName, forCellReuseIdentifier: "MessageInfoCellID")
        bottom_tableView.delegate = self
        bottom_tableView.dataSource = self
        bottom_tableView.reloadData()
        bottom_tableView.tableFooterView = UIView()
        
        chat_tableview.rowHeight = UITableView.automaticDimension
        chat_tableview.estimatedRowHeight = 10
        chat_tableview.registerCell()
        
        SocketIOManager.sharedInstance.getSingleMessageInfo(from: Themes.sharedInstance.Getuser_id(), type: ChatType, recordId: Themes.sharedInstance.CheckNullvalue(Passed_value: messageinfo?.message.recordId))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func PasReplyDetail(index:IndexPath,ReplyRecordID:String, isStatus: Bool)
    {
        
    }
    
    func PasPersonDetail(id: String) {
        let singleInfoVC:SingleInfoViewController=self.storyboard?.instantiateViewController(withIdentifier: "SingleInfoViewController") as! SingleInfoViewController
        singleInfoVC.user_id = Themes.sharedInstance.CheckNullvalue(Passed_value: id)
        self.pushView(singleInfoVC, animated: true)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if(tableView == chat_tableview)
        {
            return 1;
            
        }
        else
        {
            return 2
        }
    }
    
    
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (tableView != chat_tableview)
        {
            return 44
        }
        
        return 10;
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01;
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == chat_tableview)
        {
            return self.chatModel.dataSource.count
        }
        else
        {
            if ChatType == "group" {
                if let seen_arr = Response["time_to_seen"] as? [[String : Any]], section == 0{
                    return seen_arr.count
                }
                else if let deliver_arr = Response["time_to_deliever"] as? [[String : Any]], section == 1{
                    return deliver_arr.count
                }
                return 0
            }
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(tableView == chat_tableview)
        {
            return ""
        }
        return section == 0 ? NSLocalizedString("SEEN", comment: "SEEN") : NSLocalizedString("DELIVERED", comment: "DELIVERED")
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell_main : UITableViewCell = UITableViewCell()
        
        if(tableView == chat_tableview)
        {
            
            let messageFrame: UUMessageFrame = self.chatModel.dataSource[indexPath.row] as! UUMessageFrame
            if(messageFrame.message.info_type == "0")
            {
                
                let cell1 = TableviewCellGenerator.sharedInstance.returnCell(for: tableView, messageFrame: messageFrame, indexPath: indexPath)
                cell1.RowIndex = indexPath
                return cell1
            }
            else
            {
                let cell:ChatInfoCell = tableView.dequeueReusableCell(withIdentifier: "ChatInfoCell") as! ChatInfoCell
                cell.Info_Btn.isHidden = true
                cell.date_lbl.isHidden = false
                
                let dateStr = Themes.sharedInstance.ReturnDateTimeFormat(timestamp: messageFrame.message.timestamp)
                
                let date_lblsize: CGSize = (dateStr as NSString).size(withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16.0)])
                
                cell.date_lbl.frame = CGRect(x: ((cell.frame.size.width) - date_lblsize.width + 5)/2  , y: ((cell.frame.size.height) - date_lblsize.height)/2 , width: date_lblsize.width + 5, height: date_lblsize.height)
                
                cell.date_lbl.setTitle(dateStr, for: .normal)
                
                cell_main = cell
                
                cell_main.selectionStyle = .blue
                cell_main.backgroundColor = UIColor.clear
                cell_main.contentView.backgroundColor = UIColor.clear
            }
        }
        else
        {
            let cell:MessageInfoCell = tableView.dequeueReusableCell(withIdentifier: "MessageInfoCellID") as! MessageInfoCell
            if(ChatType == "single")
            {
                cell.logo_image.setProfilePic(Themes.sharedInstance.CheckNullvalue(Passed_value: Response["id"]), "single")
                cell.nameLbl.setNameTxt(Themes.sharedInstance.CheckNullvalue(Passed_value: Response["id"]), "single")
                let seen = Themes.sharedInstance.CheckNullvalue(Passed_value: Response["time_to_seen"])
                let time_to_deliever = Themes.sharedInstance.CheckNullvalue(Passed_value: Response["time_to_deliever"])
                
                if(indexPath.section == 0) {
                    cell.time_Lbl.text = seen == "0" ? "•••" : Themes.sharedInstance.ReturnDateTimeFormat(timestamp: seen) + " at " + Themes.sharedInstance.ReturnTimeForChat(timestamp: seen)
                }
                else {
                    cell.time_Lbl.text = time_to_deliever == "0" ? "•••" : Themes.sharedInstance.ReturnDateTimeFormat(timestamp: time_to_deliever) + " at " + Themes.sharedInstance.ReturnTimeForChat(timestamp: time_to_deliever)
                }
            }
            else
            {
                if let seen_arr = Response["time_to_seen"] as? [[String : Any]], indexPath.section == 0{
                    let seen = seen_arr[indexPath.row]
                    cell.logo_image.setProfilePic(Themes.sharedInstance.CheckNullvalue(Passed_value: seen["id"]), "single")
                    cell.nameLbl.setNameTxt(Themes.sharedInstance.CheckNullvalue(Passed_value: seen["id"]), "single")
                    let time = Themes.sharedInstance.CheckNullvalue(Passed_value: seen["time_to_seen"])
                    cell.time_Lbl.text = time == "0" ? "•••" : Themes.sharedInstance.ReturnDateTimeFormat(timestamp: time) + " at " + Themes.sharedInstance.ReturnTimeForChat(timestamp: time)
                }
                else if let deliver_arr = Response["time_to_deliever"] as? [[String : Any]], indexPath.section == 1{
                    let deliver = deliver_arr[indexPath.row]
                    cell.logo_image.setProfilePic(Themes.sharedInstance.CheckNullvalue(Passed_value: deliver["id"]), "single")
                    cell.nameLbl.setNameTxt(Themes.sharedInstance.CheckNullvalue(Passed_value: deliver["id"]), "single")
                    let time = Themes.sharedInstance.CheckNullvalue(Passed_value: deliver["time_to_deliever"])
                    cell.time_Lbl.text = time == "0" ? "•••" : Themes.sharedInstance.ReturnDateTimeFormat(timestamp: time) + " at " + Themes.sharedInstance.ReturnTimeForChat(timestamp: time)
                }
            }
            cell.selectionStyle = .none
            cell_main = cell
        }
        return cell_main
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        
        //        if(isBeginEditing)
        //        {
        //
        //            if(chat_tableview.indexPathsForSelectedRows != nil)
        //            {
        //                let indexpath:[IndexPath] = chat_tableview.indexPathsForSelectedRows!
        //
        //                if(indexpath.count > 0)
        //                {
        //                    left_item.isEnabled = true
        //
        //                }
        //                else
        //                {
        //                    left_item.isEnabled = false
        //
        //                }
        //            }
        //            else
        //
        //            {
        //                left_item.isEnabled = false
        //
        //            }
        //        }
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        //        if(isBeginEditing)
        //        {
        //            if(chat_tableview.indexPathsForSelectedRows != nil)
        //            {
        //                let indexpath:[IndexPath] = chat_tableview.indexPathsForSelectedRows!
        //
        //                if(indexpath.count > 0)
        //                {
        //                    left_item.isEnabled = true
        //
        //                }
        //                else
        //                {
        //                    left_item.isEnabled = false
        //
        //                }
        //            }
        //            else
        //
        //            {
        //                left_item.isEnabled = false
        //
        //            }
        //        }
    }
    func headImageDidClick(_ cell: UUMessageCell, userId: String)
    {
        
    }
    func cellContentDidClick(_ cell: UUMessageCell, image contentImage: UIImage)
    {
        
    }
    func DidclickContentBtn(messagFrame:UUMessageFrame)
    {
        
    }
    func DidClickMenuAction(actioname:MenuAcion,index:IndexPath)
    {
        
    }
    func playerTime(_ TotalDuration: Double, currentime CurrentTime: Double) {
        
        let indexpath = NSIndexPath.init(row: pause_row, section: 0)
        
        let cellItem:UUMessageCell? = chat_tableview.cellForRow(at: indexpath as IndexPath) as? UUMessageCell
        if(cellItem != nil)
        {
            cellItem?.total = TotalDuration
            //self.messageFrame.message.progress = "\(CurrentTime)"
            
            cellItem?.btnContent.myProgressView.maximumValue = Float(TotalDuration)
            
            let precentage:CGFloat = CGFloat(((100.0*Double(CurrentTime))/Double(TotalDuration))/100.0);
            
            print("jjjjj","\(precentage):\(CurrentTime):\(TotalDuration)")
            //&& !slidePlay
            if(!(cellItem?.slideMove)!){
                
                let min = CurrentTime/60;
                let sec = CurrentTime.truncatingRemainder(dividingBy: 60) ;
                cellItem?.btnContent.second.text = String(format: "%02d:%02d", Int(min),Int(sec))
                //                print("current",cellItem?.audio.player.currentTime)
                cellItem?.audio.player.currentTime = CurrentTime
                cellItem?.messageFrame.message.progress = "\(CurrentTime)"
                
                if(CurrentTime == 0.0){
                    let min = TotalDuration/60;
                    let sec = TotalDuration.truncatingRemainder(dividingBy: 60) ;
                    cellItem?.btnContent.second.text = String(format: "%02d:%02d", Int(min),Int(sec))
                }
                
                cellItem?.btnContent.myProgressView.value = Float(CurrentTime)
                
            }
            
            //print("sss",cellItem?.messageFrame.message.progress!!)
        }
        
    }
    
    func uuavAudioPlayerBeiginPlay()
    {
        let indexpath = NSIndexPath.init(row: pause_row, section: 0)
        
        let cellItem:UUMessageCell? = chat_tableview.cellForRow(at: indexpath as IndexPath) as? UUMessageCell
        if(cellItem != nil){
            UIDevice.current.isProximityMonitoringEnabled = true
            print("\(UUAVAudioPlayer.sharedInstance().player.currentTime)")
            cellItem?.btnContent.didLoadVoice()
        }
        
    }
    
    func PausePlayingAudioIfAny()
    {
        for i in 0 ..< self.chatModel.dataSource.count
        {
            let indexpath = NSIndexPath.init(row: i, section: 0)
            
            let cellItemAll:UUMessageCell? = chat_tableview.cellForRow(at: indexpath as IndexPath) as? UUMessageCell
            
            if (i != pause_row)
            {
                
                cellItemAll?.is_paused = true
                cellItemAll?.btnContent.stopPlay()
                
            }
        }
        
        
    }
    
    
    func uuavAudioPlayerDidFinishPlay(_ Ispause: Bool) {
        
        let indexpath = NSIndexPath.init(row: pause_row, section: 0)
        //        cellForRow(at: indexpath as IndexPath) as! UUMessageCell
        
        let cellItem:UUMessageCell? = chat_tableview.cellForRow(at: indexpath as IndexPath) as? UUMessageCell
        if(cellItem != nil){
            cellItem?.is_paused = false
            
            if(!Ispause)
            {
                // finish playing
                UIDevice.current.isProximityMonitoringEnabled = false
                cellItem?.contentVoiceIsPlaying = false
                cellItem?.btnContent.stopPlay()
                UUAVAudioPlayer.sharedInstance().stopSound()
                
            }
            else
            {
                
                cellItem?.is_paused = true
                cellItem?.contentVoiceIsPlaying = true
                cellItem?.btnContent.stopPlay()
                
            }
        }
    }
    func uuavAudioPlayerBeiginLoadVoice()
    {
        
        let indexpath = NSIndexPath.init(row: pause_row, section: 0)
        
        let cellItem:UUMessageCell? = chat_tableview.cellForRow(at: indexpath as IndexPath) as? UUMessageCell
        if (cellItem != nil){
            cellItem?.btnContent.benginLoadVoice()
        }
        
        
    }
    @IBAction func btnContentClick(_ sender: Any)
    {
        
        //check each cell with audio and whether it is playing , then stop
        
        
        let row: NSInteger = (sender as AnyObject).tag
        
        pause_row = row
        initial = 1
        self.PausePlayingAudioIfAny()
        
        let indexpath = NSIndexPath.init(row: row, section: 0)
        
        let cellItem:UUMessageCell? = chat_tableview.cellForRow(at: indexpath as IndexPath) as? UUMessageCell
        
        if(cellItem != nil){
            if (cellItem?.messageFrame.message.type == MessageType(rawValue: 3)!) {
                
                //                print("jbhhhh",cellItem?.messageFrame.message.progress)
                
                if (!(cellItem?.contentVoiceIsPlaying)!) {
                    
                    if(cellItem?.songData != nil)
                    {
                        
                        //messageFrame.message.progress = "0.0"
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.VoicePlayHasInterrupt), object: nil)
                        cellItem?.contentVoiceIsPlaying = true
                        cellItem?.audio = UUAVAudioPlayer.sharedInstance()
                        cellItem?.audio.delegate = self
                        //audio.player.prepareToPlay()
                        //slidePlay = false
                        
                        cellItem?.slideMove = false
                        
                        if(cellItem?.messageFrame.message.progress != "0.0")
                        {
                            cellItem?.btnContent.startPlay()
                            
                            cellItem?.audio.playSong(with: cellItem?.songData)
                            
                            cellItem?.audio.player.currentTime = TimeInterval(Float((cellItem?.btnContent.myProgressView.value)!))
                            
                            cellItem?.audio.player.currentTime = TimeInterval(Float((cellItem?.messageFrame.message.progress)!)!)
                            
                            
                        }
                        else
                        {
                            
                            cellItem?.audio.playSong(with: cellItem?.songData)
                        }
                        
                        
                    }
                    
                }
                else
                {
                    
                    if(Double((cellItem?.messageFrame.message.progress)!) == Double((cellItem?.audio.player.duration)!))
                    {
                        
                        //self.btnContent.stopPlay()
                        self.uuavAudioPlayerDidFinishPlay(false)
                        
                    }
                    else
                    {
                        
                        //for pause
                        if(cellItem?.is_paused == false)
                        {
                            //slideMove = false
                            cellItem?.audio.player.pause()
                            cellItem?.audio.pause()
                            self.uuavAudioPlayerDidFinishPlay(true)
                            
                        }
                            
                            //play after initial
                            
                        else
                        {
                            
                            cellItem?.is_paused = false
                            cellItem?.btnContent.startPlay()
                            print("the time is \(String(describing: cellItem?.messageFrame.message.progress))")
                            cellItem?.slideMove = false
                            //slidePlay = true
                            cellItem?.audio.playSong(with: cellItem?.songData)
                            cellItem?.audio.player.currentTime = TimeInterval(Float((cellItem?.messageFrame.message.progress)!)!)
                            
                            
                        }
                    }
                }
            }
                
            else if cellItem?.messageFrame.message.type == MessageType(rawValue: 2)! {
                if cellItem?.messageFrame.message.from == MessageFrom(rawValue: 1)!
                    
                {
                    
                    let videoPath:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: cellItem!.messageFrame.message.thumbnail!, upload_detail: "upload_Path") as! String
                    
                    let videoURL = URL(fileURLWithPath: videoPath)
                    let player = AVPlayer(url: videoURL )
                    let playerViewController = AVPlayerViewController()
                    playerViewController.player = player
                    
                    (cellItem?.delegate as! UIViewController).presentView(playerViewController, animated: true) {
                        playerViewController.player!.play()
                    }
                }
                else
                {
                    let download_status:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: cellItem!.messageFrame.message.thumbnail!, upload_detail: "download_status") as! String
                    if(download_status == "0")
                    {
                        let videoPath:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: cellItem!.messageFrame.message.thumbnail!, upload_detail: "serverpath") as! String
                        let videoURL = URL(string: Themes.sharedInstance.getDownloadURL(videoPath))
                        let player = AVPlayer(url: videoURL! )
                        let playerViewController = AVPlayerViewController()
                        playerViewController.player = player
                        (cellItem?.delegate as! UIViewController).presentView(playerViewController, animated: true) {
                            playerViewController.player!.play()
                        }
                    }
                    else
                    {
                        
                        let videoPath:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: cellItem!.messageFrame.message.thumbnail!, upload_detail: "upload_Path") as! String
                        //                        let video_Path:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: cellItem!.messageFrame.message.thumbnail!, upload_detail: "serverpath") as! String!
                        let videoURL = URL(fileURLWithPath: videoPath)
                        let player = AVPlayer(url: videoURL )
                        let playerViewController = AVPlayerViewController()
                        playerViewController.player = player
                        (cellItem?.delegate as! UIViewController).presentView(playerViewController, animated: true) {
                            playerViewController.player!.play()
                        }
                    }
                }
            }
            else if cellItem?.messageFrame.message.type == MessageType(rawValue: 1)! {
                
                if (cellItem?.btnContent.backImageView != nil)
                {
                    let configuration = ImageViewerConfiguration { config in
                        config.imageView = cellItem?.btnContent.backImageView
                    }
                    self.presentView(ImageViewerController(configuration: configuration), animated: true)
                }
                
                if (cellItem?.delegate is UIViewController) {
                    
                    (cellItem?.delegate as! UIViewController).view.endEditing(true)
                    
                }
            }
                
            else if cellItem?.messageFrame.message.type == MessageType(rawValue: 0)! {
                
                cellItem?.btnContent.becomeFirstResponder()
                let menu = UIMenuController.shared
                menu.setTargetRect((cellItem?.btnContent.frame)!, in: (cellItem?.btnContent.superview!)!)
                menu.setMenuVisible(true, animated: true)
                
            }
            
            if (cellItem?.messageFrame.message.type == MessageType(rawValue: 6)!)
            {
                
                cellItem?.delegate?.DidclickContentBtn(messagFrame: (cellItem?.messageFrame)!)
                
            }
        }
        
    }
    
    func sliderValueChanged(slider:UISlider)
    {
        
        print(slider.value)
        
        let row = slider.tag
        let indexpath = NSIndexPath.init(row: row, section: 0)
        
        let cellItem:UUMessageCell? = chat_tableview.cellForRow(at: indexpath as IndexPath) as? UUMessageCell
        
        print("cell is ", cellItem! )
        if(cellItem != nil){
            if(self.pause_row == row){
                print(row)
                
                
                
                //         if(self.pause_row != row && self.initial == 1){
                //
                //            let indexpath = NSIndexPath.init(row: self.pause_row, section: 0)
                //
                //            let cellItem:UUMessageCell = self.chat_tableview.cellForRow(at: indexpath as IndexPath) as! UUMessageCell
                //            cellItem.audio.player.pause()
                //            cellItem.audio.pause()
                //            cellItem.uuavAudioPlayerDidFinishPlay(true)
                //        }
                
                if(cellItem?.total != nil)
                {
                    
                    //slideMove = true
                    //                    print("total value : ", cellItem?.total)
                    
                    //let min:CGFloat = CGFloat((Double(slider.value)*Double(self.total))/60);
                    //let precentage:CGFloat = CGFloat(Double(slider.value)*Double(self.total));
                    
                    cellItem?.messageFrame.message.progress = "\(slider.value)"
                    cellItem?.audio.player.currentTime = TimeInterval(slider.value)
                    
                    if(slider.value == 0.0){
                        
                        let upload_Path:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: cellItem!.messageFrame.message.thumbnail!, upload_detail: "upload_Path") as! String
                        
                        cellItem?.btnContent.second.text =  cellItem?.ReturnruntimeDuration(sourceMovieURL: URL(fileURLWithPath:upload_Path))
                        
                    }else{
                        
                        let min = slider.value/60;
                        let sec = slider.value.truncatingRemainder(dividingBy: 60) ;
                        cellItem?.btnContent.second.text = String(format: "%02d:%02d", Int(min),Int(sec))
                        
                    }
                    
                    cellItem?.audio.player.pause()
                    cellItem?.audio.pause()
                    self.uuavAudioPlayerDidFinishPlay(true)
                    
                }
                else
                {
                    //print("self.total at else ", self.total)
                    
                    cellItem?.messageFrame.message.progress = "\(slider.value)"
                    
                    if(slider.value == 0.0){
                        
                        let upload_Path:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: cellItem!.messageFrame.message.thumbnail!, upload_detail: "upload_Path") as! String
                        
                        cellItem?.btnContent.second.text = cellItem?.ReturnruntimeDuration(sourceMovieURL:URL(fileURLWithPath:upload_Path))
                        
                    }else{
                        
                        let min = slider.value/60;
                        let sec = slider.value.truncatingRemainder(dividingBy: 60);
                        
                        cellItem?.btnContent.second.text = String(format: "%02d:%02d", Int(min),Int(sec))
                        
                    }
                    
                    
                }
            }else{
                
                let row = slider.tag
                
                let indexpath = NSIndexPath.init(row: row, section: 0)
                
                let cellItem:UUMessageCell? = chat_tableview.cellForRow(at: indexpath as IndexPath) as? UUMessageCell
                
                if(cellItem != nil)
                {
                    
                    cellItem?.messageFrame.message.progress = "\(slider.value)"
                    //cellItem.audio.player.currentTime = TimeInterval(slider.value)
                    
                    if(slider.value == 0.0){
                        
                        let upload_Path:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: cellItem!.messageFrame.message.thumbnail!, upload_detail: "upload_Path") as! String
                        if(upload_Path != "")
                        {
                            cellItem?.btnContent.second.text =  cellItem?.ReturnruntimeDuration(sourceMovieURL: URL(fileURLWithPath:upload_Path))
                        }
                        
                    }else{
                        
                        let min = slider.value/60;
                        let sec = slider.value.truncatingRemainder(dividingBy: 60);
                        cellItem?.btnContent.second.text = String(format: "%02d:%02d", Int(min),Int(sec))
                        
                    }
                }
            }
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func DidclickBack(_ sender: Any) {
        self.pop(animated: true)
    }
    
    func addNotificationListener() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.reloadData), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            weak.bottom_tableView.reloadData()
        }
    }
    
    func removeNotificationListener() {
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        removeNotificationListener()
    }
    
}

extension MessageInfoViewController : AppDelegateDelegates {
    func receiveMessageInfo(response: [String : Any]) {
        Response = response
    }
}

