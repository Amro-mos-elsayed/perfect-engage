//
//  NetworkUsageVC.swift
//
//
//  Created by Casperon iOS on 26/09/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit

class NetworkUsageVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var table: UITableView!
    var headers : NSArray = NSArray()
    var Datasource : [String : Any] = [:]
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        headers = [NSLocalizedString("MESSAGES", comment: "com") , NSLocalizedString("CHAT MEDIA", comment: "com"), NSLocalizedString("TOTAL BYTES", comment: "com")]
        
        Datasource  = ["\(headers[0])" : [["Left" : NSLocalizedString("Sent", comment:"Sent" ) , "Right" : "0"], ["Left" : NSLocalizedString("Received", comment:"Sent" ) , "Right" : "0"], ["Left" : NSLocalizedString("Bytes Sent", comment:"Sent" ) , "Right" : "0 KB"], ["Left" : NSLocalizedString("Bytes Received", comment:"Sent" ), "Right" : "0 KB"]], "\(headers[1])" : [["Left" : NSLocalizedString("Bytes Sent", comment:"Sent" ), "Right" : "0 KB"], ["Left" : NSLocalizedString("Bytes Received", comment:"Sent" ) , "Right" : "0 KB"]], "\(headers[2])" : [["Left" : NSLocalizedString("Sent", comment:"Sent" ), "Right" : "0 KB"], ["Left" : NSLocalizedString("Received", comment:"Sent") , "Right" : "0 KB"]]]
        
        Themes.sharedInstance.activityView(View: self.view)
        DispatchQueue.main.async {
            let SentChatArr = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "from", FetchString: Themes.sharedInstance.Getuser_id(), SortDescriptor:"timestamp") as! NSArray
            
            var SentData : Data = Data()
            var SentMediaDataBytes : Int = 0
            
            var ReceivedData : Data = Data()
            var ReceivedMediaDataBytes : Int = 0
            
            var SentDataCount: String = ByteCountFormatter.string(fromByteCount: Int64((SentData as NSData).length) , countStyle: .file)
            var SentMediaDataCount: String = ByteCountFormatter.string(fromByteCount: Int64(SentMediaDataBytes) , countStyle: .file)
            var TotalSentDataCount: String = ByteCountFormatter.string(fromByteCount: Int64((SentData as NSData).length + SentMediaDataBytes) , countStyle: .file)
            
            var ReceivedDataCount: String = ByteCountFormatter.string(fromByteCount: Int64((ReceivedData as NSData).length) , countStyle: .file)
            var ReceivedMediaDataCount: String = ByteCountFormatter.string(fromByteCount: Int64(ReceivedMediaDataBytes) , countStyle: .file)
            var TotalReceivedDataCount: String = ByteCountFormatter.string(fromByteCount: Int64((ReceivedData as NSData).length + ReceivedMediaDataBytes) , countStyle: .file)
            
            
            if(SentChatArr.count > 0)
            {
                for Sentchat : NSManagedObject in (SentChatArr as! Array<NSManagedObject>) {
                    
                    if(Int(Sentchat.value(forKey: "type") as! String) == 0)//UUMessageTypeText
                    {
                        SentData.append((Sentchat.value(forKey: "payload") as! String).data(using: .utf8)!)
                    }
                    else if(Int(Sentchat.value(forKey: "type") as! String) == 1)//UUMessageTypePicture
                    {
                        SentMediaDataBytes += self.SentMediatoBytes(id: (Sentchat.value(forKey: "thumbnail") as! String))
                        SentMediaDataBytes += (((Sentchat.value(forKey: "payload") as! String).data(using: .utf8)!) as NSData).length
                    }
                    else if(Int(Sentchat.value(forKey: "type") as! String) == 2)//UUMessageTypeVideo
                    {
                        SentMediaDataBytes += self.SentMediatoBytes(id: (Sentchat.value(forKey: "thumbnail") as! String))
                        SentMediaDataBytes += (((Sentchat.value(forKey: "payload") as! String).data(using: .utf8)!) as NSData).length
                    }
                    else if(Int(Sentchat.value(forKey: "type") as! String) == 3)//UUMessageTypeVoice
                    {
                        SentMediaDataBytes += self.SentMediatoBytes(id: (Sentchat.value(forKey: "thumbnail") as! String))
                    }
                    else if(Int(Sentchat.value(forKey: "type") as! String) == 4)//UUMessageTypeLink
                    {
                        SentData.append((Sentchat.value(forKey: "payload") as! String).data(using: .utf8)!)
                    }
                    else if(Int(Sentchat.value(forKey: "type") as! String) == 5)//UUMessageTypeContact
                    {
                        SentData.append((Sentchat.value(forKey: "payload") as! String).data(using: .utf8)!)
                    }
                    else if(Int(Sentchat.value(forKey: "type") as! String) == 6)//UUMessageTypeDocument
                    {
                        SentMediaDataBytes += self.SentMediatoBytes(id: (Sentchat.value(forKey: "thumbnail") as! String))
                    }
                    else if(Int(Sentchat.value(forKey: "type") as! String) == 7)//UUMessageTypeReply
                    {
                        SentData.append((Sentchat.value(forKey: "payload") as! String).data(using: .utf8)!)
                    }
                    else if(Int(Sentchat.value(forKey: "type") as! String) == 14)//UUMessageTypeLocation
                    {
                        SentData.append((Sentchat.value(forKey: "payload") as! String).data(using: .utf8)!)
                    }
                }
                SentDataCount = ByteCountFormatter.string(fromByteCount: Int64((SentData as NSData).length) , countStyle: .file)
                SentMediaDataCount = ByteCountFormatter.string(fromByteCount: Int64(SentMediaDataBytes) , countStyle: .file)
                TotalSentDataCount = ByteCountFormatter.string(fromByteCount: Int64((SentData as NSData).length + SentMediaDataBytes) , countStyle: .file)
                
            }
            let ReceivedChatArr = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "to", FetchString: Themes.sharedInstance.Getuser_id(), SortDescriptor:"timestamp") as! NSArray
            if(ReceivedChatArr.count > 0)
            {
                
                for Receivedchat : NSManagedObject in (ReceivedChatArr as! Array<NSManagedObject>) {
                    
                    if(Int(Receivedchat.value(forKey: "type") as! String) == 0)//UUMessageTypeText
                    {
                        ReceivedData.append((Receivedchat.value(forKey: "payload") as! String).data(using: .utf8)!)
                    }
                    else if(Int(Receivedchat.value(forKey: "type") as! String) == 1)//UUMessageTypePicture
                    {
                        ReceivedMediaDataBytes += self.ReceivedMediatoBytes(id: (Receivedchat.value(forKey: "thumbnail") as! String))
                        ReceivedMediaDataBytes += (((Receivedchat.value(forKey: "payload") as! String).data(using: .utf8)!) as NSData).length
                    }
                    else if(Int(Receivedchat.value(forKey: "type") as! String) == 2)//UUMessageTypeVideo
                    {
                        ReceivedMediaDataBytes += self.ReceivedMediatoBytes(id: (Receivedchat.value(forKey: "thumbnail") as! String))
                        ReceivedMediaDataBytes += (((Receivedchat.value(forKey: "payload") as! String).data(using: .utf8)!) as NSData).length
                    }
                    else if(Int(Receivedchat.value(forKey: "type") as! String) == 3)//UUMessageTypeVoice
                    {
                        ReceivedMediaDataBytes += self.ReceivedMediatoBytes(id: (Receivedchat.value(forKey: "thumbnail") as! String))
                        ReceivedMediaDataBytes += (((Receivedchat.value(forKey: "payload") as! String).data(using: .utf8)!) as NSData).length
                    }
                    else if(Int(Receivedchat.value(forKey: "type") as! String) == 4)//UUMessageTypeLink
                    {
                        ReceivedData.append((Receivedchat.value(forKey: "payload") as! String).data(using: .utf8)!)
                    }
                    else if(Int(Receivedchat.value(forKey: "type") as! String) == 5)//UUMessageTypeContact
                    {
                        ReceivedData.append((Receivedchat.value(forKey: "payload") as! String).data(using: .utf8)!)
                    }
                    else if(Int(Receivedchat.value(forKey: "type") as! String) == 6)//UUMessageTypeDocument
                    {
                        ReceivedMediaDataBytes += self.ReceivedMediatoBytes(id: (Receivedchat.value(forKey: "thumbnail") as! String))
                        ReceivedMediaDataBytes += (((Receivedchat.value(forKey: "payload") as! String).data(using: .utf8)!) as NSData).length
                    }
                    else if(Int(Receivedchat.value(forKey: "type") as! String) == 7)//UUMessageTypeReply
                    {
                        ReceivedData.append((Receivedchat.value(forKey: "payload") as! String).data(using: .utf8)!)
                    }
                    else if(Int(Receivedchat.value(forKey: "type") as! String) == 14)//UUMessageTypeLocation
                    {
                        ReceivedData.append((Receivedchat.value(forKey: "payload") as! String).data(using: .utf8)!)
                    }
                }
                
                ReceivedDataCount = ByteCountFormatter.string(fromByteCount: Int64((ReceivedData as NSData).length) , countStyle: .file)
                ReceivedMediaDataCount = ByteCountFormatter.string(fromByteCount: Int64(ReceivedMediaDataBytes) , countStyle: .file)
                TotalReceivedDataCount = ByteCountFormatter.string(fromByteCount: Int64((ReceivedData as NSData).length + ReceivedMediaDataBytes) , countStyle: .file)
                
            }
            self.Datasource = ["\(self.headers[0])" : [["Left" : NSLocalizedString("Sent", comment:"Sent") , "Right" : "\(SentChatArr.count)"], ["Left" : NSLocalizedString("Received", comment:"Received"), "Right" : "\(ReceivedChatArr.count)"], ["Left" : NSLocalizedString("Bytes Sent", comment:"Bytes Sent") , "Right" : "\(SentDataCount)"], ["Left" : NSLocalizedString("Bytes Received", comment:"Bytes Received") , "Right" : "\(ReceivedDataCount)"]], "\(self.headers[1])" : [["Left" : NSLocalizedString("Bytes Sent", comment:"Received"), "Right" : "\(SentMediaDataCount)"], ["Left" : NSLocalizedString("Bytes Received", comment:"Bytes Received"), "Right" : "\(ReceivedMediaDataCount)"]], "\(self.headers[2])" : [["Left" : NSLocalizedString("Sent", comment:"Sent"), "Right" : "\(TotalSentDataCount)"], ["Left" : NSLocalizedString("Received", comment:"Received"), "Right" : "\(TotalReceivedDataCount)"]]]
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            self.table.reloadData()
        }
        
    }
    
    func SentMediatoBytes(id : String) -> Int {
        let mediaArr = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Upload_Details, attribute: "upload_data_id", FetchString: id, SortDescriptor: nil) as! NSArray
        var mediaDetail : NSManagedObject?
        if(mediaArr.count > 0)
        {
            mediaDetail = mediaArr[0] as? NSManagedObject
        }
        return Int(mediaDetail?.value(forKey: "upload_byte_count") as! String)!
    }
    
    func ReceivedMediatoBytes(id : String) -> Int {
        let mediaArr = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Upload_Details, attribute: "upload_data_id", FetchString: id, SortDescriptor: nil) as! NSArray
        var mediaDetail : NSManagedObject?
        var download_byte_count : Int = 0
        if(mediaArr.count > 0)
        {
            mediaDetail = mediaArr[0] as? NSManagedObject
            if((mediaDetail?.value(forKey: "download_status") as! String) == "0")
            {
                download_byte_count = (mediaDetail?.value(forKey: "compressed_data") as! String).length
            }
            else if((mediaDetail?.value(forKey: "download_status") as! String) == "1" || (mediaDetail?.value(forKey: "download_status") as! String) == "2")
            {
                var documentDirectory = CommondocumentDirectory()
                documentDirectory = documentDirectory.appendingPathComponent((mediaDetail?.value(forKey: "upload_Path") as! String))

                let fileAttributes = try? FileManager.default.attributesOfItem(atPath: documentDirectory.absoluteString)
                let fileSizeNumber = fileAttributes?[.size] as? NSNumber
                if(fileSizeNumber != nil)
                {
                    download_byte_count = Int(fileSizeNumber!)
                }
                
            }
        }
        return download_byte_count
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func Back(_ sender: Any) {
        self.pop(animated: true)
    }
        
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return headers.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return headers[section] as? String
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 44
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return (Datasource["\(headers[section])"] as! NSArray).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell : UITableViewCell = UITableViewCell.init(style: .value1, reuseIdentifier: "Cell")
        cell.textLabel?.text = ((Datasource["\(headers[indexPath.section])"] as! NSArray)[indexPath.row] as! Dictionary)["Left"]
        cell.detailTextLabel?.text = ((Datasource["\(headers[indexPath.section])"] as! NSArray)[indexPath.row] as! Dictionary)["Right"]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16.0)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 16.0)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
    }
    
}

