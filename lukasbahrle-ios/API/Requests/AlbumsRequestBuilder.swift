//
//  AlbumsRequestBuilder.swift
//  lukasbahrle-ios
//
//  Created by Lukas Bahrle Santana on 08/03/2021.
//

import ArtistBrowser

struct AlbumsRequestBuilder: RequestBuilder {
    var baseURL: URL = URL(string: "https://api.spotify.com/v1/")!
    
    var path: String =  ""
    
    var httpMethod: HTTPMethod = .GET
    
    var params: [URLQueryItem]? = [
        URLQueryItem(name: "limit", value: "20")
    ]
    
    var headers: [String : String]?
    
    var body: Data?
    
    mutating func set(artistId: String, loadedItems: Int){
        
        path = "artists/\(artistId)/albums"
        
        var queryParams = params!
        queryParams.append(URLQueryItem(name: "offset", value: "\(loadedItems)"))
        
        params = queryParams
    }
    
}
