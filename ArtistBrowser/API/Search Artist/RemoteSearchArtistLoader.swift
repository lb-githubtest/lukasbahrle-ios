//
//  RemoteSearchArtistLoader.swift
//  ArtistBrowser
//
//  Created by Lukas Bahrle Santana on 24/02/2021.
//

import Foundation

public struct Artist: Equatable{
    public let id: String
    public let name:String
    public let thumbnail: URL?
    public let genres: [String]
    
    public init(id: String, name:String, thumbnail: URL?, genres: [String]){
        self.id = id
        self.name = name
        self.thumbnail = thumbnail
        self.genres = genres
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
    
    @discardableResult
    public func load(text: String, loadedItems: Int = 0, completion: @escaping (SearchArtistLoader.Result) -> Void) -> CancellableTask {
        client.get(request: request(text, loadedItems)) { result in
            switch result{
            case .failure(let error):
                completion(.failure(error))
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

