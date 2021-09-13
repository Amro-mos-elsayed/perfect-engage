//
//  AssetHandler.swift

//
//  Created by Casp iOS on 10/04/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit
import DKImagePickerController
import Photos

class AssetHandler: NSObject {
    static let sharedInstance = AssetHandler()
    var isgroup:Bool = Bool()
    func ProcessAsset(assets: [DKAsset],oppenentID:String, isFromStatus : Bool, completionHandler:   @escaping (_ AssetArr: NSMutableArray?, _ error:NSError? ) -> ()?)
    {
        if(isFromStatus)
        {
            let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
            if(assets.count > 0)
            {
                let User_chat_id=from
                print(assets)
                let AssetArr = NSMutableArray()
                for i in 0..<assets.count
                {
                    DispatchQueue.main.async {
                        var url:NSString! = NSString()
                        
                        var timestamp:String = String(Date().ticks)
                        var servertimeStr:String = Themes.sharedInstance.getServerTime()
                        
                        if(servertimeStr == "")
                        {
                            servertimeStr = "0"
                        }
                        let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
                        timestamp =  "\((timestamp as NSString).longLongValue + Int64(i) - serverTimestamp)"
                        let ObjMultiRecord:MultimediaRecord = MultimediaRecord()
                        let asset:DKAsset = assets[i]
                        if(asset.isVideo)
                        {
                            DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                                self.ReturnAssetvalue(asset: asset, from: from, to: "", User_chat_id: User_chat_id, url: url, timestamp: timestamp,isFromStatus: isFromStatus, completionHandler: { (ObjMultiRecord, error) -> ()? in
                                    AssetArr.add(ObjMultiRecord)
                                    if(AssetArr.count == assets.count)
                                    {
                                        completionHandler(AssetArr, nil)
                                    }
                                    return nil
                                })
                            })
                            
                            //PHImageManager.default().requestAVAsset(forVideo: asset.originalAsset!, options: options, resultHandler: { (_asset: AVAsset?, audioMix: AVAudioMix?, info:[AnyHashable : Any]?) in
                            //                        })
                        }
                        else
                        {
                            
                            
                            asset.fetchOriginalImage(true, completeBlock: ({ (image, info) in
                                print(image!)
                                
                            }))
                            
                            asset.originalAsset?.requestContentEditingInput(with: PHContentEditingInputRequestOptions()) { (input, _) in
                                let image:UIImage =  (input?.displaySizeImage)!.fixOrientation()
                                print(image)
                                url = ("\((input?.fullSizeImageURL?.absoluteString)!)" as NSString)
                                let Pathextension:String = "JPEG"
                                if(self.isgroup == true)
                                {
                                    ObjMultiRecord.assetname = "\(User_chat_id)-g-\(timestamp).\(Pathextension.lowercased())"
                                }
                                else
                                {
                                    ObjMultiRecord.assetname = "\(User_chat_id)-\(timestamp).\(Pathextension.lowercased())"
                                }
                                ObjMultiRecord.timestamp = timestamp
                                ObjMultiRecord.userCommonID = User_chat_id
                                ObjMultiRecord.assetpathname = url as String
                                print(ObjMultiRecord.assetpathname)
                                ObjMultiRecord.toID = ""
                                ObjMultiRecord.isVideo = asset.isVideo
                                ObjMultiRecord.StartTime = 0.0
                                ObjMultiRecord.Endtime = 0.0
                                ObjMultiRecord.Thumbnail = image
                                print(input?.displaySizeImage?.size ?? CGSize.zero)
                                
                                var rawData = image.pngData()
                                
                                if(Pathextension == "PNG")
                                {
                                    
                                    ObjMultiRecord.rawData = image.pngData()
                                    
                                }
                                else
                                {
                                    ObjMultiRecord.rawData = image.jpegData(compressionQuality: 0.5)
//                                        UIImageJPEGRepresentation(image, 0.5)
                                    
                                }
                                
                                print("total Image size in original size KB:\(Double((rawData?.count)!) / 1024.0) compressed size KB:\(Double((ObjMultiRecord.rawData.count)) / 1024.0)")
                                
                                ObjMultiRecord.CompresssedData = image.jpegData(compressionQuality: 0.1)!
//                                    UIImageJPEGRepresentation(image, 0.1)! as Data
                                ObjMultiRecord.Base64Str = Themes.sharedInstance.convertImageToBase64(imageData:ObjMultiRecord.CompresssedData)
                                AssetArr.add(ObjMultiRecord)
                                if(AssetArr.count == assets.count)
                                {
                                    completionHandler(AssetArr, nil)
                                }
                            }
                        }
                    }
                }
            }
        }
        else
        {
            let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
            let to:String=Themes.sharedInstance.CheckNullvalue(Passed_value: oppenentID)
            if(assets.count > 0)
            {
                let User_chat_id=from + "-" + to;
                print(assets)
                let AssetArr = NSMutableArray()
                for i in 0..<assets.count
                {
                    DispatchQueue.main.async {
                        var url:NSString! = NSString()
                        
                        var timestamp:String = String(Date().ticks)
                        var servertimeStr:String = Themes.sharedInstance.getServerTime()
                        
                        if(servertimeStr == "")
                        {
                            servertimeStr = "0"
                        }
                        let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
                        timestamp =  "\((timestamp as NSString).longLongValue + Int64(i) - serverTimestamp)"
                        let ObjMultiRecord:MultimediaRecord = MultimediaRecord()
                        let asset:DKAsset = assets[i]
                        if(asset.isVideo)
                        {
                            DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                                self.ReturnAssetvalue(asset: asset, from: from, to: to, User_chat_id: User_chat_id, url: url, timestamp: timestamp,isFromStatus: isFromStatus, completionHandler: { (ObjMultiRecord, error) -> ()? in
                                    AssetArr.add(ObjMultiRecord)
                                    if(AssetArr.count == assets.count)
                                    {
                                        completionHandler(AssetArr, nil)
                                    }
                                    return nil
                                })
                            })
                            
                            //PHImageManager.default().requestAVAsset(forVideo: asset.originalAsset!, options: options, resultHandler: { (_asset: AVAsset?, audioMix: AVAudioMix?, info:[AnyHashable : Any]?) in
                            //                        })
                        }
                        else
                        {
                            
                            
                            asset.fetchOriginalImage(true, completeBlock: ({ (image, info) in
                                print(image!)
                                
                            }))
                            
                            asset.originalAsset?.requestContentEditingInput(with: PHContentEditingInputRequestOptions()) { (input, _) in
                                let image:UIImage =  (input?.displaySizeImage)!.fixOrientation()
                                print(image)
                                url = ("\((input?.fullSizeImageURL?.absoluteString)!)" as NSString)
                                let Pathextension:String = "JPEG"
                                if(self.isgroup == true)
                                {
                                    ObjMultiRecord.assetname = "\(User_chat_id)-g-\(timestamp).\(Pathextension.lowercased())"
                                }
                                else
                                {
                                    ObjMultiRecord.assetname = "\(User_chat_id)-\(timestamp).\(Pathextension.lowercased())"
                                }
                                ObjMultiRecord.timestamp = timestamp
                                ObjMultiRecord.userCommonID = User_chat_id
                                ObjMultiRecord.assetpathname = url as String
                                print(ObjMultiRecord.assetpathname)
                                ObjMultiRecord.toID = to
                                ObjMultiRecord.isVideo = asset.isVideo
                                ObjMultiRecord.StartTime = 0.0
                                ObjMultiRecord.Endtime = 0.0
                                ObjMultiRecord.Thumbnail = image
                                print(input?.displaySizeImage?.size ?? CGSize.zero)
                                
                                var rawData = image.pngData()
                                
                                if(Pathextension == "PNG")
                                {
                                    
                                    ObjMultiRecord.rawData = image.pngData()
                                    
                                }
                                else
                                {
                                    ObjMultiRecord.rawData = image.jpegData(compressionQuality: 0.5)
//                                        UIImageJPEGRepresentation(image, 0.5)
                                    
                                }
                                
                                print("total Image size in original size KB:\(Double((rawData?.count)!) / 1024.0) compressed size KB:\(Double((ObjMultiRecord.rawData.count)) / 1024.0)")
                                
                                ObjMultiRecord.CompresssedData = image.jpegData(compressionQuality: 0.1)
//                                    UIImageJPEGRepresentation(image, 0.1)
                                ObjMultiRecord.Base64Str = Themes.sharedInstance.convertImageToBase64(imageData:ObjMultiRecord.CompresssedData)
                                AssetArr.add(ObjMultiRecord)
                                if(AssetArr.count == assets.count)
                                {
                                    completionHandler(AssetArr, nil)
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }
    func ProcessFilterAsset(ObjMultiRecord:MultimediaRecord,oppenentID:String, isFromStatus : Bool, completionHandler: @escaping(_ ObjMultiRecord:MultimediaRecord) -> ()?)
    {
        let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
        let to:String=Themes.sharedInstance.CheckNullvalue(Passed_value: oppenentID)
        
        let User_chat_id = isFromStatus ? from : "\(from)-\(to)"
        DispatchQueue.main.async {
            let url = String()
            
            var timestamp:String = String(Date().ticks)
            var servertimeStr:String = Themes.sharedInstance.getServerTime()
            
            if(servertimeStr == "")
            {
                servertimeStr = "0"
            }
            let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
            timestamp =  "\((timestamp as NSString).longLongValue + Int64(0) - serverTimestamp)"
            let ObjMultiRecord:MultimediaRecord = ObjMultiRecord
            
            if(ObjMultiRecord.isVideo)
            {
                
            }
            else
            {
                
                let image:UIImage =  ObjMultiRecord.Thumbnail
                print(image)
                let Pathextension:String = "JPEG"
                if(self.isgroup == true)
                {
                    ObjMultiRecord.assetname = "\(User_chat_id)-g-\(timestamp).\(Pathextension.lowercased())"
                }
                else
                {
                    ObjMultiRecord.assetname = "\(User_chat_id)-\(timestamp).\(Pathextension.lowercased())"
                }
                let isVid = ObjMultiRecord.isVideo
                ObjMultiRecord.timestamp = timestamp
                ObjMultiRecord.userCommonID = User_chat_id
                ObjMultiRecord.assetpathname = url
                print(ObjMultiRecord.assetpathname)
                ObjMultiRecord.toID = isFromStatus ? "" : oppenentID
                ObjMultiRecord.isVideo = isVid
                ObjMultiRecord.StartTime = 0.0
                ObjMultiRecord.Endtime = 0.0
                ObjMultiRecord.Thumbnail = image
                
                
                var rawData = image.pngData()
                
                if(Pathextension == "PNG")
                {
                    
                    ObjMultiRecord.rawData = image.pngData()
                }
                else
                {
                    ObjMultiRecord.rawData = image.jpegData(compressionQuality: 0.5)
                    
                }
                
                print("total Image size in original size KB:\(Double((rawData?.count)!) / 1024.0) compressed size KB:\(Double((ObjMultiRecord.rawData.count)) / 1024.0)")
                
                ObjMultiRecord.CompresssedData = image.jpegData(compressionQuality: 0.1)
//                    UIImageJPEGRepresentation(image, 0.1)! as Data
                ObjMultiRecord.Base64Str = Themes.sharedInstance.convertImageToBase64(imageData:ObjMultiRecord.CompresssedData)
                completionHandler(ObjMultiRecord)
            }
        }
    }
    func ReturnAssetvalue(asset:DKAsset,from:String,to:String,
                          User_chat_id:String,url:NSString,timestamp:String ,isFromStatus: Bool, completionHandler:   @escaping (_ AssetArr: MultimediaRecord, _ error:NSError? ) -> ()?)
        
    {
        var url = url
        let ObjMultiRecord:MultimediaRecord = MultimediaRecord()
        let options: PHVideoRequestOptions = PHVideoRequestOptions()
        options.version = .original
        asset.fetchAVAsset(options, completeBlock: { [weak self] (_asset, _: [AnyHashable : Any]?) in
            
            if let urlAsset = _asset as? AVURLAsset {
                
                var timestamp:String =  String(Date().ticks)
                var servertimeStr:String = Themes.sharedInstance.getServerTime()
                
                if(servertimeStr == "")
                {
                    servertimeStr = "0"
                }
                let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
                timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"

                let Temppath:String = NSTemporaryDirectory().appending("\(timestamp).mp4")
                
                let videoURL = NSURL(string: urlAsset.url.absoluteString)
                let AVasset:AVAsset =  AVURLAsset(url: videoURL! as URL)
                let compatiblePresets:NSArray = AVAssetExportSession.exportPresets(compatibleWith: AVasset) as NSArray
                if(compatiblePresets.contains(AVAssetExportPresetMediumQuality))
                {
                    let exportSession = AVAssetExportSession(asset: AVasset, presetName: AVAssetExportPresetMediumQuality)
                    let TempURl = NSURL(fileURLWithPath: Temppath)
                    exportSession?.outputURL = TempURl as URL?
                    exportSession?.outputFileType = AVFileType.mp4
                    
                    exportSession?.exportAsynchronously(completionHandler: {
                        
                        switch exportSession?.status
                            
                        {
                        case  .failed?:
                            break;
                        case .cancelled?:
                            
                            break;
                        default:
                            
                            DispatchQueue.main.async {
                                
                                print(exportSession?.status as Any)
                                do
                                {
                                    let data = try Data(contentsOf: (exportSession?.outputURL)!, options: .mappedIfSafe)
                                    
                                    url = urlAsset.url.absoluteString  as NSString
                                    print("the ur is \(url)")
                                    
                                    
                                    var time_stamp:String = String(Date().ticks)
                                    time_stamp =  timestamp
                                    
                                    //                let Pathextension:String = "\(url.pathExtension)"
                                    if(self?.isgroup == true)
                                    {
                                        ObjMultiRecord.assetname = "\(User_chat_id)-g-\(time_stamp).mp4"
                                    }
                                    else
                                    {
                                        ObjMultiRecord.assetname = "\(User_chat_id)-\(time_stamp).mp4"
                                    }
                                    ObjMultiRecord.timestamp = time_stamp
                                    ObjMultiRecord.FromID = from
                                    ObjMultiRecord.toID = to
                                    ObjMultiRecord.userCommonID = User_chat_id
                                    ObjMultiRecord.assetpathname! = url as String
                                    ObjMultiRecord.isVideo = asset.isVideo
                                    if(ObjMultiRecord.isVideo)
                                    {
                                        ObjMultiRecord.Thumbnail = self?.getThumnail(videoURL: urlAsset)
                                    }
                                    else
                                    {
                                        ObjMultiRecord.Thumbnail = nil
                                    }
                                    
                                    ObjMultiRecord.rawDataPath =  urlAsset.url
                                    
                                    if(ObjMultiRecord.Thumbnail != nil)
                                    {
                                        ObjMultiRecord.VideoThumbnail = ObjMultiRecord.Thumbnail.jpegData(compressionQuality: 1.0)
                                        ObjMultiRecord.CompresssedData = ObjMultiRecord.Thumbnail.jpegData(compressionQuality: 0.3)
                                        ObjMultiRecord.Base64Str = Themes.sharedInstance.convertImageToBase64(imageData:ObjMultiRecord.CompresssedData)
                                        
                                    }
                                    ObjMultiRecord.StartTime = 0.0
                                    ObjMultiRecord.FileSize = Float(data.count/1024/1024)
                                    print(ObjMultiRecord.FileSize)
                                    ObjMultiRecord.totalDuration = urlAsset.duration.seconds
                                    if(ObjMultiRecord.FileSize > Constant.sharedinstance.UploadSize)
                                    {
                                        let Percentage:Int = Int((Constant.sharedinstance.UploadSize/ObjMultiRecord.FileSize)*Float(100.0))
                                        let Time_Value:Float = Float(Float(Percentage
                                            )*Float(ObjMultiRecord.totalDuration)/100.0)
                                        
                                        ObjMultiRecord.Endtime = Double(Time_Value)
                                        print(ObjMultiRecord.Endtime)
                                        ObjMultiRecord.isVideotrimmed = true
                                    }
                                    else
                                    {
                                        ObjMultiRecord.Endtime = urlAsset.duration.seconds
                                        ObjMultiRecord.isVideotrimmed = false
                                    }
                                    completionHandler(ObjMultiRecord,nil)
                                }
                                catch{
                                    print(error.localizedDescription)
                                }
                            }
                        }
                    })
                }
                
            }
            
        })
        
    }
    
    func getThumnail(videoURL:AVAsset)->UIImage
    {
        let assetImgGenerate = AVAssetImageGenerator(asset: videoURL)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(Float64(1.5), preferredTimescale: 100)
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            return thumbnail
        } catch {
            return UIImage(named: "VideoThumbnail")!
        }
    }
    
}


