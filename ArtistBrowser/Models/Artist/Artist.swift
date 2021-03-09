//
//  Artist.swift
//  ArtistBrowser
//
//  Created by Lukas Bahrle Santana on 09/03/2021.
//

import Foundation

public struct Artist: Equatable{
    public let id: String
    public let name:String
    public let thumbnail: URL?
    public let genres: [String]
    
    public init(id: String, name:String, thumbnail: URL?, genres: [String]){
        self.id = id
        self.name = name
        self.thumbnail = thumbnail
        self.genres = genres
    }
}
