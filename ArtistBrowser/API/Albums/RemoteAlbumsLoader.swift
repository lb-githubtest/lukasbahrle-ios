//
//  RemoteAlbumsLoader.swift
//  ArtistBrowser
//
//  Created by Lukas Bahrle Santana on 28/02/2021.
//

import Foundation

public class RemoteAlbumsLoader: AlbumsLoader {
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
        case unauthorized
    }
    
    let request: (Int) -> URLRequest
    let client: HTTPClient
    
    public init(request: @escaping (Int) -> URLRequest, client: HTTPClient){
        self.request = request
        self.client = client
    }
    
    @discardableResult
    public func load(loadedItems: Int = 0, completion: @escaping (AlbumsLoader.Result) -> Void) -> CancellableTask {
        
        print("\(request(loadedItems).url)")
        
        return client.get(request: request(loadedItems)) { result in
            switch result{
            case .failure(_):
                completion(.failure(Error.connectivity))
            case let .success((data, httpResponse)):
                completion(self.map(data, from: httpResponse))
            }
        }
    }
    
    private func map(_ data: Data, from response: HTTPURLResponse) -> AlbumsLoader.Result {
        do {
            let list = try RemoteAlbumsMapper.map(data, from: response)
            return .success(list)
        } catch {
            return .failure(error)
        }
    }
}
