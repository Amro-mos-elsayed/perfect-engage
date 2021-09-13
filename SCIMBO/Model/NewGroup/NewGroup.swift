//
//  NewGroup.swift
//
//
//  Created by CASPERON on 30/01/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit

class NewGroup: NSObject {
    
    var contact_phoneArray:NSMutableArray = NSMutableArray()
    var contactName_Array:NSMutableArray = NSMutableArray()
    var imageData_Array:NSMutableArray = NSMutableArray()
    var checkReldFrmSetName:String = String()

}
class NewGroupAdd:NSObject{
    
    
    var name :NSString = NSString ()
    var phoneNo:NSString = NSString()
    var image:NSString = NSString()
    var id:NSString = NSString()
    var isSelect:Bool!
 
    

     init(name: NSString, phoneNo:NSString, image: NSString ,bool:Bool,id:NSString) {
        self.name = name
        self.phoneNo = phoneNo
        self.image = image
        self.id = id
        self.isSelect = bool
    }
}
