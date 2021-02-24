//
//  URLRequest+Basic64EncodedAuthorizationHeader.swift
//  ArtistBrowser
//
//  Created by Lukas Bahrle Santana on 24/02/2021.
//

import Foundation

extension URLRequest {
    static func basicBase64EncodedAuthorizationHeader(username: String, password: String) -> (key: String, value: String){
        let encodedCredentials = Data("\(username):\(password)".utf8).base64EncodedString()
        return ("Authorization", "Basic \(encodedCredentials)")
    }
}
