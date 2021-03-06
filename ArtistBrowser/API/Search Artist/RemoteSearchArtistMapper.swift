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
            ArtistList(items: self.items.map{$0.toModel()}, canLoadMore: offset + limit < total)
        }
    }
    
    private struct RemoteArtist: Codable{
        let id: String
        let name: String
        let images: [RemoteArtistImage]
        let genres: [String]
        func toModel() -> Artist{
            Artist(id: id, name: name, thumbnail: URL(string: images.first?.url ?? ""), genres: genres)
        }
    }
    
    private struct RemoteArtistImage: Codable{
        let width: Int
        let height: Int
        let url: String
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
