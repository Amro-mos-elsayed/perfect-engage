//
//  SettingHandler.swift
//
//
//  Created by MV Anand Casp iOS on 05/09/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit
enum settingtype {
    case notification,account,chats,aboutandhelp
    
}

class SettingHandler: NSObject {
   static let sharedinstance = SettingHandler()
    func SaveSetting(user_ID:String,setting_type:settingtype)
    {
         if(setting_type == .notification)
        {
            let Dict:Dictionary = ["group_sound":"Default","is_show_notification_group":true,"is_sound":true,"is_vibrate":true,"is_show_notification_single":true,"single_sound":"Default","user_id":user_ID] as [String : Any]
            let Checkuser_Id:Bool = DatabaseHandler.sharedInstance.countForDataForTable(Entityname: Constant.sharedinstance.Notification_Setting, attribute: "user_id", FetchString: user_ID)
            if(!Checkuser_Id)
            {
                DatabaseHandler.sharedInstance.InserttoDatabase(Dict: Dict as NSDictionary, Entityname: Constant.sharedinstance.Notification_Setting)
            }
            else
            {
                DatabaseHandler.sharedInstance.UpdateData(Entityname: Constant.sharedinstance.Notification_Setting, FetchString: Themes.sharedInstance.Getuser_id(), attribute: "user_id", UpdationElements: Dict as NSDictionary?)
            }
        }
     }
 }
