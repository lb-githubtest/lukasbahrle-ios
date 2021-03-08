//
//  TokenRequestBuilder.swift
//  lukasbahrle-ios
//
//  Created by Lukas Bahrle Santana on 08/03/2021.
//

import ArtistBrowser

struct TokenRequestBuilder: RequestBuilder {
    var baseURL: URL = URL(string: "https://accounts.spotify.com/")!
    
    var path: String =  "api/token"
    
    var httpMethod: HTTPMethod = .POST
    
    var params: [URLQueryItem]?
    
    var headers: [String : String]? =  ["Content-Type": "application/x-www-form-urlencoded"]
    
    var body: Data? = "grant_type=client_credentials".data(using: .utf8)
}
