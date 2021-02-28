//
//  AlbumsLoader.swift
//  ArtistBrowser
//
//  Created by Lukas Bahrle Santana on 28/02/2021.
//

import Foundation

public protocol AlbumsLoader{
    typealias Result = Swift.Result<AlbumList, Error>
    
    @discardableResult
    func load(loadedItems: Int, completion: @escaping (Result) -> Void) -> CancellableTask
}
