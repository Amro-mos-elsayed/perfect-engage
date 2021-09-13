//
//  FavRecord.swift
//
//
//  Created by Casp iOS on 01/02/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit

class FavRecord: NSObject {
    var name:String = String()
    var countrycode:String = String()
    var id:String = String()
    var is_add:String = String()
    var msisdn:String = String()
    var phnumber:String = String()
    var profilepic:String = String()
    var status:String = String()
    var contact_ID:String = String()
    var type:String = String()
    var is_mute:String = String()
    var is_online:String = String()
    var time_stamp:String = String()
    var conv_id:String = String()
    var is_locked:String = String()
    var encrypt_password:String = String()
}

func returnFavRecord(_ id : String) -> FavRecord {
    let contact = DatabaseHandler.sharedInstance.FetchFromDatabase(Entityname: Constant.sharedinstance.Favourite_Contact, attribute: "id", FetchString: id, SortDescriptor: nil) as! [Favourite_Contact]
    let fav = FavRecord()
    _ = contact.map {
        fav.name = Themes.sharedInstance.CheckNullvalue(Passed_value: $0.name)
        fav.countrycode = Themes.sharedInstance.CheckNullvalue(Passed_value: $0.countrycode)
        fav.id = Themes.sharedInstance.CheckNullvalue(Passed_value: $0.id)
        fav.is_add = Themes.sharedInstance.CheckNullvalue(Passed_value: $0.is_add)
        fav.msisdn = Themes.sharedInstance.CheckNullvalue(Passed_value: $0.msisdn)
        fav.phnumber = Themes.sharedInstance.CheckNullvalue(Passed_value: $0.phnumber)
        fav.profilepic = Themes.sharedInstance.CheckNullvalue(Passed_value: $0.profilepic)
        fav.status = Themes.sharedInstance.CheckNullvalue(Passed_value: $0.status)
        fav.contact_ID = Themes.sharedInstance.CheckNullvalue(Passed_value: $0.contact_id)
        fav.type = Themes.sharedInstance.CheckNullvalue(Passed_value: $0.is_fav)
        fav.is_mute = Themes.sharedInstance.CheckNullvalue(Passed_value: $0.is_mute)
        fav.is_online = Themes.sharedInstance.CheckNullvalue(Passed_value: $0.is_online)
        fav.time_stamp = Themes.sharedInstance.CheckNullvalue(Passed_value: $0.time_stamp)
        fav.conv_id = Themes.sharedInstance.CheckNullvalue(Passed_value: $0.conv_id)
        fav.is_locked = Themes.sharedInstance.CheckNullvalue(Passed_value: $0.is_locked)
        fav.encrypt_password = Themes.sharedInstance.CheckNullvalue(Passed_value: $0.encrypt_password)
    }
    return fav
}


