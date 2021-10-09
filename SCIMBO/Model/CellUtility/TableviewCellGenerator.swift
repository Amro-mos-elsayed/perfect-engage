//
//  CustomTableviewCell.swift
//
//  Created by raguraman on 20/06/18.
//  Copyright © 2018 CASPERON. All rights reserved.
//

public var outgoingBubbleColour: UIColor = UIColor(red: 221/255, green: 255/255, blue: 192/255, alpha: 1.0)
public var incommingBubbleColour: UIColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1.0)
public var outgoingHighlightColour: UIColor = UIColor(red: 200/255, green: 229/255, blue: 177/255, alpha: 1.0)
public var incommingHighlightColour: UIColor = UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 1.0)

import UIKit
import SDWebImage
import SwiftyGif

class TableviewCellGenerator{
    static let sharedInstance = TableviewCellGenerator()
    public var max_witdh_percent: CGFloat = 0.8
    public var max_img_witdh_percent: CGFloat = 0.75
    public var image_max_height_percent:CGFloat = 0.35
    public var defaultFont: UIFont = UIFont.systemFont(ofSize: 16.0)
    public var deletedFont: UIFont = UIFont.italicSystemFont(ofSize:16.0)
    public var emojiFont: UIFont = UIFont.systemFont(ofSize: 45.0)
    
    private var normalCellWith:CGFloat{
        get{
            return UIScreen.main.bounds.width*max_witdh_percent
        }
    }
    private var imageCellWith:CGFloat{
        get{
            return UIScreen.main.bounds.width*max_img_witdh_percent
        }
    }
    private var imageMaxHeight:CGFloat{
        get{
            return UIScreen.main.bounds.height*image_max_height_percent
        }
    }
    private var contacts_ArrObj = [NSObject]()
    private var contactNoArr:NSMutableArray = NSMutableArray()
    
    private var ReplyrangeArr : [NSRange] = [NSRange]()
    private var ReplyIdArr : [String] = [String]()
    
    
    fileprivate func getMessageLabelText(_ messageFrame: UUMessageFrame, label: UILabel, cell: CustomTableViewCell) {
        
        var payload = ""
        
        let message:UUMessage! = messageFrame.message
        if(messageFrame.message.chat_type == "group")
        {
            if(message.message_type == "14")
            {
                payload = "\(messageFrame.message.title_place!)\n\(messageFrame.message.stitle_place!)"
            }
            else
            {
                payload = messageFrame.message.payload
                
            }
        }
        else
        {
            if(message.message_type == "14")
            {
                payload = "\(messageFrame.message.title_place!)\n\(messageFrame.message.stitle_place!)"
            }
            else
            {
                payload = (messageFrame.message.payload)!
            }
        }
        
        let arr = Themes.sharedInstance.getID_Range_Payload_Name(message: payload)
        
        cell.TagIdArr = arr[0] as! [String]
        cell.TagRangeArr = arr[1] as! [NSRange]
        payload = arr[2] as! String
        
        var attributed = NSMutableAttributedString(string: payload)
        
        attributed.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15.0)], range: NSMakeRange(0, payload.length))
        
        _ = cell.TagRangeArr.map {
            attributed.addAttributes([NSAttributedString.Key.foregroundColor : CustomColor.sharedInstance.themeColor, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15.0)], range: $0)
            
            attributed.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.lightGray, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15.0)], range: NSMakeRange($0.location-1, 1))
        }
        if(cell.TagRangeArr.count > 0)
        {
            label.attributedText = attributed
        }
        else
        {
            label.text = payload
        }
        
        var types: NSTextCheckingResult.CheckingType = .link
        var detector = try? NSDataDetector(types: types.rawValue)
        let matches = detector?.matches(in: label.text!, options: .reportCompletion, range: NSMakeRange(0, (label.text?.count)!))
        
        types = .phoneNumber
        detector = try? NSDataDetector(types: types.rawValue)
        let matches1 = detector?.matches(in: label.text!, options: .reportCompletion, range: NSMakeRange(0, (label.text?.count)!))

//        print(">>>>>>>>>>>>> \(matches)")
        var isAttribute = false
        for match in matches! {
            isAttribute = true
            attributed = setAsLink(match.range, attributed)
        }
        for match in matches1! {
            isAttribute = true
            attributed = setAsLink(match.range, attributed)
        }
        if isAttribute {
            label.attributedText = attributed
        }
        label.setLineSpacing(lineSpacing: 2.0)
        label.decideTextDirection()
    }
    
    func setAsLink(_ foundRange : NSRange?,_ attributed : NSMutableAttributedString) -> NSMutableAttributedString
    {
        if let foundRange = foundRange {
            if foundRange.location != NSNotFound {
                let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
                let colorAttribute = [NSAttributedString.Key.foregroundColor: UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)]
                attributed.addAttributes(underlineAttribute, range: foundRange)
                attributed.addAttributes(colorAttribute, range: foundRange)
            }
        }
        return attributed
    }

    
    fileprivate func getTimeLabelText(_ messageFrame: UUMessageFrame) -> String{
        if(messageFrame.message.timestamp != nil)
        {
            let dateStr:String = Themes.sharedInstance.ReturnTimeForChat(timestamp: messageFrame.message.timestamp!)
            if(messageFrame.message.isStar == "1")
            {
                return "🚩\(dateStr)"
            }
            else
            
            {
                return dateStr
            }
        }else{
            return ""
        }
    }
    
    fileprivate func setStatusIcon(_ messageFrame: UUMessageFrame!) -> UIImage?
    {
        //        self.messageFrame = messageFrame
        if(messageFrame.message.from == MessageFrom(rawValue: 1))
        {
            //            self.StatusMark.isHidden=false
            if(messageFrame.message.message_status == "1")
            {
                return UIImage(named: "singletick")!
            }
            else if(messageFrame.message.message_status == "2")
            {
                return UIImage(named: "doubletick")!
            }
            else if(messageFrame.message.message_status == "3")
            {
                return UIImage(named: "doubletickgreen")!
            }
            else
            {
                return UIImage(named: "wait")!
                
            }
        }
        else
        {
            return nil
            
        }
    }
    
    
    
    
    fileprivate func getLabelDeatil(_ sender: UILabel, maxWidth: CGFloat = 262.5) -> (height:CGFloat, lineCount:Int){
        
        let localTextView = UITextView()
        localTextView.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: maxWidth, height: CGFloat(MAXFLOAT))
        localTextView.font = sender.font
        localTextView.setLineSpacing(lineSpacing: 2.0)
        localTextView.text = sender.font != emojiFont ? (sender.text ?? "") + "★11:08 AM  " : sender.text
        
        
        localTextView.sizeToFit()
        
        var calculatedHeight = localTextView.frame.height
        if sender.numberOfLines < localTextView.numberOfLines(){
            calculatedHeight = localTextView.heightForLines(sender.numberOfLines+(3))
        }
        if sender.font == emojiFont{
            calculatedHeight += 5
        }else if localTextView.numberOfLines() > 1{
            calculatedHeight += 10
        }
        return (height:calculatedHeight, lineCount:localTextView.numberOfLines())
    }
    
    fileprivate func thumbnailSetter(_ messageFrame: UUMessageFrame, in imageView:UIImageView, cell:ImageTableViewCell){
        let message:UUMessage! = messageFrame.message
        let upload_status:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "upload_status") as! String
        let _:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "download_status") as! String
        let failure_status:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "failure_status") as! String
        let upload_paused:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "upload_paused") as! String
        
        if message?.from == MessageFrom(rawValue: 1)!
        {
            
            if(upload_status == "1" && failure_status == "0")
            {
                cell.hideLoaderView(true)
                
            }else if(upload_status == "1"){
                
                cell.hideLoaderView(true)
                
            }
            else if(upload_status == ""){
                cell.hideLoaderView(true)
            }
            else
            {
                cell.hideLoaderView(false)
            }
            
            
            
            if(upload_status == "1")
            {
                cell.customButton.setImage(#imageLiteral(resourceName: "playIcon.png"), for: .normal)
            }
            else if(upload_status == ""){
                cell.customButton.setImage(#imageLiteral(resourceName: "playIcon.png"), for: .normal)
            }
            else
            {
                cell.customButton.setImage(nil, for: .normal)
            }
            
            print("pause\(upload_paused) || status\(upload_status)")
            if (upload_paused == "1")&&(upload_status == "0"){
                cell.setTrilingConstraint(50, animated: false)
                cell.hideLoaderView(true)
                cell.customButton.setImage(#imageLiteral(resourceName: "playIcon.png"), for: .normal)
            }else{
                cell.setTrilingConstraint(0, animated: false)
            }
            cell.gifImg.isHidden = true
            cell.chatImg.isHidden = false
            UploadHandler.Sharedinstance.loadVideoThumbnailOfMe(messageFrame: messageFrame, ImageView: imageView)
        }
        else
        {
            cell.gifImg.isHidden = true
            cell.chatImg.isHidden = false
            cell.customButton.setImage(#imageLiteral(resourceName: "playIcon.png"), for: .normal)
            UploadHandler.Sharedinstance.loadVideoThumbnailOfOthers(messageFrame: messageFrame, ImageView: imageView)
            cell.hideLoaderView(true)
        }
    }
    
    fileprivate func imageSetter(_ messageFrame: UUMessageFrame, in imageView: UIImageView, gifImageView: UIImageView, cell:ImageTableViewCell){
        let message:UUMessage! = messageFrame.message
        print(messageFrame.message.thumbnail)
        let upload_status:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "upload_status") as! String
        let failure_status:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "failure_status") as! String
        let upload_paused:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "upload_paused") as! String
        
        if message?.from == MessageFrom(rawValue: 1)!
        {
            if(upload_status == "1" && failure_status == "0")
            {
                cell.hideLoaderView(true)
            }else if(upload_status == "1"){
                cell.hideLoaderView(true)
            }
            else if(upload_status == ""){
                cell.hideLoaderView(true)
            }
            else
            {
                cell.hideLoaderView(false)
                
            }
            print("pause\(upload_paused) || status\(upload_status)")
            if (upload_paused == "1")&&(upload_status == "0"){
                cell.setTrilingConstraint(50, animated: false)
                cell.hideLoaderView(true)
            }else{
                cell.setTrilingConstraint(0, animated: false)
            }
        }
        
        
        self.loadImage(messageFrame, in: imageView, gifImageView: gifImageView, cell: cell)
        
    }
    
    
    func loadImage(_ messageFrame : UUMessageFrame, in imageView:UIImageView, gifImageView: UIImageView, cell:ImageTableViewCell){
        imageView.image = nil
        gifImageView.image = nil
        if(messageFrame.message.type == MessageType(rawValue: 1))
        {
            let serverpath:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "serverpath") as! String
            
            let PhotoPath:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "upload_Path") as! String
            
            if(messageFrame.message.from == MessageFrom(rawValue: 0))
            {
                if((URL(string: serverpath))?.pathExtension.lowercased() == "gif")
                {
                    imageView.isHidden = true
                    gifImageView.isHidden = false
                    self.loadGifImage(messageFrame, in: gifImageView, cell: cell)
                }
                else
                {
                    imageView.isHidden = false
                    gifImageView.isHidden = true
                    self.loadNormalImage(messageFrame, in: imageView, cell: cell)
                }
            }
            else
            {
                if(URL(fileURLWithPath: PhotoPath).pathExtension.lowercased() == "gif")
                {
                    imageView.isHidden = true
                    gifImageView.isHidden = false
                    self.loadGifImage(messageFrame, in: gifImageView, cell: cell)
                }
                else
                {
                    imageView.isHidden = false
                    gifImageView.isHidden = true
                    self.loadNormalImage(messageFrame, in: imageView, cell: cell)
                    
                }
            }
        }
    }
    
    func loadNormalImage(_ messageFrame : UUMessageFrame, in imageView:UIImageView, cell:ImageTableViewCell)
    {
        cell.customButton.setImage(nil, for: .normal)

        let download_status:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "download_status") as! String
        
        let PhotoPath:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "upload_Path") as! String
       
        var ThembnailData:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "compressed_data") as! String
       
        let str:String = "data:image/jpg;base64,";
        
        if !ThembnailData.contains("data:image")
        {
            ThembnailData = str.appending(ThembnailData)
        }
        
        imageView.sd_setImage(with: URL(string:ThembnailData))

        
        if(download_status == "2"){
            if messageFrame.message.from != MessageFrom(rawValue: 1)!
            {
                cell.hideLoaderView(true)
            }
            
            if FileManager.default.fileExists(atPath: PhotoPath) {
                let url = URL(fileURLWithPath: PhotoPath)
                imageView.sd_setImage(with: url)
            }else{
                let param:NSDictionary = ["download_status":"0"]
                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Upload_Details, FetchString: messageFrame.message.thumbnail!, attribute: "upload_data_id", UpdationElements: param)
                cell.hideLoaderView(false, isUpload: false)
                
                DownloadHandler.sharedinstance.handleDownLoad(false)

            }
        }else if (download_status == "0"){
            cell.hideLoaderView(false, isUpload: false)
            let autodownload  = UploadHandler.Sharedinstance.GetAutoDownloadInfo(file_type: "photos", download_status: download_status)
            if autodownload{
                DownloadHandler.sharedinstance.handleDownLoad(false)
            }
        }else{
            cell.hideLoaderView(false, isUpload: false, downloadViewState: .indeterminate)
        }
    }
    
    func loadGifImage(_ messageFrame : UUMessageFrame, in imageView:UIImageView, cell:ImageTableViewCell)
    {
        
        let download_status:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "download_status") as! String
        
        let upload_status:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "upload_status") as! String
        
        let upload_paused:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "upload_paused") as! String
        
        let PhotoPath:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "upload_Path") as! String
       
        if(upload_status == "1" || upload_paused == "1")
        {
            cell.customButton.setImage(#imageLiteral(resourceName: "gifIcon"), for: .normal)
        }
        else
        {
            cell.customButton.setImage(nil, for: .normal)
        }
        
        var ThembnailData:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "compressed_data") as! String
        let str:String = "data:image/jpg;base64,";
        if !ThembnailData.contains("data:image")
        {
            ThembnailData = str.appending(ThembnailData)
        }
        do {
            imageView.image = UIImage(cgImage: (UIImage(data: try Data(contentsOf: URL(string:ThembnailData)!))?.cgImage)!, scale: 1.0, orientation: UIImage.Orientation.up)
        }
        catch {
            print(error.localizedDescription)
        }
        
        if(download_status == "2"){
            if messageFrame.message.from != MessageFrom(rawValue: 1)!
            {
                cell.hideLoaderView(true)
            }
            
            if FileManager.default.fileExists(atPath: PhotoPath) {
                let url = URL(fileURLWithPath: PhotoPath)
                do {
                    let image = UIImage(gifData: try Data(contentsOf: url))
                    imageView.setGifImage(image)
                    imageView.stopAnimatingGif()
                }
                catch {
                    print(error.localizedDescription)
                }
            }else{
                let param:NSDictionary = ["download_status":"0"]
                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Upload_Details, FetchString: messageFrame.message.thumbnail!, attribute: "upload_data_id", UpdationElements: param)
                cell.hideLoaderView(false, isUpload: false)
                DownloadHandler.sharedinstance.handleDownLoad(false)
            }
        }else if (download_status == "0"){
            cell.hideLoaderView(false, isUpload: false)
            let autodownload  = UploadHandler.Sharedinstance.GetAutoDownloadInfo(file_type: "photos", download_status: download_status)
            if autodownload{
                DownloadHandler.sharedinstance.handleDownLoad(false)
            }
        }else{
            cell.hideLoaderView(false, isUpload: false, downloadViewState: .indeterminate)
        }
    }
    
    fileprivate func GetThumbnail(docID:String)->String
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
    
    fileprivate func replayViewSetter(_ messageFrame: UUMessageFrame, cell:ReplayTableViewCell){
        let messageFromID:String = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Reply_detail, attrib_name: "doc_id", fetchString: messageFrame.message.doc_id, returnStr: "from_id")
        let message_type:String = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Reply_detail, attrib_name: "doc_id", fetchString: messageFrame.message.doc_id, returnStr: "message_type")
        let message:UUMessage! = messageFrame.message
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
                cell.replayName.text = "You • Status"
                
            }
            else
            {
                cell.replayName.text = "You"
            }
            cell.replaycolour.backgroundColor = UIColor(red:23/255, green:109/255, blue:69/255, alpha:1.0)
            cell.replayName.textColor = UIColor(red:23/255, green:109/255, blue:69/255, alpha:1.0)
            
        }
        else
        {
            if(messageFrame.message.reply_type == "status")
            {
                cell.replayName.text = "\(Themes.sharedInstance.setNameTxt(messageFromID, "single")) • Status"
            }
            else
            {
                cell.replayName.setNameTxt(messageFromID, "single")
            }
            cell.replaycolour.backgroundColor = UIColor.orange
            cell.replayName.textColor = UIColor.orange
            
        }
        
        print(payload, messageFrame.message.doc_id)
        if(message_type == "1")
        {
            cell.replayImgWidth.constant = 55
            let ThembnailData:String! = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Reply_detail, attrib_name: "doc_id", fetchString: messageFrame.message.doc_id, returnStr: "compressed_data")
            var str:String = "data:image/jpg;base64,";
            if ThembnailData!.contains("data:image")
            {
                str = ThembnailData
            }
            else
            {
                str = str.appending(ThembnailData)
            }
            do{
                
                let imageData = try Data(contentsOf: URL(string: str)!)
                let image = UIImage(data: imageData)
                cell.replayImg.image = image
                cell.replayImg.isHidden = false
            }
            catch{
                print("data loading Error \(error.localizedDescription)")
            }
            cell.replayMsg.text = "📷 Photo"
        }
        else if(message_type == "2")
        {
            cell.replayImgWidth.constant = 55
            let ThembnailData:String! = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Reply_detail, attrib_name: "doc_id", fetchString: messageFrame.message.doc_id, returnStr: "compressed_data")
            var str:String = "data:image/jpg;base64,";
            if ThembnailData!.contains("data:image")
            {
                str = ThembnailData
            }
            else
            {
                str = str.appending(ThembnailData)
            }
            let ImageData = NSData(contentsOf:URL(string:str)!)
            let image:UIImage? = UIImage(data: ImageData! as Data)
            cell.replayImg.image = image
            cell.replayImg.isHidden = false
            cell.replayMsg.text = "📹 Video"
        }
        else if(message_type == "3")
        {
            cell.replayImgWidth.constant = 0
            cell.replayImg.isHidden = true
            cell.replayMsg.text = "🎵 Audio"
            
        }
        else if(message_type == "5")
        {
            cell.replayImgWidth.constant = 0
            cell.replayImg.isHidden = true
            cell.replayMsg.text = "📝 Contact"
            
        }
        else if(message_type == "6" || message_type == "20")
        {
            cell.replayImgWidth.constant = 0
            cell.replayImg.isHidden = true
            cell.replayMsg.text = "📄 Document"
            
        }
        else if(message_type == "14")
        {
            cell.replayImgWidth.constant = 0
            cell.replayImg.isHidden = true
            cell.replayMsg.text = payload
            
        }
        else if(message_type == "4"){
            cell.replayImgWidth.constant = 0
            cell.replayImg.isHidden = true
            cell.replayMsg.text = payload
            
        }
        else if(message_type == "0")
        {
            cell.replayImgWidth.constant = 0
            cell.replayImg.isHidden = true
            cell.replayMsg.text = payload
            
        }else if(message_type == "7")
        {
            cell.replayImgWidth.constant = 0
            cell.replayImg.isHidden = true
            cell.replayMsg.text = payload
        }
        //        ReplyRecordID = recordId
        
        if(payload.length > 0)
        {
            let attributed = NSMutableAttributedString(string: cell.replayMsg.text!)
            
            attributed.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15.0)], range: NSMakeRange(0, (cell.replayMsg.text?.length)!))
            _ = self.ReplyrangeArr.map {
                attributed.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15.0)], range: $0)
            }
            if(self.ReplyrangeArr.count > 0)
            {
                cell.replayMsg.attributedText = attributed
            }
        }
        cell.replayMsg.decideTextDirection()
    }
    
    fileprivate func checkFavContact(phone:String) ->Bool{
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
    
    fileprivate func getProfileImage(phone:String) -> String{
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
    
    fileprivate func contactButtonSetter(_ messageFrame:UUMessageFrame, cell:ContactTableViewCell){
        
        var IsInMyContact = false
        var IsUsingApp = false
        var IsMyContact = false
        
        IsInMyContact = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Contact_add, attribute: "contact_mobilenum", FetchString: messageFrame.message.contact_phone!)
        IsInMyContact = !IsInMyContact ? DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "msisdn", FetchString: messageFrame.message.contact_phone!) : IsInMyContact
        IsMyContact = Themes.sharedInstance.GetMyPhonenumber().contains(messageFrame.message.contact_phone)
        IsUsingApp = messageFrame.message.contact_profile != "nil" && messageFrame.message.contact_profile != ""
        
        if(IsMyContact) {
            cell.doubleButtonView.isHidden = true
            cell.singleButtonView.isHidden = true
        }
        else {
//            if IsInMyContact, IsUsingApp {
//                cell.doubleButtonView.isHidden = true
//                cell.singleButtonView.isHidden = false
//                cell.singleButton.setTitle(contactTitle.msg.rawValue, for: .normal)
//            }
//            else if IsInMyContact, !IsUsingApp {
//                cell.doubleButtonView.isHidden = true
//                cell.singleButtonView.isHidden = false
//                cell.singleButton.setTitle(contactTitle.invite.rawValue, for: .normal)
//            }
             if  IsUsingApp {
                cell.doubleButtonView.isHidden = false
                cell.singleButtonView.isHidden = true
                cell.saveContactBtn.setTitle(contactTitle.contact.rawValue, for: .normal)
                cell.inviteContatBtn.isHidden = false
                cell.inviteContatBtn.setTitle(contactTitle.msg.rawValue, for: .normal)
            }
            else if !IsInMyContact || !IsUsingApp {
                cell.doubleButtonView.isHidden = false
                cell.singleButtonView.isHidden = true
                cell.seperatorLabel?.backgroundColor = UIColor.white
                cell.seperatorLabel?.isHidden = true
                cell.inviteContatBtn.isHidden = true
                cell.saveContactBtn.setTitle(contactTitle.contact.rawValue, for: .normal)
           
                             
            }
        }
    }
    
    fileprivate func contactImgSetter(_ messageFrame: UUMessageFrame, cell:ContactTableViewCell){
        cell.contactImg.sd_setImage(with: URL(string: messageFrame.message.contact_profile),placeholderImage: UIImage(named: "avatar"), options: .refreshCached)
    }
    
    fileprivate func FetchContactImage(_ messageFrame:UUMessageFrame) -> String!
    {
        var userProf:String! = String()
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
    
    fileprivate func setUrlPreviewFrame(_ messageFrame: UUMessageFrame!, cell:URLTableViewCell, calculatedValue: CGFloat)
    {
        
        
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
        let myAttribute = [ NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor.black]
        let myString = NSMutableAttributedString(string: "\(String(describing: title!))", attributes: myAttribute )
        
        let myAttribute1 = [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13), NSAttributedString.Key.foregroundColor: UIColor.black.withAlphaComponent(0.5)]
        myString.append(NSMutableAttributedString(string: "\n\(String(describing: description!))", attributes: myAttribute1 ))
        cell.urlTextView.attributedText = myString
        
        let sampleTextView = UITextView()
        sampleTextView.frame = CGRect(x: 0, y: 0, width: 262.5, height: CGFloat.leastNormalMagnitude)
        sampleTextView.attributedText = myString
        sampleTextView.sizeToFit()
        var viewHeight = sampleTextView.frame.height
        print(sampleTextView.frame.height)
        
        if let url = messageFrame.message.imageURl, url != ""{
            print(url)
            cell.urlImgView.isHidden = false
            cell.urlImgView.sd_setImage(with: URL(string:url), placeholderImage: UIImage(named: "favicons"), options: .refreshCached) { (img, err, type, url) in
            }
            
        }
        else{
            viewHeight -= 20
            cell.urlImgView.isHidden = true
        }
        
        cell.urlViewHeightConstraint.constant = viewHeight
        messageFrame.message.messageheight = calculatedValue+viewHeight
        
    }
    
    fileprivate func audioDownloadHandler(_ messageFrame: UUMessageFrame, _ cell: AudioTableViewCell) {
        cell.isDownloadInProgress(.indeterminate)
        let serverpath:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "serverpath") as! String
        
        let param:NSDictionary = ["download_status":"0"]
        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Upload_Details, FetchString: messageFrame.message.thumbnail!, attribute: "upload_data_id", UpdationElements: param)

        DownloadHandler.sharedinstance.handleDownLoad(true)
        cell.audioDuration.textColor = UIColor.lightGray
        
        DispatchQueue.global(qos: .background).async {
            let upload_PathData = NSData(contentsOf:URL(string:serverpath)!)
            DispatchQueue.main.async {
                cell.songData = upload_PathData as Data?
            }
        }
        
        DispatchQueue.global(qos: .background).async {
            let time = self.ReturnruntimeDuration(sourceMovieURL:URL(string:serverpath)!)
            DispatchQueue.main.async {
                cell.audioDuration.text = time
            }
        }
    }
    
    
    fileprivate func setAudioCell(_ messageFrame: UUMessageFrame, cell:AudioTableViewCell){
        let message:UUMessage! = messageFrame.message
        let download_status:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "download_status") as! String
        var upload_Path:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "upload_Path") as! String
        cell.useImg.image = #imageLiteral(resourceName: "avatar")
        let userImgUrl = message?.from == MessageFrom(rawValue: 1)! ? Themes.sharedInstance.setProfilePic(Themes.sharedInstance.Getuser_id(), "single") : self.FetchContactImage(messageFrame)
        if let userImgUrl = userImgUrl, userImgUrl != ""{
            let nsURL = URL(string:userImgUrl)! as  URL
            cell.useImg.sd_setImage(with: nsURL, placeholderImage: #imageLiteral(resourceName: "avatar"), options: .refreshCached)
        }
        if(messageFrame.message.from == MessageFrom(rawValue: 1)!)
        {
            let upload_status = Themes.sharedInstance.CheckNullvalue(Passed_value: UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "upload_status"))
            if(upload_status == "0")
            {
                cell.isDownloadInProgress(.indeterminate)
            }
            else
            {
                cell.isDownloadInProgress(.none)
            }
            if(upload_Path != "")
            {
                if FileManager.default.fileExists(atPath: upload_Path) {
                    let upload_PathData = NSData(contentsOf:URL(fileURLWithPath:upload_Path))
                    cell.audioSlider.setValue(0.0, animated: true)
                    cell.audioDuration.text = self.ReturnruntimeDuration(sourceMovieURL:URL(fileURLWithPath:upload_Path))
                    cell.audioDuration.textColor = UIColor.lightGray
                    cell.songData = upload_PathData as Data?
                }
                else
                {
                    audioDownloadHandler(messageFrame, cell)
                }
            }
        }
        else
        {
            if download_status == "0"{
                let autodownload  = UploadHandler.Sharedinstance.GetAutoDownloadInfo(file_type: "audio", download_status: download_status)
                if autodownload{
                    audioDownloadHandler(messageFrame, cell)
                }else{
                    cell.showManualDownload()
                }
            }else if download_status == "1"{
                cell.isDownloadInProgress(.indeterminate)
            }else if download_status == "2"{
                upload_Path = upload_Path.replacingOccurrences(of: "file:///", with: "")
                cell.isDownloadInProgress(.none)
                if(upload_Path != "")
                {
                    if FileManager.default.fileExists(atPath: upload_Path) {
                        let upload_PathData = NSData(contentsOf:URL(fileURLWithPath:upload_Path))
                        cell.audioSlider.setValue(0.0, animated: true)
                        cell.audioDuration.text = self.ReturnruntimeDuration(sourceMovieURL:URL(fileURLWithPath:upload_Path))
                        cell.audioDuration.textColor = UIColor.lightGray
                        cell.songData = upload_PathData as Data?
                    }
                    else
                    {
                        audioDownloadHandler(messageFrame, cell)
                    }
                }
            }

        }
    }
    
    
    fileprivate func ReturnruntimeDuration(sourceMovieURL:URL)->String
    {
        do {
            let sourceAsset = try AVAudioPlayer(contentsOf: sourceMovieURL)
            let duration = sourceAsset.duration
            let ti = NSInteger(duration)
            let seconds = ti % 60
            let minutes = (ti / 60) % 60
            return String(format: "%0.2d:%0.2d",minutes,seconds)
        }
        catch {
            print(error.localizedDescription)
        }
        return "00:00"
    }
    
    
    
    fileprivate func SetDocumentDetail(_ messageFrame: UUMessageFrame!, cell:DocTableViewCell)
    {
        var fileName = String()
        if let localValue = messageFrame.message.docName{
            fileName = localValue
        }
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
                cell.fileName.text = fileName
                print(messageFrame.message.docPageCount!, fileName)
                cell.messageLabel.text = "\(messageFrame.message.docPageCount!) pages ● \(Gettotalbyte) ● \((fileName as NSString).pathExtension.uppercased())"
                
                var ThembnailData:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "compressed_data") as! String
                let str:String = "data:image/jpg;base64,";
                
                if !ThembnailData.contains("data:image")
                {
                    ThembnailData = str.appending(ThembnailData)
                }
                
                cell.fileImg.sd_setImage(with: URL(string:ThembnailData)!)
                
                cell.fileTypeImg.image =  #imageLiteral(resourceName: "docicon")
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
                
                cell.fileName.text = fileName
                cell.messageLabel.text = "\(Gettotalbyte) ● \((fileName as NSString).pathExtension.uppercased())"
                
                cell.fileTypeImg.image =  #imageLiteral(resourceName: "docicon")
            }
            let upload_status = Themes.sharedInstance.CheckNullvalue(Passed_value: UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "upload_status"))
            if(upload_status == "0")
            {
                cell.isDownloadInProgress(.indeterminate)
            }
            else
            {
                cell.isDownloadInProgress(.none)
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
                    
                    cell.fileImg.sd_setImage(with: URL(string:ThembnailData)!)
                    
                    let TotalBye:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "total_byte_count") as! String
                    let Gettotalbyte:String = Themes.sharedInstance.transformedValue(TotalBye) as! String
                    
                    cell.fileName.text = fileName
                    cell.messageLabel.text = "\(Gettotalbyte) ● \((fileName as NSString).pathExtension.uppercased())"
                    cell.fileTypeImg.image =  #imageLiteral(resourceName: "docicon")
                    
                }
                else
                {
                    
                    let TotalBye:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "total_byte_count") as! String
                    let Gettotalbyte:String = Themes.sharedInstance.transformedValue(TotalBye) as! String
                    
                    cell.fileName.text = fileName
                    cell.messageLabel.text = "\(Gettotalbyte) ● \((fileName as NSString).pathExtension.uppercased())"
                    cell.fileTypeImg.image =  #imageLiteral(resourceName: "docicon")
                    
                    
                }
                
                
            }
            else
            {
                
                if(messageFrame.message.docType == "1")
                {
                    let TotalBye:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "total_byte_count") as! String
                    let Gettotalbyte:String = Themes.sharedInstance.transformedValue(TotalBye) as! String
                    cell.fileName.text = fileName
                    cell.messageLabel.text = "\(messageFrame.message.docPageCount!) pages ● \(Gettotalbyte) ● \((fileName as NSString).pathExtension.uppercased())"
                    var ThembnailData:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "compressed_data") as! String
                    let str:String = "data:image/jpg;base64,";
                    
                    if !ThembnailData.contains("data:image")
                    {
                        ThembnailData = str.appending(ThembnailData)
                    }
                    
                    cell.fileImg.sd_setImage(with: URL(string:ThembnailData)!)
                    cell.fileTypeImg.image =  #imageLiteral(resourceName: "docicon")
                    
                    cell.fileName.text = fileName
                    cell.messageLabel.text = "\(Gettotalbyte) ● \((fileName as NSString).pathExtension.uppercased())"
                    cell.fileTypeImg.image =  #imageLiteral(resourceName: "docicon")
                }
                else
                {
                    let TotalBye:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "total_byte_count") as! String
                    let Gettotalbyte:String = Themes.sharedInstance.transformedValue(TotalBye) as! String
                    
                    cell.fileName.text = fileName
                    cell.messageLabel.text = "\(Gettotalbyte) ● \((fileName as NSString).pathExtension.uppercased())"
                    cell.fileTypeImg.image =  #imageLiteral(resourceName: "docicon")
                }
            }
            if download_status == "0"{
                let autodownload  = UploadHandler.Sharedinstance.GetAutoDownloadInfo(file_type: "documents", download_status: download_status)
                if autodownload{
                    self.documentDownload(messageFrame, cell: cell)
                }else{
                    cell.showManualDownload()
                }
            }else if download_status == "1"{
                cell.isDownloadInProgress(.indeterminate)
            }else if download_status == "2"{
                var upload_Path:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "upload_Path") as! String
                
                upload_Path = upload_Path.replacingOccurrences(of: "file:///", with: "")
                cell.isDownloadInProgress(.none)
                if(upload_Path != "")
                {
                    if !FileManager.default.fileExists(atPath: upload_Path) {
                        self.documentDownload(messageFrame, cell: cell)
                    }
                }
            }
        }
        cell.hideLoaderView(true)
    }
    
    func documentDownload(_ messageFrame: UUMessageFrame!, cell:DocTableViewCell)
    {
        let download_status:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "download_status") as! String


        if(download_status == "2"){
            let PhotoPath:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "upload_Path") as! String
            
            if FileManager.default.fileExists(atPath: PhotoPath) {
                cell.isDownloadInProgress(.none)
            }else{
                let param:NSDictionary = ["download_status":"0"]
                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Upload_Details, FetchString: messageFrame.message.thumbnail!, attribute: "upload_data_id", UpdationElements: param)
                cell.isDownloadInProgress(.indeterminate)
                DownloadHandler.sharedinstance.handleDownLoad(false)

            }
        }else if (download_status == "0"){
            let autodownload  = UploadHandler.Sharedinstance.GetAutoDownloadInfo(file_type: "documents", download_status: download_status)
            if autodownload{
                DownloadHandler.sharedinstance.handleDownLoad(false)
                cell.isDownloadInProgress(.indeterminate)
            }
            else
            {
                cell.showManualDownload()
            }
        }else{
            cell.isDownloadInProgress(.indeterminate)
        }
    }
    
    public func returnCell(for tableView:UITableView, messageFrame:UUMessageFrame, indexPath : IndexPath) -> CustomTableViewCell{
        var textCell = CustomTableViewCell()
        messageFrame.message.thumbnail = GetThumbnail(docID: messageFrame.message.doc_id)
        
        switch (messageFrame.message.type)
        {
        case MessageType(rawValue: 0)!:
            var cellId = messageFrame.message.from == MessageFrom(rawValue: 1) ? "outgoingText" : "incomingText"
            cellId = cellId.appending("")
            let CustomTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! TextTableViewCell
            CustomTableViewCell.messageFrame = messageFrame
            CustomTableViewCell.readCount = messageFrame.message.readmore_count ?? ""
            CustomTableViewCell.timeLabel.text = getTimeLabelText(messageFrame)
            CustomTableViewCell.messageLabel.font = messageFrame.message.is_deleted == "1" ?  defaultFont : defaultFont
            self.getMessageLabelText(messageFrame, label: CustomTableViewCell.messageLabel, cell: CustomTableViewCell)
            CustomTableViewCell.messageLabel.font = ((CustomTableViewCell.messageLabel.text ?? "").containsOnlyEmoji && (CustomTableViewCell.messageLabel.text ?? "").glyphCount <= 3) ? emojiFont : CustomTableViewCell.messageLabel.font
            CustomTableViewCell.messageLabel.textAlignment = CustomTableViewCell.messageLabel.font == emojiFont ? .center : .left
            if(CustomTableViewCell.messageLabel.font != emojiFont)
            {
                CustomTableViewCell.messageLabel.decideTextDirection()
            }
            CustomTableViewCell.bubleImage = messageFrame.message.from == MessageFrom(rawValue: 1) ? "inBubble" : "outBubble"
            CustomTableViewCell.cellMaxWidth.constant = normalCellWith
            let calculatedValue = getLabelDeatil(CustomTableViewCell.messageLabel, maxWidth: normalCellWith-50)
            CustomTableViewCell.readMoreBtn.isHidden = calculatedValue.lineCount > CustomTableViewCell.messageLabel.numberOfLines ? false : true
            CustomTableViewCell.statusImg?.image = self.setStatusIcon(messageFrame)
            CustomTableViewCell.customButton.setImage(nil, for: .normal)
            if calculatedValue.lineCount > 1 || CustomTableViewCell.messageLabel.font == emojiFont{
                CustomTableViewCell.timeLabelLeadingConstraint.constant = -(CustomTableViewCell.timeLabel.frame.width+10)
                CustomTableViewCell.messageLabelBottom.constant = 30
            }
            else{
                CustomTableViewCell.timeLabelLeadingConstraint.constant = 5
                CustomTableViewCell.messageLabelBottom.constant = 8
            }
            CustomTableViewCell.hideLoaderView(true)
            textCell = CustomTableViewCell
            break
        case MessageType(rawValue: 1)!:
            var cellId = messageFrame.message.from == MessageFrom(rawValue: 1) ? "outgoingImage" : "incomingImage"
            cellId = cellId.appending("")
            let CustomTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ImageTableViewCell
            CustomTableViewCell.messageFrame = messageFrame
            CustomTableViewCell.readCount = messageFrame.message.readmore_count ?? ""
            CustomTableViewCell.timeLabel.text = getTimeLabelText(messageFrame)
            self.getMessageLabelText(messageFrame, label: CustomTableViewCell.messageLabel, cell: CustomTableViewCell)
            CustomTableViewCell.bubleImage = (messageFrame.message.from == MessageFrom(rawValue: 1)) ? "inBubble" : "outBubble"
            CustomTableViewCell.cellMaxWidth.constant = imageCellWith
            let localValue = getLabelDeatil(CustomTableViewCell.messageLabel, maxWidth: imageCellWith-16)
            let maxHeight = messageFrame.message.payload.length == 0 ? imageMaxHeight : 160
            let calculatedValue = (height: localValue.height+maxHeight+8, lineCount: localValue.lineCount)
            CustomTableViewCell.readMoreBtn.isHidden = calculatedValue.lineCount > CustomTableViewCell.messageLabel.numberOfLines ? false : true
            CustomTableViewCell.statusImg?.image = self.setStatusIcon(messageFrame)
            self.imageSetter(messageFrame, in: CustomTableViewCell.chatImg, gifImageView: CustomTableViewCell.gifImg, cell: CustomTableViewCell)
            
            if(messageFrame.message.payload.length == 0)
            {
                CustomTableViewCell.imageHeightConstaraint.constant = calculatedValue.height - 10
                CustomTableViewCell.timeLabel.textColor = .white
                CustomTableViewCell.messageLabelBottom.constant = 8
                CustomTableViewCell.messageTop.constant = 0
            }
            else
            {
                CustomTableViewCell.imageHeightConstaraint.constant = 160
                CustomTableViewCell.timeLabel.textColor = UIColor.black.withAlphaComponent(0.24)
                CustomTableViewCell.messageLabelBottom.constant = 30
                CustomTableViewCell.messageTop.constant = 5
                
            }
            CustomTableViewCell.showVideoSize = false
            textCell = CustomTableViewCell
            break
        case MessageType(rawValue: 2)!:
            var cellId = messageFrame.message.from == MessageFrom(rawValue: 1) ? "outgoingImage" : "incomingImage"
            cellId = cellId.appending("")
            let CustomTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ImageTableViewCell
            CustomTableViewCell.messageFrame = messageFrame
            
            CustomTableViewCell.readCount = messageFrame.message.readmore_count ?? ""
            CustomTableViewCell.timeLabel.text = getTimeLabelText(messageFrame)
            self.getMessageLabelText(messageFrame, label: CustomTableViewCell.messageLabel, cell: CustomTableViewCell)
            CustomTableViewCell.cellMaxWidth.constant = imageCellWith
            let calculatedValue: (height: CGFloat, lineCount: Int)
            CustomTableViewCell.bubleImage = messageFrame.message.from == MessageFrom(rawValue: 1) ? "inBubble" : "outBubble"
            let localValue = getLabelDeatil(CustomTableViewCell.messageLabel, maxWidth: imageCellWith-10)
            calculatedValue = (height: localValue.height+168, lineCount: localValue.lineCount)
            CustomTableViewCell.statusImg?.image = self.setStatusIcon(messageFrame)
            self.thumbnailSetter(messageFrame, in: CustomTableViewCell.chatImg, cell: CustomTableViewCell)
            CustomTableViewCell.readMoreBtn.isHidden = calculatedValue.lineCount > CustomTableViewCell.messageLabel.numberOfLines ? false : true
            
            let download_status:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "download_status") as! String
            if download_status == "2"{
                CustomTableViewCell.showVideoSize = false
            }else{
                CustomTableViewCell.showVideoSize = true
                
                let upload_type = Themes.sharedInstance.CheckNullvalue(Passed_value: UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "upload_type"))
                let download_status = Themes.sharedInstance.CheckNullvalue(Passed_value: UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "download_status"))
                var autodownload = true
                if(upload_type == "2")
                {
                    autodownload = UploadHandler.Sharedinstance.GetAutoDownloadInfo(file_type: "videos", download_status: download_status)
                }
                if(autodownload)
                {
                    CustomTableViewCell.downloadIndicator?.setIndicatorStatus(.indeterminate)
                }
                else
                {
                    CustomTableViewCell.downloadIndicator?.setIndicatorStatus(.none)

                }

                if download_status == "1"{
                    CustomTableViewCell.downloadIndicator?.setIndicatorStatus(.indeterminate)
                }else{
                    CustomTableViewCell.downloadIndicator?.setIndicatorStatus(.none)
                }
                
            }
            
            
            if(messageFrame.message.payload.length == 0)
            {
                CustomTableViewCell.imageHeightConstaraint.constant = 210
                CustomTableViewCell.timeLabel.textColor = .white
                CustomTableViewCell.messageLabelBottom.constant = 8
                CustomTableViewCell.messageTop.constant = 0
            }
            else
            {
                CustomTableViewCell.imageHeightConstaraint.constant = 160
                CustomTableViewCell.timeLabel.textColor = UIColor.black.withAlphaComponent(0.24)
                CustomTableViewCell.messageLabelBottom.constant = 30
                CustomTableViewCell.messageTop.constant = 5
                
            }
            CustomTableViewCell.layoutSubviews()
            textCell = CustomTableViewCell
            break
        case MessageType(rawValue: 3)!:
            var cellId = messageFrame.message.from == MessageFrom(rawValue: 1) ? "outgoingAudio" : "incomingAudio"
            cellId = cellId.appending("")
            let CustomTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! AudioTableViewCell
            CustomTableViewCell.messageFrame = messageFrame
            CustomTableViewCell.timeLabel.text = getTimeLabelText(messageFrame)
            CustomTableViewCell.bubleImage = messageFrame.message.from == MessageFrom(rawValue: 1) ? "inBubble" : "outBubble"
            messageFrame.message.messageheight = 80
            CustomTableViewCell.cellMaxWidth.constant = imageCellWith
            CustomTableViewCell.statusImg?.image = self.setStatusIcon(messageFrame)
            CustomTableViewCell.customButton.setImage(nil, for: .normal)
            self.setAudioCell(messageFrame, cell: CustomTableViewCell)
            CustomTableViewCell.hideLoaderView(true)
            textCell = CustomTableViewCell
            break
        case MessageType(rawValue: 4)!:
            var cellId = messageFrame.message.from == MessageFrom(rawValue: 1) ? "outgoingUrl" : "incomingUrl"
            cellId = cellId.appending("")
            let CustomTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! URLTableViewCell
            CustomTableViewCell.messageFrame = messageFrame
            CustomTableViewCell.readCount = messageFrame.message.readmore_count ?? ""
            CustomTableViewCell.timeLabel.text = getTimeLabelText(messageFrame)
            self.getMessageLabelText(messageFrame, label: CustomTableViewCell.messageLabel, cell: CustomTableViewCell)
            CustomTableViewCell.bubleImage = messageFrame.message.from == MessageFrom(rawValue: 1) ? "inBubble" : "outBubble"
            CustomTableViewCell.cellMaxWidth.constant = normalCellWith
            let localValue = getLabelDeatil(CustomTableViewCell.messageLabel, maxWidth: normalCellWith*0.875)
            let calculatedValue = (height: localValue.height, lineCount: localValue.lineCount)
            CustomTableViewCell.messageLabelBottom.constant = calculatedValue.lineCount>1 ? 30 : 8
            CustomTableViewCell.readMoreBtn.isHidden = calculatedValue.lineCount > CustomTableViewCell.messageLabel.numberOfLines ? false : true
            CustomTableViewCell.statusImg?.image = self.setStatusIcon(messageFrame)
            
            CustomTableViewCell.customButton.setImage(nil, for: .normal)
            self.setUrlPreviewFrame(messageFrame, cell: CustomTableViewCell, calculatedValue: calculatedValue.height)
            CustomTableViewCell.hideLoaderView(true)
            textCell = CustomTableViewCell
            break
        case MessageType(rawValue: 5)!:
            var cellId = messageFrame.message.from == MessageFrom(rawValue: 1) ? "outgoingContact" : "incomingContact"
            cellId = cellId.appending("")
            let CustomTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ContactTableViewCell
            CustomTableViewCell.messageFrame = messageFrame
            CustomTableViewCell.timeLabel.text = getTimeLabelText(messageFrame)
            CustomTableViewCell.bubleImage = messageFrame.message.from == MessageFrom(rawValue: 1) ? "inBubble" : "outBubble"
            contactImgSetter(messageFrame, cell: CustomTableViewCell)
            CustomTableViewCell.statusIcon?.image = self.setStatusIcon(messageFrame)
            CustomTableViewCell.contactName.text = messageFrame.message.contact_name
            contactButtonSetter(messageFrame, cell: CustomTableViewCell)
            CustomTableViewCell.hideLoaderView(true)
            textCell = CustomTableViewCell
            break
            
        case MessageType(rawValue: 6)!:
            var cellId = messageFrame.message.from == MessageFrom(rawValue: 1) ? "outgoingFile" : "incomingFile"
            cellId = cellId.appending("")
            let CustomTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! DocTableViewCell
            CustomTableViewCell.cellMaxWidth.constant = normalCellWith
            CustomTableViewCell.messageFrame = messageFrame
            if(messageFrame.message.docType == "1")
            {
                CustomTableViewCell.fileImg.isHidden = false
                CustomTableViewCell.imgHeightConstraint.constant = 180;
            }
            else
            {
                CustomTableViewCell.fileImg.isHidden = true
                CustomTableViewCell.imgHeightConstraint.constant = 37.5;
            }
            CustomTableViewCell.timeLabel.text = getTimeLabelText(messageFrame)
            CustomTableViewCell.bubleImage = messageFrame.message.from == MessageFrom(rawValue: 1) ? "inBubble" : "outBubble"
            CustomTableViewCell.statusImg?.image = self.setStatusIcon(messageFrame)
            CustomTableViewCell.customButton.setImage(nil, for: .normal)

            let download_status:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "download_status") as! String

            if(messageFrame.message.from == MessageFrom(rawValue: 0))
            {
                if download_status == "0"{
                    let autodownload  = UploadHandler.Sharedinstance.GetAutoDownloadInfo(file_type: "documents", download_status: download_status)
                    if autodownload{
                        CustomTableViewCell.customButton.isHidden = false
                    }
                    else
                    {
                        CustomTableViewCell.customButton.isHidden = true
                    }
                }
                else
                {
                    CustomTableViewCell.customButton.isHidden = false
                }
            }
            else
            {
                CustomTableViewCell.customButton.isHidden = false
            }
            
            self.SetDocumentDetail(messageFrame, cell: CustomTableViewCell)
            CustomTableViewCell.hideLoaderView(true)
            textCell = CustomTableViewCell
            break
        case MessageType(rawValue: 7)!:
            var cellId = messageFrame.message.from == MessageFrom(rawValue: 1) ? "outgoingReplay" : "incomingReplay"
            cellId = cellId.appending("")
            let CustomTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ReplayTableViewCell
            CustomTableViewCell.messageFrame = messageFrame
            CustomTableViewCell.readCount = messageFrame.message.readmore_count ?? ""
            CustomTableViewCell.timeLabel.text = getTimeLabelText(messageFrame)
            self.getMessageLabelText(messageFrame, label: CustomTableViewCell.messageLabel, cell: CustomTableViewCell)
            CustomTableViewCell.bubleImage = messageFrame.message.from == MessageFrom(rawValue: 1) ? "inBubble" : "outBubble"
            CustomTableViewCell.cellMaxWidth.constant = normalCellWith
            var calculatedValue: (height: CGFloat, lineCount: Int)
            let localValue = getLabelDeatil(CustomTableViewCell.messageLabel, maxWidth: normalCellWith*0.875)
            calculatedValue = (height: localValue.height+65, lineCount: localValue.lineCount)
            CustomTableViewCell.readMoreBtn.isHidden = calculatedValue.lineCount > CustomTableViewCell.messageLabel.numberOfLines ? false : true
            if calculatedValue.lineCount > 1 || CustomTableViewCell.messageLabel.font == emojiFont{
                CustomTableViewCell.timeLabelLeadingConstraint.constant = -(CustomTableViewCell.timeLabel.frame.width+10)
                CustomTableViewCell.messageLabelBottom.constant = 30
            }
            else{
                CustomTableViewCell.timeLabelLeadingConstraint.constant = 5
                CustomTableViewCell.messageLabelBottom.constant = 8
            }
            CustomTableViewCell.timeLabelLeadingConstraint.constant = calculatedValue.lineCount > 1 ? -(CustomTableViewCell.timeLabel.frame.width+10) : 3
            messageFrame.message.messageheight = calculatedValue.height
            CustomTableViewCell.statusImg?.image = self.setStatusIcon(messageFrame)
            replayViewSetter(messageFrame, cell: CustomTableViewCell)
            
            CustomTableViewCell.customButton.setImage(nil, for: .normal)
            CustomTableViewCell.hideLoaderView(true)
            textCell = CustomTableViewCell
            break
        case MessageType(rawValue: 14)!:
            var cellId = messageFrame.message.from == MessageFrom(rawValue: 1) ? "outgoingImage" : "incomingImage"
            cellId = cellId.appending("")
            let CustomTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ImageTableViewCell
            CustomTableViewCell.messageFrame = messageFrame
            CustomTableViewCell.readCount = messageFrame.message.readmore_count ?? ""
            CustomTableViewCell.timeLabel.text = getTimeLabelText(messageFrame)
            self.getMessageLabelText(messageFrame, label: CustomTableViewCell.messageLabel, cell: CustomTableViewCell)
            CustomTableViewCell.bubleImage = messageFrame.message.from == MessageFrom(rawValue: 1) ? "inBubble" : "outBubble"
            CustomTableViewCell.cellMaxWidth.constant = imageCellWith
            var calculatedValue: (height: CGFloat, lineCount: Int)
            let localValue = getLabelDeatil(CustomTableViewCell.messageLabel, maxWidth: imageCellWith-16)
            calculatedValue = (height: localValue.height+168, lineCount: localValue.lineCount)
            messageFrame.message.messageheight = calculatedValue.height
            CustomTableViewCell.statusImg?.image = self.setStatusIcon(messageFrame)
            CustomTableViewCell.gifImg.isHidden = true
            CustomTableViewCell.chatImg.isHidden = false
            CustomTableViewCell.chatImg.sd_setImage(with: URL(string:messageFrame.message.imagelink), placeholderImage: #imageLiteral(resourceName: "placeholder"), options: .refreshCached)
            if(messageFrame.message.payload.length == 0)
            {
                CustomTableViewCell.imageHeightConstaraint.constant = 210
                CustomTableViewCell.timeLabel.textColor = .white
            }
            else
            {
                CustomTableViewCell.imageHeightConstaraint.constant = 160
                CustomTableViewCell.timeLabel.textColor = UIColor.black.withAlphaComponent(0.24)
                
            }
            if calculatedValue.lineCount > 1{
                CustomTableViewCell.messageLabelBottom.constant = 30
            }
            else{
                CustomTableViewCell.messageLabelBottom.constant = 8
            }
            CustomTableViewCell.readMoreBtn.isHidden = calculatedValue.lineCount > CustomTableViewCell.messageLabel.numberOfLines ? false : true
            CustomTableViewCell.customButton.setImage(nil, for: .normal)
            
            CustomTableViewCell.readMoreBtn.isHidden = calculatedValue.lineCount > CustomTableViewCell.messageLabel.numberOfLines ? false : true
            CustomTableViewCell.hideLoaderView(true)
            CustomTableViewCell.showVideoSize = false
            textCell = CustomTableViewCell
            break
        default:
            break
        }
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        textCell.selectedBackgroundView = backgroundView
        textCell.group = messageFrame.message.chat_type == "group" ? true : false
        if(textCell.group && Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message.contactmsisdn) != "") {
            textCell.senderNameLabel?.setNameTxt(Themes.sharedInstance.CheckNullvalue(Passed_value: messageFrame.message.user_from), "single")
        }

        _ = textCell.contentView.subviews.map {
            if($0.tag == 100)
            {
                $0.removeFromSuperview()
            }
        }
        textCell.addLeftReplyView()
        return textCell
    }
    
}



