//
//  Singleton.swift
//
//
//  Created by CASPERON on 27/12/16.
//  Copyright © 2016 CASPERON. All rights reserved.
//

import UIKit

class Singleton:NSObject{
//MARK: Shared Instance
    static let sharedInstance : Singleton = Singleton()
    var countryName:String = String()
    var countryCode:String = String()
}
