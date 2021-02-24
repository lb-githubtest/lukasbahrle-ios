//
//  XCTestCase+Helpers.swift
//  ArtistBrowserTests
//
//  Created by Lukas Bahrle Santana on 24/02/2021.
//

import Foundation
import ArtistBrowser


extension URL{
    static func any() -> URL{
        return URL(string: "any-url")!
    }
}


extension NSError{
    static func any() -> NSError{
        NSError(domain: "any", code: 0)
    }
}


extension Data{
    static func anyJSONData() -> Data{
        "{}".data(using: .utf8)!
    }
    
    static func anyInvalidJsonData() -> Data {
        Data("invalid json".utf8)
    }
}

extension Dictionary where Key: Any, Value:Any {
    var jsonData:Data {
        try! JSONSerialization.data(withJSONObject: self)
    }
}


extension Credentials{
    static func any() -> Credentials{
        Credentials(username: "username", password: "password")
    }
}







struct BasicRequestBuilder: RequestBuilder{
    var baseURL: URL
    var path: String
    
    static func any() -> BasicRequestBuilder{
        return BasicRequestBuilder(baseURL: URL.any(), path: "")
    }
    
}

struct BasicRequest: Request{
    var builder: RequestBuilder
    
    static func any() -> Request{
        BasicRequest(builder: BasicRequestBuilder.any())
    }
}

