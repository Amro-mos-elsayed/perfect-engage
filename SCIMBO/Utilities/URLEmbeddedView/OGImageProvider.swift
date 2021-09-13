//
//  OGImageProvider.swift
//  URLEmbeddedView
//
//  Created by Taiki Suzuki on 2016/03/07.
//
//

import Foundation

public final class OGImageProvider: NSObject {
    private final class Task {
        let innerTask: URLSessionTask
        var shouldExecuteCompletion: Bool
        
        init(innerTask: URLSessionTask) {
            self.innerTask = innerTask
            self.shouldExecuteCompletion = true
        }
    }
    
    //MARK: - Static constants
    @objc(sharedInstance)
    public static let shared = OGImageProvider()
    
    //MARK: - Properties
    private let session = OGSession(configuration: .default)
    
    private override init() {
        super.init()
    }

    @objc public func loadImage(urlString: String, completion: ((UIImage?, Error?) -> Void)? = nil) -> String? {
        guard let url = URL(string: urlString) else {
            completion?(nil, NSError(domain: "can not create NSURL with \(urlString)", code: 9999, userInfo: nil))
            return nil
        }
        if !urlString.isEmpty {
            if let image = OGImageCacheManager.shared.cachedImage(urlString: urlString) {
                completion?(image, nil)
                return nil
            }
        }
        let request = ImageRequest(url: url)
        let uuid = UUID()
        session.send(request, uuid: uuid, success: { value, isExpired in
            OGImageCacheManager.shared.storeImage(value.1, data: value.0, urlString: urlString)
            if !isExpired { completion?(value.1, nil) }
        }, failure: { error, isExpired in
            if !isExpired { completion?(nil,  error) }
        })
        return uuid.uuidString
    }
    
    @objc public func clearMemoryCache() {
        OGImageCacheManager.shared.clearMemoryCache()
    }
    
    @objc public func clearAllCache() {
        OGImageCacheManager.shared.clearAllCache()
    }
    
    func cancelLoad(_ uuidString: String, stopTask: Bool) {
       session.cancelLoad(withUUIDString: uuidString, stopTask: stopTask)
    }
}
