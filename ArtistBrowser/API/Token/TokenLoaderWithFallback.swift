//
//  TokenLoaderWithFallback.swift
//  ArtistBrowser
//
//  Created by Lukas Bahrle Santana on 02/03/2021.
//

import Foundation

public class TokenLoaderFallback: TokenLoader{
    let primaryLoader: TokenLoader
    let fallbackLoader: TokenLoader
    
    public init(primary: TokenLoader, fallback: TokenLoader){
        self.primaryLoader = primary
        self.fallbackLoader = fallback
    }
    
    public func load(completion: @escaping (TokenLoader.Result) -> Void) {
        primaryLoader.load {[weak self] (result) in
            switch result{
            case .success(let token):
                completion(.success(token))
            case .failure(_):
                self?.loadSecondary(completion: completion)
            }
        }
    }
    
    private func loadSecondary(completion: @escaping (TokenLoader.Result) -> Void) {
        
        fallbackLoader.load { (result) in
            switch result{
            case .success(let token):
                completion(.success(token))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
