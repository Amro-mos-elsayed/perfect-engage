//
//  YoutubeEmbedRequest.swift
//  URLEmbeddedView
//
//  Created by marty-suzuki on 2017/10/08.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import Foundation

struct YoutubeEmbedRequest: OGRequest {
    let url: URL
    
    init?(url: URL) {
        guard
            let escapedString = url.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: "https://www.youtube.com/oembed?url=\(escapedString)")
        else { return nil }
        self.url = url
    }
    
    static func response(data: Data) throws -> OpenGraph.Youtube {
        let rawJson = try JSONSerialization.jsonObject(with: data, options: [])
        let json = try (rawJson as? [AnyHashable : Any]) ?? { throw OGSession.Error.castFaild }()
        return try OpenGraph.Youtube(json: json) ?? { throw OGSession.Error.jsonDecodeFaild }()
    }
}
