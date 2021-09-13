//
//  OGDataCacheManager.swift
//  URLEmbeddedView
//
//  Created by Taiki Suzuki on 2016/03/11.
//
//

import UIKit
import CoreData

final class OGDataCacheManager: NSObject {
    @objc(sharedInstance)
    static let shared = OGDataCacheManager()
    
    private struct CacheKey {
        static let timeOfExpirationForOGData = "TimeOfExpirationForOGDataCache"
    }
    
    lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle(for: type(of: self)).url(forResource: "URLEmbeddedViewOGData", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("URLEmbeddedViewOGData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        let options = [NSMigratePersistentStoresAutomaticallyOption : true, NSInferMappingModelAutomaticallyOption : true]
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch {
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "URLEmbeddedView-OGDataCache Error", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        return coordinator
    }()
    
    lazy var writerManagedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    lazy var mainManagedObjectContext: NSManagedObjectContext = {
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.parent = self.writerManagedObjectContext
        return managedObjectContext
    }()
    
    lazy var updateManagedObjectContext: NSManagedObjectContext = {
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.parent = self.mainManagedObjectContext
        return managedObjectContext
    }()
    
//    var timeOfExpiration: NSTimeInterval {
//        get {
//            let ud = NSUserDefaults.standardUserDefaults()
//            return ud.doubleForKey(CacheKey.timeOfExpirationForOGData)
//        }
//        set {
//            let ud = NSUserDefaults.standardUserDefaults()
//            ud.setDouble(newValue, forKey: CacheKey.timeOfExpirationForOGData)
//            ud.synchronize()
//        }
//    }
    
    var updateInterval: TimeInterval = {
        let ud = UserDefaults.standard
        guard let updateInterval = ud.updateIntervalForOGData else {
            let interval = 10.days
            ud.updateIntervalForOGData = interval
            return interval
        }
        return updateInterval
    }() {
        didSet { UserDefaults.standard.updateIntervalForOGData = updateInterval }
    }
    
    private override init() {
        super.init()
    }

    func delete(_ object: NSManagedObject, completion: ((NSError?) -> Void)?) {
        object.managedObjectContext?.delete(object)
        saveContext(completion)
    }
    
    func saveContext (_ completion: ((NSError?) -> Void)?) {
        saveContext(updateManagedObjectContext, success: { [weak self] in
            guard let mainManagedObjectContext = self?.mainManagedObjectContext else {
                completion?(NSError(domain: "mainManagedObjectContext is not avairable", code: 9999, userInfo: nil))
                return
            }
            self?.saveContext(mainManagedObjectContext, success: { [weak self] in
                guard let writerManagedObjectContext = self?.writerManagedObjectContext else {
                    completion?(NSError(domain: "writerManagedObjectContext is not avairable", code: 9999, userInfo: nil))
                    return
                }
                self?.saveContext(writerManagedObjectContext, success: {
                    completion?(nil)
                }, failure: { [weak self] in
                    self?.mainManagedObjectContext.rollback()
                    self?.updateManagedObjectContext.rollback()
                    completion?($0)
                })
            }, failure: { [weak self] in
                self?.updateManagedObjectContext.rollback()
                completion?($0)
            })
        }, failure: {
            completion?($0)
        })
    }
    
    private func saveContext(_ context: NSManagedObjectContext, success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        context.perform {
            if !context.hasChanges {
                success?()
            }
            do {
                try context.save()
                success?()
            } catch let e as NSError {
                context.rollback()
                failure?(e)
            }
        }
    }
}
