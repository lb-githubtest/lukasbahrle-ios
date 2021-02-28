//
//  RemoteAlbumsMapper.swift
//  ArtistBrowser
//
//  Created by Lukas Bahrle Santana on 28/02/2021.
//

import Foundation


public struct Album: Equatable{
    let id: String
    let name: String
    let thumbnail: URL?
    let releaseDate: Date
}

public struct AlbumList: Equatable{
    public let items:[Album]
    public let canLoadMore: Bool
}

class RemoteAlbumsMapper{
    
    private struct AlbumsListRemoteResponse: Codable{
        let items: [RemoteAlbum]
        let limit: Int
        let offset: Int
        let total: Int
        
        func toModel() -> AlbumList{
            AlbumList(items: self.items.map{$0.toModel()}, canLoadMore: offset + limit < total)
        }
    }
    
    private struct RemoteAlbum: Codable{
        let id: String
        let name: String
        let images: [RemoteAlbumImage]
        let release_date: Date
        func toModel() -> Album{
            Album(id: id, name: name, thumbnail: URL(string: images.first?.url ?? ""), releaseDate: release_date)
        }
    }
    
    private struct RemoteAlbumImage: Codable{
        let width: Int
        let height: Int
        let url: String
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> AlbumList {
        
        if response.isUnauthorized {
            throw RemoteSearchArtistLoader.Error.unauthorized
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.yyyyMMdd)
        guard response.isOK, let albumListResponse = try? decoder.decode(AlbumsListRemoteResponse.self, from: data) else {
            throw RemoteSearchArtistLoader.Error.invalidData
        }
        return albumListResponse.toModel()
    }
}




