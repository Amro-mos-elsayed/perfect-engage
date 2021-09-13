//
//  OGData.swift
//  URLEmbeddedView
//
//  Created by Taiki Suzuki on 2016/03/11.
//
//

import Foundation
import CoreData

public final class OGData: NSManagedObject {
    fileprivate enum PropertyName: String {
        case description = "og:description"
        case image       = "og:image"
        case siteName    = "og:site_name"
        case title       = "og:title"
        case type        = "og:type"
        case url         = "og:url"
    }

    class func fetchOrInsertOGData(url: String,
                                   managedObjectContext: NSManagedObjectContext = OGDataCacheManager.shared.updateManagedObjectContext,
                                   completion: @escaping (OGData) -> ()) {
        fetchOGData(url: url, managedObjectContext: managedObjectContext) { ogData in
            if let ogData = ogData {
                completion(ogData)
            }
            let newOGData = NSEntityDescription.insertNewObject(forEntityName: "OGData", into: managedObjectContext) as! OGData
            let date = Date()
            newOGData.createDate = date
            newOGData.updateDate = date
            completion(newOGData)
        }
    }
    
    class func fetchOGData(url: String,
                           managedObjectContext: NSManagedObjectContext = OGDataCacheManager.shared.updateManagedObjectContext,
                           completion: @escaping (OGData?) -> ()) {
        managedObjectContext.perform {
            let fetchRequest = NSFetchRequest<OGData>()
            fetchRequest.entity = NSEntityDescription.entity(forEntityName: "OGData", in: managedObjectContext)
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "sourceUrl = %@", url)
            let fetchedList = (try? managedObjectContext.fetch(fetchRequest))
            completion(fetchedList?.first)
        }
    }

    func setValue(_ html: OpenGraph.HTML) {
        html.metaList.forEach {
            guard let propertyName = PropertyName(rawValue: $0.property) else { return }
            switch propertyName  {
            case .siteName    : siteName        = $0.content
            case .type        : pageType        = $0.content
            case .title       : pageTitle       = $0.content
            case .image       : imageUrl        = $0.content
            case .url         : url             = $0.content
            case .description : pageDescription = $0.content.replacingOccurrences(of: "\n", with: " ")
            }
        }
    }
    
    func setValue(_ youtube: OpenGraph.Youtube) {
        self.pageTitle = youtube.title
        self.pageType = youtube.type
        self.siteName = youtube.providerName
        self.imageUrl = youtube.thumbnailUrl
    }
    
    func save() {
        updateDate = Date()
        OGDataCacheManager.shared.saveContext(nil)
    }
}
