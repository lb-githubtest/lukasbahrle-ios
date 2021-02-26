//
//  RemoteTokenLoader.swift
//  ArtistBrowser
//
//  Created by Lukas Bahrle Santana on 24/02/2021.
//

import Foundation


public class RemoteTokenLoader: TokenLoader{
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    let request: () -> URLRequest
    let client: HTTPClient
    
    public init(request: @escaping () -> URLRequest, client: HTTPClient){
        self.request = request
        self.client = client
    }
    
    public func load(completion: @escaping (TokenLoader.Result) -> Void) {
        client.get(request: request()) { result in
            switch result{
            case let .success((data, httpResponse)):
                completion(self.map(data, from: httpResponse))
            case .failure(_):
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    
    private func map(_ data: Data, from response: HTTPURLResponse) -> TokenLoader.Result {
        do {
            let tokenResponse = try RemoteTokenMapper.map(data, from: response)
            return .success(tokenResponse)
        } catch {
            return .failure(error)
        }
    }
}

