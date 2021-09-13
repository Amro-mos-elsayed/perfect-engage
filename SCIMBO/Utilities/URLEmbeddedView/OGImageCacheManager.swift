//
//  OGImageCacheManager.swift
//  URLEmbeddedView
//
//  Created by Taiki Suzuki on 2016/03/11.
//
//

import UIKit

class OGImageCacheManager: NSObject {
    @objc(sharedInstance)
    static let shared = OGImageCacheManager()
    
    private struct CacheKey {
        static let timeOfExpirationForOGImage = "TimeOfExpirationForOGImageCache"
    }
        
    private let fileManager = FileManager()
    private lazy var memoryCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 30
        return cache
    }()
    private lazy var cacheDirectory: String = {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        return (paths[paths.count-1] as NSString).appendingPathComponent("images")
    }()
    
//    var timeOfExpiration: NSTimeInterval {
//        get {
//            let ud = NSUserDefaults.standardUserDefaults()
//            return ud.doubleForKey(CacheKey.timeOfExpirationForOGImage)
//        }
//        set {
//            let ud = NSUserDefaults.standardUserDefaults()
//            ud.setDouble(newValue, forKey: CacheKey.timeOfExpirationForOGImage)
//            ud.synchronize()
//        }
//    }
    
    private override init() {
        super.init()
        createDirectoriesIfNeeded()
        NotificationCenter.default.addObserver(self, selector: #selector(type(of: self).didReceiveMemoryWarning(_:)), name: UIApplication.didReceiveMemoryWarningNotification , object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }
    
    @objc dynamic func didReceiveMemoryWarning(_ notification: Notification) {
        clearMemoryCache()
    }

    //MARK: - Create directories
    private func createDirectoriesIfNeeded() {
        createRootDirectoryIfNeeded()
        createSubDirectoriesIfNeeded()
    }
    
    private func createRootDirectoryIfNeeded() {
        var isDirectory: ObjCBool = false
        let exists = fileManager.fileExists(atPath: cacheDirectory, isDirectory: &isDirectory)
        if exists && isDirectory.boolValue { return }
        do {
            try fileManager.createDirectory(atPath: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {}
    }
    
    private func createSubDirectoriesIfNeeded() {
        for i in 0..<16 {
            for j in 0..<16 {
                let directoryName = String(format: "%@/%x%x", self.cacheDirectory, i, j)
                var isDirectory: ObjCBool = false
                let exists = fileManager.fileExists(atPath: directoryName, isDirectory: &isDirectory)
                if exists && isDirectory.boolValue { continue }
                do {
                    try fileManager.createDirectory(atPath: directoryName, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    continue
                }
            }
        }
    }

    //MARK: - Read and write
    private func pathForURLString(_ urlString: String) -> String {
        let md5String = urlString.md5()
        if md5String.count < 2 { return cacheDirectory + "/" }
        return cacheDirectory + "/" +  md5String.substring(to: md5String.index(md5String.startIndex, offsetBy: 2)) + "/" + md5String
    }
    
    func cachedImage(urlString: String) -> UIImage? {
        if let image = memoryCache.object(forKey: urlString as NSString) {
            return image
        }
        if let image = UIImage(contentsOfFile: pathForURLString(urlString)) {
            memoryCache.setObject(image, forKey: urlString as NSString)
            return image
        }
        return nil
    }
    
    func storeImage(_ image: UIImage, data: Data, urlString: String) {
        memoryCache.setObject(image, forKey: urlString as NSString)
        try? data.write(to: URL(fileURLWithPath: pathForURLString(urlString)), options: [])
    }

    //MARK: - Cache clear
    func clearMemoryCache() {
        memoryCache.removeAllObjects()
    }
    
    func clearAllCache() {
        clearMemoryCache()
        if !fileManager.fileExists(atPath: cacheDirectory) {
            createDirectoriesIfNeeded()
            return
        }
        do {
            try fileManager.removeItem(atPath: cacheDirectory)
            createDirectoriesIfNeeded()
        } catch {}
    }
}
