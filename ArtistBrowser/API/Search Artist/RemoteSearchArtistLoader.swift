//
//  RemoteSearchArtistLoader.swift
//  ArtistBrowser
//
//  Created by Lukas Bahrle Santana on 24/02/2021.
//

import Foundation

public struct Artist: Equatable{
    public let name:String
    
    public init(name:String){
        self.name = name
    }
}

public struct ArtistList: Equatable{
    public let items:[Artist]
    public let offset: Int
    public let total: Int
    
    public init(items:[Artist], offset: Int, total: Int){
        self.items = items
        self.offset = offset
        self.total = total
    }
}


public class RemoteSearchArtistLoader: SearchArtistLoader {
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
        case unauthorized
    }
    
    let request: (String) -> URLRequest
    let client: HTTPClient
    
    public init(request: @escaping (String) -> URLRequest, client: HTTPClient){
        self.request = request
        self.client = client
    }
    
    public func load(text: String, completion: @escaping (SearchArtistLoader.Result) -> Void) {
        client.get(request: request(text)) { result in
            switch result{
            case .failure(_):
                completion(.failure(Error.connectivity))
            case let .success((data, httpResponse)):
                completion(self.map(data, from: httpResponse))
            }
        }
    }
    
    private func map(_ data: Data, from response: HTTPURLResponse) -> SearchArtistLoader.Result {
        do {
            let list = try RemoteSearchArtistMapper.map(data, from: response)
            return .success(list)
        } catch {
            return .failure(error)
        }
    }
}

