//
//  TokenRequest.swift
//  ArtistBrowser
//
//  Created by Lukas Bahrle Santana on 24/02/2021.
//

import Foundation

struct TokenRequest: Request {
    typealias CredentialsLoader = () -> Credentials
    
    let builder: RequestBuilder
    let credentialsLoader: CredentialsLoader
    
    init(builder: RequestBuilder, credentialsLoader: @escaping CredentialsLoader){
        self.builder = builder
        self.credentialsLoader = credentialsLoader
    }
    
    func get() -> URLRequest {
        let credentials = credentialsLoader()
        
        var request = builder.build()
        let authHeader = URLRequest.basicBase64EncodedAuthorizationHeader(username: credentials.username, password: credentials.password)
        request.addValue(authHeader.value, forHTTPHeaderField: authHeader.key)
       
        return request
    }
    
}

