//
//  RemoteSearchArtistMapper.swift
//  ArtistBrowser
//
//  Created by Lukas Bahrle Santana on 24/02/2021.
//

import Foundation

class RemoteSearchArtistMapper{
    private struct Root: Codable{
        let artists: ArtistListRemoteResponse
        
        func toModel() -> ArtistList{
            artists.toModel()
        }
    }
    
    private struct ArtistListRemoteResponse: Codable{
        let items: [RemoteArtist]
        let limit: Int
        let offset: Int
        let total: Int
        
        func toModel() -> ArtistList{
            ArtistList(items: self.items.map{$0.toModel()}, offset: offset, total: total)
        }
    }
    
    private struct RemoteArtist: Codable{
        let name: String
        func toModel() -> Artist{
            Artist(name: name)
        }
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> ArtistList {
        
        if response.isUnauthorized {
            throw RemoteSearchArtistLoader.Error.unauthorized
        }
        
        guard response.isOK, let artistListResponse = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteSearchArtistLoader.Error.invalidData
        }
        return artistListResponse.toModel()
    }
}
