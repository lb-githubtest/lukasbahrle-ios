//
//  KeychainTokenStore.swift
//  ArtistBrowser
//
//  Created by Lukas Bahrle Santana on 02/03/2021.
//

import Foundation

public protocol TokenStore{
    func save(token: Token, completion: @escaping (Result<Void, Error>) -> ())
    func get(completion: @escaping (Result<Token, Error>) -> ())
}

public class KeychainTokenStore: TokenStore{
    public enum Error: Swift.Error{
        case notFoundError
        case saveError
    }
    
    private let key = "KeychainTokenStore.key"
    
    public init(){}
    
    public func save(token: Token, completion: @escaping (Result<Void, Swift.Error>) -> ()) {
        
        guard let data = token.data(using: .utf8) else {
            completion(.failure(Error.saveError))
            return
        }
        
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecValueData: data
        ]
        
        guard SecItemAdd(query as CFDictionary, nil) == noErr else {
            completion(.failure(Error.saveError))
            return
        }
        completion(.success(()))
    }
    
    public func get(completion: @escaping (Result<Token, Swift.Error>) -> ()) {
        
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: kCFBooleanTrue ?? true,
            kSecMatchLimit: kSecMatchLimitOne
        ] as [CFString : Any]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == noErr, let data = result as? Data, let token = String(data: data, encoding: .utf8) else{
            completion(.failure(Error.notFoundError))
            return
        }
        
        completion(.success(token))
    }
    
}
