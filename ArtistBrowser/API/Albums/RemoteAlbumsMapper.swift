//
//  RemoteAlbumsMapper.swift
//  ArtistBrowser
//
//  Created by Lukas Bahrle Santana on 28/02/2021.
//

import Foundation


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
        private enum DatePrecision: String{
            case day = "day"
            case year = "year"
        }
        
        let id: String
        let name: String
        let images: [RemoteAlbumImage]
        let release_date: Date
        let release_date_precision: String
        
        func toModel() -> Album{
            Album(id: id, name: name, thumbnail: URL(string: images.first?.url ?? ""), releaseDate: release_date)
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(String.self, forKey: .id)
            name = try container.decode(String.self, forKey: .name)
            images = try container.decode([RemoteAlbumImage].self, forKey: .images)

            let dateString = try container.decode(String.self, forKey: .release_date)
            release_date_precision = try container.decode(String.self, forKey: .release_date_precision)
        
            guard let datePrecision = DatePrecision(rawValue: release_date_precision) else{
                release_date = Date()
                return
            }
            
            let formatter: DateFormatter
            switch datePrecision {
                case .day:
                    formatter = DateFormatter.yyyyMMdd
                case .year:
                    formatter = DateFormatter.yyyy
            }
            
            if let date = formatter.date(from: dateString) {
                release_date = date
            } else {
                throw NSError()
            }
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




