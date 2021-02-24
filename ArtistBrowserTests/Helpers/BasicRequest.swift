//
//  BasicRequest.swift
//  ArtistBrowserTests
//
//  Created by Lukas Bahrle Santana on 24/02/2021.
//

import Foundation
import ArtistBrowser

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
