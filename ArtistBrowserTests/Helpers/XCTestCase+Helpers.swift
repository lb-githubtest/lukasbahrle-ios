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


extension URLRequest{
    static func any() -> URLRequest{
        URLRequest(url: URL.any())
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









