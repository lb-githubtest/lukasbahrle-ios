//
//  TokenCache.swift
//  ArtistBrowser
//
//  Created by Lukas Bahrle Santana on 02/03/2021.
//

import Foundation

public protocol TokenSaver{
    func save(token: Token, completion: @escaping (Result<Void, Error>) -> ())
}

public class TokenCache: TokenLoader, TokenSaver {
    let store: TokenStore
    
    public init(store: TokenStore){
        self.store = store
    }
    public func load(completion: @escaping (TokenLoader.Result) -> Void) {
        store.get(completion: completion)
    }
    
    public func save(token: Token, completion: @escaping (Result<Void, Error>) -> ()) {
        store.save(token: token, completion: completion)
    }
}


