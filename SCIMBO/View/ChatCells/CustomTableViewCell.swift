//
//  CustomTableViewCell.swift
//
//  Created by raguraman on 04/07/18.
//  Copyright © 2018 CASPERON. All rights reserved.
//

import UIKit

protocol CustomTableViewCellDelegate : class {
    func DidClickMenuAction(actioname:MenuAcion,index:IndexPath)
    func contactBtnTapped(sender:UIButton)
    func saveTarget(sender:UIButton)
    
    func playPauseTapped(sender:UIButton)
    func sliderChanged(_ slider:UISlider, event:UIControl.Event)
    func readMorePressed(sender:UIButton, count:String)
    func forwordPressed(_ sender:UIButton)
    func PasPersonDetail(id:String)
}

class CustomTableViewCell:UITableViewCell{
    
    //MARK:- public properties
    public var messageFrame = UUMessageFrame()
    public var customButton = UIButton()
    public var replyImg = UIImageView()
    public weak var delegate:CustomTableViewCellDelegate?
    public var calculatedValue: (height: CGFloat, lineCount: Int)?
    public var songData:Data?
    public var bubleImage = String()
    public var readCount = String()
    public var showVideoSize = false
    public var TagRangeArr : [NSRange] = [NSRange]()
    public var TagIdArr : [String] = [String]()
    
    //MARK:- computed properties
    public var group = Bool(){
        didSet{
            if group{
                senderNameLabel?.isHidden = messageFrame.message.from == MessageFrom(rawValue: 0) ? false : true
                senderNameLabelHeight?.constant = messageFrame.message.from == MessageFrom(rawValue: 0) ? 25 : 0
            }else{
                senderNameLabel?.isHidden = true
                senderNameLabelHeight?.constant = 0
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    public var RowIndex = IndexPath(){
        didSet{
            customButton.tag = RowIndex.row
            loaderView?.loadingButton.tag = RowIndex.row
        }
    }
    
    //MARK:- private properties
    private var loaderView:LoaderView?
    
    //This are the outlet from sub classes
    @IBOutlet weak var senderNameLabel: UILabel?
    @IBOutlet weak var senderNameLabelHeight: NSLayoutConstraint?
    
    //MARK:- system function
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    //MARK:- custom function
    func addButton(to sender:UIView){
        sender.addSubview(customButton)
        customButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: customButton, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: sender, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: customButton, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: sender, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: customButton, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: sender, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: customButton, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: sender, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1, constant: 0).isActive = true
        sender.bringSubviewToFront(customButton)
    }
    
    func addLeftReplyView() {
        self.contentView.clipsToBounds = false
        replyImg.frame = CGRect(x: -45, y: self.contentView.center.y - 15, width: 30, height: 30)
        replyImg.image = #imageLiteral(resourceName: "replyIcon")
        replyImg.contentMode = .scaleAspectFit
        replyImg.alpha = 0.0
        replyImg.tag = 100
        self.contentView.addSubview(replyImg)
        self.contentView.bringSubviewToFront(replyImg)
    }
    
    //MARK:- Loader function
    func addLoader(to sender:UIView){
        loaderView = UINib(nibName: "LoaderView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as? LoaderView
        sender.addSubview(loaderView!)
        loaderView?.frame = sender.bounds
        loaderView?.isHidden = true
        loaderView?.loadingButton.addTarget(self, action: #selector(loadingButtonPressed(_:)), for: .touchUpInside)
        sender.bringSubviewToFront(loaderView!)
        loaderView?.downloadIndicator.setActionForTap { (sender, state) in
            self.downloadButtonPressed(sender, status: state)
        }
    }
    
    public func downloadButtonPressed(_ sender:ACPDownloadView?, status:ACPDownloadStatus){
        switch status{
        case .none:
            sender?.setIndicatorStatus(.indeterminate)
            DownloadHandler.sharedinstance.handleDownLoad(true)

            break
        default:
            
            break
        }
    }
    
    @objc func loadingButtonPressed(_ sender:UIButton){
        loaderView?.isHidden(value: true)
        if(messageFrame.message.from == MessageFrom(rawValue: 1))
        {
            if(messageFrame.message.type == MessageType(rawValue: 2))
            {
                customButton.setImage(#imageLiteral(resourceName: "playIcon"), for: .normal)
            }
            if(messageFrame.message.type == MessageType(rawValue: 1))
            {
                let download_status:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "download_status") as! String
                
                if(download_status == "2"){
                    
                    let PhotoPath:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "upload_Path") as! String
                    
                    if FileManager.default.fileExists(atPath: PhotoPath) {
                        let url = URL(fileURLWithPath: PhotoPath)
                        if(url.pathExtension.lowercased() == "gif")
                        {
                            customButton.setImage(#imageLiteral(resourceName: "gifIcon"), for: .normal)
                        }
                    }
                }
            }
            let status =  "1"
            UploadHandler.Sharedinstance.updateUploadControler(pathid: messageFrame.message.thumbnail!, status: status)
        }
    }
    
    func retriveLoading(){
        loaderView?.isHidden(value: false)
        self.hideLoaderView(false, isUpload: true)
        let status =  "0"
        UploadHandler.Sharedinstance.updateUploadControler(pathid: messageFrame.message.thumbnail!, status: status)
    }
    
    //show and hide loader in a view
    func hideLoaderView(_ value:Bool, isUpload:Bool = true, downloadViewState:ACPDownloadStatus = .none){
        
        loaderView?.isHidden = value
        loaderView?.downloadIndicator.setIndicatorStatus(downloadViewState)
        if !value{
            if(messageFrame.message.from == MessageFrom(rawValue: 0))
            {
                loaderView?.loadingButton.isUserInteractionEnabled = false
                let upload_byte_count:String! = Themes.sharedInstance.CheckNullvalue(Passed_value: UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "upload_byte_count"))
                
                let total_byte_count:String! = Themes.sharedInstance.CheckNullvalue(Passed_value: UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "total_byte_count"))

                if(upload_byte_count != "0")
                {
                    loaderView?.setupProgress(isInitial: false)
                    SetLoader_data(messageFrame, total_byte_count, upload_byte_count)
                }
                else
                {
                    loaderView?.setupProgress(isInitial: true)
                    loaderView?.isUpload = isUpload
                }
                loaderView?.loadingButton.isHidden = false
                loaderView?.loadingButton.setImage(#imageLiteral(resourceName: "emptyIcon"), for: .normal)
                
                let upload_type = Themes.sharedInstance.CheckNullvalue(Passed_value: UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "upload_type"))
                let download_status = Themes.sharedInstance.CheckNullvalue(Passed_value: UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "download_status"))
                var autodownload = true
                if(upload_type == "1")
                {
                    autodownload = UploadHandler.Sharedinstance.GetAutoDownloadInfo(file_type: "photos", download_status: download_status)
                }
                if(autodownload)
                {
                    loaderView?.downloadIndicator.setIndicatorStatus(.indeterminate)
                }
                else
                {
                    loaderView?.downloadIndicator.setIndicatorStatus(.none)
                }
            }
            else
            {
                let upload_count:String! = Themes.sharedInstance.CheckNullvalue(Passed_value: UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "upload_count"))
                
                let upload_byte_count:String! = Themes.sharedInstance.CheckNullvalue(Passed_value: UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "upload_byte_count"))

                let total_byte_count:String! = Themes.sharedInstance.CheckNullvalue(Passed_value: UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "total_byte_count"))

                if(upload_count != "1")
                {
                    loaderView?.setupProgress(isInitial: false)
                    SetLoader_data(messageFrame, total_byte_count, upload_byte_count)
                }
                else
                {
                    loaderView?.setupProgress(isInitial: true)
                    loaderView?.isUpload = isUpload
                }
                loaderView?.loadingButton.isHidden = !isUpload
                loaderView?.loadingButton.setImage(#imageLiteral(resourceName: "stopIcon"), for: .normal)
                loaderView?.downloadIndicator.setIndicatorStatus(.indeterminate)
            }
        }
        else
        {
            loaderView?.isUpload = isUpload
        }
    }
    
    
    func removeLoader(){
        loaderView?.removeFromSuperview()
    }
    
    func SetLoader_data(_ messageFrame: UUMessageFrame!, _ total_byte_count : String, _ upload_byte_count : String)
    {
        loaderView?.progressView.isHidden = false
        loaderView?.downloadIndicator.isHidden = true
        
        if(upload_byte_count != "" && total_byte_count != "")
        {
            if(total_byte_count == upload_byte_count)
            {
                messageFrame.message.messageid = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_one_one, attrib_name: "doc_id", fetchString: messageFrame.message.doc_id, returnStr: "id")
                
            }
            
            let precentage:CGFloat = CGFloat(((100.0*Double(upload_byte_count)!)/Double(total_byte_count)!)/100.0);
            
            if messageFrame.message.from == MessageFrom(rawValue: 0)! {
                self.loaderView?.setPercentage(precentage)
            }
                
            else
                
            {
                self.loaderView?.setPercentage(precentage)
            }
        }
        
    }
    
    
    @objc func tapTextview(tap: UITapGestureRecognizer) {
        
        var isPerson = false
        var index = 0
        let label = tap.view as! UILabel
        
        let myTextView = UITextView(frame: label.frame)
        myTextView.font = label.font
        myTextView.attributedText = label.attributedText
        
        let layoutManager = myTextView.layoutManager
        
        var location = tap.location(in: label)
        location.x -= myTextView.textContainerInset.left;
        location.y -= myTextView.textContainerInset.top;
        
        let characterIndex = layoutManager.characterIndex(for: location, in: myTextView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        if characterIndex < myTextView.textStorage.length {
            
            print("Your character is at index: \(characterIndex)")
            
            let myRange = NSRange(location: characterIndex, length: 1)
            _ = TagRangeArr.map{
                let range = $0
                if(range.contains(myRange.location))
                {
                    print(TagIdArr[index])
                    isPerson = true
                    index = TagRangeArr.index(of: range)!
                }
            }
            
            _ = getLinkRangeArray(myTextView.attributedText.string).map {
                let range = $0["range"] as! NSRange
                let type = $0["type"] as! String
                let data = $0["data"] as! String
                if(range.contains(myRange.location)) {
                    if type == "link" {
                        UIApplication.shared.open(URL(string: data)!, options: [:], completionHandler: nil)
                    }
                    else
                    {
                        UIApplication.shared.open(URL(string: "tel://" + data)!, options: [:], completionHandler: nil)
                    }
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
    
    func getLinkRangeArray(_ payload : String) -> [[String : Any]]
    {
        var types: NSTextCheckingResult.CheckingType = .link
        var detector = try? NSDataDetector(types: types.rawValue)
        let matches = detector?.matches(in: payload, options: .reportCompletion, range: NSMakeRange(0, payload.count))
        
        types = .phoneNumber
        detector = try? NSDataDetector(types: types.rawValue)
        let matches1 = detector?.matches(in: payload, options: .reportCompletion, range: NSMakeRange(0, payload.count))
        var RangeArr = [[String : Any]]()
        
        for match in matches! {
            let foundRange: NSRange = match.range
            if foundRange.location != NSNotFound {
                RangeArr.append(["data" : match.url?.absoluteString ?? "", "type" : "link", "range" : foundRange])
            }
        }
        
        for match in matches1! {
            let foundRange: NSRange = match.range
            if foundRange.location != NSNotFound {
                RangeArr.append(["data" : match.phoneNumber ?? "", "type" : "phone", "range" : foundRange])
            }
        }
        return RangeArr
    }
    
    //MARK:- popover menu actions
    
    @objc func deleteMessageActionTapped(sender: UIMenuController) {
        self.delegate?.DidClickMenuAction(actioname: .delete, index: RowIndex)
    }
    @objc func CopyMessageActionTapped(sender: UIMenuController) {
        self.delegate?.DidClickMenuAction(actioname: .copy, index: RowIndex)
    }
    @objc func ForwardActionTapped(sender: UIMenuController) {
        self.delegate?.DidClickMenuAction(actioname: .Forward, index: RowIndex)
    }
    @objc func ReplyActionTapped(sender: UIMenuController) {
        self.delegate?.DidClickMenuAction(actioname: .Reply, index: RowIndex)
    }
    @objc func InfoActionTapped(sender: UIMenuController) {
        self.delegate?.DidClickMenuAction(actioname: .Info, index: RowIndex)
    }
    @objc func StarActionTapped(sender: UIMenuController) {
        self.delegate?.DidClickMenuAction(actioname: .star, index: RowIndex)
    }
}
