//
//  Call_record.swift
//
//
//  Created by MV Anand Casp iOS on 09/10/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit

class Call_record: NSObject,Codable
{
    var ContactMsisdn:String = String()
    var From_avatar:String = String()
    var To_avatar:String = String()
    var To_msisdn:String = String()
    var call_status:String = String()
    var doc_id:String = String()
    var from:String = String()
    var id:String = String()
    var msgId:String = String()
    var recordId:String = String()
    var type:String = String()
     var to:String = String()
    var timestamp:String = String()
    var from_device_type:String = String()
    var to_device_type:String = String()
    var user_busy:String = String()
    var roomid:String = String()
    var reconnecting:String = String()
    
    
    
    enum CodingKeys: String, CodingKey {
        case roomid, type, id
        case msgId, user_busy
        case from
        case doc_id
        case timestamp
        case call_status
        case to
        case recordId
        case ContactMsisdn
        case From_avatar
        case To_avatar
        case To_msisdn
        case to_device_type
        case from_device_type
        case reconnecting
    }
    
}
