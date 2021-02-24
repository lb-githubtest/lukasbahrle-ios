//
//  HTTPURLResponse+Status.swift
//  ArtistBrowser
//
//  Created by Lukas Bahrle Santana on 24/02/2021.
//

import Foundation

extension HTTPURLResponse {
    var isOK: Bool {
        statusCode == 200
    }
    
    var isUnauthorized: Bool {
        statusCode == 401
    }
}

