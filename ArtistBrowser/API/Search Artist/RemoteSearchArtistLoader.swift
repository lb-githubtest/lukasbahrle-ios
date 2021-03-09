//
//  RemoteSearchArtistLoader.swift
//  ArtistBrowser
//
//  Created by Lukas Bahrle Santana on 24/02/2021.
//

import Foundation

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

