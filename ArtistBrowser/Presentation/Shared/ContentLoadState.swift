//
//  ContentLoadState.swift
//  ArtistBrowser
//
//  Created by Lukas Bahrle Santana on 06/03/2021.
//

import Foundation


public enum ContentLoadState: Equatable{
    case notLoaded
    case loading
    case failed
    case loaded(canLoadMore: Bool, countAdded: Int)
    
    public var canLoadMore: Bool {
        switch self {
        case .loaded(canLoadMore: let canLoadMore, countAdded: _):
            return canLoadMore
        default:
            return true
        }
    }
}
