//
//  ChatBackUpHandler.swift

//
//  Created by Casperon iOS on 05/10/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit

class ChatBackUpHandler: NSObject {
    var entityArr = [Constant.sharedinstance.Group_details,
                     Constant.sharedinstance.Chat_one_one,
                     Constant.sharedinstance.Chat_intiated_details,
                     Constant.sharedinstance.Link_details,
                     Constant.sharedinstance.Contact_details,
                     Constant.sharedinstance.Other_Group_message,
                     Constant.sharedinstance.Upload_Details,
                     Constant.sharedinstance.Location_details,
                     Constant.sharedinstance.Secret_Chat,
                     Constant.sharedinstance.Conv_detail,
                     Constant.sharedinstance.Group_message_ack,
                     Constant.sharedinstance.Reply_detail]
    
    static let sharedInstance = ChatBackUpHandler()
    // MARK: - Backup & Restore from iCloud Drive
    
    func retriveDocumentFromiCloud(View : UIView, completionHandler: @escaping (_ success: Bool) -> ())
    {
        
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            // create the destination url for the text file to be saved
            // let fileURL = documentDirectory.appendingPathComponent("jsonfile.txt")
            do{
                let paramDic : NSDictionary = ["id":Themes.sharedInstance.Getuser_id()]
                URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.getBackupFile as String, param: paramDic , completionHandler: {(responseObject, error) ->  () in
                    do{
                        
                        if(error != nil )
                        {
                            // self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                            print(error ?? "defaultValue")
                            
                        }
                        else{
                            print(responseObject ?? "response")
                            let result = responseObject! as NSDictionary
                            
                            if let val = result["filebase64"] {
                                if val != nil {
                                    DatabaseHandler.sharedInstance.truncateDataForTable(Entityname: Constant.sharedinstance.Group_details)
                                    // DatabaseHandler.sharedInstance.truncateDataForTable(Entityname: Constant.sharedinstance.grou)
                                    let filestream = result["filebase64"] as! String
                                    let chatData = Data(base64Encoded: filestream, options: .ignoreUnknownCharacters)
                                    //  let decod = PropertyListSerialization.propertyList(from:chatData !, options: [], format: nil)
                                    let datasourceDictionary = try! PropertyListSerialization.propertyList(from:chatData!, format: nil) as! [String:Any]
                                    // let decoded = try JSONSerialization.jsonObject(with: chatData! as Data, options: [])
                                    if let dictFromJSON = datasourceDictionary as? [String : Any] {
                                        let keys = Array(dictFromJSON.keys)
                                        _ = keys.map {
                                            let index = (keys as NSArray).index(of: $0)
                                            let dictArr = dictFromJSON[$0] as! [[String : Any]]
                                            let entity = $0
                                            _ = dictArr.map {
                                                var dic = $0
                                                if entity == Constant.sharedinstance.Group_details {
                                                    if let groupUsersArr = dic["groupUsers"] as? NSArray {
                                                        let groupUsers : NSData = NSKeyedArchiver.archivedData(withRootObject: groupUsersArr) as NSData
                                                        dic["groupUsers"] = groupUsers
                                                    }
                                                }
                                                else if entity == Constant.sharedinstance.Upload_Details {
                                                    if let video_thumbnail_str = dic["video_thumbnail"] as? String {
                                                        let video_thumbnail = Data(base64Encoded: video_thumbnail_str)
                                                        dic["video_thumbnail"] = video_thumbnail
                                                    }
                                                }
                                                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: dic as NSDictionary, Entityname: entity)
                                                
                                            }
                                        }
                                    }
                                }
                                //else
                                completionHandler(true)
                            }else{
                                completionHandler(true)
                            }
                            
                        }
                    }catch let error {
                        print("error",error.localizedDescription)
                    }
                })
                //  var chatData = NSData();//= Data(base64Encoded: fileStream, options: .ignoreUnknownCharacters)
                // let chatData = try Data(contentsOf: fileURL)
                //   let decoded = try JSONSerialization.jsonObject(with: chatData as Data, options: [])
                //                    if let dictFromJSON = decoded as? [String : Any] {
                //                        let keys = Array(dictFromJSON.keys)
                //                        _ = keys.map {
                //                            let index = (keys as NSArray).index(of: $0)
                //                            DispatchQueue.main.async {
                //                                Themes.sharedInstance.Setprogress(progress: CGFloat(Float(index + 1)/Float(self.entityArr.count)))
                //                            }
                //                            let dictArr = dictFromJSON[$0] as! [[String : Any]]
                //                            let entity = $0
                //                            _ = dictArr.map {
                //                                var dic = $0
                //                                if entity == Constant.sharedinstance.Group_details {
                //                                    if let groupUsersArr = dic["groupUsers"] as? NSArray {
                //                                        let groupUsers : NSData = NSKeyedArchiver.archivedData(withRootObject: groupUsersArr) as NSData
                //                                        dic["groupUsers"] = groupUsers
                //                                    }
                //                                }
                //                                else if entity == Constant.sharedinstance.Upload_Details {
                //                                    if let video_thumbnail_str = dic["video_thumbnail"] as? String {
                //                                        let video_thumbnail = Data(base64Encoded: video_thumbnail_str)
                //                                        dic["video_thumbnail"] = video_thumbnail
                //                                    }
                //                                }
                //                                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: dic as NSDictionary, Entityname: entity)
                //                            }
                //                        }
                //                    }
            }catch {
                
                print("error reading file")
                completionHandler(false)
            }
        }
    }
    
    func deleteBackup()
    {
        
        let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents").appendingPathComponent(Themes.sharedInstance.GetAppname()).appendingPathComponent("\(Themes.sharedInstance.GetMyPhonenumber())")
        
        if((iCloudDocumentsURL) != nil)
        {
            self.removeFile(iCloudDocumentsURL!)
        }
        
    }
    //
    func copyDocumentsToiCloudDrive(View : UIView!, completionHandler: @escaping (_ success: Bool) -> ()) {
        DispatchQueue.main.async {
            Themes.sharedInstance.progressView(View: View, Message: "Uploading...")
            //  let localDocumentsURL = CommondocumentDirectory()
            var chatDic = [String : Any]()
            // var fileURL : URL?
            // fileURL = localDocumentsURL.appendingPathComponent("backup.txt")
            
            _ = self.entityArr.map {
                let entity = $0
                var chats = DatabaseHandler.sharedInstance.fetchTableAllData(Entityname: $0) as! [Any]
                _ = chats.map {
                    let index = (chats as NSArray).index(of: $0)
                    chats[index] = self.convertToDictionary($0 as! NSManagedObject, entity)
                }
                chatDic[$0] = chats
            }
            do {
                var jsonData : NSData = NSData.init() //= try JSONSerialization.data(withJSONObject: chatDic, options: .prettyPrinted)
                do {
                    jsonData = try PropertyListSerialization.data(fromPropertyList: chatDic, format: PropertyListSerialization.PropertyListFormat.binary, options :0) as NSData
                    // jsonData = try JSONSerialization.data(withJSONObject: chatDic, options: .prettyPrinted) as NSData
                    // do sth
                } catch{
                    print(error)
                }
                
                do {
                    // get the documents folder url
                    if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                        let fileStream:String = jsonData.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))
                        print("saving was successful")
                        /// upload Backup file
                        let param:NSDictionary = ["id":Themes.sharedInstance.Getuser_id(),"filebase64":fileStream]
                        print("iid",Themes.sharedInstance.Getuser_id())
                        URLhandler.sharedinstance.makeCall(url:Constant.sharedinstance.UploadBackupFile as String, param: param, completionHandler: {(responseObject, error) ->  () in
                            //Themes.sharedInstance.RemoveactivityView(View: self)
                            Themes.sharedInstance.successProgressView(View: View, Message: "Uploaded Successfully")
                            if(error != nil)
                            {
                                // self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                                Themes.sharedInstance.successProgressView(View: View, Message: "Uploaded Failed")
                                print(error ?? "defaultValue")
                            }
                            else{
                                print(responseObject ?? "response")
                                let result = responseObject! as NSDictionary
                                let errNo = result["errNum"] as! String
                                let message = result["message"]
                            }
                        })
                    }
                } catch {
                    print("error:", error)
                }
                
                //  try jsonData.write(to: fileURL!)
                
            } catch {
                print(error.localizedDescription)
            }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            //                Themes.sharedInstance.progressView(View: View, Message: "Uploading...")
            //                Themes.sharedInstance.successProgressView(View: View, Message: "Uploaded Successfully")
            //                SSZipArchive.createZipFile(atPath: (iCloudDocumentsURL?.path.appending("/chat_backup.zip"))!, withContentsOfDirectory: localDocumentsURL.path, keepParentDirectory: false, withPassword: Themes.sharedInstance.GetAppname(), andProgressHandler: { (entryNumber, total) in
            //                    Themes.sharedInstance.Setprogress(progress: CGFloat(Float(entryNumber)/Float(total)))
            //                    if(entryNumber == total)
            //                    {
            //                        self.removeFile(localDocumentsURL)
            //                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            //                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            //                            Themes.sharedInstance.successProgressView(View: View, Message: "Uploaded Successfully")
            //                            self.getBackupFileInfo()
            //                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            //                                completionHandler(true)
            //                            })
            //                        })
            //                    }
            //
            //                })
            // }
            //            else
            //            {
            //                Themes.sharedInstance.ShowNotification("iCloud not enabled", false)
            //                self.getBackupFileInfo()
            //            }
        }
    }
    
    func convertToDictionary(_ object: NSManagedObject, _ entity_name: String) -> [String : Any] {
        let entity = object.entity
        let attributes = entity.attributesByName
        
        var result = [String: Any]()
        for key in attributes.keys {
            var value = object.value(forKey: key)
            if let groupUsers = value as? Data, entity_name == Constant.sharedinstance.Group_details {
                value = NSKeyedUnarchiver.unarchiveObject(with: groupUsers) as! NSArray
            }
            else if let video_thumbnail = value as? Data, entity_name == Constant.sharedinstance.Upload_Details {
                value = video_thumbnail.base64EncodedString()
            }
            result[key] = value
        }
        return result
    }
    
    func checkBackup() -> Bool
    {
        let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents").appendingPathComponent(Themes.sharedInstance.GetAppname()).appendingPathComponent("\(Themes.sharedInstance.GetMyPhonenumber())")
        
        if((iCloudDocumentsURL) != nil)
        {
            var isDir:ObjCBool = false
            if(FileManager.default.fileExists(atPath: (iCloudDocumentsURL?.path)!, isDirectory: &isDir))
            {
                getBackupFileInfo()
                return true
            }
        }
        self.updateDB(param: ["user_id" : Themes.sharedInstance.Getuser_id(), "backup_time" : "-", "backup_size" : "-", "backup_option" : "0", "option_change_date" : Date()])
        return false
    }
    
    func checkiCloud() -> Bool
    {
        let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
        
        if((iCloudDocumentsURL) != nil)
        {
            var isDir:ObjCBool = false
            if(FileManager.default.fileExists(atPath: (iCloudDocumentsURL?.path)!, isDirectory: &isDir))
            {
                return true
            }
        }
        return false
    }
    
    func getBackupFileInfo()
    {
        let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents").appendingPathComponent(Themes.sharedInstance.GetAppname()).appendingPathComponent("\(Themes.sharedInstance.GetMyPhonenumber())")
        if((iCloudDocumentsURL) != nil)
        {
            var isDir:ObjCBool = false
            if(FileManager.default.fileExists(atPath: (iCloudDocumentsURL?.path)!, isDirectory: &isDir))
            {
                do{
                    try FileManager.default.startDownloadingUbiquitousItem(at: URL(fileURLWithPath: (iCloudDocumentsURL?.path.appending("/chat_backup.zip"))!))
                }
                catch
                {
                    print(error)
                }
                var attrs = try? FileManager.default.attributesOfItem(atPath: (iCloudDocumentsURL?.path)!.appending("/chat_backup.zip"))
                if attrs != nil {
                    let date = attrs?[.creationDate] as? Date
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .medium
                    dateFormatter.doesRelativeDateFormatting = true
                    
                    let timeFormatter = DateFormatter()
                    timeFormatter.dateFormat = "h:mm a"
                    
                    let time = "\(dateFormatter.string(from: date!)), \(timeFormatter.string(from: date!))"
                    
                    let size = ByteCountFormatter.string(fromByteCount: attrs?[.size] as! Int64 , countStyle: .file)
                    
                    self.updateDB(param: ["user_id" : Themes.sharedInstance.Getuser_id(), "backup_time" : "\(time)", "backup_size" : "\(size)"])
                    
                }
                else
                {
                    self.updateDB(param: ["user_id" : Themes.sharedInstance.Getuser_id(), "backup_time" : "-", "backup_size" : "-", "backup_option" : "0", "option_change_date" : Date()])
                }
            }
        }
        else
        {
            self.updateDB(param: ["user_id" : Themes.sharedInstance.Getuser_id(), "backup_time" : "-", "backup_size" : "-", "backup_option" : "0", "option_change_date" : Date()])
        }
    }
    
    func updateAutoBackupSettings(Option : String)
    {
        self.updateDB(param: ["user_id" : Themes.sharedInstance.Getuser_id(), "backup_option":"\(Option)", "option_change_date" : Date()])
    }
    
    func updateDB(param : NSDictionary)
    {
        let count : Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Chat_Backup_Settings, attribute: "user_id", FetchString: Themes.sharedInstance.Getuser_id())
        if(count)
        {
            DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Chat_Backup_Settings, FetchString: Themes.sharedInstance.Getuser_id(), attribute: "user_id", UpdationElements: param)
        }
        else
        {
            if((param.value(forKey: "backup_option")) != nil)
            {
                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: ["user_id" : (param["user_id"])!, "backup_time" : (param["backup_time"])!, "backup_size" : (param["backup_size"])!, "backup_option" : (param["backup_option"])!, "option_change_date" : (param["option_change_date"])!], Entityname: Constant.sharedinstance.Chat_Backup_Settings)
            }
            else
            {
                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: ["user_id" : (param["user_id"])!, "backup_time" : (param["backup_time"])!, "backup_size" : (param["backup_size"])!, "backup_option" : "0", "option_change_date" : Date()], Entityname: Constant.sharedinstance.Chat_Backup_Settings)
                
            }
        }
        
    }
    
    func AutoBackUp()
    {
        let BackupFileInfo = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Chat_Backup_Settings, attribute: "user_id", FetchString: Themes.sharedInstance.Getuser_id(), SortDescriptor: nil) as! NSArray
        
        if(BackupFileInfo.count > 0)
        {
            let BackupFileInfoDict : NSManagedObject = BackupFileInfo[0] as! NSManagedObject
            let backup_setting = BackupFileInfoDict.value(forKey: "backup_option") as! String
            
            switch (Int(backup_setting))! {
            case 1://Daily
                let from = getLastBackUpDate()
                let to = dateByAddingDays(Date: from)
                let DateNow = Date()
                let timeInterval = to.timeIntervalSince(DateNow)
                self.doAutoBackup(timeInterval: timeInterval)
                break
            case 2://Weekly
                let from = getLastBackUpDate()
                let to = dateByAddingWeek(Date: from)
                let DateNow = Date()
                let timeInterval = to.timeIntervalSince(DateNow)
                self.doAutoBackup(timeInterval: timeInterval)
                break
            case 3://Monthly
                let from = getLastBackUpDate()
                let to = dateByAddingMonth(Date: from)
                let DateNow = Date()
                let timeInterval = to.timeIntervalSince(DateNow)
                self.doAutoBackup(timeInterval: timeInterval)
                break
            default:
                break
            }
        }
    }
    
    func doAutoBackup(timeInterval : TimeInterval!) {
        var Interval = Int(timeInterval)
        if(Interval < 0)
        {
            Interval = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval, execute: {
            self.copyDocumentsToiCloudDrive(View: UIView(), completionHandler: { (success) in
                
            })
        })
        
    }
    
    func dateByAddingDays(Date: Date)->Date{
        return Calendar.current.date(byAdding: .day, value: 1, to: Date)!
    }
    
    func dateByAddingWeek(Date: Date)->Date{
        return Calendar.current.date(byAdding: .weekday, value: 1, to: Date)!
    }
    
    func dateByAddingMonth(Date: Date)->Date{
        return Calendar.current.date(byAdding: .month, value: 1, to: Date)!
    }
    
    
    
    func getLastBackUpDate() -> Date
    {
        let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents").appendingPathComponent(Themes.sharedInstance.GetAppname()).appendingPathComponent("\(Themes.sharedInstance.GetMyPhonenumber())")
        if((iCloudDocumentsURL) != nil)
        {
            var isDir:ObjCBool = false
            if(FileManager.default.fileExists(atPath: (iCloudDocumentsURL?.path)!, isDirectory: &isDir))
            {
                do{
                    try FileManager.default.startDownloadingUbiquitousItem(at: URL(fileURLWithPath: (iCloudDocumentsURL?.path.appending("/chat_backup.zip"))!))
                }
                catch
                {
                    print(error)
                }
                var attrs = try? FileManager.default.attributesOfItem(atPath: (iCloudDocumentsURL?.path)!.appending("/chat_backup.zip"))
                if attrs != nil {
                    let date = attrs?[.creationDate] as? Date
                    return date!
                }
            }
        }
        
        let BackupFileInfo = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Chat_Backup_Settings, attribute: "user_id", FetchString: Themes.sharedInstance.Getuser_id(), SortDescriptor: nil) as! NSArray
        var option_change_date : Date = Date()
        if(BackupFileInfo.count > 0)
        {
            let BackupFileInfoDict : NSManagedObject = BackupFileInfo[0] as! NSManagedObject
            option_change_date = BackupFileInfoDict.value(forKey: "option_change_date") as! Date
        }
        
        return option_change_date
    }
    
    func createFile(_ url : URL) {
        var isDir:ObjCBool = false
        if (!FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func removeFile(_ url : URL) {
        var isDir:ObjCBool = false
        if(FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir))
        {
            do {
                try FileManager.default.removeItem(at: url)
            }
            catch{
                print(error)
            }
        }
    }
    
}

