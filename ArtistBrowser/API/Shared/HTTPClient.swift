//
//  HTTPClient.swift
//  ArtistBrowser
//
//  Created by Lukas Bahrle Santana on 24/02/2021.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    @discardableResult
    func get(request: URLRequest, completion: @escaping (Result) -> Void) -> CancellableTask
}
