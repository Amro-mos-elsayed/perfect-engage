//
//  EditViewController.swift
//
//
//  Created by Casp iOS on 06/04/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit
import MobileCoreServices
import ICGVideoTrimmer
import DKImagePickerController
import SwiftyGiphy
import SDWebImage
import Mantis

@objc protocol EditViewControllerDelegate  : class {
    @objc optional func EdittedImage(AssetArr:NSMutableArray,Status:String)
}

class EditViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,ICGVideoTrimmerDelegate,UICollectionViewDelegateFlowLayout, UITextFieldDelegate, CropViewControllerDelegate {
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage) {
        print(cropped)
        let ObjMultiMedia:MultimediaRecord = AssetArr[self.EditedIndex] as! MultimediaRecord
        ObjMultiMedia.Thumbnail = cropped
        
        AssetHandler.sharedInstance.ProcessFilterAsset(ObjMultiRecord: ObjMultiMedia, oppenentID: self.to_id, isFromStatus: isfromStatus, completionHandler: { (objrec) -> ()? in
            self.AssetArr.removeObject(at: self.EditedIndex)
            self.AssetArr.insert(objrec, at: self.EditedIndex)
            self.mediaCollectionView_main.reloadData()
            self.mediaCollectionView.reloadData()
            return ()
        })
    }
    
    func cropViewControllerDidFailToCrop(_ cropViewController: CropViewController, original: UIImage) {
        
    }
    
    func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
        
    }
    
    func cropViewControllerWillDismiss(_ cropViewController: CropViewController) {
        
    }
    
    
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mediaCollectionView: UICollectionView!
    @IBOutlet weak var mediaCollectionView_main: UICollectionView!
    @IBOutlet weak var done_Btn: UIButton!
    @IBOutlet weak var close_Btn: UIButton!
    @IBOutlet weak var crop_Btn: UIButton!
    @IBOutlet weak var delete_Btn: UIButton!
    @IBOutlet weak var txt_caption: UITextField!
    @IBOutlet weak var txt_caption_view: UIView!
    @IBOutlet weak var txt_caption_bottom: NSLayoutConstraint!
    @IBOutlet weak var btn_send_bottom: NSLayoutConstraint!
    @IBOutlet weak var btn_add_bottom: NSLayoutConstraint!
    var GlobalIndex:Int = Int()
    var EditedIndex:Int = Int()
    weak var Delegate:EditViewControllerDelegate?
    var isVideoData:Bool = Bool()
    var exportSession: AVAssetExportSession!
    var AssetArr:NSMutableArray = NSMutableArray()
    var isfromStatus : Bool = Bool()
    var selectedAssets = [DKAsset]()
    var isgroup:Bool = Bool()
    var to_id : String = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        addNotificationListener()
        txt_caption.delegate = self
        txt_caption_view.layer.borderWidth = 1;
        txt_caption_view.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    
    
    func trimmerView(_ trimmerView: ICGVideoTrimmerView!, didChangeLeftPosition startTime: CGFloat, rightPosition endTime: CGFloat) {
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mediaCollectionView_main.isPagingEnabled = true
        let Nib = UINib(nibName: "MediaCollectionViewCell", bundle: nil)
        mediaCollectionView.register(Nib, forCellWithReuseIdentifier: "MediaCollectionViewCellID")
        GlobalIndex = 0
        self.mediaCollectionView.dataSource = self
        self.mediaCollectionView.delegate = self
        let ObjTemp : MultimediaRecord = AssetArr[GlobalIndex] as! MultimediaRecord
        if !ObjTemp.isVideo && !ObjTemp.isGif {
            self.crop_Btn.isHidden = false
            self.delete_Btn.isHidden = false
        }else{
            self.crop_Btn.isHidden = true
            self.delete_Btn.isHidden = true
        }

        self.mediaCollectionView.reloadData()
        UIView.animate(withDuration: 0.2) {
            
            let height : CGFloat = self.AssetArr.count == 1 ? -55 : 8
            
            self.txt_caption_bottom.constant = height
            self.btn_send_bottom.constant = height
            self.btn_add_bottom.constant = height
            
            self.mediaCollectionView.isHidden = self.AssetArr.count == 1
        }
    }
    
    func keyboardWillShow(notification: Notification){
        adjustKeyboardShow(true, notification: notification)
    }
    
    func keyboardWillDisappear(notification: Notification){
        adjustKeyboardShow(false, notification: notification)
    }
    
    func adjustKeyboardShow(_ open: Bool, notification: Notification) {
        let userInfo = notification.userInfo ?? [:]
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        var height = (keyboardFrame.height - mediaCollectionView.bounds.height)
        let Dheight : CGFloat = self.AssetArr.count == 1 ? -55 : 8

        height = open ? height : Dheight
        UIView.animate(withDuration: 0.3) {
            self.txt_caption_bottom.constant = height
            self.btn_send_bottom.constant = height
            self.btn_add_bottom.constant = height
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text : String = (textField.text?.appending(string))!
        print(text)
        
        let ObjMultimedia : MultimediaRecord = AssetArr[GlobalIndex] as! MultimediaRecord
        ObjMultimedia.caption = text
        
        return true
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
            let ObjMultiMedia:MultimediaRecord = AssetArr[i] as! MultimediaRecord
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
                                
                                print(self.exportSession?.status as Any)
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
                                
                                let uploadDataCount:String = UploadHandler.Sharedinstance.getArrayOfBytesFromImage(ObjMultiMedia.rawData,splitCount: splitcount)
                                let imagecount:Int = ObjMultiMedia.rawData.count
                                let Dict:[String:Any] = ["failure_status":"0","total_byte_count":"\(imagecount)","upload_byte_count":"0","upload_count":"1","upload_data_id":ObjMultiMedia.PathId,"upload_Path":"\(ObjMultiMedia.assetpathname!)","upload_status":"0","user_common_id":"\(ObjMultiMedia.userCommonID)","serverpath":"","user_id":Themes.sharedInstance.Getuser_id(),"data_count":uploadDataCount,"compressed_data":ObjMultiMedia.Base64Str,"to_id":"\(ObjMultiMedia.toID)","message_status":"0","timestamp":timestamp,"total_data_count":"\(splitcount)","width":"\(ObjMultiMedia.Thumbnail.size.width)","height":"\(ObjMultiMedia.Thumbnail.size.height)","upload_type":"2","video_thumbnail":ObjMultiMedia.VideoThumbnail,"download_status":"2","is_uploaded":"1", "upload_paused":"0"]
                                
                                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict as NSDictionary, Entityname: Constant.sharedinstance.Upload_Details);
                                self.AssetArr.replaceObject(at: i, with: ObjMultiMedia)
                                
                                if(i+1 <= self.AssetArr.count-1)
                                {
                                    Themes.sharedInstance.setprogressinAlert(controller: self, progress: Float(i) / Float(self.AssetArr.count-1), completionHandler: nil)
                                    let ObjMulrec = self.AssetArr.object(at: i+1) as! MultimediaRecord
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
                                        self.pop(animated: true)
                                        
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
            let ObjMultiMedia:MultimediaRecord = AssetArr[i] as! MultimediaRecord
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
                                
                                print(self.exportSession?.status as Any)
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
                                
                                let uploadDataCount:String = UploadHandler.Sharedinstance.getArrayOfBytesFromImage(ObjMultiMedia.rawData,splitCount: splitcount)
                                let imagecount:Int = ObjMultiMedia.rawData.count
                                let Dict:[String:Any] = ["failure_status":"0","total_byte_count":"\(imagecount)","upload_byte_count":"0","upload_count":"1","upload_data_id":ObjMultiMedia.PathId,"upload_Path":"\(ObjMultiMedia.assetpathname!)","upload_status":"0","user_common_id":"\(ObjMultiMedia.userCommonID)","serverpath":"","user_id":Themes.sharedInstance.Getuser_id(),"data_count":uploadDataCount,"compressed_data":ObjMultiMedia.Base64Str,"to_id":"\(ObjMultiMedia.toID)","message_status":"0","timestamp":timestamp,"total_data_count":"\(splitcount)","width":"\(ObjMultiMedia.Thumbnail.size.width)","height":"\(ObjMultiMedia.Thumbnail.size.height)","upload_type":"2","video_thumbnail":ObjMultiMedia.VideoThumbnail,"download_status":"2","is_uploaded":"1", "upload_paused":"0"]
                                
                                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict as NSDictionary, Entityname: Constant.sharedinstance.Status_Upload_Details);
                                self.AssetArr.replaceObject(at: i, with: ObjMultiMedia)
                                self.exportSession = nil
                                
                                if(i+1 <= self.AssetArr.count-1)
                                {
                                    Themes.sharedInstance.setprogressinAlert(controller: self, progress: Float(i) / Float(self.AssetArr.count-1), completionHandler: nil)
                                    let ObjMulrec = self.AssetArr.object(at: i+1) as! MultimediaRecord
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
                                        self.pop(animated: true)
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
            let ObjTemp : MultimediaRecord = AssetArr[GlobalIndex] as! MultimediaRecord
            if !ObjTemp.isVideo && !ObjTemp.isGif {
                self.crop_Btn.isHidden = false
                self.delete_Btn.isHidden = false
            }else{
                self.crop_Btn.isHidden = true
                self.delete_Btn.isHidden = true
            }

            mediaCollectionView.reloadData()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.mediaCollectionView_main {
            let currentIndex: Int = Int(mediaCollectionView_main.contentOffset.x) / Int(mediaCollectionView_main.frame.size.width)
            GlobalIndex = Int(currentIndex)
            let ObjTemp : MultimediaRecord = AssetArr[GlobalIndex] as! MultimediaRecord
            if !ObjTemp.isVideo && !ObjTemp.isGif {
                self.crop_Btn.isHidden = false
                self.delete_Btn.isHidden = false
            }else{
                self.crop_Btn.isHidden = true
                self.delete_Btn.isHidden = true
            }

            mediaCollectionView.reloadData()
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return AssetArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(isfromStatus)
        {
            txt_caption.resignFirstResponder()
            let ObjTemp : MultimediaRecord = AssetArr[GlobalIndex] as! MultimediaRecord
            txt_caption.text = ObjTemp.caption
            if(collectionView == mediaCollectionView)
            {
                let Cell:MediaCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaCollectionViewCellID", for: indexPath) as! MediaCollectionViewCell
                let ObjMultiMedia:MultimediaRecord = AssetArr[indexPath.row] as! MultimediaRecord
                if(ObjMultiMedia.isVideo)
                {
                    Cell.MediaImageView.image = ObjMultiMedia.Thumbnail
                    Cell.play_img.image = #imageLiteral(resourceName: "playIcon")
                    Cell.play_img.isHidden = false
                }
                else if(ObjMultiMedia.isGif)
                {
                    Cell.MediaImageView.image = UIImage(data: ObjMultiMedia.CompresssedData)
                    Cell.play_img.image = #imageLiteral(resourceName: "gifIcon")
                    Cell.play_img.isHidden = false
                }
                else
                {
                    Cell.MediaImageView.image = ObjMultiMedia.Thumbnail
                    Cell.play_img.isHidden = true
                }
                
                print(ObjMultiMedia.assetpathname!)
                
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
                
                let cell: VideoTrimCell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoTrimCellID", for: indexPath) as! VideoTrimCell
                
                cell.ObjMultimedia = AssetArr[indexPath.row] as! MultimediaRecord
                cell.isVideoData = cell.ObjMultimedia.isVideo
                cell.fromStatus = true
                DispatchQueue.main.async {
                    cell.UpdateUI()
                }
                
                cell.TrimmerView.frame = CGRect(x: 10, y: 0, width: self.mediaCollectionView_main.frame.size.width - 20, height: cell.TrimmerView.frame.size.height)
                
                return  cell
                
            }
        }
        else
        {
            txt_caption.resignFirstResponder()
            let ObjTemp : MultimediaRecord = AssetArr[GlobalIndex] as! MultimediaRecord
            txt_caption.text = ObjTemp.caption
            if(collectionView == mediaCollectionView)
            {
                let Cell:MediaCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaCollectionViewCellID", for: indexPath) as! MediaCollectionViewCell
                let ObjMultiMedia:MultimediaRecord = AssetArr[indexPath.row] as! MultimediaRecord
                if(ObjMultiMedia.isVideo)
                {
                    Cell.MediaImageView.image = ObjMultiMedia.Thumbnail
                    Cell.play_img.image = #imageLiteral(resourceName: "playIcon")
                    Cell.play_img.isHidden = false
                }
                else if(ObjMultiMedia.isGif)
                {
                    Cell.MediaImageView.image = UIImage(data: ObjMultiMedia.CompresssedData)
                    Cell.play_img.image = #imageLiteral(resourceName: "gifIcon")
                    Cell.play_img.isHidden = false
                }
                else
                {
                    Cell.MediaImageView.image = ObjMultiMedia.Thumbnail
                    Cell.play_img.isHidden = true
                }
                
                print(ObjMultiMedia.assetpathname!)
                
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
                
                let cell: VideoTrimCell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoTrimCellID", for: indexPath) as! VideoTrimCell
                
                cell.ObjMultimedia = AssetArr[indexPath.row] as! MultimediaRecord
                cell.isVideoData = cell.ObjMultimedia.isVideo
                cell.fromStatus = false
                DispatchQueue.main.async {
                    cell.UpdateUI()
                }
                
                cell.TrimmerView.frame = CGRect(x: 10, y: 0, width: self.mediaCollectionView_main.frame.size.width - 20, height: cell.TrimmerView.frame.size.height)
                
                return  cell
                
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(collectionView == mediaCollectionView_main)
        {
            let ObjTemp : MultimediaRecord = AssetArr[indexPath.item] as! MultimediaRecord
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
        Themes.sharedInstance.RemoveactivityView(View: self.view)
        self.Delegate?.EdittedImage!( AssetArr: AssetArr,Status:"CHECK")
        self.pop(animated: true)
    }
    @IBAction func DidclickClose(_ sender: Any) {
        pauseIfPlaying()
        Themes.sharedInstance.RemoveactivityView(View: self.view)
        self.pop(animated: true)
        
    }
    @IBAction func DidclickPlay_Btn(_ sender: Any) {
        
    }
    @IBAction func Crop_Btn_Action(_ sender: Any) {
        
        let visibleRect = CGRect(origin: self.mediaCollectionView_main.contentOffset, size: self.mediaCollectionView_main.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let visibleIndexPath = self.mediaCollectionView_main.indexPathForItem(at: visiblePoint)
        if self.AssetArr.count  > visibleIndexPath!.row{
            EditedIndex = visibleIndexPath!.row
            let ObjMultiMedia:MultimediaRecord = self.AssetArr[visibleIndexPath!.row] as! MultimediaRecord
            if !ObjMultiMedia.isGif && !ObjMultiMedia.isVideo {
                let cropViewController = Mantis.cropViewController(image: ObjMultiMedia.Thumbnail)
                cropViewController.delegate = self
                present(cropViewController, animated: true)
            }
        }
    }
    @IBAction func Delete_Btn_Action(_ sender: Any) {
        let visibleRect = CGRect(origin: self.mediaCollectionView_main.contentOffset, size: self.mediaCollectionView_main.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let visibleIndexPath = self.mediaCollectionView_main.indexPathForItem(at: visiblePoint)
        if self.AssetArr.count  > visibleIndexPath!.row{
            self.AssetArr.removeObject(at: visibleIndexPath!.row)
            if self.AssetArr.count > 0 {
                self.mediaCollectionView_main.reloadData()
                self.mediaCollectionView.reloadData()
            }else{
                pauseIfPlaying()
                Themes.sharedInstance.RemoveactivityView(View: self.view)
                self.pop(animated: true)
            }
        }
    }
    @IBAction func DidclickSendBtn(_ sender: Any) {
        pauseIfPlaying()
        
        (sender as! UIButton).isUserInteractionEnabled = false
        
        Themes.sharedInstance.showprogressAlert(controller: self)
        
        if(AssetArr.count > 0)
        {
            if(isfromStatus)
            {
                self.doStatusSendAction()
            }
            else
            {
                
                self.doMessageSendAction()
            }
        }
    }
    
    func pauseIfPlaying()
    {
        
        for i in 0..<self.mediaCollectionView_main.numberOfItems(inSection: 0) {
            let cell = self.mediaCollectionView_main.cellForItem(at: IndexPath(item: i, section: 0))
            if(cell != nil)
            {
                if((cell as! VideoTrimCell).isVideoData)
                {
                    (cell as! VideoTrimCell).avPlayer.pause()
                    (cell as! VideoTrimCell).Play_Btn.isHidden = false
                    (cell as! VideoTrimCell).stopPlaybackTimeChecker()
                    
                    (cell as! VideoTrimCell).TrimmerView.hideTracker(true)
                }
            }
            
        }
    }
    
    @IBAction func DidclickAddBtn(_ sender: Any) {
        
        let pickerController = DKImagePickerController()
        pickerController.maxSelectableCount = 10
        pickerController.assetType = .allAssets
        pickerController.sourceType = .photo
//        pickerController.isFromChat = true
//        pickerController.defaultSelectedAssets = self.selectedAssets
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            _ = self.AssetArr.map {
                let objrec = $0 as! MultimediaRecord
                if(!objrec.isGif)
                {
                    self.AssetArr.remove($0)
                }
            }
            if(assets.count > 0 || self.AssetArr.count > 0)
            {
                if(assets.count > 0)
                {
                    self.selectedAssets = assets
                    Themes.sharedInstance.activityView(View: self.view)
                    AssetHandler.sharedInstance.isgroup = false
                    let to_id = self.to_id
                    AssetHandler.sharedInstance.ProcessAsset(assets: assets,oppenentID: to_id,isFromStatus: self.isfromStatus, completionHandler: { [weak self] (AssetArr, error) -> ()? in
                        if((AssetArr?.count)! > 0)
                        {
                            DispatchQueue.main.async {
                                Themes.sharedInstance.RemoveactivityView(View: (self?.view)!)
                            
                                self?.AssetArr.addObjects(from: AssetArr! as! [Any])
                                UIView.animate(withDuration: 0.2) {
                                    let height : CGFloat = self?.AssetArr.count == 1 ? -55 : 8
                                    
                                    self?.txt_caption_bottom.constant = height
                                    self?.btn_send_bottom.constant = height
                                    self?.btn_add_bottom.constant = height
                                    
                                    self?.mediaCollectionView.isHidden = self?.AssetArr.count == 1
                                }
                                self?.mediaCollectionView.reloadData()
                                self?.mediaCollectionView_main.reloadData()
                                
                                let visibleRect = CGRect(origin: (self?.mediaCollectionView_main.contentOffset)!, size: (self?.mediaCollectionView_main.bounds.size)!)
                                let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
                                let visibleIndexPath = self?.mediaCollectionView_main.indexPathForItem(at: visiblePoint)
                                if (self?.AssetArr.count)!  > visibleIndexPath!.row{

                                let ObjTemp:MultimediaRecord = self?.AssetArr[visibleIndexPath!.row] as! MultimediaRecord

                                if !ObjTemp.isVideo && !ObjTemp.isGif {
                                    self?.crop_Btn.isHidden = false
                                    self?.delete_Btn.isHidden = false
                                }else{
                                    self?.crop_Btn.isHidden = true
                                    self?.delete_Btn.isHidden = true
                                }
                                }
                                
                            }
                        }
                        return ()
                    })
                }
                else
                {
                    self.selectedAssets = []
                    UIView.animate(withDuration: 0.2) {
                        let height : CGFloat = self.AssetArr.count == 1 ? -55 : 8
                        
                        self.txt_caption_bottom.constant = height
                        self.btn_send_bottom.constant = height
                        self.btn_add_bottom.constant = height
                        
                        self.mediaCollectionView.isHidden = self.AssetArr.count == 1
                    }
                    self.mediaCollectionView.reloadData()
                    self.mediaCollectionView_main.reloadData()
                }
            }
            else
            {
                self.pop(animated: true)
            }
        }
//        pickerController.didClickGif = {
//            let picker = SwiftyGiphyViewController()
//            picker.delegate = self
//            let navigation = UINavigationController(rootViewController: picker)
//            self.presentView(navigation, animated: true)
//
//        }
        self.presentView(pickerController, animated: true)
    }
    func doStatusSendAction()
    {
        Themes.sharedInstance.setprogressinAlert(controller: self, progress: 0.0, completionHandler: nil)
        let ObjMultiMedia = AssetArr.object(at: 0) as! MultimediaRecord
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
        let ObjMultiMedia = AssetArr.object(at: 0) as! MultimediaRecord
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
        let ObjMultiMedia = AssetArr.object(at: i) as! MultimediaRecord
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
        
        let uploadDataCount:String = UploadHandler.Sharedinstance.getArrayOfBytesFromImage(ObjMultiMedia.rawData,splitCount: splitcount)
        let imagecount:Int = ObjMultiMedia.rawData.count
        let Dict:[String:Any] = ["failure_status":"0","total_byte_count":"\(imagecount)","upload_byte_count":"0","upload_count":"1","upload_data_id":ObjMultiMedia.PathId,"upload_Path":"\(ObjMultiMedia.assetpathname!)","upload_status":"0","user_common_id":"\(ObjMultiMedia.userCommonID)","serverpath":"","user_id":Themes.sharedInstance.Getuser_id(),"data_count":uploadDataCount,"compressed_data":ObjMultiMedia.Base64Str,"to_id":"\(ObjMultiMedia.toID)","message_status":"0","timestamp":timestamp,"total_data_count":"\(splitcount)","width":"\(ObjMultiMedia.Thumbnail.size.width)","height":"\(ObjMultiMedia.Thumbnail.size.height)","upload_type":"1","download_status":"2","is_uploaded":"1", "upload_paused":"0"]
        DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict as NSDictionary, Entityname: Constant.sharedinstance.Status_Upload_Details);
        print("the dict is >>>> \(Dict)")
        
        if(i+1 <= self.AssetArr.count-1)
        {
            Themes.sharedInstance.setprogressinAlert(controller: self, progress: Float(i) / Float(self.AssetArr.count-1), completionHandler: nil)
            let ObjMultiMedia = AssetArr.object(at: i+1) as! MultimediaRecord
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
                self.pop(animated: true)
                
            }
        }
    }
    
    func doMessageImageAction(i : Int)
    {
        let ObjMultiMedia:MultimediaRecord = AssetArr[i] as! MultimediaRecord
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
        let uploadDataCount:String = UploadHandler.Sharedinstance.getArrayOfBytesFromImage(ObjMultiMedia.rawData,splitCount: splitcount)
        let imagecount:Int = ObjMultiMedia.rawData.count
        let Dict:[String:Any] = ["failure_status":"0","total_byte_count":"\(imagecount)","upload_byte_count":"0","upload_count":"1","upload_data_id":ObjMultiMedia.PathId,"upload_Path":"\(ObjMultiMedia.assetpathname!)","upload_status":"0","user_common_id":"\(ObjMultiMedia.userCommonID)","serverpath":"","user_id":Themes.sharedInstance.Getuser_id(),"data_count":uploadDataCount,"compressed_data":ObjMultiMedia.Base64Str,"to_id":"\(ObjMultiMedia.toID)","message_status":"0","timestamp":timestamp,"total_data_count":"\(splitcount)","width":"\(ObjMultiMedia.Thumbnail.size.width)","height":"\(ObjMultiMedia.Thumbnail.size.height)","upload_type":"1","download_status":"2","is_uploaded":"1", "upload_paused":"0"]
        DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict as NSDictionary, Entityname: Constant.sharedinstance.Upload_Details);
        print("the dict is >>>> \(Dict)")
        if(i+1 <= self.AssetArr.count-1)
        {
            Themes.sharedInstance.setprogressinAlert(controller: self, progress: Float(i) / Float(self.AssetArr.count-1), completionHandler: nil)
            let ObjMultiMedia = AssetArr.object(at: i+1) as! MultimediaRecord
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
                self.pop(animated: true)
                
            }
        }
    }
    
    func addNotificationListener() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            weak.keyboardWillShow(notification:notify)
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            weak.keyboardWillDisappear(notification: notify)
        }
    }
    
    func removeNotificationListener() {
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        exportSession = nil
        removeNotificationListener()
    }

}

extension EditViewController : SwiftyGiphyViewControllerDelegate {
    
    func giphyControllerDidSelectGif(controller: SwiftyGiphyViewController, item: GiphyItem) {
        self.dismissView(animated: true, completion: {
            Themes.sharedInstance.showprogressAlert(controller: self)
            var url : URL?
            if(item.downsizedImage != nil)
            {
                url = item.downsizedImage?.url
            }
            else if(item.fixedHeightImage != nil)
            {
                url = item.fixedHeightImage?.url
            }
            else
            {
                url = item.originalImage?.url
            }
            
            SDWebImageDownloader.shared().downloadImage(with: url, options: .highPriority, progress: { (received, total, url) in
                DispatchQueue.main.async {
                    if(received != total)
                    {
                        Themes.sharedInstance.setprogressinAlert(controller: self, progress: Float(received) / Float(total), completionHandler: nil)
                    }
                }
            }) { (image, data, error, success) in
                if(error == nil)
                {
                    DispatchQueue.main.async {
                        Themes.sharedInstance.setprogressinAlert(controller: self, progress: 1.0, completionHandler: {
                            
                            Filemanager.sharedinstance.CreateFolder(foldername: "Temp")
                            
                            var timestamp:String = String(Date().ticks)
                            var servertimeStr:String = Themes.sharedInstance.getServerTime()
                            
                            if(servertimeStr == "")
                            {
                                servertimeStr = "0"
                            }
                            let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
                            timestamp =  "\((timestamp as NSString).longLongValue + Int64(0) - serverTimestamp)"
                            
                            
                            let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
                            let to:String=Themes.sharedInstance.CheckNullvalue(Passed_value: self.to_id)
                            
                            let User_chat_id = (to == "") ? from : from + "-" + to;
                            
                            let url = Filemanager.sharedinstance.SaveImageFile(imagePath: "Temp/\(timestamp).gif", imagedata: data!)
                            
                            let ObjMultiRecord:MultimediaRecord = MultimediaRecord()
                            
                            let Pathextension:String = "GIF"
                            if(self.isgroup)
                            {
                                ObjMultiRecord.assetname = "\(User_chat_id)-g-\(timestamp).\(Pathextension.lowercased())"
                            }
                            else
                            {
                                ObjMultiRecord.assetname = "\(User_chat_id)-\(timestamp).\(Pathextension.lowercased())"
                            }
                            ObjMultiRecord.timestamp = timestamp
                            ObjMultiRecord.userCommonID = User_chat_id
                            ObjMultiRecord.assetpathname = url
                            print(ObjMultiRecord.assetpathname)
                            ObjMultiRecord.toID = to
                            ObjMultiRecord.isVideo = false
                            ObjMultiRecord.StartTime = 0.0
                            ObjMultiRecord.Endtime = 0.0
                            ObjMultiRecord.Thumbnail = image
                            ObjMultiRecord.rawData = data
                            ObjMultiRecord.isGif = true
                            
                            ObjMultiRecord.CompresssedData = image!.jpegData(compressionQuality: 0.1)
                            ObjMultiRecord.Base64Str = Themes.sharedInstance.convertImageToBase64(imageData:ObjMultiRecord.CompresssedData)
                            
                            Filemanager.sharedinstance.DeleteFile(foldername: "Temp/\(timestamp).gif")
                            
                            self.AssetArr.addObjects(from: [ObjMultiRecord])
                            
                            UIView.animate(withDuration: 0.2) {
                                let height : CGFloat = self.AssetArr.count == 1 ? -55 : 8
                                
                                self.txt_caption_bottom.constant = height
                                self.btn_send_bottom.constant = height
                                self.btn_add_bottom.constant = height
                                
                                self.mediaCollectionView.isHidden = self.AssetArr.count == 1
                            }
                            self.mediaCollectionView.reloadData()
                            self.mediaCollectionView_main.reloadData()
                        })
                        
                        
                        //                        let Path:String =  Filemanager.sharedinstance.SaveImageFile(imagePath: "\(Constant.sharedinstance.photopath)/\(ObjMultiRecord.assetname)",imagedata: ObjMultiRecord.rawData)
                        //                        ObjMultiRecord.PathId = ObjMultiRecord.assetname
                        //                        ObjMultiRecord.assetpathname = Path
                        //
                        //                        var splitcount:Int = ObjMultiRecord.rawData.count / Constant.sharedinstance.SendbyteCount
                        //                        if(splitcount < 1)
                        //                        {
                        //                            splitcount = 1
                        //                        }
                        //                        let uploadDataCount:String = UploadHandler.Sharedinstance.getArrayOfBytesFromImage(ObjMultiRecord.rawData,splitCount: splitcount)
                        //                        let imagecount:Int = ObjMultiRecord.rawData.count
                        //                        let Dict:[String:Any] = ["failure_status":"0","total_byte_count":"\(imagecount)","upload_byte_count":"0","upload_count":"1","upload_data_id":ObjMultiRecord.PathId,"upload_Path":"\(ObjMultiRecord.assetpathname!)","upload_status":"0","user_common_id":"\(ObjMultiRecord.userCommonID)","serverpath":"","user_id":Themes.sharedInstance.Getuser_id(),"data_count":uploadDataCount,"compressed_data":ObjMultiRecord.Base64Str,"to_id":"\(ObjMultiRecord.toID)","message_status":"0","timestamp":timestamp,"total_data_count":"\(splitcount)","width":"\(ObjMultiRecord.Thumbnail.size.width)","height":"\(ObjMultiRecord.Thumbnail.size.height)","upload_type":"1","download_status":"2","is_uploaded":"1", "upload_paused":"0"]
                        //                        DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict as NSDictionary, Entityname: Constant.sharedinstance.Upload_Details);
                        //                        print("the dict is >>>> \(Dict)")
                        //                        self.EdittedImage(AssetArr: NSMutableArray.init(array: [ObjMultiRecord]), Status: "CHECK")
                    }
                }
                else {
                    Themes.sharedInstance.setprogressinAlert(controller: self, progress: 1.0, completionHandler: nil)
                }
            }
        })
    }
    
    func giphyControllerDidCancel(controller: SwiftyGiphyViewController) {
        self.dismissView(animated: true, completion: nil)
    }
}

//extension EditViewController : CropViewControllerProtocal{
//    func didGetCroppedImage(image: UIImage) {
//        print(image)
//        let ObjMultiMedia:MultimediaRecord = AssetArr[self.EditedIndex] as! MultimediaRecord
//        ObjMultiMedia.Thumbnail = image
//
//        AssetHandler.sharedInstance.ProcessFilterAsset(ObjMultiRecord: ObjMultiMedia, oppenentID: self.to_id, isFromStatus: isfromStatus, completionHandler: { (objrec) -> ()? in
//            self.AssetArr.removeObject(at: self.EditedIndex)
//            self.AssetArr.insert(objrec, at: self.EditedIndex)
//            self.mediaCollectionView_main.reloadData()
//            self.mediaCollectionView.reloadData()
//            return ()
//        })
//
//
//    }
//
//}
