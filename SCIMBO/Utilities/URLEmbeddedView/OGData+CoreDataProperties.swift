//
//  OGData+CoreDataProperties.swift
//  URLEmbeddedView
//
//  Created by Taiki Suzuki on 2016/03/12.
//
//

import Foundation
import CoreData

extension OGData {

    @NSManaged public var createDate: Date
    @NSManaged public var imageUrl: String
    @NSManaged public var pageDescription: String
    @NSManaged public var pageTitle: String
    @NSManaged public var pageType: String
    @NSManaged public var siteName: String
    @NSManaged public var sourceUrl: String
    @NSManaged public var updateDate: Date
    @NSManaged public var url: String

}
