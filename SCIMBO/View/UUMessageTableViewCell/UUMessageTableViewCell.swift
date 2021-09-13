//
//  UUMessageCell
//  ChatApp
//
//  Created by Casp iOS on 29/12/16.
//  Copyright © 2016 Casp iOS. All rights reserved.
//

import UIKit
import SDWebImage
import AVFoundation
import AVKit
import ACPDownload
enum MenuAcion {
    case delete, Forward, Reply, Info,star,copy
}
protocol UUMessageCellDelegate : class {
    
    func headImageDidClick(_ cell: UUMessageCell, userId: String)
    func cellContentDidClick(_ cell: UUMessageCell, image contentImage: UIImage)
    func DidclickContentBtn(messagFrame:UUMessageFrame)
    func DidClickMenuAction(actioname:MenuAcion,index:IndexPath)
    func PasReplyDetail(index:IndexPath,ReplyRecordID:String, isStatus: Bool)
    func PasPersonDetail(id:String)
    
}
class UUMessageCell: UITableViewCell, UUMessageContentButtonDelegate {
    
    var autoCircularProgressView:MRCircularProgressView = MRCircularProgressView()
    var loaderView:UIView = UIView()
    
    var isFromUrlPrev = false
    var slidePlay = false
    var slideMove:Bool = false
    var currTime:Double!
    var total:Double!
    var timer = Timer()
    var is_paused = false
    var player: AVAudioPlayer!
    var voiceURL = ""
    var songData: Data!
    var audio: UUAVAudioPlayer!
    var headImageBackView: UIView!
    var contentVoiceIsPlaying = false
    var chatModel:ChatModel=ChatModel()
    var labelTime: UILabel!
    var labelNum: UILabel!
    var DocumentWrapperView: UIView!
    var btnHeadImage: UIButton!
    var blueDot: UIImageView!
    var StatusMark: UIImageView!
    var UsernameLbl: UILabel!
    var _bubbleImage: UIImageView!
    var Player_Image: UIImageView!
    var contact_view: UIView!
    var contact_name: UILabel!
    var profile_pic: UIImageView!
    var save_contact:UIButton!
    var message:UIButton!
    var send_message:Bool = Bool()
    
    var contacts_ArrObj = [NSObject]()
    var contactNoArr:NSMutableArray = NSMutableArray()
    var _textView: UITextView!
    var Urlpreview:UIView!
    var linkImage:UIImageView!
    var descLabel:UILabel!
    var titleLabel:UILabel!
    var DocimageView: UIImageView!
    var DocDetailLbl: UILabel!
    var DocNameLbl: UILabel!
    var PdfHeaderImageView: UIImageView!
    var currentProgress:CGFloat = CGFloat()
    var btnContent: UUMessageContentButton!
    var messageFrame: UUMessageFrame!
    var line:UIView!
    var line_vertical:UIView!
    
    weak var delegate: UUMessageCellDelegate?
    let ChatMargin:CGFloat = 10
    let ChatIconWH:CGFloat = 0
    let ChatPicWH:CGFloat = 200
    let ChatContentW:CGFloat = 180
    let ChatTimeMarginW:CGFloat = 15
    let ChatTimeMarginH:CGFloat = 10
    let ChatContentTop:CGFloat = 15
    let ChatContentLeft:CGFloat = 60
    let  ChatContentBottom:CGFloat = 15
    let ChatContentRight:CGFloat = 15
    let ChatTimeFont:UIFont = UIFont.systemFont(ofSize: 10.0)
    let ChatContentFont:UIFont = UIFont.systemFont(ofSize: 15.0)
    var MyTimer:Timer?
    var RowIndex:IndexPath = IndexPath()
    var ReplyRecordID:String = String()
    var ReplyView = Bundle.main.loadNibNamed("ReplyDetailView", owner: self, options: nil)?[0] as! ReplyDetailView
    var isCaption : Bool = Bool()
    var isFromStatus : Bool = Bool()
    var TagRangeArr : [NSRange] = [NSRange]()
    var TagIdArr : [String] = [String]()
    var ReplyrangeArr : [NSRange] = [NSRange]()
    var ReplyIdArr : [String] = [String]()
    var TempPayload = ""
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.autoresizesSubviews=true;
        self.contentView.autoresizesSubviews=true;
        self.backgroundColor = UIColor.clear
        self.selectionStyle = .none
        // 1Created
        self.labelTime = UILabel()
        self.labelTime.textAlignment = .left
        self.labelTime.textColor = UIColor.gray
        self.labelTime.font = ChatTimeFont
        
        self.UsernameLbl = UILabel()
        self.UsernameLbl.textAlignment = .left
        self.UsernameLbl.textColor = UIColor.lightGray
        self.UsernameLbl.font=UIFont.systemFont(ofSize:10.0)
        UsernameLbl.isHidden = true
        //self.contentView.addSubview(self.labelTime)
        self.StatusMark = UIImageView()
        // 2Create Profile
        // [self.contentView addSubview:headImageBackView];
        //  [headImageBackView addSubview:self.btnHeadImage];
        self.blueDot = UIImageView()
        self.blueDot.image = UIImage(named: "mic")!
        // [self.contentView addSubview:self.blueDot];
        // 3、Create Avatar subscript
        self.labelNum = UILabel()
        DocumentWrapperView = UIView()
        // 4、Create content
        self.btnContent = UUMessageContentButton(type: .custom)
        self.btnContent.titleLabel!.font = ChatContentFont
        self.btnContent.titleLabel!.numberOfLines = 0
        // self.btnContent.addTarget(self, action: #selector(self.btnContentClick), for: .touchUpInside)
        _textView = UITextView()
        _bubbleImage = UIImageView()
        self.Player_Image = UIImageView()
        self.profile_pic = UIImageView()
        self.save_contact = UIButton()
        self.message = UIButton()
        self.line = UIView()
        self.contact_view = UIView()
        self.line_vertical = UIView()
        self.contact_name = UILabel()
        PdfHeaderImageView = UIImageView()
        Urlpreview = UIView()
        linkImage = UIImageView()
        descLabel = UILabel()
        titleLabel = UILabel()
        loaderView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        self.contentView.addSubview(_bubbleImage)
        self.contentView.addSubview(_textView)
        self.contentView.addSubview(self.btnContent)
        self.contentView.addSubview(self.labelNum)
        self.contentView.addSubview(StatusMark)
        
        self._bubbleImage.addSubview(Urlpreview)
        self.Urlpreview.addSubview(descLabel)
        self.Urlpreview.addSubview(titleLabel)
        self.Urlpreview.addSubview(linkImage)
        
        self.btnContent.addSubview(self.contact_view)
        self.contact_view.addSubview(self.line)
        self.contact_view.addSubview(self.line_vertical)
        self.contact_view.addSubview(self.save_contact)
        self.contact_view.addSubview(self.message)
        
        self.btnContent.addSubview(DocumentWrapperView)
        self.btnContent.addSubview(ReplyView)
        ReplyView.isHidden = true
        DocimageView = UIImageView()
        DocDetailLbl = UILabel()
        DocNameLbl = UILabel()
        DocumentWrapperView.addSubview(DocimageView)
        self.btnContent.addSubview(DocDetailLbl)
        DocumentWrapperView.addSubview(DocNameLbl)
        DocumentWrapperView.addSubview(PdfHeaderImageView)
        DocumentWrapperView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        DocumentWrapperView.layer.cornerRadius = 3.0;
        DocumentWrapperView.clipsToBounds = true;
        DocumentWrapperView.isHidden = true;
        DocumentWrapperView.isUserInteractionEnabled = false;
        self.contentView.addSubview(self.UsernameLbl)
        
        let ReplyTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DidclickReplyView))
        ReplyTap.numberOfTapsRequired = 1
        ReplyView.addGestureRecognizer(ReplyTap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.sensorStateChange), name: UIDevice.proximityStateDidChangeNotification, object: nil)
        contentVoiceIsPlaying = false
        self.audio = UUAVAudioPlayer.sharedInstance()
        //  self.audio.delegate = self
    }
    @objc func DidclickReplyView()
    {
        self.delegate?.PasReplyDetail(index:RowIndex,ReplyRecordID:ReplyRecordID, isStatus : isFromStatus)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func returnHeight()->CGFloat
    {
        return _bubbleImage.frame.size.height
    }
    
    func makeMaskView(_ view: UIView, with image: UIImage) {
        let imageViewMask = UIImageView(image: image)
        imageViewMask.frame = view.frame.insetBy(dx: CGFloat(0.0), dy: CGFloat(0.0))
        view.layer.mask = imageViewMask.layer
    }
    @objc func sensorStateChange(_ notification: NotificationCenter) {
        if UIDevice.current.proximityState == true {
            print("Device is close to user")
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord)
                
            }
            catch
            {
            }
        }
        else {
            print("Device is not close to user")
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            }
            catch {
            }
        }
    }
    //   Avatar Click
    func btnHeadImageClick(_ button: UIButton)
    {
    }
    func setSeenStatus(_ Status: String)
    {
    }
    
    func GetThumbnail(docID:String)->String
    {
        
        var thumbnail :String = String()
        let ChatArr:NSArray=DatabaseHandler.sharedInstance.FetchFromDatabaseWithLimit(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "doc_id", Predicatefromat: "==", FetchString: docID, Limit: 0, SortDescriptor: nil) as NSArray
        if(ChatArr.count > 0)
        {
            for i in 0 ..< ChatArr.count {
                let ResponseDict = ChatArr[i] as! NSManagedObject
                thumbnail=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "thumbnail"));
            }
        }
        
        return thumbnail
        
    }
    
    func set_MessageFrame(_ messageFrame: UUMessageFrame!,CheckLastmessage:Bool,IndexPath:NSIndexPath) {
        if(messageFrame.message.timestamp != nil)
        {
            self.btnContent.myProgressView.isHidden = true
            self.messageFrame = messageFrame
            let message:UUMessage! = messageFrame.message
            _ = ""

            messageFrame.message.thumbnail = GetThumbnail(docID: messageFrame.message.doc_id)
            
            
            
            let arr = Themes.sharedInstance.getID_Range_Payload_Name(message: messageFrame.message.payload)
            self.TagIdArr = arr[0] as! [String]
            
            TagRangeArr = arr[1] as! [NSRange]
            
            TempPayload = arr[2] as! String
            
            

            //prepare for reuse
            self.btnContent.voiceBackView.isHidden = true
            self.btnContent.isHidden = true;
            self.Player_Image.isHidden = true
            self.btnContent.downloadView.isHidden = true
            DocDetailLbl.isHidden = true
            DocumentWrapperView.isHidden = true
            ReplyView.isHidden = true
            UsernameLbl.isHidden = true
            switch (message.type)
            {
            case MessageType(rawValue: 0)!:
                //        DispatchQueue.main.async {
                //setButtonContent
                self.setTextView(messageFrame,IndexPath: IndexPath)
                self.setTimeLabel(messageFrame)
                self.setBubble(messageFrame,CheckLastmessage: CheckLastmessage)
                self.addStatusIcon(messageFrame)
                self.setStatusIcon(messageFrame)
                self.setNeedsLayout()
                messageFrame.message.messageheight =   self.returnHeight()
                self.profile_pic.isHidden = true
                self.save_contact.isHidden = true
                self.message.isHidden = true
                self.line.isHidden = true
                self.contact_view.isHidden = true
                self.line_vertical.isHidden = true
                self.contact_name.isHidden = true
                self._bubbleImage.isHidden=true
                self._bubbleImage.isHidden=false
                self._textView.isHidden=false
                self.btnContent.isHidden=true
                //self._textView.textColor = UIColor.black;
                self.labelNum.textColor = UIColor.lightGray
                Themes.sharedInstance.setShadowonLabel(self.labelNum, UIColor.clear)
                self.loaderView.isHidden = true
                self.Player_Image.isHidden = true
                Urlpreview.isHidden = true
                linkImage.isHidden = true
                descLabel.isHidden = true
                titleLabel.isHidden = true
                if(message.from == MessageFrom(rawValue: 1))
                {
                    var text = self.labelNum.text!
                    if(message.is_deleted == "1")
                    {
                        self.StatusMark.isHidden = true
                        
                        if(text.contains("★"))
                        {
                            text = text.replacingOccurrences(of: "★", with: "")
                        }
                    }
                    else
                    {
                        self.StatusMark.isHidden = false
                        text = self.labelNum.text!
                    }
                    self.labelNum.text = text
                    
                }
                //    }
                break;
            case MessageType(rawValue: 1)!:
                //                DispatchQueue.main.async {
                
                self.isCaption = (TempPayload.length == 0) ? false : true
                if(self.isCaption)
                {
                    self.setMessageFrameForType14(messageFrame, CheckLastmessage: CheckLastmessage, IndexPath: IndexPath, Type:1)
                }
                else
                {
                    self.setMessageFrameForType1(messageFrame, CheckLastmessage: CheckLastmessage, IndexPath: IndexPath)
                }
                
                //              }
                break;
            // messageFrame.message.messageheight = returnHeight()
            case MessageType(rawValue: 2)!:
                //                DispatchQueue.main.async {
                
                self.isCaption = (TempPayload.length == 0) ? false : true
                if(self.isCaption)
                {
                    self.setMessageFrameForType14(messageFrame, CheckLastmessage: CheckLastmessage, IndexPath: IndexPath, Type:2)
                }
                else
                {
                    self.setMessageFrameForType2(messageFrame, CheckLastmessage: CheckLastmessage, IndexPath: IndexPath)
                }
                //                }
                break
            case MessageType(rawValue: 3)!:
                
                
                self.profile_pic.isHidden = true
                self.save_contact.isHidden = true
                self.message.isHidden = true
                self.line.isHidden = true
                self.contact_view.isHidden = true
                self.line_vertical.isHidden = true
                self.contact_name.isHidden = true
                self.btnContent.downloadView.tintColor = UIColor.blue
                self.btnContent.backImageView.isHidden = true
                self.btnContent.voiceBackView.isHidden = false
                self.btnContent.backgroundColor = UIColor.clear
                //      self.btnContent.second!.text = "0.\(message.strVoiceTime)"
                self.btnContent.titleLabel?.textColor = UIColor.clear
                self.btnContent.layer.cornerRadius = 5.0
                self.btnContent.clipsToBounds = true
                self.labelNum.textColor = UIColor.lightGray
                Themes.sharedInstance.setShadowonLabel(self.labelNum, UIColor.clear)
                self.loaderView.isHidden = true
                self._textView.isHidden = true
                self.btnContent.isHidden = false
                self.btnContent.myProgressView.isHidden = false
                self.Urlpreview.isHidden = true
                self.linkImage.isHidden = true
                self.descLabel.isHidden = true
                self.titleLabel.isHidden = true
                self.SetAudioFrame(messageFrame, IndexPath: IndexPath)
                self.setTimeLabel(messageFrame)
                self.setBubble(messageFrame,CheckLastmessage: CheckLastmessage)
                self.btnContent.setFrame(messageFrame)
                let download_status:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "download_status") as! String
                self.addStatusIcon(messageFrame)
                self.setStatusIcon(messageFrame)
                let upload_status:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "upload_status") as! String
                if message?.from == MessageFrom(rawValue: 1)!
                {
                    self.btnContent.userImageView.setProfilePic(Themes.sharedInstance.Getuser_id(), "")
                    let upload_Path:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "upload_Path") as! String
                    if(download_status == "2")
                    {
                        if(upload_status == "1")
                        {
                            self.btnContent.play_pause.isHidden = false;
                            self.btnContent.removeLoading()
                            
                        }
                        else
                        {
                            self.btnContent.startLoading()
                            self.btnContent.play_pause.isHidden = true;
                        }
                        
                        if(upload_Path != "")
                        {
                            if FileManager.default.fileExists(atPath: upload_Path) {
                                let upload_PathData = NSData(contentsOf:URL(fileURLWithPath:upload_Path))
                                self.btnContent.second.isHidden = false
                                self.btnContent.second.text = self.ReturnruntimeDuration(sourceMovieURL:URL(fileURLWithPath:upload_Path))
                                self.btnContent.second.textColor = UIColor.lightGray
                                self.songData = upload_PathData as Data?
                            }
                            else
                            {
                                let serverpath:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "serverpath") as! String
                                
                                let param:NSDictionary = ["download_status":"0"]
                                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Upload_Details, FetchString: messageFrame.message.thumbnail!, attribute: "upload_data_id", UpdationElements: param)

                                DownloadHandler.sharedinstance.handleDownLoad(true)

                                let upload_PathData = NSData(contentsOf:URL(string:serverpath)!)
                                self.btnContent.second.isHidden = false
                                self.btnContent.second.text = self.ReturnruntimeDuration(sourceMovieURL:URL(string:serverpath)!)
                                self.btnContent.second.textColor = UIColor.lightGray
                                self.songData = upload_PathData as Data?
                            }
                        }
                    }
                    else if(download_status == "1")
                    {
                        self.btnContent.startDownloading()
                        self.btnContent.play_pause.isHidden = true;
                        self.SetLoader_data(messageFrame)
                    }
                    else if(download_status == "0")
                    {
                        self.btnContent.delegate = self
                        self.btnContent.downloadView.isHidden = false
                        self.btnContent.downloadView.frame = CGRect(x: self.btnContent.play_pause.frame.origin.x, y: self.btnContent.play_pause.frame.origin.y, width: self.btnContent.play_pause.frame.size.width + 5, height: self.btnContent.play_pause.frame.size.height + 5)
                        self.btnContent.downloadView.isUserInteractionEnabled = true
                        self.btnContent.downloadView.setIndicatorStatus(.none)
                        self.btnContent.play_pause.isHidden = true;
                        self.songData = nil
                    }
                }
                else
                    
                {
                    let userimage:String! = self.FetchContactImage(messageFrame)
                    if(userimage != nil && userimage != "")
                    {
                        let nsURL = URL(string:userimage!)! as  URL
                        self.btnContent.userImageView.sd_setImage(with: nsURL, placeholderImage: #imageLiteral(resourceName: "avatar"), options: .refreshCached)
                    }
                    else
                    {
                        self.btnContent.userImageView.image = #imageLiteral(resourceName: "avatar")
                    }
                    
                    var upload_Path:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "upload_Path") as! String
                    
                    let mediaDetailArr = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Data_Usage_Settings, attribute: "user_id", FetchString: Themes.sharedInstance.Getuser_id(), SortDescriptor: nil) as! NSArray
                    
                    if(mediaDetailArr.count > 0)
                    {
                        var autodownload : Bool = true
                        if((mediaDetailArr[0] as! NSManagedObject).value(forKey: "audio") as! String == "0" && download_status == "0")
                        {
                            autodownload = false
                        }
                        else if((mediaDetailArr[0] as! NSManagedObject).value(forKey: "audio") as! String == "1" && (UIApplication.shared.delegate as! AppDelegate).byreachable == "2" && download_status == "0")
                        {
                            autodownload = false
                        }
                        else if((mediaDetailArr[0] as! NSManagedObject).value(forKey: "audio") as! String != "0" && (UIApplication.shared.delegate as! AppDelegate).byreachable == "" && download_status == "0")
                        {
                            autodownload = false
                        }
                        if(!autodownload)
                        {
                            
                            self.btnContent.delegate = self
                            self.btnContent.downloadView.isHidden = false
                            self.btnContent.downloadView.frame = CGRect(x: self.btnContent.play_pause.frame.origin.x, y: self.btnContent.play_pause.frame.origin.y, width: self.btnContent.play_pause.frame.size.width + 5, height: self.btnContent.play_pause.frame.size.height + 5)
                            self.btnContent.downloadView.isUserInteractionEnabled = true
                            self.btnContent.downloadView.setIndicatorStatus(.none)
                            self.btnContent.play_pause.isHidden = true;
                            self.songData = nil
                        }
                        else
                        {
                            if(download_status == "1")
                            {
                                self.btnContent.startDownloading()
                                self.btnContent.play_pause.isHidden = true;
                                self.SetLoader_data(messageFrame)
                            }
                            else  if(download_status == "2")
                            {
                                self.btnContent.play_pause.isHidden = false;
                                self.btnContent.removeLoading()
                                upload_Path = upload_Path.replacingOccurrences(of: "file:///", with: "")
                                
                                if(upload_Path != "")
                                {
                                    if FileManager.default.fileExists(atPath: upload_Path) {
                                        let upload_PathData = NSData(contentsOf:URL(fileURLWithPath:upload_Path))
                                        
                                        self.songData = upload_PathData as Data?
                                        self.btnContent.second.isHidden = false
                                        self.btnContent.second.text = self.ReturnruntimeDuration(sourceMovieURL:URL(fileURLWithPath:upload_Path))
                                        self.btnContent.second.textColor = UIColor.lightGray
                                    }
                                    else
                                    {
                                        let serverpath:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "serverpath") as! String
                                        
                                        let param:NSDictionary = ["download_status":"0"]
                                        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Upload_Details, FetchString: messageFrame.message.thumbnail!, attribute: "upload_data_id", UpdationElements: param)

                                        DownloadHandler.sharedinstance.handleDownLoad(true)

                                        let upload_PathData = NSData(contentsOf:URL(string:serverpath)!)
                                        
                                        self.songData = upload_PathData as Data?
                                        self.btnContent.second.isHidden = false
                                        self.btnContent.second.text = self.ReturnruntimeDuration(sourceMovieURL:URL(string:serverpath)!)
                                        self.btnContent.second.textColor = UIColor.lightGray
                                    }
                                }
                            }
                        }
                    }
                    else{
                        if(download_status == "1")
                        {
                            self.btnContent.startDownloading()
                            self.btnContent.play_pause.isHidden = true;
                            self.SetLoader_data(messageFrame)
                        }
                        else  if(download_status == "2")
                        {
                            self.btnContent.play_pause.isHidden = false;
                            self.btnContent.removeLoading()
                            upload_Path = upload_Path.replacingOccurrences(of: "file:///", with: "")
                            
                            if(upload_Path != "")
                            {
                                if FileManager.default.fileExists(atPath: upload_Path) {
                                    let upload_PathData = NSData(contentsOf:URL(fileURLWithPath:upload_Path))
                                    
                                    self.songData = upload_PathData as Data?
                                    self.btnContent.second.isHidden = false
                                    self.btnContent.second.text = self.ReturnruntimeDuration(sourceMovieURL:URL(fileURLWithPath:upload_Path))
                                    self.btnContent.second.textColor = UIColor.lightGray
                                }
                                else
                                {
                                    let serverpath:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "serverpath") as! String
                                    
                                    let param:NSDictionary = ["download_status":"0"]
                                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Upload_Details, FetchString: messageFrame.message.thumbnail!, attribute: "upload_data_id", UpdationElements: param)

                                    DownloadHandler.sharedinstance.handleDownLoad(true)

                                    let upload_PathData = NSData(contentsOf:URL(string:serverpath)!)
                                    
                                    self.songData = upload_PathData as Data?
                                    self.btnContent.second.isHidden = false
                                    self.btnContent.second.text = self.ReturnruntimeDuration(sourceMovieURL:URL(string:serverpath)!)
                                    self.btnContent.second.textColor = UIColor.lightGray
                                }
                            }
                        }
                    }
                }
            case MessageType(rawValue: 4)!:
                
                //mapImage.isHidden = true
                //pin.isHidden = true
                self.profile_pic.isHidden = true
                self.save_contact.isHidden = true
                self.message.isHidden = true
                self.line.isHidden = true
                self.contact_view.isHidden = true
                self.line_vertical.isHidden = true
                self.contact_name.isHidden = true
                Urlpreview.isHidden = false
                linkImage.isHidden = false
                descLabel.isHidden = false
                titleLabel.isHidden = false
                self.Player_Image.isHidden = true
                PdfHeaderImageView.isHidden = true
                //isFromUrlPrev = true
                self.setLinkFrame()
                self.setTextView(messageFrame,IndexPath: IndexPath)
                //setLink(messageFrame, IndexPath: IndexPath)
                self.setTimeLabel(messageFrame)
                self.setBubble(messageFrame,CheckLastmessage: CheckLastmessage)
                self.addStatusIcon(messageFrame)
                self.setStatusIcon(messageFrame)
                
                self.setUrlPreviewFrame(messageFrame, IndexPath: IndexPath)
                self.setNeedsLayout()
                messageFrame.message.messageheight = returnHeight()
                _bubbleImage.isHidden = true
                _bubbleImage.isHidden = false
                //_linkView.isHidden = true
                _textView.isHidden = false
                self.btnContent.isHidden=true
                // added Attributed textview
                //_textView.textColor = UIColor.black;
                // Urlpreview.backgroundColor = UIColor.red;
                labelNum.textColor = UIColor.lightGray
                loaderView.isHidden = true
                break;
            case MessageType(rawValue: 5)!:
                //self.setTextView(messageFrame,IndexPath: IndexPath)
                self.btnContent.backImageView.isHidden = true
                self.btnContent.voiceBackView.isHidden = false
                self.btnContent.backgroundColor = UIColor.clear
                //      self.btnContent.second!.text = "0.\(message.strVoiceTime)"
                self.btnContent.titleLabel?.textColor = UIColor.clear
                self.btnContent.layer.cornerRadius = 5.0
                self.btnContent.clipsToBounds = true
                self.btnContent.second.text = messageFrame.message.contact_name
                self.labelNum.textColor = UIColor.lightGray
                Themes.sharedInstance.setShadowonLabel(self.labelNum, UIColor.clear)
                self.loaderView.isHidden = true
                self._textView.isHidden = true
                self.btnContent.isHidden = false
                self.profile_pic.isHidden = false
                self.save_contact.isHidden = false
                self.message.isHidden = false
                self.Urlpreview.isHidden = true
                self.line.isHidden = false
                self.contact_view.isHidden = false
                self.line_vertical.isHidden = false
                self.SetAudioFrame(messageFrame, IndexPath: IndexPath)
                self.setTimeLabel(messageFrame)
                self.setBubble(messageFrame,CheckLastmessage: CheckLastmessage)
                self.btnContent.setFrame(messageFrame)
                self.setProfile()
                self.addStatusIcon(messageFrame)
                self.setStatusIcon(messageFrame)
                //contact profile
                self.btnContent.userImageView.isHidden = false
                if(messageFrame.message.chat_type == "single"){
                    if(messageFrame.message.contact_id == messageFrame.message.to)
                    {
                        if(messageFrame.message.contact_profile == "nil"){
                            
                            if(self.checkFavContact(phone: messageFrame.message.contact_phone)){
                                self.btnContent.userImageView.sd_setImage(with: URL(string: self.getProfileImage(phone: messageFrame.message.contact_phone)),placeholderImage: UIImage(named: "avatar"), options: .refreshCached)
                            }
                            else
                            {
                                self.btnContent.userImageView.image = #imageLiteral(resourceName: "avatar")
                            }
                        }else{
                            self.btnContent.userImageView.sd_setImage(with: URL(string: messageFrame.message.contact_profile),placeholderImage: UIImage(named: "avatar"), options: .refreshCached)
                        }
                    }else{
                        self.btnContent.userImageView.sd_setImage(with: URL(string: messageFrame.message.contact_profile),placeholderImage: UIImage(named: "avatar"), options: .refreshCached)
                    }
                }else{
                    self.btnContent.userImageView.sd_setImage(with: URL(string: messageFrame.message.contact_profile),placeholderImage: UIImage(named: "avatar"), options: .refreshCached)
                }
                
                //self.setProfile()
                messageFrame.message.messageheight =   self.returnHeight()
                break;
                
            case MessageType(rawValue: 6)!:
                //        DispatchQueue.main.async {
                self.profile_pic.isHidden = true
                self.save_contact.isHidden = true
                self.message.isHidden = true
                self.line.isHidden = true
                self.contact_view.isHidden = true
                self.line_vertical.isHidden = true
                self.contact_name.isHidden = true
                DocDetailLbl.isHidden = false
                self.Urlpreview.isHidden = true
                self.linkImage.isHidden = true
                self.descLabel.isHidden = true
                self.titleLabel.isHidden = true
                if(message.docType == "1")
                {
                    PdfHeaderImageView.isHidden = false
                    messageFrame.message.messageheight = 153;
                }
                else
                {
                    PdfHeaderImageView.isHidden = true
                    messageFrame.message.messageheight = 73;
                }
                let upload_status:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "upload_status") as! String
                self.btnContent.downloadView.tintColor = UIColor.blue
                self.btnContent.backImageView.isHidden = true
                self.btnContent.voiceBackView.isHidden = true
                self.btnContent.titleLabel?.textColor = UIColor.clear
                self.btnContent.layer.cornerRadius = 5.0
                self.btnContent.clipsToBounds = true
                self.labelNum.textColor = UIColor.lightGray
                Themes.sharedInstance.setShadowonLabel(self.labelNum, UIColor.clear)
                self.loaderView.isHidden = true
                self._textView.isHidden = true
                self.btnContent.isHidden = false
                self.DocumentWrapperView.isHidden = false
                self.SetAudioFrame(messageFrame, IndexPath: IndexPath)
                self.setWrapperView(messageFrame)
                self.setTimeLabel(messageFrame)
                self.setBubble(messageFrame,CheckLastmessage: CheckLastmessage)
                self.SetDocumentView(messageFrame)
                self.SetDocumentDetail(messageFrame)
                self.btnContent.downloadView.frame = CGRect(x: self.DocNameLbl.frame.origin.x+self.DocNameLbl.frame.size.width+5, y: self.DocNameLbl.frame.origin.y, width: 25, height: 25)
                self.SetLoader_data(messageFrame)
                self.btnContent.userImageView.setProfilePic(Themes.sharedInstance.Getuser_id(), "")
                //    let serverpath:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "serverpath") as! String!
                let download_status:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "download_status") as! String
                self.addStatusIcon(messageFrame)
                self.setStatusIcon(messageFrame)
                if message?.from == MessageFrom(rawValue: 1)!
                {
                    let upload_Path:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "upload_Path") as! String
                    
                    if(upload_Path != "")
                    {
                        if FileManager.default.fileExists(atPath: upload_Path) {
                            if(upload_status == "1")
                            {
                                self.btnContent.play_pause.isHidden = false;
                                self.btnContent.removeLoading()
                            }
                            else
                            {
                                self.btnContent.startLoading()
                                self.btnContent.play_pause.isHidden = true;
                            }
                            let upload_PathData = NSData(contentsOf:URL(fileURLWithPath:upload_Path))
                            self.btnContent.second.isHidden = false
                            self.btnContent.second.text = self.ReturnruntimeDuration(sourceMovieURL:URL(fileURLWithPath:upload_Path))
                            self.btnContent.second.textColor = UIColor.lightGray
                            self.songData = upload_PathData as Data?
                        }
                        else
                        {
                            let serverpath:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "serverpath") as! String
                            
                            let param:NSDictionary = ["download_status":"0"]
                            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Upload_Details, FetchString: messageFrame.message.thumbnail!, attribute: "upload_data_id", UpdationElements: param)

                            DownloadHandler.sharedinstance.handleDownLoad(true)

                            if(upload_status == "1")
                            {
                                self.btnContent.play_pause.isHidden = false;
                                self.btnContent.removeLoading()
                            }
                            else
                            {
                                self.btnContent.startLoading()
                                self.btnContent.play_pause.isHidden = true;
                            }
                            let upload_PathData = NSData(contentsOf:URL(string:serverpath)!)
                            self.btnContent.second.isHidden = false
                            self.btnContent.second.text = self.ReturnruntimeDuration(sourceMovieURL:URL(string:serverpath)!)
                            self.btnContent.second.textColor = UIColor.lightGray
                            self.songData = upload_PathData as Data?
                        }
                    }
                    
                }
                else
                    
                {
                    var upload_Path:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "upload_Path") as! String
                    let mediaDetailArr = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Data_Usage_Settings, attribute: "user_id", FetchString: Themes.sharedInstance.Getuser_id(), SortDescriptor: nil) as! NSArray
                    
                    if(mediaDetailArr.count > 0)
                    {
                        var autodownload : Bool = true
                        if((mediaDetailArr[0] as! NSManagedObject).value(forKey: "documents") as! String == "0" && download_status == "0")
                        {
                            autodownload = false
                        }
                        else if((mediaDetailArr[0] as! NSManagedObject).value(forKey: "documents") as! String == "1" && (UIApplication.shared.delegate as! AppDelegate).byreachable == "2" && download_status == "0")
                        {
                            autodownload = false
                        }
                        else if((mediaDetailArr[0] as! NSManagedObject).value(forKey: "documents") as! String != "0" && (UIApplication.shared.delegate as! AppDelegate).byreachable == "" && download_status == "0")
                        {
                            autodownload = false
                        }
                        if(!autodownload)
                        {
                            
                            self.btnContent.delegate = self
                            self.btnContent.downloadView.isHidden = false
                            self.btnContent.downloadView.frame = CGRect(x: self.DocumentWrapperView.frame.origin.x+self.DocumentWrapperView.frame.size.width - 35, y: self.DocumentWrapperView.frame.origin.y + self.DocumentWrapperView.frame.size.height - 35, width: 30, height: 30)
                            self.btnContent.downloadView.isUserInteractionEnabled = true
                            self.btnContent.downloadView.setIndicatorStatus(.none)
                            self.btnContent.play_pause.isHidden = true;
                            self.songData = nil
                        }
                        else
                        {
                            
                            
                            if(download_status == "1")
                            {
                                self.btnContent.startDownloading()
                                self.SetLoader_data(messageFrame)
                                //                    btnContent.removeLoading()
                                //                    let upload_PathData = NSData(contentsOf:URL(fileURLWithPath:upload_Path))
                                //                    songData = upload_PathData as Data!
                            }
                            else  if(download_status == "2")
                            {
                                self.btnContent.removeLoading()
                                upload_Path = upload_Path.replacingOccurrences(of: "file:///", with: "")
                                
                                
                                if(upload_Path != "")
                                {
                                    if FileManager.default.fileExists(atPath: upload_Path) {
                                        let upload_PathData = NSData(contentsOf:URL(fileURLWithPath:upload_Path))
                                        
                                        self.songData = upload_PathData as Data?
                                        self.btnContent.second.isHidden = false
                                        self.btnContent.second.text = self.ReturnruntimeDuration(sourceMovieURL:URL(fileURLWithPath:upload_Path))
                                        self.btnContent.second.textColor = UIColor.lightGray
                                    }
                                    else
                                    {
                                        let serverpath:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "serverpath") as! String
                                        
                                        let param:NSDictionary = ["download_status":"0"]
                                        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Upload_Details, FetchString: messageFrame.message.thumbnail!, attribute: "upload_data_id", UpdationElements: param)

                                        DownloadHandler.sharedinstance.handleDownLoad(true)

                                        let upload_PathData = NSData(contentsOf:URL(string:serverpath)!)
                                        
                                        self.songData = upload_PathData as Data?
                                        self.btnContent.second.isHidden = false
                                        self.btnContent.second.text = self.ReturnruntimeDuration(sourceMovieURL:URL(string:serverpath)!)
                                        self.btnContent.second.textColor = UIColor.lightGray
                                    }
                                }
                            }
                        }
                    }
                    else{
                        if(download_status == "1")
                        {
                            self.btnContent.startDownloading()
                            self.SetLoader_data(messageFrame)
                        }
                        else  if(download_status == "2")
                        {
                            self.btnContent.removeLoading()
                            upload_Path = upload_Path.replacingOccurrences(of: "file:///", with: "")
                            
                            
                            if(upload_Path != "")
                            {
                                if FileManager.default.fileExists(atPath: upload_Path) {
                                    let upload_PathData = NSData(contentsOf:URL(fileURLWithPath:upload_Path))
                                    
                                    self.songData = upload_PathData as Data?
                                    self.btnContent.second.isHidden = false
                                    self.btnContent.second.text = self.ReturnruntimeDuration(sourceMovieURL:URL(fileURLWithPath:upload_Path))
                                    self.btnContent.second.textColor = UIColor.lightGray
                                }
                                else
                                {
                                    let serverpath:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "serverpath") as! String
                                    
                                    let param:NSDictionary = ["download_status":"0"]
                                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Upload_Details, FetchString: messageFrame.message.thumbnail!, attribute: "upload_data_id", UpdationElements: param)

                                    DownloadHandler.sharedinstance.handleDownLoad(true)

                                    let upload_PathData = NSData(contentsOf:URL(string:serverpath)!)
                                    
                                    self.songData = upload_PathData as Data?
                                    self.btnContent.second.isHidden = false
                                    self.btnContent.second.text = self.ReturnruntimeDuration(sourceMovieURL:URL(string:serverpath)!)
                                    self.btnContent.second.textColor = UIColor.lightGray
                                }
                            }
                        }
                    }
                }
                break
            case MessageType(rawValue: 7)!:
                //        DispatchQueue.main.async {
                //setButtonContent
                self.profile_pic.isHidden = true
                self.save_contact.isHidden = true
                self.message.isHidden = true
                self.line.isHidden = true
                self.contact_view.isHidden = true
                self.line_vertical.isHidden = true
                self.contact_name.isHidden = true
                self.SetReplyFrame(messageFrame)
                self.setTextView(messageFrame,IndexPath: IndexPath)
                self.setTimeLabel(messageFrame)
                self.setBubble(messageFrame,CheckLastmessage: CheckLastmessage)
                self.addStatusIcon(messageFrame)
                self.setStatusIcon(messageFrame)
                self.setNeedsLayout()
                messageFrame.message.messageheight =   self.returnHeight()
                self._bubbleImage.isHidden=true
                self._bubbleImage.isHidden=false
                self._textView.isHidden=false
                self.btnContent.isHidden=false
                self.btnContent.backImageView.isHidden = true
                self.labelNum.textColor = UIColor.lightGray
                Themes.sharedInstance.setShadowonLabel(self.labelNum, UIColor.clear)
                self.loaderView.isHidden = true
                self.Player_Image.isHidden = true
                self.btnContent.myProgressView.isHidden = true
                ReplyView.isHidden = false
                self.Urlpreview.isHidden = true
                self.linkImage.isHidden = true
                self.descLabel.isHidden = true
                self.titleLabel.isHidden = true
                //    self.btnContent.slide
                
                break
            case MessageType(rawValue: 14)!:
                //        DispatchQueue.main.async {
                //setButtonContent
                
                self.setMessageFrameForType14(messageFrame, CheckLastmessage: CheckLastmessage, IndexPath: IndexPath, Type:14)
                
                //    self.btnContent.slide
                break;
            default:
                break
                
            }
            self.btnContent.contentHorizontalAlignment = .right
            self.btnContent.contentVerticalAlignment = .top
            self.btnContent.titleLabel?.textAlignment = .left
        }
    }
    
    func setMessageFrameForType1(_ messageFrame: UUMessageFrame!,CheckLastmessage:Bool,IndexPath:NSIndexPath)
    {
        let message:UUMessage! = messageFrame.message
        self.profile_pic.isHidden = true
        self.save_contact.isHidden = true
        self.message.isHidden = true
        self.line.isHidden = true
        self.contact_view.isHidden = true
        self.line_vertical.isHidden = true
        self.contact_name.isHidden = true
        self._textView.isHidden=true
        self.btnContent.isHidden=false
        self.btnContent.downloadView.tintColor = UIColor.white
        self.btnContent.backImageView.isHidden = false
        self.btnContent.titleLabel?.textColor = UIColor.clear
        self.btnContent.layer.cornerRadius = 5.0
        self.btnContent.clipsToBounds = true
        self.labelNum.textColor = UIColor.white
        Themes.sharedInstance.setShadowonLabel(self.labelNum, UIColor.black)
        self.loaderView.isHidden = false
        self.Urlpreview.isHidden = true
        self.linkImage.isHidden = true
        self.descLabel.isHidden = true
        self.titleLabel.isHidden = true
        self.SetImageView(messageFrame, IndexPath: IndexPath)
        self.setTimeLabel(messageFrame)
        self.setBubble(messageFrame,CheckLastmessage: CheckLastmessage)
        self.addStatusIcon(messageFrame)
        self.setStatusIcon(messageFrame)
        self.btnContent.clipsToBounds = true
        self.btnContent.backImageView.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: self.btnContent.frame.size.width, height: self.btnContent.frame.size.height)
        let upload_status:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "upload_status") as! String
        let failure_status:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "failure_status") as! String
        
        if(upload_status == "1" && failure_status == "0")
        {
            
            self.loaderView.removeFromSuperview()
            
        }else if(upload_status == "1"){
            
            self.loaderView.removeFromSuperview()
            
        }
        else
        {
            self.SetLoader_data(messageFrame)
            self.setLoadingView(messageFrame)
        }
        self.SetupProgressView()
        let _:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "download_status") as! String
        
        if message?.from == MessageFrom(rawValue: 1)!
        {
            UploadHandler.Sharedinstance.loadMyImage(messageFrame: messageFrame, imageView: self.btnContent.backImageView, isLoaderShow: true, completion: nil)

//            if(download_status == "2")
//            {
//                let PhotoPath:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "upload_Path") as! String!
//
//                if(PhotoPath != nil)
//                {
//                    if FileManager.default.fileExists(atPath: PhotoPath!) {
//                        let url = URL(fileURLWithPath: PhotoPath!)
//                        //        let data = NSData(contentsOf: url as URL)
//                        self.btnContent.backImageView.sd_setImage(with: url)
//                    }
//                    else
//                    {
//                        let serverpath:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "serverpath") as! String!
//                        let ThembnailData:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "compressed_data") as! String!
//                        let upload_type:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "upload_type") as! String!
//
//                        let url = URL(string: serverpath!)
//                        //        let data = NSData(contentsOf: url as URL)
//                        if(ThembnailData != nil && ThembnailData != "")
//                        {
//                            self.btnContent.backImageView.sd_setImage(with: URL(string:ThembnailData)!)
//                        }
//                        DownloadHandler.sharedinstance.StartDownload(Str: serverpath,type:upload_type, ismanual:true)
//                        SDWebImageManager.shared().imageDownloader?.downloadImage(with: url, options: .highPriority, progress: nil, completed: { (image:UIImage?, data:Data?, erro:Error?, downloaded:Bool) in
//                            if(image != nil)
//                            {
//                                self.btnContent.backImageView.image = image!
//                            }
//                        })
//                    }
//
//                }
//                else
//
//                {
//                    self.btnContent.backImageView.image = UIImage(named:"VideoThumbnail")
//                }
//            }
//
//            else
//            {
//                let serverpath:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "serverpath") as! String!
//                print(messageFrame.message.thumbnail!)
//                let ThembnailData:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "compressed_data") as! String!
//                if(ThembnailData != nil && ThembnailData != "")
//                {
//                    self.btnContent.backImageView.sd_setImage(with: URL(string:ThembnailData)!)
//                }
//
//                if(serverpath != nil)
//                {
//                    SDWebImageManager.shared().imageDownloader?.downloadImage(with: URL(string:serverpath), options: .highPriority, progress: nil, completed: { (image:UIImage?, data:Data?, erro:Error?, downloaded:Bool) in
//                        if(image != nil)
//                        {
//                            self.btnContent.backImageView.image = image!
//                        }
//                    })
//                }
//            }
            
        }
        else
        {
            UploadHandler.Sharedinstance.loadFriendsImage(messageFrame: messageFrame, imageView: self.btnContent.backImageView, isLoaderShow: true, completion: nil)

            
//            if(download_status == "2")
//            {
//                let PhotoPath:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "upload_Path") as! String!
//
//                if(PhotoPath != nil)
//                {
//                    if FileManager.default.fileExists(atPath: PhotoPath!) {
//                        let url = URL(fileURLWithPath: PhotoPath!)
//                        //        let data = NSData(contentsOf: url as URL)
//                        self.btnContent.backImageView.sd_setImage(with: url)
//                    }
//                    else
//                    {
//                        let serverpath:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "serverpath") as! String!
//                        let ThembnailData:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "compressed_data") as! String!
//                        let upload_type:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "upload_type") as! String!
//
//                        let url = URL(string: serverpath!)
//                        //        let data = NSData(contentsOf: url as URL)
//                        if(ThembnailData != nil && ThembnailData != "")
//                        {
//                            self.btnContent.backImageView.sd_setImage(with: URL(string:ThembnailData)!)
//                        }
//                        DownloadHandler.sharedinstance.StartDownload(Str: serverpath,type:upload_type, ismanual:true)
//                        SDWebImageManager.shared().imageDownloader?.downloadImage(with: url, options: .highPriority, progress: nil, completed: { (image:UIImage?, data:Data?, erro:Error?, downloaded:Bool) in
//                            if(image != nil)
//                            {
//                                self.btnContent.backImageView.image = image!
//                            }
//                        })
//                    }
//
//                }
//                else
//
//                {
//                    self.btnContent.backImageView.image = UIImage(named:"VideoThumbnail")
//                }
//            }
//
//            else
//            {
//                let serverpath:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "serverpath") as! String!
//                print(messageFrame.message.thumbnail!)
//                let ThembnailData:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "compressed_data") as! String!
//                if(ThembnailData != nil && ThembnailData != "")
//                {
//                    self.btnContent.backImageView.sd_setImage(with: URL(string:ThembnailData)!)
//                }
//
//
//
//                let mediaDetailArr = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Data_Usage_Settings, attribute: "user_id", FetchString: Themes.sharedInstance.Getuser_id(), SortDescriptor: nil) as! NSArray
//
//                if(mediaDetailArr.count > 0)
//                {
//                    var autodownload : Bool = true
//                    if((mediaDetailArr[0] as! NSManagedObject).value(forKey: "photos") as! String == "0" && download_status == "0")
//                    {
//                        autodownload = false
//                    }
//                    else if((mediaDetailArr[0] as! NSManagedObject).value(forKey: "photos") as! String == "1" && (UIApplication.shared.delegate as! AppDelegate).byreachable == "2" && download_status == "0")
//                    {
//                        autodownload = false
//                    }
//                    else if((mediaDetailArr[0] as! NSManagedObject).value(forKey: "photos") as! String != "0" && (UIApplication.shared.delegate as! AppDelegate).byreachable == "" && download_status == "0")
//                    {
//                        autodownload = false
//                    }
//                    if(!autodownload)
//                    {
//                        self.btnContent.delegate = self
//                        self.btnContent.downloadView.isHidden = false
//                        self.btnContent.downloadView.frame = CGRect(x: self.btnContent.frame.centerX - 70, y: self.btnContent.frame.centerY - ((messageFrame.message.chat_type == "group") ? 70 : 50), width: 100, height: 100)
//                        self.btnContent.downloadView.isUserInteractionEnabled = true
//                        self.btnContent.downloadView.setIndicatorStatus(.none)
//                    }else if(download_status == "2"){
//                        self.btnContent.downloadView.isHidden = true
//                    }
//                    else
//                    {
//
//                        self.btnContent.delegate = self
//                        self.btnContent.downloadView.isHidden = false
//                        self.btnContent.downloadView.frame = CGRect(x: self.btnContent.frame.centerX - 70, y: self.btnContent.frame.centerY - ((messageFrame.message.chat_type == "group") ? 70 : 50), width: 100, height: 100)
//                        self.btnContent.downloadView.isUserInteractionEnabled = false
//                        self.btnContent.downloadView.setIndicatorStatus(.indeterminate)
//
//                        SDWebImageManager.shared().imageDownloader?.downloadImage(with: URL(string:serverpath), options: .highPriority, progress: nil, completed: { (image:UIImage?, data:Data?, erro:Error?, downloaded:Bool) in
//                            if(image != nil)
//                            {
//                                self.btnContent.downloadView.isHidden = true
//                                self.btnContent.backImageView.image = image!
//                            }
//                        })
//                    }
//                }
//                else
//                {
//
//                    self.btnContent.delegate = self
//                    self.btnContent.downloadView.isHidden = false
//                    self.btnContent.downloadView.frame = CGRect(x: self.btnContent.frame.centerX - 70, y: self.btnContent.frame.centerY - ((messageFrame.message.chat_type == "group") ? 70 : 50), width: 100, height: 100)
//                    self.btnContent.downloadView.isUserInteractionEnabled = false
//                    self.btnContent.downloadView.setIndicatorStatus(.indeterminate)
//
//                    SDWebImageManager.shared().imageDownloader?.downloadImage(with: URL(string:serverpath), options: .highPriority, progress: nil, completed: { (image:UIImage?, data:Data?, erro:Error?, downloaded:Bool) in
//                        if(image != nil)
//                        {
//                            self.btnContent.downloadView.isHidden = true
//                            self.btnContent.backImageView.image = image!
//                        }
//                    })
//                }
//            }
            
        }
        self.Player_Image.isHidden = true
        messageFrame.message.messageheight = self.returnHeight()
        print(self.btnContent.frame);
        self._bubbleImage.isHidden=false
    }
    
    func startDownload() {
        
        self.btnContent.downloadView.setIndicatorStatus(.indeterminate)
        print(messageFrame.message.thumbnail!)
        let serverpath:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "serverpath") as! String
        
        if(serverpath != "")
        {
            DownloadHandler.sharedinstance.handleDownLoad(true)
        }
    }
    
    func setMessageFrameForType2(_ messageFrame: UUMessageFrame!, CheckLastmessage: Bool, IndexPath: NSIndexPath)
    {
        let message:UUMessage! = messageFrame.message
        
        self.profile_pic.isHidden = true
        self.save_contact.isHidden = true
        self.message.isHidden = true
        self.line.isHidden = true
        self.contact_view.isHidden = true
        self.line_vertical.isHidden = true
        self.contact_name.isHidden = true
        self._textView.isHidden=true
        self.btnContent.isHidden=false
        self.btnContent.downloadView.tintColor = UIColor.white
        self.btnContent.backImageView.isHidden = false
        self.Player_Image.isHidden = false
        self.btnContent.titleLabel?.textColor = UIColor.clear
        self.btnContent.layer.cornerRadius = 5.0
        self.btnContent.clipsToBounds = true
        self.labelNum.textColor = UIColor.white
        Themes.sharedInstance.setShadowonLabel(self.labelNum, UIColor.black)
        self.loaderView.isHidden = false
        self.Urlpreview.isHidden = true
        self.linkImage.isHidden = true
        self.descLabel.isHidden = true
        self.titleLabel.isHidden = true
        self.SetImageView(messageFrame, IndexPath: IndexPath)
        self.setTimeLabel(messageFrame)
        self.setBubble(messageFrame,CheckLastmessage: CheckLastmessage)
        self.addStatusIcon(messageFrame)
        self.setStatusIcon(messageFrame)
        self.btnContent.clipsToBounds = true
        self.btnContent.backImageView.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: self.btnContent.frame.size.width, height: self.btnContent.frame.size.height)
        print("the thumbnail is \(messageFrame.message.thumbnail!).....\(messageFrame.message.doc_id!)")
        let upload_status:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "upload_status") as! String
        let _:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "download_status") as! String
        let failure_status:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "failure_status") as! String
        self.SetPlayerView(messageFrame: messageFrame)
        self.loaderView.isHidden = true
        if message?.from == MessageFrom(rawValue: 1)!
        {
            self.loaderView.isHidden = false
            
            if(upload_status == "1" && failure_status == "0")
            {
                self.loaderView.removeFromSuperview()
            }
            else
            {
                self.SetLoader_data(messageFrame)
                self.setLoadingView(messageFrame)
            }
            self.SetupProgressView()
            
            
            if(upload_status == "1")
            {
                self.Player_Image.isHidden = false
            }
            else
            {
                self.Player_Image.isHidden = true
            }
           UploadHandler.Sharedinstance.loadVideoThumbnailOfMe(messageFrame: messageFrame, ImageView: self.btnContent.backImageView)
        }
        else
        {
            self.Player_Image.isHidden = false
            self.btnContent.setFrame(messageFrame)
            UploadHandler.Sharedinstance.loadVideoThumbnailOfOthers(messageFrame: messageFrame, ImageView: self.btnContent.backImageView)
           
            self.btnContent.downloadView.isHidden = true
            self.Player_Image.isHidden = false
        }
        print(self.btnContent.frame);
        self._bubbleImage.isHidden=false
        messageFrame.message.messageheight = self.returnHeight()
    }
    
    func setMessageFrameForType14(_ messageFrame: UUMessageFrame!, CheckLastmessage: Bool, IndexPath: NSIndexPath, Type:Int)
    {
        self.profile_pic.isHidden = true
        self.save_contact.isHidden = true
        self.message.isHidden = true
        self.line.isHidden = true
        self.contact_view.isHidden = true
        self.line_vertical.isHidden = true
        self.contact_name.isHidden = true
        self.SetmapImageView(messageFrame)
        self.setTextView(messageFrame,IndexPath: IndexPath)
        self.setTimeLabel(messageFrame)
        self.setBubble(messageFrame,CheckLastmessage: CheckLastmessage)
        self.addStatusIcon(messageFrame)
        self.setStatusIcon(messageFrame)
        self.setNeedsLayout()
        messageFrame.message.messageheight  =   self.returnHeight()
        self._bubbleImage.isHidden=false
        self._textView.isHidden=false
        self.btnContent.isHidden=false
        self.btnContent.downloadView.tintColor = UIColor.white
        self.btnContent.backImageView.isHidden = false
        self.labelNum.textColor = UIColor.lightGray
        Themes.sharedInstance.setShadowonLabel(self.labelNum, UIColor.clear)
        self.loaderView.isHidden = true
        self.Player_Image.isHidden = true
        self.btnContent.myProgressView.isHidden = true
        ReplyView.isHidden = true
        print(messageFrame.message.imagelink)
        self.btnContent.backImageView.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: self.btnContent.frame.size.width, height: self.btnContent.frame.size.height)
        
        self.Urlpreview.isHidden = true
        self.linkImage.isHidden = true
        self.descLabel.isHidden = true
        self.titleLabel.isHidden = true
        
        if(Type == 14)
        {
            if(messageFrame.message.from == MessageFrom(rawValue: 1))
            {
                self.btnContent.backImageView.sd_setImage(with: URL(string:messageFrame.message.imagelink), placeholderImage: #imageLiteral(resourceName: "placeholder"), options: .refreshCached)
                
            }
            else
            {
                self.btnContent.backImageView.sd_setImage(with: URL(string:messageFrame.message.imagelink), placeholderImage: #imageLiteral(resourceName: "placeholder"), options: .refreshCached)
                
            }
        }
        else if(Type == 1)
        {
            self.loaderView.isHidden = false
            
            let upload_status:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "upload_status") as! String
            let failure_status:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "failure_status") as! String
            
            if(upload_status == "1" && failure_status == "0")
            {
                self.loaderView.removeFromSuperview()
            }
            else
            {
                self.SetLoader_data(messageFrame)
                self.setLoadingView(messageFrame)
            }
            self.SetupProgressView()
            
            if messageFrame.message.from == MessageFrom(rawValue: 1)!
            {
                UploadHandler.Sharedinstance.loadMyImage(messageFrame: messageFrame, imageView: self.btnContent.backImageView, isLoaderShow: true, completion: nil)
            }
            else
            {
               UploadHandler.Sharedinstance.loadFriendsImage(messageFrame: messageFrame, imageView: self.btnContent.backImageView, isLoaderShow: true, completion: nil)
            }
        }
        else if(Type == 2)
        {
            let upload_status:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "upload_status") as! String
            let failure_status:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "failure_status") as! String
            self.SetPlayerView(messageFrame: messageFrame)
            self.loaderView.isHidden = true
            if messageFrame.message?.from == MessageFrom(rawValue: 1)!
            {
                
                self.loaderView.isHidden = false
                
                if(upload_status == "1" && failure_status == "0")
                {
                    self.loaderView.removeFromSuperview()
                }
                else
                {
                    self.SetLoader_data(messageFrame)
                    self.setLoadingView(messageFrame)
                }
                self.SetupProgressView()
                
                
                if(upload_status == "1")
                {
                    self.Player_Image.isHidden = false
                }
                else
                {
                    self.Player_Image.isHidden = true
                }
                UploadHandler.Sharedinstance.loadVideoThumbnailOfMe(messageFrame: messageFrame, ImageView: self.btnContent.backImageView)
            }
            else
            {
                self.Player_Image.isHidden = false
                self.btnContent.setFrame(messageFrame)
                self.btnContent.downloadView.isHidden = true

                UploadHandler.Sharedinstance.loadVideoThumbnailOfOthers(messageFrame: messageFrame, ImageView: self.btnContent.backImageView)
            }
        }
    }
    
    func ReturnruntimeDuration(sourceMovieURL:URL)->String
    {
        let sourceAsset = AVURLAsset(url: sourceMovieURL)
        let duration: CMTime = sourceAsset.duration
        
        let dMinutes: Int = Int((CMTimeGetSeconds(duration).truncatingRemainder(dividingBy: 3600)) / 60)
        let dSeconds: Int = Int(CMTimeGetSeconds(duration).truncatingRemainder(dividingBy: 60))
        let  DurationText: String =  String(format: "%02d:%02d", dMinutes,dSeconds)
        return "\(DurationText)"
    }
    func ReturnDownloadProgress(Dict: NSDictionary) {
        
        print("<<<<uthe dict is \(String(describing: Dict["url"]))")
        
    }
    func Setloader(_ messageFrame: UUMessageFrame!,CheckLastmessage:Bool,IndexPath:NSIndexPath)
    {
        
    }
    func setWrapperView(_ messageFrame: UUMessageFrame!)
    {
        
        if(messageFrame.message.type == MessageType(rawValue: 6)!)
        {
            print(btnContent.frame.size.width)
            DocumentWrapperView.frame = CGRect(x: 0, y: 0, width: self.btnContent.frame.size.width, height: self.btnContent.frame.size.height-20)
            print(DocumentWrapperView.frame.size.width)
            
            
        }
        
    }
    
    
    func setStatusIcon(_ messageFrame: UUMessageFrame!)
    {
        self.messageFrame = messageFrame
        if(messageFrame.message.from == MessageFrom(rawValue: 1))
        {
            self.StatusMark.isHidden=false
            if(messageFrame.message.message_status == "1")
            {
                self.StatusMark.image = UIImage(named: "singletick")!
            }
            else if(messageFrame.message.message_status == "2")
            {
                self.StatusMark.image = UIImage(named: "doubletick")!
            }
            else if(messageFrame.message.message_status == "3")
            {
                self.StatusMark.image = UIImage(named: "doubletickgreen")!
            }
            else
            {
                self.StatusMark.image = UIImage(named: "wait")!
                
            }
        }
        else
        {
            self.StatusMark.isHidden=true
            
        }
    }
    func addStatusIcon(_ messageFrame: UUMessageFrame!) {
        let time_frame: CGRect = labelNum.frame
        var status_frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(10), height: CGFloat(10))
        status_frame.origin.x = time_frame.origin.x + time_frame.size.width + 6
        status_frame.origin.y = time_frame.origin.y
        StatusMark.frame = status_frame
        StatusMark.contentMode = .scaleAspectFill
        
        if(messageFrame.message.type == MessageType(rawValue: 0)! || messageFrame.message.type == MessageType(rawValue: 4)!)
        {
            StatusMark.autoresizingMask = _textView.autoresizingMask
        }
        
        if(messageFrame.message.type == MessageType(rawValue: 1)! || messageFrame.message.type == MessageType(rawValue: 2)! || messageFrame.message.type == MessageType(rawValue: 3)! || messageFrame.message.type == MessageType(rawValue: 6)! || messageFrame.message.type == MessageType(rawValue: 7)! || messageFrame.message.type == MessageType(rawValue: 14)! || messageFrame.message.type == MessageType(rawValue: 5)!)
        {
            
            StatusMark.autoresizingMask = btnContent.autoresizingMask
        }
    }
    func SetupProgressView()
    {
        DispatchQueue.main.async {
            // Progress
            self.autoCircularProgressView.backgroundColor = UIColor.clear
            self.autoCircularProgressView.frame = CGRect(x: self.loaderView.center.x-30, y: self.loaderView.center.y-30, width: 60, height: 60)
            self.autoCircularProgressView.progressColor = UIColor.white
            self.autoCircularProgressView.progressArcWidth = 3.0
            
            let doesContain = self.subviews.contains(self.autoCircularProgressView)
            if(!doesContain)
            {
                self.loaderView.addSubview(self.autoCircularProgressView)
            }
        }
    }
    func SetPlayerView(messageFrame:UUMessageFrame)
    {
        self.Player_Image.frame = CGRect(x: 108, y: self.btnContent.center.y-30, width: 60, height: 60)
        
        if(messageFrame.message.from == MessageFrom(rawValue:0) && messageFrame.message.chat_type == "group")
        {
            self.Player_Image.frame = CGRect(x: 108, y: self.btnContent.center.y-45, width: 60, height: 60)
            
        }
        self.Player_Image.image = UIImage(named: "playIcon")
        Player_Image.isUserInteractionEnabled = false
        self.btnContent.addSubview(Player_Image)
    }
    
    func Setprogress(progress:CGFloat)
    {
        currentProgress = currentProgress+0.25
        self.autoCircularProgressView.setProgress(currentProgress, animated: true)
        
    }
    func setLoadingView(_ messageFrame: UUMessageFrame!)
    {
        
        if(messageFrame.message.type == MessageType(rawValue: 0)!)
        {
            loaderView.frame = CGRect(x: 0, y: 0, width: self.btnContent.frame.size.width, height: self.btnContent.frame.size.height)
            self.btnContent.addSubview(loaderView)
        }
            
        else if(messageFrame.message.type == MessageType(rawValue: 1)!)
        {
            loaderView.frame = CGRect(x: 0, y: 0, width: self.btnContent.frame.size.width, height: self.btnContent.frame.size.height)
            
            self.btnContent.addSubview(loaderView)
            
        }
            
        else if(messageFrame.message.type == MessageType(rawValue: 2)!)
        {
            loaderView.frame = CGRect(x: 0, y: 0, width: self.btnContent.frame.size.width, height: self.btnContent.frame.size.height)
            
            self.btnContent.addSubview(loaderView)
            
        }
        
        
        
    }
    
    
    func SetLoader_data(_ messageFrame: UUMessageFrame!)
    {
        DispatchQueue.main.async {
            let total_byte_count:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "total_byte_count") as! String
            
            let upload_byte_count:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "upload_byte_count") as! String
            if(total_byte_count == upload_byte_count)
            {
                messageFrame.message.messageid = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_one_one, attrib_name: "doc_id", fetchString: messageFrame.message.doc_id, returnStr: "id")
                
            }
            if(upload_byte_count != "")
            {
                
                let precentage:CGFloat = CGFloat(((100.0*Double(upload_byte_count)!)/Double(total_byte_count)!)/100.0);
                
                if messageFrame.message.from == MessageFrom(rawValue: 0)! {
                    if(messageFrame.message.type == MessageType(rawValue: 3)! || messageFrame.message.type == MessageType(rawValue: 2)! || messageFrame.message.type == MessageType(rawValue: 6)!)
                    {
                        print(precentage)
                        self.btnContent.downloadView.setProgress(Float(precentage), animated: true)
                        
                    }
                    
                }
                    
                else
                    
                {
                    self.autoCircularProgressView.setProgress(precentage, animated: true);
                }
            }
            
        }
    }
    func setBubble(_ messageFrame: UUMessageFrame!,CheckLastmessage:Bool)
    {
        self.messageFrame = messageFrame
        let message:UUMessage! = messageFrame.message
        //Margins to Bubble
        let marginLeft: CGFloat = 5
        let marginRight: CGFloat = 2
        //Bubble positions
        var bubble_x: CGFloat
        let bubble_y: CGFloat = 0
        var bubble_width: CGFloat = CGFloat()
        var bubble_height: CGFloat = CGFloat()
        if(message.type == MessageType(rawValue: 0)! || message.type == MessageType(rawValue: 7)! || message.type == MessageType(rawValue: 14)! || message.type == MessageType(rawValue: 4)! || (isCaption && (message.type == MessageType(rawValue: 1)! || message.type == MessageType(rawValue: 2)!)))
        {
            
            bubble_height = min(_textView.frame.size.height+_textView.frame.origin.y + 8, labelNum.frame.origin.y + labelNum.frame.size.height + 6)
            
            if(message.type == MessageType(rawValue: 4)!){
                if((messageFrame.message.desc) != ""){
                    bubble_height = _textView.frame.size.height + Urlpreview.frame.size.height + labelNum.frame.size.height
                    
                }else{
                    
                    bubble_height = min(_textView.frame.size.height + 8, labelNum.frame.origin.y + labelNum.frame.size.height + 6)
                }
            }
            
            if message?.from == MessageFrom(rawValue: 1)! {
                print(_textView.frame.origin.x)
                print(message.type)
                
                if(message.type == MessageType(rawValue: 7)! || message.type == MessageType(rawValue: 14)! || (isCaption && (message.type == MessageType(rawValue: 1)! || message.type == MessageType(rawValue: 2)!)))
                {
                    bubble_height = _textView.frame.size.height+_textView.frame.origin.y+8
                    
                    bubble_x = min(btnContent.frame.origin.x - marginLeft, labelNum.frame.origin.x - 2 * marginLeft)
                }
                    
                else
                {
                    bubble_x = min(_textView.frame.origin.x - marginLeft, labelNum.frame.origin.x - 2 * marginLeft)
                }
                
                if(!CheckLastmessage)
                {
                    _bubbleImage.image = UIImage(named: "chat4")?.stretchableImage(withLeftCapWidth: 15, topCapHeight: 14)
                }
                else
                {
                    _bubbleImage.image = UIImage(named: "chat3")?.stretchableImage(withLeftCapWidth: 15, topCapHeight: 14)
                    
                }
                bubble_width = contentView.frame.size.width - bubble_x - marginRight
            }
            else {
                bubble_x = marginRight
                if(message.type == MessageType(rawValue: 7)! || message.type == MessageType(rawValue: 14)! || (isCaption && (message.type == MessageType(rawValue: 1)! || message.type == MessageType(rawValue: 2)!)))
                {
                    bubble_height = _textView.frame.size.height+_textView.frame.origin.y+8
                }
                
                if(message.type == MessageType(rawValue: 4)!){
                    if((messageFrame.message.desc) != ""){
                        bubble_height = _textView.frame.size.height + Urlpreview.frame.size.height + labelNum.frame.size.height
                        
                    }else{
                        
                        bubble_height = min(_textView.frame.size.height + 8, labelNum.frame.origin.y + labelNum.frame.size.height + 6)
                    }
                }
                
                if(!CheckLastmessage)
                {
                    
                    _bubbleImage.image = UIImage(named: "chat5")?.stretchableImage(withLeftCapWidth: 21, topCapHeight: 14)
                }
                else
                {
                    _bubbleImage.image = UIImage(named: "chat6")?.stretchableImage(withLeftCapWidth: 21, topCapHeight: 14)
                }
                let firstValue = _textView.frame.origin.x + _textView.frame.size.width + marginLeft
                let secondValue = labelNum.frame.origin.x + labelNum.frame.size.width + 2 * marginLeft
                bubble_width = max(firstValue, secondValue)
                
                if(message.type == MessageType(rawValue: 4)!){
                    if((messageFrame.message.desc) != ""){
                        
                        bubble_width = Urlpreview.frame.size.width + 20
                        
                    }
                    
                }
                
            }
            _bubbleImage.frame = CGRect(x: bubble_x, y: bubble_y, width: bubble_width, height: bubble_height)
            _bubbleImage.autoresizingMask = _textView.autoresizingMask
        }
        else if (message.type == MessageType(rawValue: 1)! || message.type == MessageType(rawValue: 2)! || message.type == MessageType(rawValue: 3)! || message.type == MessageType(rawValue: 6)! || message.type == MessageType(rawValue: 5)!)
        {
            //         bubble_x = 0;
            //        bubble_height = 150
            //         bubble_width = 0;
            bubble_height = 200
            
            if message?.from == MessageFrom(rawValue: 1)!
            {
                bubble_height = 200
                
                if(message.type == MessageType(rawValue: 5)!){
                    let mob_no:String = Themes.sharedInstance.GetMyPhonenumber()
                    let user_mob:String = mob_no.substring(from: mob_no.index(mob_no.endIndex, offsetBy: -10))
                    if(message.contact_phone == user_mob || message.contact_phone == mob_no){
                        bubble_height = 90
                    }else{
                        bubble_height = 120
                    }
                    
                }
                
                if(message.type == MessageType(rawValue: 3)!)
                {
                    bubble_height = 100
                    
                }
                
                if(message.type == MessageType(rawValue: 6)!)
                {
                    if(message.docType == "1")
                    {
                        bubble_height = 160
                    }
                    else
                    {
                        bubble_height = 80
                        
                    }
                    
                }
                
                bubble_x = min(btnContent.frame.origin.x - marginLeft, labelNum.frame.origin.x - 2 * marginLeft)
                
                if(!CheckLastmessage)
                {
                    _bubbleImage.image = UIImage(named: "chat4")?.stretchableImage(withLeftCapWidth: 15, topCapHeight: 14)
                }
                else
                {
                    _bubbleImage.image = UIImage(named: "chat3")?.stretchableImage(withLeftCapWidth: 15, topCapHeight: 14)
                    
                }
                
                bubble_width = contentView.frame.size.width - bubble_x - marginRight
                
                _bubbleImage.autoresizingMask = .flexibleLeftMargin
                
            }
            else {
                if(message?.chat_type == "group")
                {
                    if(message.type == MessageType(rawValue: 3)!)
                    {
                        bubble_height = 100+20
                        
                    }
                    
                    if(message.type == MessageType(rawValue: 5)!){
                        let mob_no:String = Themes.sharedInstance.GetMyPhonenumber()
                        let user_mob:String = mob_no.substring(from: mob_no.index(mob_no.endIndex, offsetBy: -10))
                        if(message.contact_phone == user_mob || message.contact_phone == mob_no){
                            bubble_height = 90 + 20
                        }else{
                            bubble_height = 120 + 20
                        }
                    }
                    
                    if(message.type == MessageType(rawValue: 6)!)
                    {
                        if(message.docType == "1")
                        {
                            bubble_height = 160+20
                        }
                        else
                        {
                            bubble_height = 80+20
                            
                        }
                        
                    }
                }
                else
                {
                    if(message.type == MessageType(rawValue: 3)!)
                    {
                        bubble_height = 100
                        
                    }
                    
                    if(message.type == MessageType(rawValue: 5)!){
                        let mob_no:String = Themes.sharedInstance.GetMyPhonenumber()
                        let user_mob:String = mob_no.substring(from: mob_no.index(mob_no.endIndex, offsetBy: -10))
                        if(message.contact_phone == user_mob || message.contact_phone == mob_no){
                            bubble_height = 90
                        }else{
                            bubble_height = 120
                        }
                    }
                    if(message.type == MessageType(rawValue: 6)!)
                    {
                        if(message.docType == "1")
                        {
                            bubble_height = 160
                        }
                        else
                        {
                            bubble_height = 80
                            
                        }
                        
                    }
                }
                
                bubble_x = marginRight
                if(!CheckLastmessage)
                {
                    _bubbleImage.image = UIImage(named: "chat5")?.stretchableImage(withLeftCapWidth: 21, topCapHeight: 14)
                }
                else
                {
                    _bubbleImage.image = UIImage(named: "chat6")?.stretchableImage(withLeftCapWidth: 21, topCapHeight: 14)
                }
                let firstValue = btnContent.frame.origin.x + btnContent.frame.size.width + marginLeft
                let secondValue = labelNum.frame.origin.x + labelNum.frame.size.width + 2 * marginLeft
                bubble_width = max(firstValue, secondValue)
                _bubbleImage.autoresizingMask = .flexibleRightMargin
            }
            _bubbleImage.frame = CGRect(x: bubble_x, y: bubble_y, width: bubble_width, height: bubble_height)
            _bubbleImage.autoresizingMask = btnContent.autoresizingMask
            //        _bubbleImage.autoresizingMask = _textView.autoresizingMask
        }
        print("The bubble frame is \(_bubbleImage.frame)")
    }
    
    func SetDocumentView(_ messageFrame: UUMessageFrame!)
    {
        DocNameLbl.font = UIFont.systemFont(ofSize: 14.0)
        DocNameLbl.textColor = UIColor.black
        DocDetailLbl.font = UIFont.systemFont(ofSize: 12.0)
        DocNameLbl.numberOfLines = 0
        DocDetailLbl.textColor = UIColor.lightGray
        if(messageFrame.message.docType == "1")
        {
            PdfHeaderImageView.frame = CGRect(x: 0, y: 0, width: self.DocumentWrapperView.frame.size.width, height: self.btnContent.frame.size.height-60)
            DocimageView.frame = CGRect(x: 5, y: PdfHeaderImageView.frame.origin.y+PdfHeaderImageView.frame.size.height+5, width: 30, height: 30)
            DocNameLbl.frame = CGRect(x: DocimageView.frame.origin.x+DocimageView.frame.size.width+5, y: DocimageView.frame.origin.y, width: DocumentWrapperView.frame.size.width-DocNameLbl.frame.origin.x-80, height: 30)
            DocDetailLbl.frame = CGRect(x: 5, y: self.DocumentWrapperView.frame.origin.y+self.DocumentWrapperView.frame.size.height+4, width: 200, height: 14)
        }
        else
        {
            DocimageView.frame = CGRect(x: 10, y: 10, width: 30, height: 30)
            DocNameLbl.frame = CGRect(x: DocimageView.frame.origin.x+DocimageView.frame.size.width+5, y: DocimageView.frame.origin.y, width: DocumentWrapperView.frame.size.width-DocNameLbl.frame.origin.x-80, height: 30)
            DocDetailLbl.frame = CGRect(x: 5, y: self.DocumentWrapperView.frame.origin.y+self.DocumentWrapperView.frame.size.height+4, width: 200, height: 14)
        }
    }
    
    func SetDocumentDetail(_ messageFrame: UUMessageFrame!)
    {
        
        if(messageFrame.message.from == MessageFrom(rawValue: 1)!)
        {
            print(messageFrame.message.docType)
            if(messageFrame.message.docType == "1")
            {
                var TotalBye = ""
                if((messageFrame?.message.thumbnail) == "")
                {
                    TotalBye = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: (messageFrame?.message.doc_id)!, upload_detail: "total_byte_count") as! String
                    
                }
                else
                {
                    TotalBye = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: (messageFrame?.message.thumbnail)!, upload_detail: "total_byte_count") as! String
                    
                }
                let Gettotalbyte:String = Themes.sharedInstance.transformedValue(TotalBye) as! String
                DocNameLbl.text = messageFrame.message.docName
                print(messageFrame.message.docPageCount!, messageFrame.message.docName)
                DocDetailLbl.text = "\(messageFrame.message.docPageCount!) pages ● \(Gettotalbyte) ● \((messageFrame.message.docName as NSString).pathExtension.uppercased())"
                
                var ThembnailData:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "compressed_data") as! String
                let str:String = "data:image/jpg;base64,";
                
                if !ThembnailData.contains("data:image")
                {
                    ThembnailData = str.appending(ThembnailData)
                }
                
                PdfHeaderImageView.sd_setImage(with: URL(string:ThembnailData))
                
                DocimageView.image =  #imageLiteral(resourceName: "docicon")
                PdfHeaderImageView.contentMode = .scaleAspectFill
                PdfHeaderImageView.clipsToBounds = true
            }
            else
            {
                var TotalBye = ""
                if((messageFrame?.message.thumbnail) == "")
                {
                    TotalBye = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: (messageFrame?.message.doc_id)!, upload_detail: "total_byte_count") as! String
                    
                }
                else
                {
                    TotalBye = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: (messageFrame?.message.thumbnail)!, upload_detail: "total_byte_count") as! String
                    
                }
                let Gettotalbyte:String = Themes.sharedInstance.transformedValue(TotalBye) as! String
                
                DocNameLbl.text = messageFrame.message.docName
                DocDetailLbl.text = "\(Gettotalbyte) ● \((messageFrame.message.docName as NSString).pathExtension.uppercased())"
                DocimageView.image =  #imageLiteral(resourceName: "docicon")
            }
        }
        else
            
        {
            let download_status:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "download_status") as! String
            if(download_status == "0" || download_status == "1")
            {
                if(messageFrame.message.docType == "1")
                {
                    
                    var ThembnailData:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "compressed_data") as! String
                    let str:String = "data:image/jpg;base64,";
                    
                    if !ThembnailData.contains("data:image")
                    {
                        ThembnailData = str.appending(ThembnailData)
                    }
                    
                    PdfHeaderImageView.sd_setImage(with: URL(string:ThembnailData))
                    
                    PdfHeaderImageView.contentMode = .scaleAspectFill
                    PdfHeaderImageView.clipsToBounds = true
                    
                    let TotalBye:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "total_byte_count") as! String
                    let Gettotalbyte:String = Themes.sharedInstance.transformedValue(TotalBye) as! String
                    
                    DocNameLbl.text = messageFrame.message.docName
                    DocDetailLbl.text = "\(Gettotalbyte) ● \((messageFrame.message.docName as NSString).pathExtension.uppercased())"
                    DocimageView.image =  #imageLiteral(resourceName: "docicon")
                    
                }
                else
                {
                    
                    let TotalBye:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "total_byte_count") as! String
                    let Gettotalbyte:String = Themes.sharedInstance.transformedValue(TotalBye) as! String
                    
                    DocNameLbl.text = messageFrame.message.docName
                    DocDetailLbl.text = "\(Gettotalbyte) ● \((messageFrame.message.docName as NSString).pathExtension.uppercased())"
                    DocimageView.image =  #imageLiteral(resourceName: "docicon")
                    
                    
                }
                
                
            }
            else
            {
                
                if(messageFrame.message.docType == "1")
                {
                    let TotalBye:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "total_byte_count") as! String
                    let Gettotalbyte:String = Themes.sharedInstance.transformedValue(TotalBye) as! String
                    DocNameLbl.text = messageFrame.message.docName
                    DocDetailLbl.text = "\(messageFrame.message.docPageCount!) pages ● \(Gettotalbyte) ● \((messageFrame.message.docName as NSString).pathExtension.uppercased())"
                    var ThembnailData:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "compressed_data") as! String
                    let str:String = "data:image/jpg;base64,";
                    
                    if !ThembnailData.contains("data:image")
                    {
                        ThembnailData = str.appending(ThembnailData)
                    }
                    
                    PdfHeaderImageView.sd_setImage(with: URL(string:ThembnailData))
                    
                    DocimageView.image =  #imageLiteral(resourceName: "docicon")
                    PdfHeaderImageView.contentMode = .scaleAspectFill
                    PdfHeaderImageView.clipsToBounds = true
                    
                    DocNameLbl.text = messageFrame.message.docName
                    DocDetailLbl.text = "\(Gettotalbyte) ● \((messageFrame.message.docName as NSString).pathExtension.uppercased())"
                    DocimageView.image =  #imageLiteral(resourceName: "docicon")
                }
                else
                {
                    let TotalBye:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "total_byte_count") as! String
                    let Gettotalbyte:String = Themes.sharedInstance.transformedValue(TotalBye) as! String
                    
                    DocNameLbl.text = messageFrame.message.docName
                    DocDetailLbl.text = "\(Gettotalbyte) ● \((messageFrame.message.docName as NSString).pathExtension.uppercased())"
                    DocimageView.image =  #imageLiteral(resourceName: "docicon")
                }
            }
        }
    }
    
    
    func setTimeLabel(_ messageFrame: UUMessageFrame!) {
        if(messageFrame.message.timestamp != nil)
        {
            //        self.labelTime.frame = messageFrame.timeF
            let message:UUMessage! = messageFrame.message
            labelNum.frame = CGRect(x:0,y:0,width:62,height:14);
            self.messageFrame = messageFrame
            
            let dateStr:String = Themes.sharedInstance.ReturnTimeForChat(timestamp: messageFrame.message.timestamp!)
            if(messageFrame.message.isStar == "1")
            {
                self.labelNum.text = "★\(dateStr)"
            }
            else
            {
                self.labelNum.text = dateStr
            }
            labelNum.font = UIFont.systemFont(ofSize: 11.0)
            labelNum.isUserInteractionEnabled = false
            labelNum.alpha = 0.7
            labelNum.textAlignment = .right;
            if(message.type == MessageType(rawValue: 0)! || message.type == MessageType(rawValue: 7)! || message.type == MessageType(rawValue: 14)! || message.type == MessageType(rawValue: 4)! || (isCaption && (message.type == MessageType(rawValue: 1)! || message.type == MessageType(rawValue: 2)!)))
            {
                //Set Text to Label
                //Set position
                var time_x: CGFloat
                var time_y: CGFloat = _textView.frame.size.height+_textView.frame.origin.y - 11.5
                if(message.type == MessageType(rawValue: 4)!){
                    if((messageFrame.message.desc) != ""){
                        
                        time_y = _textView.frame.size.height +
                            Urlpreview.frame.size.height - 11
                        
                    }else{
                        
                        time_y = _textView.frame.size.height - 11.5
                        
                    }
                }
                
                if message?.from == MessageFrom(rawValue: 1)! {
                    if(message.type == MessageType(rawValue: 4)!){
                        if((messageFrame.message.desc) != ""){
                            
                            time_x = _textView.frame.origin.x + Urlpreview.frame.size.width - labelNum.frame.size.width - 4
                            
                        }else{
                            
                            time_x = _textView.frame.origin.x + _textView.frame.size.width - labelNum.frame.size.width - 21
                            
                        }
                    }else{
                        time_x = _textView.frame.origin.x + _textView.frame.size.width - labelNum.frame.size.width - 20
                    }
                }
                else {
                    time_x = max(_textView.frame.origin.x + _textView.frame.size.width - labelNum.frame.size.width, _textView.frame.origin.x)
                    
                    if(message.type == MessageType(rawValue: 4)!){
                        if((messageFrame.message.desc) != ""){
                            
                            time_x = _textView.frame.origin.x + Urlpreview.frame.size.width - labelNum.frame.size.width - 3
                            
                        }else{
                            
                            time_x = _textView.frame.origin.x + _textView.frame.size.width - labelNum.frame.size.width - 20
                            
                        }
                    }
                }
                
                if(message.type == MessageType(rawValue: 4)!){
                    if((messageFrame.message.desc) == "" || (messageFrame.message.desc) == nil){
                        if isSingleLineCase(messageFrame) {
                            time_x = _textView.frame.origin.x + _textView.frame.size.width - 7
                            time_y -= 10
                        }
                    }
                }else{
                    if isSingleLineCase(messageFrame) {
                        time_x = _textView.frame.origin.x + _textView.frame.size.width-7
                        time_y -= 10
                        
                    }
                }
                
                labelNum.frame = CGRect(x: time_x, y: time_y, width: CGFloat(labelNum.frame.size.width), height: CGFloat(labelNum.frame.size.height))
                
                if(message.type == MessageType(rawValue: 0)! || message.type == MessageType(rawValue: 4)!)
                {
                    labelNum.autoresizingMask = _textView.autoresizingMask
                    
                }
                else if(message.type == MessageType(rawValue: 7)! || message.type == MessageType(rawValue: 14)! || (isCaption && (message.type == MessageType(rawValue: 1)! || message.type == MessageType(rawValue: 2)!)))
                {
                    
                    labelNum.autoresizingMask = btnContent.autoresizingMask
                    
                }
                
            }
            else if(message.type == MessageType(rawValue: 1)! || message.type == MessageType(rawValue: 2)! || message.type == MessageType(rawValue: 3)! || message.type == MessageType(rawValue: 6)! || message.type == MessageType(rawValue: 5)!)
            {
                //Set Text to Label
                //Set position
                var time_x: CGFloat
                var time_y: CGFloat = btnContent.frame.size.height - 11.5
                if(message.chat_type == "group" && message?.from == MessageFrom(rawValue: 0)!)
                {
                    time_y = btnContent.frame.size.height+10
                    
                }
                if message?.from == MessageFrom(rawValue: 1)! {
                    time_x = btnContent.frame.origin.x + btnContent.frame.size.width - labelNum.frame.size.width - 25
                }
                else {
                    time_x = max(btnContent.frame.origin.x + btnContent.frame.size.width - labelNum.frame.size.width, btnContent.frame.origin.x)
                    time_x -= 3
                }
                
                
                if(message.type == MessageType(rawValue: 5)!){
                    
                    labelNum.frame = CGRect(x: time_x, y: time_y - 50, width: CGFloat(labelNum.frame.size.width), height: CGFloat(labelNum.frame.size.height))
                    labelNum.autoresizingMask = btnContent.autoresizingMask
                    
                }else{
                    
                    labelNum.frame = CGRect(x: time_x, y: time_y, width: CGFloat(labelNum.frame.size.width), height: CGFloat(labelNum.frame.size.height))
                    labelNum.autoresizingMask = btnContent.autoresizingMask
                    
                }
            }
            if(message.type == MessageType(rawValue: 5)!)
            {
                labelNum.frame.origin.x = labelNum.frame.origin.x + 10
            }
            else if(message.type == MessageType(rawValue: 0)!)
            {
                if(labelNum.frame.origin.y > 45.0)
                {
                    labelNum.frame.origin.x = labelNum.frame.origin.x + 6
                }
                else
                {
                    labelNum.frame.origin.x = labelNum.frame.origin.x - 4
                }
            }
            else if(message.type == MessageType(rawValue: 3)! || message.type == MessageType(rawValue: 6)!)
            {
                labelNum.frame.origin.x = labelNum.frame.origin.x + 10
            }
            else if(message.type == MessageType(rawValue: 1)! || message.type == MessageType(rawValue: 2)!)
            {
                labelNum.frame.origin.x = labelNum.frame.origin.x + 3
            }
            else if(message.type == MessageType(rawValue: 14)!)
            {
                labelNum.frame.origin.x = labelNum.frame.origin.x + 5
            }
        }
        print(labelNum.frame)
    }
    
    func SetmapImageView(_ messageFrame: UUMessageFrame!)
    {
        
        
        let message:UUMessage! = messageFrame.message
        let max_witdh: CGFloat = 0.7 * 375
        self.btnContent.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(max_witdh), height: CGFloat(136))
        
        var imgView_x: CGFloat = CGFloat()
        var imgView_y: CGFloat = CGFloat()
        let imgView_w: CGFloat = self.btnContent.frame.size.width
        let imgView_h: CGFloat = self.btnContent.frame.size.height
        
        var autoresizing: UIView.AutoresizingMask
        
        if message?.from == MessageFrom(rawValue: 1)! {
            
            
            imgView_x = contentView.frame.size.width - imgView_w - 20
            imgView_x -= 0.0;
            autoresizing = .flexibleLeftMargin
            imgView_y = 5
        }
        else {
            if(messageFrame.message.chat_type == "group")
            {
                UsernameLbl.isHidden = false
                UsernameLbl.frame = CGRect(x: CGFloat(25), y: CGFloat(5), width: self.btnContent.frame.size.width-20, height: 20)
                
                UsernameLbl.textColor = UIColor(red:23/255, green:109/255, blue:69/255, alpha:1.0)
                UsernameLbl.font = UIFont.systemFont(ofSize: 13.0)
                UsernameLbl.setNameTxt(Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message.user_from), "single")
                imgView_y = UsernameLbl.frame.origin.y+UsernameLbl.frame.size.height+2
                
            }
            else
            {
                UsernameLbl.isHidden = true
                imgView_y = 5
                
                
            }
            
            
            imgView_x = 20
            autoresizing = .flexibleRightMargin
        }
        print(imgView_w)
        self.btnContent.autoresizingMask = autoresizing
        self.btnContent.frame = CGRect(x: imgView_x, y: imgView_y, width: imgView_w, height: imgView_h)
    }
    
    func SetReplyFrame(_ messageFrame: UUMessageFrame!)
    {
        let message:UUMessage! = messageFrame.message
        let max_witdh: CGFloat = 0.7 * 375
        
        if(message.type == MessageType(rawValue: 7))
            
        {
            self.btnContent.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(max_witdh), height: CGFloat(50))
            print(self.btnContent.frame)
        }
        
        var imgView_x: CGFloat
        var imgView_y: CGFloat!
        let imgView_w: CGFloat = self.btnContent.frame.size.width
        let imgView_h: CGFloat = self.btnContent.frame.size.height
        
        var autoresizing: UIView.AutoresizingMask
        if message?.from == MessageFrom(rawValue: 1)! {
            imgView_x = contentView.frame.size.width - imgView_w - 20
            imgView_x -= 0.0;
            autoresizing = .flexibleLeftMargin
        }
        else
        {
            imgView_x = 20
            autoresizing = .flexibleRightMargin
        }
        if(message?.chat_type == "single")
        {
            UsernameLbl.isHidden = true
            imgView_y = 5
        }
        else if(message?.chat_type == "group")
        {
            if(message?.from == MessageFrom(rawValue: 0))
            {
                if(message?.type == MessageType(rawValue: 7))
                {
                    
                    UsernameLbl.isHidden = false
                    
                }
                else
                {
                    
                    UsernameLbl.isHidden = true
                    
                }
                
                UsernameLbl.frame = CGRect(x: CGFloat(25), y: CGFloat(5), width: self.btnContent.frame.size.width-20, height: 20)
                
                UsernameLbl.textColor = UIColor(red:23/255, green:109/255, blue:69/255, alpha:1.0)
                UsernameLbl.font = UIFont.systemFont(ofSize: 13.0)
                UsernameLbl.setNameTxt(Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message.user_from), "single")
                print(self.btnContent.frame)
                imgView_y = UsernameLbl.frame.origin.y+UsernameLbl.frame.size.height
                UsernameLbl.autoresizingMask = autoresizing
            }
            else
            {
                UsernameLbl.isHidden = true
                imgView_y = 5
            }
            
        }
        
        print(imgView_w)
        self.btnContent.autoresizingMask = autoresizing
        self.btnContent.frame = CGRect(x: imgView_x, y: imgView_y, width: imgView_w, height: imgView_h)
        ReplyView.frame = CGRect(x: 5, y: 5, width: self.btnContent.frame.size.width-10, height: 50)
        let messageFromID:String = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Reply_detail, attrib_name: "doc_id", fetchString: messageFrame.message.doc_id, returnStr: "from_id")
        let recordId:String = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Reply_detail, attrib_name: "doc_id", fetchString: messageFrame.message.doc_id, returnStr: "recordId")
        ReplyView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.4)
        ReplyView.layer.cornerRadius = 3.0;
        ReplyView.clipsToBounds = true
        ReplyView.close_Btn.isHidden  = true
        let message_type:String = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Reply_detail, attrib_name: "doc_id", fetchString: messageFrame.message.doc_id, returnStr: "message_type")
        
        var payload:String = String()
        
        if(message?.from == MessageFrom(rawValue: 0))
        {
            payload = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Reply_detail, attrib_name: "doc_id", fetchString: messageFrame.message.doc_id, returnStr: "payload")
            
        }else{
            payload = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Reply_detail, attrib_name: "doc_id", fetchString: messageFrame.message.doc_id, returnStr: "payload")
        }
        
        let arr = Themes.sharedInstance.getID_Range_Payload_Name(message: payload)
        
        self.ReplyIdArr = arr[0] as! [String]
        
        self.ReplyrangeArr = arr[1] as! [NSRange]
        
        payload = arr[2] as! String
        
        
        
        if(Themes.sharedInstance.Getuser_id() == messageFromID)
        {
            if(messageFrame.message.reply_type == "status")
            {
                ReplyView.name_Lbl.text = "You • Status"
                isFromStatus = true
                
            }
            else
            {
                ReplyView.name_Lbl.text = "You"
                isFromStatus = false
            }
            ReplyView.user_status_Lbl.backgroundColor = UIColor(red:23/255, green:109/255, blue:69/255, alpha:1.0)
            ReplyView.name_Lbl.textColor = UIColor(red:23/255, green:109/255, blue:69/255, alpha:1.0)
            
        }
        else
        {
            if(messageFrame.message.reply_type == "status")
            {
                ReplyView.name_Lbl.text = "\(Themes.sharedInstance.setNameTxt(messageFromID, "single")) • Status"
                isFromStatus = true
            }
            else
            {
                ReplyView.name_Lbl.text = Themes.sharedInstance.setNameTxt(messageFromID, "single")
                isFromStatus = false
            }
            ReplyView.user_status_Lbl.backgroundColor = UIColor.orange
            ReplyView.name_Lbl.textColor = UIColor.orange
            
        }
        
        print(payload, messageFrame.message.doc_id)
        ReplyView.thumbnail_Image.frame.origin.x = ReplyView.frame.size.width-ReplyView.thumbnail_Image.frame.size.width
        if(message_type == "1")
        {
            let ThembnailData:String! = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Reply_detail, attrib_name: "doc_id", fetchString: messageFrame.message.doc_id, returnStr: "compressed_data")
            
            do{
                
                let imageData = try Data(contentsOf: URL(string: ThembnailData)!)
                let image = UIImage(data: imageData)
                ReplyView.thumbnail_Image.image = image
            }
            catch{
                print(error.localizedDescription)
            }
            ReplyView.message_Lbl.text = "📷 Photo"
        }
        else if(message_type == "2")
        {
            var ThembnailData:String! = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Reply_detail, attrib_name: "doc_id", fetchString: messageFrame.message.doc_id, returnStr: "compressed_data")
            let str:String = "data:image/jpg;base64,";
            
            if !ThembnailData.contains("data:image")
            {
                ThembnailData = str.appending(ThembnailData)
            }
            
            ReplyView.thumbnail_Image.sd_setImage(with: URL(string:ThembnailData))
            ReplyView.message_Lbl.text = "📹 Video"
        }
        else if(message_type == "3")
        {
            ReplyView.message_Lbl.text = "🎵 Audio"
            
        }
        else if(message_type == "5")
        {
            ReplyView.message_Lbl.text = "📝 \(payload)"
            
        }
        else if(message_type == "6" && message_type == "20")
        {
            ReplyView.message_Lbl.text = "📄 Document"
            
        }
        else if(message_type == "14")
        {
            ReplyView.message_Lbl.text = payload
            
        }
        else if(message_type == "4"){
            ReplyView.message_Lbl.text = payload
            
        }
        else if(message_type == "0")
        {
            ReplyView.message_Lbl.text = payload
            
        }else if(message_type == "7")
        {
            ReplyView.message_Lbl.text = payload
        }
        ReplyRecordID = recordId
        
        if(payload.length > 0)
        {
            let attributed = NSMutableAttributedString(string: self.ReplyView.message_Lbl.text!)
            
            attributed.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15.0)], range: NSMakeRange(0, (self.ReplyView.message_Lbl.text?.length)!))
            _ = self.ReplyrangeArr.map {
                attributed.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15.0)], range: $0)
            }
            if(self.ReplyrangeArr.count > 0)
            {
                self.ReplyView.message_Lbl.attributedText = attributed
            }
        }
        let previousReplyH = self.ReplyView.message_Lbl.frame.size.height
        
        var height = self.ReplyView.message_Lbl.text?.height(withConstrainedWidth: self.ReplyView.message_Lbl.frame.size.width, font: UIFont.systemFont(ofSize: 15.0))
        
        if(Double(height!) > Double(previousReplyH))
        {
            if(Double(height!) > 62.0){
                height = 62
            }
            var rect = self.ReplyView.message_Lbl.frame
            rect.size.height = height!
            self.ReplyView.message_Lbl.frame = rect
            
            rect = self.ReplyView.frame
            rect.size.height = self.ReplyView.frame.size.height + height! - previousReplyH
            self.ReplyView.frame = rect
        }
        
    }
    
    func SetAudioFrame(_ messageFrame: UUMessageFrame!,IndexPath:NSIndexPath) {
        
        let message:UUMessage! = messageFrame.message
        let max_witdh: CGFloat = 0.7 * 375
        if(message.type == MessageType(rawValue: 3))
        {
            self.btnContent.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(max_witdh), height: CGFloat(90))
        }
            
        else if(message.type == MessageType(rawValue: 6))
            
        {
            if(message.docType == "1")
            {
                self.btnContent.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(max_witdh), height: CGFloat(150))
                print(self.btnContent.frame)
            }
            else
            {
                self.btnContent.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(max_witdh), height: CGFloat(70))
                print(self.btnContent.frame)
                
            }
            
        }else if(message.type == MessageType(rawValue: 5)){
            self.btnContent.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(max_witdh), height: CGFloat(110))
        }
        
        var imgView_x: CGFloat
        var imgView_y: CGFloat
        let imgView_w: CGFloat = self.btnContent.frame.size.width
        let imgView_h: CGFloat = self.btnContent.frame.size.height
        
        var autoresizing: UIView.AutoresizingMask
        
        if message?.from == MessageFrom(rawValue: 1)! {
            
            imgView_x = contentView.frame.size.width - imgView_w - 20
            imgView_x -= 0.0;
            autoresizing = .flexibleLeftMargin
            imgView_y = 5
        }
        else {
            if(messageFrame.message.chat_type == "group")
            {
                self.btnContent.frame.size.height += 20
                UsernameLbl.isHidden = false
                UsernameLbl.frame = CGRect(x: CGFloat(25), y: CGFloat(5), width: self.btnContent.frame.size.width-20, height: 20)
                
                UsernameLbl.textColor = UIColor(red:23/255, green:109/255, blue:69/255, alpha:1.0)
                UsernameLbl.font = UIFont.systemFont(ofSize: 13.0)
                UsernameLbl.setNameTxt(Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message.user_from), "single")
                imgView_y = UsernameLbl.frame.origin.y+UsernameLbl.frame.size.height+2
                
            }
            else
            {
                UsernameLbl.isHidden = true
                imgView_y = 5
            }
            //         imgView_y = 5
            imgView_x = 20
            autoresizing = .flexibleRightMargin
        }
        print(imgView_w)
        self.btnContent.autoresizingMask = autoresizing
        self.btnContent.frame = CGRect(x: imgView_x, y: imgView_y, width: imgView_w, height: imgView_h)
        
        
    }
    
    func SetImageView(_ messageFrame: UUMessageFrame!,IndexPath:NSIndexPath) {
        let message:UUMessage! = messageFrame.message
        let max_witdh: CGFloat = 0.7 * 375
        self.btnContent.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(max_witdh), height: CGFloat(186))
        
        var imgView_x: CGFloat = CGFloat()
        var imgView_y: CGFloat = CGFloat()
        let imgView_w: CGFloat = self.btnContent.frame.size.width
        var imgView_h: CGFloat = self.btnContent.frame.size.height
        var autoresizing: UIView.AutoresizingMask
        
        if message?.from == MessageFrom(rawValue: 1)! {
            
            imgView_x = contentView.frame.size.width - imgView_w - 20
            imgView_x -= 0.0;
            autoresizing = .flexibleLeftMargin
            imgView_y = 5
        }
        else {
            if(messageFrame.message.chat_type == "group")
            {
                self.btnContent.frame.size.height -= 25
                UsernameLbl.isHidden = false
                UsernameLbl.frame = CGRect(x: CGFloat(25), y: CGFloat(5), width: self.btnContent.frame.size.width-20, height: 20)
                UsernameLbl.textColor = UIColor(red:23/255, green:109/255, blue:69/255, alpha:1.0)
                UsernameLbl.font = UIFont.systemFont(ofSize: 13.0)
                UsernameLbl.setNameTxt(Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message.user_from), "single")
                imgView_y = UsernameLbl.frame.origin.y+UsernameLbl.frame.size.height+2
                imgView_h = self.btnContent.frame.size.height
            }
            else
            {
                UsernameLbl.isHidden = true
                imgView_y = 5
            }
            //            imgView_y = 5
            imgView_x = 20
            autoresizing = .flexibleRightMargin
        }
        print(imgView_w)
        self.btnContent.autoresizingMask = autoresizing
        self.btnContent.frame = CGRect(x: imgView_x, y: imgView_y, width: imgView_w, height: imgView_h)
    }
    func setTextView(_ messageFrame: UUMessageFrame!,IndexPath:NSIndexPath) {
        self.messageFrame = messageFrame
        let message:UUMessage! = messageFrame.message
        print("the message>>> is \(TempPayload)")
        let max_witdh: CGFloat = 0.7 * 375
        _textView.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: max_witdh, height: CGFloat(MAXFLOAT))
        _textView.backgroundColor = UIColor.clear
        
        if(messageFrame.message.chat_type == "group")
        {
            if(message.message_type == "14")
            {
                _textView.text = "\(messageFrame.message.title_place!)\n\(messageFrame.message.stitle_place!)"
            }
            else
            {
                _textView.text = TempPayload
            }
        }
        else
        {
            if(message.message_type == "14")
            {
                _textView.text = "\(messageFrame.message.title_place!)\n\(messageFrame.message.stitle_place!)"
            }
            else
            {
                _textView.text = TempPayload
            }
        }
        
        
        if(message.is_deleted == "1")
        {
            _textView.font = UIFont.italicSystemFont(ofSize:16.0)
        }
        else
        {
            _textView.font = UIFont.systemFont(ofSize: 16.0)
        }
        
        let attributed = NSMutableAttributedString(string: self._textView.text!)
        
        attributed.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15.0)], range: NSMakeRange(0, self._textView.text.length))
        
        _ = TagRangeArr.map {
            attributed.addAttributes([NSAttributedString.Key.foregroundColor : CustomColor.sharedInstance.themeColor, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15.0)], range: $0)
            
            attributed.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.lightGray, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15.0)], range: NSMakeRange($0.location-1, 1))
        }
        if(TagRangeArr.count > 0)
        {
            self._textView.attributedText = attributed
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapTextview(tap:)))
        _textView.addGestureRecognizer(tap)
        _textView.isUserInteractionEnabled = true

        _textView.sizeToFit()
        
        var textView_x: CGFloat = CGFloat()
        var textView_y: CGFloat = CGFloat()
        var textView_w: CGFloat = CGFloat()
        if(message.message_type == "7" || message.message_type == "14" || (isCaption && (message.type == MessageType(rawValue: 1)! || message.type == MessageType(rawValue: 2)!)))
        {
            textView_w = btnContent.frame.size.width
            
        }
        else
        {
            textView_w = _textView.frame.size.width
        }
        let textView_h: CGFloat = _textView.frame.size.height
        var autoresizing: UIView.AutoresizingMask
        if message?.from == MessageFrom(rawValue: 1)!
        {
            if(message.message_type == "5"){
                textView_x = 65.0
            }
            if(message.message_type == "7")
            {
                textView_x = contentView.frame.size.width - textView_w - 20
                textView_x -= 0.0
                textView_x -= 0.0;
                textView_y =   ReplyView.frame.origin.y+ReplyView.frame.size.height-2
            }
            else if(message.message_type == "14" || (isCaption && (message.type == MessageType(rawValue: 1)! || message.type == MessageType(rawValue: 2)!)))
            {
                textView_x = contentView.frame.size.width - textView_w - 20
                textView_x -= 0.0
                textView_x -= 0.0;
                textView_y =   btnContent.frame.origin.y+btnContent.frame.size.height-2
                
            } else if(message.message_type == "4"){
                
                if((messageFrame.message.desc) != ""){
                    
                    textView_x = contentView.frame.size.width - Urlpreview.frame.size.width + 35
                    textView_y = -3
                    textView_x -= isSingleLineCase(messageFrame) ? 60.0 : 60.0   //65.0
                    textView_x -= 0.0;
                    
                }else{
                    textView_x = contentView.frame.size.width - textView_w - 20
                    textView_y = -3
                    textView_x -= isSingleLineCase(messageFrame) ? 65.0 : 0.0   //65.0
                    textView_x -= 0.0;
                    
                }
            }
            else if(message.message_type == "0")
            {
                
                
                UsernameLbl.isHidden = true
                textView_x = contentView.frame.size.width - textView_w - 20
                textView_y = -3
                textView_x -= isSingleLineCase(messageFrame) ? 65.0 : 0.0
                textView_x -= 0.0;
            }
            else
            {
            }
            autoresizing = .flexibleLeftMargin
        }
        else
        {
            textView_x = 20
            if(message.message_type == "7")
            {
                textView_y = -1 + ReplyView.frame.origin.y+ReplyView.frame.size.height+btnContent.frame.origin.y
                
            }
            else if(message.message_type == "14" || (isCaption && (message.type == MessageType(rawValue: 1)! || message.type == MessageType(rawValue: 2)!)))
            {
                
                textView_y = -1 + btnContent.frame.origin.y+btnContent.frame.size.height-2
                
                
            }
                
            else  if message.message_type == "0"
            {
                if(messageFrame.message.chat_type == "group")
                {
                    textView_w += 40
                    
                    UsernameLbl.isHidden = false
                    UsernameLbl.frame = CGRect(x: CGFloat(20), y: CGFloat(5), width: textView_w+40, height: 20)
                    
                    UsernameLbl.textColor = UIColor(red:23/255, green:109/255, blue:69/255, alpha:1.0)
                    UsernameLbl.font = UIFont.systemFont(ofSize: 13.0)
                    UsernameLbl.setNameTxt(Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message.user_from), "single")
                    textView_y = UsernameLbl.frame.origin.y+UsernameLbl.frame.size.height-2
                }
                else
                {
                    UsernameLbl.isHidden = true
                    textView_y = -3
                }
            }
            else
            {
                textView_y = -1
            }
            
            autoresizing = .flexibleRightMargin
            
            //            if(messageFrame.message.chat_type == "group")
            //            {
            //                textView_x = 20-5
            //            }
        }
        if(message.message_type == "4")
        {
            
            if((messageFrame.message.desc) != ""){
                //print("sdkcjdkcbdkjbc")
                _textView.autoresizingMask = autoresizing
                _textView.frame = CGRect(x: textView_x, y: textView_y + Urlpreview.frame.size.height + 2, width: textView_w, height: textView_h)
            }else{
                _textView.autoresizingMask = autoresizing
                _textView.frame = CGRect(x: textView_x, y: textView_y, width: textView_w, height: textView_h)
            }
            
        }else if(message.message_type == "5"){
            // _textView.frame = CGRect(x: textView_x - 3, y: textView_y + 11, width: textView_w, height: textView_h)
            _textView.frame = CGRect(x: contentView.frame.size.width/2 - 3, y: textView_y + 11, width: textView_w, height: textView_h)
            _textView.autoresizingMask = autoresizing
            
        }else{
            _textView.autoresizingMask = autoresizing
            _textView.frame = CGRect(x: textView_x, y: textView_y, width: textView_w, height: textView_h)
            print(_textView.frame.size.height ,_textView.frame.size.width)
        }
        
        _textView.isEditable = false
        _textView.isSelectable = false
        _textView.isScrollEnabled = false
        _textView.dataDetectorTypes = UIDataDetectorTypes.link
        _textView.backgroundColor = UIColor.clear
        _textView.isUserInteractionEnabled = true
    }
    
    @objc func tapTextview(tap: UITapGestureRecognizer) {
        
        var isPerson = false
        var index = 0
        _ = TagRangeArr.map{
            let range = $0
            
            let myTextView = tap.view as! UITextView
            let layoutManager = _textView.layoutManager
            
            var location = tap.location(in: myTextView)
            location.x -= myTextView.textContainerInset.left;
            location.y -= myTextView.textContainerInset.top;
            
            let characterIndex = layoutManager.characterIndex(for: location, in: myTextView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
            
            if characterIndex < myTextView.textStorage.length {
                
                print("Your character is at index: \(characterIndex)")
                
                let myRange = NSRange(location: characterIndex, length: 1)
                if(range.contains(myRange.location))
                {
                    print(TagIdArr[index])
                    isPerson = true
                    index = TagRangeArr.index(of: range)!
                }
            }
        }
        if(isPerson)
        {
            if(Themes.sharedInstance.CheckNullvalue(Passed_value: TagIdArr[index]) != Themes.sharedInstance.Getuser_id())
            {
                self.delegate?.PasPersonDetail(id: Themes.sharedInstance.CheckNullvalue(Passed_value: TagIdArr[index]))
            }
        }
    }
    
    func fail_delta() -> Int
    {
        return 60
    }
    func isStatusFailedCase() -> Bool {
        return false
    }
    func isSingleLineCase(_ messageFrame: UUMessageFrame!) -> Bool {
        self.messageFrame = messageFrame
        let message:UUMessage! = messageFrame.message
        
        let delta_x: CGFloat = message?.from == MessageFrom(rawValue: 1)! ? 65.0 : 44.0
        let textView_height: CGFloat = _textView.frame.size.height
        let textView_width: CGFloat = _textView.frame.size.width
        let view_width: CGFloat = contentView.frame.size.width
        
        
        print("\(String(describing: TempPayload))>>>>\(textView_height):{}}}}}{}}\(textView_width + delta_x) {{}}}}}} \(0.8 * view_width)")
        //Single Line Case
        
        if(message.chat_type == "group")
        {
            return (textView_height <= 55 && textView_width + delta_x <= 0.8 * view_width) ? true : false
            
        }
            
        else    {
            return (textView_height <= 45 && textView_width + delta_x <= 0.8 * view_width) ? true : false
            
        }
        
    }

    func FetchContactImage(_ messageFrame:UUMessageFrame) -> String!
    {
        var userProf:String! = String()
        UsernameLbl.isHidden=false
        let CheckBool:Bool=DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "msisdn", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message.contactmsisdn))
        if(CheckBool)
        {
            let usernameArr:NSArray=DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "msisdn", FetchString: Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message.contactmsisdn), SortDescriptor: nil) as! NSArray
            if(usernameArr.count > 0)
            {
                for i in 0..<usernameArr.count
                {
                    let contactDict=usernameArr[i] as! NSManagedObject
                    let profilepic:String=Themes.sharedInstance.CheckNullvalue(Passed_value: contactDict.value(forKey: "profilepic"))
                    if(profilepic != "")
                    {
                        userProf=profilepic
                    }
                    
                }
                
            }
            else
            {
                userProf = nil
                
                
            }
            
        }
        else
        {
            userProf = nil
            
        }
        
        return userProf
        
    }
    
    
    
    @objc func deleteMessageActionTapped(sender: UIMenuController) {
        // implement custom action here
        self.delegate?.DidClickMenuAction(actioname: .delete, index: RowIndex)
    }
    
    @objc func CopyMessageActionTapped(sender: UIMenuController) {
        // implement custom action here
        self.delegate?.DidClickMenuAction(actioname: .copy, index: RowIndex)
    }
    
    
    @objc func ForwardActionTapped(sender: UIMenuController) {
        // implement custom action here
        self.delegate?.DidClickMenuAction(actioname: .Forward, index: RowIndex)
        
    }
    @objc func ReplyActionTapped(sender: UIMenuController) {
        self.delegate?.DidClickMenuAction(actioname: .Reply, index: RowIndex)
        
        // implement custom action here
    }
    @objc func InfoActionTapped(sender: UIMenuController) {
        self.delegate?.DidClickMenuAction(actioname: .Info, index: RowIndex)
        
        // implement custom action here
    }
    @objc func StarActionTapped(sender: UIMenuController) {
        self.delegate?.DidClickMenuAction(actioname: .star, index: RowIndex)
        
        // implement custom action here
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func getContacts(id:String) ->Bool{
        
        var mob_no:String = String()
        var user_mob:String = String()
        var checkContact:Bool = Bool()
        if(id.length >= 10){
            mob_no = id
            user_mob = mob_no.substring(from: mob_no.index(mob_no.endIndex, offsetBy: -10))
            checkContact = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Contact_add, attribute: "contact_mobilenum", FetchString: user_mob);
            if(checkContact == false)
            {
                checkContact = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Contact_add, attribute: "contact_mobilenum", FetchString: id);
            }
        }else{
            checkContact = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Contact_add, attribute: "contact_mobilenum", FetchString: id);
        }
        
        if(checkContact)
        {
            var contactsArray:NSArray = NSArray()
            if(id.length >= 10){
                contactsArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Contact_add, attribute: "contact_mobilenum", FetchString: user_mob, SortDescriptor: nil) as! NSArray
                if(contactsArray.count == 0)
                {
                    contactsArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Contact_add, attribute: "contact_mobilenum", FetchString: id, SortDescriptor: nil) as! NSArray
                }
            }else{
                contactsArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Contact_add, attribute: "contact_mobilenum", FetchString: id, SortDescriptor: nil) as! NSArray
            }
            
            
            if(contactsArray.count > 0)
            {
                //let CheckFavcontactArr:NSMutableArray=NSMutableArray()
                for i in 0..<contactsArray.count
                {
                    
                    let constactObj=contactsArray[i] as! NSManagedObject
                    contacts_ArrObj.append(constactObj)
                    contactNoArr.add(Themes.sharedInstance.CheckNullvalue(Passed_value:  contacts_ArrObj[i].value(forKey: "contact_mobilenum")))
                    
                }
            }
            
        }
        if(contactNoArr.contains(id) || contactNoArr.contains(user_mob)){
            return true
        }else{
            return false
        }
    }
    
    func checkFavContact(phone:String) ->Bool{
        let checkBool:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "msisdn", FetchString:phone)
        var isfav:Bool = false
        if(checkBool){
            isfav = checkBool
        }else{
            let checkBool:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "phnumber", FetchString:phone)
            if(checkBool){
                isfav = checkBool
            }
        }
        return isfav
    }
    
    func getProfileImage(phone:String) -> String{
        let checkBool:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "msisdn", FetchString:phone)
        var profileImage:String = ""
        if(checkBool){
            let profile:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "msisdn", FetchString: phone, SortDescriptor: nil) as! NSArray
            if(profile.count > 0){
                for i in 0..<profile.count{
                    let profile:NSManagedObject = profile[i] as! NSManagedObject
                    let profile_image:String = Themes.sharedInstance.CheckNullvalue(Passed_value: profile.value(forKey: "profilepic"))
                    profileImage = profile_image
                }
            }
        }else{
            let checkBool:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "phnumber", FetchString:phone)
            if(checkBool){
                let profile:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "msisdn", FetchString: phone, SortDescriptor: nil) as! NSArray
                if(profile.count > 0){
                    for i in 0..<profile.count{
                        let profile:NSManagedObject = profile[i] as! NSManagedObject
                        let profile_image:String = Themes.sharedInstance.CheckNullvalue(Passed_value: profile.value(forKey: "profilepic"))
                        profileImage = profile_image
                    }
                }
            }
        }
        return profileImage
    }
    func setProfile(){
        
        let messager:UUMessage! = messageFrame.message
        
        if(messageFrame.message.chat_type == "group"){
            contact_view.frame = CGRect(x: 0, y:self.btnContent.userImageView.frame.size.height + self.btnContent.userImageView.frame.origin.y + labelNum.frame.size.height - 5, width:self.btnContent.frame.size.width, height:150)
        }else{
            contact_view.frame = CGRect(x:0, y:labelNum.frame.origin.y + labelNum.frame.size.height, width:self.btnContent.frame.size.width, height:150)
        }
        
        //contact_view.backgroundColor = UIColor.red
        if(messageFrame.message.chat_type == "single"){
            if(messager?.from == MessageFrom(rawValue: 1)!){
                let mob_no:String = Themes.sharedInstance.GetMyPhonenumber()
                let user_mob:String = mob_no.substring(from: mob_no.index(mob_no.endIndex, offsetBy: -10))
                if(messageFrame.message.contact_phone == mob_no || messageFrame.message.contact_phone == user_mob){
                    self.contact_view.isHidden = true
                }
                else if(messageFrame.message.contact_id == messageFrame.message.to)
                {
                    if(messageFrame.message.contact_profile == "nil"){
                        
                        if(self.checkFavContact(phone: messageFrame.message.contact_phone)){
                            send_message = true
                            
                            message.frame = CGRect(x:0, y: 4, width:contact_view.frame.size.width , height:40)
                            
                            message.setTitle("Message", for: .normal)
                            message.setTitleColor(UIColor(red:1/255, green:169/255, blue:229/255, alpha: 1), for: .normal)
                            message.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
                            
                            self.line.frame = CGRect(x:0, y:0, width:contact_view.frame.size.width, height:1)
                            line.backgroundColor = UIColor.lightGray
                            save_contact.isHidden = true
                            line_vertical.isHidden = true
                        }else{
                            send_message = false
                            message.frame = CGRect(x:0, y: 4, width:contact_view.frame.size.width , height:40)
                            save_contact.isHidden = true
                            message.setTitle("Invite", for: .normal)
                            message.setTitleColor(UIColor(red:1/255, green:169/255, blue:229/255, alpha: 1), for: .normal)
                            message.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
                            
                            self.line.frame = CGRect(x:0, y:0, width:contact_view.frame.size.width, height:1)
                            line.backgroundColor = UIColor.lightGray
                            save_contact.isHidden = true
                            line_vertical.isHidden = true
                        }
                        
                    }else{
                        send_message = true
                        
                        message.frame = CGRect(x:0, y: 4, width:contact_view.frame.size.width , height:40)
                        
                        message.setTitle("Message", for: .normal)
                        message.setTitleColor(UIColor(red:1/255, green:169/255, blue:229/255, alpha: 1), for: .normal)
                        message.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
                        
                        self.line.frame = CGRect(x:0, y:0, width:contact_view.frame.size.width, height:1)
                        line.backgroundColor = UIColor.lightGray
                        save_contact.isHidden = true
                        line_vertical.isHidden = true
                    }
                    
                    
                }else{
                    send_message = true
                    
                    message.frame = CGRect(x:0, y: 4, width:contact_view.frame.size.width , height:40)
                    
                    message.setTitle("Message", for: .normal)
                    message.setTitleColor(UIColor(red:1/255, green:169/255, blue:229/255, alpha: 1), for: .normal)
                    message.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
                    
                    self.line.frame = CGRect(x:0, y:0, width:contact_view.frame.size.width, height:1)
                    line.backgroundColor = UIColor.lightGray
                    save_contact.isHidden = true
                    line_vertical.isHidden = true
                }
                
                
            }else{
                
                let mycontacts = getContacts(id: messageFrame.message.contact_phone)
                let favcontacts = checkFavContact(phone: messageFrame.message.contact_phone)
                
                let mob_no:String = Themes.sharedInstance.GetMyPhonenumber()
                let user_mob:String = mob_no.substring(from: mob_no.index(mob_no.endIndex, offsetBy: -10))
                if(messageFrame.message.contact_phone == mob_no || messageFrame.message.contact_phone == user_mob){
                    self.contact_view.isHidden = true
                }
                else if((messageFrame.message.contact_id == Themes.sharedInstance.Getuser_id()) && (mycontacts == true)){
                    
                    send_message = false
                    
                    message.frame = CGRect(x:0, y: 4, width:contact_view.frame.size.width , height:40)
                    save_contact.isHidden = true
                    if(favcontacts == true)
                    {
                        message.setTitle("Message", for: .normal)
                        send_message = true
                    }
                    else
                    {
                        message.setTitle("Invite", for: .normal)
                        send_message = false
                    }
                    message.setTitleColor(UIColor(red:1/255, green:169/255, blue:229/255, alpha: 1), for: .normal)
                    message.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
                    
                    
                    self.line.frame = CGRect(x:0, y:0, width:contact_view.frame.size.width, height:1)
                    line.backgroundColor = UIColor.lightGray
                    save_contact.isHidden = true
                    line_vertical.isHidden = true
                    
                }
                else if((messageFrame.message.contact_id == Themes.sharedInstance.Getuser_id()) && (mycontacts == false)){
                    send_message = false
                    save_contact.frame = CGRect(x:0, y: 4, width:contact_view.frame.size.width/2 , height:40)
                    
                    save_contact.setTitle("Save Contact", for: .normal)
                    save_contact.setTitleColor(UIColor(red:1/255, green:169/255, blue:229/255, alpha: 1), for: .normal)
                    save_contact.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
                    
                    message.frame = CGRect(x:contact_view.frame.size.width/2, y: 4, width:contact_view.frame.size.width/2  , height:40)
                    
                    if(favcontacts == true)
                    {
                        message.setTitle("Message", for: .normal)
                        send_message = true
                    }
                    else
                    {
                        message.setTitle("Invite", for: .normal)
                        send_message = false
                    }
                    message.setTitleColor(UIColor(red:1/255, green:169/255, blue:229/255, alpha: 1), for: .normal)
                    message.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
                    
                    self.line.frame = CGRect(x:0, y:0, width:contact_view.frame.size.width, height:1)
                    line.backgroundColor = UIColor.lightGray
                    
                    self.line_vertical.frame = CGRect(x:contact_view.frame.size.width/2, y: line.frame.origin.y, width:1 , height:contact_view.frame.size.height)
                    line_vertical.backgroundColor = UIColor.lightGray
                    
                }else if((messageFrame.message.contact_id != Themes.sharedInstance.Getuser_id()) && (mycontacts == true)){
                    send_message = true
                    message.frame = CGRect(x:0, y: 4, width:contact_view.frame.size.width , height:40)
                    save_contact.isHidden = true
                    if(favcontacts == true)
                    {
                        message.setTitle("Message", for: .normal)
                        send_message = true
                    }
                    else
                    {
                        message.setTitle("Invite", for: .normal)
                        send_message = false
                    }
                    message.setTitleColor(UIColor(red:1/255, green:169/255, blue:229/255, alpha: 1), for: .normal)
                    message.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
                    
                    self.line.frame = CGRect(x:0, y:0, width:contact_view.frame.size.width, height:1)
                    line.backgroundColor = UIColor.lightGray
                    save_contact.isHidden = true
                    line_vertical.isHidden = true
                }else if((messageFrame.message.contact_id != Themes.sharedInstance.Getuser_id()) && (mycontacts == false)){
                    send_message = true
                    save_contact.frame = CGRect(x:0, y: 4, width:contact_view.frame.size.width/2 , height:40)
                    
                    save_contact.setTitle("Save Contact", for: .normal)
                    save_contact.setTitleColor(UIColor(red:1/255, green:169/255, blue:229/255, alpha: 1), for: .normal)
                    save_contact.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
                    
                    message.frame = CGRect(x:contact_view.frame.size.width/2, y: 4, width:contact_view.frame.size.width/2  , height:40)
                    
                    if(favcontacts == true)
                    {
                        message.setTitle("Message", for: .normal)
                        send_message = true
                    }
                    else
                    {
                        message.setTitle("Invite", for: .normal)
                        send_message = false
                    }
                    message.setTitleColor(UIColor(red:1/255, green:169/255, blue:229/255, alpha: 1), for: .normal)
                    message.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
                    
                    self.line.frame = CGRect(x:0, y:0, width:contact_view.frame.size.width, height:1)
                    line.backgroundColor = UIColor.lightGray
                    
                    self.line_vertical.frame = CGRect(x:contact_view.frame.size.width/2, y: line.frame.origin.y, width:1 , height:contact_view.frame.size.height)
                    line_vertical.backgroundColor = UIColor.lightGray
                }
            }
        }else if(messageFrame.message.chat_type == "group"){
            if(messager?.from == MessageFrom(rawValue: 1)!){
                let mob_no:String = Themes.sharedInstance.GetMyPhonenumber()
                let user_mob:String = mob_no.substring(from: mob_no.index(mob_no.endIndex, offsetBy: -10))
                if(messageFrame.message.contact_phone == mob_no || messageFrame.message.contact_phone == user_mob){
                    self.contact_view.isHidden = true
                }
                else if(self.checkFavourite(user_id: messageFrame.message.contact_id) == false){
                    send_message = false
                    message.frame = CGRect(x:0, y: 4, width:contact_view.frame.size.width , height:40)
                    save_contact.isHidden = true
                    message.setTitle("Invite", for: .normal)
                    message.setTitleColor(UIColor(red:1/255, green:169/255, blue:229/255, alpha: 1), for: .normal)
                    message.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
                    
                    self.line.frame = CGRect(x:0, y:0, width:contact_view.frame.size.width, height:1)
                    line.backgroundColor = UIColor.lightGray
                    save_contact.isHidden = true
                    line_vertical.isHidden = true
                    
                }else{
                    send_message = true
                    
                    message.frame = CGRect(x:0, y: 4, width:contact_view.frame.size.width , height:40)
                    
                    message.setTitle("Message", for: .normal)
                    message.setTitleColor(UIColor(red:1/255, green:169/255, blue:229/255, alpha: 1), for: .normal)
                    message.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
                    
                    self.line.frame = CGRect(x:0, y:0, width:contact_view.frame.size.width, height:1)
                    line.backgroundColor = UIColor.lightGray
                    save_contact.isHidden = true
                    line_vertical.isHidden = true
                }
                
                
            }else{
                
                
                let mycontacts = getContacts(id: messageFrame.message.contact_phone)
                let favcontacts = checkFavContact(phone: messageFrame.message.contact_phone)
                
                if((messageFrame.message.contact_id == messageFrame.message.user_from) && (mycontacts == true)){
                    
                    send_message = false
                    
                    message.frame = CGRect(x:0, y: 4, width:contact_view.frame.size.width , height:40)
                    save_contact.isHidden = true
                    if(favcontacts == true)
                    {
                        message.setTitle("Message", for: .normal)
                        send_message = true
                    }
                    else
                    {
                        message.setTitle("Invite", for: .normal)
                        send_message = false
                    }
                    message.setTitleColor(UIColor(red:1/255, green:169/255, blue:229/255, alpha: 1), for: .normal)
                    message.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
                    
                    
                    self.line.frame = CGRect(x:0, y:0, width:contact_view.frame.size.width, height:1)
                    line.backgroundColor = UIColor.lightGray
                    save_contact.isHidden = true
                    line_vertical.isHidden = true
                    
                }
                else if((messageFrame.message.contact_id == messageFrame.message.user_from) && (mycontacts == false)){
                    send_message = false
                    save_contact.frame = CGRect(x:0, y: 4, width:contact_view.frame.size.width/2 , height:40)
                    
                    save_contact.setTitle("Save Contact", for: .normal)
                    save_contact.setTitleColor(UIColor(red:1/255, green:169/255, blue:229/255, alpha: 1), for: .normal)
                    save_contact.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
                    
                    message.frame = CGRect(x:contact_view.frame.size.width/2, y: 4, width:contact_view.frame.size.width/2  , height:40)
                    
                    if(favcontacts == true)
                    {
                        message.setTitle("Message", for: .normal)
                        send_message = true
                    }
                    else
                    {
                        message.setTitle("Invite", for: .normal)
                        send_message = false
                    }
                    message.setTitleColor(UIColor(red:1/255, green:169/255, blue:229/255, alpha: 1), for: .normal)
                    message.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
                    
                    self.line.frame = CGRect(x:0, y:0, width:contact_view.frame.size.width, height:1)
                    line.backgroundColor = UIColor.lightGray
                    
                    self.line_vertical.frame = CGRect(x:contact_view.frame.size.width/2, y: line.frame.origin.y, width:1 , height:contact_view.frame.size.height)
                    line_vertical.backgroundColor = UIColor.lightGray
                    
                }else if((messageFrame.message.contact_id != messageFrame.message.user_from) && (mycontacts == true)){
                    send_message = true
                    message.frame = CGRect(x:0, y: 4, width:contact_view.frame.size.width , height:40)
                    save_contact.isHidden = true
                    if(favcontacts == true)
                    {
                        message.setTitle("Message", for: .normal)
                        send_message = true
                    }
                    else
                    {
                        message.setTitle("Invite", for: .normal)
                        send_message = false
                    }
                    message.setTitleColor(UIColor(red:1/255, green:169/255, blue:229/255, alpha: 1), for: .normal)
                    message.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
                    
                    self.line.frame = CGRect(x:0, y:0, width:contact_view.frame.size.width, height:1)
                    line.backgroundColor = UIColor.lightGray
                    save_contact.isHidden = true
                    line_vertical.isHidden = true
                }else if((messageFrame.message.contact_id != messageFrame.message.user_from) && (mycontacts == false)){
                    send_message = true
                    save_contact.frame = CGRect(x:0, y: 4, width:contact_view.frame.size.width/2 , height:40)
                    
                    save_contact.setTitle("Save Contact", for: .normal)
                    save_contact.setTitleColor(UIColor(red:1/255, green:169/255, blue:229/255, alpha: 1), for: .normal)
                    save_contact.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
                    
                    message.frame = CGRect(x:contact_view.frame.size.width/2, y: 4, width:_bubbleImage.frame.size.width/2  , height:40)
                    if(favcontacts == true)
                    {
                        message.setTitle("Message", for: .normal)
                        send_message = true
                    }
                    else
                    {
                        message.setTitle("Invite", for: .normal)
                        send_message = false
                    }
                    message.setTitleColor(UIColor(red:1/255, green:169/255, blue:229/255, alpha: 1), for: .normal)
                    message.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
                    
                    self.line.frame = CGRect(x:0, y:0, width:contact_view.frame.size.width, height:1)
                    line.backgroundColor = UIColor.lightGray
                    
                    self.line_vertical.frame = CGRect(x:contact_view.frame.size.width/2, y: line.frame.origin.y, width:1 , height:contact_view.frame.size.height)
                    line_vertical.backgroundColor = UIColor.lightGray
                }
            }
        }
    }
    
    func checkFavourite(user_id:String) ->Bool{
        var is_favour:Bool = false
        let Checkuser:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "id", FetchString: user_id)
        if(Themes.sharedInstance.Getuser_id() != user_id){
            if(Checkuser){
                is_favour = true
            }
        }
        
        
        return is_favour
    }
    
    func setLinkFrame(){
        
        Urlpreview.frame.size.height = 100
        Urlpreview.frame.size.width = 245
        
    }
    
    func setUrlPreviewFrame(_ messageFrame: UUMessageFrame!,IndexPath:NSIndexPath)
    {
        
        let message:UUMessage! = messageFrame.message
        
        descLabel.font=descLabel.font.withSize(12)
        descLabel.numberOfLines = 0
        
        titleLabel.font = UIFont.boldSystemFont(ofSize:16.0)
        titleLabel.numberOfLines = 0
        //descLabel.sizeToFit()
        var title = messageFrame.message.title_str
        var description = messageFrame.message.desc
        
        //removing unwanted characters...
        if let range = title?.range(of:"{"){
            let firstPart = title?[(title?.startIndex)!..<range.lowerBound]
            title=String(firstPart!)
        }
        
        if let range = description?.range(of:"{"){
            
            let firstPart = description?[(description?.startIndex)!..<range.lowerBound]
            description=String(firstPart!)
            
        }
        
        self.linkImage.sd_setImage(with: URL(string:messageFrame.message.imageURl), placeholderImage: UIImage(named: "favicons"), options: .refreshCached)
        
        descLabel.text = description
        titleLabel.text = title
        
        descLabel.lineBreakMode = .byTruncatingTail
        
        titleLabel.adjustsFontSizeToFitWidth = true
        
        if((messageFrame.message.desc) != ""){
            //print("sdkcjdkcbdkjbc")
            
            if message?.from == MessageFrom(rawValue: 1)!{
                Urlpreview.frame =  CGRect(x: 10, y:5 , width:245, height: 100)
            }else{
                Urlpreview.frame =  CGRect(x: 13, y:5 , width:245, height: 100)
            }
            
            print(Urlpreview.frame)
            //Urlpreview.autoresizingMask = autoresizing
            Urlpreview.layer.cornerRadius = 10
            Urlpreview.clipsToBounds = true
            titleLabel.frame = CGRect(x:4,y:0, width:Urlpreview.frame.size.width/2, height:45)
            titleLabel.adjustsFontForContentSizeCategory = true
            //titleLabel.adjustsFontSizeToFitWidth = true
            
            if message?.from == MessageFrom(rawValue: 1)!{
                linkImage.frame = CGRect(x:Urlpreview.frame.origin.x + Urlpreview.frame.size.width - 60, y:0, width: 50, height: 50)
            }else{
                linkImage.frame = CGRect(x:Urlpreview.frame.origin.x + Urlpreview.frame.size.width - 63, y:0, width: 50, height: 50)
            }
            
            //linkImage.contentMode = .scaleAspectFill
            descLabel.frame = CGRect(x:4,y:titleLabel.frame.origin.y + titleLabel.frame.size.height + 2, width:Urlpreview.frame.size.width - linkImage.frame.size.width, height: Urlpreview.frame.size.height/2)
            
            Urlpreview.backgroundColor = UIColor.lightText
            Urlpreview.backgroundColor = UIColor.init(white: 0.7, alpha: 0.5)
            isFromUrlPrev = true
            
        }else{
            
            Urlpreview.isHidden = true
            
        }
        
    }
    
    override func prepareForReuse() {
        self.btnContent.backImageView.image = nil
    }
}

extension UUMessageCell : UITextViewDelegate
{
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if (URL.absoluteString == "") {
            UIApplication.shared.open(URL, options: [:], completionHandler: nil)
        }
        return false
    }
}


