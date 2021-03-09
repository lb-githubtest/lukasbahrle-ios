//
//  AlbumList.swift
//  ArtistBrowser
//
//  Created by Lukas Bahrle Santana on 09/03/2021.
//

import Foundation

public struct AlbumList: Equatable{
    public let items:[Album]
    public let canLoadMore: Bool
    
    public init(items: [Album], canLoadMore: Bool) {
        self.items = items
        self.canLoadMore = canLoadMore
    }
}
