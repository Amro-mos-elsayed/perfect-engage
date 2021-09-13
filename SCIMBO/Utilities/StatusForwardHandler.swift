//
//  StatusForwardHandler.swift
//
//
//  Created by Casperon iOS on 04/09/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

typealias StatusCompletionCallback = (_ success: Bool, _ sentcount: Int, _ personcount: Int) -> ()
class StatusForwardHandler : NSObject
{
    var index:Int = Int()
    var personindex:Int = Int()
    static let sharedInstance = StatusForwardHandler()
    var DoneCallback: StatusCompletionCallback?;
    var isFromStatus : Bool = Bool()
    func forward(messageArr : [AnyObject], toPersons : [AnyObject], completion: StatusCompletionCallback!)
    {
        DoneCallback = completion
        for i in 0..<toPersons.count
        {
            personindex = i + 1;
            for j in 0..<messageArr.count
            {
                index = j + 1
                let messageDetail : UUMessageFrame  = messageArr[j] as! UUMessageFrame
                let user : NSDictionary = toPersons[i] as! NSDictionary
                if messageDetail.message.message_type as String  == "0"
                {
                    self.text_forward(message: messageDetail, person: user, type: user.value(forKey: "type") as! String)
                }
                else if messageDetail.message.message_type as String  == "1"
                {
                    self.picture_forward(message: messageDetail, person: user, type: user.value(forKey: "type") as! String)
                }
                else if messageDetail.message.message_type as String  == "2"
                {
                    self.video_forward(message: messageDetail, person: user, type: user.value(forKey: "type") as! String)
                }
                else if messageDetail.message.message_type as String  == "3"
                {
                    self.audio_forward(message: messageDetail, person: user, type: user.value(forKey: "type") as! String)
                }
                else if messageDetail.message.message_type as String  == "4"
                {
                    self.link_forward(message: messageDetail, person: user, type: user.value(forKey: "type") as! String)
                }
                else if messageDetail.message.message_type as String  == "5"
                {
                    self.contact_forward(message: messageDetail, person: user, type: user.value(forKey: "type") as! String)
                }
                else if messageDetail.message.message_type as String == "6"
                {
                    self.document_forward(message: messageDetail, person: user, type: user.value(forKey: "type") as! String)
                }
                else if messageDetail.message.message_type as String == "20"
                {
                    self.document_forward(message: messageDetail, person: user, type: user.value(forKey: "type") as! String)
                }
                else if messageDetail.message.message_type as String == "7"
                {
                    self.text_forward(message: messageDetail, person: user, type: user.value(forKey: "type") as! String)
                }
                else if messageDetail.message.message_type as String == "14"
                {
                    self.location_forward(message: messageDetail, person: user, type: user.value(forKey: "type") as! String)
                }
            }
        }
    }
    
    func text_forward(message : UUMessageFrame, person : NSDictionary, type : String)
    {
        let payload : String = message.message.payload
        let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
        let to:String=Themes.sharedInstance.CheckNullvalue(Passed_value: person["id"])
        
        var timestamp:String = String(Date().ticks)
        var servertimeStr:String = Themes.sharedInstance.getServerTime()
        
        if(servertimeStr == "")
        {
            servertimeStr = "0"
        }
        let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
        timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
        
        
        let Name:String=Themes.sharedInstance.setNameTxt(Themes.sharedInstance.Getuser_id(), "")
        let Phonenumber:String=Themes.sharedInstance.setPhoneTxt(Themes.sharedInstance.Getuser_id())
        var toDocId:String="\(from)-\(to)-\(timestamp)"
        
        if(type == "group")
        {
            toDocId = "\(from)-\(to)-g-\(timestamp)"
        }
        var dic:[AnyHashable: Any]
        
        dic = ["type": "0","convId":"","doc_id":Themes.sharedInstance.CheckNullvalue(Passed_value:toDocId
            ),"filesize":"","from":Themes.sharedInstance.CheckNullvalue(Passed_value:from
            ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:to
            ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
            ),"message_status":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
            ),"id":timestamp,"name":Themes.sharedInstance.CheckNullvalue(Passed_value:Name
            ),"payload":Themes.sharedInstance.CheckNullvalue(Passed_value:payload
            ),"recordId":"","timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
            ),"thumbnail":"","width":"0.0","height":"0.0","msgId":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
            ),"contactmsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value:Phonenumber
            ),"user_common_id":Themes.sharedInstance.CheckNullvalue(Passed_value:from + "-" + to
            ),"message_from":"1","chat_type":type,"info_type":"0","created_by":from,"is_reply":"0", "date" : Themes.sharedInstance.getTimeStamp()]
        DatabaseHandler.sharedInstance.InserttoDatabase(Dict: dic as NSDictionary,Entityname: Constant.sharedinstance.Chat_one_one)

        let chatarray:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: from + "-" + to)
        if(!chatarray)
        {
            let User_dict:[AnyHashable: Any] = ["user_common_id": from + "-" + to,"user_to_dp":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_type":"single","is_archived":"0","conv_id":"","timestamp":timestamp,"opponent_id":to,"is_read":"0","chat_count":"0"]
            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: User_dict as NSDictionary,Entityname: Constant.sharedinstance.Chat_intiated_details)
        }
        else
        {
            let User_dict:[AnyHashable: Any]=["timestamp":timestamp,"is_archived":"0","is_read":"0"]
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: from + "-" + to , attribute: "user_common_id", UpdationElements: User_dict as NSDictionary?)
        }
        
        if(type == "single")
        {
            SocketIOManager.sharedInstance.SendMessage(from: Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id()), to: to, payload: payload, type: "0", timestamp: timestamp, DocID:toDocId,thumbnail: "",thumbnail_data: "",filesize: "",height: "0",width: "0",doc_name:"",numPages: "", duration: "", is_secret_chat: "No")
        }
        else  if(type == "group")
        {
            let Groupdic:[AnyHashable: Any] = ["from":Themes.sharedInstance.Getuser_id(),"to":to,"type":"0","payload":EncryptionHandler.sharedInstance.encryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value:payload.decoded), toid:to, chat_type: type),"convId":to,"toDocId":EncryptionHandler.sharedInstance.encryptmessage(str:toDocId,toid:to, chat_type: type),"groupType":"9","userName":Themes.sharedInstance.CheckNullvalue(Passed_value: person["name"]),"id":EncryptionHandler.sharedInstance.encryptmessage(str:Themes.sharedInstance.CheckNullvalue(Passed_value: timestamp),toid:to, chat_type: type), "is_tag_applied" : ""]
            SocketIOManager.sharedInstance.SendMessage_group(param: Groupdic as NSDictionary)
        }
        DoneCallback!(true, index, personindex)
    }
    
    func picture_forward(message : UUMessageFrame, person : NSDictionary, type : String)
    {
        let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
        let to:String=Themes.sharedInstance.CheckNullvalue(Passed_value: person["id"])
        
        let ImageDetailArr =  DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Status_Upload_Details, attribute: "upload_data_id", FetchString: "\(message.message.thumbnail!)" , SortDescriptor: nil) as! NSArray
        if ImageDetailArr.count > 0
        {
            
            let ImageDetailDict:NSManagedObject = ImageDetailArr[0] as! NSManagedObject
            let ObjMultiMedia:MultimediaRecord = self.returnMultiMediaRecordforPicture(picture_message: ImageDetailDict, from: from, to: to,type:type) as MultimediaRecord
            
            let Path:String =  Filemanager.sharedinstance.SaveImageFile(imagePath: "\(Constant.sharedinstance.photopath)/\(ObjMultiMedia.assetname)",imagedata: ObjMultiMedia.rawData)
            ObjMultiMedia.PathId = ObjMultiMedia.assetname
            ObjMultiMedia.assetpathname = Path
            var timestamp:String = String(Date().ticks)
            var servertimeStr:String = Themes.sharedInstance.getServerTime()
            
            if(servertimeStr == "")
            {
                servertimeStr = "0"
            }
            let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
            timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
            
            var splitcount:Int = ObjMultiMedia.rawData.count / Constant.sharedinstance.SendbyteCount
            if(splitcount < 1)
            {
                splitcount = 1
            }
            let uploadDataCount:String = UploadHandler.Sharedinstance.getArrayOfBytesFromImage(ObjMultiMedia.rawData,splitCount: splitcount)
            let imagecount:Int = ObjMultiMedia.rawData.count
            let Dict:[String:Any] = ["failure_status":"0","total_byte_count":"\(imagecount)","upload_byte_count":"0","upload_count":"1","upload_data_id":ObjMultiMedia.PathId,"upload_Path":"\(ObjMultiMedia.assetpathname!)","upload_status":"0","user_common_id":"\(ObjMultiMedia.userCommonID)","serverpath":"","user_id":Themes.sharedInstance.Getuser_id(),"data_count":uploadDataCount,"compressed_data":ObjMultiMedia.Base64Str,"to_id":"\(ObjMultiMedia.toID)","message_status":"0","timestamp":timestamp,"total_data_count":"\(splitcount)","width":"\(ObjMultiMedia.Thumbnail.size.width)","height":"\(ObjMultiMedia.Thumbnail.size.height)","upload_type":"1","download_status":"2","is_uploaded":"1", "upload_paused" : "0"]
            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict as NSDictionary, Entityname: Constant.sharedinstance.Upload_Details);
            print("the dict is >>>> \(Dict)")
            self.picture_upload(ObjMultiMedia: ObjMultiMedia, person: person, type: type)
        }
    }
    
    func picture_upload(ObjMultiMedia : MultimediaRecord, person: NSDictionary, type: String)
    {
        
        let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
        let to:String=Themes.sharedInstance.CheckNullvalue(Passed_value: person["id"])
        
        var timestamp:String = String(Date().ticks)
        var servertimeStr:String = Themes.sharedInstance.getServerTime()
        
        if(servertimeStr == "")
        {
            servertimeStr = "0"
        }
        let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
        timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
        
        
        let Name:String=Themes.sharedInstance.setNameTxt(Themes.sharedInstance.Getuser_id(), "")
        let Phonenumber:String=Themes.sharedInstance.setPhoneTxt(Themes.sharedInstance.Getuser_id())
        var toDocId:String="\(from)-\(to)-\(ObjMultiMedia.timestamp)"
        if(type == "group")
        {
            toDocId = "\(from)-\(to)-g-\(ObjMultiMedia.timestamp)"
        }
        
        let dic:[AnyHashable: Any] = ["type": "1","convId":"","doc_id":Themes.sharedInstance.CheckNullvalue(Passed_value:toDocId
            ),"filesize":"","from":Themes.sharedInstance.CheckNullvalue(Passed_value:from
            ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:to
            ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
            ),"message_status":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
            ),"id":ObjMultiMedia.timestamp,"name":Themes.sharedInstance.CheckNullvalue(Passed_value:Name
            ),"payload":"","recordId":"","timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
            ),"thumbnail":ObjMultiMedia.PathId,"width":"0.0","height":"0.0","msgId":Themes.sharedInstance.CheckNullvalue(Passed_value:ObjMultiMedia.timestamp
            ),"contactmsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value:Phonenumber
            ),"user_common_id":Themes.sharedInstance.CheckNullvalue(Passed_value:from + "-" + to
            ),"message_from":"1","chat_type":type,"info_type":"0","created_by":from,"is_reply":"0", "date" : Themes.sharedInstance.getTimeStamp()]
        
        DatabaseHandler.sharedInstance.InserttoDatabase(Dict: dic as NSDictionary,Entityname: Constant.sharedinstance.Chat_one_one)

        let chatarray:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: from + "-" + to)
        print(dic)
        
        if(!chatarray)
        {
            let User_dict:[AnyHashable: Any] = ["user_common_id": from + "-" + to,"user_to_dp":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_type":"single","is_archived":"0","conv_id":"","timestamp":timestamp,"opponent_id":to,"chat_count":"0"]
            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: User_dict as NSDictionary,Entityname: Constant.sharedinstance.Chat_intiated_details)
        }
        else
            
        {
            let User_dict:[AnyHashable: Any]=["timestamp":timestamp,"is_archived":"0","is_read":"0","chat_count":"0"]
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: from + "-" + to , attribute: "user_common_id", UpdationElements: User_dict as NSDictionary?)
        }
        
        
        
        UploadHandler.Sharedinstance.handleUpload()
        DoneCallback!(true, index, personindex)
    }
    
    func returnMultiMediaRecordforPicture(picture_message : NSManagedObject, from: String, to: String,type:String) -> MultimediaRecord
    {
        let ObjMultiRecord = MultimediaRecord()
        let User_chat_id=from + "-" + to;
        var timestamp:String = String(Date().ticks)
        var servertimeStr:String = Themes.sharedInstance.getServerTime()
        if(servertimeStr == "")
        {
            servertimeStr = "0"
        }
        let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
        timestamp =  "\(((timestamp as NSString).longLongValue) + Int64(1) - serverTimestamp)"
        ObjMultiRecord.userCommonID = User_chat_id
        ObjMultiRecord.assetpathname = Themes.sharedInstance.CheckNullvalue(Passed_value: picture_message.value(forKey: "upload_Path"))
        let path:NSString = picture_message.value(forKey: "upload_Path") as! NSString
        ObjMultiRecord.assetname = "\(User_chat_id)-\(timestamp).\(String(describing: (path.pathExtension)))"
        if(type == "group")
        {
            ObjMultiRecord.assetname = "\(User_chat_id)-\(timestamp)-\(index).\(String(describing: (path.pathExtension)))"
            
        }
        ObjMultiRecord.toID = to
        ObjMultiRecord.StartTime = 0.0
        ObjMultiRecord.Endtime = 0.0
        ObjMultiRecord.timestamp = timestamp
        let documentDirectory = CommondocumentDirectory()
        do {
            ObjMultiRecord.rawData = try Data(contentsOf: documentDirectory.appendingPathComponent(ObjMultiRecord.assetpathname))
        } catch {
            print("Unable to load data: \(error)")
        }
        ObjMultiRecord.Base64Str = picture_message.value(forKey: "compressed_data") as! String
        return ObjMultiRecord
    }
    
    func video_forward(message: UUMessageFrame, person: NSDictionary, type: String)
    {
        
        let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
        let to:String=Themes.sharedInstance.CheckNullvalue(Passed_value: person["id"])
        
        let videoDetailArr =  DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Status_Upload_Details, attribute: "upload_data_id", FetchString: "\(message.message.thumbnail!)" , SortDescriptor: nil) as! NSArray
        if videoDetailArr.count > 0
        {
            
            let videoDetailDict:NSManagedObject = videoDetailArr[0] as! NSManagedObject
            let ObjMultiMedia:MultimediaRecord = self.returnMultiMediaRecordforVideo(video_message: videoDetailDict, from: from, to: to, type: type) as MultimediaRecord
            
            self.ExportAsset(ObjMultiMedia: ObjMultiMedia, person: person, type: type)
            
        }
    }
    
    func returnMultiMediaRecordforVideo(video_message: NSManagedObject, from: String, to: String, type: String) -> MultimediaRecord {
        
        
        let ObjMultiRecord:MultimediaRecord = MultimediaRecord()
        let User_chat_id=from + "-" + to;
        var timestamp:String = String(Date().ticks)
        var servertimeStr:String = Themes.sharedInstance.getServerTime()
        
        if(servertimeStr == "")
        {
            servertimeStr = "0"
        }
        let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
        timestamp =  "\((timestamp as NSString).longLongValue + Int64(index) - serverTimestamp)"
        ObjMultiRecord.timestamp = timestamp
        ObjMultiRecord.assetname = "\(User_chat_id)-\(timestamp).mp4"
        if(type == "group")
        {
            ObjMultiRecord.assetname = "\(User_chat_id)-g-\(timestamp).mp4"
            
        }
        ObjMultiRecord.FromID = from
        ObjMultiRecord.toID = to
        ObjMultiRecord.userCommonID = User_chat_id
        ObjMultiRecord.assetpathname =  Themes.sharedInstance.CheckNullvalue(Passed_value: video_message.value(forKey: "upload_Path"))
        ObjMultiRecord.isVideo = true
        
        let documentDirectory = CommondocumentDirectory()
        let url = documentDirectory.appendingPathComponent(ObjMultiRecord.assetpathname)

        ObjMultiRecord.Thumbnail = self.getThumnail(videoURL: url)
        
        
        ObjMultiRecord.rawDataPath = url
        
        if(ObjMultiRecord.Thumbnail != nil)
        {
            ObjMultiRecord.VideoThumbnail = ObjMultiRecord.Thumbnail.jpegData(compressionQuality: 1.0)
            ObjMultiRecord.CompresssedData = ObjMultiRecord.Thumbnail.jpegData(compressionQuality: 0.1)
            ObjMultiRecord.Base64Str = Themes.sharedInstance.convertImageToBase64(imageData:ObjMultiRecord.CompresssedData)
            
        }
        let videoAsset = AVAsset(url: url)
        
        ObjMultiRecord.StartTime = 0.0
        ObjMultiRecord.FileSize = videoAsset.calculateFileSize()/1024/1024
        print(ObjMultiRecord.FileSize)
        ObjMultiRecord.totalDuration = videoAsset.duration.seconds
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
            ObjMultiRecord.Endtime = videoAsset.duration.seconds
            ObjMultiRecord.isVideotrimmed = false
        }
        
        return ObjMultiRecord
        
    }
    
    func getThumnail(videoURL:URL)->UIImage
    {
        let videoAsset = AVAsset(url: videoURL)
        let assetImgGenerate = AVAssetImageGenerator(asset: videoAsset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(Float64(1), preferredTimescale: 100)
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            return thumbnail
        } catch {
            return UIImage(named: "VideoThumbnail")!
        }
        
    }
    
    func ExportAsset(ObjMultiMedia: MultimediaRecord, person: NSDictionary, type: String)
    {
        FileManager.default.clearTmpDirectory()
        var timestamp:String = String(Date().ticks)
        var servertimeStr:String = Themes.sharedInstance.getServerTime()
        
        if(servertimeStr == "")
        {
            servertimeStr = "0"
        }
        let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
        timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
        
        let Temppath:String = NSTemporaryDirectory().appending("\(timestamp).mp4")
        if(ObjMultiMedia.isVideo)
        {
            let documentDirectory = CommondocumentDirectory()
            let videoURL = documentDirectory.appendingPathComponent(ObjMultiMedia.assetpathname)

            let AVasset:AVAsset =  AVURLAsset(url: videoURL)
            let compatiblePresets:NSArray = AVAssetExportSession.exportPresets(compatibleWith: AVasset) as NSArray
            if(compatiblePresets.contains(AVAssetExportPresetMediumQuality))
            {
                var exportSession: AVAssetExportSession!
                
                exportSession = AVAssetExportSession(asset: AVasset, presetName: AVAssetExportPresetMediumQuality)
                let TempURl = NSURL(fileURLWithPath: Temppath)
                exportSession.outputURL = TempURl as URL?
                exportSession.outputFileType = AVFileType.mp4
                //                    let start: CMTime = CMTimeMakeWithSeconds(ObjMultiMedia.StartTime, AVasset.duration.timescale)
                //                    let duration: CMTime = CMTimeMakeWithSeconds(ObjMultiMedia.Endtime - ObjMultiMedia.StartTime, AVasset.duration.timescale)
                //                    let length = Float(AVasset.duration.value)
                let startTime = CMTime(seconds: Double(ObjMultiMedia.StartTime ), preferredTimescale: 1000)
                let endTime = CMTime(seconds: Double(Float(ObjMultiMedia.Endtime) ), preferredTimescale: 1000)
                
                
                let range:CMTimeRange = CMTimeRangeMake(start: startTime, duration: endTime)
                
                exportSession.timeRange = range
                exportSession?.exportAsynchronously(completionHandler: {
                    
                    switch exportSession!.status
                        
                    {
                    case  .failed:
                        print("failed \(String(describing: exportSession?.error))")
                        break;
                    case .cancelled:
                        print("cancelled \(String(describing: exportSession?.error))")
                        break;
                    default:
                        
                        DispatchQueue.main.async {
                            
                            print(exportSession?.status as Any)
                            do
                            {
                                print("\(String(describing: exportSession?.outputURL))......\(Temppath)")
                                let data = try Data(contentsOf: (exportSession?.outputURL)!, options: .mappedIfSafe)
                                ObjMultiMedia.rawData = data
                            }
                            catch{
                                print(error.localizedDescription)
                            }
                            var timestamp:String = String(Date().ticks)
                            var servertimeStr:String = Themes.sharedInstance.getServerTime()
                            if(servertimeStr == "")
                            {
                                servertimeStr = "0"
                            }
                            let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
                            timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
                            let Path:String =  Filemanager.sharedinstance.SaveImageFile( imagePath: "\(Constant.sharedinstance.videopathpath)/\(ObjMultiMedia.assetname)",imagedata: ObjMultiMedia.rawData)
                            ObjMultiMedia.PathId = ObjMultiMedia.assetname
                            ObjMultiMedia.assetpathname = Path
                            var splitcount:Int = ObjMultiMedia.rawData.count / Constant.sharedinstance.SendbyteCount
                            if(splitcount < 1)
                            {
                                splitcount = 1
                            }
                            
                            let uploadDataCount:String = UploadHandler.Sharedinstance.getArrayOfBytesFromImage(ObjMultiMedia.rawData,splitCount: splitcount)
                            let imagecount:Int = ObjMultiMedia.rawData.count
                            let Dict:[String:Any] = ["failure_status":"0","total_byte_count":"\(imagecount)","upload_byte_count":"0","upload_count":"1","upload_data_id":ObjMultiMedia.PathId,"upload_Path":"\(ObjMultiMedia.assetpathname!)","upload_status":"0","user_common_id":"\(ObjMultiMedia.userCommonID)","serverpath":"","user_id":Themes.sharedInstance.Getuser_id(),"data_count":uploadDataCount,"compressed_data":ObjMultiMedia.Base64Str,"to_id":"\(ObjMultiMedia.toID)","message_status":"0","timestamp":timestamp,"total_data_count":"\(splitcount)","width":"\(ObjMultiMedia.Thumbnail.size.width)","height":"\(ObjMultiMedia.Thumbnail.size.height)","upload_type":"2","video_thumbnail":ObjMultiMedia.VideoThumbnail,"download_status":"2","is_uploaded":"1", "upload_paused" : "0"]
                            
                            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict as NSDictionary, Entityname: Constant.sharedinstance.Upload_Details);
                            
                            self.video_upload(ObjMultiMedia: ObjMultiMedia, person: person, type: type)
                        }
                        break;
                    }
                })
            }
        }
    }
    
    func video_upload(ObjMultiMedia : MultimediaRecord, person: NSDictionary, type: String){
        let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
        let to:String=Themes.sharedInstance.CheckNullvalue(Passed_value: person["id"])
        var timestamp:String = String(Date().ticks)
        var servertimeStr:String = Themes.sharedInstance.getServerTime()
        
        if(servertimeStr == "")
        {
            servertimeStr = "0"
        }
        let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
        timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
        let Name:String=Themes.sharedInstance.setNameTxt(Themes.sharedInstance.Getuser_id(), "")
        let Phonenumber:String=Themes.sharedInstance.setPhoneTxt(Themes.sharedInstance.Getuser_id())
        var toDocId:String="\(from)-\(to)-\(ObjMultiMedia.timestamp)"
        if(type == "group")
        {
            toDocId = "\(from)-\(to)-g-\(ObjMultiMedia.timestamp)"
        }
        let dic:[AnyHashable: Any] = ["type": "2","convId":"","doc_id":Themes.sharedInstance.CheckNullvalue(Passed_value:toDocId
            ),"filesize":"","from":Themes.sharedInstance.CheckNullvalue(Passed_value:from
            ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:to
            ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
            ),"message_status":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
            ),"id":ObjMultiMedia.timestamp,"name":Themes.sharedInstance.CheckNullvalue(Passed_value:Name
            ),"payload":"","recordId":"","timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
            ),"thumbnail":ObjMultiMedia.PathId,"width":"0.0","height":"0.0","msgId":ObjMultiMedia.timestamp,"contactmsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value:Phonenumber
            ),"user_common_id":Themes.sharedInstance.CheckNullvalue(Passed_value:from + "-" + to
            ),"message_from":"1","chat_type":type,"info_type":"0","created_by":from,"is_reply":"0", "date" : Themes.sharedInstance.getTimeStamp()]
        
        DatabaseHandler.sharedInstance.InserttoDatabase(Dict: dic as NSDictionary,Entityname: Constant.sharedinstance.Chat_one_one)

        let chatarray:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: from + "-" + to)
        print(dic)
        
        if(!chatarray)
        {
            let User_dict:[AnyHashable: Any] = ["user_common_id": from + "-" + to,"user_to_dp":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_type":"single","is_archived":"0","conv_id":"","timestamp":timestamp,"opponent_id":to,"chat_count":"0"]
            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: User_dict as NSDictionary,Entityname: Constant.sharedinstance.Chat_intiated_details)
        }
        else
            
        {
            let User_dict:[AnyHashable: Any]=["timestamp":timestamp,"is_archived":"0","is_read":"0","chat_count":"0"]
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: from + "-" + to , attribute: "user_common_id", UpdationElements: User_dict as NSDictionary?)
        }
        
        UploadHandler.Sharedinstance.handleUpload()
        DoneCallback!(true, index, personindex)
    }
    
    func link_forward(message: UUMessageFrame, person: NSDictionary, type: String)
    {
        let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
        let to:String=Themes.sharedInstance.CheckNullvalue(Passed_value: person["id"])
        var timestamp:String = String(Date().ticks)
        var servertimeStr:String = Themes.sharedInstance.getServerTime()
        
        if(servertimeStr == "")
        {
            servertimeStr = "0"
        }
        let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
        timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
        
        let Name:String=Themes.sharedInstance.setNameTxt(Themes.sharedInstance.Getuser_id(), "")
        let Phonenumber:String=Themes.sharedInstance.setPhoneTxt(Themes.sharedInstance.Getuser_id())
        var toDocId:String="\(from)-\(to)-\(timestamp)"
        if(type == "group")
        {
            toDocId = "\(from)-\(to)-g-\(timestamp)"
        }
        let payload:String = message.message.payload
        
        var dic:[AnyHashable: Any]
        
        let LinkDetailArr : NSArray =  DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Link_details, attribute: "doc_id", FetchString: "\(message.message.doc_id!)", SortDescriptor: nil) as! NSArray
        
        var Title_str : String = String()
        var ImageURl : String = String()
        var Desc : String = String()
        var Url_str : String = String()
        
        if(LinkDetailArr.count > 0)
        {
            let LinkDetailDict:NSManagedObject = LinkDetailArr[0] as! NSManagedObject
            Title_str = LinkDetailDict.value(forKey: "title") as! String
            ImageURl = LinkDetailDict.value(forKey: "image_url") as! String
            Desc = LinkDetailDict.value(forKey: "desc") as! String
            Url_str = LinkDetailDict.value(forKey: "url_str") as! String
        }
        
        dic = ["type": "4","convId":"","doc_id":Themes.sharedInstance.CheckNullvalue(Passed_value:toDocId
            ),"filesize":"","from":Themes.sharedInstance.CheckNullvalue(Passed_value:from
            ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:to
            ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
            ),"message_status":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
            ),"id":timestamp,"name":Themes.sharedInstance.CheckNullvalue(Passed_value:Name
            ),"payload":Themes.sharedInstance.CheckNullvalue(Passed_value:payload
            ),"recordId":"","timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
            ),"thumbnail":"","width":"0.0","height":"0.0","msgId":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
            ),"contactmsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value:Phonenumber
            ),"user_common_id":Themes.sharedInstance.CheckNullvalue(Passed_value:from + "-" + to
            ),"message_from":"1","chat_type":type,"info_type":"0","created_by":from,"title":Themes.sharedInstance.CheckNullvalue(Passed_value: Title_str),"image_url":Themes.sharedInstance.CheckNullvalue(Passed_value: ImageURl),"desc":Themes.sharedInstance.CheckNullvalue(Passed_value: Desc),"url_str":Themes.sharedInstance.CheckNullvalue(Passed_value: Url_str), "date" : Themes.sharedInstance.getTimeStamp()]
        DatabaseHandler.sharedInstance.InserttoDatabase(Dict: dic as NSDictionary,Entityname: Constant.sharedinstance.Chat_one_one)

        let link_dic:[AnyHashable: Any] = ["doc_id":Themes.sharedInstance.CheckNullvalue(Passed_value:toDocId
            ),"title":Themes.sharedInstance.CheckNullvalue(Passed_value: Title_str),"thumbnail_data":Themes.sharedInstance.CheckNullvalue(Passed_value: ImageURl),"image_url":Themes.sharedInstance.CheckNullvalue(Passed_value: ImageURl),"desc":Themes.sharedInstance.CheckNullvalue(Passed_value: Desc),"url_str":Themes.sharedInstance.CheckNullvalue(Passed_value: Url_str)]
        DatabaseHandler.sharedInstance.InserttoDatabase(Dict: link_dic as NSDictionary,Entityname: Constant.sharedinstance.Link_details)
        let chatarray:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: from + "-" + to)
        if(!chatarray)
        {
            let User_dict:[AnyHashable: Any] = ["user_common_id": from + "-" + to,"user_to_dp":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_type":type,"is_archived":"0","conv_id":"","timestamp":timestamp,"opponent_id":to,"is_read":"0","chat_count":"0"]
            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: User_dict as NSDictionary,Entityname: Constant.sharedinstance.Chat_intiated_details)
        }
        else
        {
            let User_dict:[AnyHashable: Any]=["timestamp":timestamp,"is_archived":"0","is_read":"0"]
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: from + "-" + to , attribute: "user_common_id", UpdationElements: User_dict as NSDictionary?)
        }
        
        if(type == "single")
        {
            
            let metadict:NSDictionary = ["title":Themes.sharedInstance.CheckNullvalue(Passed_value: Title_str),"url_str":Themes.sharedInstance.CheckNullvalue(Passed_value: Url_str),"desc":Themes.sharedInstance.CheckNullvalue(Passed_value:Desc).decoded,"image_url":Themes.sharedInstance.CheckNullvalue(Passed_value:ImageURl),"thumbnail_data":""]
            let Dict:Dictionary = ["from":Themes.sharedInstance.Getuser_id(),"to":to,"payload":EncryptionHandler.sharedInstance.encryptmessage(str: payload.decoded,toid:to, chat_type: type),"id":EncryptionHandler.sharedInstance.encryptmessage(str: timestamp,toid:to, chat_type: type),"type":"4","toDocId":EncryptionHandler.sharedInstance.encryptmessage(str: toDocId,toid:to, chat_type: type),"metaDetails":metadict] as [String : Any]

            SocketIOManager.sharedInstance.EmitMessage(param: Dict)
        }
        else  if(type == "group")
        {
            let metadict:NSDictionary = ["title":Themes.sharedInstance.CheckNullvalue(Passed_value: Title_str),"url_str":Themes.sharedInstance.CheckNullvalue(Passed_value: Url_str),"desc":Themes.sharedInstance.CheckNullvalue(Passed_value:Desc).decoded,"image_url":Themes.sharedInstance.CheckNullvalue(Passed_value:ImageURl),"thumbnail_data":""]
            
            let displayName = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Group_details, attrib_name: "id", fetchString: to, returnStr: "displayName")
            
            let Dict:Dictionary = ["from":Themes.sharedInstance.Getuser_id(),"to":to,"payload":EncryptionHandler.sharedInstance.encryptmessage(str: payload.decoded,toid:to, chat_type: type), "id":EncryptionHandler.sharedInstance.encryptmessage(str: timestamp,toid:to, chat_type: type),"type":"4","toDocId":EncryptionHandler.sharedInstance.encryptmessage(str: toDocId,toid:to, chat_type: type),"metaDetails":metadict,"groupType":"9","userName":displayName,"convId":to] as [String : Any]
            
            SocketIOManager.sharedInstance.Groupevent(param: Dict)
        }
        DoneCallback!(true, index, personindex)
    }
    func contact_forward(message: UUMessageFrame, person: NSDictionary, type: String)
    {
        let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
        let to:String=Themes.sharedInstance.CheckNullvalue(Passed_value: person["id"])
        var timestamp:String = String(Date().ticks)
        var servertimeStr:String = Themes.sharedInstance.getServerTime()
        
        if(servertimeStr == "")
        {
            servertimeStr = "0"
        }
        let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
        timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
        
        
        let Name:String=Themes.sharedInstance.setNameTxt(Themes.sharedInstance.Getuser_id(), "")
        let Phonenumber:String=Themes.sharedInstance.setPhoneTxt(Themes.sharedInstance.Getuser_id())
        var toDocId:String="\(from)-\(to)-\(timestamp)"
        if(type == "group")
        {
            toDocId = "\(from)-\(to)-g-\(timestamp)"
        }
        var dic:[AnyHashable: Any]!
        
        dic = ["type": "5","convId":"","doc_id":Themes.sharedInstance.CheckNullvalue(Passed_value:toDocId
            ),"filesize":"","from":Themes.sharedInstance.CheckNullvalue(Passed_value:from
            ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:to
            ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
            ),"message_status":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
            ),"id":timestamp,"name":Themes.sharedInstance.CheckNullvalue(Passed_value:Name
            ),"payload":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(message.message.contact_name!)"),"recordId":"","timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp),"thumbnail":"","width":"0.0","height":"0.0","msgId":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
            ),"contactmsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value:Phonenumber
            ),"user_common_id":Themes.sharedInstance.CheckNullvalue(Passed_value:from + "-" + to
            ),"message_from":"1","chat_type":type,"info_type":"0","created_by":from,"contact_profile":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(message.message.contact_profile!)"),"contact_phone":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(message.message.contact_phone!)"),"contact_id":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(message.message.contact_id!)"),"contact_name":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(message.message.contact_name!)"),"contact_details":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(message.message.contact_details!)"), "date" : Themes.sharedInstance.getTimeStamp()]
        //addRefreshViews()
        DatabaseHandler.sharedInstance.InserttoDatabase(Dict: dic as NSDictionary,Entityname: Constant.sharedinstance.Chat_one_one)

        let contact_dic:[AnyHashable: Any] = ["doc_id":Themes.sharedInstance.CheckNullvalue(Passed_value:toDocId
            ),"contact_profile":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(message.message.contact_profile!)"),"contact_phone":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(message.message.contact_phone!)"),"contact_id":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(message.message.contact_id!)"),"contact_name":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(message.message.contact_name!)"),"contact_details":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(message.message.contact_details!)")]
        
        DatabaseHandler.sharedInstance.InserttoDatabase(Dict: contact_dic as NSDictionary,Entityname: Constant.sharedinstance.Contact_details)
        
        let chatarray:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: from + "-" + to)
        if(!chatarray)
        {
            let User_dict:[AnyHashable: Any] = ["user_common_id": from + "-" + to,"user_to_dp":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_type":type,"is_archived":"0","conv_id":"","timestamp":timestamp,"opponent_id":to,"is_read":"0","chat_count":"0"]
            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: User_dict as NSDictionary,Entityname: Constant.sharedinstance.Chat_intiated_details)
            
        }
        else
        {
            let User_dict:[AnyHashable: Any]=["timestamp":timestamp,"is_archived":"0","is_read":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_count":"0"]
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: from + "-" + to , attribute: "user_common_id", UpdationElements: User_dict as NSDictionary?)
        }
        
        let details:NSMutableDictionary = ["contact_profile":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(message.message.contact_profile!)"),"contact_phone":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(message.message.contact_phone!)"),"id":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(message.message.contact_id!)"),"contactDetails":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(message.message.contact_details!)")]
        
        if(type == "single")
        {
            //createdTomsisdn = phonenumber
            //contact_name = id
            
            if let json = try?JSONSerialization.data(withJSONObject: details, options: []) {
                // here `json` is your JSON data
                if let content = String(data: json, encoding: String.Encoding.utf8) {
                    // here `content` is the JSON data decoded as a String
                    print(content)
                    
                    if(type == "single"){
                        let Dict:Dictionary = ["from":Themes.sharedInstance.Getuser_id(),"to":to,"payload":"","id":EncryptionHandler.sharedInstance.encryptmessage(str: timestamp,toid:to, chat_type: type),"type":"5","toDocId":EncryptionHandler.sharedInstance.encryptmessage(str: toDocId,toid:to, chat_type: type),"contact_name":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(message.message.contact_name!)"),"createdTomsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(message.message.contact_phone!)"),"contactDetails":EncryptionHandler.sharedInstance.encryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value:"\(message.message.contact_details!)"),toid:to, chat_type: type), "createdTo":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(message.message.contact_id!)")] as [String : Any]

                        SocketIOManager.sharedInstance.EmitMessage(param: Dict)
                    }
                }
            }
        }
        else
        {
            let displayName = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Group_details, attrib_name: "id", fetchString: to, returnStr: "displayName")
            
            if let json = try?JSONSerialization.data(withJSONObject: details, options: []) {
                // here `json` is your JSON data
                if let content = String(data: json, encoding: String.Encoding.utf8) {
                    // here `content` is the JSON data decoded as a String
                    print(content)
                    let Dict:Dictionary = ["from":Themes.sharedInstance.Getuser_id(),"to":to,"payload":"","id":EncryptionHandler.sharedInstance.encryptmessage(str: timestamp,toid:to, chat_type: type),"type":"5","toDocId":EncryptionHandler.sharedInstance.encryptmessage(str: toDocId,toid:to, chat_type: type),"contact_name":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(message.message.contact_name!)"),"createdTomsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(message.message.contact_phone!)"),"contactDetails":EncryptionHandler.sharedInstance.encryptmessage(str: Themes.sharedInstance.CheckNullvalue(Passed_value:"\(message.message.contact_details!)"),toid:to, chat_type: type),"groupType":"9","userName":displayName,"convId":to,"createdTo":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(message.message.contact_id!)")] as [String : Any]
                    SocketIOManager.sharedInstance.Groupevent(param: Dict)
                }
            }
            
        }
        DoneCallback!(true, index, personindex)
    }
    
    func audio_forward(message: UUMessageFrame, person: NSDictionary, type: String)
    {
        var voice = Data()
        var audioAsset : AVAsset?
        let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
        let to:String=Themes.sharedInstance.CheckNullvalue(Passed_value: person["id"])
        var timestamp:String = String(Date().ticks)
        var servertimeStr:String = Themes.sharedInstance.getServerTime()
        
        if(servertimeStr == "")
        {
            servertimeStr = "0"
        }
        let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
        timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
        
        let AudioDetailArr =  DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Status_Upload_Details, attribute: "upload_data_id", FetchString: "\(message.message.thumbnail!)" , SortDescriptor: nil) as! NSArray
        if(AudioDetailArr.count > 0)
        {
            let AudioDetailDict:NSManagedObject = AudioDetailArr[0] as! NSManagedObject
            let audiopath : String = AudioDetailDict.value(forKey: "upload_Path") as! String
            let documentDirectory = CommondocumentDirectory()
            let url = documentDirectory.appendingPathComponent(audiopath)

            do {
                voice = try Data(contentsOf: url)
            } catch {
                print("Unable to load data: \(error)")
            }
            
            audioAsset = AVAsset(url: url)
        }
        let InfoDict:NSDictionary = self.SaveAudioFile(voice: voice,seconds: Int(audioAsset!.duration.seconds), person: person,type: type)
        let PathName:String = InfoDict.object(forKey: "id") as! String
        let messageid:String = InfoDict.object(forKey: "timestamp") as! String
        
        let Name:String=Themes.sharedInstance.setNameTxt(Themes.sharedInstance.Getuser_id(), "")
        let Phonenumber:String=Themes.sharedInstance.setPhoneTxt(Themes.sharedInstance.Getuser_id())
        var toDocId:String="\(from)-\(to)-\(messageid)"
        if(type == "group")
        {
            toDocId = "\(from)-\(to)-g-\(messageid)"
        }
        let dic:[AnyHashable: Any] = ["type": "3","convId":"","doc_id":Themes.sharedInstance.CheckNullvalue(Passed_value:toDocId
            ),"filesize":"","from":Themes.sharedInstance.CheckNullvalue(Passed_value:from
            ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:to
            ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
            ),"message_status":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
            ),"id":"\(messageid)","name":Themes.sharedInstance.CheckNullvalue(Passed_value:Name
            ),"payload":"Audio","recordId":"","timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
            ),"thumbnail":PathName,"width":"0.0","height":"0.0","msgId":messageid,"contactmsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value:Phonenumber
            ),"user_common_id":Themes.sharedInstance.CheckNullvalue(Passed_value:from + "-" + to
            ),"message_from":"1","chat_type":type,"info_type":"0","created_by":from,"is_reply":"0", "date" : Themes.sharedInstance.getTimeStamp()]
        
        DatabaseHandler.sharedInstance.InserttoDatabase(Dict: dic as NSDictionary,Entityname: Constant.sharedinstance.Chat_one_one)

        let chatarray:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: from + "-" + to)
        print(dic)
        
        if(!chatarray)
        {
            let User_dict:[AnyHashable: Any] = ["user_common_id": from + "-" + to,"user_to_dp":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_type":"single","is_archived":"0","conv_id":"","timestamp":timestamp,"opponent_id":to,"is_read":"0","chat_count":"0"]
            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: User_dict as NSDictionary,Entityname: Constant.sharedinstance.Chat_intiated_details)
        }
        else
        {
            let User_dict:[AnyHashable: Any]=["timestamp":timestamp,"is_archived":"0","is_read":"0","chat_count":"0"]
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: from + "-" + to , attribute: "user_common_id", UpdationElements: User_dict as NSDictionary?)
        }
        
        
        UploadHandler.Sharedinstance.handleUpload()
        DoneCallback!(true, index, personindex)
    }
    
    func SaveAudioFile(voice: Data,seconds:Int,person:NSDictionary,type: String)->NSDictionary
    {
        let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
        let to:String=Themes.sharedInstance.CheckNullvalue(Passed_value: person["id"])
        var timestamp:String = String(Date().ticks)
        var servertimeStr:String = Themes.sharedInstance.getServerTime()
        
        if(servertimeStr == "")
        {
            servertimeStr = "0"
        }
        let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
        timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
        
        
        let User_chat_id=from + "-" + to;
        var AssetName:String = "\(User_chat_id)-\(timestamp).mp3"
        if(type == "group")
        {
            AssetName = "\(User_chat_id)-g-\(timestamp).mp3"
        }
        let Path:String =  Filemanager.sharedinstance.SaveImageFile(imagePath: "\(Constant.sharedinstance.voicepath)/\(AssetName)",imagedata: voice)
        
        var splitcount:Int = voice.count / Constant.sharedinstance.SendbyteCount
        if(splitcount < 1)
        {
            splitcount = 1
        }
        let uploadDataCount:String = UploadHandler.Sharedinstance.getArrayOfBytesFromImage(voice, splitCount: splitcount)
        let imagecount:Int = voice.count
        let Dict:[String:Any] = ["failure_status":"0","total_byte_count":"\(imagecount)","upload_byte_count":"0","upload_count":"1","upload_data_id":AssetName,"upload_Path":Path,"upload_status":"0","user_common_id":User_chat_id,"serverpath":"","user_id":Themes.sharedInstance.Getuser_id(),"data_count":uploadDataCount,"compressed_data":"","to_id":to,"message_status":"0","timestamp":timestamp,"total_data_count":"\(splitcount)","width":"0.0","height":"0.0","upload_type":"3","download_status":"2","strVoiceTime":"\(seconds)","is_uploaded":"1", "upload_paused" : "0"]
        DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict as NSDictionary, Entityname: Constant.sharedinstance.Upload_Details);
        let param:NSDictionary = ["id":AssetName,"pathname":Path,"timestamp":timestamp]
        return param
    }
    
    func document_forward(message: UUMessageFrame, person: NSDictionary, type: String)
    {
        
        let DocumentDetailArr =  DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Upload_Details, attribute: "upload_data_id", FetchString: "\(message.message.thumbnail!)" , SortDescriptor: nil) as! NSArray
        var url = NSURL()
        
        if(DocumentDetailArr.count > 0)
        {
            let DocumentDetailDict:NSManagedObject = DocumentDetailArr[0] as! NSManagedObject
            let filepath : String = DocumentDetailDict.value(forKey: "upload_Path") as! String
            let documentDirectory = CommondocumentDirectory()
            url = documentDirectory.appendingPathComponent(filepath) as NSURL
        }
        let cico : URL = url as URL
        print("The Url is : \(cico)")
        let objRecord:DocumentRecord = DocumentRecord()
        let Pathextension:String = cico.pathExtension
        if(Pathextension.uppercased() == "PDF")
        {
            let document: CGPDFDocument? = CGPDFDocument(url as CFURL)
            
            let pageCount: size_t = document!.numberOfPages
            objRecord.docPageCount = "\(pageCount)"
            objRecord.docType = "1"
            objRecord.docImage =  self.buildThumbnailImage(document: document!)!
            objRecord.docPath = cico
            objRecord.path_extension = Pathextension.lowercased()
            objRecord.docName = cico.lastPathComponent.lowercased()
        }
        else
        {
            objRecord.docPageCount = ""
            objRecord.docType = "2"
            objRecord.docImage =  #imageLiteral(resourceName: "docicon")
            objRecord.docPath = cico
            objRecord.path_extension = Pathextension.lowercased()
            objRecord.docName = cico.lastPathComponent.lowercased()
        }
        
        let Dict:NSDictionary = self.SaveDoc(objRecord: objRecord, person: person, type: type)
        
        if(Dict.count > 0)
        {
            let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
            let to:String=Themes.sharedInstance.CheckNullvalue(Passed_value: person["id"])
            var timestamp:String = String(Date().ticks)
            var servertimeStr:String = Themes.sharedInstance.getServerTime()
            
            if(servertimeStr == "")
            {
                servertimeStr = "0"
            }
            let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
            timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
            let msgID:String = Dict.object(forKey: "timestamp") as! String
            
            
            let PathName:String = Dict.object(forKey: "id") as! String
            let Name:String=Themes.sharedInstance.setNameTxt(Themes.sharedInstance.Getuser_id(), "")
            let Phonenumber:String=Themes.sharedInstance.setPhoneTxt(Themes.sharedInstance.Getuser_id())
            var toDocId:String="\(from)-\(to)-\(msgID)"
            if(type == "group")
            {
                toDocId = "\(from)-\(to)-g-\(msgID)"
            }
            let dic:[AnyHashable: Any] = ["type": "6","convId":"","doc_id":Themes.sharedInstance.CheckNullvalue(Passed_value:toDocId
                ),"filesize":"","from":Themes.sharedInstance.CheckNullvalue(Passed_value:from
                ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:to
                ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
                ),"message_status":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
                ),"id":"\(msgID)","name":Themes.sharedInstance.CheckNullvalue(Passed_value:Name
                ),"payload":"Document","recordId":"","timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
                ),"thumbnail":PathName,"width":"0.0","height":"0.0","msgId":Themes.sharedInstance.CheckNullvalue(Passed_value:"\(msgID)"
                ),"contactmsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value:Phonenumber
                ),"user_common_id":Themes.sharedInstance.CheckNullvalue(Passed_value:from + "-" + to
                ),"message_from":"1","chat_type":type,"info_type":"0","created_by":from,"docType":objRecord.docType,"docName":objRecord.docName,"docPageCount":objRecord.docPageCount,"is_reply":"0", "date" : Themes.sharedInstance.getTimeStamp()]
            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: dic as NSDictionary,Entityname: Constant.sharedinstance.Chat_one_one)

            let chatarray:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: from + "-" + to)
            print(dic)
            
            if(!chatarray)
            {
                
                let User_dict:[AnyHashable: Any] = ["user_common_id": from + "-" + to,"user_to_dp":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_type":"single","is_archived":"0","conv_id":"","timestamp":timestamp,"opponent_id":to,"chat_count":"0"]
                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: User_dict as NSDictionary,Entityname: Constant.sharedinstance.Chat_intiated_details)
            }
            else
                
            {
                let User_dict:[AnyHashable: Any]=["timestamp":timestamp,"is_archived":"0","is_read":"0","chat_count":"0"]
                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: from + "-" + to , attribute: "user_common_id", UpdationElements: User_dict as NSDictionary?)
            }
        }
        UploadHandler.Sharedinstance.handleUpload()
        DoneCallback!(true, index, personindex)
    }
    
    func buildThumbnailImage(document:CGPDFDocument) -> UIImage? {
        guard let page = document.page(at: 1) else { return nil }
        let pageRect = page.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        let img:UIImage? = renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(pageRect)
            ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height);
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0);
            ctx.cgContext.drawPDFPage(page);
        }
        if(img == nil)
        {
            return nil
        }
        return img
    }
    
    func SaveDoc(objRecord:DocumentRecord, person: NSDictionary,type:String)->NSDictionary
    {
        
        let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
        let to:String=Themes.sharedInstance.CheckNullvalue(Passed_value: person["id"])
        var timestamp:String = String(Date().ticks)
        var servertimeStr:String = Themes.sharedInstance.getServerTime()
        
        if(servertimeStr == "")
        {
            servertimeStr = "0"
        }
        let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
        timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
        
        
        let User_chat_id=from + "-" + to;
        var AssetName:String = "\(User_chat_id)-\(timestamp).\(objRecord.path_extension)"
        if(type == "group")
        {
            AssetName = "\(User_chat_id)-g-\(timestamp).\(objRecord.path_extension)"
        }
        var CompressedImage:String = String()
        if(objRecord.docImage != nil)
        {
            let data : Data = objRecord.docImage.pngData() ?? Data()
            CompressedImage = Themes.sharedInstance.convertImageToBase64(imageData:data)
        }
        else
            
        {
            CompressedImage = ""
        }
        
        do
        {
            let Docdata:NSData = try NSData(contentsOf: objRecord.docPath)
            let Path:String =  Filemanager.sharedinstance.SaveImageFile(imagePath: "\(Constant.sharedinstance.docpath)/\(AssetName)",imagedata: Docdata as Data)
            
            var splitcount:Int = Docdata.length / Constant.sharedinstance.SendbyteCount
            if(splitcount < 1)
            {
                splitcount = 1
            }
            
            let uploadDataCount:String = UploadHandler.Sharedinstance.getArrayOfBytesFromImage(Docdata as Data, splitCount: splitcount)
            let imagecount:Int = Docdata.length
            let Dict:[String:Any] = ["failure_status":"0","total_byte_count":"\(imagecount)","upload_byte_count":"0","upload_count":"1","upload_data_id":AssetName,"upload_Path":Path,"upload_status":"0","user_common_id":User_chat_id,"serverpath":"","user_id":Themes.sharedInstance.Getuser_id(),"data_count":uploadDataCount,"compressed_data":"\(CompressedImage)","to_id":to,"message_status":"0","timestamp":timestamp,"total_data_count":"\(splitcount)","width":"0.0","height":"0.0","upload_type":"6","download_status":"0","doc_name":objRecord.docName,"doc_type":objRecord.docType,"doc_pagecount":objRecord.docPageCount,"is_uploaded":"1", "upload_paused" : "0"]
            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict as NSDictionary, Entityname: Constant.sharedinstance.Upload_Details);
            let param:NSDictionary = ["id":AssetName,"pathname":Path,"timestamp":timestamp]
            return param
        }
        catch
        {
            print(error)
            return [:]
        }
    }
    func location_forward(message : UUMessageFrame, person : NSDictionary, type : String)
    {
        let from:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.Getuser_id())
        let to:String=Themes.sharedInstance.CheckNullvalue(Passed_value: person["id"])
        var timestamp:String = String(Date().ticks)
        var servertimeStr:String = Themes.sharedInstance.getServerTime()
        
        if(servertimeStr == "")
        {
            servertimeStr = "0"
        }
        let serverTimestamp:Int64 = (servertimeStr as NSString).longLongValue
        timestamp =  "\((timestamp as NSString).longLongValue - serverTimestamp)"
        
        
        let Name:String=Themes.sharedInstance.setNameTxt(Themes.sharedInstance.Getuser_id(), "")
        let Phonenumber:String=Themes.sharedInstance.setPhoneTxt(Themes.sharedInstance.Getuser_id())
        var toDocId:String="\(from)-\(to)-\(timestamp)"
        if(type == "group")
        {
            toDocId = "\(from)-\(to)-g-\(timestamp)"
        }
        
        let LocationtDetailArr =  DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Location_details, attribute: "doc_id", FetchString: "\(message.message.doc_id!)" , SortDescriptor: nil) as! NSArray
        
        var imagelink : String = String()
        var address : String = String()
        var display : String = String()
        var title : String = String()
        var stitle : String = String()
        var latitude : String = String()
        var longitude : String = String()
        if(LocationtDetailArr.count > 0)
        {
            let LocationDetailDict:NSManagedObject = LocationtDetailArr[0] as! NSManagedObject
            imagelink = LocationDetailDict.value(forKey: "image_link") as! String
            title = LocationDetailDict.value(forKey: "title") as! String
            stitle = LocationDetailDict.value(forKey: "stitle") as! String
            latitude = LocationDetailDict.value(forKey: "lat") as! String
            longitude = LocationDetailDict.value(forKey: "long") as! String
            address = "\(title),\(stitle)"
            display = title
        }
        
        let DBDict:NSDictionary = ["type": "14","convId":"","doc_id":Themes.sharedInstance.CheckNullvalue(Passed_value:toDocId
            ),"filesize":"","from":Themes.sharedInstance.CheckNullvalue(Passed_value:from
            ),"to":Themes.sharedInstance.CheckNullvalue(Passed_value:to
            ),"isStar":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
            ),"message_status":Themes.sharedInstance.CheckNullvalue(Passed_value:"0"
            ),"id":timestamp,"name":Themes.sharedInstance.CheckNullvalue(Passed_value:Name
            ),"payload":Themes.sharedInstance.CheckNullvalue(Passed_value:address
            ),"recordId":"","timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
            ),"thumbnail":"","width":"0.0","height":"0.0","msgId":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp
            ),"contactmsisdn":Themes.sharedInstance.CheckNullvalue(Passed_value:Phonenumber
            ),"user_common_id":Themes.sharedInstance.CheckNullvalue(Passed_value:from + "-" + to
            ),"message_from":"1","chat_type":type,"info_type":"0","created_by":from, "date" : Themes.sharedInstance.getTimeStamp()]
        DatabaseHandler.sharedInstance.InserttoDatabase(Dict: DBDict as NSDictionary,Entityname: Constant.sharedinstance.Chat_one_one)

        let chatarray:Bool =  DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_intiated_details, attribute: "user_common_id", FetchString: from + "-" + to)
        if(!chatarray)
        {
            let User_dict:[AnyHashable: Any] = ["user_common_id": from + "-" + to,"user_to_dp":"0","user_id":Themes.sharedInstance.Getuser_id(),"chat_type":type,"is_archived":"0","conv_id":"","timestamp":timestamp,"opponent_id":to,"is_read":"0","chat_count":"0"]
            DatabaseHandler.sharedInstance.InserttoDatabase(Dict: User_dict as NSDictionary,Entityname: Constant.sharedinstance.Chat_intiated_details)
        }
        else
        {
            let User_dict:[AnyHashable: Any]=["timestamp":timestamp,"is_archived":"0","is_read":"0"]
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_intiated_details, FetchString: from + "-" + to , attribute: "user_common_id", UpdationElements: User_dict as NSDictionary?)
        }
        
        let RedirectLink:String = "https://maps.google.com/maps?q=\(latitude),\(longitude)&amp;z=15&amp;hl=en"
        let LocationDIct:NSDictionary = ["doc_id":toDocId,"image_link":imagelink,"lat":"\(latitude)","long":"\(longitude)","redirect_link":RedirectLink,"thumbnail_data":"","title":Themes.sharedInstance.CheckNullvalue(Passed_value: display),"stitle":Themes.sharedInstance.CheckNullvalue(Passed_value:stitle)]
        DatabaseHandler.sharedInstance.InserttoDatabase(Dict: LocationDIct as NSDictionary,Entityname: Constant.sharedinstance.Location_details)
        
        SDWebImageManager.shared().imageDownloader?.downloadImage(with: URL(string:imagelink), options: .highPriority, progress: nil, completed: { (image:UIImage?, data:Data?, erro:Error?, downloaded:Bool) in
            if(image != nil)
            {
                
                let MapimageData:Data = image!.jpegData(compressionQuality: 1.0)!
                let base64str:String = Themes.sharedInstance.convertImageToBase64(imageData:MapimageData)
                
                let metadict:NSDictionary = ["title":Themes.sharedInstance.CheckNullvalue(Passed_value: display),"url":RedirectLink,"description":Themes.sharedInstance.CheckNullvalue(Passed_value:stitle),"image":imagelink,"thumbnail_data":base64str]
                
                if(type == "single")
                {
                    let Dict:Dictionary = ["from":Themes.sharedInstance.Getuser_id(),"to":to,"payload":EncryptionHandler.sharedInstance.encryptmessage(str: "\(latitude),\(longitude)",toid:to, chat_type: type),"id":EncryptionHandler.sharedInstance.encryptmessage(str: timestamp,toid:to, chat_type: type),"type":"14","toDocId":EncryptionHandler.sharedInstance.encryptmessage(str: toDocId,toid:to, chat_type: type),"metaDetails":metadict] as [String : Any]
                    SocketIOManager.sharedInstance.EmitMessage(param: Dict)
                }
                else
                {
                    let displayName = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Group_details, attrib_name: "id", fetchString: to, returnStr: "displayName")
                    let Dict:Dictionary = ["from":Themes.sharedInstance.Getuser_id(),"to":to,"payload":EncryptionHandler.sharedInstance.encryptmessage(str: "\(latitude),\(longitude)",toid:to, chat_type: type),"id":EncryptionHandler.sharedInstance.encryptmessage(str: timestamp,toid:to, chat_type: type),"type":"14","toDocId":EncryptionHandler.sharedInstance.encryptmessage(str: toDocId,toid:to, chat_type: type),"metaDetails":metadict,"groupType":"9","userName":displayName,"convId":to] as [String : Any]
                    SocketIOManager.sharedInstance.Groupevent(param: Dict)
                }
                self.DoneCallback!(true, self.index, self.personindex)
            }
        })
    }
    
}

