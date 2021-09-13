//
//  DocumentRecord.swift
//
//
//  Created by MV Anand Casp iOS on 04/07/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit

class DocumentRecord: NSObject {
    var docPageCount:String = String()
    var docName:String = String()
    var docType:String = String()
    var docPath:URL!
    var docContent:String = String()
    var path_extension:String = String()
    var docImage:UIImage! = UIImage()
    //Doc Type
    //1-PDF
    //2-DOC
    //3-PPT
}
