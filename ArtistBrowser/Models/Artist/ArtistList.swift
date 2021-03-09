//
//  ArtistList.swift
//  ArtistBrowser
//
//  Created by Lukas Bahrle Santana on 09/03/2021.
//

import Foundation

public struct ArtistList: Equatable{
    public let items:[Artist]
    public let canLoadMore: Bool
    
    public init(items:[Artist], canLoadMore: Bool){
        self.items = items
        self.canLoadMore = canLoadMore
    }
}
