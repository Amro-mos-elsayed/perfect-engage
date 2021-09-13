////
////  EncryptionHandler.swift
//
////  Created by CasperoniOS on 05/06/18.
////  Copyright © 2018 CASPERON. All rights reserved.
////
//
import UIKit
import SwiftyRSA

class EncryptionHandler:NSObject {
    static let sharedInstance = EncryptionHandler()
    //Encrypt Data
    func encryptData(data:Any)->Any?
    {
        if(Constant.sharedinstance.isEncryptionEnabled)
        {
            let jsonDict = data as! [String:Any]
            let str:String = Themes.sharedInstance.ReturnjsonStr(jsonStr: jsonDict)
            let SHA256 = CryptoJS.SHA256()
            let gettoken:String = SHA256.hash(Themes.sharedInstance.getToken())
            let binaryData = gettoken.dataFromHexadecimalString()
            let base64String = binaryData?.base64EncodedString()
            let AES = CryptoJS.AES()
            let ciphertext:String? = AES.encrypt(str, password: base64String!)
            if(ciphertext != nil)
            {
                return ciphertext!
            }
            else
            {
                return data
            }
        }
        else
        {
            return data
        }
    }
    //Decrypt Data
    func decryptData(data:Any)->Any?
    {
        if(Constant.sharedinstance.isEncryptionEnabled)
        {
            if let str:String = data as? String
            {
                let SHA256 = CryptoJS.SHA256()
                let gettoken:String = SHA256.hash(Themes.sharedInstance.getToken())
                let binaryData = gettoken.dataFromHexadecimalString()
                let base64String = binaryData?.base64EncodedString()
                let AES = CryptoJS.AES()
                let deciphertext:String? = AES.decrypt(str, password: base64String!)
                if(deciphertext != nil)
                {
                    let _data = Themes.sharedInstance.ReturnStrtojson(jsonStr:deciphertext!)
                    if(_data != nil)
                    {
                        return _data! as NSDictionary
                        
                    }
                    else
                    {
                        return nil
                    }
                }
                else
                {
                    return data as! NSDictionary
                }
            }
            else
            {
                return data as! NSDictionary
            }
        }
        else
        {
            return data as! NSDictionary
        }
    }
    
    func Decryptmessage(str:Any,toid:String,chat_type:String)->Any
    {
        
        if(Constant.sharedinstance.isEncryptionEnabled)
        {
            var secrettoken:String = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Favourite_Contact, attrib_name: "id", fetchString: toid, returnStr: "security_code")
            if(secrettoken.length == 0)
            {
                secrettoken = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Conv_detail, attrib_name: "opp_id", fetchString: toid, returnStr: "security_code")
                if(secrettoken.length == 0)
                {
                    secrettoken = Themes.sharedInstance.getToken()
                }
            }
            let publickey:String = KeychainService.loadPassword(service:  "\(Themes.sharedInstance.Getuser_id())-public_key")! as String
            let privatekey:String = KeychainService.loadPassword(service:  "\(Themes.sharedInstance.Getuser_id())-private_key")! as String
            if(str is String)
            {
                if(publickey.length != 0 && privatekey.length != 0 && (str as! String).length != 0)
                {
                    do
                    {
                        let SHA256 = CryptoJS.SHA256()
                        let gettoken:String = SHA256.hash(secrettoken)
                        let binaryData = gettoken.dataFromHexadecimalString()
                        let base64String = binaryData?.base64EncodedString()
                        let AES = CryptoJS.AES()
                        let deciphertext:String? = AES.decrypt(str as! String, password: base64String!)
                        let _PrivateKey = try PrivateKey(pemEncoded: privatekey)
                        let encrypted = try EncryptedMessage(base64Encoded: deciphertext!)
                        let clear = try encrypted.decrypted(with: _PrivateKey, padding: .PKCS1)
                        let clearStr:String? = try clear.string(encoding: .utf8)
                        if(clearStr != nil && clearStr != "")
                        {
                            if let data = clearStr?.data(using: .utf8) {
                                do {
                                    let jsonDict =    try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                                    return jsonDict!
                                } catch {
                                    return clearStr!
                                }
                            }
                            else
                            {
                                return clearStr!
                            }
                        }
                        else
                        {
                            return str
                        }
                    }
                    catch
                    {
                        return str
                    }
                    
                }
                else
                {
                    return str
                    
                }
            }
            else
            {
                return str
                
            }
        }
        return str  
        
    }
    
    func encryptmessage(str:String,toid:String,chat_type:String)->String
    {
        if(Constant.sharedinstance.isEncryptionEnabled)
        {
            var secrettoken:String = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Favourite_Contact, attrib_name: "id", fetchString: toid, returnStr: "security_code")
            if(chat_type == "group")
            {
                secrettoken = Themes.sharedInstance.getToken()
            }
            else  if (secrettoken.length == 0)
            {
                secrettoken = Themes.sharedInstance.GetsingleDetail(entityname: Constant.sharedinstance.Conv_detail, attrib_name: "opp_id", fetchString: toid, returnStr: "security_code")
                if(secrettoken.length == 0)
                {
                    secrettoken = Themes.sharedInstance.getToken()
                }
            }
            let publickey:String = KeychainService.loadPassword(service:  "\(Themes.sharedInstance.Getuser_id())-public_key")! as String
            let privatekey:String = KeychainService.loadPassword(service:  "\(Themes.sharedInstance.Getuser_id())-private_key")! as String
            
            //            (UIApplication.shared.delegate as! AppDelegate).window?.makeToast(message: "public\(publickey)  private \(privatekey)", duration: 3, position: HRToastActivityPositionDefault)
            
            if(publickey.length != 0 && privatekey.length != 0 && str.length != 0 && toid.length != 0)
            {
                do
                {
                    let _publicKey = try PublicKey(pemEncoded: publickey)
                    let clear = try ClearMessage(string: str, using: .utf8)
                    let encrypted = try clear.encrypted(with: _publicKey, padding: .PKCS1)
                    let publickeyencryptedStr = encrypted.base64String
                    
                    let SHA256 = CryptoJS.SHA256()
                    let gettoken:String = SHA256.hash(secrettoken)
                    let binaryData = gettoken.dataFromHexadecimalString()
                    let base64String = binaryData?.base64EncodedString()
                    let AES = CryptoJS.AES()
                    let ciphertext:String? = AES.encrypt(publickeyencryptedStr, password: base64String!)
                    
                    //                var data = (ciphertext as! String).data(using: .utf8)
                    //                let Actsize:String = Themes.sharedInstance.returnSizeinMBStr(byteCount: (data?.count)!)
                    //
                    //
                    //                let compressedData = LzmaSDKObjCBufferCompressLZMA2(data!, 1)
                    //                let size:String = Themes.sharedInstance.returnSizeinMBStr(byteCount: (compressedData?.count)!)
                    //
                    //
                    //                print("Actual:\(Actsize)------>---->Compressed:\(size)")
                    
                    if(ciphertext != nil)
                    {
                        return ciphertext!
                    }
                    else
                    {
                        return str
                    }
                }
                catch
                {
                    return str
                    
                }
                
            }
            else
            {
                return str
                
            }
        }
        return str
        
    }
}
