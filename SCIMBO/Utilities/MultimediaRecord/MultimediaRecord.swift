//
//  MultimediaRecord.swift
//
//
//  Created by Casp iOS on 06/04/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit
import Photos
import AVFoundation

class MultimediaRecord: NSObject {
    var userCommonID:String = String()
    var toID:String = String()
    var FromID:String = String()
    var assetname:String = String()
    var isVideo:Bool = Bool()
    var assetpathname:String! = String()
    var PathId:String = String()
    
    var message_description:String = String()
    var rawData:Data! = Data()
    
    var rawDataPath:URL!
    
    var CompresssedData:Data! = Data()
    
    var VideoThumbnail:Data! = Data()
    var timestamp:String = String()
    
    var Base64Str:String = String()
    
    var Thumbnail:UIImage! = UIImage()
    var StartTime:Double = Double()
    var FileSize:Float = Float()
    
    var Endtime:Double = Double()
    var totalDuration:Double = Double()
    var isVideotrimmed:Bool = Bool()
    var isGif:Bool = Bool()
    var caption:String = String()
}


