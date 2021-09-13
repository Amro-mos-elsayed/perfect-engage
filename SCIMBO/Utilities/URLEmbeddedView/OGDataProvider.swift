//
//  OGDataProvider.swift
//  URLEmbeddedView
//
//  Created by Taiki Suzuki on 2016/03/06.
//
//

import Foundation

public final class OGDataProvider: NSObject {
    //MARK: Static constants
    @objc(sharedInstance)
    public static let shared = OGDataProvider()
        
    //MARK: - Properties
    private let session = OGSession(configuration: .default)
    
    private override init() {
        super.init()
    }
    
    @objc public var updateInterval: TimeInterval {
        get { return OGDataCacheManager.shared.updateInterval }
        set { OGDataCacheManager.shared.updateInterval = newValue }
    }
    
    @discardableResult
    @objc public func fetchOGDataWithUrlString(_ urlString: String, completion: ((OpenGraphData, Error?) -> Void)? = nil) -> String {
        return fetchOGData(urlString: urlString) { completion?($0 as OpenGraphData, $1) }
    }
    
    @discardableResult
    @nonobjc public func fetchOGData(urlString: String, completion: ((OpenGraph.Data, Error?) -> Void)? = nil) -> String {
        let uuid = UUID()
        OGData.fetchOrInsertOGData(url: urlString) { [weak self] ogData in
            guard let me = self else { return }
            if !ogData.sourceUrl.isEmpty {
                completion?(.init(ogData: ogData), nil)
                if fabs(ogData.updateDate.timeIntervalSinceNow) < me.updateInterval {
                    return
                }
            }
            ogData.sourceUrl = urlString
            guard let url = URL(string: urlString) else {
                completion?(.init(ogData: ogData), NSError(domain: "can not create NSURL with \"\(urlString)\"", code: 9999, userInfo: nil))
                return
            }

            let failure: (OGSession.Error, Bool) -> Void = { error, isExpired in
                ogData.managedObjectContext?.perform {
                    if !isExpired { completion?(.init(ogData: ogData), nil) }
                }
            }
            if url.host?.contains("youtube.com") == true {
                guard let request = YoutubeEmbedRequest(url: url) else {
                    completion?(.init(ogData: ogData), NSError(domain: "can not create NSURL with \"\(urlString)\"", code: 9999, userInfo: nil))
                    return
                }
                me.session.send(request, uuid: uuid, success: { youtube, isExpired in
                    ogData.managedObjectContext?.perform {
                        ogData.setValue(youtube)
                        ogData.save()
                        if !isExpired { completion?(.init(ogData: ogData), nil) }
                    }
                }, failure: failure)
            } else {
                let request = HtmlRequest(url: url)
                me.session.send(request, uuid: uuid, success: { html, isExpired in
                    ogData.managedObjectContext?.perform {
                        ogData.setValue(html)
                        ogData.save()
                        if !isExpired { completion?(.init(ogData: ogData), nil) }
                    }
                }, failure: failure)
            }
        }
        return uuid.uuidString
    }
    
    @objc public func deleteOGData(urlString: String, completion: ((NSError?) -> Void)? = nil) {
        OGData.fetchOGData(url: urlString) { [weak self] ogData in
            guard let ogData = ogData else {
                completion?(NSError(domain: "no object matches with \"\(urlString)\"", code: 9999, userInfo: nil))
                return
            }
            self?.deleteOGData(ogData, completion: completion)
        }
    }
    
    @objc public func deleteOGData(_ ogData: OGData, completion: ((NSError?) -> Void)? = nil) {
        OGDataCacheManager.shared.delete(ogData, completion: completion)
    }
    
    func cancelLoad(_ uuidString: String, stopTask: Bool) {
        session.cancelLoad(withUUIDString: uuidString, stopTask: stopTask)
    }
}
