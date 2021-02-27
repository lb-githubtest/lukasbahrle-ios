//
//  Request.swift
//  ArtistBrowser
//
//  Created by Lukas Bahrle Santana on 24/02/2021.
//

import Foundation

public enum HTTPMethod: String{
    case GET = "GET"
    case POST = "POST"
}


public protocol Request {
    var builder: RequestBuilder { get }
    func get() -> URLRequest
}

public extension Request {
    func get() -> URLRequest {
        builder.build()
    }
}



public protocol RequestBuilder{
    var baseURL: URL { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var params: [URLQueryItem]? { get }
    var headers: [String: String]? { get }
    var body: Data? {get}
    
    func build() -> URLRequest
}

public extension RequestBuilder{
    
    func build() -> URLRequest {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false) else {
            fatalError("URL path error")
        }
        components.queryItems = params
        
        guard let url = components.url else {
            fatalError("URL path error")
        }
        
        var request = URLRequest(url: url)
        
        if let headers = headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        request.httpBody = body
        request.httpMethod = httpMethod.rawValue
        return request
    }
}
