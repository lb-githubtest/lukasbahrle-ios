//
//  URLSessionHTTPClient.swift
//  ArtistBrowser
//
//  Created by Lukas Bahrle Santana on 24/02/2021.
//

import Foundation

public final class URLSessionHTTPClient: HTTPClient {
    enum Error: Swift.Error{
        case UnexpectedValuesRepresentation
    }
    
    private let session: URLSession
    
    public init(session: URLSession) {
        self.session = session
    }
    
    public func get(request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) -> CancellableTask{
    
        let task = session.dataTask(with: request) { data, response, error in
            
            completion(Result {
                if let error = error {
                    throw error
                } else if let data = data, let response = response as? HTTPURLResponse {
                    return (data, response)
                } else {
                    throw Error.UnexpectedValuesRepresentation
                }
            })
        }
        task.resume()
        
        return task
    }
}
