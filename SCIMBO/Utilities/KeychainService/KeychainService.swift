//
//  File.swift
//
//  Created by CasperoniOS on 05/06/18.
//  Copyright © 2018 CASPERON. All rights reserved.
//

import UIKit
import Foundation
import Security
import SwiftKeychainWrapper




public class KeychainService: NSObject {

    class func updatePassword(service: String , data: String) {
       KeychainWrapper.standard.set(data, forKey: service)
     }
    
    
    class func removePassword() {
        
        KeychainWrapper.standard.removeAllKeys()
 
    }
    
    class func removeSpecificPassword(service:String) {
        KeychainWrapper.standard.removeObject(forKey: service)
    }
    
     class func savePassword(service: String , data: String) {
        
         KeychainWrapper.standard.set(data, forKey: service)
        
    }
    
    class func loadPassword(service: String ) -> String? {
        
        let retrievedPassword: String? = KeychainWrapper.standard.string(forKey: service)
        if(retrievedPassword == nil)
        {
            if(service == Themes.sharedInstance.Getuser_id())
            {
                return Themes.sharedInstance.getsecurityToken()
            }
           else if(service ==  "\(Themes.sharedInstance.Getuser_id())-public_key")
            {
                return Themes.sharedInstance.getpublicKey()
            }
            else if(service ==  "\(Themes.sharedInstance.Getuser_id())-private_key")
            {
                return Themes.sharedInstance.getPrivatekey()

            }
            return ""
        }
        return retrievedPassword
 
    }
       
    
}
