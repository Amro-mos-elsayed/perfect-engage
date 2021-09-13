//
//  StatusRec.swift
//
//
//  Created by CASPERON on 14/02/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit

class StatusRec: NSObject {
    
    var status:String = String()
    var isSelect:Bool!
    
    init(status: String,isSelect:Bool) {
        self.status = status
        self.isSelect = isSelect
     }

    
}
