//
//  FilterContact.swift
//
//
//  Created by CASPERON on 28/02/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit

class FilterContact: NSObject {
    
    var name:String! = String()
    var id:String! = String()
    var status:String! = String()
    var phoneNo:String! = String()
    var profile:String! = String()
    var msisdn:String! = String()
    
    init(name:String,id:String,status:String,phoneNo:String, profile:String, msisdn: String){
        self.name = name
        self.id = id
        self.status = status
        self.phoneNo = phoneNo
        self.profile = profile
        self.msisdn = msisdn
     }
    
}
