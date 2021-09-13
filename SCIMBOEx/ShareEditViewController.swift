//
//  ShareEditViewController.swift
//
//
//  Created by Casp iOS on 06/04/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit
import MobileCoreServices
import ICGVideoTrimmer

@objc protocol ShareEditViewControllerDelegate : class {
    @objc optional func EdittedImage(AssetArr:[MultimediaRecord],Status:String)
}

class ShareEditViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,ICGVideoTrimmerDelegate,UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mediaCollectionView: UICollectionView!
    @IBOutlet weak var mediaCollectionView_main: UICollectionView!
    @IBOutlet weak var done_Btn: UIButton!
    @IBOutlet weak var close_Btn: UIButton!
    @IBOutlet weak var txt_caption: UITextField!
    @IBOutlet weak var txt_caption_view: UIView!
    @IBOutlet weak var txt_caption_bottom: NSLayoutConstraint!
    @IBOutlet weak var btn_send_bottom: NSLayoutConstraint!
    var GlobalIndex:Int = Int()
    weak var Delegate:ShareEditViewControllerDelegate?
    var isVideoData:Bool = Bool()
    var exportSession: AVAssetExportSession!
    var AssetArr = [MultimediaRecord]()
    var showAssetArr = [MultimediaRecord]()
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        txt_caption.delegate = self
        txt_caption_view.layer.borderWidth = 1;
        txt_caption_view.layer.borderColor = UIColor.lightGray.cgColor
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        settext()
    }
    
    func settext()
    {
        done_Btn.setTitle("Done", for: .normal)
        txt_caption.placeholder = "Add a caption..."
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mediaCollectionView_main.isPagingEnabled = true
        let Nib = UINib(nibName: "ShareMediaCollectionViewCell", bundle: nil)
        mediaCollectionView.register(Nib, forCellWithReuseIdentifier: "ShareMediaCollectionViewCellID")
        GlobalIndex = 0
        self.mediaCollectionView.dataSource = self
        self.mediaCollectionView.delegate = self
        
        self.mediaCollectionView.reloadData()
        UIView.animate(withDuration: 0.2) {
            
            let height : CGFloat = self.showAssetArr.count == 1 ? -55 : 8
            
            self.txt_caption_bottom.constant = height
            self.btn_send_bottom.constant = height
            
            self.mediaCollectionView.isHidden = self.showAssetArr.count == 1
        }
    }
    
    @objc func keyboardWillShow(notification: Notification){
        adjustKeyboardShow(true, notification: notification)
    }
    
    @objc func keyboardWillDisappear(notification: Notification){
        adjustKeyboardShow(false, notification: notification)
    }
    
    func adjustKeyboardShow(_ open: Bool, notification: Notification) {
        let userInfo = notification.userInfo ?? [:]
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        var height = (keyboardFrame.height - mediaCollectionView.bounds.height)
        let Dheight : CGFloat = self.showAssetArr.count == 1 ? -55 : 8
        
        height = open ? height : Dheight
        UIView.animate(withDuration: 0.3) {
            self.txt_caption_bottom.constant = height
            self.btn_send_bottom.constant = height
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text : String = (textField.text?.appending(string))!
        
        let ObjMultimedia = showAssetArr[GlobalIndex]
        ObjMultimedia.caption = text
        
        _ = AssetArr.map {
            if $0.assetpathname == ObjMultimedia.assetpathname {
                $0.caption = ObjMultimedia.caption
            }
        }
        
        return true
    }
    
    
    deinit {
        exportSession = nil
    }
    
    func ExportAssetMessage(i:Int)
    {
        FileManager.default.clearTmpDirectory()
        
        if(AssetArr.count > 0)
        {
            var timestamp:String =  String(Date().ticks)
            var servertimeStr:String = Themes.sharedInstance.getServerTime()
            
            if(servertimeStr == "")
            {
                servertimeStr = "0"
            }
            let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
            timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
            let Temppath:String = NSTemporaryDirectory().appending("\(timestamp).mp4")
            let ObjMultiMedia = AssetArr[i]
            if(ObjMultiMedia.isVideo)
            {
                let videoURL = NSURL(string: ObjMultiMedia.assetpathname)
                let AVasset:AVAsset =  AVURLAsset(url: videoURL! as URL)
                let compatiblePresets:NSArray = AVAssetExportSession.exportPresets(compatibleWith: AVasset) as NSArray
                if(compatiblePresets.contains(AVAssetExportPresetMediumQuality))
                {
                    exportSession = AVAssetExportSession(asset: AVasset, presetName: AVAssetExportPresetMediumQuality)
                    let TempURl = NSURL(fileURLWithPath: Temppath)
                    exportSession.outputURL = TempURl as URL?
                    exportSession.outputFileType = AVFileType.mp4
                    
                    let duration = Double(ObjMultiMedia.Endtime) - Double(ObjMultiMedia.StartTime)
                    let startTime = CMTime(seconds: Double(ObjMultiMedia.StartTime), preferredTimescale: 1000)
                    let endTime = CMTime(seconds: Double(duration), preferredTimescale: 1000)
                    let range:CMTimeRange = CMTimeRange(start: startTime, duration: endTime)
                    
                    exportSession.timeRange = range
                    self.exportSession?.exportAsynchronously(completionHandler: {
                        
                        switch self.exportSession!.status
                            
                        {
                        case  .failed:
                            break;
                        case .cancelled:
                            
                            break;
                        default:
                            
                            DispatchQueue.main.async {
                                
                                do
                                {
                                    
                                    
                                    let data = try Data(contentsOf: (self.exportSession?.outputURL)!, options: .mappedIfSafe)
                                    ObjMultiMedia.rawData = data
                                }
                                catch{
                                    print(error.localizedDescription)
                                }
                                var timestamp:String =  String(Date().ticks)
                                var servertimeStr:String = Themes.sharedInstance.getServerTime()
                                if(servertimeStr == "")
                                {
                                    servertimeStr = "0"
                                }
                                let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
                                timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
                                let Path:String =  Filemanager.sharedinstance.SaveImageFile( imagePath: "\(Constant.sharedinstance.videopathpath)/\(ObjMultiMedia.assetname)",imagedata: ObjMultiMedia.rawData)
                                var splitcount:Int = ObjMultiMedia.rawData.count / Constant.sharedinstance.SendbyteCount
                                if(splitcount < 1)
                                {
                                    splitcount = 1
                                }
                                
                                // replace with data.count
                                
                                ObjMultiMedia.PathId = ObjMultiMedia.assetname
                                ObjMultiMedia.assetpathname = Path
                                
                                let uploadDataCount:String = self.getArrayOfBytesFromImage(ObjMultiMedia.rawData,splitCount: splitcount)
                                let imagecount:Int = ObjMultiMedia.rawData.count
                                let Dict:[String:Any] = ["failure_status":"0","total_byte_count":"\(imagecount)","upload_byte_count":"0","upload_count":"1","upload_data_id":ObjMultiMedia.PathId,"upload_Path":"\(ObjMultiMedia.assetpathname!)","upload_status":"0","user_common_id":"\(ObjMultiMedia.userCommonID)","serverpath":"","user_id":Themes.sharedInstance.Getuser_id(),"data_count":uploadDataCount,"compressed_data":ObjMultiMedia.Base64Str,"to_id":"\(ObjMultiMedia.toID)","message_status":"0","timestamp":timestamp,"total_data_count":"\(splitcount)","width":"\(ObjMultiMedia.Thumbnail.size.width)","height":"\(ObjMultiMedia.Thumbnail.size.height)","upload_type":"2","video_thumbnail":ObjMultiMedia.VideoThumbnail,"download_status":"2","is_uploaded":"1", "upload_paused":"0"]
                                
                                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict as NSDictionary, Entityname: Constant.sharedinstance.Upload_Details);
                                self.AssetArr[i] = ObjMultiMedia
                                
                                if(i+1 <= self.AssetArr.count-1)
                                {
                                    Themes.sharedInstance.setprogressinAlert(controller: self, progress: Float(i) / Float(self.AssetArr.count-1), completionHandler: nil)
                                    let ObjMulrec = self.AssetArr[i+1]
                                    if(ObjMulrec.isVideo)
                                    {
                                        self.ExportAssetMessage(i: i+1)
                                    }
                                    else
                                    {
                                        self.doMessageImageAction(i: i+1)
                                    }
                                }
                                else
                                {
                                    Themes.sharedInstance.setprogressinAlert(controller: self, progress: 1.0) {
                                        self.Delegate?.EdittedImage!( AssetArr: self.AssetArr,Status:"CHECK")
                                        self.navigationController?.pop(animated: true)
                                        
                                    }
                                }
                                
                            }
                            break;
                        }
                        
                        
                        
                    })
                    
                }
                
            }
            
        }
        
        
    }
    
    func ExportAssetStatus(i : Int)
    {
        FileManager.default.clearTmpDirectory()
        
        if(AssetArr.count > 0)
        {
            var timestamp:String =  String(Date().ticks)
            var servertimeStr:String = Themes.sharedInstance.getServerTime()
            
            if(servertimeStr == "")
            {
                servertimeStr = "0"
            }
            let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
            timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
            let Temppath:String = NSTemporaryDirectory().appending("\(timestamp).mp4")
            let ObjMultiMedia = AssetArr[i]
            if(ObjMultiMedia.isVideo)
            {
                let videoURL = NSURL(string: ObjMultiMedia.assetpathname)
                let AVasset:AVAsset =  AVURLAsset(url: videoURL! as URL)
                let compatiblePresets:NSArray = AVAssetExportSession.exportPresets(compatibleWith: AVasset) as NSArray
                if(compatiblePresets.contains(AVAssetExportPresetMediumQuality))
                {
                    exportSession = AVAssetExportSession(asset: AVasset, presetName: AVAssetExportPresetMediumQuality)
                    let TempURl = NSURL(fileURLWithPath: Temppath)
                    exportSession.outputURL = TempURl as URL?
                    exportSession.outputFileType = AVFileType.mp4
                    
                    let duration = Double(ObjMultiMedia.Endtime) - Double(ObjMultiMedia.StartTime)
                    let startTime = CMTime(seconds: Double(ObjMultiMedia.StartTime), preferredTimescale: 1000)
                    let endTime = CMTime(seconds: Double(duration), preferredTimescale: 1000)
                    let range:CMTimeRange = CMTimeRange(start: startTime, duration: endTime)
                    
                    exportSession.timeRange = range
                    self.exportSession?.exportAsynchronously(completionHandler: {
                        
                        switch self.exportSession!.status
                            
                        {
                        case  .failed:
                            break;
                        case .cancelled:
                            
                            break;
                        default:
                            
                            DispatchQueue.main.async {
                                
                                do
                                {
                                    
                                    
                                    let data = try Data(contentsOf: (self.exportSession?.outputURL)!, options: .mappedIfSafe)
                                    ObjMultiMedia.rawData = data
                                }
                                catch{
                                    print(error.localizedDescription)
                                }
                                var timestamp:String =  String(Date().ticks)
                                var servertimeStr:String = Themes.sharedInstance.getServerTime()
                                if(servertimeStr == "")
                                {
                                    servertimeStr = "0"
                                }
                                let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
                                timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
                                let Path:String =  Filemanager.sharedinstance.SaveImageFile( imagePath: "\(Constant.sharedinstance.statuspath)/\(ObjMultiMedia.assetname)",imagedata: ObjMultiMedia.rawData)
                                var splitcount:Int = ObjMultiMedia.rawData.count / Constant.sharedinstance.SendbyteCount
                                if(splitcount < 1)
                                {
                                    splitcount = 1
                                }
                                
                                // replace with data.count
                                
                                ObjMultiMedia.PathId = ObjMultiMedia.assetname
                                ObjMultiMedia.assetpathname = Path
                                
                                let uploadDataCount:String = self.getArrayOfBytesFromImage(ObjMultiMedia.rawData,splitCount: splitcount)
                                let imagecount:Int = ObjMultiMedia.rawData.count
                                let Dict:[String:Any] = ["failure_status":"0","total_byte_count":"\(imagecount)","upload_byte_count":"0","upload_count":"1","upload_data_id":ObjMultiMedia.PathId,"upload_Path":"\(ObjMultiMedia.assetpathname!)","upload_status":"0","user_common_id":"\(ObjMultiMedia.userCommonID)","serverpath":"","user_id":Themes.sharedInstance.Getuser_id(),"data_count":uploadDataCount,"compressed_data":ObjMultiMedia.Base64Str,"to_id":"\(ObjMultiMedia.toID)","message_status":"0","timestamp":timestamp,"total_data_count":"\(splitcount)","width":"\(ObjMultiMedia.Thumbnail.size.width)","height":"\(ObjMultiMedia.Thumbnail.size.height)","upload_type":"2","video_thumbnail":ObjMultiMedia.VideoThumbnail,"download_status":"2","is_uploaded":"1", "upload_paused":"0"]
                                
                                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict as NSDictionary, Entityname: Constant.sharedinstance.Status_Upload_Details);
                                self.AssetArr[i] = ObjMultiMedia
                                self.exportSession = nil
                                
                                if(i+1 <= self.AssetArr.count-1)
                                {
                                    Themes.sharedInstance.setprogressinAlert(controller: self, progress: Float(i) / Float(self.AssetArr.count-1), completionHandler: nil)
                                    let ObjMulrec = self.AssetArr[i+1]
                                    if(ObjMulrec.isVideo)
                                    {
                                        self.ExportAssetStatus(i : i+1)
                                    }
                                    else
                                    {
                                        self.doStatusImageAction(i: i+1)
                                    }
                                }
                                else
                                {
                                    Themes.sharedInstance.setprogressinAlert(controller: self, progress: 1.0) {
                                        self.Delegate?.EdittedImage!( AssetArr: self.AssetArr,Status:"CHECK")
                                        self.navigationController?.pop(animated: true)
                                    }
                                }
                                
                            }
                            break;
                        }
                    })
                }
            }
            
        }
        
        
    }
    
    open override var shouldAutorotate : Bool {
        return false
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask
    {
        return .portrait
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if(collectionView == mediaCollectionView)
        {
            GlobalIndex = indexPath.row
            mediaCollectionView_main.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
            mediaCollectionView.reloadData()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.mediaCollectionView_main {
            let currentIndex: Int = Int(mediaCollectionView_main.contentOffset.x) / Int(mediaCollectionView_main.frame.size.width)
            GlobalIndex = Int(currentIndex)
            mediaCollectionView.reloadData()
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return showAssetArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        txt_caption.resignFirstResponder()
        let ObjTemp = showAssetArr[GlobalIndex]
        txt_caption.text = ObjTemp.caption
        if(collectionView == mediaCollectionView)
        {
            let Cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShareMediaCollectionViewCellID", for: indexPath) as! ShareMediaCollectionViewCell
            
            let ObjMultiMedia = showAssetArr[indexPath.row]
            if(ObjMultiMedia.isVideo)
            {
                Cell.MediaImageView.image = ObjMultiMedia.Thumbnail
                Cell.play_img.isHidden = false
            }
            else
            {
                Cell.MediaImageView.image = ObjMultiMedia.Thumbnail
                Cell.play_img.isHidden = true
            }
            
            if(indexPath.row == GlobalIndex)
            {
                
                Cell.layer.borderWidth = 1.0;
                Cell.layer.borderColor =  CustomColor.sharedInstance.themeColor.cgColor
            }
            else
            {
                Cell.layer.borderWidth = 0.0;
                Cell.layer.borderColor =  UIColor.clear.cgColor
                
            }
            Cell.backgroundColor = UIColor.clear
            Cell.backgroundView?.backgroundColor = UIColor.clear
            
            return  Cell
            
        }
        else
        {
            
            let cell: ShareVideoTrimCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShareVideoTrimCellID", for: indexPath) as! ShareVideoTrimCell
            
            cell.ObjMultimedia = showAssetArr[indexPath.row]
            cell.isVideoData = cell.ObjMultimedia.isVideo
            cell.fromStatus = false
            cell.delegate = self
            DispatchQueue.main.async {
                cell.UpdateUI()
            }
            
            cell.TrimmerView.frame = CGRect(x: 10, y: 0, width: self.mediaCollectionView_main.frame.size.width - 20, height: cell.TrimmerView.frame.size.height)
            
            return  cell
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(collectionView == mediaCollectionView_main)
        {
            let ObjTemp = showAssetArr[indexPath.item]
            if(ObjTemp.isVideo)
            {
                return CGSize(width: mediaCollectionView_main.frame.size.width, height: mediaCollectionView_main.frame.size.height - 80)
            }
            else
            {
                return CGSize(width: mediaCollectionView_main.frame.size.width, height: mediaCollectionView_main.frame.size.height)
            }
        }
        else
        {
            return CGSize(width:50, height:50)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func DidclickDone(_ sender: Any) {
        self.Delegate?.EdittedImage!( AssetArr: AssetArr,Status:"CHECK")
        self.navigationController?.pop(animated: true)
    }
    @IBAction func DidclickClose(_ sender: Any) {
        self.navigationController?.pop(animated: true)
        
    }
    @IBAction func DidclickPlay_Btn(_ sender: Any) {
        
    }
    @IBAction func DidclickSendBtn(_ sender: Any) {
        
        
        (sender as! UIButton).isUserInteractionEnabled = false
        
        Themes.sharedInstance.showprogressAlert(controller: self)
        
        for i in 0..<self.mediaCollectionView_main.numberOfItems(inSection: 0) {
            let cell = self.mediaCollectionView_main.cellForItem(at: IndexPath(item: i, section: 0))
            if(cell != nil)
            {
                if((cell as! ShareVideoTrimCell).isVideoData)
                {
                    (cell as! ShareVideoTrimCell).avPlayer.pause()
                    (cell as! ShareVideoTrimCell).Play_Btn.isHidden = false
                    (cell as! ShareVideoTrimCell).stopPlaybackTimeChecker()
                    
                    (cell as! ShareVideoTrimCell).TrimmerView.hideTracker(true)
                }
            }
            
        }
        
        if(AssetArr.count > 0)
        {
            self.doMessageSendAction()
        }
    }
    
    func doStatusSendAction()
    {
        Themes.sharedInstance.setprogressinAlert(controller: self, progress: 0.0, completionHandler: nil)
        let ObjMultiMedia = AssetArr[0]
        if(ObjMultiMedia.isVideo)
        {
            self.ExportAssetStatus(i : 0)
        }
        else
        {
            doStatusImageAction(i : 0)
        }
    }
    
    func doMessageSendAction()
    {
        Themes.sharedInstance.setprogressinAlert(controller: self, progress: 0.0, completionHandler: nil)
        let ObjMultiMedia = AssetArr[0]
        if(ObjMultiMedia.isVideo)
        {
            self.ExportAssetMessage(i : 0)
        }
        else
        {
            doMessageImageAction(i : 0)
        }
    }
    
    func doStatusImageAction(i : Int)
    {
        let ObjMultiMedia = AssetArr[0]
        var timestamp:String =  String(Date().ticks)
        var servertimeStr:String = Themes.sharedInstance.getServerTime()
        
        if(servertimeStr == "")
        {
            servertimeStr = "0"
        }
        let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
        timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
        let Path:String =  Filemanager.sharedinstance.SaveImageFile(imagePath: "\(Constant.sharedinstance.statuspath)/\(ObjMultiMedia.assetname)",imagedata: ObjMultiMedia.rawData)
        ObjMultiMedia.PathId = ObjMultiMedia.assetname
        ObjMultiMedia.assetpathname = Path
        
        var splitcount:Int = ObjMultiMedia.rawData.count / Constant.sharedinstance.SendbyteCount
        if(splitcount < 1)
        {
            splitcount = 1
        }
        
        let uploadDataCount:String = self.getArrayOfBytesFromImage(ObjMultiMedia.rawData,splitCount: splitcount)
        let imagecount:Int = ObjMultiMedia.rawData.count
        let Dict:[String:Any] = ["failure_status":"0","total_byte_count":"\(imagecount)","upload_byte_count":"0","upload_count":"1","upload_data_id":ObjMultiMedia.PathId,"upload_Path":"\(ObjMultiMedia.assetpathname!)","upload_status":"0","user_common_id":"\(ObjMultiMedia.userCommonID)","serverpath":"","user_id":Themes.sharedInstance.Getuser_id(),"data_count":uploadDataCount,"compressed_data":ObjMultiMedia.Base64Str,"to_id":"\(ObjMultiMedia.toID)","message_status":"0","timestamp":timestamp,"total_data_count":"\(splitcount)","width":"\(ObjMultiMedia.Thumbnail.size.width)","height":"\(ObjMultiMedia.Thumbnail.size.height)","upload_type":"1","download_status":"2","is_uploaded":"1", "upload_paused":"0"]
        DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict as NSDictionary, Entityname: Constant.sharedinstance.Status_Upload_Details);
        
        if(i+1 <= self.AssetArr.count-1)
        {
            Themes.sharedInstance.setprogressinAlert(controller: self, progress: Float(i) / Float(self.AssetArr.count-1), completionHandler: nil)
            let ObjMultiMedia = AssetArr[i+1]
            if(ObjMultiMedia.isVideo)
            {
                self.ExportAssetStatus(i : i+1)
            }
            else
            {
                doStatusImageAction(i: i+1)
            }
            
        }
        else
        {
            Themes.sharedInstance.setprogressinAlert(controller: self, progress: 1.0) {
                self.Delegate?.EdittedImage!( AssetArr: self.AssetArr,Status:"CHECK")
                self.navigationController?.pop(animated: true)
                
            }
        }
    }
    
    func getArrayOfBytesFromImage(_ imageData:Data,splitCount:Int)->String
    {
        var ConstantTotalByteCount:Int!
        let count = imageData.count / MemoryLayout<UInt8>.size
        ConstantTotalByteCount = count/splitCount
        return String(ConstantTotalByteCount)
    }
    
    func doMessageImageAction(i : Int)
    {
        let ObjMultiMedia = AssetArr[i]
        var timestamp:String =  String(Date().ticks)
        var servertimeStr:String = Themes.sharedInstance.getServerTime()
        
        if(servertimeStr == "")
        {
            servertimeStr = "0"
        }
        let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
        timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
        let Path:String =  Filemanager.sharedinstance.SaveImageFile(imagePath: "\(Constant.sharedinstance.photopath)/\(ObjMultiMedia.assetname)",imagedata: ObjMultiMedia.rawData)
        ObjMultiMedia.PathId = ObjMultiMedia.assetname
        ObjMultiMedia.assetpathname = Path
        
        var splitcount:Int = ObjMultiMedia.rawData.count / Constant.sharedinstance.SendbyteCount
        if(splitcount < 1)
        {
            splitcount = 1
        }
        let uploadDataCount:String = self.getArrayOfBytesFromImage(ObjMultiMedia.rawData,splitCount: splitcount)
        let imagecount:Int = ObjMultiMedia.rawData.count
        let Dict:[String:Any] = ["failure_status":"0","total_byte_count":"\(imagecount)","upload_byte_count":"0","upload_count":"1","upload_data_id":ObjMultiMedia.PathId,"upload_Path":"\(ObjMultiMedia.assetpathname!)","upload_status":"0","user_common_id":"\(ObjMultiMedia.userCommonID)","serverpath":"","user_id":Themes.sharedInstance.Getuser_id(),"data_count":uploadDataCount,"compressed_data":ObjMultiMedia.Base64Str,"to_id":"\(ObjMultiMedia.toID)","message_status":"0","timestamp":timestamp,"total_data_count":"\(splitcount)","width":"\(ObjMultiMedia.Thumbnail.size.width)","height":"\(ObjMultiMedia.Thumbnail.size.height)","upload_type":"1","download_status":"2","is_uploaded":"1", "upload_paused":"0"]
        DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict as NSDictionary, Entityname: Constant.sharedinstance.Upload_Details);
        if(i+1 <= self.AssetArr.count-1)
        {
            Themes.sharedInstance.setprogressinAlert(controller: self, progress: Float(i) / Float(self.AssetArr.count-1), completionHandler: nil)
            let ObjMultiMedia = AssetArr[i+1]
            if(ObjMultiMedia.isVideo)
            {
                self.ExportAssetMessage(i : i+1)
            }
            else
            {
                doMessageImageAction(i: i+1)
            }
            
        }
        else
        {
            Themes.sharedInstance.setprogressinAlert(controller: self, progress: 1.0) {
                self.Delegate?.EdittedImage!( AssetArr: self.AssetArr,Status:"CHECK")
                self.navigationController?.pop(animated: true)
                
            }
        }
    }
}

extension ShareEditViewController : ShareVideoTrimCellDelegate {
    func updateTrimDetails(_ ObjMultimedia: MultimediaRecord) {
        _ = AssetArr.map {
            if $0.assetpathname == ObjMultimedia.assetpathname {
                $0.StartTime = ObjMultimedia.StartTime
                $0.Endtime = ObjMultimedia.Endtime
            }
        }
    }
}







