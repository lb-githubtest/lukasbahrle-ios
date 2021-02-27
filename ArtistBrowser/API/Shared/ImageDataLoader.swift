//
//  ImageDataLoader.swift
//  ArtistBrowser
//
//  Created by Lukas Bahrle Santana on 26/02/2021.
//

import Foundation

public protocol ImageDataLoader{
    func load(from url:URL, completion: @escaping (Result<Data, Error>) -> Void) -> CancellableTask
}

public class RemoteImageDataLoader: ImageDataLoader{
    private var client: HTTPClient
    
    public init(client: HTTPClient){
        self.client = client
    }
    
    public func load(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> CancellableTask {
        
        return client.get(request: URLRequest(url: url)) { (result) in
            switch result{
                case .failure(let error):
                    completion(.failure(error))
                case let .success((data, response)):
                    guard response.isOK else {
                        completion(.failure(NSError()))
                        return
                    }
                    completion(.success(data))
            }
        }
    }
}
