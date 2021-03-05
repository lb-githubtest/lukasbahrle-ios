//
//  RemoteTokenMapper.swift
//  ArtistBrowser
//
//  Created by Lukas Bahrle Santana on 24/02/2021.
//

import Foundation

public class RemoteTokenMapper{
    struct TokenRemoteResponse: Codable{
        let access_token: String
        let token_type: String
        let expires_in: Int
        
        func toModel() -> Token {
            return access_token
        }
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> Token {
        guard response.isOK, let tokenResponse = try? JSONDecoder().decode(TokenRemoteResponse.self, from: data) else {
            throw RemoteTokenLoader.Error.invalidData
        }
        return tokenResponse.toModel()
    }
}
