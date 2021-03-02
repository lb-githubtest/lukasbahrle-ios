//
//  Result+Unauthorized.swift
//  ArtistBrowser
//
//  Created by Lukas Bahrle Santana on 02/03/2021.
//

import Foundation

extension Result where Success == (Data, HTTPURLResponse) {
    var isUnauthorized: Bool {
        (try? self.get().1.isUnauthorized) ?? false
    }
}
