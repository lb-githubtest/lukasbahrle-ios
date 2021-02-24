//
//  TokenLoader.swift
//  ArtistBrowser
//
//  Created by Lukas Bahrle Santana on 24/02/2021.
//

import Foundation

public typealias Token = String

public protocol TokenLoader{
    typealias Result = Swift.Result<Token, Error>
    
    func load(completion: @escaping (Result) -> Void)
}
