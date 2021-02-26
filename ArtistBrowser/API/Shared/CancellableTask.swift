//
//  CancellableTask.swift
//  ArtistBrowser
//
//  Created by Lukas Bahrle Santana on 26/02/2021.
//

import Foundation

public protocol CancellableTask {
    func cancel()
}


extension URLSessionDataTask: CancellableTask{}
