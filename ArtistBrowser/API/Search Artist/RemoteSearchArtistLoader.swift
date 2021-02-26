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
    public let canLoadMore: Bool
    
    public init(items:[Artist], canLoadMore: Bool){
        self.items = items
        self.canLoadMore = canLoadMore
    }
}


public class RemoteSearchArtistLoader: SearchArtistLoader {
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
        case unauthorized
    }
    
    let request: (String, Int) -> URLRequest
    let client: HTTPClient
    
    public init(request: @escaping (String, Int) -> URLRequest, client: HTTPClient){
        self.request = request
        self.client = client
    }
    
    public func load(text: String, page: Int = 0, completion: @escaping (SearchArtistLoader.Result) -> Void) {
        client.get(request: request(text, page)) { result in
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

