  //
  //  UploadHandler.swift
  
  //
  //  Created by Casp iOS on 05/04/17.
  //  Copyright © 2017 CASPERON. All rights reserved.
  //
  
  import UIKit
  import SDWebImage
  
  class UploadHandler: NSObject {
    
    var startTime: CFAbsoluteTime!
    var stopTime: CFAbsoluteTime!
    var bytesReceived: Int!
    
    static let Sharedinstance = UploadHandler()
    
    var downloadView: ACPDownloadView {
        let downloadView : ACPDownloadView = ACPDownloadView(frame: CGRect.zero)
        downloadView.tintColor = UIColor.white
        downloadView.backgroundColor = UIColor.clear
        downloadView.isUserInteractionEnabled = false
        downloadView.setIndicatorStatus(.indeterminate)
        return downloadView
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
                    
                    
                    let CheckBool:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname:Constant.sharedinstance.Upload_Details , attribute: "upload_data_id", FetchString: image_id as String)
                    if(CheckBool)
                    {
                        let total_byte_count:String = self.ReturnuploadDetails(pathid: image_id as String, upload_detail: "total_byte_count")! as! String
                        let upload_type:String = self.ReturnuploadDetails(pathid: image_id as String, upload_detail: "upload_type")! as! String
                        let upload_Path:String =  self.ReturnuploadDetails(pathid: image_id as String, upload_detail: "upload_Path")! as! String
                        let upload_paused:String = self.ReturnuploadDetails(pathid: image_id as String, upload_detail: "upload_paused")! as! String
                        var image_Url:String = Themes.sharedInstance.CheckNullvalue(Passed_value: responseDict.object(forKey: "filename"))
                        let incrementbufferCount:Int = Int(bufferAt as String)! + 1
                        
                        let previous_upload_byte_count:String = self.ReturnuploadDetails(pathid: image_id as String, upload_detail: "upload_byte_count")! as! String
                        
                        upload_byte_count = "\(Int(previous_upload_byte_count)! + Int(upload_byte_count)!)"
                        
                        if(Int(upload_byte_count)! > Int(total_byte_count)!)
                        {
                            upload_byte_count = total_byte_count
                        }
                        DispatchQueue.main.async {
                            let Dict:[String:AnyHashable]=["upload_byte_count" : upload_byte_count]
                            DatabaseHandler.sharedInstance.UpdateData(Entityname:Constant.sharedinstance.Upload_Details , FetchString: image_id as String, attribute: "upload_data_id", UpdationElements: Dict as NSDictionary?)
                            if(upload_byte_count != total_byte_count)
                            {
                                DispatchQueue.main.async {
                                    let Dict:[String:AnyHashable]=["upload_status":"0","upload_count":"\(incrementbufferCount)"]
                                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Upload_Details, FetchString: image_id as String, attribute: "upload_data_id", UpdationElements: Dict as NSDictionary?)
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
                                                
//                                                if(upload_type != "3")
//                                                {
                                                    let File_status_dict:[String: String] = ["upload_status": "1","type":upload_type,"status":"0", "total_byte_count" : total_byte_count, "upload_byte_count" : previous_upload_byte_count]
                                                    
                                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.loaderdata), object: image_id , userInfo: File_status_dict)
//                                                }
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
                                let timestampStored:String = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_one_one, attrib_name: "doc_id", fetchString: toDocId, returnStr: "timestamp")
                                
                                //                    let to:String = self.ReturnuploadDetails(pathid: image_id as String, upload_detail: "to_id")!
                                let Dict:[String:AnyHashable]=["upload_status":"1","upload_count":"\(bufferAt)","serverpath":"\(image_Url)","upload_data_id":"\(toDocId)"]
                                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Upload_Details, FetchString: image_id as String, attribute: "upload_data_id", UpdationElements: Dict as NSDictionary?)
                                let File_status_dict:[String: String] = ["upload_status": "1","type":upload_type,"status":"1","id": timestampStored,"docid":toDocId]
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.loaderdata), object: image_id , userInfo: File_status_dict)
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
        let ChatArr:NSArray=DatabaseHandler.sharedInstance.FetchFromDatabaseWithLimit(Entityname: "\(Constant.sharedinstance.Chat_one_one)", attribute: "thumbnail", Predicatefromat: "==", FetchString: thumbnail_data, Limit: 0, SortDescriptor: nil) as NSArray
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
        var toDocId:String=toDocId
        
        var thumbnail:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "serverpath")! as! String
        let to:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "to_id")! as! String
        let thumbnail_data:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "compressed_data")! as! String
        let total_byte_count:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "total_byte_count")! as! String
        let height:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "height")! as! String
        let width:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "width")! as! String
        let upload_type:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "upload_type")! as! String
        let upload_path:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "upload_Path")! as! String
        thumbnail = thumbnail.replacingOccurrences(of: ImgUrl, with: ".")
        
        
        
        
        let Chattype:String = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_one_one, attrib_name: "doc_id", fetchString: toDocId, returnStr: "chat_type")
        let Payload:String = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_one_one, attrib_name: "doc_id", fetchString: toDocId, returnStr: "payload")
        let displayName = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Group_details, attrib_name: "id", fetchString: to, returnStr: "displayName")
        let Group_toID:String = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_one_one, attrib_name: "doc_id", fetchString: toDocId, returnStr: "to")
        
        var duration = ""
        let chat_type:String = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_one_one, attrib_name: "doc_id", fetchString: toDocId, returnStr: "chat_type")
        
        let mesageID:String  = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_one_one, attrib_name: "doc_id", fetchString: toDocId, returnStr: "id")
        
        if(chat_type == "single" || chat_type == "secret")
        {
            let param:NSDictionary = ["doc_id":"\(toDocId)","thumbnail":"\(toDocId)"]
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_one_one, FetchString: thumbnailid, attribute: "thumbnail", UpdationElements: param)
        }
        else
        {
            toDocId =  "\(Themes.sharedInstance.Getuser_id())-\(to)-g-\(mesageID)"
            let param:NSDictionary = ["doc_id":"\(toDocId)","thumbnail":"\(toDocId)"]
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_one_one, FetchString: thumbnailid, attribute: "thumbnail", UpdationElements: param)
        }
        
        
        
        if(upload_type == "2" || upload_type == "3")
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
                let secrettype:String = Themes.sharedInstance.returnisSecret(user_id: to)
                
                SocketIOManager.sharedInstance.SendMessage(from: Themes.sharedInstance.Getuser_id(), to: "\(to)", payload: Payload, type: "1", timestamp: Themes.sharedInstance.CheckNullvalue(Passed_value:"\(timestamp)"), DocID: toDocId, thumbnail: thumbnail, thumbnail_data: thumbnail_data,filesize: total_byte_count,height: height,width: width,doc_name:"",numPages:"", duration:duration, is_secret_chat: secrettype)
            }else if(Chattype == "secret"){
                SocketIOManager.sharedInstance.secretMessage(from: Themes.sharedInstance.Getuser_id(), to: "\(to)", payload: Payload, type: "1", timestamp: Themes.sharedInstance.CheckNullvalue(Passed_value:"\(timestamp)"), DocID: toDocId, thumbnail: thumbnail, thumbnail_data: thumbnail_data,filesize: total_byte_count,height: height,width: width,doc_name:"",numPages:"", duration: duration, chat_type: "secret")
            }
            else
            {
                
                
                let Groupdic:[String: Any] = ["from":Themes.sharedInstance.Getuser_id(),"to":Group_toID,"type":"1","payload":EncryptionHandler.sharedInstance.encryptmessage(str:Payload.decoded,toid:to, chat_type: Chattype),"convId":"\(Group_toID)","toDocId":EncryptionHandler.sharedInstance.encryptmessage(str:"\(toDocId)",toid:to, chat_type: Chattype),"groupType":"9","userName":displayName,"id":EncryptionHandler.sharedInstance.encryptmessage(str:mesageID,toid:to, chat_type: Chattype),"thumbnail":EncryptionHandler.sharedInstance.encryptmessage(str:"\(thumbnail)",toid:to, chat_type: Chattype),"filesize":total_byte_count,"height": height,"width": width,"thumbnail_data":thumbnail_data]
                SocketIOManager.sharedInstance.SendMessage_group(param: Groupdic as NSDictionary)
            }
            
        }
        else if(upload_type == "2")
        {
            
            if(Chattype == "single")
            {
                let secrettype:String = Themes.sharedInstance.returnisSecret(user_id: to)
                
                SocketIOManager.sharedInstance.SendMessage(from: Themes.sharedInstance.Getuser_id(), to: "\(to)", payload: Payload, type: "2", timestamp: Themes.sharedInstance.CheckNullvalue(Passed_value:"\(timestamp)"), DocID: toDocId, thumbnail: thumbnail, thumbnail_data: thumbnail_data,filesize: total_byte_count,height: height,width: width,doc_name:"",numPages:"", duration: duration, is_secret_chat: secrettype)
            }else if(Chattype == "secret"){
                SocketIOManager.sharedInstance.secretMessage(from: Themes.sharedInstance.Getuser_id(), to: "\(to)", payload: Payload, type: "2", timestamp: Themes.sharedInstance.CheckNullvalue(Passed_value:"\(timestamp)"), DocID: toDocId, thumbnail: thumbnail, thumbnail_data: thumbnail_data,filesize: total_byte_count,height: height,width: width,doc_name:"",numPages:"", duration: duration, chat_type: "secret")
            }
                
            else
            {
                
                let Groupdic:[AnyHashable: Any] = ["from":Themes.sharedInstance.Getuser_id(),"to":Group_toID,"type":"2","payload":EncryptionHandler.sharedInstance.encryptmessage(str:Payload.decoded,toid:to, chat_type: Chattype),"convId":"\(Group_toID)","toDocId":EncryptionHandler.sharedInstance.encryptmessage(str:"\(toDocId)",toid:to, chat_type: Chattype),"groupType":"9","userName":displayName,"id":EncryptionHandler.sharedInstance.encryptmessage(str:mesageID,toid:to, chat_type: Chattype),"thumbnail":EncryptionHandler.sharedInstance.encryptmessage(str:"\(thumbnail)",toid:to, chat_type: Chattype),"filesize":total_byte_count,"height": height,"width": width,"thumbnail_data":thumbnail_data, "duration" : duration]
                SocketIOManager.sharedInstance.SendMessage_group(param: Groupdic as NSDictionary)
            }
            
        }
            
        else if(upload_type == "3")
        {
            if(Chattype == "single")
            {
                let secrettype:String = Themes.sharedInstance.returnisSecret(user_id: to)
                
                SocketIOManager.sharedInstance.SendMessage(from: Themes.sharedInstance.Getuser_id(), to: "\(to)", payload: "Audio", type: "3", timestamp: Themes.sharedInstance.CheckNullvalue(Passed_value:"\(timestamp)"), DocID: toDocId, thumbnail: thumbnail, thumbnail_data: thumbnail_data,filesize: total_byte_count,height: "0.0",width: "0.0",doc_name:"",numPages:"", duration: duration, is_secret_chat: secrettype)
                
            }else if(Chattype == "secret"){
                SocketIOManager.sharedInstance.secretMessage(from: Themes.sharedInstance.Getuser_id(), to: "\(to)", payload: "Audio", type: "3", timestamp: Themes.sharedInstance.CheckNullvalue(Passed_value:"\(timestamp)"), DocID: toDocId, thumbnail: thumbnail, thumbnail_data: thumbnail_data,filesize: total_byte_count,height: "0.0",width: "0.0",doc_name:"",numPages:"", duration: duration, chat_type: "secret")
            }
                
            else
            {
                
                let Groupdic:[AnyHashable: Any] = ["from":Themes.sharedInstance.Getuser_id(),"to":Group_toID,"type":"3","payload":EncryptionHandler.sharedInstance.encryptmessage(str:Payload.decoded,toid:to, chat_type: Chattype),"convId":"\(Group_toID)","toDocId":EncryptionHandler.sharedInstance.encryptmessage(str:"\(toDocId)",toid:to, chat_type: Chattype),"groupType":"9","userName":displayName,"id":EncryptionHandler.sharedInstance.encryptmessage(str:mesageID,toid:to, chat_type: Chattype),"thumbnail":EncryptionHandler.sharedInstance.encryptmessage(str:"\(thumbnail)",toid:to, chat_type: Chattype),"thumbnail_data": thumbnail_data,"filesize":total_byte_count,"height": "0.0","width": "0.0","duration" : duration, "audio_type" : "1"]
                SocketIOManager.sharedInstance.SendMessage_group(param: Groupdic as NSDictionary)
            }
            
            
        }
            
        else if(upload_type == "6" || upload_type == "20")
        {
            let doc_name:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "doc_name")! as! String
            let doc_pagecount:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "doc_pagecount")! as! String
            
            if(Chattype == "single")
            {
                let secrettype:String = Themes.sharedInstance.returnisSecret(user_id: to)
                
                SocketIOManager.sharedInstance.SendMessage(from: Themes.sharedInstance.Getuser_id(), to: "\(to)", payload: "Document", type: "\(upload_type)", timestamp: Themes.sharedInstance.CheckNullvalue(Passed_value:"\(timestamp)"), DocID: toDocId, thumbnail: thumbnail, thumbnail_data: thumbnail_data,filesize: total_byte_count,height: "0.0",width: "0.0",doc_name:doc_name,numPages:doc_pagecount, duration: duration, is_secret_chat: secrettype)
                
            }else if(Chattype == "secret"){
                SocketIOManager.sharedInstance.secretMessage(from: Themes.sharedInstance.Getuser_id(), to: "\(to)", payload: "Document", type: "\(upload_type)", timestamp: Themes.sharedInstance.CheckNullvalue(Passed_value:"\(timestamp)"), DocID: toDocId, thumbnail: thumbnail, thumbnail_data: thumbnail_data,filesize: total_byte_count,height: "0.0",width: "0.0",doc_name:doc_name,numPages:doc_pagecount, duration: duration, chat_type: "secret")
            }
                
            else
            {
                let Groupdic:[AnyHashable: Any] = ["from":Themes.sharedInstance.Getuser_id(),"to":Group_toID,"type":"20","payload":EncryptionHandler.sharedInstance.encryptmessage(str: Payload.decoded,toid:to, chat_type: Chattype),"convId":"\(Group_toID)","toDocId":EncryptionHandler.sharedInstance.encryptmessage(str:"\(toDocId)",toid:to, chat_type: Chattype),"groupType":"9","userName":displayName,"id":EncryptionHandler.sharedInstance.encryptmessage(str:mesageID,toid:to, chat_type: Chattype),"thumbnail":EncryptionHandler.sharedInstance.encryptmessage(str:"\(thumbnail)",toid:to, chat_type: Chattype),"thumbnail_data": thumbnail_data,"filesize":total_byte_count,"height": "0.0","width": "0.0","original_filename":EncryptionHandler.sharedInstance.encryptmessage(str: doc_name,toid:to, chat_type: Chattype),"numPages": doc_pagecount]
                SocketIOManager.sharedInstance.SendMessage_group(param: Groupdic as NSDictionary)
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
                            SocketIOManager.sharedInstance.uploadMedia(from:Themes.sharedInstance.Getuser_id(),imageName:data_name,uploadType:"single_chat",bufferAt:"\(UploadCount)",imageByte:endMarker,file_end: "0", speed: "\(ByteArr.count)")
                            
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
                        let timestampStored:String = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Chat_one_one, attrib_name: "doc_id", fetchString: toDocId, returnStr: "timestamp")
                        let bufferAt = Themes.sharedInstance.CheckNullvalue(Passed_value: self.ReturnuploadDetails(pathid: data_name, upload_detail: "upload_count"))
                        let upload_type = Themes.sharedInstance.CheckNullvalue(Passed_value: self.ReturnuploadDetails(pathid: data_name, upload_detail: "upload_type"))
                        //                    let to:String = self.ReturnuploadDetails(pathid: image_id as String, upload_detail: "to_id")!
                        let Dict:[String:AnyHashable]=["upload_status":"1","upload_count":"\(bufferAt)","serverpath":"\(image_Url)","upload_data_id":"\(toDocId)"]
                        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Upload_Details, FetchString: data_name, attribute: "upload_data_id", UpdationElements: Dict as NSDictionary?)
                        let File_status_dict:[String: String] = ["upload_status": "1","type":upload_type,"status":"1","id": timestampStored,"docid":toDocId]
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.sharedinstance.loaderdata), object: data_name, userInfo: File_status_dict)
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
                                    
                                    SocketIOManager.sharedInstance.uploadMedia(from:Themes.sharedInstance.Getuser_id(),imageName:data_name,uploadType:"single_chat",bufferAt:"\(UploadCount)",imageByte:endMarker,file_end: "1", speed : "\(ByteArr.count)")
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
        let UploadDetailArr = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Upload_Details, attribute: "upload_data_id", FetchString: data_name, SortDescriptor: nil) as! [Upload_Details]
        
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
    
    func updateUploadControler(pathid:String, status:String){
        let Dict:[String:AnyHashable]=["upload_paused":status]
        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Upload_Details, FetchString: pathid, attribute: "upload_data_id", UpdationElements: Dict as NSDictionary?)
        if status == "0"{
            handleUpload()
        }
    }
    
    func ReturnuploadDetails(pathid:String,upload_detail:String)->Any?
    {
        
        let UploadArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Upload_Details, attribute: "upload_data_id", FetchString: pathid, SortDescriptor: nil) as! NSArray
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
            let chatintiatedDetailArr=DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Chat_intiated_details, SortDescriptor: nil, predicate: predicate,Limit:0) as! NSArray
            if(chatintiatedDetailArr.count > 0)
            {
                for i in 0..<chatintiatedDetailArr.count
                {
                    let ReponseDict:NSManagedObject = chatintiatedDetailArr[i] as! NSManagedObject
                    
                    
                    let p1 = NSPredicate(format: "user_common_id = %@", Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.value(forKey: "user_common_id")))
                    let p2 = NSPredicate(format: "message_status = %@", "0")
                    
                    let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1,p2])
                    let Chat_one_oneArr=DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Chat_one_one, SortDescriptor: nil, predicate: predicate,Limit:0) as! NSArray
                    if(Chat_one_oneArr.count > 0)
                    {
                        for i in 0..<Chat_one_oneArr.count
                        {
                            
                            let Chat_one_ReponseDict:NSManagedObject = Chat_one_oneArr[i] as! NSManagedObject
                            
                            let message_type = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"type"))
                            
                            var duration = ""
                            
                            let is_forward = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"is_forward"))
                            let msgType = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"msgType"))
                            let msgrecordId = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"msgrecordId"))
                            if (is_forward == "1") {
                                let to = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"to"))
                                let timestamp = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"timestamp"))
                                let doc_id = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"doc_id"))
                                let chat_type = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"chat_type"))
                                if(chat_type == "single")
                                {
                                    SocketIOManager.sharedInstance.SendForwardMessage(from: Themes.sharedInstance.Getuser_id(), to: to, msgType: msgType, id: timestamp, toDocId: doc_id, recordId: msgrecordId)
                                }
                                else
                                {
                                    let Groupdic:[AnyHashable: Any] = ["from":Themes.sharedInstance.Getuser_id(),"to":to, "msgType" : msgType, "id" : (timestamp as NSString).longLongValue, "toDocId":doc_id, "recordId" : msgrecordId, "groupType":"17"]
                                    SocketIOManager.sharedInstance.SendMessage_group(param: Groupdic as NSDictionary)
                                }
                            }
                            else
                            {
                                if(message_type == "2" || message_type == "3")
                                {
                                    let upload_path = Themes.sharedInstance.CheckNullvalue(Passed_value: self.ReturnuploadDetails(pathid: Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey: "doc_id")), upload_detail: "upload_Path"))
                                    if(upload_path != "")
                                    {
                                        duration = Themes.sharedInstance.CheckNullvalue(Passed_value: Themes.sharedInstance.getMediaDuration(url: NSURL(fileURLWithPath: upload_path)))
                                    }
                                }
                                
                                if(message_type == "0" || message_type == "7")
                                {
                                    
                                    let to = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"to"))
                                    let payload = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"payload"))
                                    let doc_id = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"doc_id"))
                                    let timestamp = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"timestamp"))
                                    
                                    let chat_type = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"chat_type"))
                                    let is_reply = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"is_reply"))
                                    
                                    // DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { {
                                    if(chat_type == "single")
                                    {
                                        if(is_reply == "0")
                                        {
                                            let secrettype:String = Themes.sharedInstance.returnisSecret(user_id: to)
                                            
                                            SocketIOManager.sharedInstance.SendMessage(from: Themes.sharedInstance.Getuser_id(), to: "\(to)", payload: payload, type: "0", timestamp: timestamp, DocID:doc_id,thumbnail: "",thumbnail_data: "",filesize: "",height: "0",width: "0",doc_name:"",numPages:"", duration: duration,is_secret_chat: secrettype)
                                        }
                                        else
                                        {
                                            let recordID:String = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Reply_detail, attrib_name: "doc_id", fetchString: doc_id, returnStr: "recordId")
                                            
                                            
                                            let isStatus = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Status_one_one, attrib_name: "recordId", fetchString: recordID, returnStr: "recordId") == "" ? false : true
                                            
                                            var ReplyDict:[AnyHashable: Any] = ["from":Themes.sharedInstance.Getuser_id(),"to":to,"type":"0","payload":EncryptionHandler.sharedInstance.encryptmessage(str:payload.decoded,toid:to, chat_type: chat_type),"toDocId":EncryptionHandler.sharedInstance.encryptmessage(str:doc_id,toid:to, chat_type: chat_type),"id":EncryptionHandler.sharedInstance.encryptmessage(str:timestamp,toid:to, chat_type: chat_type),"recordId":recordID]
                                            
                                            if(isStatus)
                                            {
                                                ReplyDict["reply_type"] = "status"
                                            }
                                            SocketIOManager.sharedInstance.EmitReplyMessage(param: ReplyDict as NSDictionary)
                                        }
                                    }
                                    else if(chat_type == "secret"){
                                        if(is_reply == "0")
                                        {
                                            SocketIOManager.sharedInstance.secretMessage(from: Themes.sharedInstance.Getuser_id(), to: "\(to)", payload: payload, type: "0", timestamp: timestamp, DocID:doc_id,thumbnail: "",thumbnail_data: "",filesize: "",height: "0",width: "0",doc_name:"",numPages:"", duration: duration, chat_type: "secret")
                                            
                                        }
                                        else
                                        {
                                            let recordID:String = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Reply_detail, attrib_name: "doc_id", fetchString: doc_id, returnStr: "recordId")
                                            
                                            
                                            let ReplyDict:[AnyHashable: Any] = ["from":Themes.sharedInstance.Getuser_id(),"to":to,"type":"0","payload":EncryptionHandler.sharedInstance.encryptmessage(str:payload.decoded,toid:to, chat_type: chat_type),"toDocId":EncryptionHandler.sharedInstance.encryptmessage(str:doc_id,toid:to, chat_type: chat_type),"id":EncryptionHandler.sharedInstance.encryptmessage(str:timestamp,toid:to, chat_type: chat_type),"recordId":recordID,"chat_type":"secret"]
                                            SocketIOManager.sharedInstance.EmitReplyMessage(param: ReplyDict as NSDictionary)
                                        }
                                    }
                                    else
                                    {
                                        if(is_reply == "0")
                                        {
                                            let displayName = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Group_details, attrib_name: "id", fetchString: to, returnStr: "displayName")
                                            let Groupdic:[AnyHashable: Any] = ["from":Themes.sharedInstance.Getuser_id(),"to":to,"type":"0","payload":EncryptionHandler.sharedInstance.encryptmessage(str:payload.decoded,toid:to, chat_type: chat_type),"convId":to,"toDocId":EncryptionHandler.sharedInstance.encryptmessage(str:doc_id,toid:to, chat_type: chat_type),"groupType":"9","userName":displayName,"id":EncryptionHandler.sharedInstance.encryptmessage(str:timestamp,toid:to, chat_type: chat_type)]
                                            SocketIOManager.sharedInstance.SendMessage_group(param: Groupdic as NSDictionary)
                                        }
                                        else
                                        {
                                            let displayName = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Group_details, attrib_name: "id", fetchString: to, returnStr: "displayName")
                                            
                                            let recordID:String = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Reply_detail, attrib_name: "doc_id", fetchString: doc_id, returnStr: "recordId")
                                            
                                            
                                            
                                            let ReplyDict:[AnyHashable: Any] = ["from":Themes.sharedInstance.Getuser_id(),"to":to,"type":"0","payload":EncryptionHandler.sharedInstance.encryptmessage(str:payload.decoded,toid:to, chat_type: chat_type),"toDocId":EncryptionHandler.sharedInstance.encryptmessage(str:doc_id,toid:to, chat_type: chat_type),"id":EncryptionHandler.sharedInstance.encryptmessage(str:Themes.sharedInstance.CheckNullvalue(Passed_value: timestamp),toid:to, chat_type: chat_type),"recordId":recordID,"groupType":"18","userName":displayName,"convId":to]
                                            
                                            SocketIOManager.sharedInstance.EmitGroupReplyMessage(param: ReplyDict as NSDictionary)
                                        }
                                    }
                                    
                                }
                                if(message_type == "13")
                                {
                                    
                                    let to = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"to"))
                                    let payload = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"payload"))
                                    let doc_id = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"doc_id"))
                                    let timestamp = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"timestamp"))
                                    
                                    let incognito_timer = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Secret_Chat, attrib_name: "doc_id", fetchString: doc_id, returnStr: "incognito_timer")
                                    
                                    
                                    let dic = ["from":Themes.sharedInstance.Getuser_id(),"to":to,"incognito_timer_mode":payload,"payload":payload,"chat_type":"secret","type":"13","toDocId":doc_id,"incognito_timer":incognito_timer,"id":timestamp,"secret_type":"no"]
                                    
                                    SocketIOManager.sharedInstance.changeExpirationTime(param: dic)
                                    
                                }
                                else if(message_type == "1")
                                {
                                    
                                    let thumbail = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"thumbnail"))
                                    let payload = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"payload"))
                                    let chat_type:String = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"chat_type"))
                                    let toDocId:String=thumbail
                                    
                                    let upload_status:String = Themes.sharedInstance.CheckNullvalue(Passed_value: self.ReturnuploadDetails(pathid: toDocId, upload_detail: "upload_status")! as! String)
                                    
                                    if(upload_status == "1")
                                    {
                                        
                                        
                                        let timestamp:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"timestamp"))
                                        var thumbnail:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "serverpath")! as! String
                                        thumbnail = thumbnail.replacingOccurrences(of: ImgUrl, with: ".")
                                        
                                        let to:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "to_id")! as! String
                                        let thumbnail_data:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "compressed_data")! as! String
                                        let total_byte_count:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "total_byte_count")! as! String
                                        let height:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "height")! as! String
                                        let width:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "width")! as! String
                                        
                                        let doc_id = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"doc_id"))
                                        
                                        // DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { {
                                        // your code here
                                        if(chat_type == "secret"){
                                            SocketIOManager.sharedInstance.secretMessage(from: Themes.sharedInstance.Getuser_id(), to: "\(to)", payload: payload, type: "1", timestamp: Themes.sharedInstance.CheckNullvalue(Passed_value:"\(timestamp)"), DocID: doc_id, thumbnail: thumbnail, thumbnail_data: thumbnail_data,filesize: total_byte_count,height: height,width: width,doc_name:"",numPages:"", duration: duration, chat_type: "secret")
                                        }
                                        if(chat_type == "group"){
                                            
                                            let displayName = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Group_details, attrib_name: "id", fetchString: to, returnStr: "displayName")
                                            
                                            let Groupdic:[String: Any] = ["from":Themes.sharedInstance.Getuser_id(),"to":"\(to)","type":"1","payload":EncryptionHandler.sharedInstance.encryptmessage(str:payload.decoded,toid:to, chat_type: chat_type),"convId":"\(to)","toDocId":EncryptionHandler.sharedInstance.encryptmessage(str:"\(doc_id)",toid:to, chat_type: chat_type),"groupType":"9","userName":displayName,"id":EncryptionHandler.sharedInstance.encryptmessage(str:Themes.sharedInstance.CheckNullvalue(Passed_value: timestamp),toid:to, chat_type: chat_type),"thumbnail":EncryptionHandler.sharedInstance.encryptmessage(str:"\(thumbnail)",toid:to, chat_type: chat_type),"filesize":total_byte_count,"height": height,"width": width,"thumbnail_data":thumbnail_data]
                                            SocketIOManager.sharedInstance.SendMessage_group(param: Groupdic as NSDictionary)
                                        }
                                        else{
                                            let secrettype:String = Themes.sharedInstance.returnisSecret(user_id: to)
                                            
                                            SocketIOManager.sharedInstance.SendMessage(from: Themes.sharedInstance.Getuser_id(), to: "\(to)", payload: payload, type: "1", timestamp: Themes.sharedInstance.CheckNullvalue(Passed_value:"\(timestamp)"), DocID: toDocId, thumbnail: thumbnail, thumbnail_data: thumbnail_data,filesize: total_byte_count,height: height,width: width,doc_name:"",numPages:"", duration: duration,is_secret_chat: secrettype)
                                        }
                                        
                                        //                                    }
                                    }
                                    
                                }
                                    
                                else if(message_type == "2")
                                {
                                    let thumbail = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"thumbnail"))
                                    
                                    let payload = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"payload"))
                                    
                                    let toDocId:String=thumbail
                                    
                                    let doc_id = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"doc_id"))
                                    
                                    let upload_status:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "upload_status")! as! String
                                    
                                    
                                    if(upload_status == "1")
                                    {
                                        
                                        
                                        let timestamp:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"timestamp"))
                                        let chat_type:String = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"chat_type"))
                                        var thumbnail:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "serverpath")! as! String
                                        thumbnail = thumbnail.replacingOccurrences(of: ImgUrl, with: ".")
                                        let to:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "to_id")! as! String
                                        let thumbnail_data:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "compressed_data")! as! String
                                        let total_byte_count:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "total_byte_count")! as! String
                                        let height:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "height")! as! String
                                        let width:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "width")! as! String
                                        
                                        
                                        // DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { {
                                        // your code here
                                        if(chat_type == "secret"){
                                            SocketIOManager.sharedInstance.secretMessage(from: Themes.sharedInstance.Getuser_id(), to: "\(to)", payload: payload, type: "2", timestamp: Themes.sharedInstance.CheckNullvalue(Passed_value:"\(timestamp)"), DocID: doc_id, thumbnail: thumbnail, thumbnail_data: thumbnail_data,filesize: total_byte_count,height: height,width: width,doc_name:"",numPages:"", duration: duration, chat_type: "secret")
                                        }
                                        else if(chat_type == "group"){
                                            let displayName = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Group_details, attrib_name: "id", fetchString: to, returnStr: "displayName")
                                            
                                            let Groupdic:[AnyHashable: Any] = ["from":Themes.sharedInstance.Getuser_id(),"to":"\(to)","type":"2","payload":EncryptionHandler.sharedInstance.encryptmessage(str:payload.decoded,toid:to, chat_type: chat_type),"convId":"\(to)","toDocId":EncryptionHandler.sharedInstance.encryptmessage(str:"\(toDocId)",toid:to, chat_type: chat_type),"groupType":"9","userName":displayName,"id":EncryptionHandler.sharedInstance.encryptmessage(str:Themes.sharedInstance.CheckNullvalue(Passed_value: timestamp),toid:to, chat_type: chat_type),"thumbnail":"\(thumbnail)","filesize":total_byte_count,"height": height,"width": width,"thumbnail_data":thumbnail_data, "duration" : duration]
                                            
                                            SocketIOManager.sharedInstance.SendMessage_group(param: Groupdic as NSDictionary)
                                        }
                                        else{
                                            let secrettype:String = Themes.sharedInstance.returnisSecret(user_id: to)
                                            
                                            SocketIOManager.sharedInstance.SendMessage(from: Themes.sharedInstance.Getuser_id(), to: "\(to)", payload: Themes.sharedInstance.CheckNullvalue(Passed_value: payload), type: "2", timestamp: Themes.sharedInstance.CheckNullvalue(Passed_value:"\(timestamp)"), DocID: doc_id, thumbnail: thumbnail, thumbnail_data: thumbnail_data,filesize: total_byte_count,height: height,width: width,doc_name:"",numPages:"", duration: duration,is_secret_chat: secrettype)
                                        }
                                    }
                                }
                                else if(message_type == "3")
                                {
                                    let thumbail = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"thumbnail"))
                                    
                                    let toDocId:String=thumbail
                                    
                                    let upload_status:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "upload_status")! as! String
                                    let doc_id = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"doc_id"))
                                    if(upload_status == "1")
                                    {
                                        
                                        let timestamp:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"timestamp"))
                                        let chat_type:String = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"chat_type"))
                                        let payload:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"payload"))
                                        var thumbnail:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "serverpath")! as! String
                                        thumbnail = thumbnail.replacingOccurrences(of: ImgUrl, with: ".")
                                        let to:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "to_id")! as! String
                                        let thumbnail_data:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "compressed_data")! as! String
                                        let total_byte_count:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "total_byte_count")! as! String
                                        let height:String = "0.0"
                                        let width:String = "0.0"
                                        // DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { {
                                        // your code here
                                        if(chat_type == "secret"){
                                            SocketIOManager.sharedInstance.secretMessage(from: Themes.sharedInstance.Getuser_id(), to: "\(to)", payload: payload, type: "3", timestamp: Themes.sharedInstance.CheckNullvalue(Passed_value:"\(timestamp)"), DocID: doc_id, thumbnail: thumbnail, thumbnail_data: thumbnail_data,filesize: total_byte_count,height: height,width: width,doc_name:"",numPages:"", duration: duration, chat_type: "secret")
                                        }
                                        else if(chat_type == "group"){
                                            let displayName = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Group_details, attrib_name: "id", fetchString: to, returnStr: "displayName")
                                            
                                            let Groupdic:[AnyHashable: Any] = ["from":Themes.sharedInstance.Getuser_id(),"to":to,"type":"3","payload":EncryptionHandler.sharedInstance.encryptmessage(str:payload.decoded,toid:to, chat_type: chat_type),"convId":"\(to)","toDocId":EncryptionHandler.sharedInstance.encryptmessage(str:"\(doc_id)",toid:to, chat_type: chat_type),"groupType":"9","userName":displayName,"id":EncryptionHandler.sharedInstance.encryptmessage(str:Themes.sharedInstance.CheckNullvalue(Passed_value: timestamp),toid:to, chat_type: chat_type),"thumbnail":EncryptionHandler.sharedInstance.encryptmessage(str:"\(thumbnail)",toid:to, chat_type: chat_type),"thumbnail_data": thumbnail_data,"filesize":total_byte_count,"height": "0.0","width": "0.0","duration" : duration, "audio_type" : "1"]
                                            SocketIOManager.sharedInstance.SendMessage_group(param: Groupdic as NSDictionary)
                                            
                                            
                                        }
                                            
                                        else{
                                            let secrettype:String = Themes.sharedInstance.returnisSecret(user_id: to)
                                            
                                            SocketIOManager.sharedInstance.SendMessage(from: Themes.sharedInstance.Getuser_id(), to: "\(to)", payload: payload, type: "3", timestamp: Themes.sharedInstance.CheckNullvalue(Passed_value:"\(timestamp)"), DocID: doc_id, thumbnail: thumbnail, thumbnail_data: thumbnail_data,filesize: total_byte_count,height: height,width: width,doc_name:"",numPages:"", duration: duration,is_secret_chat: secrettype)
                                        }
                                        
                                        //                                    }
                                        
                                    }
                                    
                                    
                                }
                                    
                                    
                                    
                                else if(message_type == "6" || message_type == "20")
                                {
                                    let thumbail = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"thumbnail"))
                                    
                                    let toDocId:String=thumbail
                                    
                                    let upload_status:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "upload_status")! as! String
                                    
                                    if(upload_status == "1")
                                    {
                                        
                                        
                                        let timestamp:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"timestamp"))
                                        
                                        var payload:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"payload"))
                                        
                                        payload = (payload.length == 0) ? "Piture" : payload
                                        let chat_type:String = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"chat_type"))
                                        var thumbnail:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "serverpath")! as! String
                                        thumbnail = thumbnail.replacingOccurrences(of: ImgUrl, with: ".")
                                        let to:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "to_id")! as! String
                                        let thumbnail_data:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "compressed_data")! as! String
                                        let total_byte_count:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "total_byte_count")! as! String
                                        
                                        let doc_name:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "doc_name")! as! String
                                        
                                        
                                        let doc_pagecount:String = self.ReturnuploadDetails(pathid: toDocId, upload_detail: "doc_pagecount")! as! String
                                        
                                        
                                        let height:String = "0.0"
                                        let width:String = "0.0"
                                        
                                        
                                        // DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { {
                                        // your code here
                                        if(chat_type == "secret"){
                                            SocketIOManager.sharedInstance.secretMessage(from: Themes.sharedInstance.Getuser_id(), to: "\(to)", payload: payload, type: "20", timestamp: Themes.sharedInstance.CheckNullvalue(Passed_value:"\(timestamp)"), DocID: toDocId, thumbnail: thumbnail, thumbnail_data: thumbnail_data,filesize: total_byte_count,height: height,width: width,doc_name:doc_name,numPages:doc_pagecount, duration: duration, chat_type: "secret")
                                        }
                                        else if(chat_type == "group")
                                        {
                                            let displayName = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Group_details, attrib_name: "id", fetchString: to, returnStr: "displayName")
                                            
                                            let Groupdic:[AnyHashable: Any] = ["from":Themes.sharedInstance.Getuser_id(),"to":to,"type":"20","payload":EncryptionHandler.sharedInstance.encryptmessage(str:payload.decoded,toid:to, chat_type: chat_type),"convId":"\(to)","toDocId":EncryptionHandler.sharedInstance.encryptmessage(str:"\(toDocId)",toid:to, chat_type: chat_type),"groupType":"9","userName":displayName,"id":EncryptionHandler.sharedInstance.encryptmessage(str:Themes.sharedInstance.CheckNullvalue(Passed_value: timestamp),toid:to, chat_type: chat_type),"thumbnail":EncryptionHandler.sharedInstance.encryptmessage(str:"\(thumbnail)",toid:to, chat_type: chat_type),"thumbnail_data": thumbnail_data,"filesize":total_byte_count,"height": "0.0","width": "0.0","original_filename":EncryptionHandler.sharedInstance.encryptmessage(str:doc_name,toid:to, chat_type: chat_type),"numPages": ""]
                                            SocketIOManager.sharedInstance.SendMessage_group(param: Groupdic as NSDictionary)
                                            
                                        }
                                        else{
                                            
                                            let secrettype:String = Themes.sharedInstance.returnisSecret(user_id: to)
                                            SocketIOManager.sharedInstance.SendMessage(from: Themes.sharedInstance.Getuser_id(), to: "\(to)", payload: payload, type: "20", timestamp: Themes.sharedInstance.CheckNullvalue(Passed_value:"\(timestamp)"), DocID: toDocId, thumbnail: thumbnail, thumbnail_data: thumbnail_data,filesize: total_byte_count,height: height,width: width,doc_name:doc_name,numPages:doc_pagecount, duration: duration,is_secret_chat: secrettype)
                                        }
                                        
                                        //                                    }
                                        
                                        
                                    }
                                    
                                    
                                    
                                    
                                }else if(message_type == "4"){
                                    
                                    var title:String = ""
                                    var image_url:String = ""
                                    var desc:String = ""
                                    var url_str:String = ""
                                    var thumbnail_data:String = ""
                                    
                                    let doc_id = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"doc_id"))
                                    let message:String = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"payload"))
                                    let chat_type:String = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"chat_type"))
                                    let timestamp:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"timestamp"))
                                    let to:String = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"to"))
                                    let link_array:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Link_details, attribute: "doc_id", FetchString: doc_id, SortDescriptor: nil) as! NSArray
                                    if(link_array.count > 0){
                                        for i in 0..<link_array.count{
                                            let ResponseDict:NSManagedObject = link_array[i] as! NSManagedObject
                                            title = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "title"))
                                            image_url =  Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "image_url"))
                                            desc = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "desc"))
                                            url_str = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "url_str"))
                                            thumbnail_data = Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "thumbnail_data"))
                                        }
                                    }
                                    
                                    // DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { {
                                    // your code here
                                    if(chat_type == "single"){
                                        let param:NSDictionary = ["title":Themes.sharedInstance.CheckNullvalue(Passed_value: title),"host":"","url":Themes.sharedInstance.CheckNullvalue(Passed_value: url_str),"description":Themes.sharedInstance.CheckNullvalue(Passed_value:desc).decoded,"image":Themes.sharedInstance.CheckNullvalue(Passed_value:image_url),"thumbnail_data":Themes.sharedInstance.CheckNullvalue(Passed_value:thumbnail_data)]
                                        
                                        let metadict  = param
                                        
                                        let Dict:Dictionary = ["from":Themes.sharedInstance.Getuser_id(),"to":to,"payload":EncryptionHandler.sharedInstance.encryptmessage(str:Themes.sharedInstance.CheckNullvalue(Passed_value:"\(message.decoded)"
                                        ),toid:to, chat_type: chat_type),"id":EncryptionHandler.sharedInstance.encryptmessage(str:"\(timestamp)",toid:to, chat_type: chat_type),"type":"4","toDocId":EncryptionHandler.sharedInstance.encryptmessage(str:"\(doc_id)",toid:to, chat_type: chat_type),"metaDetails":metadict] as [String : Any]
                                        SocketIOManager.sharedInstance.EmitMessage(param: Dict)
                                    }
                                    if(chat_type == "group"){
                                        let param:NSDictionary = ["title":Themes.sharedInstance.CheckNullvalue(Passed_value: title),"host":"","url":Themes.sharedInstance.CheckNullvalue(Passed_value: url_str),"description":Themes.sharedInstance.CheckNullvalue(Passed_value:desc).decoded,"image":Themes.sharedInstance.CheckNullvalue(Passed_value:image_url),"thumbnail_data":Themes.sharedInstance.CheckNullvalue(Passed_value:thumbnail_data)]
                                        
                                        let metadict  = param
                                        
                                        let displayName = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Group_details, attrib_name: "id", fetchString: to, returnStr: "displayName")
                                        let Dict:Dictionary = ["from":Themes.sharedInstance.Getuser_id(),"to":to,"payload":EncryptionHandler.sharedInstance.encryptmessage(str:Themes.sharedInstance.CheckNullvalue(Passed_value:"\(message.decoded)"
                                        ),toid:to, chat_type: chat_type),"id":EncryptionHandler.sharedInstance.encryptmessage(str:"\(timestamp)",toid:to, chat_type: chat_type),"type":"4","toDocId":EncryptionHandler.sharedInstance.encryptmessage(str:doc_id,toid:to, chat_type: chat_type),"metaDetails":metadict,"groupType":"9","userName":displayName,"convId":to] as [String : Any]
                                        SocketIOManager.sharedInstance.Groupevent(param: Dict)
                                        
                                    }
                                    else if(chat_type == "secret"){
                                        let param:NSDictionary = ["title":Themes.sharedInstance.CheckNullvalue(Passed_value: title),"host":"","url":Themes.sharedInstance.CheckNullvalue(Passed_value: url_str),"description":Themes.sharedInstance.CheckNullvalue(Passed_value:desc).decoded,"image":Themes.sharedInstance.CheckNullvalue(Passed_value:image_url),"thumbnail_data":Themes.sharedInstance.CheckNullvalue(Passed_value:thumbnail_data)]
                                        
                                        let metadict  = param
                                        
                                        let Dict:Dictionary = ["from":Themes.sharedInstance.Getuser_id(),"to":to,"payload":EncryptionHandler.sharedInstance.encryptmessage(str:Themes.sharedInstance.CheckNullvalue(Passed_value:"\(message.decoded)"
                                        ),toid:to, chat_type: chat_type),"id":EncryptionHandler.sharedInstance.encryptmessage(str:"\(timestamp)",toid:to, chat_type: chat_type),"type":"4","toDocId":EncryptionHandler.sharedInstance.encryptmessage(str:"\(doc_id)",toid:to, chat_type: chat_type),"metaDetails":metadict,"chat_type":"secret"] as [String : Any]
                                        SocketIOManager.sharedInstance.EmitMessage(param: Dict)
                                    }
                                    else{
                                        let param:NSDictionary = ["title":Themes.sharedInstance.CheckNullvalue(Passed_value: title),"host":"","url":Themes.sharedInstance.CheckNullvalue(Passed_value: url_str),"description":Themes.sharedInstance.CheckNullvalue(Passed_value:desc).decoded,"image":Themes.sharedInstance.CheckNullvalue(Passed_value:image_url),"thumbnail_data":Themes.sharedInstance.CheckNullvalue(Passed_value:thumbnail_data)]
                                        
                                        let metadict  = param
                                        
                                        let displayName = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Group_details, attrib_name: "id", fetchString: to, returnStr: "displayName")
                                        let Dict:Dictionary = ["from":Themes.sharedInstance.Getuser_id(),"to":to,"payload":EncryptionHandler.sharedInstance.encryptmessage(str:Themes.sharedInstance.CheckNullvalue(Passed_value:"\(message.decoded)"
                                        ),toid:to, chat_type: chat_type),"id":EncryptionHandler.sharedInstance.encryptmessage(str:"\(timestamp)",toid:to, chat_type: chat_type),"type":"4","toDocId":EncryptionHandler.sharedInstance.encryptmessage(str:doc_id,toid:to, chat_type: chat_type),"metaDetails":metadict,"groupType":"9","userName":displayName,"convId":to] as [String : Any]
                                        SocketIOManager.sharedInstance.Groupevent(param: Dict)
                                    }
                                    //                                }
                                    
                                    
                                    
                                }else if(message_type == "14"){
                                    let doc_id = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"doc_id"))
                                    let timestamp:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"timestamp"))
                                    let chat_type:String = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"chat_type"))
                                    let to:String = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"to"))
                                    
                                    var Latitude:String = ""
                                    var longitude:String = ""
                                    var title_place:String = ""
                                    var Stitle_place:String = ""
                                    var image_link:String = ""
                                    var thumbnail_data:String = ""
                                    var redirect_link:String = ""
                                    
                                    let ChekLocation:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Location_details, attribute: "doc_id", FetchString: doc_id)
                                    if(ChekLocation)
                                    {
                                        let LocationArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Location_details, attribute: "doc_id", FetchString: doc_id, SortDescriptor: nil) as! NSArray
                                        for i in 0..<LocationArr.count
                                        {
                                            let ObjRecord:NSManagedObject = LocationArr[i] as! NSManagedObject
                                            redirect_link = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "redirect_link"))
                                            Latitude = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "lat"))
                                            longitude =  Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "long"))
                                            title_place = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "title"))
                                            Stitle_place = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "stitle"))
                                            image_link = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "image_link"))
                                            thumbnail_data = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "thumbnail_data"))
                                            
                                        }
                                    }
                                    
                                    // DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { {
                                    if(chat_type == "single"){
                                        let param:NSDictionary = ["title":Themes.sharedInstance.CheckNullvalue(Passed_value: title_place),"url":redirect_link,"description":Themes.sharedInstance.CheckNullvalue(Passed_value:Stitle_place),"image":image_link,"thumbnail_data":thumbnail_data]
                                        
                                        let metadict  = param
                                        
                                        let Dict:Dictionary = ["from":Themes.sharedInstance.Getuser_id(),"to":to,"payload": EncryptionHandler.sharedInstance.encryptmessage(str: "\(Latitude),\(longitude)",toid:to, chat_type: chat_type),"id":EncryptionHandler.sharedInstance.encryptmessage(str:"\(timestamp)",toid:to, chat_type: chat_type),"type":"14","toDocId":EncryptionHandler.sharedInstance.encryptmessage(str:doc_id,toid:to, chat_type: chat_type),"metaDetails":metadict] as [String : Any]
                                        
                                        SocketIOManager.sharedInstance.EmitMessage(param: Dict)
                                    }
                                    else if(chat_type == "group")
                                    {
                                        let param:NSDictionary = ["title":Themes.sharedInstance.CheckNullvalue(Passed_value: title_place),"url":redirect_link,"description":Themes.sharedInstance.CheckNullvalue(Passed_value:Stitle_place),"image":image_link,"thumbnail_data":thumbnail_data]
                                        
                                        let metadict  = param
                                        
                                        let displayName = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Group_details, attrib_name: "id", fetchString: to, returnStr: "displayName")
                                        
                                        let Dict:Dictionary = ["from":Themes.sharedInstance.Getuser_id(),"to":to,"payload": EncryptionHandler.sharedInstance.encryptmessage(str: "\(Latitude),\(longitude)",toid:to, chat_type: chat_type),"id":EncryptionHandler.sharedInstance.encryptmessage(str:"\(timestamp)",toid:to, chat_type: chat_type),"type":"14","toDocId":EncryptionHandler.sharedInstance.encryptmessage(str:doc_id,toid:to, chat_type: chat_type),"metaDetails":metadict,"groupType":"9","userName":displayName,"convId":to] as [String : Any]
                                        SocketIOManager.sharedInstance.Groupevent(param: Dict)
                                        
                                    }
                                    else if(chat_type == "secret"){
                                        let param:NSDictionary = ["title":Themes.sharedInstance.CheckNullvalue(Passed_value: title_place),"url":redirect_link,"description":Themes.sharedInstance.CheckNullvalue(Passed_value:Stitle_place),"image":image_link,"thumbnail_data":thumbnail_data]
                                        
                                        let metadict  = param
                                        
                                        let Dict:Dictionary = ["from":Themes.sharedInstance.Getuser_id(),"to":to,"payload":EncryptionHandler.sharedInstance.encryptmessage(str: "\(Latitude),\(longitude)",toid:to, chat_type: chat_type),"id":EncryptionHandler.sharedInstance.encryptmessage(str: timestamp,toid:to, chat_type: chat_type),"type":"14","toDocId":EncryptionHandler.sharedInstance.encryptmessage(str:doc_id,toid:to, chat_type: chat_type),"metaDetails":metadict,"chat_type":"secret"] as [String : Any]
                                        SocketIOManager.sharedInstance.EmitMessage(param: Dict)
                                    }
                                }else if(message_type == "5"){
                                    var contact_id:String = ""
                                    var contact_profile:String = ""
                                    var contact_name:String = ""
                                    var contact_phone:String = ""
                                    var contact_details:String = ""
                                    let doc_id = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"doc_id"))
                                    let timestamp:String=Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"timestamp"))
                                    let chat_type:String = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"chat_type"))
                                    let to:String = Themes.sharedInstance.CheckNullvalue(Passed_value: Chat_one_ReponseDict.value(forKey:"to"))
                                    
                                    let ChekLocation:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Contact_details, attribute: "doc_id", FetchString: doc_id)
                                    
                                    if(ChekLocation)
                                    {
                                        let ContactArr:NSArray = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Contact_details, attribute: "doc_id", FetchString: doc_id, SortDescriptor: nil) as! NSArray
                                        for i in 0..<ContactArr.count
                                        {
                                            let ObjRecord:NSManagedObject = ContactArr[i] as! NSManagedObject
                                            contact_id = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "contact_id"))
                                            contact_profile =  Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "contact_profile"))
                                            contact_name = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "contact_name"))
                                            contact_phone = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "contact_phone"))
                                            contact_details = Themes.sharedInstance.CheckNullvalue(Passed_value: ObjRecord.value(forKey: "contact_details"))
                                        }
                                    }
                                    
                                    // DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { {
                                    let details:NSMutableDictionary = ["contact_profile":contact_profile,"contact_phone":contact_phone,"id":contact_id,"contactDetails":contact_details]
                                    if(chat_type == "single"){
                                        if let json = try?JSONSerialization.data(withJSONObject: details, options: []) {
                                            // here `json` is your JSON data
                                            if String(data: json, encoding: String.Encoding.utf8) != nil {
                                                // here `content` is the JSON data decoded as a String
                                                let Dict:Dictionary = ["from":Themes.sharedInstance.Getuser_id(),"to":to,"payload":"","id":EncryptionHandler.sharedInstance.encryptmessage(str:"\(timestamp)",toid:to, chat_type: chat_type),"type":"5","toDocId":EncryptionHandler.sharedInstance.encryptmessage(str:"\(doc_id)",toid:to, chat_type: chat_type),"contact_name":contact_name,"createdTomsisdn":contact_phone,"contactDetails":EncryptionHandler.sharedInstance.encryptmessage(str:  contact_details,toid:to, chat_type: chat_type),"createdTo":to] as [String : Any]
                                                SocketIOManager.sharedInstance.EmitMessage(param: Dict)
                                            }
                                        }
                                    }
                                    else if(chat_type == "group")
                                    {
                                        
                                        if let json = try?JSONSerialization.data(withJSONObject: details, options: []) {
                                            // here `json` is your JSON data
                                            if String(data: json, encoding: String.Encoding.utf8) != nil {
                                                // here `content` is the JSON data decoded as a String
                                                let displayName = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Group_details, attrib_name: "id", fetchString: to, returnStr: "displayName")
                                                
                                                let Dict:Dictionary = ["from":Themes.sharedInstance.Getuser_id(),"to":to,"payload":"","id":EncryptionHandler.sharedInstance.encryptmessage(str:"\(timestamp)",toid:to, chat_type: chat_type),"type":"5","toDocId":EncryptionHandler.sharedInstance.encryptmessage(str:"\(doc_id)",toid:to, chat_type: chat_type),"contact_name":contact_name,"createdTomsisdn":contact_phone,"contactDetails":EncryptionHandler.sharedInstance.encryptmessage(str:  contact_details,toid:to, chat_type: chat_type),"createdTo":Themes.sharedInstance.Getuser_id(),"chat_type":"group","groupType":"9","userName":displayName,"convId":to] as [String : Any]
                                                
                                                
                                                SocketIOManager.sharedInstance.Groupevent(param: Dict)
                                            }
                                        }
                                    }
                                    else if(chat_type == "secret"){
                                        if let json = try?JSONSerialization.data(withJSONObject: details, options: []) {
                                            // here `json` is your JSON data
                                            if String(data: json, encoding: String.Encoding.utf8) != nil {
                                                // here `content` is the JSON data decoded as a String
                                                let Dict:Dictionary = ["from":Themes.sharedInstance.Getuser_id(),"to":to,"payload":"","id":EncryptionHandler.sharedInstance.encryptmessage(str:"\(timestamp)",toid:to, chat_type: chat_type),"type":"5","toDocId":EncryptionHandler.sharedInstance.encryptmessage(str:"\(doc_id)",toid:to, chat_type: chat_type),"contact_name":contact_name,"createdTomsisdn":contact_phone,"contactDetails":EncryptionHandler.sharedInstance.encryptmessage(str:  contact_details,toid:to, chat_type: chat_type),"createdTo":to,"chat_type":"secret"] as [String : Any]
                                                
                                                SocketIOManager.sharedInstance.EmitMessage(param: Dict)
                                            }
                                        }
                                    }
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
        let p3 = NSPredicate(format: "upload_paused != %@", "1")
        
        let compound = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2, p3])
        
        let UploadDetailArr = DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Upload_Details, SortDescriptor: nil, predicate: compound, Limit: 0) as! [Upload_Details]
        
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
                    SocketIOManager.sharedInstance.getFileInfoBytes(imageName: upload_data_id, uploadType: "single_chat")
                    break
                }
                else
                {
                    let pred = NSPredicate(format: "upload_data_id == %@",   Themes.sharedInstance.CheckNullvalue(Passed_value: ReponseDict.upload_data_id))
                    DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Upload_Details, Predicatefromat: pred, Deletestring: nil, AttributeName: nil)
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
        
        let UploadDetailArr = DatabaseHandler.sharedInstance.FetchFromDatabaseWithPredicate(Entityname: Constant.sharedinstance.Upload_Details, SortDescriptor: nil, predicate: p1, Limit: 0) as! [Upload_Details]
        
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
                    DatabaseHandler.sharedInstance.DeleteFromDataBase(Entityname: Constant.sharedinstance.Upload_Details, Predicatefromat: pred, Deletestring: nil, AttributeName: nil)
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
    
    func loadMyImage(messageFrame : UUMessageFrame, imageView: UIImageView, isLoaderShow: Bool, completion: (() -> Swift.Void)? = nil)
    {
        imageView.subviews.forEach { view in
            if(view.isKind(of: ACPDownloadView.self))
            {
                view.removeFromSuperview()
            }
        }
        imageView.image = nil
        if(messageFrame.message.type == MessageType(rawValue: 1))
        {
            let download_status:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "download_status") as! String
            
            if messageFrame.message.from == MessageFrom(rawValue: 1)!
            {
                if(download_status == "2")
                {
                    let PhotoPath:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "upload_Path") as! String
                    
                    if(PhotoPath != "")
                    {
                        if FileManager.default.fileExists(atPath: PhotoPath) {
                            let url = URL(fileURLWithPath: PhotoPath)
                            //        let data = NSData(contentsOf: url as URL)
                            imageView.sd_setImage(with: url)
                            if(completion != nil)
                            {
                                completion!()
                            }
                        }
                        else
                        {
                            let autodownload  = self.GetAutoDownloadInfo(file_type: "photos", download_status: download_status)
                            if(autodownload)
                            {
                                let serverpath:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "serverpath") as! String
                                var ThembnailData:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "compressed_data") as! String
                                let str:String = "data:image/jpg;base64,";
                                if !ThembnailData.contains("data:image")
                                {
                                    ThembnailData = str.appending(ThembnailData)
                                }
                                
                                imageView.sd_setImage(with: URL(string:ThembnailData)!)
                                
                                let url = URL(string: serverpath)
                                
                                let downloadView = self.downloadView
                                if(isLoaderShow)
                                {
                                    let width : CGFloat = 50
                                    downloadView.frame = CGRect(x: (imageView.frame.size.width - width)/2, y: (imageView.frame.size.height - width)/2, width: width, height: width)
                                    imageView.addSubview(downloadView)
                                }
                                
                                SDWebImageManager.shared().imageDownloader?.downloadImage(with: url, options: .highPriority, progress: nil, completed: { (image:UIImage?, data:Data?, erro:Error?, downloaded:Bool) in
                                    if(image != nil)
                                    {
                                        downloadView.removeFromSuperview()
                                        let imagedata = image!.jpegData(compressionQuality: 1.0)!
                                        let assetname:String = messageFrame.message.thumbnail! + ".jpg"
                                        let Path:String =  Filemanager.sharedinstance.SaveImageFile(imagePath: "\(Constant.sharedinstance.photopath)/\(assetname)",imagedata: imagedata)
                                        imageView.image = image!
                                        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Upload_Details, FetchString: messageFrame.message.thumbnail!, attribute: "upload_data_id", UpdationElements: ["download_status" : "2","upload_Path":Path])
                                        if(completion != nil)
                                        {
                                            completion!()
                                        }
                                    }
                                })
                            }
                            else
                            {
                                var ThembnailData:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "compressed_data") as! String
                                let str:String = "data:image/jpg;base64,";
                                if !ThembnailData.contains("data:image")
                                {
                                    ThembnailData = str.appending(ThembnailData)
                                }
                                imageView.sd_setImage(with: URL(string:ThembnailData))
                                let downloadView = self.downloadView
                                if(isLoaderShow)
                                {
                                    let width : CGFloat = 50
                                    downloadView.frame = CGRect(x: (imageView.frame.size.width - width)/2, y: (imageView.frame.size.height - width)/2, width: width, height: width)
                                    
                                    downloadView.isUserInteractionEnabled = true
                                    downloadView.setIndicatorStatus(.none)
                                    
                                    imageView.addSubview(downloadView)
                                    
                                    downloadView.setActionForTap { (downloadView, status) in
                                        switch (status)
                                        {
                                        case .none:
                                            self.startDownload(messageFrame: messageFrame)
                                            downloadView?.isUserInteractionEnabled = false
                                            downloadView?.setIndicatorStatus(.indeterminate)
                                            break;
                                        case .running:
                                            downloadView?.setIndicatorStatus(.completed)
                                            break;
                                        case .indeterminate:
                                            downloadView?.setIndicatorStatus(.running)
                                            break;
                                        case .completed:
                                            downloadView?.setIndicatorStatus(.none)
                                            break;
                                        }
                                    }
                                }
                            }
                            
                        }
                        
                    }
                    else
                        
                    {
                        imageView.image = UIImage(named:"VideoThumbnail")
                    }
                }
                    
                else
                {
                    let autodownload  = self.GetAutoDownloadInfo(file_type: "photos", download_status: download_status)
                    if(autodownload)
                    {
                        let serverpath:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "serverpath") as! String
                        var ThembnailData:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "compressed_data") as! String
                        let str:String = "data:image/jpg;base64,";
                        if !ThembnailData.contains("data:image")
                        {
                            ThembnailData = str.appending(ThembnailData)
                        }
                        if(ThembnailData != "")
                        {
                            imageView.sd_setImage(with: URL(string:ThembnailData)!)
                        }
                        DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Upload_Details, FetchString: messageFrame.message.thumbnail!, attribute: "upload_data_id", UpdationElements: ["download_status" : "1"])
                        
                        if(serverpath != "")
                        {
                            
                            let downloadView = self.downloadView
                            if(isLoaderShow)
                            {
                                let width : CGFloat = 50.0
                                downloadView.frame = CGRect(x: (imageView.frame.size.width - width)/2, y: (imageView.frame.size.height - width)/2, width: width, height: width)
                                imageView.addSubview(downloadView)
                            }
                            
                            SDWebImageManager.shared().imageDownloader?.downloadImage(with: URL(string:serverpath), options: .highPriority, progress: nil, completed: { (image:UIImage?, data:Data?, erro:Error?, downloaded:Bool) in
                                if(image != nil)
                                {
                                    downloadView.removeFromSuperview()
                                    
                                    let imagedata = image!.jpegData(compressionQuality: 1.0)!
                                    let assetname:String = messageFrame.message.thumbnail! + ".jpg"
                                    let Path:String =  Filemanager.sharedinstance.SaveImageFile(imagePath: "\(Constant.sharedinstance.photopath)/\(assetname)",imagedata: imagedata)
                                    imageView.image = image!
                                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Upload_Details, FetchString: messageFrame.message.thumbnail!, attribute: "upload_data_id", UpdationElements: ["download_status" : "2","upload_Path":Path])
                                    if(completion != nil)
                                    {
                                        completion!()
                                    }
                                }
                            })
                        }
                    }
                    else
                    {
                        var ThembnailData:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "compressed_data") as! String
                        let str:String = "data:image/jpg;base64,";
                        if !ThembnailData.contains("data:image")
                        {
                            ThembnailData = str.appending(ThembnailData)
                        }
                        imageView.sd_setImage(with: URL(string:ThembnailData))
                        
                        let downloadView = self.downloadView
                        if(isLoaderShow)
                        {
                            let width : CGFloat = 50
                            downloadView.frame = CGRect(x: (imageView.frame.size.width - width)/2, y: (imageView.frame.size.height - width)/2, width: width, height: width)
                            
                            downloadView.isUserInteractionEnabled = true
                            downloadView.setIndicatorStatus(.none)
                            
                            imageView.addSubview(downloadView)
                            
                            downloadView.setActionForTap { (downloadView, status) in
                                switch (status)
                                {
                                case .none:
                                    self.startDownload(messageFrame: messageFrame)
                                    downloadView?.isUserInteractionEnabled = false
                                    downloadView?.setIndicatorStatus(.indeterminate)
                                    break;
                                case .running:
                                    downloadView?.setIndicatorStatus(.completed)
                                    break;
                                case .indeterminate:
                                    downloadView?.setIndicatorStatus(.running)
                                    break;
                                case .completed:
                                    downloadView?.setIndicatorStatus(.none)
                                    break;
                                }
                            }
                        }
                    }
                }
            }
        }
        else
        {
            self.loadVideoThumbnailOfMe(messageFrame: messageFrame, ImageView: imageView)
        }
        
        
    }
    
    func loadFriendsImage(messageFrame : UUMessageFrame, imageView: UIImageView, isLoaderShow: Bool, completion: (() -> Swift.Void)? = nil)
    {
        imageView.subviews.forEach { view in
            if(view.isKind(of: ACPDownloadView.self))
            {
                view.removeFromSuperview()
            }
        }
        imageView.image = nil
        if(messageFrame.message.type == MessageType(rawValue: 1))
        {
            
            let download_status:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "download_status") as! String
            
            if(download_status == "2")
            {
                let PhotoPath:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "upload_Path") as! String
                
                if(PhotoPath != "")
                {
                    if FileManager.default.fileExists(atPath: PhotoPath) {
                        let url = URL(fileURLWithPath: PhotoPath)
                        //        let data = NSData(contentsOf: url as URL)
                        imageView.sd_setImage(with: url)
                        if(completion != nil)
                        {
                            completion!()
                        }
                    }
                    else
                    {
                        let autodownload  = self.GetAutoDownloadInfo(file_type: "photos", download_status: download_status)
                        if(autodownload)
                        {
                            let serverpath:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "serverpath") as! String
                            var ThembnailData:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "compressed_data") as! String
                            let str:String = "data:image/jpg;base64,";
                            if !ThembnailData.contains("data:image")
                            {
                                ThembnailData = str.appending(ThembnailData)
                            }
                            
                            imageView.sd_setImage(with: URL(string:ThembnailData)!)
                            
                            let url = URL(string: serverpath)
                            
                            let downloadView = self.downloadView
                            if(isLoaderShow)
                            {
                                let width : CGFloat = 50.0
                                downloadView.frame = CGRect(x: (imageView.frame.size.width - width)/2, y: (imageView.frame.size.height - width)/2, width: width, height: width)
                                imageView.addSubview(downloadView)
                            }
                            
                            SDWebImageManager.shared().imageDownloader?.downloadImage(with: url, options: .highPriority, progress: nil, completed: { (image:UIImage?, data:Data?, erro:Error?, downloaded:Bool) in
                                if(image != nil)
                                {
                                    downloadView.removeFromSuperview()
                                    
                                    let imagedata = image!.jpegData(compressionQuality: 1.0)!
                                    let assetname:String = messageFrame.message.thumbnail! + ".jpg"
                                    let Path:String =  Filemanager.sharedinstance.SaveImageFile(imagePath: "\(Constant.sharedinstance.photopath)/\(assetname)",imagedata: imagedata)
                                    imageView.image = image!
                                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Upload_Details, FetchString: messageFrame.message.thumbnail!, attribute: "upload_data_id", UpdationElements: ["download_status" : "2","upload_Path":Path])
                                    if(completion != nil)
                                    {
                                        completion!()
                                    }
                                    
                                }
                            })
                        }
                        else
                        {
                            var ThembnailData:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "compressed_data") as! String
                            let str:String = "data:image/jpg;base64,";
                            if !ThembnailData.contains("data:image")
                            {
                                ThembnailData = str.appending(ThembnailData)
                            }
                            imageView.sd_setImage(with: URL(string:ThembnailData))
                            
                            let downloadView = self.downloadView
                            if(isLoaderShow)
                            {
                                let width : CGFloat = 50
                                downloadView.frame = CGRect(x: (imageView.frame.size.width - width)/2, y: (imageView.frame.size.height - width)/2, width: width, height: width)
                                
                                downloadView.isUserInteractionEnabled = true
                                downloadView.setIndicatorStatus(.none)
                                
                                imageView.addSubview(downloadView)
                                
                                downloadView.setActionForTap { (downloadView, status) in
                                    switch (status)
                                    {
                                    case .none:
                                        self.startDownload(messageFrame: messageFrame)
                                        downloadView?.isUserInteractionEnabled = false
                                        downloadView?.setIndicatorStatus(.indeterminate)
                                        break;
                                    case .running:
                                        downloadView?.setIndicatorStatus(.completed)
                                        break;
                                    case .indeterminate:
                                        downloadView?.setIndicatorStatus(.running)
                                        break;
                                    case .completed:
                                        downloadView?.setIndicatorStatus(.none)
                                        break;
                                    }
                                }
                            }
                        }
                        
                    }
                    
                }
                else
                    
                {
                    imageView.image = UIImage(named:"VideoThumbnail")
                }
            }
                
            else
            {
                let autodownload  = self.GetAutoDownloadInfo(file_type: "photos", download_status: download_status)
                if(autodownload)
                {
                    let serverpath:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "serverpath") as! String
                    var ThembnailData:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "compressed_data") as! String
                    let str:String = "data:image/jpg;base64,";
                    if !ThembnailData.contains("data:image")
                    {
                        ThembnailData = str.appending(ThembnailData)
                    }
                    
                    imageView.sd_setImage(with: URL(string:ThembnailData))
                    
                    DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Upload_Details, FetchString: messageFrame.message.thumbnail!, attribute: "upload_data_id", UpdationElements: ["download_status" : "1"])
                    
                    let downloadView = self.downloadView
                    if(isLoaderShow)
                    {
                        let width : CGFloat = 50.0
                        downloadView.frame = CGRect(x: (imageView.frame.size.width - width)/2, y: (imageView.frame.size.height - width)/2, width: width, height: width)
                        imageView.addSubview(downloadView)
                    }
                    
                    SDWebImageManager.shared().imageDownloader?.downloadImage(with: URL(string:serverpath), options: .highPriority, progress: nil, completed: { (image:UIImage?, data:Data?, erro:Error?, downloaded:Bool) in
                        if(image != nil)
                        {
                            downloadView.removeFromSuperview()
                            let imagedata = image!.jpegData(compressionQuality: 1.0)!
                            let assetname:String = messageFrame.message.thumbnail! + ".jpg"
                            let Path:String =  Filemanager.sharedinstance.SaveImageFile(imagePath: "\(Constant.sharedinstance.photopath)/\(assetname)",imagedata: imagedata)
                            imageView.image = image!
                            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Upload_Details, FetchString: messageFrame.message.thumbnail!, attribute: "upload_data_id", UpdationElements: ["download_status" : "2","upload_Path":Path])
                            if(completion != nil)
                            {
                                completion!()
                            }
                        }
                    })
                }
                else
                {
                    var ThembnailData:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "compressed_data") as! String
                    let str:String = "data:image/jpg;base64,";
                    if !ThembnailData.contains("data:image")
                    {
                        ThembnailData = str.appending(ThembnailData)
                    }
                    imageView.sd_setImage(with: URL(string:ThembnailData))
                    
                    let downloadView = self.downloadView
                    if(isLoaderShow)
                    {
                        let width : CGFloat = 50
                        downloadView.frame = CGRect(x: (imageView.frame.size.width - width)/2, y: (imageView.frame.size.height - width)/2, width: width, height: width)
                        
                        downloadView.isUserInteractionEnabled = true
                        downloadView.setIndicatorStatus(.none)
                        
                        imageView.addSubview(downloadView)
                        
                        downloadView.setActionForTap { (downloadView, status) in
                            switch (status)
                            {
                            case .none:
                                self.startDownload(messageFrame: messageFrame)
                                downloadView?.isUserInteractionEnabled = false
                                downloadView?.setIndicatorStatus(.indeterminate)
                                break;
                            case .running:
                                downloadView?.setIndicatorStatus(.completed)
                                break;
                            case .indeterminate:
                                downloadView?.setIndicatorStatus(.running)
                                break;
                            case .completed:
                                downloadView?.setIndicatorStatus(.none)
                                break;
                            }
                        }
                    }
                }
                
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
        let PhotoPath:Data = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "video_thumbnail") as! Data
        var ThembnailData:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "compressed_data") as! String
        
        
        
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
        var ThembnailData:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "compressed_data") as! String
        
        let str:String = "data:image/jpg;base64,";
        
        if !ThembnailData.contains("data:image")
        {
            ThembnailData = str.appending(ThembnailData)
        }
        
        ImageView.sd_setImage(with: URL(string:ThembnailData))
    }
    
    func GetAutoDownloadInfo(file_type : String, download_status : String) -> Bool
    {
        
        let mediaDetailArr = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Data_Usage_Settings, attribute: "user_id", FetchString: Themes.sharedInstance.Getuser_id(), SortDescriptor: nil) as! NSArray
        
        if(mediaDetailArr.count > 0)
        {
            let dataSettingObj = mediaDetailArr.firstObject as! NSManagedObject
            
            switch (Themes.sharedInstance.CheckNullvalue(Passed_value: dataSettingObj.value(forKey: file_type))){
            case "0":
                return false
            case "1":
                return (UIApplication.shared.delegate as! AppDelegate).byreachable == "1" ? true : false
            case "2":
                return true
            default:
                return true
            }
        }
        else
        {
            return true
        }
    }
    
    func startDownload(messageFrame : UUMessageFrame) {
        
        self.downloadView.setIndicatorStatus(.indeterminate)
        let serverpath:String = UploadHandler.Sharedinstance.ReturnuploadDetails(pathid: messageFrame.message.thumbnail!, upload_detail: "serverpath") as! String
        
        if(serverpath != "")
        {
            DownloadHandler.sharedinstance.handleDownLoad(true)
        }
    }
  }
  
  

