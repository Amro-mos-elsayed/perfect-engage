//
//  Filemanager.swift
//
//
//  Created by MV Anand Casp iOS on 18/05/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit
import Contacts

func CommondocumentDirectory() -> URL {
    if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constant.sharedinstance.AppGroupID) {
        return url
    }
    else{
        let documentsDirectoryURL = try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return documentsDirectoryURL
    }
}

class Filemanager: NSObject {
    static let sharedinstance=Filemanager()

    func CreateFolder(foldername:String)
    {
        
        let documentsDirectory = CommondocumentDirectory()
        let dataPath = documentsDirectory.appendingPathComponent(foldername)
        if(!CheckDocumentexist(foldername: foldername))
        {
            do {
                try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                print("Error creating directory: \(error.localizedDescription)")
            }
        }
        

    }
    
    func CheckDocumentexist(foldername:String)->Bool
    {
        
        let documentDirectoryURL = CommondocumentDirectory()
       let databaseURL = documentDirectoryURL.appendingPathComponent(foldername)
         var fileExists:Bool = Bool()
        
        do {
            fileExists = try databaseURL.checkResourceIsReachable()
            // handle the boolean result
        } catch let error as NSError {
            print(error)
        }
        return fileExists
     }
    
    func SaveImageFile(imagePath:String,imagedata:Data)->String
    {
        self.CreateFolder(foldername: Constant.sharedinstance.photopath);
        self.CreateFolder(foldername: Constant.sharedinstance.videopathpath);
        self.CreateFolder(foldername: Constant.sharedinstance.docpath);
        self.CreateFolder(foldername: Constant.sharedinstance.voicepath);
        self.CreateFolder(foldername: Constant.sharedinstance.wallpaperpath)
        self.CreateFolder(foldername: Constant.sharedinstance.statuspath);

        let documentsDirectoryURL = CommondocumentDirectory()
        // create a name for your image
        let fileURL = documentsDirectoryURL.appendingPathComponent(imagePath)
         var Filepath:String = ""
         if !FileManager.default.fileExists(atPath: fileURL.path) {
            do
            {
                
            try  imagedata.write(to: fileURL)
                print("file saved \(fileURL.path)")
                if FileManager.default.fileExists(atPath: fileURL.path)
                {
                     print("file saved \(imagePath)")
                }
                Filepath = imagePath;
             }
             catch
            {
            print("error saving file \(error.localizedDescription)")
            }
          
        } else {
            print("file already exists")
            return imagePath;

        }
        
        return Filepath;

    }
    
    func zipMediaFiles(file:String,pics:NSMutableArray,contacts:NSMutableArray){
        let files = "chats.txt"
        let chats = "chats"
        self.DeleteFile(foldername: chats)
        let dir = CommondocumentDirectory()
        let fileURL = dir.appendingPathComponent(chats)
        do {
            try FileManager.default.createDirectory(atPath: fileURL.path, withIntermediateDirectories:true , attributes: nil)
        } catch{
            
        }
        let toSave = fileURL.appendingPathComponent(files)
        do {
            try file.write(to: toSave, atomically: false, encoding: .utf8)
            
        }
        catch {
        }
        if(pics.count > 0){
            for i in 0..<pics.count{
                let split:String = pics[i] as! String
                let splittedStringsArray = split.split(separator: "/", maxSplits: 1, omittingEmptySubsequences: true).map(String.init)
                let first_split = splittedStringsArray[1].split(separator: "-", maxSplits: 1, omittingEmptySubsequences: true).map(String.init)
                let second_split = first_split[1].split(separator: "-", maxSplits: 1, omittingEmptySubsequences: true).map(String.init)
                let destinationURL = dir.appendingPathComponent(chats).appendingPathComponent(second_split[1])
                let documentsDirectory = CommondocumentDirectory()
                let dataPath = documentsDirectory.appendingPathComponent(pics[i] as! String)
                
                do{
                    try FileManager.default.copyItem(atPath: dataPath.path, toPath: destinationURL.path)
                }catch{
                    print(error.localizedDescription)
                    
                }
            }
        }
        if(contacts.count > 0){
            for i in 0..<contacts.count{
                do{
                    
                    let data = try CNContactVCardSerialization.data(with: [contacts[i] as! CNContact])
                    
                    let documentsDirectory = CommondocumentDirectory()
                    let name:String = (contacts[i] as! CNContact).givenName
                    
                    let fileURL = documentsDirectory.appendingPathComponent(chats).appendingPathComponent("\(name).vcf")
                    
                    try data.write(to: fileURL, options: .atomic)
                }catch{
                    
                }
                
            }
        }
    }
    
    func convertTextFile(file:String){
        let files = "chats.txt"
        let chats = "chats"
        let dir = CommondocumentDirectory()
        let fileURL = dir.appendingPathComponent(chats)
        do {
            try FileManager.default.createDirectory(atPath: fileURL.path, withIntermediateDirectories:true , attributes: nil)
        } catch{
            
        }
        let toSave = fileURL.appendingPathComponent(files)
        do {
            try file.write(to: toSave, atomically: false, encoding: .utf8)
        }
        catch {
        }
        
    }
    
    func retrieveallFiles(directoryname:String)
    {
        var documentDirectory = CommondocumentDirectory()        
        documentDirectory = documentDirectory.appendingPathComponent(directoryname)

        
        let manager = FileManager.default
        do {
            let allItems = try manager.contentsOfDirectory(atPath: documentDirectory.absoluteString)

            for i in 0..<allItems.count
            {
                print(documentDirectory.appendingPathComponent(allItems[i] as String))

//    let image    = UIImage(contentsOfFile: documentDirectory.appending(allItems[i] as String))
             }
            
 // for var path: String in allItems.filter({ predicate.evaluate(with: $0) }) {
//    
//    print(path)
//    
//    
//
//     // Enumerate each .png file in directory
//}

        } catch  {
            
            print(error.localizedDescription)
            
        }
      
    }
    func DeleteFile(foldername:String)
    {
        if(CheckDocumentexist(foldername: foldername))
        {
            let documentDirectoryURL = CommondocumentDirectory()
             let databaseURL = documentDirectoryURL.appendingPathComponent(foldername)
            
     do
     {
         try FileManager.default.removeItem(at: databaseURL)
            
             }
     catch {
        print("the error is \(error.localizedDescription)")
            }
        
        }
    }

}

