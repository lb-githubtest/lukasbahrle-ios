//
//  SearchArtistLoader.swift
//  ArtistBrowser
//
//  Created by Lukas Bahrle Santana on 24/02/2021.
//

import Foundation

public protocol SearchArtistLoader{
    typealias Result = Swift.Result<ArtistList, Error>
    
    func load(completion: @escaping (Result) -> Void)
}