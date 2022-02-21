//
//  StatusUploadHandler.swift

//
//  Created by Casp iOS on 05/04/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit
import SDWebImage
import ACPDownload
import MMMaterialDesignSpinner

class StatusUploadHandler: NSObject {
    static let Sharedinstance = StatusUploadHandler()
    var startTime: CFAbsoluteTime!
    var stopTime: CFAbsoluteTime!
    var bytesReceived: Int!
    
    var spinnerView : MMMaterialDesignSpinner {
        let spinnerView = MMMaterialDesignSpinner(frame: CGRect(x: 2.5, y: 2.5, width: 55, height: 55))
        spinnerView.lineWidth = 2.5;
        spinnerView.tintColor = UIColor(red: 90/255, green: 88/255, blue: 85/255, alpha: 1.0);
        spinnerView.startAnimating()
        return spinnerView
    }
    
    var spinner:UIView {
        let spinner = UIView.init(frame: CGRect.zero)
        spinner.backgroundColor = UIColor(red: 242/255, green: 241/255, blue: 237/255, alpha: 1.0);
        spinner.layer.masksToBounds = true
        spinner.layer.cornerRadius = 30
        spinner.addSubview(spinnerView)
        spinner.tag = 100
        return spinner
    }
    
    func getArrayOfBytesFromImage(_ imageData:Data,splitCount:Int)->String
    {
        var ConstantTotalByteCount:Int!
        let count = imageData.count / MemoryLayout<UInt8>.size
        ConstantTotalByteCount = count/splitCount
        return String(ConstantTotalByteCount)
    }
    
    func ReturnImageByteArr(_ imageData:Data)->NSMutableArray {
        let byteArray:NSMutableArray = NSMutableArray()
        
        let count = imageData.count / MemoryLayout<UInt8>.size
        var bytes = [UInt8](repeating: 0, count: count)
        (imageData as NSData).getBytes(&bytes, length:count * MemoryLayout<UInt8>.size)
        for i in 0 ..< count
        {
            byteArray.add(NSNumber(value: bytes[i]))
        }
        
        
        
        return byteArray
        
        
    }
    
    func Received(Status: String, imagename: String, responseDict: NSDictionary)
    {
        DispatchQueue.main.sync {
            
            if(Status != "CHECK")
            {
                if(responseDict.count > 0)
                {
                    var upload_byte_count = Themes.sharedInstance.CheckNullvalue(Passed_value: responseDict.object(forKey: "speed"))
                    
                    let bufferAt:NSString = Themes.sharedInstance.CheckNullvalue(Passed_value: responseDict.object(forKey: "bufferAt")) as NSString
                    let image_id:NSString = Themes.sharedInstance.CheckNullvalue(Passed_value: responseDict.object(forKey: "ImageName")) as NSString
                    
                    let uploaded_bytes  = Double(upload_byte_count)!
                    if(uploaded_bytes < 0)
                    {
                        print(uploaded_bytes)
                    }
                    self.stopTime = CFAbsoluteTimeGetCurrent()
                    let elapsed = self.stopTime - self.startTime
                    
                    let next_upload_bytes = uploaded_bytes / elapsed
                    
                    
                    let CheckBool:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname:Constant.sharedinstance.Status_Upload_Details , attribute: "upload_data_id", FetchString: image_id as String)
                    if(CheckBool)
                    {
                        let total_byte_count:String = self.ReturnuploadDetails(pathid: image_id as String, upload_detail: "total_byte_count") as! String
                        let upload_type:String = self.ReturnuploadDetails(pathid: image_id as String, upload_detail: "upload_type") as! String
                        let upload_Path:String =  self.ReturnuploadDetails(pathid: image_id as String, upload_detail: "upload_Path") as! String
                        let upload_paused:String = self.ReturnuploadDetails(pathid: image_id as String, upload_detail: "upload_paused") as! String
                        var image_Url:String = Themes.sharedInstance.CheckNullvalue(Passed_value: responseDict.object(forKey: "filename"))
                        let incrementbufferCount:Int = Int(bufferAt as String)! + 1
                        
                        let previous_upload_byte_count:String = self.ReturnuploadDetails(pathid: image_id as String, upload_detail: "upload_byte_count") as! String
                        
                        upload_byte_count = "\(Int(previous_upload_byte_count)! + Int(upload_byte_count)!)"
                        
                        if(Int(upload_byte_count)! > Int(total_byte_count)!)
                        {
                            upload_byte_count = total_byte_count
                        }
                        DispatchQueue.main.async {
                            let Dict:[String:AnyHashable]=["upload_byte_count" : upload_byte_count]
                            DatabaseHandler.sharedInstance.UpdateData(Entityname:Constant.sharedinstance.Status_Upload_Details , FetchString: image_id as String, attribute: "upload_data_id", UpdationElements: Dict as NSDictionary?)
                            if(upload_byte_count != total_byte_count)
                            {
                                DispatchQueue.main.async {
                                    let Dict:[String:AnyHashable]=["upload_status":"0","upload_count":"\(incrementbufferCount)"]
                                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Status_Upload_Details, FetchString: image_id as String, attribute: "upload_data_id", UpdationElements: Dict as NSDictionary?)
                                    if FileManager.default.fileExists(atPath: upload_Path)
                                    {
                                        let url = URL(fileURLWithPath: upload_Path)
                                        var data:NSData!
                                        
                                        data = NSData(contentsOf: url)
                                        
                                        if (data == nil)
                                        {
                                            
                                            let url = URL(string: upload_Path)
                                            data =  NSData(contentsOf: url!)
                                        }
                                        
                                        if(data != nil)
                                        {
                                            if upload_paused != "1"{
                                                let byteArr:NSMutableArray = self.ReturnImageByteArr(data as Data)
                                                
                                                self.uploadBytes(Total_Byte_Arr: byteArr, bytesToSend: Double(next_upload_bytes), Uploaded_bytes: Int(upload_byte_count)!, UploadCount: incrementbufferCount, data_name: image_id as String, file_name: image_Url)
                                            }
                                            else{
                                                self.handleUpload()
                                            }
                                        }
                                    }
                                }
                            }
                            else
                            {
                                if(image_Url != "")
                                {
                                    if(image_Url.substring(to: 1) == ".")
                                    {
                                        image_Url.remove(at: image_Url.startIndex)
                                    }
                                    image_Url = ("\(ImgUrl)\(image_Url)")
                                }
                                
                                let toDocId:String=self.GetDocID(thumbnail_data: image_id as String)
                                let timestampStored:String = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Status_one_one, attrib_name: "doc_id", fetchString: toDocId, returnStr: "timestamp")
                                
                                //                    let to:String = self.ReturnuploadDetails(pathid: image_id as String, upload_detail: "to_id")!
                                let Dict:[String:AnyHashable]=["upload_status":"1","upload_count":"\(bufferAt)","serverpath":"\(image_Url)","upload_data_id":"\(toDocId)"]
                                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Status_Upload_Details, FetchString: image_id as String, attribute: "upload_data_id", UpdationElements: Dict as NSDictionary?)
                                let File_status_dict:[String: String] = ["upload_status": "1","type":upload_type,"status":"1","id": timestampStored,"docid":toDocId]
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.statusloaderdata), object: image_id , userInfo: File_status_dict)
                                self.sendUploadedMessage(thumbnailid: image_id as String,timestamp:timestampStored,toDocId: toDocId)
                                self.handleUpload()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func GetDocID(thumbnail_data:String)->String
    {
        var thumbnail :String = String()
        let ChatArr:NSArray=DatabaseHandler.sharedInstance.FetchFromDatabaseWithLimit(Entityname: Constant.sharedinstance.Status_one_one, attribute: "thumbnail", Predicatefromat: "==", FetchString: thumbnail_data, Limit: 0, SortDescriptor: nil) as NSArray
        if(ChatArr.count > 0)
        {
            for i in 0 ..< ChatArr.count {
                let ResponseDict = ChatArr[i] as! NSManagedObject
                thumbnail=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "doc_id"));
            }
        }
        
        return thumbnail
    }
    
    
    
    func sendUploadedMessage(thumbnailid:String,timestamp:String,toDocId:String)
    {
        let toDocId:String=toDocId
        
        var thumbnail:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "serverpath") as! String
        let to:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "to_id") as! String
        let thumbnail_data:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "compressed_data") as! String
        let total_byte_count:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "total_byte_count") as! String
        let height:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "height") as! String
        let width:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "width") as! String
        let upload_type:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "upload_type") as! String
        let upload_path:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "upload_Path") as! String
        thumbnail = thumbnail.replacingOccurrences(of: ImgUrl, with: ".")
        
        
        
        
        let Chattype:String = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Status_one_one, attrib_name: "doc_id", fetchString: toDocId, returnStr: "chat_type")
        let Payload:String = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Status_one_one, attrib_name: "doc_id", fetchString: toDocId, returnStr: "payload")
        var duration = ""
        let chat_type:String = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Status_one_one, attrib_name: "doc_id", fetchString: toDocId, returnStr: "chat_type")
        
        
        if(chat_type == "single")
        {
            let param:NSDictionary = ["timestamp":Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp),"doc_id":toDocId,"thumbnail":toDocId]
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Status_one_one, FetchString: thumbnailid, attribute: "thumbnail", UpdationElements: param)
        }
        
        
        
        if(upload_type == "2")
        {
            if(upload_path != "")
            {
                duration = Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.getMediaDuration(url: NSURL(fileURLWithPath: upload_path)))
            }
        }
        
        if(upload_type == "1")
        {
            if(Chattype == "single")
            {
                SocketIOManager.sharedInstance.SendStatusMessage(from: Themes.sharedInstance.Getuser_id(), to: to, payload: Payload, type: "1", timestamp: Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp), DocID: toDocId, thumbnail: thumbnail, thumbnail_data: thumbnail_data,filesize: total_byte_count,height: height,width: width,doc_name:"",numPages:"", duration:duration, themeColor: "", theme_font: "")
            }
            
        }
        else if(upload_type == "2")
        {
            
            if(Chattype == "single")
            {
                SocketIOManager.sharedInstance.SendStatusMessage(from: Themes.sharedInstance.Getuser_id(), to: to, payload: Payload, type: "2", timestamp: Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp), DocID: toDocId, thumbnail: thumbnail, thumbnail_data: thumbnail_data,filesize: total_byte_count,height: height,width: width,doc_name:"",numPages:"", duration: duration, themeColor: "", theme_font: "")
            }
            
        }
    }
    
    
    func uploadBytes(Total_Byte_Arr:NSMutableArray, bytesToSend : Double, Uploaded_bytes: Int, UploadCount:Int, data_name:String, file_name:String)
    {
        DispatchQueue.global(qos: .background).async {
            let TenPercent = round(Double(bytesToSend) * 20 / 100)
            
            let bytesToSend = Int(bytesToSend + TenPercent)
            
            if(Total_Byte_Arr.count > 0 && bytesToSend > 0)
            {
                let TotalofNextBytes = Uploaded_bytes + bytesToSend
                if(TotalofNextBytes <= Total_Byte_Arr.count)
                {
                    let ByteArr:NSMutableArray = NSMutableArray()
                    ByteArr.addObjects(from: Total_Byte_Arr.subarray(with: NSRange(location: Uploaded_bytes, length: TotalofNextBytes - Uploaded_bytes)))
                    let NewArr=NSArray(array: ByteArr)
                    let endMarker = NSData(bytes:NewArr as! [UInt8] , length: ByteArr.count)
                    if (SocketIOManager.sharedInstance.socket.status == .connected)
                    {
                        let imageSize: Int = endMarker.length
                        if(imageSize != 0)
                        {
                            self.startTime = CFAbsoluteTimeGetCurrent()
                            self.stopTime = self.startTime
                            self.bytesReceived = 0
                            
                            print("uploading.....total.....speed....." + ByteCountFormatter.string(fromByteCount: Int64(TotalofNextBytes) , countStyle: .file) + "....." + ByteCountFormatter.string(fromByteCount: Int64(Total_Byte_Arr.count) , countStyle: .file) + "....." + ByteCountFormatter.string(fromByteCount: Int64(ByteArr.count) , countStyle: .file))
                            SocketIOManager.sharedInstance.uploadStatusImage(from:Themes.sharedInstance.Getuser_id(),imageName:data_name,uploadType:"status",bufferAt:"\(UploadCount)",imageByte:endMarker,file_end: "0", speed: "\(ByteArr.count)")
                            
                        }
                    }
                }
                else
                {
                    if(Uploaded_bytes == Total_Byte_Arr.count)
                    {
                        var image_Url:String = file_name
                        if(image_Url != "")
                        {
                            if(image_Url.substring(to: 1) == ".")
                            {
                                image_Url.remove(at: image_Url.startIndex)
                            }
                            image_Url = ("\(ImgUrl)\(image_Url)")
                        }
                        
                        let toDocId:String=self.GetDocID(thumbnail_data: data_name as String)
                        let timestampStored:String = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Status_one_one, attrib_name: "doc_id", fetchString: toDocId, returnStr: "timestamp")
                        let bufferAt = Themes.sharedInstance.CheckNullvalue(Passed_value: self.ReturnuploadDetails(pathid: data_name, upload_detail: "upload_count"))
                        let upload_type = Themes.sharedInstance.CheckNullvalue(Passed_value: self.ReturnuploadDetails(pathid: data_name, upload_detail: "upload_type"))
                        
                        let Dict:[String:AnyHashable]=["upload_status":"1","upload_count":"\(bufferAt)","serverpath":"\(image_Url)","upload_data_id":"\(toDocId)"]
                        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Status_Upload_Details, FetchString: data_name, attribute: "upload_data_id", UpdationElements: Dict as NSDictionary?)
                        let File_status_dict:[String: String] = ["upload_status": "1","type":upload_type,"status":"1","id": timestampStored,"docid":toDocId]
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.statusloaderdata), object: data_name, userInfo: File_status_dict)
                        self.sendUploadedMessage(thumbnailid: data_name,timestamp:timestampStored,toDocId: toDocId)
                        self.handleUpload()
                    }
                    else
                    {
                        if(Uploaded_bytes < Total_Byte_Arr.count)
                        {
                            let ByteArr:NSMutableArray = NSMutableArray()
                            ByteArr.addObjects(from: Total_Byte_Arr.subarray(with: NSRange(location: Uploaded_bytes, length: Total_Byte_Arr.count - Uploaded_bytes)))
                            let NewArr=NSArray(array: ByteArr)
                            let endMarker = NSData(bytes:NewArr as! [UInt8] , length: ByteArr.count)
                            if (SocketIOManager.sharedInstance.socket.status == .connected)
                            {
                                let imageSize: Int = endMarker.length
                                if(imageSize != 0)
                                {
                                    self.startTime = CFAbsoluteTimeGetCurrent()
                                    self.stopTime = self.startTime
                                    self.bytesReceived = 0
                                    
                                    print("uploading.....total.....speed....." + ByteCountFormatter.string(fromByteCount: Int64(Total_Byte_Arr.count) , countStyle: .file) + "....." + ByteCountFormatter.string(fromByteCount: Int64(Total_Byte_Arr.count) , countStyle: .file) + "....." + ByteCountFormatter.string(fromByteCount: Int64(ByteArr.count) , countStyle: .file))
                                    
                                    SocketIOManager.sharedInstance.uploadStatusImage(from:Themes.sharedInstance.Getuser_id(),imageName:data_name,uploadType:"status",bufferAt:"\(UploadCount)",imageByte:endMarker,file_end: "1", speed : "\(ByteArr.count)")
                                }
                            }
                        }
                        else
                        {
                            print(Uploaded_bytes, Total_Byte_Arr.count)
                        }
                    }
                }
            }
        }
    }
    
    func returnUploadByteCount(bytesToSend: Double, data_name: String) -> String
    {
        let UploadDetailArr = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Status_Upload_Details, attribute: "upload_data_id", FetchString: data_name, SortDescriptor: nil) as! [Status_Upload_Details]
        
        if(UploadDetailArr.count > 0)
        {
            let ReponseDict = UploadDetailArr[0]
            
            let PhotoPath:String =  Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.upload_Path)
            let upload_byte_count:String =  Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.upload_byte_count)
            
            let documentsDirectoryURL = CommondocumentDirectory()
            let fileURL = documentsDirectoryURL.appendingPathComponent(PhotoPath)
            let url = URL(fileURLWithPath: fileURL.path)
            let data =   NSData(contentsOf: url)
            if(data != nil)
            {
                let Total_Byte_Arr:NSMutableArray = self.ReturnImageByteArr(data! as Data)
                if(Total_Byte_Arr.count > 0)
                {
                    let bytesToSend = Int(bytesToSend)
                    let TotalofNextBytes = Int(upload_byte_count)! + bytesToSend
                    if(TotalofNextBytes <= Total_Byte_Arr.count)
                    {
                        return "\(TotalofNextBytes)"
                    }
                    else
                    {
                        return "\(upload_byte_count)"
                    }
                }
            }
        }
        return "0"
    }
    
    func ReturnuploadDetails(pathid:String,upload_detail:String)->Any
    {
        
        let UploadArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Status_Upload_Details, attribute: "upload_data_id", FetchString: pathid, SortDescriptor: nil) as! NSArray
        var ReturnUploadDetail = ""
        if(UploadArr.count > 0)
        {
            
            for i in 0..<UploadArr.count
            {
                let ReponseDict:NSManagedObject = UploadArr[i] as! NSManagedObject
                
                if(upload_detail == "upload_Path")
                {
                    let documentsDirectoryURL = CommondocumentDirectory()

                    let fileURL = documentsDirectoryURL.appendingPathComponent(Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: upload_detail)))
                    ReturnUploadDetail = fileURL.path;
                    
                }
                    
                else if(upload_detail == "upload_Path_voice")
                {
                    ReturnUploadDetail = Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "upload_Path"))
                }
                    
                else if(upload_detail == "video_thumbnail")
                {
                    if(ReponseDict.value(forKey: upload_detail) != nil)
                    {
                        return ReponseDict.value(forKey: upload_detail)!
                    }
                    else
                    {
                        return Data()
                    }
                }
                    
                    
                else
                {
                    ReturnUploadDetail = Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: upload_detail))
                }
                
            }
            
        }
        if(upload_detail == "video_thumbnail")
        {
            return Data()
        }
        else {
            return ReturnUploadDetail
        }
    }
    
    func SendFailedMessages()
        
    {
        if (SocketIOManager.sharedInstance.socket.status == .connected)
        {
            
            let p1 = NSPredicate(format: "user_id = %@", Themes.sharedInstance.Getuser_id())
            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1])
            let chatintiatedDetailArr=DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Status_initiated_details, SortDescriptor: nil, predicate: predicate,Limit:0) as! NSArray
            if(chatintiatedDetailArr.count > 0)
            {
                for i in 0..<chatintiatedDetailArr.count
                {
                    let ReponseDict:NSManagedObject = chatintiatedDetailArr[i] as! NSManagedObject
                    
                    
                    let p1 = NSPredicate(format: "user_common_id = %@", Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "user_common_id")))
                    let p2 = NSPredicate(format: "message_status = %@", "0")
                    
                    let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1,p2])
                    let Status_one_oneArr=DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Status_one_one, SortDescriptor: nil, predicate: predicate,Limit:0) as! NSArray
                    if(Status_one_oneArr.count > 0)
                    {
                        for i in 0..<Status_one_oneArr.count
                        {
                            
                            let Chat_one_ReponseDict:NSManagedObject = Status_one_oneArr[i] as! NSManagedObject
                            
                            let message_type = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"type"))
                            
                            var duration = ""
                            
                            if(message_type == "2")
                            {
                                let upload_path = Themes.sharedInstance.CheckNullvalue(Passed_value: self.ReturnuploadDetails(pathid: Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey: "doc_id")), upload_detail: "upload_Path"))
                                if(upload_path != "")
                                {
                                    duration = Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.getMediaDuration(url: NSURL(fileURLWithPath: upload_path)))
                                }
                            }
                            if(message_type == "0")
                            {
                                let payload = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"payload"))
                                let timestamp:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"timestamp"))
                                let toDocId:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"doc_id"))
                                let colorCode = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"theme_color"))
                                let fontName = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"theme_font"))
                                
                                SocketIOManager.sharedInstance.SendStatusMessage(from: Themes.sharedInstance.Getuser_id(), to: "", payload: payload, type: "0", timestamp: Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp), DocID: toDocId, thumbnail: "", thumbnail_data: "",filesize: "",height: "",width: "",doc_name:"",numPages:"", duration:"", themeColor: colorCode, theme_font: fontName)
                            }
                            else if(message_type == "1")
                            {
                                
                                let thumbail = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"thumbnail"))
                                let payload = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"payload"))
                                let toDocId:String=thumbail
                                
                                let upload_status:String = Themes.sharedInstance.CheckNullvalue(Passed_value: self.ReturnuploadDetails(pathid: toDocId, upload_detail: "upload_status") as! String)
                                
                                if(upload_status == "1")
                                {
                                    
                                    
                                    let timestamp:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"timestamp"))
                                    var thumbnail:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "serverpath") as! String
                                    thumbnail = thumbnail.replacingOccurrences(of: ImgUrl, with: ".")
                                    
                                    let to:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "to_id") as! String
                                    let thumbnail_data:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "compressed_data") as! String
                                    let total_byte_count:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "total_byte_count") as! String
                                    let height:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "height") as! String
                                    let width:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "width") as! String
                                    
                                    
                                    SocketIOManager.sharedInstance.SendStatusMessage(from: Themes.sharedInstance.Getuser_id(), to: to, payload: payload, type: "1", timestamp: Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp), DocID: toDocId, thumbnail: thumbnail, thumbnail_data: thumbnail_data,filesize: total_byte_count,height: height,width: width,doc_name:"",numPages:"", duration: duration, themeColor: "", theme_font: "")
                                    
                                }
                                
                            }
                                
                            else if(message_type == "2")
                            {
                                let thumbail = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"thumbnail"))
                                
                                let payload = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"payload"))
                                
                                let toDocId:String=thumbail
                                
                                let doc_id = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"doc_id"))
                                
                                let upload_status:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "upload_status") as! String
                                
                                if(upload_status == "1")
                                {
                                    
                                    
                                    let timestamp:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"timestamp"))
                                    var thumbnail:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "serverpath") as! String
                                    thumbnail = thumbnail.replacingOccurrences(of: ImgUrl, with: ".")
                                    let to:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "to_id") as! String
                                    let thumbnail_data:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "compressed_data") as! String
                                    let total_byte_count:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "total_byte_count") as! String
                                    let height:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "height") as! String
                                    let width:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "width") as! String
                                    
                                    
                                    
                                    SocketIOManager.sharedInstance.SendStatusMessage(from: Themes.sharedInstance.Getuser_id(), to: to, payload: Themes.sharedInstance.CheckNullvalue(Passed_value: payload), type: "2", timestamp: Themes.sharedInstance.CheckNullvalue(Passed_value:timestamp), DocID: doc_id, thumbnail: thumbnail, thumbnail_data: thumbnail_data,filesize: total_byte_count,height: height,width: width,doc_name:"",numPages:"", duration: duration, themeColor: "", theme_font: "")
                                }
                                
                            }
                        }
                    }
                    
                }
                
            }
        }
    }
    
    func handleUpload()
    {
        let p1 = NSPredicate(format: "user_id == %@", Themes.sharedInstance.Getuser_id())
        let p2 = NSPredicate(format: "upload_status == %@", "0")
        
        let compound = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2])
        
        let UploadDetailArr = DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Status_Upload_Details, SortDescriptor: nil, predicate: compound, Limit: 0) as! [Status_Upload_Details]
        
        if(UploadDetailArr.count > 0)
        {
            for ReponseDict in UploadDetailArr
            {
                let PhotoPath:String =  Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.upload_Path)
                let documentsDirectoryURL = CommondocumentDirectory()
                let fileURL = documentsDirectoryURL.appendingPathComponent(PhotoPath)
                let url = URL(fileURLWithPath: fileURL.path)
                let data =   NSData(contentsOf: url)
                if(data != nil)
                {
                    let upload_data_id = Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.upload_data_id)
                    SocketIOManager.sharedInstance.getFileInfoBytes(imageName: upload_data_id, uploadType: "status")
                    break
                }
                else
                {
                    let pred = NSPredicate(format: "upload_data_id == %@",   Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.upload_data_id))
                    DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Status_Upload_Details, Predicatefromat: pred, Deletestring: nil, AttributeName: nil)
                }
            }
        }
        else
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                self.SendFailedMessages()
            }
        }
    }
    
    func uploadFile(data_name : String, file_name: String) {
        let p1 = NSPredicate(format: "upload_data_id == %@", data_name)
        
        let UploadDetailArr = DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Status_Upload_Details, SortDescriptor: nil, predicate: p1, Limit: 0) as! [Status_Upload_Details]
        
        if(UploadDetailArr.count > 0)
        {
            for ReponseDict in UploadDetailArr
            {
                let PhotoPath:String =  Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.upload_Path)
                let documentsDirectoryURL = CommondocumentDirectory()
                let fileURL = documentsDirectoryURL.appendingPathComponent(PhotoPath)
                let url = URL(fileURLWithPath: fileURL.path)
                let data =   NSData(contentsOf: url)
                if(data != nil)
                {
                    let byteArr:NSMutableArray = self.ReturnImageByteArr(data! as Data)
                    let upload_byte_count = Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.upload_byte_count)
                    let upload_count = Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.upload_count)
                    let upload_data_id = Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.upload_data_id)
                    if(byteArr.count > 0)
                    {
                        self.uploadBytes(Total_Byte_Arr: byteArr, bytesToSend: Double(Constant.sharedinstance.SendbyteCount), Uploaded_bytes: Int(upload_byte_count)!, UploadCount: Int(upload_count)!, data_name: upload_data_id, file_name: file_name)
                    }
                    break
                }
                else
                {
                    let pred = NSPredicate(format: "upload_data_id == %@",   Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.upload_data_id))
                    DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Status_Upload_Details, Predicatefromat: pred, Deletestring: nil, AttributeName: nil)
                }
            }
        }
        else
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.SendFailedMessages()
            }
        }
    }
    
    func loadMyImage(messageFrame : UUMessageFrame, imageView: UIImageView, isLoaderShow: Bool, isGif: Bool, completion: (() -> Swift.Void)? = nil)
    {
        imageView.subviews.forEach { view in
            if(view.tag == 100)
            {
                view.removeFromSuperview()
            }
        }
        imageView.image = nil
        if(messageFrame.message.type == MessageType(rawValue: 1))
        {
            let download_status:String = StatusUploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "download_status") as! String
            
            if messageFrame.message.from == MessageFrom(rawValue: 1)!
            {
                if(download_status == "2")
                {
                    let PhotoPath:String = StatusUploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "upload_Path") as! String
                    
                    if(PhotoPath != "")
                    {
                        if FileManager.default.fileExists(atPath: PhotoPath) {
                            let url = URL(fileURLWithPath: PhotoPath)
                            //        let data = NSData(contentsOf: url as URL)
                            if(isGif)
                            {
                                do {
                                    let image = try UIImage(gifData: try Data(contentsOf: url))
                                    imageView.setGifImage(image)
                                    imageView.startAnimatingGif()
                                }
                                catch {
                                    print(error.localizedDescription)
                                }
                            }
                            else
                            {
                                imageView.sd_setImage(with: url)
                            }
                            if(completion != nil)
                            {
                                completion!()
                            }
                        }
                        else
                        {
                            let serverpath:String = StatusUploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "serverpath") as! String
                            var ThembnailData:String = StatusUploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "compressed_data") as! String
                            let str:String = "data:image/jpg;base64,";
                            if !ThembnailData.contains("data:image")
                            {
                                ThembnailData = str.appending(ThembnailData)
                            }
                            
                            if(isGif)
                            {
                                do {
                                    imageView.image = UIImage(cgImage: (UIImage(data: try Data(contentsOf: URL(string:ThembnailData)!))?.cgImage)!, scale: 1.0, orientation: UIImage.Orientation.up)
                                }
                                catch {
                                    print(error.localizedDescription)
                                }
                            }
                            else
                            {
                                imageView.sd_setImage(with: URL(string:ThembnailData)!)
                            }
                            
                            let url = URL(string: serverpath)

                            let spinner = self.spinner
                            if(isLoaderShow)
                            {
                                spinner.frame = CGRect(x: imageView.center.x - 30, y: imageView.center.y - 30, width: 60, height: 60)
                                imageView.addSubview(spinner)
                            }
                            
                            SDWebImageManager.shared().imageDownloader?.downloadImage(with: url, options: .highPriority, progress: nil, completed: { (image:UIImage?, data:Data?, erro:Error?, downloaded:Bool) in
                                if(image != nil)
                                {
                                    spinner.removeFromSuperview()
                                    
                                    if(isGif)
                                    {
                                        let imagedata = data
                                        let assetname:String = messageFrame.message.thumbnail! + ".gif"
                                        let Path:String =  Filemanager.sharedinstance.SaveImageFile(imagePath: "\(Constant.sharedinstance.statuspath)/\(assetname)",imagedata: imagedata!)
                                        
                                        do {
                                            let image = try UIImage(gifData: imagedata!)
                                            imageView.setGifImage(image)
                                            imageView.startAnimatingGif()
                                        }
                                        catch {
                                            print(error.localizedDescription)
                                        }

                                        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Status_Upload_Details, FetchString: messageFrame.message.thumbnail!, attribute: "upload_data_id", UpdationElements: ["download_status" : "2","upload_Path":Path])
                                        if(completion != nil)
                                        {
                                            completion!()
                                        }
                                    }
                                    else
                                    {
                                        let imagedata = image!.jpegData(compressionQuality: 1.0)!
                                        let assetname:String = messageFrame.message.thumbnail! + ".jpg"
                                        let Path:String =  Filemanager.sharedinstance.SaveImageFile(imagePath: "\(Constant.sharedinstance.statuspath)/\(assetname)",imagedata: imagedata)
                                        imageView.image = image!
                                        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Status_Upload_Details, FetchString: messageFrame.message.thumbnail!, attribute: "upload_data_id", UpdationElements: ["download_status" : "2","upload_Path":Path])
                                        if(completion != nil)
                                        {
                                            completion!()
                                        }
                                    }
                                    
                                }
                            })
                        }
                        
                    }
                    else
                        
                    {
                        imageView.image = UIImage(named:"VideoThumbnail")
                    }
                }
                    
                else
                {
                    let serverpath:String = StatusUploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "serverpath") as! String
                    var ThembnailData:String = StatusUploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "compressed_data") as! String
                    let str:String = "data:image/jpg;base64,";
                    if !ThembnailData.contains("data:image")
                    {
                        ThembnailData = str.appending(ThembnailData)
                    }
                    
                    if(ThembnailData != "")
                    {
                        if(isGif)
                        {
                            do {
                                imageView.image = UIImage(cgImage: (UIImage(data: try Data(contentsOf: URL(string:ThembnailData)!))?.cgImage)!, scale: 1.0, orientation: UIImage.Orientation.up)
                            }
                            catch {
                                print(error.localizedDescription)
                            }
                        }
                        else
                        {
                            imageView.sd_setImage(with: URL(string:ThembnailData)!)
                        }
                    }
                    
                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Status_Upload_Details, FetchString: messageFrame.message.thumbnail!, attribute: "upload_data_id", UpdationElements: ["download_status" : "1"])
                    
                    if(serverpath != "")
                    {
                        let spinner = self.spinner
                        if(isLoaderShow)
                        {
                            spinner.frame = CGRect(x: imageView.center.x - 30, y: imageView.center.y - 30, width: 60, height: 60)
                            imageView.addSubview(spinner)
                        }
                        
                        SDWebImageManager.shared().imageDownloader?.downloadImage(with: URL(string:serverpath), options: .highPriority, progress: nil, completed: { (image:UIImage?, data:Data?, erro:Error?, downloaded:Bool) in
                            if(image != nil)
                            {
                                spinner.removeFromSuperview()
                                
                                if(isGif)
                                {
                                    let imagedata = data
                                    let assetname:String = messageFrame.message.thumbnail! + ".gif"
                                    let Path:String =  Filemanager.sharedinstance.SaveImageFile(imagePath: "\(Constant.sharedinstance.statuspath)/\(assetname)",imagedata: imagedata!)
                                    
                                    do {
                                        let image = try UIImage(gifData: imagedata!)
                                        imageView.setGifImage(image)
                                        imageView.startAnimatingGif()
                                    }
                                    catch {
                                        print(error.localizedDescription)
                                    }
                                    
                                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Status_Upload_Details, FetchString: messageFrame.message.thumbnail!, attribute: "upload_data_id", UpdationElements: ["download_status" : "2","upload_Path":Path])
                                    if(completion != nil)
                                    {
                                        completion!()
                                    }
                                }
                                else
                                {
                                    let imagedata = image!.jpegData(compressionQuality: 1.0)!
                                    let assetname:String = messageFrame.message.thumbnail! + ".jpg"
                                    let Path:String =  Filemanager.sharedinstance.SaveImageFile(imagePath: "\(Constant.sharedinstance.statuspath)/\(assetname)",imagedata: imagedata)
                                    imageView.image = image!
                                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Status_Upload_Details, FetchString: messageFrame.message.thumbnail!, attribute: "upload_data_id", UpdationElements: ["download_status" : "2","upload_Path":Path])
                                    if(completion != nil)
                                    {
                                        completion!()
                                    }
                                }
                            }
                        })
                    }
                }
                
            }
        }
        else
        {
            self.loadVideoThumbnailOfMe(messageFrame: messageFrame, ImageView: imageView)
        }
        
        
    }
    
    func loadFriendsImage(messageFrame : UUMessageFrame, imageView: UIImageView, isLoaderShow: Bool, isGif: Bool, completion: (() -> Swift.Void)? = nil)
    {
        imageView.subviews.forEach { view in
            if(view.tag == 100)
            {
                view.removeFromSuperview()
            }
        }
        imageView.image = nil
        if(messageFrame.message.type == MessageType(rawValue: 1))
        {
            
            let download_status:String = StatusUploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "download_status") as! String
            
            if(download_status == "2")
            {
                let PhotoPath:String = StatusUploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "upload_Path") as! String
                
                if(PhotoPath != "")
                {
                    if FileManager.default.fileExists(atPath: PhotoPath) {
                        let url = URL(fileURLWithPath: PhotoPath)
                        if(isGif)
                        {
                            do {
                                let image = try UIImage(gifData: try Data(contentsOf: url))
                                imageView.setGifImage(image)
                                imageView.startAnimatingGif()
                            }
                            catch {
                                print(error.localizedDescription)
                            }
                        }
                        else
                        {
                            imageView.sd_setImage(with: url)
                        }
                        if(completion != nil)
                        {
                            completion!()
                        }
                    }
                    else
                    {
                        let serverpath:String = StatusUploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "serverpath") as! String
                        var ThembnailData:String = StatusUploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "compressed_data") as! String
                        let str:String = "data:image/jpg;base64,";
                        if !ThembnailData.contains("data:image")
                        {
                            ThembnailData = str.appending(ThembnailData)
                        }
                        
                        if(isGif)
                        {
                            do {
                                imageView.image = UIImage(cgImage: (UIImage(data: try Data(contentsOf: URL(string:ThembnailData)!))?.cgImage)!, scale: 1.0, orientation: UIImage.Orientation.up)
                            }
                            catch {
                                print(error.localizedDescription)
                            }
                        }
                        else
                        {
                            imageView.sd_setImage(with: URL(string:ThembnailData)!)
                        }
                        
                        let url = URL(string: serverpath)
                        
                        let spinner = self.spinner
                        if(isLoaderShow)
                        {
                            spinner.frame = CGRect(x: imageView.center.x - 30, y: imageView.center.y - 30, width: 60, height: 60)
                            imageView.addSubview(spinner)
                        }
                        
                        SDWebImageManager.shared().imageDownloader?.downloadImage(with: url, options: .highPriority, progress: nil, completed: { (image:UIImage?, data:Data?, erro:Error?, downloaded:Bool) in
                            if(image != nil)
                            {
                                spinner.removeFromSuperview()
                                
                                if(isGif)
                                {
                                    let imagedata = data
                                    let assetname:String = messageFrame.message.thumbnail! + ".gif"
                                    let Path:String =  Filemanager.sharedinstance.SaveImageFile(imagePath: "\(Constant.sharedinstance.statuspath)/\(assetname)",imagedata: imagedata!)
                                    
                                    do {
                                        let image = try UIImage(gifData: imagedata!)
                                        imageView.setGifImage(image)
                                        imageView.startAnimatingGif()
                                    }
                                    catch {
                                        print(error.localizedDescription)
                                    }
                                    
                                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Status_Upload_Details, FetchString: messageFrame.message.thumbnail!, attribute: "upload_data_id", UpdationElements: ["download_status" : "2","upload_Path":Path])
                                    if(completion != nil)
                                    {
                                        completion!()
                                    }
                                }
                                else
                                {
                                    let imagedata = image!.jpegData(compressionQuality: 1.0)!
                                    let assetname:String = messageFrame.message.thumbnail! + ".jpg"
                                    let Path:String =  Filemanager.sharedinstance.SaveImageFile(imagePath: "\(Constant.sharedinstance.statuspath)/\(assetname)",imagedata: imagedata)
                                    imageView.image = image!
                                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Status_Upload_Details, FetchString: messageFrame.message.thumbnail!, attribute: "upload_data_id", UpdationElements: ["download_status" : "2","upload_Path":Path])
                                    if(completion != nil)
                                    {
                                        completion!()
                                    }
                                }
                            }
                        })
                    }
                    
                }
                else
                    
                {
                    imageView.image = UIImage(named:"VideoThumbnail")
                }
            }
            else
            {
                let serverpath:String = StatusUploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "serverpath") as! String
                var ThembnailData:String = StatusUploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "compressed_data") as! String
                let str:String = "data:image/jpg;base64,";
                if !ThembnailData.contains("data:image")
                {
                    ThembnailData = str.appending(ThembnailData)
                }
                
                if(ThembnailData != "")
                {
                    if(isGif)
                    {
                        do {
                            imageView.image = UIImage(cgImage: (UIImage(data: try Data(contentsOf: URL(string:ThembnailData)!))?.cgImage)!, scale: 1.0, orientation: UIImage.Orientation.up)
                        }
                        catch {
                            print(error.localizedDescription)
                        }
                    }
                    else
                    {
                        imageView.sd_setImage(with: URL(string:ThembnailData)!)
                    }
                }
                
                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Status_Upload_Details, FetchString: messageFrame.message.thumbnail!, attribute: "upload_data_id", UpdationElements: ["download_status" : "1"])
                
                let spinner = self.spinner
                if(isLoaderShow)
                {
                    spinner.frame = CGRect(x: imageView.center.x - 30, y: imageView.center.y - 30, width: 60, height: 60)
                    imageView.addSubview(spinner)
                }
                
                SDWebImageManager.shared().imageDownloader?.downloadImage(with: URL(string:serverpath), options: .highPriority, progress: nil, completed: { (image:UIImage?, data:Data?, erro:Error?, downloaded:Bool) in
                    if(image != nil)
                    {
                        spinner.removeFromSuperview()
                        if(isGif)
                        {
                            let imagedata = data
                            let assetname:String = messageFrame.message.thumbnail! + ".gif"
                            let Path:String =  Filemanager.sharedinstance.SaveImageFile(imagePath: "\(Constant.sharedinstance.statuspath)/\(assetname)",imagedata: imagedata!)
                            
                            do {
                                let image = try UIImage(gifData: imagedata!)
                                imageView.setGifImage(image)
                                imageView.startAnimatingGif()
                            }
                            catch {
                                print(error.localizedDescription)
                            }
                            
                            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Status_Upload_Details, FetchString: messageFrame.message.thumbnail!, attribute: "upload_data_id", UpdationElements: ["download_status" : "2","upload_Path":Path])
                            if(completion != nil)
                            {
                                completion!()
                            }
                        }
                        else
                        {
                            let imagedata = image!.jpegData(compressionQuality: 1.0)!
                            let assetname:String = messageFrame.message.thumbnail! + ".jpg"
                            let Path:String =  Filemanager.sharedinstance.SaveImageFile(imagePath: "\(Constant.sharedinstance.statuspath)/\(assetname)",imagedata: imagedata)
                            imageView.image = image!
                            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Status_Upload_Details, FetchString: messageFrame.message.thumbnail!, attribute: "upload_data_id", UpdationElements: ["download_status" : "2","upload_Path":Path])
                            if(completion != nil)
                            {
                                completion!()
                            }
                        }
                    }
                })
            }
        }
        else
        {
            self.loadVideoThumbnailOfOthers(messageFrame: messageFrame, ImageView: imageView)
        }
    }
    
    func loadVideoThumbnailOfMe(messageFrame : UUMessageFrame, ImageView : UIImageView)
    {
        
        ImageView.image = nil
        let PhotoPath:Data = StatusUploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "video_thumbnail") as! Data
        var ThembnailData:String = StatusUploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "compressed_data") as! String
        
        
        
        if(ThembnailData != "")
        {
            let str:String = "data:image/jpg;base64,";
            
            if !ThembnailData.contains("data:image")
            {
                ThembnailData = str.appending(ThembnailData)
            }
            
            ImageView.sd_setImage(with: URL(string:ThembnailData))
            
        }
        else if(PhotoPath.count > 0)
        {
            let image:UIImage? = UIImage(data: PhotoPath)
            if(image != nil)
            {
                ImageView.image = image!
            }
        }
        else
        {
            ImageView.image = UIImage(named:"VideoThumbnail")
        }
        
    }
    
    func loadVideoThumbnailOfOthers(messageFrame : UUMessageFrame, ImageView : UIImageView)
    {
        ImageView.image = nil
        var ThembnailData:String = StatusUploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "compressed_data") as! String
        
        let str:String = "data:image/jpg;base64,";
        
        if !ThembnailData.contains("data:image")
        {
            ThembnailData = str.appending(ThembnailData)
        }
        
        ImageView.sd_setImage(with: URL(string:ThembnailData))
    }
}




