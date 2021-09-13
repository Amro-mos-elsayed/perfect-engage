//
//  ChatModel.swift
//  ChatApp
//
//  Created by Casp iOS on 29/12/16.
//  Copyright © 2016 Casp iOS. All rights reserved.
//

import UIKit

class ChatModel: NSObject {
    var dataSource:NSMutableArray = NSMutableArray()
    var isGroupChat = false
    var isReceive = false
    
    var previousTime: String? = nil
    func populateRandomDataSource() {
        self.dataSource = NSMutableArray()
        //[self.dataSource addObjectsFromArray:[self additems:5]];
    }
    func addSpecifiedItem(_ dic: [AnyHashable: Any], isPagination:Bool) {
        let messageFrame = UUMessageFrame()
        let message = UUMessage()
        var dataDic = dic
        dataDic["strTime"] = Date().description
        print(dataDic)
        message.setWithDict(dataDic)
        message.minuteOffSetStart(previousTime, end: Themes.sharedInstance.CheckNullvalue(Passed_value: dataDic["strTime"]))
        messageFrame.showTime = message.showDateLabel
        messageFrame.message = message
        if (messageFrame.message.type == MessageType(rawValue: 1)!) {
            messageFrame.message.progress = "0"
            //            messageFrame.message.thumbnail = Constant.sharedinstance
        }
        else if (messageFrame.message.type == MessageType(rawValue: 2)!) {
            messageFrame.message.progress = "0"
            //            messageFrame.message.thumbnail = Constant.sharedinstance
        }
        
        
        if message.showDateLabel {
            previousTime = dataDic["strTime"] as! String?
        }
        if(isPagination)
        {
            self.dataSource.insert(messageFrame, at: 0)
        }
        else
        {
            self.dataSource.add(messageFrame)
        }
    }
    func GetThumbnail(docID:String)->String
    {
        
        var thumbnail :String = String()
        let ChatArr:NSArray=DatabaseHandler.sharedInstance.FetchFromDatabaseWithLimit(Entityname: Constant.sharedinstance.Chat_one_one, attribute: "doc_id", Predicatefromat: "==", FetchString: docID, Limit: 0, SortDescriptor: "timestamp") as NSArray
        if(ChatArr.count > 0)
        {
            for i in 0 ..< ChatArr.count {
                let ResponseDict = ChatArr[i] as! NSManagedObject
                thumbnail=Themes.sharedInstance.CheckNullvalue(Passed_value: ResponseDict.value(forKey: "thumbnail"));
            }
        }
        
        return thumbnail
        
    }
    
    func getUrlpath()
    {
        
    }
    func replaceObjAtIndex(messageFrame:UUMessageFrame,index:Int)
    {
        if(index <= self.dataSource.count)
        {
            self.dataSource.replaceObject(at: index, with: messageFrame)
        }
        
    }
    func Replacespecifieditem(_ dic: [AnyHashable: Any],index:Int)
    {
        let messageFrame = UUMessageFrame()
        let message = UUMessage()
        var dataDic = dic
        dataDic["strTime"] = Date().description
        print(dataDic)
        message.setWithDict(dataDic)
        message.minuteOffSetStart(previousTime, end: Themes.sharedInstance.CheckNullvalue(Passed_value: dataDic["strTime"]))
        messageFrame.showTime = message.showDateLabel
        messageFrame.message = message
        
        
        if message.showDateLabel {
            previousTime = dataDic["strTime"] as! String?
        }
        
        self.dataSource.replaceObject(at: index, with: messageFrame)
    }
    
    
}

