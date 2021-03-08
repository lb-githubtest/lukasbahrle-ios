//
//  SearchArtistRequestBuilder.swift
//  lukasbahrle-ios
//
//  Created by Lukas Bahrle Santana on 08/03/2021.
//

import ArtistBrowser

struct SearchArtistRequestBuilder: RequestBuilder {
    var baseURL: URL = URL(string: "https://api.spotify.com/v1/")!
    
    var path: String =  "search"
    
    var httpMethod: HTTPMethod = .GET
    
    var params: [URLQueryItem]? = [
        URLQueryItem(name: "type", value: "artist"),
        URLQueryItem(name: "limit", value: "20")
    ]
    
    var headers: [String : String]?
    
    var body: Data?
    
    mutating func set(input: String, loadedItems: Int){
        var queryParams = params!
        queryParams.append(URLQueryItem(name: "q", value: input))
        queryParams.append(URLQueryItem(name: "offset", value: "\(loadedItems)"))
        
        params = queryParams
    }
}
