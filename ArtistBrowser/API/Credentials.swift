//
//  Credentials.swift
//  ArtistBrowser
//
//  Created by Lukas Bahrle Santana on 24/02/2021.
//

import Foundation

public struct Credentials{
    public let username: String
    public let password: String
    
    public init(username: String, password: String){
        self.username = username
        self.password = password
    }
}
