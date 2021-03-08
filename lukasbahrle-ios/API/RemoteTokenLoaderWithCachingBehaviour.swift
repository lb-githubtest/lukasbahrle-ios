//
//  RemoteTokenLoaderWithCachingBehaviour.swift
//  lukasbahrle-ios
//
//  Created by Lukas Bahrle Santana on 08/03/2021.
//

import ArtistBrowser

class RemoteTokenLoaderWithCachingBehaviour: TokenLoader{
    let tokenLoader: TokenLoader
    let tokenCache: TokenSaver
    
    init(tokenLoader: TokenLoader, tokenCache: TokenSaver){
        self.tokenLoader = tokenLoader
        self.tokenCache = tokenCache
    }
    
    func load(completion: @escaping (TokenLoader.Result) -> Void) {
        tokenLoader.load { [weak self] (result) in
            guard let token = try? result.get() else{
                completion(result)
                return
            }
            
            self?.tokenCache.save(token: token) { _ in
                completion(result)
            }
        }
    }
}
