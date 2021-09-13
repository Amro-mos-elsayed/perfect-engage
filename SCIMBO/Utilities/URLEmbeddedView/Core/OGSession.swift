//
//  File.swift
//  URLEmbeddedView
//
//  Created by marty-suzuki on 2017/10/08.
//

import Foundation

final class OGSession {
    private final class Task {
        private let task: URLSessionTask
        private(set) var isExpired: Bool
        
        init(task: URLSessionTask) {
            self.task = task
            self.isExpired = false
        }
        
        func expire(andCancel shouldCancel: Bool) {
            isExpired = true
            if shouldCancel {
                task.cancel()
            }
        }
    }
    
    enum Error: Swift.Error {
        case noData
        case castFaild
        case jsonDecodeFaild
        case htmlDecodeFaild
        case imageGenerateFaild
        case other(Swift.Error)
    }
    
    private let session: URLSession
    private var taskCollection: [String : Task] = [:]
    
    init(configuration: URLSessionConfiguration = .default) {
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: configuration)
    }
    
    func send<T: OGRequest>(_ request: T, uuid: UUID, success: @escaping (T.Response, Bool) -> Void, failure: @escaping (OGSession.Error, Bool) -> Void) {
        let uuidString = uuid.uuidString
        let dataTask = session.dataTask(with: request.urlRequest) { [weak self] data, response, error in
            let isExpired = self?.taskCollection[uuidString]?.isExpired ?? true
            self?.taskCollection.removeValue(forKey: uuidString)
            if let error = error {
                failure((error as? Error) ?? .other(error), isExpired)
                return
            }
            guard let data = data else {
                failure(.noData, isExpired)
                return
            }
            do {
                let response = try T.response(data: data)
                success(response, isExpired)
            } catch let e as Error {
                failure(e, isExpired)
            } catch let e {
                failure(.other(e), isExpired)
            }
        }
        let task = Task(task: dataTask)
        taskCollection[uuid.uuidString] = task
        dataTask.resume()
    }
    
    func cancelLoad(withUUIDString uuidString: String, stopTask: Bool) {
        taskCollection[uuidString]?.expire(andCancel: stopTask)
    }
}
