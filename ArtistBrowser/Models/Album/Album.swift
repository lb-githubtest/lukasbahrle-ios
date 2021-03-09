//
//  Album.swift
//  ArtistBrowser
//
//  Created by Lukas Bahrle Santana on 09/03/2021.
//

import Foundation

public struct Album: Equatable{
    let id: String
    let name: String
    let thumbnail: URL?
    let releaseDate: Date
    
    public init(id: String, name: String, thumbnail: URL?, releaseDate: Date) {
        self.id = id
        self.name = name
        self.thumbnail = thumbnail
        self.releaseDate = releaseDate
    }
}
