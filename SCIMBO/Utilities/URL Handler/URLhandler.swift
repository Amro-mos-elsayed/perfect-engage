
//
//  URLhandler.swift
//  Plumbal
//
//  Created by Casperon Tech on 07/10/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SystemConfiguration


protocol URLhandlerDelegate : class {
    func ReturnDownloadProgress(id: String, Dict: NSDictionary, status: String)
}

class URLhandler: NSObject
{
    
    weak var Delegate:URLhandlerDelegate?
    static let sharedinstance = URLhandler()
    var Dictionary:NSDictionary!=NSDictionary()
    var RetryValue:NSInteger!=3
    func isConnectedToNetwork() -> Bool {
        return (UIApplication.shared.delegate as! AppDelegate).IsInternetconnected
    }
    
    func makeCall(url: String,param:NSDictionary, completionHandler: @escaping (_ responseObject: NSDictionary?,_ error:NSError?  ) -> ()?)
    {
        let HeaderDict:NSDictionary=NSDictionary()
        if isConnectedToNetwork() == true {
            Alamofire.request("\(url)", method: .post, parameters: param as? Parameters, encoding: JSONEncoding.default, headers: HeaderDict as? HTTPHeaders).validate()
                .responseJSON { response in
                    if(response.result.error == nil)
                    {
                        do {
                            
                            self.Dictionary = try JSONSerialization.jsonObject(
                                with: response.data!,
                                options: JSONSerialization.ReadingOptions.mutableContainers
                                ) as? NSDictionary
                            completionHandler(self.Dictionary as NSDictionary?, response.result.error as NSError? )
                        }
                        catch let error as NSError {
                            // Catch fires here, with an NSErrro being thrown from the JSONObjectWithData method
                            print("A JSON parsing error occurred, here are the details:\n \(error)")
                            self.Dictionary=nil
                            completionHandler(self.Dictionary as NSDictionary?, error )
                        }
                    }
                    else
                    {
                        var i=0;
                        if(i<self.RetryValue)
                        {
                            completionHandler(self.Dictionary as NSDictionary?, response.result.error as NSError? )
                            
                        }
                        else
                        {
                            self.Dictionary=nil
                            completionHandler(self.Dictionary as NSDictionary?, response.result.error as NSError? )
                            print("A JSON parsing error occurred, here are the details:\n \(response.result.error!)")
                        }
                        i=i+1
                        
                    }
            }
        }
        else {
            
        }
    }
    func makeGetCall(url: String,param:NSDictionary, completionHandler: @escaping (_ responseObject: NSDictionary?,_ error:NSError?  ) -> ())
    {
        if isConnectedToNetwork() == true {
            
            Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.photopath);
            Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.videopathpath);
            Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.docpath);
            Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.voicepath);
            Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.wallpaperpath)
            Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.statuspath);
            
            Alamofire.request("\(url)", method: .get)
                .responseJSON { response in
                    
                    if(response.result.error == nil)
                    {
                        
                        do {
                            self.Dictionary = try JSONSerialization.jsonObject(
                                with: response.data!,
                                
                                options: JSONSerialization.ReadingOptions.mutableContainers
                                
                                ) as? NSDictionary
                            
                            completionHandler(self.Dictionary as NSDictionary?, response.result.error as NSError? )
                            
                        }
                        catch let error as NSError {
                            
                            // Catch fires here, with an NSErrro being thrown from the JSONObjectWithData method
                            print("A JSON parsing error occurred, here are the details:\n \(error)")
                            self.Dictionary=nil
                            completionHandler(self.Dictionary as NSDictionary?, error )
                            
                        }
                        
                        
                    }
                    else
                    {
                        
                        var i=0;
                        if(i<self.RetryValue)
                        {
                            
                            self.makeCall(url: url, param: param, completionHandler: { (Dictionary, nil) -> ()? in
                                return
                            })
                            //self.makeCall(url: url, param: param, completionHandler: nil)
                        }
                        else
                        {
                            self.Dictionary=nil
                            completionHandler(self.Dictionary as NSDictionary?, response.result.error as NSError? )
                            print("A JSON parsing error occurred, here are the details:\n \(response.result.error!)")
                        }
                        i=i+1
                        
                    }
            }
        }
        else
        {
        }
    }
    
    func DownloadFile(id: String, url: String,type:String,param:NSDictionary?, completionHandler: @escaping (_ responseObject: DownloadResponse<Data>?,_ error:NSError?  ) -> ())
    {
        print(url)
        
        DispatchQueue.main.async {

            if self.isConnectedToNetwork() == true {
            let Url:URL? = URL(string:url)
            if(Url != nil)
            {
                Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.photopath);
                Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.videopathpath);
                Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.docpath);
                Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.voicepath);
                Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.wallpaperpath)
                Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.statuspath);
                
                var FolderPath:String = String()
                if(type == "1")
                {
                    FolderPath = Constant.sharedinstance.photopath
                }
                else if(type == "2")
                {
                    FolderPath = Constant.sharedinstance.videopathpath
                }
                else if(type == "3")
                {
                    FolderPath = Constant.sharedinstance.voicepath
                }
                    
                else if(type == "6" || type == "20")
                {
                    FolderPath = Constant.sharedinstance.docpath
                }
                
                print(url)
                var documentsURL = CommondocumentDirectory()
                documentsURL.appendPathComponent("\(FolderPath)/\(Themes.sharedInstance.CheckNullvalue(Passed_value: Url?.lastPathComponent))")
                if !FileManager.default.fileExists(atPath: documentsURL.absoluteString)
                {
                    let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                        return (documentsURL, [.removePreviousFile])
                    }
                    
                    let headers = ["authorization" : Themes.sharedInstance.getToken(), "userid" : Themes.sharedInstance.Getuser_id(), "requesttype" : "site", "referer" : ImgUrl]
                    Alamofire.download("\(url)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers, to: destination).downloadProgress(queue: DispatchQueue.global(qos: .background)) { (progress) in
                        print("Completed Progress: \(progress.fractionCompleted)")
                        print("Totaldddd Progress: \(progress.completedUnitCount)....\(url)")
                        if(self.Delegate !=  nil)
                        {
                            DispatchQueue.main.async {
                                let Dict:NSDictionary = ["url":"\(url)","completed_progress":"\(progress.completedUnitCount)","total_progress":"\(progress.totalUnitCount)"]
                                
                                self.Delegate?.ReturnDownloadProgress(id: id, Dict: Dict,status: "1")
                                
                            }
                        }
                        
                        } .validate().responseData { ( response ) in
                            
                            DispatchQueue.main.async {
                                if(response.error == nil)
                                {
                                    
                                    completionHandler(response, response.error as NSError?)
                                }
                                else
                                {
                                    
                                    completionHandler(response, response.error as NSError?)
                                }
                            }
                    }
                }
                else
                {
                    completionHandler(nil, nil)
                }
            }
            else
            {
                DispatchQueue.main.async {
                    self.Delegate?.ReturnDownloadProgress(id: id, Dict: [:],status: "0")
                }
            }
            
        }
            
        else {
            DispatchQueue.main.async {
                self.Delegate?.ReturnDownloadProgress(id: id, Dict: [:],status: "0")
            }
        }
        }
    }
    
    
    func DownloadStatusFile(id: String, url: String,type:String,param:NSDictionary?, completionHandler: @escaping (_ responseObject: DownloadResponse<Data>?,_ error:NSError?  ) -> ())
    {
        print(url)
        
        if isConnectedToNetwork() == true {
            let Url:URL? = URL(string:url)
            if(Url != nil)
            {
                Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.photopath);
                Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.videopathpath);
                Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.docpath);
                Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.voicepath);
                Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.wallpaperpath)
                Filemanager.sharedinstance.CreateFolder(foldername: Constant.sharedinstance.statuspath);
                
                //            let destination = DownloadRequest.suggestedDownloadDestination()
                var FolderPath:String = String()
                if(type == "1" || type == "2")
                {
                    FolderPath = Constant.sharedinstance.statuspath
                }
                
                var documentsURL = CommondocumentDirectory()
                documentsURL.appendPathComponent("\(FolderPath)/\(Themes.sharedInstance.CheckNullvalue(Passed_value: Url?.lastPathComponent))")
                if !FileManager.default.fileExists(atPath: documentsURL.absoluteString)
                {
                    let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                        return (documentsURL, [.removePreviousFile])
                    }
                    
                    let headers = ["authorization" : Themes.sharedInstance.getToken(), "userid" : Themes.sharedInstance.Getuser_id(), "requesttype" : "site", "referer" : ImgUrl]
                    
                    Alamofire.download("\(url)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers, to: destination).downloadProgress(queue: DispatchQueue.global(qos: .background)) { (progress) in
                        print("Completed Progress: \(progress.fractionCompleted)")
                        print("Totaldddd Progress: \(progress.completedUnitCount)....\(url)")
                        if(self.Delegate !=  nil)
                        {
                            DispatchQueue.main.async {
                                
                                let Dict:NSDictionary = ["url":"\(url)","completed_progress":"\(progress.completedUnitCount)","total_progress":"\(progress.totalUnitCount)"]
                                
                                self.Delegate?.ReturnDownloadProgress(id: id, Dict: Dict,status: "1")
                            }
                        }
                        
                        } .validate().responseData { ( response ) in
                            
                            if(response.error == nil)
                            {
                                
                                completionHandler(response, response.error as NSError? )
                            }
                            else
                            {
                                
                                completionHandler(response, response.error as NSError? )
                            }
                    }
                }
                else
                {
                    completionHandler(nil, nil)
                }
            }
            else{
                DispatchQueue.main.async {
                    self.Delegate?.ReturnDownloadProgress(id: id, Dict: [:],status: "0")
                }
            }
        }
        else
        {
            DispatchQueue.main.async {
                self.Delegate?.ReturnDownloadProgress(id: id, Dict: [:],status: "0")
            }
        }
    }
    
    deinit {
    }
}


