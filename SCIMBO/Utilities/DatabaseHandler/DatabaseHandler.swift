//
//  DatabaseHandler.swift
//  ChatApp
//
//  Created by Casp iOS on 06/01/17.
//  Copyright © 2017 Casp iOS. All rights reserved.
//

import UIKit
import CoreData



class DatabaseHandler: NSObject {
    static let sharedInstance = DatabaseHandler()
    let context = CoreDataStorage.mainQueueContext()
    
    override init() {
        super.init()
    }
    
    //Count Check
    func countForDataForTable(Entityname: String,attribute:String?,FetchString:String?) -> Bool {
        //        self.context.performAndWait{ () -> Void in
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entityname)
        let Entity = NSEntityDescription.entity(forEntityName: Entityname, in: context)
        fetchRequest.entity = Entity
        
        if(FetchString != nil)
        {
            fetchRequest.predicate = NSPredicate(format: "\(attribute!) == %@", FetchString!)
        }
        var count:Int
        
        do {
            count = try context.count(for: fetchRequest)
        } catch let error as NSError {
            count = 0
            print("Error: \(error)")
        }
        return (count > 0) ? true: false
        //        }
    }
    
    //Insert
    func InserttoDatabase(Dict:NSDictionary,Entityname:String)
    {
        if Entityname == Constant.sharedinstance.Group_details{
                       
                   let GroupArr:NSArray=DatabaseHandler.sharedInstance.FetchFromDatabaseWithLimit(Entityname: Entityname, attribute: "id", Predicatefromat: "==", FetchString: Dict.value(forKey: "id") as! String, Limit: 0, SortDescriptor: nil) as NSArray
                   if GroupArr.count == 1 {
                    print("app exit dubliacte group")
                       return
                   }else
                   {
                    let id = Dict.value(forKey: "id")
                    print("app insert rows ingroup details ",GroupArr.count)
                    print("dicId ",id)
                       let obj = NSEntityDescription.insertNewObject(forEntityName: Entityname as String, into: context)
                       if(Dict.count > 0)
                       {
                           obj.safeSetValuesForKeys(with: Dict as! [String : AnyObject])
                           do {
                               try context.save()
                           }
                           catch let error {
                               print("the insert error is \(error.localizedDescription)")
                           }
                       }
                   }
        }else
        {
        let obj = NSEntityDescription.insertNewObject(forEntityName: Entityname as String, into: context)
        if(Dict.count > 0)
        {
            obj.safeSetValuesForKeys(with: Dict as! [String : AnyObject])
            do {
                try context.save()
            }
            catch let error {
                print("the insert error is \(error.localizedDescription)")
            }
        }
        }
    }
    //Update
    func UpdateData(Entityname:String?,FetchString:String?,attribute:String?,UpdationElements:NSDictionary?)
    {
        
        let batchRequest = NSBatchUpdateRequest(entityName: Entityname! as String) // 2
        batchRequest.propertiesToUpdate = UpdationElements! as? [AnyHashable : Any] // 3
        batchRequest.resultType = .updatedObjectIDsResultType // 4
        batchRequest.predicate = NSPredicate(format: "\(attribute!) == %@", FetchString!)
        let error : NSError?
        do {
            if let updateResult:NSBatchUpdateResult = try context.execute(batchRequest) as? NSBatchUpdateResult
            {
                
                if let res = updateResult.result {
                    let objectID = res as! NSArray
                    for managedObjects in objectID {
                        let object = try! context.existingObject(with: managedObjects as! NSManagedObjectID)
                        context.refresh(object, mergeChanges: false)
                    }
                } else {
                    print("Error during batch update: )")
                }
            }
        }
        catch let error1 as NSError {
            error = error1
            if let error = error {
                print(error.userInfo)
            }
        }
        
        do {
            try context.save()
        }
        catch {
            print(error.localizedDescription)
        }
        //        AppDelegate.sharedInstance.saveContext()
    }
    
    func UpdateDataWithPredicate(Entityname:String?,predicate:NSPredicate? ,UpdationElements:NSDictionary?)
    {
        
        
        let batchRequest = NSBatchUpdateRequest(entityName: Entityname! as String) // 2
        batchRequest.propertiesToUpdate = UpdationElements! as? [AnyHashable : Any] // 3
        batchRequest.resultType = .updatedObjectIDsResultType // 4
        batchRequest.predicate = predicate!
        let error : NSError?
        do {
            if let updateResult:NSBatchUpdateResult = try context.execute(batchRequest) as? NSBatchUpdateResult
            {
                
                if let res = updateResult.result {
                    let objectID = res as! NSArray
                    for managedObjects in objectID {
                        let object = try! context.existingObject(with: managedObjects as! NSManagedObjectID)
                        context.refresh(object, mergeChanges: false)
                    }
                } else {
                    print("Error during batch update: )")
                }
            }
        }
        catch let error1 as NSError {
            error = error1
            if let error = error {
                print(error.userInfo)
            }
        }
        
        
    }
    //fetch
    
    func FetchFromDatabaseWithPredicate(Entityname:String?, SortDescriptor: String?,predicate:NSPredicate?,Limit:NSInteger!)->Any
    {
        
        
        let entity =  NSEntityDescription.entity(forEntityName: Entityname! as String, in: context)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entityname!)
        fetchRequest.entity = entity
        
        if (SortDescriptor?.isEmpty) != nil {
            
            let descriptor: NSSortDescriptor = NSSortDescriptor(key: SortDescriptor!, ascending: false)
            fetchRequest.sortDescriptors = [descriptor]
        }
        if(predicate != nil)
        {
            fetchRequest.predicate = predicate!
        }
        
        if(Limit != 0)
        {
            fetchRequest.fetchLimit=Limit;
        }
        
        var returnData:Any!
        do {
            returnData = try context.fetch(fetchRequest) as Any
        } catch {
            print(error.localizedDescription)
        }
        return returnData
    }
    
    
    
    func FetchFromDatabase(Entityname:String?,attribute:String?,FetchString:String?, SortDescriptor: String?)->Any
    {
        
        
        let entity =  NSEntityDescription.entity(forEntityName: Entityname! as String, in: context)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entityname!)
        fetchRequest.entity = entity
        
        if (SortDescriptor?.isEmpty) != nil {
            
            let descriptor: NSSortDescriptor = NSSortDescriptor(key: SortDescriptor!, ascending: true)
            fetchRequest.sortDescriptors = [descriptor]
        }
        
        
        if(FetchString != nil)
        {
            fetchRequest.predicate = NSPredicate(format: "\(attribute!) == %@", FetchString!)
        }
        
        var returnData:Any!
        do {
            
            returnData = try context.fetch(fetchRequest) as Any
            
        } catch {
            
        }
        
        return returnData
    }
    
    func fetchTableAllData(Entityname: String?) -> NSArray {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: Entityname!, in: context)
        fetchRequest.returnsObjectsAsFaults = false
        
        
        let savedObjects = try! context.fetch(fetchRequest) as? [NSManagedObject]
        return savedObjects! as NSArray
    }
    
    func FetchFromDatabaseWithLimit(Entityname:String?,attribute:String?,Predicatefromat:String?,FetchString:String?,Limit:NSInteger!, SortDescriptor: String?)->[Any]
    {
        
        
        let Entity = NSEntityDescription.entity(forEntityName: Entityname!, in: context)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entityname!)
        fetchRequest.entity = Entity
        
        fetchRequest.predicate = NSPredicate(format: "\(attribute!) == %@", FetchString!)
        
        if (SortDescriptor?.isEmpty) != nil {
            
            let descriptor: NSSortDescriptor = NSSortDescriptor(key: "\(SortDescriptor!)", ascending: false)
            fetchRequest.sortDescriptors = [descriptor]
        }
        if(Limit != 0)
        {
            fetchRequest.fetchLimit=Limit;
        }
        
        
        var returnData = [Any]()
        do {
            returnData = try context.fetch(fetchRequest) as [Any]
        } catch {
        }
        return returnData
    }
    
    func FetchFromDatabaseWithascending(Entityname:String?, SortDescriptor: String?, predicate:NSPredicate?, Limit:NSInteger!,
                                        StartRange : NSInteger!)->Any
    {
        
        
        let entity =  NSEntityDescription.entity(forEntityName: Entityname! as String, in: context)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entityname!)
        fetchRequest.entity = entity
        
        if (SortDescriptor?.isEmpty) != nil {
            
            let descriptor: NSSortDescriptor = NSSortDescriptor(key: SortDescriptor!, ascending: true)
            fetchRequest.sortDescriptors = [descriptor]
        }
        
        if(predicate != nil)
        {
            fetchRequest.predicate = predicate!
        }
        
        if(Limit != 0)
        {
            fetchRequest.fetchLimit=Limit;
        }
        fetchRequest.fetchOffset = StartRange
        
        var returnData:Any!
        do {
            returnData = try context.fetch(fetchRequest) as Any
        } catch {
            print(error.localizedDescription)
        }
        return returnData
    }
    
    
    func FetchFromDatabaseWithRange(Entityname:String?, SortDescriptor: String?, predicate:NSPredicate?, Limit:NSInteger!,
                                    StartRange : NSInteger!)->Any
    {
        
        
        let entity =  NSEntityDescription.entity(forEntityName: Entityname! as String, in: context)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entityname!)
        fetchRequest.entity = entity
        
        if (SortDescriptor?.isEmpty) != nil {
            
            let descriptor: NSSortDescriptor = NSSortDescriptor(key: SortDescriptor!, ascending: false)
            fetchRequest.sortDescriptors = [descriptor]
        }
        
        if(predicate != nil)
        {
            fetchRequest.predicate = predicate!
        }
        
        if(Limit != 0)
        {
            fetchRequest.fetchLimit=Limit;
        }
        fetchRequest.fetchOffset = StartRange
        
        var returnData:Any!
        do {
            returnData = try context.fetch(fetchRequest) as Any
        } catch {
            print(error.localizedDescription)
        }
        return returnData
    }
    
    //Delete
    
    func DeleteFromDataBase(Entityname:String?,Predicatefromat:NSPredicate?,Deletestring:String?,AttributeName:String?) {
        //retrieve the entity that we just created
        var Predicatefromat = Predicatefromat
        if(Entityname == Constant.sharedinstance.Chat_one_one && AttributeName == "user_common_id")
        {
            let predicate = NSPredicate(format: "type != %@", "72")
            Predicatefromat = NSCompoundPredicate(andPredicateWithSubpredicates: [Predicatefromat!, predicate])
        }
        let entity =  NSEntityDescription.entity(forEntityName: Entityname!, in: context)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entityname!)
        fetchRequest.entity = entity
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = Predicatefromat!
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            
        } catch let error as NSError {
            debugPrint(error)
        }
    }
    
    func truncateDataForTable(Entityname: String?) {
        
        if Entityname == Constant.sharedinstance.Group_details{
            print("trunacte")
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: Entityname!, in: context)
        fetchRequest.includesPropertyValues = false
        
        
        if let results = try! context.fetch(fetchRequest) as? [NSManagedObject] {
            for result in results {
                context.delete(result)
            }
            print("Deleted \(results.count) Objects")
        }
        
        
        do {
            try context.save()
        }
        catch {
            print(error.localizedDescription)
        }
        
    }
    
    func truncateDataForTables(_ Entitys: [String]) {
        _ = Entitys.map {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
            fetchRequest.entity = NSEntityDescription.entity(forEntityName: $0, in: context)
            fetchRequest.includesPropertyValues = false
            
            
            if let results = try! context.fetch(fetchRequest) as? [NSManagedObject] {
                for result in results {
                    context.delete(result)
                }
                print("Deleted \(results.count) Objects")
            }
            
            
            do {
                try context.save()
            }
            catch {
                print(error.localizedDescription)
            }

        }
    }
    
    func FetchFromDBWithCompletion(Entityname: String?, attribute: String?, FetchString: String?, SortDescriptor: String?, completion: @escaping (Any)->()) {
        
        let entity =  NSEntityDescription.entity(forEntityName: Entityname! as String, in: context)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entityname!)
        fetchRequest.entity = entity
        fetchRequest.returnsObjectsAsFaults = false
        
        if (SortDescriptor?.isEmpty) != nil {
            let descriptor: NSSortDescriptor = NSSortDescriptor(key: SortDescriptor!, ascending: true)
            fetchRequest.sortDescriptors = [descriptor]
        }
        
        if(FetchString != nil) {
            fetchRequest.predicate = NSPredicate(format: "\(attribute!) == %@", FetchString!)
        }
        
        let asyncFetch = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) { (result:NSAsynchronousFetchResult!) -> Void in
            if let result = result.finalResult {
                completion(result)
            }
        }
        
        do {
            // Execute Asynchronous Fetch Request
            try context.execute(asyncFetch)
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
            completion((Any).self)
        }
    }

    func fetchTableAllDataCompletion(Entityname: String?, completion: @escaping (Any)->()) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: Entityname!, in: context)
        fetchRequest.returnsObjectsAsFaults = false
        
        let asyncFetch = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) { (result:NSAsynchronousFetchResult!) -> Void in
            if let result = result.finalResult {
                completion(result)
            }
        }
        
        do {
            // Execute Asynchronous Fetch Request
            try context.execute(asyncFetch)
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
            completion((Any).self)
        }
    }
    
}


