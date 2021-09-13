//
//  AssetHandler.swift

//
//  Created by Casp iOS on 10/04/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit
import Photos

class AssetHandler: NSObject {
    static let sharedInstance = AssetHandler()
    var isgroup:Bool = Bool()
    var AssetArr = [MultimediaRecord]()
    var showAssetArr = [MultimediaRecord]()
    var totalAssets = Int()
    func ProcessAsset(assets: [[String : Any]],
                      Persons : [[String : Any]],
                      completionHandler: @escaping (_ AssetArr: [MultimediaRecord], _ showAssetArr: [MultimediaRecord], _ error:NSError?) -> ()) {
        
        AssetArr = [MultimediaRecord]()
        showAssetArr = [MultimediaRecord]()
        totalAssets = assets.count * Persons.count
        if(assets.count > 0)
        {
            for i in 0..<assets.count
            {
                DispatchQueue.main.async {
                    
                    var timestamp:String = String(Date().ticks)
                    var servertimeStr:String = Themes.sharedInstance.getServerTime()
                    
                    if(servertimeStr == "")
                    {
                        servertimeStr = "0"
                    }
                    let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
                    timestamp =  "\((timestamp as NSString).longLongValue + Int64(i) - serverTimestamp)"
                    let asset = assets[i]
                    let isVideo = Themes.sharedInstance.CheckNullvalue(Passed_value: asset["type"]) == "2" ? true : false
                    let url = asset["url"]
                    if(isVideo)
                    {
                        let url = url as! URL
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                            var tempPersons = Persons
                            let person = tempPersons[0]
                            let personID = Themes.sharedInstance.CheckNullvalue(Passed_value: person["id"])
                            let chat_type = Themes.sharedInstance.CheckNullvalue(Passed_value: person["type"])
                            let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
                            let to:String=Themes.sharedInstance.CheckNullvalue(Passed_value: personID)
                            let User_chat_id="\(from)-\(to)";
                            self.ReturnAssetvalue(asset: url, from: from, to: to, User_chat_id: User_chat_id, timestamp: timestamp, type : chat_type, completionHandler: { (ObjMultiRecord, error) in
                                if(error == nil)
                                {
                                    self.AssetArr.append(ObjMultiRecord)
                                    let isContain = self.showAssetArr.filter{$0.assetpathname == url.absoluteString}
                                    if(isContain.count == 0)
                                    {
                                        self.showAssetArr.append(ObjMultiRecord)
                                    }
                                    tempPersons.remove(at: 0)
                                    _ = tempPersons.map {
                                        let ObjRecord: MultimediaRecord = MultimediaRecord()
                                        let personID = Themes.sharedInstance.CheckNullvalue(Passed_value: $0["id"])
                                        let chat_type = Themes.sharedInstance.CheckNullvalue(Passed_value: $0["type"])
                                        let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
                                        let to:String=Themes.sharedInstance.CheckNullvalue(Passed_value: personID)
                                        let User_chat_id="\(from)-\(to)";
                                        
                                        ObjRecord.type = chat_type
                                        if(chat_type == "group")
                                        {
                                            ObjRecord.assetname = "\(User_chat_id)-g-\(timestamp).mp4"
                                        }
                                        else
                                        {
                                            ObjRecord.assetname = "\(User_chat_id)-\(timestamp).mp4"
                                        }
                                        ObjRecord.timestamp = timestamp
                                        ObjRecord.FromID = from
                                        ObjRecord.toID = to
                                        ObjRecord.userCommonID = User_chat_id
                                        ObjRecord.assetpathname = ObjMultiRecord.assetpathname
                                        ObjRecord.isVideo = ObjMultiRecord.isVideo
                                        ObjRecord.Thumbnail = ObjMultiRecord.Thumbnail
                                        ObjRecord.rawDataPath =  ObjMultiRecord.rawDataPath
                                        ObjRecord.VideoThumbnail = ObjMultiRecord.VideoThumbnail
                                        ObjRecord.CompresssedData = ObjMultiRecord.CompresssedData
                                        ObjRecord.Base64Str = ObjMultiRecord.Base64Str
                                        ObjRecord.StartTime = ObjMultiRecord.StartTime
                                        ObjRecord.FileSize = ObjMultiRecord.FileSize
                                        ObjRecord.totalDuration = ObjMultiRecord.totalDuration
                                        ObjRecord.Endtime = ObjMultiRecord.Endtime
                                        ObjRecord.isVideotrimmed = ObjMultiRecord.isVideotrimmed
                                        self.AssetArr.append(ObjRecord)
                                    }
                                    if(self.AssetArr.count == self.totalAssets)
                                    {
                                        completionHandler(self.AssetArr, self.showAssetArr, nil)
                                    }
                                }
                            })
                        })
                    }
                    else
                    {
                        var tempPersons = Persons
                        let ObjMultiRecord:MultimediaRecord = MultimediaRecord()
                        let person = tempPersons[0]
                        let personID = Themes.sharedInstance.CheckNullvalue(Passed_value: person["id"])
                        let chat_type = Themes.sharedInstance.CheckNullvalue(Passed_value: person["type"])
                        let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
                        let to:String=Themes.sharedInstance.CheckNullvalue(Passed_value: personID)
                        ObjMultiRecord.type = chat_type
                        let User_chat_id="\(from)-\(to)";
                        self.getImageFromURL(url, completion: { (image) in
                            if var image = image {
                                image = image.fixOrientation()
                                
                                let Pathextension:String = "JPEG"
                                if(chat_type == "group")
                                {
                                    ObjMultiRecord.assetname = "\(User_chat_id)-g-\(timestamp).\(Pathextension.lowercased())"
                                }
                                else
                                {
                                    ObjMultiRecord.assetname = "\(User_chat_id)-\(timestamp).\(Pathextension.lowercased())"
                                }
                                ObjMultiRecord.timestamp = timestamp
                                ObjMultiRecord.userCommonID = User_chat_id
                                if let url = url as? URL {
                                    ObjMultiRecord.assetpathname = url.absoluteString
                                }
                                else if url is UIImage {
                                    ObjMultiRecord.assetpathname = ""
                                }
                                ObjMultiRecord.toID = to
                                ObjMultiRecord.isVideo = isVideo
                                ObjMultiRecord.StartTime = 0.0
                                ObjMultiRecord.Endtime = 0.0
                                ObjMultiRecord.Thumbnail = image
                                
                                if(Pathextension == "PNG")
                                {
                                    
                                    ObjMultiRecord.rawData = image.pngData()
                                    
                                }
                                else
                                {
                                    ObjMultiRecord.rawData = image.jpegData(compressionQuality: 0.5)
                                    
                                }
                                
                                ObjMultiRecord.CompresssedData = image.jpegData(compressionQuality: 0.1)
                                ObjMultiRecord.Base64Str = Themes.sharedInstance.convertImageToBase64(imageData:ObjMultiRecord.CompresssedData)
                                self.AssetArr.append(ObjMultiRecord)
                                if let url = url as? URL {
                                    let isContain = self.showAssetArr.filter{$0.assetpathname == url.absoluteString}
                                    if(isContain.count == 0) {
                                        self.showAssetArr.append(ObjMultiRecord)
                                    }
                                }
                                else if url is UIImage {
                                    self.showAssetArr.append(ObjMultiRecord)
                                }
                                
                                tempPersons.remove(at: 0)
                                _ = tempPersons.map {
                                    let ObjRecord : MultimediaRecord = MultimediaRecord()
                                    let personID = Themes.sharedInstance.CheckNullvalue(Passed_value: $0["id"])
                                    let chat_type = Themes.sharedInstance.CheckNullvalue(Passed_value: $0["type"])
                                    let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
                                    let to:String=Themes.sharedInstance.CheckNullvalue(Passed_value: personID)
                                    ObjRecord.type = chat_type
                                    let User_chat_id="\(from)-\(to)";
                                    
                                    let Pathextension:String = "JPEG"
                                    if(chat_type == "group")
                                    {
                                        ObjRecord.assetname = "\(User_chat_id)-g-\(timestamp).\(Pathextension.lowercased())"
                                    }
                                    else
                                    {
                                        ObjRecord.assetname = "\(User_chat_id)-\(timestamp).\(Pathextension.lowercased())"
                                    }
                                    ObjRecord.timestamp = timestamp
                                    ObjRecord.userCommonID = User_chat_id
                                    ObjRecord.assetpathname = ObjMultiRecord.assetpathname
                                    ObjRecord.toID = to
                                    ObjRecord.isVideo = ObjMultiRecord.isVideo
                                    ObjRecord.StartTime = ObjMultiRecord.StartTime
                                    ObjRecord.Endtime = ObjMultiRecord.Endtime
                                    ObjRecord.Thumbnail = ObjMultiRecord.Thumbnail
                                    ObjRecord.rawData = ObjMultiRecord.rawData
                                    ObjRecord.CompresssedData = ObjMultiRecord.CompresssedData
                                    ObjRecord.Base64Str = ObjMultiRecord.Base64Str
                                    self.AssetArr.append(ObjRecord)
                                }
                                if(self.AssetArr.count == self.totalAssets)
                                {
                                    completionHandler(self.AssetArr, self.showAssetArr, nil)
                                }
                            }
                        })
                    }
                }
            }
        }
    }
    
    func ReturnAssetvalue(asset:Any?,
                          from:String,
                          to:String,
                          User_chat_id:String,
                          timestamp:String,
                          type : String,
                          completionHandler:   @escaping (_ AssetArr: MultimediaRecord, _ error:NSError? ) -> ()) {
        
        guard let asset = asset as? URL else {return}
        
        let ObjMultiRecord:MultimediaRecord = MultimediaRecord()
        ObjMultiRecord.type = type
        let urlAsset = AVURLAsset(url: asset)
        
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
                        
                        do
                        {
                            let data = try Data(contentsOf: (exportSession?.outputURL)!, options: .mappedIfSafe)
                            
                            //                let Pathextension:String = "\(url.pathExtension)"
                            if(type == "group")
                            {
                                ObjMultiRecord.assetname = "\(User_chat_id)-g-\(timestamp).mp4"
                            }
                            else
                            {
                                ObjMultiRecord.assetname = "\(User_chat_id)-\(timestamp).mp4"
                            }
                            ObjMultiRecord.timestamp = timestamp
                            ObjMultiRecord.FromID = from
                            ObjMultiRecord.toID = to
                            ObjMultiRecord.userCommonID = User_chat_id
                            ObjMultiRecord.assetpathname = asset.absoluteString
                            ObjMultiRecord.isVideo = true
                            if(ObjMultiRecord.isVideo)
                            {
                                ObjMultiRecord.Thumbnail = self.getThumnail(videoURL: urlAsset)
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
                            ObjMultiRecord.totalDuration = urlAsset.duration.seconds
                            if(ObjMultiRecord.FileSize > Constant.sharedinstance.UploadSize)
                            {
                                let Percentage:Int = Int((Constant.sharedinstance.UploadSize/ObjMultiRecord.FileSize)*Float(100.0))
                                let Time_Value:Float = Float(Float(Percentage
                                    )*Float(ObjMultiRecord.totalDuration)/100.0)
                                
                                ObjMultiRecord.Endtime = Double(Time_Value)
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
    
    func getImageFromURL(_ url : Any?, completion: @escaping(_ image : UIImage?) -> ()) {
        DispatchQueue.main.async {
            do {
                var image = UIImage()
                if let url = url as? URL {
                    let data = try Data(contentsOf: url)
                    image = UIImage(data: data)!
                }
                else if let url = url as? UIImage {
                    image = url
                }
                completion(image)
            }
            catch {
                print(error.localizedDescription)
                completion(nil)
            }
        }
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





